return function(Rules)
	local n = 0
	local function check(value) n += 1; assert(value, "Levitation lifecycle rule failed") end
	local session = {stage = 3, name = "DungeonPuzzle"}
	local context = {ready = true, stage = 3, station = "DungeonPuzzle", inRange = true, age = 1, timeout = 60, dungeonState = "Puzzle", paused = false}
	check(Rules.valid(session, context))
	for key, value in {ready = false, stage = 2, station = "", inRange = false, age = 61, dungeonState = "Reward", paused = true} do
		local changed = table.clone(context)
		changed[key] = value
		check(not Rules.valid(session, changed))
	end
	local dead = table.clone(context)
	dead.inRange = false
	check(not Rules.valid(session, dead))
	context.age = 60
	check(Rules.valid(session, context))
	context.age = -1
	check(not Rules.valid(session, context))
	-- Dungeon stations are scoped to their room.
	local control = {stage = 3, name = "SentinelControl"}
	local inRoom2 = {ready = true, stage = 3, station = "SentinelControl", inRange = true, age = 1, timeout = 60, dungeonState = "Encounter", paused = false}
	check(Rules.valid(control, inRoom2))
	for _, state in {"Puzzle", "Reward", "Idle"} do local moved = table.clone(inRoom2); moved.dungeonState = state; check(not Rules.valid(control, moved)) end
	local puzzleInRoom2 = table.clone(context); puzzleInRoom2.age = 1; puzzleInRoom2.dungeonState = "Encounter"
	check(not Rules.valid(session, puzzleInRoom2))
	local config = {StartHeight = 6, MaxHeight = 14, Step = 1}
	check(Rules.height(6, "Lower", config) == 6)
	check(Rules.height(14, "Raise", config) == 14)
	check(Rules.height(9, "Raise", config) == 10)
	check(Rules.height(9, "Lower", config) == 8)
	check(Rules.height(9, "unknown", config) == 9)
	check(Rules.valid({stage = 0, name = "Lesson"}, {ready = true, stage = 0, station = "Lesson", inRange = true, age = 0, timeout = 60}))
	print(`PASS: {n} levitation lifecycle checks`)
end
