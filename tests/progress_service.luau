-- Runs the real ProgressService with deterministic Roblox service doubles.
return function(newService, Schema)
	local checks = 0
	local function check(condition, message)
		checks += 1
		assert(condition, message)
	end
	local function fixture(studio)
		local players = {}
		local attrs = {}
		local player = {UserId = 42, Parent = players}
		local changed = {}
		function player:SetAttribute(key, value)
			local old = attrs[key]
			attrs[key] = value
			if old ~= value and changed[key] then for _, f in changed[key] do if f.active then f.fn() end end end
		end
		function player:GetAttribute(key) return attrs[key] end
		function player:GetAttributeChangedSignal(key)
			return {Connect = function(_, fn)
				changed[key] = changed[key] or {}
				local item = {active = true, fn = fn}
				table.insert(changed[key], item)
				return {Disconnect = function() item.active = false end}
			end}
		end
		local db = {value = nil, gets = 0, writes = 0, failLoad = false, failSave = false}
		function db:GetAsync(_key)
			self.gets += 1
			if self.onGet then self.onGet() end
			if self.failLoad then error("simulated read outage") end
			return self.value
		end
		function db:UpdateAsync(_key, transform)
			self.writes += 1
			if self.failSave then error("simulated write outage") end
			if self.onWrite then self.onWrite() end
			local result = transform(self.value)
			if result then self.value = result end
			return result
		end
		local services = {
			Players = players,
			RunService = {IsStudio = function() return studio end},
			DataStoreService = {GetDataStore = function()
				check(not studio, "Studio must never open the real store")
				return db
			end},
		}
		local fakeGame = {GetService = function(_, name) return services[name] end}
		local fakeTask = {wait = function() end, spawn = function(f, ...) f(...) end}
		local service = newService(fakeGame, fakeTask)
		return service, player, attrs, db
	end

	for old = 0, 3 do
		for incoming = 0, 3 do
			local merged = Schema.merge({Version = 1, Stage = old}, incoming)
			check(merged.Stage == math.max(old, incoming), "stale saves cannot regress stage")
			check(Schema.merge(merged, incoming).Stage == merged.Stage, "retry must be idempotent")
		end
	end
	local none, light, both = {Light = false, Shield = false}, {Light = true, Shield = false}, {Light = true, Shield = true}
	local v1 = Schema.decode({Version = 1, Stage = 2})
	check(v1.Version == 4 and v1.Stage == 2 and not v1.Spells.Light and not v1.Spells.Shield and not v1.Milestones.Dungeon, "v1 migrates on read with no spells")
	check(Schema.decode(nil).Version == 4, "new profiles start as v4")
	local learned = Schema.merge({Version = 1, Stage = 3}, 3, light)
	check(learned.Version == 4 and learned.Spells.Light and not learned.Spells.Shield, "v1 record upgrades when a spell is saved")
	local stale = Schema.merge({Version = 2, Stage = 3, Spells = both}, 3, none)
	check(stale.Spells.Light and stale.Spells.Shield, "stale writer cannot unlearn spells")
	check(Schema.decode(stale) ~= nil and Schema.decode(Schema.merge({Version = 2, Stage = 3, Spells = light}, 0, none)) ~= nil, "merged records stay decodable")
	check(Schema.merge({Version = 2, Stage = 3, Spells = light}, 2, none).Stage == 3, "stale writer cannot regress stage with spells")
	check(Schema.merge({Version = 1, Stage = 2}, 2, light) == nil, "spell before lesson record is rejected")
	check(Schema.merge({Version = 2, Stage = 3, Spells = none}, 3, {Light = false, Shield = true}) == nil, "Shield without Light is rejected")
	for _, bad in {false, "bad", {}, {Version = 2, Stage = 1}, {Version = 5, Stage = 1, Spells = none}, {Version = 2, Stage = 3, Spells = {Light = true, Shield = false, Fire = true}},
		{Version = 3, Stage = 3, Spells = none}, {Version = 3, Stage = 3, Spells = none, Milestones = {Dungeon = "yes"}}, {Version = 3, Stage = 3, Spells = none, Milestones = {Dungeon = true, Boss = true}},
		{Version = 3, Stage = 2, Spells = none, Milestones = {Dungeon = true}},
		{Version = 2, Stage = 3, Spells = {Light = "yes", Shield = false}}, {Version = 2, Stage = 2, Spells = light}, {Version = 2, Stage = 3, Spells = {Light = false, Shield = true}},
		{Version = 1, Stage = -1}, {Version = 1, Stage = 4}, {Version = 1, Stage = 1.5}, {Version = 1, Stage = 0/0}, {Version = 1, Stage = math.huge}} do
		check(Schema.decode(bad) == nil, "reject invalid schema")
		check(Schema.merge(bad, 1) == nil, "never replace invalid data")
	end

	do
		local s, p, a, db = fixture(false)
		s.Load(p)
		check(a.ProgressReady and a.LessonStage == 0, "new profile loads")
		check(not s.Advance(p, 1), "cannot skip lesson")
		check(s.Advance(p, 0) and s.Advance(p, 1) and s.Advance(p, 2), "normal progress")
		check(not s.Advance(p, 2) and a.LessonRecord, "reward once only")
		check(s.Save(p) and db.value.Stage == 3, "saves stage 3")
		s.Close(p)
		check(not s.Advance(p, 0), "closed profile cannot advance")
		s.Load(p)
		check(a.LessonStage == 3 and a.LessonRecord and a.LevitationUnlocked, "rejoin restores progress")
	end
	do
		local s, p, a, db = fixture(false)
		db.failLoad = true
		s.Load(p)
		check(db.gets == 3 and not a.ProgressReady, "failed load retries and blocks gameplay")
		check(not s.Advance(p, 0) and not s.Save(p) and db.writes == 0, "failed load cannot overwrite profile")
	end
	do
		local s, p, a, db = fixture(false)
		db.value = {Version = 5, Stage = 3}
		s.Load(p)
		check(not a.ProgressReady and db.gets == 1, "unknown schema blocked without retry")
		s.Close(p)
		check(db.writes == 0, "closing failed profile does not write")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		db.failSave = true
		check(not s.Save(p) and db.writes == 3 and a.LessonStage == 1, "save outage keeps dirty progress")
		db.failSave = false
		check(s.Save(p) and db.value.Stage == 1, "retry recovers dirty progress")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		db.onWrite = function()
			check(not s.Save(p), "only one save per profile")
			check(s.Advance(p, 1), "progress may advance during save")
			db.onWrite = nil
		end
		check(s.Save(p) and db.value.Stage == 1 and a.LessonStage == 2, "in-flight snapshot must not discard newer progress")
		check(s.Save(p) and db.value.Stage == 2, "next save flushes newer progress")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		db.value = {Version = 1, Stage = 3}
		check(s.Save(p) and db.value.Stage == 3 and a.LessonStage == 3, "stale server merges higher stored stage")
	end
	do
		local s, p, a, db = fixture(true)
		s.Load(p); s.Advance(p, 0); s.Close(p); s.Load(p)
		check(a.LessonStage == 1 and db.gets == 0 and db.writes == 0, "Studio uses memory only")
	end
	do
		local s, p, a, db = fixture(false)
		db.onGet = function() p.Parent = nil end
		s.Load(p)
		check(not a.ProgressReady and not s.Advance(p, 0), "leaving during load must not create an active profile")
		s.Close(p)
		check(db.writes == 0, "leaving during load must not save defaults")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		db.value = {Version = 5, Stage = 3}
		check(not s.Save(p), "new schema appearing during save must cancel write")
		check(db.value.Version == 5 and db.value.Stage == 3, "unknown schema stays unchanged")
		check(a.LessonStage == 1, "failed save retains local progress")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0); s.Advance(p, 1)
		s.Close(p)
		check(db.value.Stage == 2 and not a.ProgressReady, "close saves unsaved progress and disables gameplay")
	end
	do
		local s, p, a, db = fixture(false)
		db.value = {Version = 1, Stage = 3}
		s.Load(p)
		check(a.LessonStage == 3 and a.LightCompleted == false and a.ShieldPassed == false, "v1 profile loads with no spells learned")
		check(not s.Record(p, "Shield"), "Shield cannot be learned before Light")
		p:SetAttribute("LightCompleted", true)
		check(db.value.Version == 4 and db.value.Spells.Light and not db.value.Spells.Shield, "passing Light saves it and upgrades the record")
		local writes = db.writes
		p:SetAttribute("LightCompleted", false); p:SetAttribute("LightCompleted", true)
		check(db.writes == writes, "repeating a learned spell does not rewrite")
		p:SetAttribute("ShieldPassed", true)
		check(db.value.Spells.Shield and db.value.Stage == 3, "passing Shield saves it")
		s.Close(p)
		a.LightCompleted, a.ShieldPassed = nil, nil
		s.Load(p)
		check(a.LightCompleted == true and a.ShieldPassed == true, "rejoin restores learned spells")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		check(not s.Record(p, "Light") and not s.Record(p, "Dungeon") and a.LightCompleted == false and a.DungeonCompleted == false, "spells and milestones need the first lesson record")
		check(not s.Record(p, "Fire"), "unknown flag is rejected")
	end
	do
		local s, p, a, db = fixture(false)
		db.value = {Version = 2, Stage = 3, Spells = {Light = false, Shield = false}}
		s.Load(p)
		db.value = {Version = 2, Stage = 3, Spells = {Light = true, Shield = true}}
		db.failSave = true
		p:SetAttribute("LightCompleted", true)
		check(a.LightCompleted and db.value.Spells.Shield, "outage keeps learned spell in session")
		db.failSave = false
		check(s.Save(p) and a.ShieldPassed == true, "save adopts spells another server already stored")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p)
		s.Close(p)
		db.value = {Version = 2, Stage = 3, Spells = {Light = false, Shield = false}}
		local writes = db.writes
		p:SetAttribute("LightCompleted", true)
		check(db.writes == writes, "closed profile ignores spell attributes")
	end
	local none3 = {Dungeon = false}
	local v2 = Schema.decode({Version = 2, Stage = 3, Spells = both})
	check(v2.Version == 4 and v2.Spells.Shield and not v2.Milestones.Dungeon, "v2 migrates on read without milestones")
	local ran = Schema.merge({Version = 3, Stage = 3, Spells = none, Milestones = {Dungeon = true}}, 3, both, none3)
	check(ran.Milestones.Dungeon and ran.Spells.Shield, "stale writer cannot erase a finished dungeon")
	check(Schema.merge({Version = 1, Stage = 2}, 2, none, {Dungeon = true}) == nil, "dungeon milestone before lesson record is rejected")
	do
		local s, p, a, db = fixture(false)
		db.value = {Version = 2, Stage = 3, Spells = light}
		s.Load(p)
		check(a.DungeonCompleted == false and a.LightCompleted == true, "v2 profile loads with no dungeon milestone")
		p:SetAttribute("DungeonCompleted", true)
		check(db.value.Version == 4 and db.value.Milestones.Dungeon and db.value.Spells.Light, "finishing the dungeon saves the milestone and keeps spells")
		s.Close(p)
		a.DungeonCompleted = nil
		s.Load(p)
		check(a.DungeonCompleted == true, "rejoin restores the dungeon milestone")
	end
	-- v4 companion: bond only grows, the name is the latest writer's choice.
	local noBond = {Play = false, Explore = false, Dungeon = false, Dorm = false}
	local v3 = Schema.decode({Version = 3, Stage = 3, Spells = light, Milestones = {Dungeon = true}})
	check(v3.Version == 4 and v3.Pet.Name == 1 and not v3.Pet.Bond.Play and v3.Milestones.Dungeon, "v3 migrates with a fresh companion")
	local bonded = {Version = 4, Stage = 3, Spells = light, Milestones = none3, Pet = {Name = 2, Bond = {Play = true, Explore = false, Dungeon = false, Dorm = false}}}
	local renamed = Schema.merge(bonded, 3, light, none3, {Name = 5, Bond = noBond})
	check(renamed.Pet.Name == 5 and renamed.Pet.Bond.Play, "rename keeps bond; stale writer cannot erase bond")
	check(Schema.merge(bonded, 3, light, none3).Pet.Name == 2, "writer without pet keeps the stored name")
	check(Schema.merge(bonded, 0, none, none3) ~= nil, "low-stage writer without pet does not corrupt a bonded record")
	for _, badPet in {{Name = 0, Bond = noBond}, {Name = Schema.MaxPetNames + 1, Bond = noBond}, {Name = 1.5, Bond = noBond}, {Name = "a", Bond = noBond},
		{Name = 1, Bond = {Play = "yes", Explore = false, Dungeon = false, Dorm = false}}, {Name = 1, Bond = {Play = false, Explore = false, Dungeon = false, Dorm = false, Fly = true}},
		{Name = 1, Bond = noBond, Color = 3}, {Name = 1}} do
		check(Schema.decode({Version = 4, Stage = 3, Spells = none, Milestones = none3, Pet = badPet}) == nil, "invalid companion data is rejected")
	end
	check(Schema.decode({Version = 4, Stage = 2, Spells = none, Milestones = none3, Pet = {Name = 1, Bond = {Play = true, Explore = false, Dungeon = false, Dorm = false}}}) == nil, "bond before the lesson record is rejected")
	check(Schema.decode({Version = 4, Stage = 3, Spells = none, Milestones = none3}) == nil, "v4 needs the companion block")
	do
		local s, p, a, db = fixture(false)
		db.value = {Version = 3, Stage = 3, Spells = none, Milestones = none3}
		s.Load(p)
		check(a.PetNameIndex == 1 and a.PetBondPlay == false, "v3 profile loads a fresh companion")
		p:SetAttribute("PetBondPlay", true)
		check(db.value.Version == 4 and db.value.Pet.Bond.Play, "first shared play saves the bond")
		p:SetAttribute("PetNameIndex", 4)
		check(db.value.Pet.Name == 4 and db.value.Pet.Bond.Play, "rename saves and keeps bond")
		local writes = db.writes
		p:SetAttribute("PetNameIndex", 99)
		check(a.PetNameIndex == 4 and db.writes == writes, "out-of-range name is put back and not saved")
		p:SetAttribute("PetNameIndex", 4)
		check(db.writes == writes, "same name does not rewrite")
		s.Close(p)
		a.PetNameIndex, a.PetBondPlay = nil, nil
		s.Load(p)
		check(a.PetNameIndex == 4 and a.PetBondPlay == true and a.PetBondDorm == false, "rejoin restores companion name and bond")
	end
	do
		local s, p, a, db = fixture(false)
		s.Load(p); s.Advance(p, 0)
		check(not s.Record(p, "PetPlay") and a.PetBondPlay == false, "no bond before the lesson record")
	end
	print(`PASS: {checks} progress checks (real modules, mocked Roblox services)`)
end
