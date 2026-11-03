-- Real service callbacks with deterministic event/character/world doubles.
return function(loadServices, geometry, newStudent)
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
	function world:GetServerTimeNow() return now end
	local players = {PlayerAdded=signal(), PlayerRemoving=signal(), list={}}
	function players:GetPlayers() return self.list end
	function players:GetPlayerFromCharacter(c) for _, q in self.list do if q.Character == c then return q end end; return nil end
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
	local other = newPlayer(2)
	local heartbeat = signal()
	local remote = {OnServerEvent=signal()}
	local shared = {WaitForChild=function(_, name) if name == "LevitationAction" then return remote end; return name end}
	local services = {Players=players, RunService={Heartbeat=heartbeat}, ReplicatedStorage={WaitForChild=function() return shared end}}
	local env = {
		game={GetService=function(_, name) return services[name] end}, workspace=world,
		Vector3={new=vec,zero=vec(0,0,0)}, os={clock=function() return now end},
		task={spawn=function(f, ...) f(...) end},
	}
	local progress = {Load=function(player)
		player:SetAttribute("ProgressReady",true); player:SetAttribute("LessonStage",if newStudent then 0 else 3); player:SetAttribute("LevitationUnlocked",not newStudent)
	end, Close=function() end, Save=function() end, Advance=function(player,expected)
		if player:GetAttribute("LessonStage")~=expected or expected>=3 then return false end
		player:SetAttribute("LessonStage",expected+1)
		player:SetAttribute("LevitationUnlocked",expected+1>=1)
		player:SetAttribute("LessonRecord",expected+1>=3)
		return true
	end}
	local dungeon, lesson, encounter,guard = loadServices(env, progress)
	dungeon.Start(); lesson.Start(); encounter.Start()
	dungeon.Start(); lesson.Start(); encounter.Start()
	check(academy.DungeonEntry.Interact.Triggered:Count()==1, "dungeon start is idempotent")
	check(academy.DungeonPuzzle.Interact.Triggered:Count()==1, "lesson start is idempotent")
	check(heartbeat:Count()==2, "service starts must not duplicate heartbeat loops")
	local function prompt(name)
		now += 0.8; root.Position=academy[name].Position
		academy[name].Interact.Triggered:Fire(p)
	end
	local function tick(seconds) now += seconds; heartbeat:Fire(seconds) end
	local function action(name) now += 0.2; remote.OnServerEvent:Fire(p,name) end
	if newStudent then
		prompt("DungeonEntry")
		check(p:GetAttribute("DungeonState")=="Idle", "new student cannot enter dungeon early")
		prompt("Reward")
		check(p:GetAttribute("LessonStage")==0, "cannot claim lesson reward early")
		prompt("Lesson"); action("Cancel")
		check(p:GetAttribute("LevitationStation")=="", "first lesson cancel is recoverable")
		prompt("Lesson"); action("Place")
		check(p:GetAttribute("LessonStage")==0 and p:GetAttribute("LevitationHeight")==6, "wrong placement retries same lesson")
		for _=1,3 do action("Raise") end; action("Place")
		check(p:GetAttribute("LessonStage")==1 and p:GetAttribute("LevitationUnlocked"), "first lesson unlocks levitation")
		prompt("Puzzle")
		for _=1,6 do action("Raise") end; action("Place")
		check(p:GetAttribute("LessonStage")==2, "learned spell solves outdoor mechanism")
		prompt("Reward")
		check(p:GetAttribute("LessonStage")==3 and p:GetAttribute("LessonRecord"), "lesson record claimed")
		prompt("Reward")
		check(p:GetAttribute("LessonStage")==3, "duplicate reward does not advance")
		check(other:GetAttribute("LessonStage")==0, "another student keeps separate progress")
	end
	local function at(marker) return root.Position.X==academy[marker].Position.X and root.Position.Z==academy[marker].Position.Z end
	local function solveRoom1()
		prompt("DungeonPuzzle"); for _=1,5 do action("Raise") end; action("Place")
	end
	-- Room 1: puzzle opens the door; nothing ahead works yet.
	prompt("DungeonEntry")
	check(p:GetAttribute("DungeonState")=="Puzzle", "entry starts run")
	check(p:GetAttribute("SentinelHealth")==100, "new run starts with full sentinel health")
	check(root.Position.X==academy.PH_DungeonArrival.Position.X, "entry travels to room 1")
	prompt("DungeonDoor1")
	check(p:GetAttribute("DungeonState")=="Puzzle" and root.Position.Z==academy.DungeonDoor1.Position.Z, "room 1 door stays shut before the puzzle")
	prompt("DungeonFinish")
	check(p:GetAttribute("DungeonState")=="Puzzle", "cannot finish from room 1")
	root.Position=academy.PH_TrainingSentinel.Position
	tick(0.2); tick(2)
	check(p:GetAttribute("EncounterPhase")=="Ready" and humanoid.Health==100, "sentinel is idle until room 2")
	prompt("SentinelControl")
	check(p:GetAttribute("LevitationStation")=="", "control station is closed in room 1")
	solveRoom1()
	check(p:GetAttribute("DungeonState")=="Encounter", "solving room 1 opens room 2")
	prompt("DungeonDoor1")
	check(at("PH_DungeonRoom2Arrival"), "door 1 travels to room 2")
	-- Room 2, control-station path (and the shield consumes one hit on the way).
	prompt("DungeonDoor2")
	check(p:GetAttribute("DungeonState")=="Encounter" and root.Position.Z==academy.DungeonDoor2.Position.Z, "room 2 door stays shut while the sentinel is active")
	root.Position=academy.PH_TrainingSentinel.Position
	tick(0.2)
	check(p:GetAttribute("EncounterPhase")=="Warning", "enter area warns")
	tick(1.6)
	check(humanoid.Health==85 and p:GetAttribute("EncounterPhase")=="Rest", "one hit then rest")
	tick(3.1); tick(0.2)
	local strike=p:GetAttribute("EncounterStrikeAt")
	now=strike-0.3
	check(not guard.Cast(p,now),"untrained player cannot guard encounter")
	p:SetAttribute("ShieldPassed",true)
	check(guard.Cast(p,now),"trained player casts during sentinel warning")
	tick(0.31)
	check(humanoid.Health==85 and string.find(p:GetAttribute("ShieldCombatFeedback"),"สำเร็จ",1,true)~=nil,"sentinel hit consumes guard instead of HP")
	check(p:GetAttribute("EncounterBlocks")==1 and p:GetAttribute("DungeonState")=="Encounter", "one block is not enough to pass")
	p:SetAttribute("SentinelHealth",50)
	p.CharacterRemoving:Fire()
	check(p:GetAttribute("DungeonPaused")==true, "death pauses run")
	prompt("DungeonEntry")
	check(p:GetAttribute("DungeonPaused")==false and at("PH_DungeonRoom2Arrival") and p:GetAttribute("EncounterBlocks")==1, "recovery resumes room 2 with progress")
	check(p:GetAttribute("SentinelHealth")==50, "checkpoint preserves attack progress")
	root.Position=academy.PH_TrainingSentinel.Position
	tick(0.2); tick(1.6)
	check(p:GetAttribute("EncounterPhase")=="Rest", "sentinel rests after striking")
	prompt("SentinelControl")
	check(p:GetAttribute("LevitationStation")=="SentinelControl", "rest allows control")
	action("Place")
	check(p:GetAttribute("EncounterCleared")~=true, "wrong height cannot clear")
	for _=1,4 do action("Raise") end
	action("Place")
	check(p:GetAttribute("EncounterCleared")==true and p:GetAttribute("DungeonState")=="Reward", "control station clears room 2")
	check(p:GetAttribute("LevitationStation")=="", "completion cleans session")
	check(other:GetAttribute("EncounterCleared")==false, "other player independent")
	local health=humanoid.Health
	root.Position=academy.PH_TrainingSentinel.Position
	tick(2); tick(2)
	check(humanoid.Health==health, "cleared enemy does no damage")
	-- Role 3: the shade keeps the main door shut and drains anyone beside it until revealed.
	prompt("DungeonDoor2")
	check(p:GetAttribute("DungeonState")=="Reward" and root.Position.Z==academy.DungeonDoor2.Position.Z and string.find(p:GetAttribute("LessonHint"),"เงาขวางประตู",1,true)~=nil, "shade keeps the main door shut")
	root.Position=academy.PH_DungeonShade.Position
	health=humanoid.Health
	tick(0.2); tick(0.6)
	check(humanoid.Health==health-10, "shade drains on contact")
	tick(1.6)
	check(humanoid.Health==health-20, "shade keeps draining while near")
	root.Position=academy.PH_DungeonRoom2Arrival.Position; tick(2)
	check(humanoid.Health==health-20, "stepping away stops the drain")
	prompt("DungeonShadeRune")
	check(p:GetAttribute("ShadeRevealed")~=true and string.find(p:GetAttribute("LessonHint"),"ประตูข้าง",1,true)~=nil, "without the light spell the rune points to the side door")
	p:SetAttribute("LightCompleted",true)
	prompt("DungeonShadeRune")
	check(p:GetAttribute("ShadeRevealed")==true, "light rune reveals the shade")
	root.Position=academy.PH_DungeonShade.Position; health=humanoid.Health; tick(0.6); tick(1.6)
	check(humanoid.Health==health, "revealed shade does no harm")
	-- Room 3: finish once, recover to the checkpoint, leave from here.
	check(p:GetAttribute("DungeonRoom")==2, "server records room 2")
	prompt("DungeonDoor2")
	check(at("PH_DungeonCheckpoint") and p:GetAttribute("DungeonRoom")==3, "door 2 travels to room 3")
	p.CharacterRemoving:Fire(); prompt("DungeonEntry")
	check(at("PH_DungeonCheckpoint"), "room 3 recovery uses checkpoint")
	prompt("DungeonFinish")
	check(p:GetAttribute("DungeonState")=="Complete" and p:GetAttribute("DungeonCompleted")==true, "finish completes run")
	prompt("DungeonFinish")
	check(p:GetAttribute("DungeonState")=="Complete", "duplicate finish harmless")
	prompt("DungeonExit3")
	check(p:GetAttribute("DungeonState")=="Idle" and at("PH_DungeonReturn"), "room 3 exit returns to school")
	-- Second run, shield path: two blocks clear room 2 without the control station.
	prompt("DungeonEntry")
	check(p:GetAttribute("EncounterCleared")==false and p:GetAttribute("EncounterBlocks")==0 and p:GetAttribute("DungeonState")=="Puzzle", "new run resets encounter")
	solveRoom1(); prompt("DungeonDoor1")
	-- Role 2: the caster locks the player's lane; leaving it dodges, staying is hit, the shield blocks it.
	tick(0.2)
	check(p:GetAttribute("CasterPhase")=="Cooldown", "caster readies when the player walks room 2")
	health=humanoid.Health
	tick(2)
	check(p:GetAttribute("CasterPhase")=="Warning" and p:GetAttribute("CasterLane")==root.Position.X, "caster locks the player's lane")
	root.Position=root.Position+vec(8,0,0)
	tick(1.3)
	check(humanoid.Health==health and p:GetAttribute("CasterPhase")=="Cooldown", "leaving the lane dodges the volley")
	tick(4); tick(1.3)
	check(humanoid.Health==health-10, "staying in the lane is hit")
	tick(4)
	local volley=p:GetAttribute("CasterStrikeAt")
	now=volley-0.3
	check(guard.Cast(p,now), "shield can meet the caster volley")
	tick(0.31)
	check(humanoid.Health==health-10 and string.find(p:GetAttribute("ShieldCombatFeedback"),"ลูกยิง",1,true)~=nil, "shielded volley costs no health")
	check(p:GetAttribute("EncounterBlocks")==0, "caster blocks do not count toward the sentinel")
	root.Position=academy.PH_TrainingSentinel.Position
	tick(0.2)
	check(p:GetAttribute("CasterPhase")=="Idle", "caster holds fire inside the sentinel zone")
	health=humanoid.Health
	for block=1,2 do
		tick(0.2)
		strike=p:GetAttribute("EncounterStrikeAt")
		now=strike-0.3
		check(guard.Cast(p,now), `shield cast {block}`)
		tick(0.31)
		if block==1 then tick(3.1) end
	end
	check(p:GetAttribute("EncounterBlocks")==2 and p:GetAttribute("EncounterCleared")==true and p:GetAttribute("DungeonState")=="Reward", "two blocks clear room 2")
	check(humanoid.Health==health, "blocked strikes cost no health")
	check(p:GetAttribute("ShadeRevealed")==false, "a new run hides the shade again")
	prompt("DungeonDoor2")
	check(not at("PH_DungeonCheckpoint"), "main door is shaded again in the new run")
	prompt("DungeonDoor2Side")
	check(at("PH_DungeonCheckpoint"), "side door reaches room 3 without revealing the shade")
	prompt("DungeonExit3")
	-- Room 2 exit, then room 1 practice lifecycle.
	prompt("DungeonEntry"); solveRoom1(); prompt("DungeonDoor1")
	prompt("DungeonExit2")
	check(p:GetAttribute("DungeonState")=="Idle" and at("PH_DungeonReturn"), "room 2 exit returns to school")
	prompt("DungeonEntry")
	prompt("DungeonPuzzle"); action("Raise"); action("Cancel")
	check(p:GetAttribute("LevitationStation")=="", "cancel clears session")
	prompt("DungeonPuzzle")
	check(p:GetAttribute("LevitationStation")=="DungeonPuzzle", "can restart after cancel")
	prompt("DungeonExit"); tick(0.3)
	check(p:GetAttribute("LevitationStation")=="" and p:GetAttribute("DungeonState")=="Idle", "exit cancels active practice")
	print(`PASS: {checks} {if newStudent then "new-student " else ""}real-service flow checks (event/world doubles)`)
end
