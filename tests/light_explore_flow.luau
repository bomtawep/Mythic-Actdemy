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
	local shared={WaitForChild=function(_,name) return name end}
	local services={Players=players,RunService={Heartbeat=heartbeat},ReplicatedStorage={WaitForChild=function() return shared end}}
	local env={game={GetService=function(_,name) return services[name] end},workspace=world,os={clock=function() return now end}}
	local start=loadService(env); start(); start()
	p:SetAttribute("ProgressReady",true); p:SetAttribute("LessonStage",3)
	other:SetAttribute("ProgressReady",true); other:SetAttribute("LessonStage",3)
	local function prompt(name) now+=0.5; root.Position=academy[name].Position; academy[name].Interact.Triggered:Fire(p) end
	local function tick() now+=0.3; heartbeat:Fire(0.3) end
	check(academy.LightExploreStart.Interact.Triggered:Count()==1,"single registration")
	prompt("LightExploreStart")
	check(not p:GetAttribute("LightExploreActive"),"must pass lesson first")
	p:SetAttribute("LightCompleted",true); prompt("LightExploreStart")
	check(p:GetAttribute("LightExploreActive") and p:GetAttribute("LightExploreBits")==0,"exploration begins independently")
	prompt("ExploreRune1"); prompt("ExploreRune2")
	check(not p:GetAttribute("LightDiscovery"),"partial pattern not discovered")
	prompt("ExploreRune3")
	check(p:GetAttribute("LightExploreBits")==2 and p:GetAttribute("LightDiscovery"),"new target unlocks discovery")
	check(not p:GetAttribute("LightExploreActive"),"completion ends trial")
	check(other:GetAttribute("LightExploreBits")==0 and not other:GetAttribute("LightDiscovery"),"other explorer independent")
	check(p:GetAttribute("LightCompleted")==true and p:GetAttribute("LessonStage")==3,"no changes to previous progress")
	prompt("LightExploreStart")
	check(p:GetAttribute("LightExploreBits")==0 and p:GetAttribute("LightDiscovery"),"retry preserves session discovery")
	root.Position=vec(1000,0,0); tick()
	check(not p:GetAttribute("LightExploreActive"),"can leave freely")
	prompt("LightExploreStart"); p.CharacterRemoving:Fire()
	check(not p:GetAttribute("LightExploreActive"),"death cancels exploration")
	p:SetAttribute("LightTrialActive",true); prompt("LightExploreStart")
	check(not p:GetAttribute("LightExploreActive"),"cannot overlap original lesson")
	print(`PASS: {checks} light exploration service checks`)
end
