--!strict
local Players = game:GetService("Players")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Rules = require(shared:WaitForChild("DungeonRules"))
local Service = {}
local started = false
local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
local last: {[Player]: number} = {}
local function transition(player: Player, action: string): boolean
	local old = player:GetAttribute("DungeonState") or "Idle"
	local nextState = Rules.nextState(old, action, player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"))
	if nextState == old then return false end
	player:SetAttribute("DungeonState", nextState)
	return true
end
function Service.Solve(player: Player): boolean
	if player:GetAttribute("DungeonPaused") == true then return false end
	return transition(player, "Solve")
end
function Service.Clear(player: Player): boolean
	if player:GetAttribute("DungeonPaused") == true then return false end
	return transition(player, "Clear")
end
function Service.Start()
	if started then return end
	started = true
	local function initialize(player: Player)
		player:SetAttribute("DungeonState", "Idle")
		-- Progress may have restored a saved completion before this runs; keep it.
		if player:GetAttribute("DungeonCompleted") ~= true then player:SetAttribute("DungeonCompleted", false) end
		player:SetAttribute("EncounterCleared", false)
		player:SetAttribute("DungeonPaused", false)
		player.CharacterRemoving:Connect(function()
			if player:GetAttribute("DungeonState") ~= "Idle" then
				player:SetAttribute("DungeonPaused", true)
				player:SetAttribute("LessonHint", "รันพักอยู่: กลับประตูดันเจียนที่ซากวิหารเพื่อไปต่อจาก checkpoint")
			end
		end)
	end
	Players.PlayerAdded:Connect(initialize)
	for _, player in Players:GetPlayers() do initialize(player) end
	Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
	local function connect(name: string, callback: (Player, Model, BasePart) -> ())
		local station = academy:WaitForChild(name) :: BasePart
		local prompt = station:WaitForChild("Interact") :: ProximityPrompt
		prompt.Triggered:Connect(function(player)
			local character = player.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			if not character or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return end
			if (root.Position - station.Position).Magnitude > 15 then return end
			if os.clock() - (last[player] or -math.huge) < 0.75 then return end
			last[player] = os.clock()
			callback(player, character, root)
		end)
	end
	-- Which room a marker belongs to; the run state alone cannot tell "room 2 cleared" from "already in room 3".
	local markerRooms = {PH_DungeonArrival = 1, PH_DungeonRoom2Arrival = 2, PH_DungeonCheckpoint = 3, PH_DungeonReturn = 0}
	local function travel(character: Model, root: BasePart, markerName: string)
		local marker = academy:WaitForChild(markerName) :: BasePart
		character:PivotTo(marker.CFrame + Vector3.new(0, 4, 0))
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		local player = Players:GetPlayerFromCharacter(character)
		if player then player:SetAttribute("DungeonRoom", markerRooms[markerName] or 0) end
	end
	connect("DungeonEntry", function(player, character, root)
		if (player:GetAttribute("LevitationStation") or "") ~= "" then return end
		local recovery = Rules.recoveryMarker(player:GetAttribute("DungeonState") or "Idle", player:GetAttribute("DungeonPaused"), player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"))
		if recovery then
			travel(character, root, recovery)
			player:SetAttribute("DungeonPaused", false)
			player:SetAttribute("LessonHint", "กลับมาที่ checkpoint แล้ว ไปต่อหรือใช้ประตูกลับได้")
			return
		end
		if not transition(player, "Enter") then
			player:SetAttribute("LessonHint", "จบบทเรียนและรับบันทึกก่อนเข้าดันเจียน")
			return
		end
		player:SetAttribute("EncounterCleared", false)
		player:SetAttribute("EncounterBlocks", 0)
		player:SetAttribute("SentinelHealth", 100)
		player:SetAttribute("CombatFeedback", "คลื่นเวทพร้อม • เข้าใกล้ผู้เฝ้าแล้วกด C หรือปุ่มบนจอ")
		player:SetAttribute("ShadeRevealed", false)
		travel(character, root, "PH_DungeonArrival")
		player:SetAttribute("LessonHint", "ห้อง 1/3: ยกผลึกที่แท่นให้ตรงเป้าเพื่อเปิดประตูห้องถัดไป; กลับได้ทุกเมื่อ")
	end)
	-- Every room has its own way back to school.
	for _, exitName in {"DungeonExit", "DungeonExit2", "DungeonExit3"} do
		connect(exitName, function(player, character, root)
			transition(player, "Exit")
			player:SetAttribute("DungeonPaused", false)
			player:SetAttribute("LevitationStation", "")
			travel(character, root, "PH_DungeonReturn")
			player:SetAttribute("LessonHint", "กลับโรงเรียนแล้ว เริ่มดันเจียนใหม่ที่ประตูซากวิหารได้")
		end)
	end
	local finishHint = "ห้อง 3/3: รับผลที่แท่นจบ แล้วกลับโรงเรียน"
	for door, hint in {DungeonDoor1 = "ห้อง 2/3: หลบแนวยิง ผ่านผู้เฝ้า (คลื่นเวทโจมตี หรือแท่นควบคุมตอนพัก หรือกันด้วยม่านคุ้มกัน 2 ครั้ง) แล้วผ่านเงาที่ประตู", DungeonDoor2 = finishHint, DungeonDoor2Side = finishHint} do
		connect(door, function(player, character, root)
			if (player:GetAttribute("LevitationStation") or "") ~= "" then return end
			local state = player:GetAttribute("DungeonState")
			local target = Rules.doorTarget(door, state, player:GetAttribute("DungeonPaused"), player:GetAttribute("ShadeRevealed"))
			if not target then
				player:SetAttribute("LessonHint", if door == "DungeonDoor1" then "ประตูยังปิด: แก้ปริศนาผลึกในห้องนี้ก่อน"
					elseif state ~= "Reward" and state ~= "Complete" then "ประตูยังปิด: ผ่านผู้เฝ้าในห้องนี้ก่อน"
					else "เงาขวางประตู: เผยด้วยอักขระแสง หรือเดินอ้อมไปประตูข้าง")
				return
			end
			travel(character, root, target)
			player:SetAttribute("LessonHint", hint)
		end)
	end
	-- Light path past the shade; without the light spell the side door is always there.
	connect("DungeonShadeRune", function(player)
		local state = player:GetAttribute("DungeonState")
		if player:GetAttribute("DungeonPaused") == true or (state ~= "Encounter" and state ~= "Reward") or player:GetAttribute("ShadeRevealed") == true then return end
		if player:GetAttribute("LightCompleted") ~= true then
			player:SetAttribute("LessonHint", "ต้องผ่านแสงนำทางก่อนจึงเผยเงาได้ ใช้ประตูข้างแทนได้")
			return
		end
		player:SetAttribute("ShadeRevealed", true)
		player:SetAttribute("LessonHint", "แสงเผยเงาแล้ว เงาถอยจากประตูหลัก")
	end)
	connect("DungeonFinish", function(player)
		if player:GetAttribute("DungeonPaused") == true or not transition(player, "Finish") then
			player:SetAttribute("LessonHint", "ผ่านห้องผู้เฝ้าก่อน; รับผลได้ครั้งเดียวต่อรัน")
			return
		end
		player:SetAttribute("DungeonCompleted", true)
		player:SetAttribute("LessonHint", "จบดันเจียน 3 ห้องแล้ว! ได้หน้าบททดสอบภาคสนามในคัมภีร์ ใช้ประตูกลับโรงเรียนได้")
	end)
end
return Service
