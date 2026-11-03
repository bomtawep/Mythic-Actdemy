# Step 12 — ทดสอบ flow ข้ามบริการ

เพิ่ม `tests/service_flow.luau` และขยาย runner ให้รัน DungeonService, LessonService, EncounterService ตัวจริง ด้วย event/character/world doubles ใน Luau CLI ใช้ตำแหน่งวัตถุจาก Academy.model.json จริง แทนการจำลองกฎซ้ำในภาษาอื่น

ครอบคลุมเข้ารัน, ห้ามจบก่อนแก้, เตือน/โจมตี, เริ่มเวทช่วงพัก, วางผิด, ยกผลึกหยุดผู้เฝ้า, แยกผู้เล่น, ไม่โดนโจมตีหลังหยุด, ตาย/พัก/กู้คืน, checkpoint หลังแก้, จบรัน, รับผลซ้ำ, รันใหม่ล้างผลผู้เฝ้า, ยกเลิก/เริ่มเวทใหม่ และออกระหว่างฝึก

เพิ่ม guard Start ใน DungeonService ให้เรียกซ้ำไม่ลงทะเบียน prompt/event ซ้ำ ทดสอบ Start ซ้ำของบริการทั้งสามและจำนวน loop แล้ว

## ผลตรวจ

- compiler 27 ไฟล์ผ่าน
- tests เดิม 222 + real-service flow 25 = 247 assertions ผ่าน
- Rojo build/sourcemap และ diff whitespace ผ่าน
- รายงานและ source hashes ใน `build/luau-checks.json`

นี่คือการรันบริการจริงบน API doubles ไม่ใช่ Roblox runtime ยังไม่ตรวจ physics/latency/ภาพ/Input/client controllers; ProgressService ใน flow นี้ใช้ stub Stage 3 โดยมีชุดทดสอบข้อมูลแยกเดิม ไม่ครอบคลุม DataStore จริง ไม่เปิด Studio ตาม D16

ไม่มี asset หรือคอนเทนต์ใหม่ ขั้นถัดไปขยาย objective/สรุปผลดันเจียนให้ผู้เล่นเห็นความคืบหน้าและ checkpoint ชัด โดยไม่เพิ่มรางวัลถาวรที่ยังไม่มี schema รองรับ
