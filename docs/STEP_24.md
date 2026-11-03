# Step 24 — atomic migration และ writer admission

เพิ่ม DormRepositoryV2 เป็น candidate writer ใช้ acquire transaction เดียวรับ lease และแปลงข้อมูล v1 → v2 ไม่เปลี่ยน runtime DormPersistence ซึ่งยังใช้ v1 อยู่

- ถ้า v1 มี lease ของ server อื่นที่ยังไม่หมดอายุ จะปฏิเสธโดยไม่เปลี่ยน Version หรือข้อมูล
- เมื่อว่าง/หมดอายุ แปลงข้อมูลคงชิ้นเดิมและเขียน lease ใหม่พร้อมกันใน UpdateAsync
- Save/Release v2 รับ Items ทั้ง snapshot ผ่าน validator ตรวจ schema/ชน/bounds และ token/expiry ไม่ย้าย schema ซ้ำในขั้น Save
- writer v1 ที่ค้างอยู่หรือเข้าใหม่หลังข้อมูลเป็น v2 จะปฏิเสธ InvalidSchema ไม่เขียน downgrade
- callback ถูก replay ไม่เพิ่ม starter ซ้ำ รองรับปล่อย lease แล้ว writer ใหม่โหลดสองชิ้นกลับพร้อม ID เดิม

## ผลตรวจ

compiler 54 ไฟล์ผ่าน; tests เดิม 476 + atomic migration/admission 18 = 494 assertions ผ่าน Rojo build/sourcemap และ whitespace ผ่าน

ทดสอบ old/new writer ตัวจริงร่วม storage doubles รวม active lease, expired lease, callback replay, invalid overlap, outage และ future Version ยังไม่ตรวจ DataStore จริง/เครือข่าย ไม่เปิด Studio ตาม D16

ไม่มีการย้ายข้อมูลผู้เล่นจริง ไม่มี asset ใหม่ และห้อง gameplay ยังเป็นม้านั่งเดียว v1

ขั้นต่อไปเชื่อม manager/service/UI ให้ใช้ Items พร้อมเลือกชิ้นงาน โดยทดสอบให้ครบก่อนสลับ writer จริง การ rollback กลับ build v1 จะโหลดข้อมูลที่ย้ายแล้วไม่ได้ ต้องคง reader v2 หรือทำเครื่องมือแปลงย้อนแยกหลังประเมินข้อมูล ไม่ downgrade อัตโนมัติ
