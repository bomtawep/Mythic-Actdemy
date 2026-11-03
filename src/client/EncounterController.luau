--!strict
local Rules = require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("EncounterRules"))
local Scope = require(script.Parent:WaitForChild("ControllerScope"))
return function(player: Player, gui: ScreenGui)
	local scope = Scope.new(function(err) warn(err) end)
	local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
	local anchor = academy:WaitForChild("PH_TrainingSentinel") :: BasePart
	local caster = academy:WaitForChild("PH_DungeonCaster") :: BasePart
	local shade = academy:WaitForChild("PH_DungeonShade") :: BasePart
	local originalTransparency = anchor.LocalTransparencyModifier
	local originalShade = shade.LocalTransparencyModifier
	local zone = Instance.new("Part")
	zone.Name = "PH_PersonalAttackWarning"
	zone:SetAttribute("IsPlaceholder", true)
	zone:SetAttribute("PlaceholderId", "PH-DUN-001")
	zone.Anchored = true
	zone.CanCollide = false
	zone.CanTouch = false
	zone.CanQuery = false
	zone.Size = Vector3.new(Rules.HalfSize * 2, 0.12, Rules.HalfSize * 2)
	zone.Position = Vector3.new(anchor.Position.X, 0.1, anchor.Position.Z)
	zone.Color = Color3.fromRGB(235, 150, 65)
	zone.Transparency = 1
	zone.Parent = workspace
	-- Personal lane marker for the caster's locked volley; the server decides hits.
	local lane = Instance.new("Part")
	lane.Name = "PH_CasterLaneWarning"
	lane:SetAttribute("IsPlaceholder", true)
	lane:SetAttribute("PlaceholderId", "PH-DUN-001")
	lane.Anchored = true
	lane.CanCollide = false
	lane.CanTouch = false
	lane.CanQuery = false
	lane.Size = Vector3.new(Rules.LaneHalfWidth * 2, 0.12, Rules.CasterRoomDepth)
	lane.Color = Color3.fromRGB(150, 110, 235)
	lane.Transparency = 1
	lane.Parent = workspace
	local sign = Instance.new("BillboardGui")
	sign.Name = "PH_SentinelWarning"
	sign:SetAttribute("IsPlaceholder", true)
	sign:SetAttribute("PlaceholderId", "PH-DUN-001")
	sign.Adornee = anchor
	sign.Size = UDim2.fromOffset(230, 66)
	sign.StudsOffset = Vector3.new(0, 4, 0)
	sign.MaxDistance = 45
	sign.Parent = anchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	text.TextColor3 = Color3.fromRGB(255, 245, 220)
	text.TextSize = 17
	text.TextWrapped = true
	text.Parent = sign
	local function refresh()
		local active = Rules.active(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("LevitationStation"))
		sign.Enabled = active
		local phase = player:GetAttribute("EncounterPhase")
		zone.Transparency = if active and phase == "Warning" then 0.5 else 1
		anchor.LocalTransparencyModifier = if phase == "Cleared" then 0.65 else 0
		local aiming = player:GetAttribute("CasterPhase") == "Warning"
		lane.Transparency = if aiming then 0.5 else 1
		if aiming then lane.Position = Vector3.new(player:GetAttribute("CasterLane") or caster.Position.X, 0.36, caster.Position.Z + Rules.CasterRoomDepth / 2) end
		shade.LocalTransparencyModifier = if player:GetAttribute("ShadeRevealed") == true then 1 else 0
		text.Text = if phase == "Cleared" then "ผู้เฝ้าหยุดแล้วสำหรับรันนี้" elseif phase == "Warning" then "กำลังโจมตี! ออกจากพื้นที่สี่เหลี่ยม" elseif phase == "Rest" then "กำลังพัก — ใช้แท่นหยุดผู้เฝ้าได้" else "ผู้เฝ้าฝึก: เข้าใกล้แล้วเตือนโจมตี\nเดินอ้อมได้"
	end
	for _, attribute in {"EncounterPhase", "EncounterCleared", "ProgressReady", "LessonStage", "DungeonState", "DungeonPaused", "LevitationStation", "CasterPhase", "CasterLane", "ShadeRevealed"} do
		scope.connect(player:GetAttributeChangedSignal(attribute), refresh)
	end
	refresh()
	scope.add(function()
		zone:Destroy()
		lane:Destroy()
		sign:Destroy()
		anchor.LocalTransparencyModifier = originalTransparency
		shade.LocalTransparencyModifier = originalShade
	end)

	scope.connect(gui.Destroying, function() scope.dispose() end)
end
