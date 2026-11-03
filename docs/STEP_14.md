# Step 14 — แยก HUD/ตัวควบคุมเวทและจัดการอายุภาพ

Main.client เหลือการประกอบ HudController, LevitationController, สมุด คู่หู และ encounter แยกโค้ด HUD/เวทออกโดยคงชื่อ GUI และ remote เดิม

- VisualLifetime ให้ภาพเวทมีเจ้าของได้หนึ่ง station ต่อครั้ง ไม่สร้างซ้ำเมื่อระดับเปลี่ยน เก็บภาพเก่าเมื่อเปลี่ยน station/ยกเลิก และ dispose ซ้ำได้
- เมื่อ HUD ถูกทำลาย ยกเลิก tween คืนความโปร่งใสของผลึกต้นทาง ลบภาพส่วนตัว/เป้าหมาย และตัด event ของ HUD/เวท
- ค้นผลึกแบบไม่ yield ใน callback ถ้าชิ้นยังไม่มาไม่ค้าง WaitForChild เก็บปุ่มยกเลิกให้ใช้ได้ และลองใหม่เมื่อ child ของฉากถูกเพิ่มหรือ attributes เปลี่ยน
- ไม่ได้เพิ่ม cleanup ให้ controllers อื่นครบทั้งระบบ และยังไม่ได้ทดสอบ client Instances/Input ใน Roblox จริง

## ผลตรวจ

Luau compiler 33 ไฟล์ผ่าน; tests เดิม 296 + visual lifetime 11 = 307 assertions ผ่าน ครอบคลุมสร้างครั้งเดียว เปลี่ยน station ยกเลิก สร้างไม่สำเร็จ/ลองใหม่ dispose ซ้ำและห้ามสร้างหลัง dispose Rojo build/sourcemap/XML และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ actual tween/GUI Destroying/streaming/input จริง ผล tests เป็น resource callbacks จำลอง ไม่ใช่การรับรอง controller integration

ขั้นถัดไป: ขยาย cleanup และทดสอบ event lifecycle ของ controllers ที่เหลือ ก่อนเพิ่มระบบหอพัก/การวางของ
