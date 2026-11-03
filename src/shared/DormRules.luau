--!strict
local Rules = {}
function Rules.inside(x: number, z: number, rotation: number): boolean
	local halfX = if rotation % 180 == 0 then 2 else 1
	local halfZ = if rotation % 180 == 0 then 1 else 2
	return math.abs(x) + halfX <= 12 and math.abs(z) + halfZ <= 10
end
function Rules.apply(state: any, action: any, authorized: boolean): any
	if not authorized or type(action) ~= "string" then return nil end
	local nextState = table.clone(state)
	if action == "Place" then nextState.placed = true
	elseif action == "Store" then nextState.placed = false
	elseif action == "Left" then nextState.x -= 2
	elseif action == "Right" then nextState.x += 2
	elseif action == "Forward" then nextState.z -= 2
	elseif action == "Back" then nextState.z += 2
	elseif action == "Rotate" then nextState.rotation = (nextState.rotation + 90) % 360
	else return nil end
	if not Rules.inside(nextState.x, nextState.z, nextState.rotation) then return nil end
	return nextState
end
return Rules
