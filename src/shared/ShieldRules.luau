--!strict
local Rules={Window=0.6,Interval=3,FirstWarning=2,Rounds=3,RequiredBlocks=2,Cooldown=1,Damage=10}
function Rules.blocked(castAt: number, strikeAt: number): boolean
	return castAt==castAt and strikeAt==strikeAt and castAt<=strikeAt and strikeAt-castAt<=Rules.Window
end
function Rules.result(blocks: number, attempts: number): string
	if attempts<Rules.Rounds then return "Continue" end
	return if blocks>=Rules.RequiredBlocks then "Passed" else "Retry"
end
return table.freeze(Rules)
