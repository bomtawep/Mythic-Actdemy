--!strict
local player = game:GetService("Players").LocalPlayer
local createHud = require(script.Parent:WaitForChild("HudController"))
local startLevitation = require(script.Parent:WaitForChild("LevitationController"))
local gui = createHud(player)
startLevitation(player, gui)

local startJournal = require(script.Parent:WaitForChild("JournalController"))
startJournal(player, gui)

local startPet = require(script.Parent:WaitForChild("PetController"))
startPet(player, gui)

local startEncounter = require(script.Parent:WaitForChild("EncounterController"))
startEncounter(player, gui)

local useV2 = (game:GetService("ReplicatedStorage"):WaitForChild("DormV2Enabled") :: BoolValue).Value
local startDorm = require(script.Parent:WaitForChild(if useV2 then "DormControllerV2" else "DormController"))
startDorm(player, gui)

local startLightLesson = require(script.Parent:WaitForChild("LightLessonController"))
startLightLesson(player, gui)

local startLightExplore = require(script.Parent:WaitForChild("LightExploreController"))
startLightExplore(player, gui)

local startShieldLesson = require(script.Parent:WaitForChild("ShieldLessonController"))
startShieldLesson(player, gui)

local startCombat = require(script.Parent:WaitForChild("CombatController"))
startCombat(player, gui)
