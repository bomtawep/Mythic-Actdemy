# Step 22 — ทดสอบ client preview controller

เพิ่ม `tests/dorm_controller_flow.luau` รัน DormController ตัวจริงกับ ControllerScope/DormPreviewModel/DormRules และ Instance/event doubles ไม่ได้เปลี่ยน production gameplay หรือเพิ่ม asset

ทดสอบเริ่มจากของเก็บ, เลื่อน/หมุนไม่ส่ง remote, Confirm ส่ง Commit หนึ่งครั้งพร้อม snapshot ไม่เปลี่ยนตาม draft ภายหลัง, throttle, Cancel คืน server state โดยไม่ส่ง, invalid footprint ไม่ commit และมีข้อความ, Store ส่งแยก, server revision reset draft, ออกห้องลบ preview, ปุ่มซ่อนไม่ส่ง, เข้าใหม่สร้างภาพใหม่, ทำลาย HUD ลบภาพและ event ไม่สร้างกลับ

## ผลตรวจ

compiler 49 ไฟล์ผ่าน; tests เดิม 437 + controller flow 18 = 455 assertions ผ่าน Rojo build/sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ตัว Instance double ไม่ใช่ renderer และ CFrame double ไม่จำลอง rotation matrix ยังไม่ตรวจภาพจริง/สี/ข้อความไทย/มือถือ/Input จริง/latency หรือ DataStore จริง ชุดทดสอบนี้เพิ่มหลักฐาน callback และ lifecycle ไม่ใช่ผล visual QA

ขั้นถัดไปกำหนด catalog/ชนิดเฟอร์นิเจอร์และแผนย้าย schema ก่อนเพิ่มชิ้นใหม่ เพราะข้อมูลปัจจุบันเก็บม้านั่งชิ้นเดียว ไม่ควรยัดหลายชิ้นเข้า field เดิมโดยไม่มี migration
