# Step 15 — cleanup สมุด คู่หู และคำเตือน

เพิ่ม ControllerScope จัดการ connections/cleanup ของ JournalController, PetController และ EncounterController เมื่อ HUD ถูกทำลาย ไม่เปลี่ยนเกมเพลย์/schema/remote

- ตัด attribute/input/render/player-removal events และกัน callback ที่เข้าคิวแล้วไม่ให้ทำงานหลัง dispose
- ลบภาพคู่หูทั้งหมดบน client ลบพื้นที่เตือน/ป้ายผู้เฝ้า และคืนค่า LocalTransparencyModifier เดิม
- dispose ซ้ำได้ cleanup รายการหนึ่งล้มเหลวยังพยายามเก็บรายการที่เหลือต่อ พร้อมแจ้ง warn
- ปิดสมุดด้วย B/ปุ่มปิดเป็นเพียงซ่อนเพื่อเปิดใหม่ ไม่ dispose controller ทั้งตัว
- Main.client ส่ง GUI owner ให้ EncounterController ด้วย

## ผลตรวจ

Luau compiler 35 ไฟล์ผ่าน; tests เดิม 307 + ControllerScope 10 = 317 assertions ผ่าน ครอบคลุม disconnect ทุก connection callback หลัง dispose ไม่ทำงาน ไม่ลงทะเบียนใหม่ cleanup ของที่เพิ่มภายหลัง และ cleanup ล้มเหลวไม่ข้ามรายการอื่น Rojo build/sourcemap/XML และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจ actual Destroying/render/model/input หรือ client controllers ครบตัวใน Roblox; tests เป็น scope กับ event doubles และชุดบริการเดิม ไม่ยกระดับเป็น game-tested

ไม่มี asset ใหม่ generator path/ID ใน tracker เดิมยังใช้ ขั้นต่อไปเริ่มหอพักห้องตัวอย่างและวางของหนึ่งชิ้น โดยแยกสิทธิ์เจ้าของ/ขอบเขตวางจากข้อมูลบทเรียนก่อนเพิ่ม persistence ของห้อง
