return function(Rules)
	local n = 0
	local function check(value, message) n += 1; assert(value, message or "Dungeon transition failed") end
	local states = {"Idle", "Puzzle", "Encounter", "Reward", "Complete"}
	for _, state in states do
		check(Rules.nextState(state, "Exit", false, 0) == "Idle")
		for _, action in {"Enter", "Solve", "Clear", "Finish"} do check(Rules.nextState(state, action, false, 3) == state, "not ready cannot advance") end
		check(Rules.nextState(state, "unknown", true, 3) == state)
	end
	for stage = 0, 2 do check(Rules.nextState("Idle", "Enter", true, stage) == "Idle") end
	local state = Rules.nextState("Idle", "Enter", true, 3)
	check(state == "Puzzle", "enter starts room 1")
	for _, skip in {"Clear", "Finish"} do check(Rules.nextState(state, skip, true, 3) == "Puzzle", "room 1 cannot skip ahead") end
	state = Rules.nextState(state, "Solve", true, 3)
	check(state == "Encounter", "solving room 1 opens room 2")
	for _, skip in {"Solve", "Finish", "Enter"} do check(Rules.nextState(state, skip, true, 3) == "Encounter", "room 2 needs a clear") end
	state = Rules.nextState(state, "Clear", true, 3)
	check(state == "Reward", "clearing room 2 opens room 3")
	check(Rules.nextState(state, "Clear", true, 3) == "Reward")
	state = Rules.nextState(state, "Finish", true, 3)
	check(state == "Complete")
	check(Rules.nextState(state, "Finish", true, 3) == "Complete")
	check(Rules.nextState(state, "Enter", true, 3) == "Complete")
	local markers = {Puzzle = "PH_DungeonArrival", Encounter = "PH_DungeonRoom2Arrival", Reward = "PH_DungeonCheckpoint", Complete = "PH_DungeonCheckpoint"}
	for state, marker in markers do
		check(Rules.recoveryMarker(state, true, true, 3) == marker, "recovery resumes the current room")
		check(Rules.recoveryMarker(state, false, true, 3) == nil)
		check(Rules.recoveryMarker(state, true, false, 3) == nil)
		check(Rules.recoveryMarker(state, true, true, 2) == nil)
	end
	check(Rules.recoveryMarker("Idle", true, true, 3) == nil)
	check(Rules.recoveryMarker("unknown", true, true, 3) == nil)
	local room2 = "PH_DungeonRoom2Arrival"
	local room3 = "PH_DungeonCheckpoint"
	local doors = {
		DungeonDoor1 = {[false] = {Encounter = room2, Reward = room2, Complete = room2}, [true] = {Encounter = room2, Reward = room2, Complete = room2}},
		DungeonDoor2 = {[false] = {}, [true] = {Reward = room3, Complete = room3}},
		DungeonDoor2Side = {[false] = {Reward = room3, Complete = room3}, [true] = {Reward = room3, Complete = room3}},
	}
	for door, byReveal in doors do
		for revealed, targets in byReveal do
			for _, state in states do
				check(Rules.doorTarget(door, state, false, revealed) == targets[state], `{door} in {state} revealed={revealed}`)
				check(Rules.doorTarget(door, state, true, revealed) == nil, "paused run uses recovery, not doors")
			end
		end
	end
	check(Rules.doorTarget("DungeonExit", "Complete", false) == nil and Rules.doorTarget("DungeonDoor1", nil, false) == nil)
	print(`PASS: {n} dungeon rule checks`)
end
