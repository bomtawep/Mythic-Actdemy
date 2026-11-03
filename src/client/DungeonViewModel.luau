--!strict
-- Three fixed rooms (D55): Puzzle → Encounter → Reward/Complete.
local Model = {}
local rooms = {Puzzle = 1, Encounter = 2, Reward = 3, Complete = 3}
local checkpoints = {Puzzle = "จุดเริ่มห้อง 1", Encounter = "จุดเริ่มห้อง 2", Reward = "ห้องจบ", Complete = "ห้องจบ"}
-- `where` is the room the server last placed the player in (DungeonRoom); it beats the state when known.
function Model.describe(ready: any, state: any, paused: any, cleared: any, where: any): any
	local room = if type(state) == "string" then rooms[state] else nil
	if ready ~= true or not room then return nil end
	if where == 1 or where == 2 or where == 3 then room = where end
	local checkpoint = checkpoints[state]
	local sentinel = if cleared == true or room == 3 then "ผ่านผู้เฝ้าแล้ว" else "ห้อง 2: ใช้คลื่นเวทโจมตีผู้เฝ้า หรือแท่นควบคุม หรือกันด้วยม่านคุ้มกัน 2 ครั้ง"
	if paused == true then
		return {
			headline = "ดันเจียน • รันพักอยู่",
			objective = "กลับไปประตูดันเจียนที่ซากวิหาร (ผ่านสวนอักขระ) เพื่อไปต่อ",
			status = `Checkpoint: {checkpoint}`,
			summary = `รันพักอยู่ • กลับไปต่อที่{checkpoint}\n{sentinel}\nเก็บเฉพาะเซิร์ฟเวอร์นี้ ไม่บันทึกหลังออกเกม`,
		}
	end
	local objective = if state == "Puzzle" then "ยกผลึกกลไกหลักให้ถึงระดับ 11 แล้ววาง เพื่อเปิดประตูห้อง 2"
		elseif state == "Encounter" then "หลบแนวยิงสีม่วง แล้วผ่านผู้เฝ้า"
		elseif state == "Reward" and room == 3 then "รับผลที่แท่นจบ แล้วกลับโรงเรียน"
		elseif state == "Reward" then "ผ่านเงาที่ประตู (เผยด้วยอักขระแสง หรือใช้ประตูข้าง) แล้วรับผลที่แท่นจบ"
		else "จบรันแล้ว ใช้ประตูกลับโรงเรียนเพื่อออก"
	return {
		headline = if state == "Complete" then "ดันเจียน • จบรัน" else `ดันเจียน • ห้อง {room}/3`,
		objective = objective,
		status = if state == "Complete" then "ผลจบเฉพาะรอบเล่น • ไม่มีไอเทมถาวร" else `Checkpoint: {checkpoint} • กลับออกได้ทุกเมื่อ`,
		summary = `ดันเจียน: {objective}\n{sentinel}\nCheckpoint: {checkpoint}\nผลทดลองเฉพาะรอบเล่น ไม่มีเงินหรือไอเทมถาวร`,
	}
end
return Model
