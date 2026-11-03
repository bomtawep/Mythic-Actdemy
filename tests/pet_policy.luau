return function(Policy)
	local count = 0
	local function check(condition)
		count += 1
		assert(condition, "Pet entitlement must be checked independently of presentation")
	end
	for stage = 0, 3 do
		check(Policy.unlocked(true, stage) == (stage == 3))
		check(Policy.allowed(true, stage, true) == (stage == 3))
		check(Policy.allowed(true, stage, false))
		check(not Policy.allowed(false, stage, true))
	end
	for _, bad in {"3", 4, -1, 3.1, 0/0, math.huge, false} do
		check(not Policy.unlocked(true, bad))
	end
	for _, bad in {"true", 1, {}, false} do
		if bad ~= false then check(not Policy.allowed(true, 3, bad)) end
	end
	check(not Policy.allowed(true, 3, nil))
	check(not Policy.unlocked(nil, 3))
	-- Slice companion helpers.
	check(#Policy.Names >= 1 and #Policy.Names <= 16)
	check(Policy.validName(1) and Policy.validName(#Policy.Names) and not Policy.validName(0) and not Policy.validName(#Policy.Names + 1) and not Policy.validName(1.5) and not Policy.validName("1"))
	check(Policy.nextName(1) == 2 and Policy.nextName(#Policy.Names) == 1 and Policy.nextName(nil) == 1 and Policy.nextName(99) == 1)
	check(Policy.bondStage(0) == "รู้จัก" and Policy.bondStage(1) == "รู้จัก" and Policy.bondStage(2) == "คุ้นเคย" and Policy.bondStage(3) == "คุ้นเคย" and Policy.bondStage(4) == "ไว้ใจ")
	check(#Policy.Activities == 4)
	for _, activity in Policy.Activities do check(type(Policy.ActivityText[activity]) == "string") end
	local attrs = {PetBondPlay = true, PetBondDungeon = true, PetNameIndex = 3}
	local owner = {GetAttribute = function(_, k) return attrs[k] end}
	check(Policy.bondCount(owner) == 2)
	check(Policy.tagText(3, 2, nil) == `{Policy.Names[3]} • {Policy.Species} • คุ้นเคย`)
	check(string.find(Policy.tagText(nil, 0, "เล่นด้วยกัน"), `{Policy.Names[1]}`, 1, true) ~= nil and string.find(Policy.tagText(nil, 0, "เล่นด้วยกัน"), "\nเล่นด้วยกัน", 1, true) ~= nil)
	local text = Policy.journal(true, 3, owner)
	check(string.find(text, `คู่หู: {Policy.Names[3]}`, 1, true) ~= nil and string.find(text, "ขั้นคุ้นเคย 2/4", 1, true) ~= nil)
	local _, done = string.gsub(text, "✓", ""); local _, open = string.gsub(text, "○", "")
	check(done == 2 and open == 2, "activities marked with text, not color only")
	check(string.find(text, "ไม่ลดเมื่อออฟไลน์", 1, true) ~= nil)
	check(string.find(Policy.journal(true, 2, owner), "จบบทเรียนแรก", 1, true) ~= nil and string.find(Policy.journal(false, 3, owner), "รอข้อมูล", 1, true) ~= nil)
	print(`PASS: {count} pet policy checks`)
end
