--!strict
local started = false
local Service = {}
function Service.Start()
	if started then return end
	started = true
	-- Client requests actions, never positions or rewards.
	local Rules = require(script.Parent:WaitForChild("LevitationRules"))
	local Encounter = require(script.Parent:WaitForChild("EncounterService"))
	local EncounterRules = require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("EncounterRules"))
	local Dungeon = require(script.Parent:WaitForChild("DungeonService"))
	local Progress = require(script.Parent:WaitForChild("ProgressService"))
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local shared = ReplicatedStorage:WaitForChild("MythicAcademy")
	local Config = require(shared:WaitForChild("LevitationConfig"))
	local remote = shared:WaitForChild("LevitationAction") :: RemoteEvent
	local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
	type Session = {station: BasePart, stage: number, height: number, target: number, started: number}
	local sessions: {[Player]: Session} = {}
	local lastAction: {[Player]: number} = {}
	local lastPrompt: {[Player]: number} = {}

	local function inRange(player: Player, station: BasePart): boolean
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		return root ~= nil and root:IsA("BasePart") and humanoid ~= nil
			and humanoid.Health > 0 and (root.Position - station.Position).Magnitude <= Config.Range
	end

	local function valid(player: Player, session: Session): boolean
		return Rules.valid({stage = session.stage, name = session.station.Name}, {
			ready = player:GetAttribute("ProgressReady"),
			stage = player:GetAttribute("LessonStage"),
			station = player:GetAttribute("LevitationStation"),
			inRange = inRange(player, session.station),
			age = os.clock() - session.started,
			timeout = Config.Timeout,
			dungeonState = player:GetAttribute("DungeonState"),
			paused = player:GetAttribute("DungeonPaused"),
		})
	end

	local function finish(player: Player, message: string)
		sessions[player] = nil
		player:SetAttribute("LevitationStation", "")
		player:SetAttribute("LessonHint", message)
	end

	local function initialize(player: Player)
		player:SetAttribute("ProgressReady", false)
		player:SetAttribute("LessonStage", 0)
		player:SetAttribute("LevitationUnlocked", false)
		player:SetAttribute("LessonRecord", false)
		player:SetAttribute("LevitationStation", "")
		player:SetAttribute("LessonHint", "เดินไปแท่นฝึกสีม่วง แล้วกดเริ่มฝึก")
		player.CharacterRemoving:Connect(function()
			if sessions[player] then finish(player, "การฝึกหยุดแล้ว กลับไปเริ่มที่แท่นของขั้นปัจจุบันได้") end
		end)
		task.spawn(Progress.Load, player)
	end
	Players.PlayerAdded:Connect(initialize)
	for _, player in Players:GetPlayers() do initialize(player) end
	Players.PlayerRemoving:Connect(function(player)
		sessions[player], lastAction[player], lastPrompt[player] = nil, nil, nil
		Progress.Close(player)
	end)

	local function connectStation(name: string, stage: number, target: number)
		local station = academy:WaitForChild(name) :: BasePart
		local prompt = station:WaitForChild("Interact") :: ProximityPrompt
		prompt.Triggered:Connect(function(player)
			if player:GetAttribute("ProgressReady") ~= true or not inRange(player, station) then return end
			local now = os.clock()
			if now - (lastPrompt[player] or -math.huge) < 0.75 then return end
			lastPrompt[player] = now
			if sessions[player] then return end
			if name == "SentinelControl" and not EncounterRules.canStartControl(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("EncounterPhase"), player:GetAttribute("EncounterCleared")) then
				player:SetAttribute("LessonHint", "รอผู้เฝ้าพักหลังโจมตี แล้วเริ่มใช้แรงลอยตัวเพื่อหยุดผู้เฝ้า")
				return
			end
			if name == "DungeonPuzzle" and (player:GetAttribute("DungeonState") ~= "Puzzle" or player:GetAttribute("DungeonPaused") == true) then return end
			if player:GetAttribute("LessonStage") ~= stage then
				player:SetAttribute("LessonHint", "ทำตามลำดับ: แท่นฝึกสีม่วง → กลไกสีฟ้า → บันทึกสีทอง")
				return
			end
			if stage == 1 and player:GetAttribute("LevitationUnlocked") ~= true then return end
			sessions[player] = {station = station, stage = stage, height = Config.StartHeight, target = target, started = now}
			player:SetAttribute("LevitationHeight", Config.StartHeight)
			player:SetAttribute("LevitationTarget", target)
			player:SetAttribute("LessonHint", "ยก/ลดผลึกให้ตรงกรอบเป้าหมาย แล้วกดวาง; วางผิดลองใหม่ได้")
			player:SetAttribute("LevitationStation", name)
		end)
	end
	connectStation("Lesson", 0, Config.LessonTarget)
	connectStation("Puzzle", 1, Config.PuzzleTarget)
	connectStation("DungeonPuzzle", 3, 11)
	connectStation("SentinelControl", 3, 10)

	remote.OnServerEvent:Connect(function(player: Player, action: unknown)
		-- Constant-size protocol and per-player throttle, including invalid requests.
		local now = os.clock()
		if now - (lastAction[player] or -math.huge) < Config.ActionInterval then return end
		lastAction[player] = now
		if typeof(action) ~= "string" then return end
		local session = sessions[player]
		if not session then return end
		if not valid(player, session) then
			finish(player, "การฝึกหยุดแล้ว กลับไปที่แท่นของขั้นปัจจุบันเพื่อเริ่มใหม่")
			return
		end
		if action == "Cancel" then
			finish(player, "ยกเลิกแล้ว เริ่มฝึกใหม่ที่แท่นได้โดยไม่เสียความก้าวหน้า")
		elseif action == "Raise" or action == "Lower" then
			session.height = Rules.height(session.height, action, Config)
			player:SetAttribute("LevitationHeight", session.height)
		elseif action == "Place" then
			if session.height ~= session.target then
				session.height = Config.StartHeight
				player:SetAttribute("LevitationHeight", session.height)
				player:SetAttribute("LessonHint", "ยังไม่ตรงเป้าหมาย ผลึกกลับจุดเริ่มแล้ว ลองยกให้ตรงกรอบก่อนวาง")
				return
			end
			-- No yields between validation and progress update.
			if session.station.Name == "SentinelControl" then
				if not Encounter.Clear(player) then return end
				finish(player, "หยุดผู้เฝ้าแล้ว! ไปประตูท้ายห้องสู่ห้องจบ")
			elseif session.station.Name == "DungeonPuzzle" then
				if not Dungeon.Solve(player) then return end
				finish(player, "ปริศนาสำเร็จ! ประตูท้ายห้องเปิดแล้ว ไปห้องผู้เฝ้า")
			elseif session.stage == 0 then
				if not Progress.Advance(player, 0) then return end
				finish(player, "ผ่านบทฝึกแล้ว! ไปใช้แรงลอยตัวกับกลไกสีฟ้า")
			else
				if not Progress.Advance(player, 1) then return end
				finish(player, "กลไกทำงานแล้ว! รับบันทึกที่แท่นสีทอง")
			end
			task.spawn(Progress.Save, player)
		end
	end)

	local reward = academy:WaitForChild("Reward") :: BasePart
	local rewardPrompt = reward:WaitForChild("Interact") :: ProximityPrompt
	rewardPrompt.Triggered:Connect(function(player)
		if player:GetAttribute("ProgressReady") ~= true or not inRange(player, reward) then return end
		local now = os.clock()
		if now - (lastPrompt[player] or -math.huge) < 0.75 then return end
		lastPrompt[player] = now
		if sessions[player] or player:GetAttribute("LessonStage") ~= 2 or player:GetAttribute("LessonRecord") == true then
			player:SetAttribute("LessonHint", "ต้องผ่านบทฝึกและกลไกก่อน; บันทึกนี้รับได้ครั้งเดียว")
			return
		end
		if not Progress.Advance(player, 2) then return end
		player:SetAttribute("LessonHint", "ได้บันทึกแรงลอยตัวแล้ว! ทดลองเวทแสงที่แท่นฝั่งซ้ายลานได้")
		task.spawn(Progress.Save, player)
	end)

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.25 then return end
		elapsed = 0
		for player, session in sessions do
			if not valid(player, session) then
				finish(player, "ออกนอกระยะหรือหมดเวลาฝึก กลับไปเริ่มใหม่ที่แท่นได้")
			end
		end
	end)

end
return Service
