--!strict
local Schema = require(script.Parent:WaitForChild("DormSchemaV2"))
local Persistence = require(script.Parent:WaitForChild("DormPersistenceV2"))
local Players = game:GetService("Players")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Placement = require(shared:WaitForChild("FurniturePlacement"))
local Catalog = require(shared:WaitForChild("FurnitureCatalog"))
local remote = shared:WaitForChild("DormAction") :: RemoteEvent
local template = game:GetService("ServerStorage"):WaitForChild("MythicAcademy"):WaitForChild("Room") :: Model
local started = false
return function()
	if started then return end
	started = true
	Persistence.Start()
	local rooms: {[Player]: any} = {}
	local slots: {[number]: boolean} = {}
	local last: {[Player]: number} = {}
	local loading: {[Player]: boolean} = {}
	local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
	local entry = academy:WaitForChild("DormEntry") :: BasePart
	local function rootFor(player: Player): BasePart?
		local character = player.Character
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return nil end
		return root
	end
	local function throttle(player: Player): boolean
		if os.clock() - (last[player] or -math.huge) < 0.2 then return false end
		last[player] = os.clock()
		return true
	end
	local function travel(player: Player, position: Vector3)
		local root = rootFor(player)
		if root and player.Character then
			player.Character:PivotTo(CFrame.new(position))
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end
	local function initialize(player: Player)
		player:SetAttribute("InDorm", false)
		player:SetAttribute("DormStatus", "เข้าห้องเพื่อโหลดตำแหน่งม้านั่ง")
		player.CharacterRemoving:Connect(function() player:SetAttribute("InDorm", false) end)
	end
	Players.PlayerAdded:Connect(initialize)
	for _, player in Players:GetPlayers() do initialize(player) end
	Players.PlayerRemoving:Connect(function(player)
		local room = rooms[player]
		if room then room.model:Destroy(); slots[room.slot] = nil end
		Persistence.Close(player)
		rooms[player], last[player] = nil, nil
	end)
	local function authorized(player: Player, room: any): boolean
		local root = rootFor(player)
		if not room or not root or room.model:GetAttribute("OwnerUserId") ~= player.UserId or player:GetAttribute("InDorm") ~= true or player:GetAttribute("ProgressReady") ~= true then return false end
		local offset = root.Position - room.center
		return math.abs(offset.X) <= 14 and math.abs(offset.Z) <= 16 and math.abs(offset.Y) < 16
	end
	local function publish(player: Player, room: any)
		player:SetAttribute("DormCenter",room.center)
		local selected=room.state[room.selected]
		player:SetAttribute("DormSelectedId",if selected then selected.Id else "")
		player:SetAttribute("DormCatalogId",if selected then selected.CatalogId else "")
		player:SetAttribute("DormItemCount",#room.state)
		if selected then
			for _,key in {"x","z","rotation","placed"} do player:SetAttribute("Dorm_"..key,selected[key]) end
		end
		player:SetAttribute("DormRevision",(player:GetAttribute("DormRevision") or 0)+1)
	end
	local function create(player: Player, state: any)
		local slot = 1
		while slots[slot] do slot += 1 end
		slots[slot] = true
		-- Rooms live off the academy map (x ≥ -400 is school grounds since Step 51); entry is a warp anyway.
		local center = Vector3.new(-1200, 0, slot * 80)
		local model = template:Clone()
		model.Name = `PH_Dorm_{player.UserId}`
		model:SetAttribute("OwnerUserId", player.UserId)
		model:SetAttribute("IsPlaceholder", true)
		model:SetAttribute("PlaceholderId", "PH-DOR-001")
		for _, item in model:GetDescendants() do
			if item:IsA("BasePart") then item.Position += center end
		end
		local base=model:WaitForChild("PH_Bench") :: BasePart
		local parts={}
		for _,item in state do
			local definition=Catalog[item.CatalogId]
			local part=base:Clone()
			part.Name="PH_Furniture_"..item.Id
			part:SetAttribute("IsPlaceholder",true); part:SetAttribute("PlaceholderId","PH-DOR-001")
			part.Size=Vector3.new(definition.Width,definition.Height,definition.Depth)
			part.CFrame=CFrame.new(center+Vector3.new(item.x,definition.Height/2,item.z))*CFrame.Angles(0,math.rad(item.rotation),0)
			part.Transparency=if item.placed then 0 else 1
			part.CanCollide=false
			part:SetAttribute("FurnitureId",item.Id)
			part.Parent=model
			parts[item.Id]=part
		end
		base:Destroy()
		local room={model=model,center=center,slot=slot,parts=parts,state=state,selected=1}
		rooms[player] = room
		local exit = model:WaitForChild("Exit") :: BasePart
		local prompt = exit:WaitForChild("Interact") :: ProximityPrompt
		prompt.Triggered:Connect(function(visitor)
			local root = rootFor(visitor)
			-- Everyone physically inside may leave; guests can never edit another room.
			if root and (root.Position-exit.Position).Magnitude <= 12 and throttle(visitor) then
				visitor:SetAttribute("InDorm", false)
				travel(visitor, entry.Position + Vector3.new(0, 3, 10))
			end
		end)
		model.Parent = workspace
		return room
	end
	local prompt = entry:WaitForChild("Interact") :: ProximityPrompt
	prompt.Triggered:Connect(function(player)
		local root = rootFor(player)
		if not root or (root.Position-entry.Position).Magnitude > 15 or not throttle(player) then return end
		if player:GetAttribute("ProgressReady") ~= true or (player:GetAttribute("LevitationStation") or "") ~= "" or (player:GetAttribute("DungeonState") or "Idle") ~= "Idle" then return end
		if loading[player] then return end
		loading[player]=true
		local state=Persistence.Load(player)
		loading[player]=nil
		if not state then player:SetAttribute("LessonHint",player:GetAttribute("DormSaveStatus") or "โหลดห้องไม่ได้ กรุณาเข้าใหม่ภายหลัง") end
		-- Loading yields; revalidate identity/life/distance and gameplay state afterwards.
		local currentRoot=rootFor(player)
		if not state or player.Parent~=Players or not currentRoot or (currentRoot.Position-entry.Position).Magnitude>15 or player:GetAttribute("ProgressReady")~=true or (player:GetAttribute("LevitationStation") or "")~="" or (player:GetAttribute("DungeonState") or "Idle")~="Idle" then return end
		local room = rooms[player] or create(player,state)
		publish(player,room)
		travel(player, room.center + Vector3.new(0, 4, 10))
		player:SetAttribute("InDorm", true)
		player:SetAttribute("DormStatus", "อยู่ในห้องของคุณ • เลื่อน/หมุนตัวอย่าง แล้วกดยืนยันเพื่อวาง")
	end)
	remote.OnServerEvent:Connect(function(player: Player, action: unknown, payload: unknown)
		if not throttle(player) then return end
		local room = rooms[player]
		if not room or not authorized(player,room) then return end
		if action=="Next" then
			if #room.state>0 then room.selected=room.selected%#room.state+1; publish(player,room) end
			return
		end
		local selected=room.state[room.selected]
		if not selected then return end
		local candidate=nil
		if action=="Commit" and type(payload)=="table" and payload.Id==selected.Id then
			candidate=Placement.replace(room.state,selected.Id,payload)
		elseif action=="Store" then
			local item=table.clone(selected); item.placed=false
			candidate=Placement.replace(room.state,selected.Id,item)
		end
		local decoded=if candidate then Schema.decode({Version=2,Items=candidate}) else nil
		local nextState=if decoded then decoded.Items else nil
		if not nextState then
			player:SetAttribute("DormStatus", "วางไม่ได้: ตรวจสิทธิ์/ขอบเขตห้อง หรือเข้าใกล้ห้องของตัวเอง")
			return
		end
		if not Persistence.Set(player,nextState) then
			player:SetAttribute("DormStatus","ยังแก้ห้องไม่ได้: โหลดไม่พร้อมหรือล็อกหมดอายุ กรุณาเข้าใหม่")
			return
		end
		room.state = nextState
		for _,item in nextState do
			local part=room.parts[item.Id]
			local definition=Catalog[item.CatalogId]
			part.CFrame=CFrame.new(room.center+Vector3.new(item.x,definition.Height/2,item.z))*CFrame.Angles(0,math.rad(item.rotation),0)
			part.Transparency=if item.placed then 0 else 1
		end
		publish(player,room)
		player:SetAttribute("DormStatus","เซิร์ฟเวอร์ยืนยันตำแหน่งชิ้นที่เลือกแล้ว")
	end)
end
