return function(Model)
	local n = 0
	local function check(v, message) n += 1; assert(v, message or "Scroll model incorrect") end
	check(#Model.Pages == 5, "slice book has five pages")
	check(string.find(Model.describe(false, 3, true, true, true), "รอข้อมูล", 1, true) ~= nil)
	local cases = {
		{stage = 0, light = false, shield = false, dungeon = false, count = 0, phase = "ยังไม่พบ"},
		{stage = 1, light = false, shield = false, dungeon = false, count = 1, phase = "ค้นพบ"},
		{stage = 3, light = false, shield = false, dungeon = false, count = 2, phase = "ค้นพบ"},
		{stage = 3, light = true, shield = false, dungeon = true, count = 4, phase = "ค้นพบ"},
		{stage = 3, light = true, shield = true, dungeon = false, count = 4, phase = "รวบรวม"},
		{stage = 3, light = true, shield = true, dungeon = true, count = 5, phase = "เข้าใจ"},
	}
	for _, c in cases do
		local text = Model.describe(true, c.stage, c.light, c.shield, c.dungeon)
		check(string.find(text, `{c.count}/5 หน้า`, 1, true) ~= nil, `count {c.count}`)
		check(string.find(text, `ขั้น{c.phase}`, 1, true) ~= nil, `phase {c.phase}`)
		local _, ticks = string.gsub(text, "✓", "")
		local _, missing = string.gsub(text, "○", "")
		check(ticks == c.count and missing == 5 - c.count, "every page shows a text mark, not color only")
	end
	check(string.find(Model.describe(true, 3, true, false, false), "○ ม่านคุ้มกัน — ผ่านการฝึกม่านคุ้มกัน", 1, true) ~= nil, "missing pages say how to earn them")
	check(string.find(Model.describe(true, 3, true, true, true), "บันทึกไว้หลังออกเกม", 1, true) ~= nil)
	check(Model.owned(nil, nil, nil, nil)[1] == false and Model.owned("3", true, true, true)[2] == false, "bad stage values earn nothing")
	print(`PASS: {n} scroll model checks`)
end
