-- Real LessonService prompts with the real ProgressService on a keyed DataStore double:
-- claim → save → leave → rejoin → duplicate claim, including a save outage at claim time,
-- then a learned spell from the real light lesson that must survive rejoin.
return function(loadServices, newProgress, loadLight, loadShield, loadPets, geometry, Scroll)
	local checks = 0
	local function check(v, message) checks += 1; assert(v, message) end
	local function signal()
		local callbacks = {}
		return {Connect = function(_, f) table.insert(callbacks, f) end, Fire = function(_, ...)
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
	local function join(id)
		local attrs, changed = {}, {}
		local root = {Position=vec(0,4,0), IsA=function(_, k) return k == "BasePart" end}
		local humanoid = {Health=100}
		local character = {FindFirstChild=function() return root end, FindFirstChildOfClass=function() return humanoid end}
		function character:PivotTo(pos) root.Position = pos end
		local p = {UserId=id, Character=character, CharacterRemoving=signal(), Parent=players, root=root}
		function p:SetAttribute(k,v)
			local old = attrs[k]; attrs[k]=v
			if old ~= v and changed[k] then changed[k]:Fire() end
		end
		function p:GetAttribute(k) return attrs[k] end
		function p:GetAttributeChangedSignal(k)
			if not changed[k] then
				local list, s = {}, {}
				function s:Connect(f) local item={on=true,f=f}; table.insert(list,item); return {Disconnect=function() item.on=false end} end
				function s:Fire() for _, item in list do if item.on then item.f() end end end
				changed[k] = s
			end
			return changed[k]
		end
		table.insert(players.list, p)
		players.PlayerAdded:Fire(p)
		return p
	end
	local function leave(p)
		players.PlayerRemoving:Fire(p)
		p.Parent = nil
		table.remove(players.list, table.find(players.list, p))
	end

	-- One record per key, like the live store; writes run the service's transform.
	local db = {records={}, writes=0, failSave=false}
	function db:GetAsync(key) return self.records[key] end
	function db:UpdateAsync(key, transform)
		self.writes += 1
		if self.failSave then error("simulated write outage") end
		local result = transform(self.records[key])
		if result then self.records[key] = result end
		return result
	end
	local progressServices = {Players=players, RunService={IsStudio=function() return false end}, DataStoreService={GetDataStore=function() return db end}}
	local progress = newProgress({GetService=function(_, name) return progressServices[name] end}, {wait=function() end, spawn=function(f, ...) f(...) end})

	local heartbeat = signal()
	local remote = {OnServerEvent=signal()}
	local shieldRemote, petRemote = {OnServerEvent=signal()}, {OnServerEvent=signal()}
	local remotes = {LevitationAction=remote, ShieldAction=shieldRemote, PetAction=petRemote}
	local shared = {WaitForChild=function(_, name) return remotes[name] or name end}
	local services = {Players=players, RunService={Heartbeat=heartbeat}, ReplicatedStorage={WaitForChild=function() return shared end}}
	local env = {
		game={GetService=function(_, name) return services[name] end}, workspace=world,
		Vector3={new=vec,zero=vec(0,0,0)}, os={clock=function() return now end},
		task={spawn=function(f, ...) f(...) end},
	}
	local dungeon, lesson = loadServices(env, progress)
	lesson.Start()
	-- Worst case for restored flags: DungeonService initializes after progress has already loaded.
	dungeon.Start()
	loadPets(env)()
	-- Started after LessonService like Main.server, so their PlayerAdded resets run after progress loads.
	loadLight(env, "Lesson")()
	loadShield(env)()

	local function prompt(p, name) now += 0.8; p.root.Position=academy[name].Position; academy[name].Interact.Triggered:Fire(p) end
	local function action(p, name) now += 0.2; remote.OnServerEvent:Fire(p, name) end
	local function learn(p)
		prompt(p, "Lesson"); for _=1,3 do action(p, "Raise") end; action(p, "Place")
		prompt(p, "Puzzle"); for _=1,6 do action(p, "Raise") end; action(p, "Place")
	end

	-- Claim, duplicate claim, rejoin.
	local p = join(1)
	check(p:GetAttribute("ProgressReady") and p:GetAttribute("LessonStage")==0, "new student loads stage 0 from empty store")
	learn(p)
	check(p:GetAttribute("LessonStage")==2 and db.records.player_1.Stage==2, "lesson and mechanism saved before reward")
	prompt(p, "Reward")
	check(p:GetAttribute("LessonRecord") and db.records.player_1.Stage==3, "reward claim is saved immediately")
	local writes = db.writes
	prompt(p, "Reward")
	check(p:GetAttribute("LessonStage")==3 and db.writes==writes, "duplicate claim neither advances nor writes")
	check(string.find(p:GetAttribute("LessonHint"), "ครั้งเดียว", 1, true) ~= nil, "duplicate claim explains once-only reward")
	leave(p)
	check(db.writes==writes and db.records.player_1.Stage==3, "leaving with nothing dirty does not rewrite")
	local again = join(1)
	check(again:GetAttribute("LessonStage")==3 and again:GetAttribute("LessonRecord") and again:GetAttribute("LevitationUnlocked"), "rejoin restores claimed reward")
	prompt(again, "Reward")
	check(again:GetAttribute("LessonStage")==3 and db.writes==writes, "rejoined student cannot claim again")
	leave(again)

	-- Store outage at claim time: progress is kept for retry, never lost below the saved stage or duplicated.
	local q = join(2)
	learn(q)
	db.failSave = true
	prompt(q, "Reward")
	check(q:GetAttribute("LessonStage")==3 and db.records.player_2.Stage==2, "outage keeps claim in session, store stays at last good stage")
	check(string.find(q:GetAttribute("ProgressStatus"), "ไม่สำเร็จ", 1, true) ~= nil, "outage tells the player saving failed")
	leave(q)
	check(db.records.player_2.Stage==2, "close during outage leaves last good record intact")
	db.failSave = false
	local back = join(2)
	check(back:GetAttribute("LessonStage")==2 and not back:GetAttribute("LessonRecord"), "unsaved claim is not shown as owned after rejoin")
	prompt(back, "Reward")
	check(back:GetAttribute("LessonRecord") and db.records.player_2.Stage==3, "unsaved claim can be claimed exactly once after recovery")
	prompt(back, "Reward")
	check(db.records.player_2.Stage==3 and back:GetAttribute("LessonStage")==3, "recovered claim is still once-only")
	check(db.records.player_1.Stage==3, "other student's record untouched")

	-- Learned spells persist; spell services must not reset what progress restored.
	local r = join(3)
	learn(r); prompt(r, "Reward")
	check(r:GetAttribute("LightCompleted")==false and db.records.player_3.Spells.Light==false, "no spell learned before the light lesson")
	prompt(r, "LightLesson"); prompt(r, "LightRune1"); prompt(r, "LightRune3")
	check(r:GetAttribute("LightCompleted")==true and db.records.player_3.Spells.Light==true, "passing the real light lesson saves the spell")
	r:SetAttribute("ShieldPassed", true)
	check(db.records.player_3.Spells.Shield==true and db.records.player_3.Version==4, "shield pass saves the spell")
	r:SetAttribute("DungeonCompleted", true)
	check(db.records.player_3.Milestones.Dungeon==true, "finishing the dungeon saves the scroll field-test milestone")
	leave(r)
	local r2 = join(3)
	check(r2:GetAttribute("LightCompleted")==true and r2:GetAttribute("ShieldPassed")==true, "rejoin keeps learned spells after spell services initialize")
	check(r2:GetAttribute("DungeonCompleted")==true and r2:GetAttribute("DungeonState")=="Idle", "rejoin keeps the dungeon milestone but starts with no active run")
	check(string.find(Scroll.mastery(r2:GetAttribute("ProgressReady"), r2:GetAttribute("ShieldPassed"), r2:GetAttribute("DungeonCompleted")), "ผ่านภาคสนาม", 1, true) ~= nil, "rejoin restores derived mastery from saved lesson and dungeon flags")
	check(r2:GetAttribute("LightTrialActive")==false and r2:GetAttribute("ShieldTrialActive")==false, "rejoin still resets in-progress trials")
	check(db.records.player_1.Spells.Light==false, "spells are per student")

	-- Companion bond: shared activities count once and only with the companion out; name and bond survive rejoin.
	local function pet(p, action) now += 0.5; petRemote.OnServerEvent:Fire(p, action) end
	pet(r2, "Play")
	check(r2:GetAttribute("PetBondPlay")==false, "playing needs the companion out")
	pet(r2, true)
	check(r2:GetAttribute("PetEquipped")==true, "companion called")
	pet(r2, "Play")
	check(r2:GetAttribute("PetBondPlay")==true and db.records.player_3.Pet.Bond.Play==true, "first play with the companion saves bond")
	local before = db.writes
	pet(r2, "Play")
	check(db.writes==before, "repeat play adds nothing")
	pet(r2, "Rename")
	check(r2:GetAttribute("PetNameIndex")==2 and db.records.player_3.Pet.Name==2, "rename cycles and saves")
	pet(r2, false); r2:SetAttribute("InDorm", true); r2:SetAttribute("InDorm", false)
	check(r2:GetAttribute("PetBondDorm")==false, "activities without the companion do not count")
	pet(r2, true); r2:SetAttribute("InDorm", true)
	check(db.records.player_3.Pet.Bond.Dorm==true, "dorm visit with the companion counts")
	r2:SetAttribute("DungeonState", "Complete")
	check(db.records.player_3.Pet.Bond.Dungeon==true and db.records.player_3.Pet.Bond.Explore==false, "finished run with the companion counts")
	leave(r2)
	local r3 = join(3)
	check(r3:GetAttribute("PetNameIndex")==2 and r3:GetAttribute("PetBondPlay")==true and r3:GetAttribute("PetBondDungeon")==true and r3:GetAttribute("PetEquipped")==false, "rejoin restores name and bond, companion starts stowed")
	print(`PASS: {checks} reward persistence flow checks (real Lesson+Progress services, keyed store double)`)
end
