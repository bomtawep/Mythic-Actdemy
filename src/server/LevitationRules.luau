--!strict
local Rules = {}
function Rules.valid(session: any, context: any): boolean
	if context.ready ~= true or context.stage ~= session.stage or context.station ~= session.name then return false end
	if context.inRange ~= true or context.age < 0 or context.age > context.timeout then return false end
	-- Each dungeon station only works in its own room: puzzle in room 1, sentinel control in room 2.
	if session.name == "DungeonPuzzle" then return context.dungeonState == "Puzzle" and context.paused ~= true end
	if session.name == "SentinelControl" then return context.dungeonState == "Encounter" and context.paused ~= true end
	return true
end
function Rules.height(current: number, action: string, config: any): number
	if action == "Raise" then return math.clamp(current + config.Step, config.StartHeight, config.MaxHeight) end
	if action == "Lower" then return math.clamp(current - config.Step, config.StartHeight, config.MaxHeight) end
	return current
end
return Rules
