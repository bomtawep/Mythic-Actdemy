# Step 30 — flow เวทแสงและสถานะในสมุด

เพิ่มการทดสอบ LightLessonService ตัวจริงด้วย event/world doubles สองผู้เล่น และ LightJournalModel แสดงสถานะยังไม่เรียน/เรียนแล้ว/ผ่านปริศนา พร้อมข้อความไม่บันทึกหลังออกเกมในสมุด

- ตรวจ stage gate ระยะ prompt ชีวิต throttle เริ่มก่อนเรียนไม่ได้ ร่ายสลับกลุ่ม/แก้สำเร็จ เริ่มใหม่ไม่ล้างความสำเร็จที่เคยได้ใน session แยกสองผู้เล่น
- ตรวจเดินออก ตาย เปลี่ยนกิจกรรม ข้อมูลไม่พร้อมและ character removal หยุด trial
- รวมเงื่อนไข eligibility ของ prompt/Heartbeat เพื่อแก้ trial ที่ยังค้างตอน Health=0 ก่อน CharacterRemoving หรือเงื่อนไขเรียนไม่ครบ
- ไม่เปลี่ยน schema ข้อมูลถาวรหรือแจกของ ไม่มี asset ใหม่

## ผลตรวจ

compiler 69 ไฟล์ผ่าน; tests เดิม 663 + journal 7 + service 21 = 691 assertions ผ่าน Rojo builds/sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 LightLessonController แสง/ป้ายจริงและสมุด UI ยังไม่ตรวจ integration ครบตัว ภาพ/physics/Input/มือถือ/DataStore จริงยังไม่ตรวจ การทดสอบบริการบน doubles ไม่ใช่ game-tested

ขั้นถัดไปตรวจ client เวทแสงและ HUD/สมุดร่วมกันด้วย Instance/event doubles ให้การเริ่ม–ผ่าน–หยุดแสดงผลตรงกัน ก่อนนำเวทแสงไปใช้ในพื้นที่สำรวจหรือห้องดันเจียนใหม่
