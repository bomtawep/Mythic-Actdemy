# Step 56 — ประยุกต์เวทสู่การต่อสู้และขั้นความชำนาญ

วันที่ 3 พฤศจิกายน 2026 / การตัดสินใจ D64 / สถานะ: prototype, compiler/API-double-tested และ build-tested ยังไม่ผ่านภาพหรือเล่นจริง

## พฤติกรรมที่เพิ่ม

ผ่านแรงลอยตัว → แสง → ม่านคุ้มกันตามบทเรียนเดิม จะใช้คลื่นเวทโจมตีผู้เฝ้าในห้อง 2 ได้ด้วย C หรือปุ่มบนจอ เซิร์ฟเวอร์เลือกผู้เฝ้าอัตโนมัติในระยะ 24 studs ไม่ต้องเล็งคลิก ใช้ 4 ครั้ง (100 HP / ครั้งละ 25) คูลดาวน์ 0.9 วินาที ต้องไม่มีสิ่งกีดขวาง ไม่มี PvP หรือความเสียหายต่อผู้ยิง/เงาในขั้นนี้

เมื่อผู้เฝ้า HP เหลือศูนย์ ผ่านห้องด้วย EncounterService → DungeonService ตัวจริง เหมือนทางเลือกโล่/แท่นเดิม จากนั้นยังต้องผ่านเงาด้วยแสงหรือทางอ้อม ไปห้อง 3 และรับผลที่แท่นจบ จึงได้ milestone จบดันเจียน การยิงผู้เฝ้าอย่างเดียวไม่ให้ milestone

HP เป็นของแต่ละผู้เล่นต่อรัน ไม่แก้ Humanoid/รูปลักษณ์ศัตรูร่วม ตายแล้วกลับ checkpoint เก็บ HP ที่ลดแล้ว เริ่มรันใหม่คืน 100 ทิ้งรัน/ออกเซิร์ฟเวอร์ไม่เก็บ HP ถาวร คูลดาวน์เป็นข้อมูล server ไม่รับ damage/เวลา/เป้าหมายจาก client มี request throttle ครอบคลุมคำขอโจมตีที่ถูกปฏิเสธด้วย

## ความก้าวหน้า

สมุดคัมภีร์แสดง ผู้ฝึกหัด → พร้อมภาคสนาม → ผ่านภาคสนาม จาก ShieldPassed และ DungeonCompleted ที่ ProgressService บันทึกอยู่แล้ว schema ยัง v4 ไม่มีการเพิ่ม counter หรือเปลี่ยนวิธี merge ข้อมูล ผู้เล่นเดิมได้ขั้นตาม flags ที่มีอยู่ การจบซ้ำไม่เพิ่มขั้นหรือพลัง นี่เป็นความชำนาญแบบ milestone ยังไม่มี EXP เลเวล วัสดุ อัปเกรด หรือของดรอปสำหรับฟาร์ม

## ตำแหน่งงาน

- `src/shared/CombatRules.luau`: บริบทและค่าทดลอง
- `src/shared/CombatAction.model.json`: RemoteEvent ผ่าน Rojo ทั้งสอง project
- `src/server/CombatService.luau`: ชีวิต/ระยะ/raycast/คูลดาวน์/HP ฝั่ง server และ cleanup ตอนออก
- `src/server/EncounterService.luau`: ทางผ่านด้วยโจมตี โดยตรวจ HP ศูนย์และบริบทรัน
- `src/server/DungeonService.luau`: คืน HP เมื่อเริ่มรันใหม่ ไม่คืนเมื่อ recovery
- `src/client/CombatController.luau`: HP, feedback, คูลดาวน์ และปุ่มโจมตี/โล่รวมในแผงเดียว ใช้ Q ผ่าน controller โล่เดิมและ C ผ่าน controller ใหม่
- `src/client/ShieldLessonController.luau`: คงแผงฝึก แต่ซ่อนแผงโล่ต่อสู้เดิมเมื่อแผงรวมพร้อม
- `src/client/ScrollModel.luau`: แสดงขั้นความชำนาญจาก flags ถาวร

HUD ใหม่ลงทะเบียน PH-UI-001 ใน ASSET_TRACKER ไม่มี asset/texture/เสียงภายนอก ไม่มี VFX กระสุนหรืออนิเมชันใหม่ การโจมตีใช้ข้อความและ HP เป็น feedback ชั่วคราว ต้องทำงานภาพ/เสียงก่อนรับเป็น combat presentation จริง

## หลักฐานตรวจ

`python3 scripts/check_luau.py --bin-dir /tmp/mythic-luau-tools`: compile 95 ไฟล์ ผ่าน 1291 assertions บน API doubles รายงาน `build/luau-checks.json`

เพิ่ม integration ของ CombatService → EncounterService → DungeonService 38 checks: ปลดล็อก, บริบทผิด, ตาย, ระยะ, สิ่งกีดขวาง, คูลดาวน์/ยิงซ้ำ, HP แยกผู้เล่น, recovery, ศูนย์ HP ผ่านห้องจริง, ไม่ผ่านก่อนเวลา, action ปลอมและ client แทรก damage, cleanup ตารางเมื่อออก ตรวจ request routing ผ่าน RemoteEvent double ด้วย

เพิ่ม controller checks สำหรับ C/สัมผัส/คูลดาวน์/ปิดขณะพักรัน/ปุ่มยังไม่ปลดล็อก/แผงรวมไม่ซ้อนแผงโล่และ cleanup; ทดสอบ service flow เดิมว่าเริ่มรันคืน HP และ recovery เก็บ HP; reward persistence stack ทดสอบว่าขั้นความชำนาญกลับมาหลัง save/leave/rejoin

`python3 -I tests/placeholder_scan_test.py`: 12 tests ผ่าน; placeholder scan 97 แถวตรงทะเบียน; `rojo build` ทั้ง default และ experimental-v2 ผ่าน

## งานที่ยังต้องตรวจ

ยังไม่ตรวจภาพและท่าจริงของชุดนี้, ข้อความภาษาไทยบนมือถือ, ความชัด feedback ขณะหลบ/กางโล่, แนว raycast กับ geometry ใน Roblox, latency/หลายผู้เล่นจริง และ DataStore จริง ผล doubles ไม่ยืนยันเรื่องเหล่านี้ เครื่องมือ CUA เชื่อม Studio ไม่สำเร็จในงานฉากก่อนหน้า (`native pipe startup failed`) จึงไม่อ้างผลภาพเดิมเป็นการรับ combat ใหม่นี้

ขั้นถัดไปตรวจรับวงจรในเกมและปรับสมดุล/feedback ก่อนขยายความชำนาญหลายขั้น/วัสดุ แล้วจึงทำของแต่งและร้านขายตรงตาม RULES ยังไม่มีธุรกรรมหรือสินค้าจ่ายเงินจริงในขั้นนี้
