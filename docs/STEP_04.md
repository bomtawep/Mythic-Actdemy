# Step 04 — รันตรวจ Luau และทดสอบความผิดพลาดของข้อมูล

ขั้นนี้ปิดงานตรวจโค้ดที่ค้างจาก Step 03 ก่อนขยายสัตว์/ดันเจียน ไม่ได้เพิ่มคอนเทนต์หรือ asset ใหม่

## ผลที่รันจริง

- Luau CLI จาก release ทางการ: compile ไฟล์ Luau ใน src และ tests ครบ 8 ไฟล์ผ่าน (ตรวจไวยากรณ์ ไม่ใช่ type checking ของ Roblox)
- รัน ProgressSchema และ ProgressService ตัวจริงด้วยบริการ Roblox จำลอง ผ่าน 84 assertions
- ครอบคลุมข้อมูลผิดรูป/Version ใหม่, เซฟเก่าไม่ย้อนขั้น, retry ไม่เพิ่มรางวัล, ข้ามขั้นไม่ได้, โหลดล้มเหลวไม่เขียนทับ, เซฟล้มเหลวแล้วลองสำเร็จ, ขั้นเปลี่ยนระหว่างเซฟ, บล็อกเซฟซ้อน, ออกจากเกมระหว่างโหลด, ปิด profile แล้วเซฟข้อมูลค้าง และ Studio ไม่เปิด DataStore
- Rojo build/sourcemap และ diff whitespace ผ่าน
- รายงานพร้อม SHA-256 ของไฟล์ที่ตรวจอยู่ `build/luau-checks.json`; build ถูก ignore จาก Git ตามเดิม

## รันซ้ำ

ใช้ Luau CLI จาก [โครงการทางการ](https://github.com/luau-lang/luau/releases) ซึ่งมี `luau` และ `luau-compile` ในโฟลเดอร์เดียวกัน แล้วรัน:

```sh
python3 scripts/check_luau.py --bin-dir /path/to/luau-tools
rojo build default.project.json -o build/MythicAcademy.rbxlx
```

เครื่องมืองานนี้ดาวน์โหลดไว้ชั่วคราวที่ `/tmp/mythic-luau-tools` ไม่ได้เพิ่ม binary ใน repository หรือเปลี่ยนเครื่องมือ global

Runner รวม source ตัวจริงกับ service doubles ในไฟล์ชั่วคราว ไม่คัดลอก implementation ไปเขียนใหม่ในภาษาอื่น และไม่ใช้ credentials หรือส่งคำขอ DataStore

## ข้อจำกัดและขั้นถัดไป

ยังไม่ตรวจ Studio Play, ภาพ, อินพุต, physics, เวลา/queue จริงของ DataStore, autosave timer และ BindToClose ใน Roblox จริง ผล mock ไม่ยืนยันพฤติกรรมเครือข่ายหรือการปิดเซิร์ฟเวอร์จริง

ถัดไปต้องตรวจตาม STEP_02 และ STEP_03 ใน Studio/experience ทดสอบก่อนถือว่าวงจรหลักผ่าน จากนั้นจึงขยายสมุดนักเรียน สัตว์หนึ่งตัว และดันเจียนตาม ROADMAP โดยคงข้อจำกัดโมเดลพ่อมดเดิม
