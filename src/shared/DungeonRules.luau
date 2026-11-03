--!strict
-- Fixed three-room run (D55): puzzle room → sentinel room → finish room.
local Rules = {}
function Rules.nextState(state: string, action: string, ready: any, stage: any): string
	if action == "Exit" then return "Idle" end
	if ready ~= true or stage ~= 3 then return state end
	if state == "Idle" and action == "Enter" then return "Puzzle" end
	if state == "Puzzle" and action == "Solve" then return "Encounter" end
	if state == "Encounter" and action == "Clear" then return "Reward" end
	if state == "Reward" and action == "Finish" then return "Complete" end
	return state
end
-- Where a paused run resumes: the start of the room the player is allowed to be in.
function Rules.recoveryMarker(state: string, paused: any, ready: any, stage: any): string?
	if paused ~= true or ready ~= true or stage ~= 3 then return nil end
	if state == "Puzzle" then return "PH_DungeonArrival" end
	if state == "Encounter" then return "PH_DungeonRoom2Arrival" end
	if state == "Reward" or state == "Complete" then return "PH_DungeonCheckpoint" end
	return nil
end
-- Doors only open once the room before them is done; they never move a player backwards.
-- Room 2 has two exits: the main door behind the shade (needs it revealed) and a longer side door.
function Rules.doorTarget(door: string, state: any, paused: any, shadeRevealed: any): string?
	if paused == true then return nil end
	if door == "DungeonDoor1" and (state == "Encounter" or state == "Reward" or state == "Complete") then return "PH_DungeonRoom2Arrival" end
	local roomTwoDone = state == "Reward" or state == "Complete"
	if door == "DungeonDoor2" and roomTwoDone and shadeRevealed == true then return "PH_DungeonCheckpoint" end
	if door == "DungeonDoor2Side" and roomTwoDone then return "PH_DungeonCheckpoint" end
	return nil
end
return Rules
