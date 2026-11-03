return function(Model)
	local count = 0
	local function check(value)
		count += 1
		assert(value, "Journal must match server progress")
	end
	for stage = 0, 3 do
		local rows = Model.describe(true, stage)
		check(#rows == 4)
		check(string.find(rows[1], `{stage}/3`, 1, true) ~= nil)
		check((string.find(rows[2], "— ปลดล็อกแล้ว", 1, true) ~= nil) == (stage >= 1))
		check((string.find(rows[3], "— ได้รับแล้ว 1 รายการ", 1, true) ~= nil) == (stage == 3))
		check(#Model.describe(false, stage) == 2)
	end
	for _, invalid in {false, "3", -1, 4, 1.5, 0/0, math.huge} do
		check(#Model.describe(true, invalid) == 2)
	end
	check(#Model.describe(true, nil) == 2)
	print(`PASS: {count} journal model checks`)
end
