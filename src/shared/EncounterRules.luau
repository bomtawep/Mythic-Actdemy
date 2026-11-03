--!strict
local Rules = {}
Rules.WarningSeconds = 1.5
Rules.RestSeconds = 3
Rules.HalfSize = 8
Rules.Damage = 15
Rules.BlocksToClear = 2 -- shield path through room 2; the control station is the path without a shield
function Rules.active(ready: any, stage: any, state: any, paused: any, practice: any): boolean
	return ready == true and stage == 3 and state == "Encounter" and paused ~= true and (practice or "") == ""
end
function Rules.inside(x: number, y: number, z: number): boolean
	return math.abs(x) <= Rules.HalfSize and math.abs(z) <= Rules.HalfSize and math.abs(y) <= 8
end
function Rules.step(phase: string, deadline: number, now: number, active: boolean, inside: boolean): (string, number, boolean)
	if not active then return "Ready", 0, false end
	if phase == "Ready" and inside then return "Warning", now + Rules.WarningSeconds, false end
	if phase == "Warning" and now >= deadline then return "Rest", now + Rules.RestSeconds, inside end
	if phase == "Rest" and now >= deadline then return "Ready", 0, false end
	return phase, deadline, false
end
function Rules.canStartControl(ready: any, stage: any, state: any, paused: any, phase: any, cleared: any): boolean
	return Rules.active(ready, stage, state, paused, "") and phase == "Rest" and cleared ~= true
end
function Rules.canClear(ready: any, stage: any, state: any, paused: any, station: any, cleared: any): boolean
	return ready == true and stage == 3 and state == "Encounter" and paused ~= true and station == "SentinelControl" and cleared ~= true
end
-- Role 2, ranged caster on room 2's back wall: locks the player's lane, warns, then fires down it.
Rules.CasterFirstDelay = 2
Rules.CasterInterval = 4
Rules.CasterWarning = 1.2
Rules.CasterDamage = 10
Rules.LaneHalfWidth = 3
-- Offsets are from the caster on room 2's back wall (room 90×120, SCENE_DESIGN_SLICE §3).
Rules.CasterRoomHalfWidth = 44
Rules.CasterRoomDepth = 114
function Rules.inCasterRoom(dx: number, dz: number): boolean
	return math.abs(dx) <= Rules.CasterRoomHalfWidth and dz >= 0 and dz <= Rules.CasterRoomDepth
end
function Rules.casterStep(phase: string, deadline: number, lane: number, now: number, active: boolean, x: number): (string, number, number, boolean)
	if not active then return "Idle", 0, 0, false end
	if phase == "Idle" then return "Cooldown", now + Rules.CasterFirstDelay, 0, false end
	if phase == "Cooldown" and now >= deadline then return "Warning", now + Rules.CasterWarning, x, false end
	if phase == "Warning" and now >= deadline then return "Cooldown", now + Rules.CasterInterval, lane, math.abs(x - lane) <= Rules.LaneHalfWidth end
	return phase, deadline, lane, false
end
-- Role 3, shade at room 2's main door: hurts on contact until a light rune reveals it; the side door avoids it.
Rules.ShadeRadius = 6
Rules.ShadeDamage = 10
Rules.ShadeInterval = 1.5
function Rules.shadeActive(ready: any, stage: any, state: any, paused: any, revealed: any): boolean
	return ready == true and stage == 3 and (state == "Encounter" or state == "Reward") and paused ~= true and revealed ~= true
end
function Rules.nearShade(dx: number, dz: number): boolean
	return dx * dx + dz * dz <= Rules.ShadeRadius * Rules.ShadeRadius
end
return Rules
