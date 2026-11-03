# Step 08 — checkpoint และกู้คืนรันหลังตาย

อัปเดต Step 09: แยก LessonService/LevitationRules จาก Main แล้ว ดู STEP_09.md

เพิ่ม checkpoint เฉพาะรอบเล่น ไม่เปลี่ยน schema ข้อมูลถาวร

- เมื่อตาย/character ถูกนำออกระหว่างรัน จะพักรันด้วย DungeonPaused แทนล้างปริศนาที่ทำแล้ว เกิดใหม่ที่โรงเรียนตามระบบเดิม
- ใช้ประตูเข้าห้องทดลองอีกครั้งเพื่อกลับไปต่อ: ถ้ายังไม่แก้ปริศนาไปจุดเริ่มห้อง ถ้าแก้แล้วหรือรับผลแล้วไป checkpoint ใกล้แท่นจบ
- การกู้คืนรักษา state Reward/Complete จึงไม่บังคับแก้ซ้ำและไม่เปิดรับผลซ้ำหลังจบ
- ระหว่างพักรัน แก้ปริศนาและรับผลไม่ได้ ต้องกู้คืนผ่านประตูก่อน Server ตรวจสิทธิ์ Stage 3 และข้อมูลพร้อมเหมือนเดิม
- ออกทางประตูกลับเป็นการยกเลิกรัน เริ่มใหม่ได้ ออกจากเซิร์ฟเวอร์แล้วไม่กู้คืนรัน ยังไม่มี cross-server checkpoint/party

## ผลตรวจ

Luau compiler 19 ไฟล์ผ่าน; tests 84 progress + 28 journal + 28 pet + 35 dungeon = 175 assertions ผ่าน ตรวจกรณี recovery ตาม state, ไม่พัก, ข้อมูลไม่พร้อม, สิทธิ์ไม่ครบและ state ไม่รู้จัก Rojo build/sourcemap และ XML checkpoint ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจ event order ขณะตายจริง การย้าย character กล้อง และภาพ checkpoint ผลทดสอบกฎไม่แทน runtime Roblox

ขั้นต่อไป: แยกบริการบทเรียน/เวทจาก Main พร้อมทดสอบ lifecycle ก่อนเพิ่ม encounter ศัตรูหนึ่งพฤติกรรม
