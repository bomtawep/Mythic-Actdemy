--!strict
local Factory=require(script.Parent:WaitForChild("LightPuzzleService"))
local Configs=require(script.Parent:WaitForChild("LightPuzzleConfigs"))
return Factory.new(Configs.Explore)
