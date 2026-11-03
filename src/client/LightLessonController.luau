--!strict
local Presentation=require(script.Parent:WaitForChild("LightPresentation"))
local Configs=require(script.Parent:WaitForChild("LightPresentationConfigs"))
return Presentation.new(Configs.Lesson)
