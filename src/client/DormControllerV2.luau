--!strict
local Scope = require(script.Parent:WaitForChild("ControllerScope"))
local Preview = require(script.Parent:WaitForChild("DormPreviewModel"))
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Placement = require(shared:WaitForChild("FurniturePlacement"))
local Catalog = require(shared:WaitForChild("FurnitureCatalog"))
local remote = shared:WaitForChild("DormAction") :: RemoteEvent
return function(player: Player, gui: ScreenGui)
	local scope = Scope.new(function(err) warn(err) end)
	local frame = Instance.new("Frame")
	frame.Name = "PH_DormControls"
	frame:SetAttribute("IsPlaceholder", true)
	frame:SetAttribute("PlaceholderId", "PH-DOR-001")
	frame.AnchorPoint = Vector2.new(0.5,1)
	frame.Position = UDim2.new(0.5,0,1,-150)
	frame.Size = UDim2.new(0.94,0,0,250)
	frame.BackgroundColor3 = Color3.fromRGB(27,33,43)
	frame.Parent = gui
	local max = Instance.new("UISizeConstraint")
	max.MaxSize = Vector2.new(600,250)
	max.Parent = frame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,0,104)
	label.TextWrapped = true
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(245,240,225)
	label.BackgroundTransparency = 1
	label.Parent = frame
	local ghost: Part? = nil
	local draft={x=0,z=0,rotation=0,placed=false}
	local feedback=""
	local function clear()
		if ghost then ghost:Destroy(); ghost=nil end
	end
	local function render()
		frame.Visible=player:GetAttribute("InDorm")==true
		local center=player:GetAttribute("DormCenter")
		local definition=Catalog[player:GetAttribute("DormCatalogId") or ""]
		if not frame.Visible or typeof(center)~="Vector3" or not definition then clear(); return end
		if not ghost then
			local part=Instance.new("Part")
			part.Name="PH_FurniturePreview"
			part:SetAttribute("IsPlaceholder",true)
			part:SetAttribute("PlaceholderId","PH-DOR-001")
			part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
			part.Size=Vector3.new(4,2,2)
			part.Parent=workspace
			ghost=part
		end
		local valid=Placement.inside(player:GetAttribute("DormCatalogId"),draft.x,draft.z,draft.rotation)
		local part=ghost :: Part
		part.Size=Vector3.new(definition.Width,definition.Height,definition.Depth)
		part.CFrame=CFrame.new(center+Vector3.new(draft.x,definition.Height/2,draft.z))*CFrame.Angles(0,math.rad(draft.rotation),0)
		part.Transparency=if draft.placed then 0.55 else 1
		part.Color=if valid then Color3.fromRGB(100,200,150) else Color3.fromRGB(220,95,80)
		label.Text=`{definition.Name} • {player:GetAttribute("DormSelectedId")}\n{if valid then "ขอบเขตผ่าน (เซิร์ฟเวอร์ตรวจวางทับอีกครั้ง)" else "วางไม่ได้: ล้ำขอบหรือพื้นที่หน้าประตู"} • X {draft.x} Z {draft.z}\n{feedback}\n{player:GetAttribute("DormStatus") or "ห้องทดลอง"}\n{player:GetAttribute("DormSaveStatus") or "กำลังโหลดห้อง…"}`
	end
	local function reset()
		draft={x=player:GetAttribute("Dorm_x") or 0,z=player:GetAttribute("Dorm_z") or 0,rotation=player:GetAttribute("Dorm_rotation") or 0,placed=player:GetAttribute("Dorm_placed")==true}
		feedback="ย้าย/หมุนเป็นภาพตัวอย่าง กดยืนยันเพื่อวางจริง"
		render()
	end
	local last=-math.huge
	for index,item in {{"Confirm","ยืนยัน"},{"Store","เก็บ"},{"Rotate","หมุน"},{"Reset","ยกเลิก"},{"Left","ซ้าย"},{"Right","ขวา"},{"Forward","หน้า"},{"Back","หลัง"},{"Next","ชิ้นถัดไป"}} do
		local button=Instance.new("TextButton")
		button.Position=UDim2.new(((index-1)%4)/4,3,0,108+math.floor((index-1)/4)*46)
		button.Size=UDim2.new(0.25,-6,0,42)
		button.Text=item[2]; button.TextSize=17; button.Parent=frame
		scope.connect(button.Activated,function()
			if not frame.Visible then return end
			local action=item[1]
			if action=="Reset" then reset(); return end
			if action=="Confirm" or action=="Store" or action=="Next" then
				if action=="Confirm" and not Placement.inside(player:GetAttribute("DormCatalogId"),draft.x,draft.z,draft.rotation) then feedback="ยังยืนยันไม่ได้ เลื่อนกลับเข้าพื้นที่วาง"; render(); return end
				if os.clock()-last<0.2 then return end
				last=os.clock()
				if action=="Store" or action=="Next" then remote:FireServer(action) else
					local payload=table.clone(draft); payload.placed=true; payload.Id=player:GetAttribute("DormSelectedId"); remote:FireServer("Commit",payload)
				end
				feedback="ส่งคำขอแล้ว รอเซิร์ฟเวอร์ยืนยัน"; render(); return
			end
			draft=Preview.propose(draft,action); feedback="ภาพตัวอย่างเท่านั้น ยังไม่เปลี่ยนตำแหน่งจริง"; render()
		end)
	end
	for _,attribute in {"InDorm","DormRevision"} do scope.connect(player:GetAttributeChangedSignal(attribute),reset) end
	for _,attribute in {"DormCenter","DormStatus","DormSaveStatus"} do scope.connect(player:GetAttributeChangedSignal(attribute),render) end
	scope.add(clear)
	scope.connect(gui.Destroying,function() scope.dispose() end)
	reset()
end
