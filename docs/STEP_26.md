# Step 26 — เชื่อม service และ UI v2 แบบทดลอง

อัปเดต Step 27: default project local เปิด v2 แล้วหลัง flow tests ผ่าน ข้อความ default ยัง v1 ด้านล่างเป็นบันทึก ณ Step 26

เพิ่ม DormPersistenceV2/DormServiceV2/DormControllerV2 และ FurniturePlacement ใช้ repository/manager v2 ที่ทดสอบแล้ว พร้อมสวิตช์ `ReplicatedStorage.DormV2Enabled` อ่านตอนเริ่ม server/client

- project หลัก `default.project.json` ยัง false ใช้ v1
- `experimental-v2.project.json` เปิด true; build ด้วย `rojo build experimental-v2.project.json -o build/MythicAcademyExperimentalV2.rbxlx`
- v2 ใช้ store/key เดิมเพื่อ migration ภายใต้ lease ใน server จริง; Studio ยัง memory แยกในรอบทดสอบ ห้ามสลับ flag ระหว่างกำลังเล่น ต้องเริ่ม session ใหม่
- service สร้างภาพ primitive แยกทุก Items ตาม catalog, เลือกชิ้นด้วย Next และส่ง SelectedId/CatalogId/จำนวน/revision ให้ client
- Commit ต้องเป็น Id ที่เลือกอยู่ เปลี่ยนเฉพาะ placement ของ inventory ที่โหลดมา ตรวจ schema/collision/สิทธิ์/lease ก่อนแก้ทั้ง snapshot
- UI preview ตามขนาด catalog และปุ่มชิ้นถัดไป ขอบเขตตรวจ client แต่การวางทับยังตัดสิน server ไม่มีการซื้อหรือแจก Stool เพิ่ม ผู้เล่นเดิม migrate ได้ม้านั่งหนึ่งชิ้นเดิมเท่านั้น

## ผลตรวจ

compiler 61 ไฟล์ผ่าน; tests เดิม 517 + selection/placement 8 = 525 assertions ผ่าน build หลักและ experimental ผ่าน ตรวจ exported flag false/true ตรงกัน

v2 service/UI ใหม่ยังไม่ผ่าน flow integration ครบตัว มีเพียง compiler/export และกฎ/manager/repository tests การทดสอบ flow v1 เดิมยังผ่าน ไม่เปิด Studio ตาม D16 ยังไม่ตรวจภาพ/runtime/DataStore จริง และไม่มี migration จริงในงานนี้

ขั้นถัดไปทดสอบ v2 service/UI กับสอง Items และสองผู้เล่น รวม selected Id ล้าสมัย/collision/restore ก่อนเปิด v2 ใน build หลัก
