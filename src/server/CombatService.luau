--!strict
local Players = game:GetService("Players")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Rules = require(shared:WaitForChild("CombatRules"))
local Encounter = require(script.Parent:WaitForChild("EncounterService"))
local Service = {}
local started = false
local nextCast: {[Player]: number} = {}
local nextRequest: {[Player]: number} = {}
local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
local target = academy:WaitForChild("PH_TrainingSentinel") :: BasePart

function Service.Cast(player: Player): boolean
	local now = workspace:GetServerTimeNow()
	-- Rate-limit rejected requests too; the client never supplies damage, target or time.
	if now < (nextRequest[player] or 0) then return false end
	nextRequest[player] = now + 0.15
	if not Rules.canCast(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"),
		player:GetAttribute("ShieldPassed"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"),
		player:GetAttribute("EncounterCleared"), player:GetAttribute("LevitationStation")) then return false end
	if now < (nextCast[player] or 0) then return false end
	local character = player.Character
	local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return false end
	local direction = target.Position - root.Position
	if direction.Magnitude > Rules.Range then
		player:SetAttribute("CombatFeedback", "เข้าใกล้ผู้เฝ้าภายใน 24 studs แล้วใช้คลื่นเวท")
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character :: Model}
	local obstruction = workspace:Raycast(root.Position, direction, params)
	if obstruction and obstruction.Instance ~= target then
		player:SetAttribute("CombatFeedback", "มีสิ่งกีดขวางระหว่างคุณกับผู้เฝ้า")
		return false
	end
	nextCast[player] = now + Rules.Cooldown
	player:SetAttribute("CombatReadyAt", nextCast[player])
	local health = player:GetAttribute("SentinelHealth")
	if type(health) ~= "number" then health = Rules.MaxHealth end
	health = math.max(0, health - Rules.Damage)
	player:SetAttribute("SentinelHealth", health)
	player:SetAttribute("CombatFeedback", `คลื่นเวทโดนผู้เฝ้า • พลังผู้เฝ้า {health}/{Rules.MaxHealth}`)
	if health == 0 then Encounter.Defeat(player) end
	return true
end

function Service.Start()
	if started then return end
	started = true
	local remote = shared:WaitForChild("CombatAction") :: RemoteEvent
	remote.OnServerEvent:Connect(function(player, action)
		if action == "Cast" then Service.Cast(player) end
	end)
	Players.PlayerRemoving:Connect(function(player)
		nextCast[player], nextRequest[player] = nil, nil
	end)
end
return Service
