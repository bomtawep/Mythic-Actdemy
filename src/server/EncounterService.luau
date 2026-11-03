--!strict
local Guard = require(script.Parent:WaitForChild("ShieldGuard"))
local Dungeon = require(script.Parent:WaitForChild("DungeonService"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Rules = require(shared:WaitForChild("EncounterRules"))
local Service = {}
local started = false
-- Both ways through room 2 end here: the sentinel stops and the run moves on to the finish room.
local function clear(player: Player)
	Guard.Reset(player)
	player:SetAttribute("EncounterCleared", true)
	player:SetAttribute("EncounterStrikeAt",0)
	player:SetAttribute("EncounterPhase", "Cleared")
	Dungeon.Clear(player)
	player:SetAttribute("LessonHint", "ผ่านห้องผู้เฝ้าแล้ว! ไปประตูท้ายห้องสู่ห้องจบ")
end
-- Control-station path: levitation during the sentinel's rest.
function Service.Clear(player: Player): boolean
	if not Rules.canClear(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("LevitationStation"), player:GetAttribute("EncounterCleared")) then return false end
	clear(player)
	return true
end
-- Combat is a third way through the personal encounter; only the server can reduce this HP.
function Service.Defeat(player: Player): boolean
	if player:GetAttribute("SentinelHealth") ~= 0 or player:GetAttribute("ShieldPassed") ~= true then return false end
	if not Rules.active(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("LevitationStation")) or player:GetAttribute("EncounterCleared") == true then return false end
	clear(player)
	return true
end
function Service.Start()
	if started then return end
	started = true
	local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
	local anchor = academy:WaitForChild("PH_TrainingSentinel") :: BasePart
	local caster = academy:WaitForChild("PH_DungeonCaster") :: BasePart
	local shade = academy:WaitForChild("PH_DungeonShade") :: BasePart
	local states: {[Player]: {phase: string, deadline: number}} = {}
	local volleys: {[Player]: {phase: string, deadline: number, lane: number}} = {}
	local shadeNext: {[Player]: number} = {}
	Players.PlayerRemoving:Connect(function(player) states[player], volleys[player], shadeNext[player] = nil, nil, nil end)
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then return end
		elapsed = 0
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			local alive = root ~= nil and root:IsA("BasePart") and humanoid ~= nil and humanoid.Health > 0
			local active = player:GetAttribute("EncounterCleared") ~= true and alive and Rules.active(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("LevitationStation"))
			local inside = false
			if alive and root and root:IsA("BasePart") then
				local offset = root.Position - anchor.Position
				inside = Rules.inside(offset.X, offset.Y, offset.Z)
			end
			local now = workspace:GetServerTimeNow()
			local state = states[player] or {phase = "Ready", deadline = 0}
			local phase, deadline, hit = Rules.step(state.phase, state.deadline, now, active, inside)
			states[player] = {phase = phase, deadline = deadline}
			if phase=="Warning" and state.phase~="Warning" then player:SetAttribute("ShieldCombatFeedback","ผู้เฝ้าเตรียมโจมตี • หลบหรือกดคุ้มกันให้ตรงจังหวะ") end
			player:SetAttribute("EncounterStrikeAt",if phase=="Warning" then deadline else 0)
			player:SetAttribute("EncounterPhase", if player:GetAttribute("EncounterCleared") == true then "Cleared" else phase)
			if hit and humanoid then
				local blocked=Guard.Blocked(player,state.deadline)
				if not blocked then humanoid:TakeDamage(Rules.Damage) end
				player:SetAttribute("ShieldCombatFeedback",if blocked then "ม่านคุ้มกันป้องกันผู้เฝ้าสำเร็จ" else "โดนผู้เฝ้าโจมตี • หลบหรือกดคุ้มกันให้ตรงจังหวะ")
				-- Shield path: enough blocks in this run clears the room like the control station does.
				if blocked then
					local blocks = (player:GetAttribute("EncounterBlocks") or 0) + 1
					player:SetAttribute("EncounterBlocks", blocks)
					if blocks >= Rules.BlocksToClear then
						clear(player)
						states[player] = {phase = "Ready", deadline = 0}
						continue
					end
				end
			end
			-- Role 2: the caster fires down the lane it locked when its warning began.
			local inRoom, x = false, 0
			if alive and root and root:IsA("BasePart") then
				local fromCaster = root.Position - caster.Position
				inRoom = Rules.inCasterRoom(fromCaster.X, fromCaster.Z)
				x = root.Position.X
			end
			local volley = volleys[player] or {phase = "Idle", deadline = 0, lane = 0}
			-- One telegraph at a time: the caster holds fire on players inside the sentinel's zone.
			local vPhase, vDeadline, lane, shot = Rules.casterStep(volley.phase, volley.deadline, volley.lane, now, active and inRoom and not inside, x)
			volleys[player] = {phase = vPhase, deadline = vDeadline, lane = lane}
			player:SetAttribute("CasterPhase", vPhase)
			player:SetAttribute("CasterStrikeAt", if vPhase == "Warning" then vDeadline else 0)
			player:SetAttribute("CasterLane", lane)
			if vPhase == "Warning" and volley.phase ~= "Warning" then player:SetAttribute("ShieldCombatFeedback", "ผู้ยิงเล็งแนวของคุณ • เดินออกจากแนวที่เตือนหรือกดคุ้มกัน") end
			if shot and humanoid then
				local blocked = Guard.Blocked(player, volley.deadline)
				if not blocked then humanoid:TakeDamage(Rules.CasterDamage) end
				player:SetAttribute("ShieldCombatFeedback", if blocked then "ม่านคุ้มกันกันลูกยิงสำเร็จ" else "โดนลูกยิง • เดินออกจากแนวที่เตือนหรือกดคุ้มกัน")
			end
			-- Role 3: the shade drains anyone beside the main door until it is revealed.
			local near = false
			if alive and root and root:IsA("BasePart") and Rules.shadeActive(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("ShadeRevealed")) then
				local fromShade = root.Position - shade.Position
				near = Rules.nearShade(fromShade.X, fromShade.Z)
			end
			if near and humanoid then
				local due = shadeNext[player] or now + 0.5
				if now >= due then
					humanoid:TakeDamage(Rules.ShadeDamage)
					due = now + Rules.ShadeInterval
					player:SetAttribute("ShieldCombatFeedback", "เงาดูดพลัง • ถอยออก เผยด้วยอักขระแสง หรือใช้ประตูข้าง")
				end
				shadeNext[player] = due
			else
				shadeNext[player] = nil
			end
			-- Drop a cast once nothing can still meet it (its strike passed unconsumed) or the room is no longer live.
			local target = player:GetAttribute("ShieldCombatTarget")
			if not active or (type(target) == "number" and now >= target) then Guard.Reset(player) end
		end
	end)
end
return Service
