# Step 54 — คำใบ้ปุ่มตามอุปกรณ์และแสงบ่ายแก่

ทำต่อจากข้อสังเกต Step 53 และ D60

## เปลี่ยน

- `src/client/KeyHint.luau`: ต่อท้าย `[ปุ่ม]` เฉพาะเมื่อ `UserInputService.KeyboardEnabled` ใช้ใน JournalController (สมุด/ปิด [B]), PetController ([P]), LevitationController ([R][F][G][X]), ShieldLessonController ([Q]) บนจอสัมผัสอย่างเดียวจะเห็นแค่ชื่อปุ่ม
- `default.project.json`, `experimental-v2.project.json`: `Lighting.$properties.ClockTime = 16.5` ค่าเดียวที่ตั้งจาก source

## ผลตรวจ

- check_luau ผ่าน: compiler 91 ไฟล์ tests 1236 assertions (+1 light client: มีคีย์บอร์ดเห็น "สมุดนักเรียน [B]"; +1 metadata: จอสัมผัสเห็น "เก็บคู่หู" ไม่มี [P])
- Rojo build ทั้งสองไฟล์มี `ClockTime` 16.5; sourcemap ผ่าน
- ใน Studio ที่เชื่อม `rojo serve` อยู่ ค่า Lighting ยังเป็น 14 เพราะ serve ไม่ sync การเปลี่ยน service properties แบบสด ต้องรีสตาร์ต `rojo serve` หรือเปิด `build/MythicAcademy.rbxlx` ใหม่ ยังไม่ได้ดูภาพแสงบ่ายแก่

## ไม่ได้ทำ

ทดสอบ Server & 2 Clients เริ่มแล้ว (Studio เปิด server + 2 client) แต่ผู้ใช้สั่งหยุดก่อนได้ผล ยังไม่มีหลักฐานหลายผู้เล่นในเกมจริง
