--!strict
local Policy = {}
function Policy.unlocked(ready: any, stage: any): boolean
	return ready == true and type(stage) == "number" and stage == 3
end
function Policy.allowed(ready: any, stage: any, desired: any): boolean
	return type(desired) == "boolean" and (desired == false or Policy.unlocked(ready, stage))
end
-- Slice pet (D59, working names): one species, preset names, bond from first shared activities only.
Policy.Species = "ละอองหูใบ"
Policy.Names = table.freeze({"ใบอ่อน", "ถั่วงอก", "หยดน้ำค้าง", "ก้อนเมฆ", "ขนมปัง", "ใบชา"})
-- Each counts once, the first time it happens with the companion out; repeats never add more.
Policy.Activities = table.freeze({"Play", "Explore", "Dungeon", "Dorm"})
Policy.ActivityText = table.freeze({Play = "เล่นด้วยกัน", Explore = "ค้นพบอักขระสวนด้วยกัน", Dungeon = "จบดันเจียนด้วยกัน", Dorm = "พาเข้าหอพัก"})
function Policy.validName(index: any): boolean
	return type(index) == "number" and index % 1 == 0 and index >= 1 and index <= #Policy.Names
end
function Policy.nextName(index: any): number
	return if Policy.validName(index) then index % #Policy.Names + 1 else 1
end
function Policy.bondStage(count: number): string
	if count >= 4 then return "ไว้ใจ" end
	if count >= 2 then return "คุ้นเคย" end
	return "รู้จัก"
end
local BOND_ATTRIBUTES = {"PetBondPlay", "PetBondExplore", "PetBondDungeon", "PetBondDorm"}
function Policy.bondCount(owner: any): number
	local count = 0
	for _, attribute in BOND_ATTRIBUTES do
		if owner:GetAttribute(attribute) == true then count += 1 end
	end
	return count
end
function Policy.name(index: any): string
	return Policy.Names[if Policy.validName(index) then index else 1]
end
function Policy.tagText(index: any, count: number, feedback: any): string
	local base = `{Policy.name(index)} • {Policy.Species} • {Policy.bondStage(count)}`
	return if type(feedback) == "string" and feedback ~= "" then `{base}\n{feedback}` else base
end
-- Journal entry: name, bond stage and which shared activities are done; nothing decays offline.
function Policy.journal(ready: any, stage: any, owner: any): string
	if ready ~= true then return "คู่หู • รอข้อมูลนักเรียน" end
	if not Policy.unlocked(ready, stage) then return `คู่หู • {Policy.Species} • จบบทเรียนแรกเพื่อพบคู่หู` end
	local lines = {}
	for index, activity in Policy.Activities do
		lines[index] = `{if owner:GetAttribute(BOND_ATTRIBUTES[index]) == true then "✓" else "○"} {Policy.ActivityText[activity]}`
	end
	local count = Policy.bondCount(owner)
	return `คู่หู: {Policy.name(owner:GetAttribute("PetNameIndex"))} ({Policy.Species}) • ขั้น{Policy.bondStage(count)} {count}/{#Policy.Activities}\n{table.concat(lines, "\n")}\nทำแต่ละอย่างโดยพาคู่หูไปด้วยครั้งแรกเท่านั้น ไม่ลดเมื่อออฟไลน์ บันทึกไว้หลังออกเกม`
end
return Policy
