-- Real service callbacks with deterministic event/character/world doubles.
return function(loadService, geometry, loadOther)
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
	local other,otherRoot = newPlayer(2)
	local heartbeat = signal()
	local remote = {OnServerEvent=signal()}
	local shared={WaitForChild=function(_,name) return name end}
	local services={Players=players,RunService={Heartbeat=heartbeat},ReplicatedStorage={WaitForChild=function() return shared end}}
	local env={game={GetService=function(_,name) return services[name] end},workspace=world,os={clock=function() return now end}}
	local start=loadService(env); start(); start()
	p:SetAttribute("ProgressReady",true); p:SetAttribute("LessonStage",3)
	other:SetAttribute("ProgressReady",true); other:SetAttribute("LessonStage",3)
	local function prompt(name,who,position)
		now+=0.5
		if not who then who=p; root.Position=academy[name].Position end
		academy[name].Interact.Triggered:Fire(who)
	end
	local function tick() now+=0.3; heartbeat:Fire(0.3) end
	check(academy.LightLesson.Interact.Triggered:Count()==1,"no duplicate start")
	prompt("LightRune1")
	check(p:GetAttribute("LightBits")==0,"cannot cast before lesson")
	p:SetAttribute("LessonStage",2); prompt("LightLesson")
	check(not p:GetAttribute("LightUnlocked"),"stage gate")
	p:SetAttribute("LessonStage",3); prompt("LightLesson")
	check(p:GetAttribute("LightUnlocked") and p:GetAttribute("LightTrialActive"),"lesson enables trial")
	prompt("LightRune1")
	check(p:GetAttribute("LightBits")==3,"rune I toggles group")
	academy.LightRune1.Interact.Triggered:Fire(p)
	check(p:GetAttribute("LightBits")==3,"throttle rejects repeat")
	check(other:GetAttribute("LightBits")==0 and not other:GetAttribute("LightUnlocked"),"players independent")
	otherRoot.Position=academy.LightLesson.Position; prompt("LightLesson",other)
	otherRoot.Position=academy.LightRune2.Position; prompt("LightRune2",other)
	check(other:GetAttribute("LightBits")==7,"second player can cast independently")
	check(p:GetAttribute("LightBits")==3,"second player cast does not change first")
	prompt("LightRune3")
	check(p:GetAttribute("LightCompleted") and not p:GetAttribute("LightTrialActive"),"correct pattern completes")
	check(p:GetAttribute("LightBits")==5,"target state preserved")
	prompt("LightRune2")
	check(p:GetAttribute("LightBits")==5,"cannot mutate finished trial")
	prompt("LightLesson")
	check(p:GetAttribute("LightBits")==0 and p:GetAttribute("LightCompleted"),"retry resets puzzle but keeps session achievement")
	root.Position=vec(1000,0,0)
	now+=0.5; academy.LightRune1.Interact.Triggered:Fire(p)
	check(p:GetAttribute("LightBits")==0,"out-of-range prompt rejected")
	tick(); check(not p:GetAttribute("LightTrialActive"),"walking away stops trial")
	prompt("LightLesson"); humanoid.Health=0; tick()
	check(not p:GetAttribute("LightTrialActive"),"death stops before CharacterRemoving")
	humanoid.Health=100; prompt("LightLesson"); p.CharacterRemoving:Fire()
	check(not p:GetAttribute("LightTrialActive"),"character removal stops trial")
	prompt("LightLesson"); p:SetAttribute("DungeonState","Puzzle"); tick()
	check(not p:GetAttribute("LightTrialActive"),"dungeon transition stops light trial")
	p:SetAttribute("DungeonState","Idle"); prompt("LightLesson"); p:SetAttribute("InDorm",true); tick()
	check(not p:GetAttribute("LightTrialActive"),"dorm transition stops trial")
	p:SetAttribute("InDorm",false); prompt("LightLesson"); p:SetAttribute("ProgressReady",false); tick()
	check(not p:GetAttribute("LightTrialActive"),"lost profile readiness stops trial")
	check(p:GetAttribute("LessonStage")==3,"light never modifies saved lesson stage")
	if loadOther then
		local startExplore=loadOther(env); startExplore(); startExplore()
		p:SetAttribute("ProgressReady",true); p:SetAttribute("InDorm",false); p:SetAttribute("DungeonState","Idle")
		prompt("LightLesson"); prompt("LightExploreStart")
		check(not p:GetAttribute("LightExploreActive"),"shared factory prevents explore while lesson active")
		p:SetAttribute("LightTrialActive",false); prompt("LightExploreStart")
		check(p:GetAttribute("LightExploreActive"),"shared factory accepts completed lesson prerequisite")
		prompt("LightLesson")
		check(not p:GetAttribute("LightTrialActive"),"shared factory prevents lesson while explore active")
	end
	print(`PASS: {checks} light lesson service flow checks`)
end
