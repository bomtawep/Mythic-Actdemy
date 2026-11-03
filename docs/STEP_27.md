# Step 27 — v2 flow tests และเปิดค่าเริ่มต้นใน build local

เพิ่มชุดทดสอบ DormServiceV2 + DormPersistenceV2 + manager/repository/schema จริงกับ storage/Players/world doubles และรัน DormControllerV2 จริงกับ Instance/event doubles

- service: สองผู้เล่น มีสอง Items ใน fixture ของผู้เล่นแรกและ v1 ในผู้เล่นที่สอง เลือก Id/CatalogId, ปฏิเสธ stale selection/collision/cross-room, payload เปลี่ยนชนิดไม่ได้, เก็บเฉพาะชิ้น, save/rejoin ไม่ซ้ำ และ release ทั้งสองตอน shutdown
- client: flow draft/confirm/cancel/cleanup เดิมทั้งหมด พร้อม Next, payload Id และ preview เปลี่ยนขนาดเป็น Stool ตาม catalog
- fixture สองชิ้นเป็นข้อมูลทดสอบเท่านั้น ไม่แจก Stool ให้ผู้เล่นจริง

## ผลตรวจและการเปิดใช้

compiler 62 ไฟล์ผ่าน; tests เดิม 525 + service v2 19 + client v2 22 = 566 assertions ผ่าน build หลัก/experimental และ sourcemap ผ่าน

หลัง mock flow ผ่าน ตั้ง DormV2Enabled=true ใน default.project.json แล้ว Build หลัก local ใช้ v2 ส่วน experimental project ยังอยู่ ไม่มีการเผยแพร่หรือเรียก DataStore จริงในงานนี้ เมื่อใช้งาน server จริง acquire จะ migrate v1 ภายใต้ lease ตาม Step 24; ห้าม rollback writer เป็น v1 เพื่ออ่านข้อมูล v2 โดยคาดว่าจะ downgrade ให้

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ/physics/latency/Input หรือ DataStore จริง CFrame/Instance doubles ไม่รับรอง visual QA

ขั้นต่อไปปรับเอกสารภาพรวมให้ตรง implementation ปัจจุบัน และตรวจเส้นทางผู้เล่นแรกครบตั้งแต่บทเรียนถึงหอพักก่อนเพิ่มคอนเทนต์ใหม่
