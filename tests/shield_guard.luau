return function(loadGuard)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local distance=0
	local pos=setmetatable({},{__sub=function() return {Magnitude=distance} end})
	local anchor={Position={}}
	local world={WaitForChild=function() return {WaitForChild=function() return {WaitForChild=function() return anchor end} end} end}
	local game={GetService=function() return {WaitForChild=function() return {WaitForChild=function(_,k) return k end} end} end}
	local guard=loadGuard({game=game,workspace=world})
	local attrs={ShieldPassed=true,ProgressReady=true,LessonStage=3,DungeonState="Encounter",EncounterPhase="Warning",EncounterStrikeAt=10}
	local humanoid={Health=100}
	local root={Position=pos,IsA=function() return true end}
	local p={Character={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return humanoid end},GetAttribute=function(_,k) return attrs[k] end,SetAttribute=function(_,k,v) attrs[k]=v end}
	local function reset()
		guard.Reset(p); attrs.ShieldCombatLastAt=nil; attrs.EncounterStrikeAt=10
		attrs.DungeonPaused=false; attrs.DungeonState="Encounter"; attrs.EncounterCleared=false
		attrs.LevitationStation=""; attrs.ProgressReady=true; attrs.EncounterPhase="Warning"; humanoid.Health=100; distance=0
		attrs.CasterPhase="Cooldown"; attrs.CasterStrikeAt=0
	end
	check(guard.Cast(p,9.6),"accepted in window")
	check(not guard.Cast(p,9.7),"duplicate cast cooldown")
	check(guard.Blocked(p,10),"matching strike blocks")
	check(not guard.Blocked(p,10),"cast consumed once")
	reset(); check(guard.Cast(p,8.9) and not guard.Blocked(p,10),"early cast expires")
	reset(); check(not guard.Cast(p,10),"late cast rejected")
	reset(); guard.Cast(p,9.6); attrs.DungeonPaused=true
	check(not guard.Blocked(p,10),"paused run cannot consume old protection")
	reset(); guard.Cast(p,9.6); attrs.DungeonState="Idle"
	check(not guard.Blocked(p,10),"exit rejects stale cast")
	reset(); guard.Cast(p,9.6); humanoid.Health=0
	check(not guard.Blocked(p,10),"dead player cannot block")
	reset(); guard.Cast(p,9.6); attrs.ProgressReady=false
	check(not guard.Blocked(p,10),"lost readiness rejects stale cast")
	reset(); guard.Cast(p,9.6)
	check(not guard.Blocked(p,10.1),"new strike cannot reuse target")
	reset(); guard.Cast(p,9.6); guard.Reset(p)
	check(attrs.ShieldCombatCastAt==nil and attrs.ShieldCombatTarget==nil,"explicit cancel clears both fields")
	reset(); distance=16
	check(not guard.Cast(p,9.6),"cannot cast from outside encounter")
	reset(); attrs.EncounterPhase="Rest"
	check(not guard.Cast(p,9.6),"no cast during rest")
	reset(); attrs.LevitationStation="SentinelControl"
	check(not guard.Cast(p,9.6),"no overlapping levitation")
	reset(); attrs.EncounterCleared=true
	check(not guard.Cast(p,9.6),"cleared enemy cannot accept cast")
	-- Caster volleys can be met anywhere in the room; the earliest pending strike wins.
	reset(); attrs.EncounterPhase="Rest"; distance=40; attrs.CasterPhase="Warning"; attrs.CasterStrikeAt=12
	check(guard.Cast(p,11.7) and attrs.ShieldCombatTarget==12,"far from sentinel, cast meets the caster volley")
	check(guard.Blocked(p,12),"caster volley blocked")
	reset(); attrs.CasterPhase="Warning"; attrs.CasterStrikeAt=12
	check(guard.Cast(p,9.6) and attrs.ShieldCombatTarget==10,"sentinel strike first is chosen first")
	reset(); attrs.CasterPhase="Warning"; attrs.CasterStrikeAt=9.9
	check(guard.Cast(p,9.6) and attrs.ShieldCombatTarget==9.9,"earlier caster volley is chosen over sentinel")
	reset(); attrs.EncounterPhase="Rest"; attrs.CasterPhase="Warning"; attrs.CasterStrikeAt=12
	check(not guard.Cast(p,12),"late cast on caster rejected")
	print(`PASS: {n} shield guard lifecycle checks`)
end
