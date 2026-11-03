# Step 09 — แยกบริการบทเรียนและตรวจ lifecycle เวท

- Main เหลือการเริ่ม ProgressService, DungeonService และ LessonService ตามลำดับ
- LessonService รับผิดชอบ prompt บทเรียน/กลไก/รางวัล, session เวท, remote และการล้าง session เมื่อออก/ตาย พร้อม guard ป้องกัน Start ซ้ำ
- LevitationRules รวมกฎอายุ session ระยะ ขั้นข้อมูล ความพร้อม station และสถานะดันเจียน ใช้ทั้ง remote และ Heartbeat ลดความต่างของเงื่อนไขยกเลิก
- แก้กรณีข้อมูลไม่พร้อม/ดันเจียนพักหรือเปลี่ยน state แล้วเวทค้าง: ยกเลิกเมื่อกฎไม่ผ่าน ไม่ปล่อยค้างจนหมดเวลา
- ยังคงเวทควบคุมระดับเดิม ไม่เพิ่มคอนเทนต์ ศัตรู asset หรือ schema ข้อมูล

## ผลตรวจ

Luau compiler 22 ไฟล์ผ่าน; tests เดิม 175 + lifecycle เวท 17 = 192 assertions ผ่าน Rojo build/sourcemap และ export mapping ผ่าน

ทดสอบกฎ valid/invalid จากสถานะข้อมูล ขั้น ระยะ station เวลา dungeon pause รวมขอบเขตระดับผลึก ไม่ใช่การจำลอง event และ Instance ของ LessonService ครบทั้งตัว ยังไม่ตรวจ type ด้วย Roblox definitions, runtime, ภาพ หรือ event order จริง ไม่เปิด Studio ตาม D16

ขั้นถัดไปเลือก encounter ศัตรูต้นแบบหนึ่งพฤติกรรม พร้อมคำเตือนที่อ่านได้และทางออก ไม่ขยายจำนวนศัตรู/บอสทั้ง MVP ในครั้งเดียว
