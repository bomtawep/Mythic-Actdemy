-- Real service callbacks with deterministic event/character/world doubles.
return function(loadService, geometry)
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
	function world:GetServerTimeNow() return now end
	local shared={WaitForChild=function(_,name) return if name=="ShieldAction" then remote else name end}
	local services={Players=players,RunService={Heartbeat=heartbeat},ReplicatedStorage={WaitForChild=function() return shared end}}
	local env={game={GetService=function(_,name) return services[name] end},workspace=world}
	local start=loadService(env); start(); start()
	p:SetAttribute("ProgressReady",true); p:SetAttribute("LessonStage",3)
	local function begin() now+=0.5; root.Position=academy.ShieldLesson.Position; academy.ShieldLesson.Interact.Triggered:Fire(p) end
	local function tick(at) now=at; heartbeat:Fire(0.1) end
	local function castBefore(seconds) now=p:GetAttribute("ShieldStrikeAt")-seconds; remote.OnServerEvent:Fire(p,"Cast") end
	check(academy.ShieldLesson.Interact.Triggered:Count()==1,"single start registration")
	begin(); check(not p:GetAttribute("ShieldTrialActive"),"must finish light lesson")
	p:SetAttribute("LightCompleted",true); begin()
	check(p:GetAttribute("ShieldTrialActive") and p:GetAttribute("ShieldUnlocked"),"training starts")
	castBefore(0.3); tick(p:GetAttribute("ShieldStrikeAt")+0.01)
	check(p:GetAttribute("ShieldBlocks")==1 and humanoid.Health==100,"on-time cast blocks")
	castBefore(1.2); tick(p:GetAttribute("ShieldStrikeAt")+0.01)
	check(p:GetAttribute("ShieldBlocks")==1 and humanoid.Health==90,"early cast expires and misses")
	castBefore(0.2); tick(p:GetAttribute("ShieldStrikeAt")+0.01)
	check(p:GetAttribute("ShieldPassed") and not p:GetAttribute("ShieldTrialActive"),"two of three passes")
	check(not other:GetAttribute("ShieldPassed"),"other player independent")
	tick(now+5); check(humanoid.Health==90,"completed session never hits again")
	begin()
	for _=1,3 do tick(p:GetAttribute("ShieldStrikeAt")+0.01) end
	check(not p:GetAttribute("ShieldTrialActive") and humanoid.Health==60,"all missed finishes with retry")
	check(p:GetAttribute("ShieldPassed"),"retry does not erase session achievement")
	begin(); root.Position=vec(1000,0,0); tick(now+0.1)
	check(not p:GetAttribute("ShieldTrialActive"),"leave range cancels")
	begin(); p.CharacterRemoving:Fire()
	check(not p:GetAttribute("ShieldTrialActive"),"death cleanup")
	begin(); p:SetAttribute("ProgressReady",false); tick(now+0.1)
	check(not p:GetAttribute("ShieldTrialActive"),"lost readiness cancels")
	p:SetAttribute("ProgressReady",true); begin()
	now+=0.2; remote.OnServerEvent:Fire(p,{action="Cast"})
	check(p:GetAttribute("ShieldUntil")==nil or p:GetAttribute("ShieldUntil")<now,"forged action rejected")
	p:SetAttribute("InDorm",true); tick(now+0.1)
	check(not p:GetAttribute("ShieldTrialActive"),"dorm transition cancels")
	check(p:GetAttribute("LessonStage")==3,"does not alter persistent lesson stage")
	print(`PASS: {checks} shield lesson service flow checks`)
end
