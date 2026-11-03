# Step 36 — flow ม่านคุ้มกันและผลในสมุด

เพิ่ม ShieldLessonService flow ตัวจริงกับ clock/Players/world doubles และเชื่อม ShieldLessonController ตัวจริงในชุดทดสอบ HUD/แสง/สมุดบน Instance/event doubles

- server ตรวจ prerequisite, cast ตรงเวลา/เร็วไป, กัน 2/3 ผ่าน, all-miss retry, ไม่ hit หลังจบ, เริ่มใหม่ไม่ล้างความสำเร็จ session, ออกพื้นที่/character removal/ข้อมูลไม่พร้อม/เข้าหอพักยกเลิก และไม่แก้ saved Stage
- client ตรวจ panel/HUD, Q ส่งเฉพาะ Cast, throttle, processed input ไม่ส่ง, จบแล้วซ่อน panel และผลในสมุด, HUD ถูกทำลายแล้ว input ไม่ส่ง
- เพิ่ม ShieldJournalModel และ Entry8 ของสมุด สถานะเซฟเดิมย้าย Entry9 ระบุไม่บันทึกหลังออกเกม แก้ escape ขึ้นบรรทัดใหม่ใน feedback controller

## ผลตรวจ

compiler 83 ไฟล์ผ่าน; tests เดิม 744 + shield service 16 + client 7 = 767 assertions ผ่าน builds หลัก/experimental, sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 clock และ input เป็น doubles ยังไม่ตรวจ latency/TakeDamage/visual timing/การกดจริงบนมือถือหรือ DataStore จริง ไม่มี asset ใหม่ ไม่อ้างว่าเวทป้องกันพร้อมผลิต

ขั้นถัดไปนำม่านคุ้มกันไปใช้กับ encounter ผู้เฝ้าดันเจียนเดิม โดยใช้ผลตัดสิน server ร่วมกันและไม่ลบทางอ้อม/ทางกลับ
