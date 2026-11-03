# Step 17 — ทดสอบหอพักหลายผู้เล่นและ lifecycle

เพิ่ม `tests/dorm_service_flow.luau` รัน DormService ตัวจริงกับ API doubles ของ Players/remote/prompt/character/template โดยใช้ตำแหน่ง template จากไฟล์ JSON จริง และเพิ่ม guard เริ่มบริการซ้ำ

ตรวจสองเจ้าของแยกห้อง วาง/ย้ายแล้วไม่เปลี่ยนของคนอื่น throttle คำสั่งถี่ ปฏิเสธแก้จากห้องอื่น/payload ปลอม/ข้อมูลไม่พร้อม/ตาย/อยู่นอกห้อง กลับเข้าห้องเดิมคงเฟอร์นิเจอร์ ตายปิด InDorm ประตูกลับโรงเรียน ดันเจียนยังไม่จบเข้าห้องไม่ได้ ออกเกมลบเฉพาะห้องตนและคืน slot ให้เจ้าของใหม่

## ผลตรวจ

Luau compiler 40 ไฟล์ผ่าน; tests เดิม 332 + DormService flow 20 = 352 assertions ผ่าน Rojo build/sourcemap และ diff whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ/physics/latency/client UI จริง CFrame ใน API double ตรวจตำแหน่งเท่านั้น ไม่จำลอง rotation matrix; footprint การหมุนทดสอบแยกใน DormRules แล้ว ไม่รับรองรูปทรง/กล้องจริงจากผลนี้

ไม่มีสินทรัพย์หรือคอนเทนต์ใหม่ และยังไม่บันทึกห้องหลังออกเกม ขั้นต่อไปต้องออกแบบ schema ห้องกับ ownership/session lock แยกจาก Stage แบบเพิ่มได้อย่างเดียว ก่อนทำ persistence ของเฟอร์นิเจอร์ที่ย้าย/เก็บได้
