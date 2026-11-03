# Step 18 — schema และ repository บันทึกห้องพร้อม lease

อัปเดต: Step 19 เชื่อม persistence manager กับ DormService แล้ว ดู STEP_19.md สถานะยังไม่เชื่อมด้านล่างเป็นบันทึก ณ Step 18 ไม่ใช่สถานะล่าสุด

เพิ่มฐาน persistence ใน DormSchema/DormRepository แยกจาก ProgressSchema ขั้นนี้ยังไม่เชื่อม DormService: ห้องในเกมยังเป็น session-only ไม่มีคำขอ DataStore ห้องจริงในงานนี้

- schema v1 เก็บ furniture x/z บน grid, หมุน 0/90/180/270, placed และ Lease(Token, Expires) ตรวจชนิด/ขอบเขต/NaN/Version ก่อนใช้ ไม่เขียนค่าเริ่มทับข้อมูลเสีย
- repository รับ storage adapter, key, token เฉพาะ session และ clock จากภายนอก ใช้ UpdateAsync อ่านและรับ lease ใน transaction เดียว
- lease 120 วินาที เซิร์ฟเวอร์อื่นรับไม่ได้ก่อนหมดอายุ Save/Release ต้องมี token ตรงและยังไม่หมดอายุ
- Save ต่ออายุ lease; Release เซฟ snapshot และปล่อย lease พร้อมกัน session ที่ปล่อยแล้วเขียนต่อไม่ได้
- ป้องกัน operation ซ้อนภายใน repository ชุดเดียว ข้อมูลข้าม server ป้องกันด้วย lease ใน stored value ไม่ใช้ max(Stage) กับเฟอร์นิเจอร์ที่ลด/ย้ายได้
- ไม่มี retry/autosave/shutdown/UI ใน adapter นี้ ผู้เรียกต้องเพิ่มก่อนเชื่อม gameplay และห้ามแก้ห้องต่อเมื่อยืนยันสิทธิ์เขียนไม่ได้

## ผลตรวจ

compiler 43 ไฟล์ผ่าน; tests เดิม 352 + repository/schema 21 = 373 assertions ผ่าน ครอบคลุมสอง server แย่ง lease, เซฟ/ปล่อย/กู้ข้อมูล, หมดอายุ, เซิร์ฟเวอร์เก่า, outage, operations ซ้อน, schema เสียและ bounds Rojo build/sourcemap ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ทดสอบ DataStore จริง/การ retry callback บนเครือข่าย/การปิด server; ไม่มีการอ้างว่าห้องบันทึกถาวรแล้ว

ขั้นต่อไปเชื่อม persistence manager เข้ากับ DormService เพิ่ม token generation, renewal ก่อน 120 วินาที, dirty snapshots/retry, โหลดล้มเหลวไม่เปิดแก้ห้อง และ release ตอนออก/ปิด server พร้อมทดสอบทั้งหมด

อ้างอิงแนวคิด atomic UpdateAsync และ session locking: [Roblox player data systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing)
