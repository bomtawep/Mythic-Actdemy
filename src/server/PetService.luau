--!strict
local Players = game:GetService("Players")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Policy = require(shared:WaitForChild("PetPolicy"))
local remote = shared:WaitForChild("PetAction") :: RemoteEvent
-- Bond activities (D59): each counts once, only with the companion out. Progress persists these attributes.
local BOND_ATTRIBUTES = {Play = "PetBondPlay", Explore = "PetBondExplore", Dungeon = "PetBondDungeon", Dorm = "PetBondDorm"}
return function()
	local last: {[Player]: number} = {}
	local function unlocked(player: Player): boolean
		return Policy.unlocked(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"))
	end
	local function share(player: Player, activity: string)
		local attribute = BOND_ATTRIBUTES[activity]
		if player:GetAttribute("PetEquipped") ~= true or not unlocked(player) or player:GetAttribute(attribute) == true then return end
		player:SetAttribute(attribute, true)
		player:SetAttribute("PetFeedback", `{Policy.ActivityText[activity]} • ความผูกพันเพิ่มขึ้น`)
	end
	local function initialize(player: Player)
		player:SetAttribute("PetEquipped", false)
		local function refresh()
			if not unlocked(player) then
				player:SetAttribute("PetEquipped", false)
			end
		end
		player:GetAttributeChangedSignal("ProgressReady"):Connect(refresh)
		player:GetAttributeChangedSignal("LessonStage"):Connect(refresh)
		-- Shared activities come from state the owning services already publish.
		player:GetAttributeChangedSignal("DungeonState"):Connect(function()
			if player:GetAttribute("DungeonState") == "Complete" then share(player, "Dungeon") end
		end)
		player:GetAttributeChangedSignal("LightDiscovery"):Connect(function()
			if player:GetAttribute("LightDiscovery") == true then share(player, "Explore") end
		end)
		player:GetAttributeChangedSignal("InDorm"):Connect(function()
			if player:GetAttribute("InDorm") == true then share(player, "Dorm") end
		end)
		refresh()
	end
	Players.PlayerAdded:Connect(initialize)
	for _, player in Players:GetPlayers() do initialize(player) end
	Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
	remote.OnServerEvent:Connect(function(player: Player, desired: unknown)
		local now = os.clock()
		if now - (last[player] or -math.huge) < 0.4 then return end
		last[player] = now
		if desired == "Play" then
			if player:GetAttribute("PetEquipped") == true and unlocked(player) then
				player:SetAttribute("PetPlayAt", now)
				share(player, "Play")
			end
			return
		end
		if desired == "Rename" then
			if unlocked(player) then player:SetAttribute("PetNameIndex", Policy.nextName(player:GetAttribute("PetNameIndex"))) end
			return
		end
		if not Policy.allowed(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), desired) then return end
		player:SetAttribute("PetEquipped", desired)
	end)
end
