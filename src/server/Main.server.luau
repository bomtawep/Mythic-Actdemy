--!strict
-- Compose services once; gameplay lives in its owning module.
local Progress = require(script.Parent:WaitForChild("ProgressService"))
local Dungeon = require(script.Parent:WaitForChild("DungeonService"))
local Lesson = require(script.Parent:WaitForChild("LessonService"))
Progress.Start()
Dungeon.Start()
Lesson.Start()
local Encounter = require(script.Parent:WaitForChild("EncounterService"))
Encounter.Start()
local Combat = require(script.Parent:WaitForChild("CombatService"))
Combat.Start()
local useV2 = (game:GetService("ReplicatedStorage"):WaitForChild("DormV2Enabled") :: BoolValue).Value
local startDorm = require(script.Parent:WaitForChild(if useV2 then "DormServiceV2" else "DormService"))
startDorm()

local startLightLesson = require(script.Parent:WaitForChild("LightLessonService"))
startLightLesson()

local startLightExplore = require(script.Parent:WaitForChild("LightExploreService"))
startLightExplore()

local startShieldLesson = require(script.Parent:WaitForChild("ShieldLessonService"))
startShieldLesson()
