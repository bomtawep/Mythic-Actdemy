# Step 25 — manager v2 สำหรับหลายชิ้น

เพิ่ม DormDataManagerV2 แบบ candidate ใช้ Items กับ repository v2 แยกจาก manager v1 ที่ gameplay ยังใช้อยู่

- get/set/save/close คัดลอกข้อมูลชั้นในของทุกชิ้น ไม่แชร์ table กับผู้เรียก
- revision บอกการแก้ระหว่างเซฟ snapshot เก่า เซฟสำเร็จไม่ล้าง state ล่าสุดหรือแจ้งว่าเซฟครบทั้งที่มี revision ใหม่ค้าง
- set ยอมให้เปลี่ยน placement ของ inventory ที่โหลดมาเท่านั้น จำนวน Id และ CatalogId ต้องตรงเดิม ปฏิเสธเพิ่มของ ลบสิทธิ์ สลับชนิดหรือเปลี่ยน ID
- validator v2 ตรวจ collision/ขอบเขตทั้งรายการก่อนเก็บใน memory
- คง lease/retry/load-failure/close/shutdown เหมือนฐาน v1; manager นี้ยังไม่มีเส้นทางแจก/ซื้อของใหม่ ต้องเพิ่ม transaction ฝั่ง server แยกภายหลัง

## ผลตรวจ

compiler 56 ไฟล์ผ่าน; tests เดิม 494 + v2 manager 23 = 517 assertions ผ่าน รวมสองชนิด, deep copy, inventory admission, snapshot ระหว่างแก้, renewal/outage, close/reload/expiry และ legacy migration ผ่าน repository จริงบน storage doubles Rojo build/sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ไม่ตรวจภาพ/runtime/DataStore จริง ไม่มี asset ใหม่ ไม่มีการย้ายข้อมูลผู้เล่นจริง และห้อง gameplay ยังใช้ v1 ม้านั่งเดียว

ขั้นถัดไปเชื่อม service/persistence/UI แบบ Items พร้อมเลือก Id และตรวจขอบเขตตาม catalog โดยใช้ migration ที่ทดสอบแล้ว ก่อนสลับ runtime v2
