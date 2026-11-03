--!strict
-- First scroll book (D55/D57, working name): five fixed pages earned only from saved progress, never luck or purchase.
local Model = {}
Model.Title = "คัมภีร์เวทพื้นฐาน"
Model.Pages = table.freeze({
	{name = "ปกและบทนำ", how = "จบบทฝึกแรก"},
	{name = "แรงลอยตัว", how = "รับบันทึกแรงลอยตัว"},
	{name = "แสงนำทาง", how = "ผ่านปริศนาแสงนำทาง"},
	{name = "ม่านคุ้มกัน", how = "ผ่านการฝึกม่านคุ้มกัน"},
	{name = "บททดสอบภาคสนาม", how = "จบดันเจียน 3 ห้อง"},
})
function Model.owned(stage: any, light: any, shield: any, dungeon: any): {boolean}
	local s = if type(stage) == "number" then stage else 0
	return {s >= 1, s >= 3, light == true, shield == true, dungeon == true}
end
-- S10 phases: discovered → collected (every skill page) → understood (field test done too).
function Model.phase(owned: {boolean}): string
	local skills = owned[1] and owned[2] and owned[3] and owned[4]
	if skills and owned[5] then return "เข้าใจ" end
	if skills then return "รวบรวม" end
	for _, has in owned do
		if has then return "ค้นพบ" end
	end
	return "ยังไม่พบ"
end
function Model.mastery(ready: any, shield: any, dungeon: any): string
	if ready ~= true then return "กำลังโหลดความชำนาญ" end
	if shield ~= true then return "ผู้ฝึกหัด • เรียนแสงและม่านคุ้มกันเพื่อปลดล็อกคลื่นเวท" end
	if dungeon == true then return "ผ่านภาคสนาม • เรียนครบและจบดันเจียนแล้ว" end
	return "พร้อมภาคสนาม • จบดันเจียนเพื่อรับขั้นผ่านภาคสนาม"
end
function Model.describe(ready: any, stage: any, light: any, shield: any, dungeon: any): string
	if ready ~= true then return `{Model.Title} • รอข้อมูลนักเรียน` end
	local owned = Model.owned(stage, light, shield, dungeon)
	local count = 0
	local lines = {}
	for index, page in Model.Pages do
		if owned[index] then
			count += 1
			table.insert(lines, `✓ {page.name}`)
		else
			table.insert(lines, `○ {page.name} — {page.how}`)
		end
	end
	return `{Model.Title} • {count}/{#Model.Pages} หน้า • ขั้น{Model.phase(owned)}\n{table.concat(lines, "\n")}\nหน้าที่ได้แล้วบันทึกไว้หลังออกเกม\nความชำนาญ: {Model.mastery(ready, shield, dungeon)}`
end
return Model
