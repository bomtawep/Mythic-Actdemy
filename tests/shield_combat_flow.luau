-- Real service callbacks with deterministic event/character/world doubles.
return function(loadServices, geometry)
	local checks = 0
	local function check(v, message) checks += 1; assert(v, message) end
	local function signal()
		local callbacks = {}
		return {Count = function() return #callbacks end, Connect = function(_, f) table.insert(callbacks, f) end, Fire = function(_, ...)
			for _, f in callbacks do f(...) end
		end}
	end
	local mt = {}
	local function vec(x, y, z) return setmetatable({X=x, Y=y, Z=z}, mt) end
	mt.__sub = function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
	mt.__add = function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
	mt.__index = function(a,k) if k == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end
	local now = 10
	local academy = {}
	for name, pos in geometry do
		local node = {Name=name, Position=vec(pos[1],pos[2],pos[3]), Interact={Triggered=signal()}}
		node.CFrame = node.Position
		function node:WaitForChild(k) return self[k] end
		academy[name] = node
	end
	function academy:WaitForChild(k) return assert(self[k], k) end
	local world = {WaitForChild=function() return {WaitForChild=function() return academy end} end}
	local players = {PlayerAdded=signal(), PlayerRemoving=signal(), list={}}
	function players:GetPlayers() return self.list end
	local function newPlayer(id)
		local attrs = {}
		local root = {Position=vec(0,4,0), IsA=function(_, k) return k == "BasePart" end}
		local humanoid = {Health=100}
		function humanoid:TakeDamage(n) self.Health -= n end
		local character = {FindFirstChild=function() return root end, FindFirstChildOfClass=function() return humanoid end}
		function character:PivotTo(pos) root.Position = pos end
		local p = {UserId=id, Character=character, CharacterRemoving=signal(), Parent=players}
		function p:SetAttribute(k,v) attrs[k]=v end
		function p:GetAttribute(k) return attrs[k] end
		table.insert(players.list,p)
		return p, root, humanoid
	end
	local p, root, humanoid = newPlayer(1)
	local other,otherRoot,otherHumanoid = newPlayer(2)
	local heartbeat = signal()
	local remote = {OnServerEvent=signal()}
	function world:GetServerTimeNow() return now end
	local shared={WaitForChild=function(_,name) return if name=="ShieldAction" then remote else name end}
	local services={Players=players,RunService={Heartbeat=heartbeat},ReplicatedStorage={WaitForChild=function() return shared end}}
	local env={game={GetService=function(_,name) return services[name] end},workspace=world}
	local startShield,encounter=loadServices(env)
	startShield(); encounter.Start(); startShield(); encounter.Start()
	p:SetAttribute("ProgressReady",true); p:SetAttribute("LessonStage",3); p:SetAttribute("LightCompleted",true)
	other:SetAttribute("ProgressReady",true); other:SetAttribute("LessonStage",3)
	root.Position=academy.ShieldLesson.Position
	academy.ShieldLesson.Interact.Triggered:Fire(p)
	check(p:GetAttribute("ShieldTrialActive"),"real training started")
	for _=1,3 do
		now=p:GetAttribute("ShieldStrikeAt")-0.3
		remote.OnServerEvent:Fire(p,"Cast")
		now=p:GetAttribute("ShieldStrikeAt")+0.01; heartbeat:Fire(0.1)
	end
	check(p:GetAttribute("ShieldPassed") and humanoid.Health==100,"training earns permission without fixture grant")
	p:SetAttribute("DungeonState","Encounter"); other:SetAttribute("DungeonState","Encounter")
	root.Position=academy.PH_TrainingSentinel.Position; otherRoot.Position=root.Position
	now+=0.2; heartbeat:Fire(0.2)
	check(p:GetAttribute("EncounterPhase")=="Warning" and other:GetAttribute("EncounterPhase")=="Warning","independent warnings start")
	local strike=p:GetAttribute("EncounterStrikeAt")
	now=strike-0.3; remote.OnServerEvent:Fire(p,"Cast"); remote.OnServerEvent:Fire(other,"Cast")
	check(p:GetAttribute("ShieldCombatTarget")==strike,"ShieldAction routes through lesson service to combat guard")
	check(other:GetAttribute("ShieldCombatTarget")==nil,"untrained other cannot copy cast")
	now=strike+0.01; heartbeat:Fire(0.1)
	check(humanoid.Health==100 and otherHumanoid.Health==85,"only casting trained player protected")
	check(p:GetAttribute("ShieldCombatTarget")==nil,"hit consumes cast")
	check(string.find(p:GetAttribute("ShieldCombatFeedback"),"สำเร็จ",1,true)~=nil,"server feedback confirms block")
	now+=0.2; remote.OnServerEvent:Fire(p,"Cast")
	check(p:GetAttribute("ShieldCombatTarget")==nil,"remote cast in rest rejected")
	now+=3.1; heartbeat:Fire(3.1); now+=0.1; heartbeat:Fire(0.1)
	strike=p:GetAttribute("EncounterStrikeAt")
	now=strike-0.3; remote.OnServerEvent:Fire(p,"Cast")
	p:SetAttribute("DungeonPaused",true)
	now=strike+0.01; heartbeat:Fire(0.1)
	check(p:GetAttribute("ShieldCombatTarget")==nil and humanoid.Health==100,"paused run resets accepted cast without damage")
	p:SetAttribute("DungeonPaused",false); now+=0.1; heartbeat:Fire(0.1)
	strike=p:GetAttribute("EncounterStrikeAt")
	now=strike-0.3; remote.OnServerEvent:Fire(p,"Cast"); humanoid.Health=0
	now=strike+0.01; heartbeat:Fire(0.1)
	check(p:GetAttribute("ShieldCombatTarget")==nil and humanoid.Health==0,"death cancels cast before hit")
	p.CharacterRemoving:Fire(); humanoid.Health=100
	now+=0.1; heartbeat:Fire(0.1)
	strike=p:GetAttribute("EncounterStrikeAt")
	now=strike+0.01; heartbeat:Fire(0.1)
	check(humanoid.Health==85,"respawn cannot reuse previous life cast")
	p:SetAttribute("DungeonState","Idle"); now+=0.2; heartbeat:Fire(0.2)
	now+=1; remote.OnServerEvent:Fire(p,"Cast")
	check(p:GetAttribute("ShieldCombatTarget")==nil,"outside run cannot cast")
	check(p:GetAttribute("LessonStage")==3 and not other:GetAttribute("ShieldPassed"),"progress remains separate")
	check(academy.ShieldLesson.Interact.Triggered:Count()==1,"no duplicate prompt registration")
	print(`PASS: {checks} shield action/encounter routing checks`)
end
