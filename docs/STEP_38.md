# Step 38 — guard lifecycle และ feedback

ตรวจ ShieldGuard ตัวจริงบน doubles และเพิ่มความเข้มงวดที่ hit: ชีวิต/profile/Stage/รัน/พัก/เวทอื่นยังต้องพร้อม ไม่ใช้ cast เดิมเมื่อบริบทเปลี่ยน แม้ target timestamp จะตรง

- Guard.Reset ล้าง accepted cast กับ target เมื่อผู้เฝ้าถูกหยุด บริบท encounter ไม่ active หรือเปลี่ยนออกจาก Warning (รวมกรณีผู้เล่นหลบจนไม่มี hit)
- cast ใช้ครั้งเดียว target ต่างกันใช้ไม่ได้ กดเร็วเกินหมดช่วง กดซ้ำติด cooldown ระยะไกล/Rest/แรงลอยตัว/ผู้เฝ้าหยุดไม่รับ cast
- มี feedback เมื่อ server รับ cast และล้างข้อความรอบก่อนเมื่อเริ่ม Warning ใหม่
- client combat UI ต้อง profile พร้อม/Stage 3 เพิ่มเติมก่อนแสดงปุ่ม

## ผลตรวจ

compiler 85 ไฟล์ผ่าน; tests เดิม 776 + guard lifecycle 16 + UI readiness 1 = 793 assertions ผ่าน builds หลัก/experimental, sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ/latency/Input/physics/network จริง ค่าช่วงเวลาเป็นค่าทดลอง ไม่มี asset/schema/รางวัลใหม่

ขั้นถัดไปเพิ่มหลักฐาน routing ShieldAction ผ่านบริการจริงร่วม Encounter และสถานการณ์หลายผู้เล่น/การตาย แทนการเรียก Guard โดยตรงในบาง fixture ก่อนปรับความยากหรือเพิ่มศัตรู
