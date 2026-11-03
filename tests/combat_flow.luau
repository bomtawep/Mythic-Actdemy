-- Real CombatService -> EncounterService -> DungeonService, with world/network doubles.
return function(load, Rules, Scroll)
	local checks = 0
	local function check(v, message) checks += 1; assert(v, message) end
	local function signal()
		local handlers = {}
		return {Connect = function(_, f) table.insert(handlers, f) end,
			Fire = function(_, ...) for _, f in handlers do f(...) end end,
			Count = function() return #handlers end}
	end
	local mt = {}
	local function vec(x, y, z) return setmetatable({X=x,Y=y,Z=z}, mt) end
	mt.__sub = function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
	mt.__index = function(a,k) if k == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end
	local target = {Position=vec(1320,4,0)}
	local academy = {WaitForChild=function() return target end}
	local now, obstruction, raycasts = 10, nil, 0
	local world = {WaitForChild=function() return {WaitForChild=function() return academy end} end,
		GetServerTimeNow=function() return now end,
		Raycast=function(_, _, _, params)
			raycasts += 1
			check(params.FilterDescendantsInstances[1] ~= nil, "ray excludes attacking character")
			return obstruction
		end}
	local players = {PlayerRemoving=signal()}
	local remote = {OnServerEvent=signal()}
	local shared = {WaitForChild=function(_, name) return if name == "CombatAction" then remote else name end}
	local services = {Players=players, ReplicatedStorage={WaitForChild=function() return shared end}, RunService={}}
	local env = {workspace=world, game={GetService=function(_, name) return services[name] end},
		RaycastParams={new=function() return {} end}, Enum={RaycastFilterType={Exclude="Exclude"}}}
	local combat, encounter = load(env)
	combat.Start(); combat.Start()
	check(remote.OnServerEvent:Count() == 1 and players.PlayerRemoving:Count() == 1, "start is idempotent")
	local function player()
		local attrs = {ProgressReady=true, LessonStage=3, ShieldPassed=true, DungeonState="Encounter", SentinelHealth=100}
		local root = {Position=vec(1320,4,12),IsA=function() return true end}
		local humanoid = {Health=100}
		local p = {GetAttribute=function(_, k) return attrs[k] end, SetAttribute=function(_, k,v) attrs[k]=v end}
		p.Character = {FindFirstChild=function() return root end, FindFirstChildOfClass=function() return humanoid end}
		return p, attrs, root, humanoid
	end
	local p,a,root,h = player()
	local other,b = player()
	local function cast(q) now += 1; return combat.Cast(q or p) end
	for key,value in {ProgressReady=false,LessonStage=2,ShieldPassed=false,DungeonState="Puzzle",DungeonPaused=true,EncounterCleared=true,LevitationStation="DungeonPuzzle"} do
		local old=a[key]; a[key]=value
		check(not cast() and a.SentinelHealth==100, `reject invalid context {key}`)
		a[key]=old
	end
	h.Health=0; check(not cast(), "dead player cannot attack"); h.Health=100
	root.Position=vec(1320,4,25); check(not cast() and a.SentinelHealth==100, "out of range cannot hit")
	root.Position=vec(1320,4,12)
	obstruction={Instance={Name="Wall"}}
	check(not cast() and a.SentinelHealth==100, "wall blocks damage")
	obstruction={Instance=target}
	check(cast() and a.SentinelHealth==75, "ray reaching sentinel deals server damage")
	local rays=raycasts
	check(not combat.Cast(p) and raycasts==rays, "immediate replay is throttled")
	now+=0.2; check(not combat.Cast(p) and a.SentinelHealth==75, "cooldown rejects later replay")
	obstruction=nil
	check(cast() and a.SentinelHealth==50 and b.SentinelHealth==100, "health is per player")
	a.DungeonPaused=true; check(not cast() and a.SentinelHealth==50, "pause preserves partial HP")
	a.DungeonPaused=false
	check(cast() and a.SentinelHealth==25, "resume continues encounter")
	check(not encounter.Defeat(p), "cannot clear enemy before HP reaches zero")
	check(cast() and a.SentinelHealth==0 and a.EncounterCleared and a.DungeonState=="Reward", "four hits use real encounter and dungeon transition")
	check(not cast() and a.SentinelHealth==0, "cannot damage a cleared encounter")
	check(b.DungeonState=="Encounter" and not b.EncounterCleared, "another player's room stays live")
	check(cast(other) and b.SentinelHealth==75, "other player can attack independently")
	now+=1; remote.OnServerEvent:Fire(other,"Unknown",100000)
	check(b.SentinelHealth==75, "unknown action ignored")
	remote.OnServerEvent:Fire(other,"Cast",100000)
	check(b.SentinelHealth==50, "client extra damage is ignored")
	players.PlayerRemoving:Fire(other)
	check(combat.Cast(other) and b.SentinelHealth==25, "removal clears both throttle tables")
	check(string.find(Scroll.mastery(true,true,false),"พร้อมภาคสนาม",1,true)~=nil, "trained student has field goal")
	check(string.find(Scroll.mastery(true,true,true),"ผ่านภาคสนาม",1,true)~=nil, "saved completion derives mastery")
	check(string.find(Scroll.mastery(true,false,true),"ผู้ฝึกหัด",1,true)~=nil, "old completion does not grant unlearned attack")
	check(string.find(Scroll.mastery(false,true,true),"กำลังโหลด",1,true)~=nil, "loading does not advertise progress")
	check(Rules.Damage==25 and Rules.MaxHealth==100, "prototype balance is explicit")
	print(`PASS: {checks} combat service integration checks`)
end
