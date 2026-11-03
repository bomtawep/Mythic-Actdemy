--!strict
-- First combat slice: a short-range pulse against the personal sentinel encounter.
local Rules = {}
Rules.MaxHealth = 100
Rules.Damage = 25
Rules.Range = 24
Rules.Cooldown = 0.9
function Rules.canCast(ready: any, stage: any, learned: any, state: any, paused: any, cleared: any, practice: any): boolean
	return ready == true and stage == 3 and learned == true and state == "Encounter"
		and paused ~= true and cleared ~= true and (practice or "") == ""
end
return Rules
