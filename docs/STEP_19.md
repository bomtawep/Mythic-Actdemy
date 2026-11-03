# Step 19 — เชื่อม persistence หอพัก

เชื่อม DormService กับ DormPersistence และ DormDataManager ใช้ schema/repository Step 18 แล้ว ไม่แก้ ProgressSchema

- Server จริงใช้ DataStore `MythicAcademy_Dorm_v1` key `room_<UserId>` token UUID ใหม่ต่อ player session Studio ใช้ memory adapter ไม่เปิด store จริง ข้อมูลหายเมื่อ Stop
- โหลด/acquire lease ก่อนสร้างห้อง ตรวจผู้เล่นยังอยู่ มีชีวิต อยู่ใกล้ประตูและเงื่อนไขเกมอีกครั้งหลังโหลดที่ yield
- แก้ห้องได้เฉพาะ profile โหลดสำเร็จและ lease ยังใช้ได้ สถานะตำแหน่งอยู่ memory; save/renew ทุก 30 วินาที lease 120 วินาที
- snapshot ระหว่างเซฟไม่ทับการแก้ล่าสุดใน memory เซฟรอบถัดไปเก็บค่าล่าสุด หนึ่ง operation ต่อ profile; retry StorageError สูงสุด 3 ครั้ง ไม่ retry ข้อมูลเสีย/เสียสิทธิ์
- lease หมด/ถูกย้าย/ข้อมูลเสียหยุดแก้ห้อง ต้องออกเข้าใหม่ ไม่มี fallback เขียนค่าเริ่มทับ profile
- ออกจาก server บันทึกค่าล่าสุดและ release; BindToClose หยุด load/edit ใหม่ ปิด profile แบบขนานและรอสูงสุด 25 วินาที ใช้ lease expiry เป็นทางกู้คืนกรณีปล่อยไม่ได้
- HUD หอพักแยกสถานะตำแหน่งกับสถานะเซฟ; โหลดห้องไม่ได้แจ้งผ่านคำใบ้หลัก ไม่อ้างว่าเซฟแล้วเพียงเพราะวางสำเร็จ

## ผลตรวจ

compiler 46 ไฟล์ผ่าน; tests เดิม 373 + manager 20 = 393 assertions ผ่าน ครอบคลุมล็อกชน โหลด/เซฟล้มเหลว retry snapshot ระหว่างแก้ renewal close/rejoin expiry และ shutdown admission Rojo build/sourcemap/XML ผ่าน

manager/repository ทดสอบด้วย storage doubles และ DormService flow เดิมใช้ persistence stand-in ยังไม่เป็น full end-to-end กับ datastore; timer/BindToClose/UUID/latency จริงและภาพยังไม่ตรวจ ไม่เปิด Studio ตาม D16 ไม่มีการเรียก store จริงในงานนี้

หากบริการล่มหรือ server crash ก่อนเซฟสำเร็จ อาจสูญเสียตำแหน่งที่ยังค้างใน memory; หาก load สำเร็จฝั่ง storage แต่ response หาย lease อาจค้างได้ถึง 120 วินาที ไม่ถือว่าเป็นข้อมูลว่าง

ขั้นถัดไปขยาย flow tests ให้ DormService ใช้ persistence manager/repository ตัวจริงร่วมกัน รวมผู้เล่นออกระหว่างโหลดและ server shutdown ก่อนเพิ่มเฟอร์นิเจอร์
