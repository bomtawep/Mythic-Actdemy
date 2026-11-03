# Step 39 — ShieldAction ร่วม encounter หลายผู้เล่น

เพิ่ม `tests/shield_combat_flow.luau` โหลด ShieldLessonService/ShieldGuard/EncounterService ตัวจริงร่วมกันและยิง OnServerEvent จำลอง ไม่เรียก Guard.Cast ตรงใน flow นี้

ฝึกจริงใน fixture จนได้ ShieldPassed → เข้าบริบทดันเจียน → ShieldAction/Cast → accepted target → encounter hit ใช้ผล guard ตรวจผู้เล่นอีกคนที่ยังไม่ผ่านฝึกว่าร่ายเลียนแบบไม่ได้และยังโดน damage ตามปกติ

ตรวจ consume, feedback, ปฏิเสธ cast ช่วงพัก, pause/death ล้าง accepted cast, เกิดใหม่ไม่ใช้ cast ชีวิตก่อน, ออกจากรันไม่รับ cast และ startup ซ้ำไม่สร้าง prompt ซ้ำ ไม่มี production gameplay/asset ใหม่ในขั้นนี้

## ผลตรวจ

compiler 86 ไฟล์ผ่าน; tests เดิม 793 + routing flow 15 = 808 assertions ผ่าน builds หลัก/experimental, sourcemap และ whitespace ผ่าน

ยังไม่ใช่ network จริง: Players/clock/remote/Heartbeat/TakeDamage เป็น doubles ไม่ตรวจ latency, streaming, physics, Input หรือภาพจริง ไม่เปิด Studio ตาม D16 ไม่รับรองเกมพร้อมเผยแพร่จากจำนวน assertions

ขั้นถัดไปเพิ่มตัวตรวจดัมมี่/coverage ของฉากและ generator ให้รายการ PH ตรง ASSET_TRACKER ก่อนขยายคอนเทนต์ต่อ ลดโอกาสลืมแทนของชั่วคราว
