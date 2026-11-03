# Step 23 — catalog และ schema migration หลายชิ้น

เพิ่ม FurnitureCatalog แบบ immutable: Bench 4×2×2 และ Stool 2×2×2 studs เป็นขนาดทดลอง ไม่ใช่งานภาพหรือสิทธิ์ซื้อ เพิ่ม DormSchemaV2 เป็น candidate ยังไม่สลับ runtime repository จาก v1

- v2 เก็บ Items สูงสุด 8 ชิ้น แต่ละชิ้นมี Id คงที่และ CatalogId แยกจากกัน พร้อมตำแหน่ง/หมุน/วาง
- แปลง v1 ม้านั่งชิ้นเดียวเป็น `starter-bench-001` คงตำแหน่ง การหมุน placed และ lease เดิม ไม่แก้ source
- migrate v2 ซ้ำเพียงตรวจ/คัดลอก ไม่เพิ่ม starter ซ้ำ ข้อมูลเสีย/Version ใหม่ปฏิเสธ ไม่ fallback ทับ
- ตรวจ ID ซ้ำ catalog ไม่รู้จัก finite/grid/footprint bounds จำนวนชิ้นและ array แบบ dense รวม placed objects ทับกันไม่ได้ (ขอบชนกันได้ ของเก็บไม่ชนกัน)
- ไม่มี model เก้าอี้เพิ่มหรือการแจกเก้าอี้จริง ยังไม่มี UI เลือกหลายชิ้น/การซื้อ/runtime placement v2

## ผลตรวจ

compiler 52 ไฟล์ผ่าน; tests เดิม 455 + catalog/migration 21 = 476 assertions ผ่าน Rojo build/sourcemap/XML และ whitespace ผ่าน ไม่เปิด Studio ตาม D16 ไม่ตรวจภาพหรือ DataStore จริง

ขั้นต่อไปเชื่อม v2 ทั้ง repository/manager/service/UI พร้อมทดสอบการย้ายข้อมูลภายใต้ lease เดียวกันก่อนเปิดหลายชิ้น ห้าม deploy writer v1 ร่วมกับ v2 โดยไม่มีแผน version admission และ rollback: v1 ต้องปฏิเสธ v2 ตามกฎเดิม ไม่ downgrade เงียบ ๆ
