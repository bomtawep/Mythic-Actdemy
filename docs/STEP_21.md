# Step 21 — preview ก่อนยืนยันวางม้านั่ง

- ปุ่มย้าย/หมุนปรับ draft บน client และแสดงม้านั่งโปร่งแสง ยังไม่ย้ายเฟอร์นิเจอร์จริงหรือบันทึกข้อมูล
- ยืนยันส่ง Commit พร้อม x/z/rotation/placed ไป server; server ตรวจ schema finite/grid/footprint เจ้าของ ตำแหน่งผู้เล่นและ lease ผ่านช่องทางเดิมก่อนเปลี่ยนจริง
- ตำแหน่งวางไม่ได้เป็นสีเตือนพร้อมข้อความ ไม่พึ่งสีอย่างเดียว กดยืนยันไม่ได้ใน client และ server ปฏิเสธ payload ที่ข้าม UI ด้วย
- ยกเลิกคืน draft จาก attributes ที่ server ยืนยันล่าสุด เก็บส่งคำสั่งเก็บชิ้นจริง ปุ่มเดิม Move ยังรองรับฝั่ง server สำหรับการทดสอบ/compatibility
- Server ส่ง DormCenter/Dorm_x/z/rotation/placed และ DormRevision กลับ client; draft reset เมื่อเข้าห้องหรือเซิร์ฟเวอร์ยืนยัน revision ใหม่
- ลบ preview เมื่อออกห้องหรือ HUD ถูกทำลาย ไม่มี asset ภายนอกเพิ่ม

## ผลตรวจ

compiler 48 ไฟล์ผ่าน; tests เดิม 425 + preview model 6 + Commit flow 3×2 = 437 assertions ผ่าน รวม Commit ใน DormService จริงกับ persistence stack และการปฏิเสธนอกขอบ/NaN Rojo build/sourcemap/XML ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ preview สี/ความชัด/การบังเฟอร์นิเจอร์เดิม/มือถือหรือ client runtime; โมเดลดัมมี่ยังคงขนาดม้านั่งเดียว ไม่มีลากวางด้วย pointer/gamepad

ขั้นถัดไปทดสอบ client controller ด้วย event/Instance doubles เพื่อยืนยันว่าการเลื่อน preview ไม่ยิง remote และยกเลิก/ออกห้องล้างภาพครบ ก่อนเพิ่มเฟอร์นิเจอร์ชนิดใหม่
