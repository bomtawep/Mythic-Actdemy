# Step 34 — presentation แสงร่วมและ flow สองจุด

รวม LightLessonController/LightExploreController เป็น wrappers ใช้ LightPresentation และ immutable LightPresentationConfigs ร่วมกัน แยก prefix ของ rune, bits/unlocked, resource names และกิจกรรมที่ห้ามแสดงซ้อน

- pattern บทเรียนและสวนแยกกัน ใช้ eligibility การแสดงผลและ cleanup เดียวกัน
- ขณะสวน active ซ่อนชุดบทเรียน และขณะบทเรียน active ซ่อนชุดสวน เมื่อจบ/กลับบริบทปกติคง pattern ล่าสุดของแต่ละจุด
- เพิ่ม flow client จริงร่วมสอง presentation/HUD/สมุดบน Instance/event doubles ทั้ง pattern 101/010, เป้าหมายสวน, journal discovery และล้างทรัพยากรหกดวง/ป้ายทั้งหมด
- ไม่เพิ่ม remote, schema, asset หรือคอนเทนต์ใหม่

## ผลตรวจ

compiler 77 ไฟล์ผ่าน; tests เดิม 726 + combined presentation 5 = 731 assertions ผ่าน (client flow รวม 22) builds หลัก/experimental, sourcemap และ whitespace ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจ renderer/ความสว่าง/ข้อความ/การบังฉาก/มือถือ/Input/บริการจริง การทดสอบ Instance doubles ไม่แทน visual QA

ขั้นถัดไปกลับไปขยาย Prototype ตามแผน: เวทที่สามที่เล่นต่างจากการยก/สลับแสง พร้อมโจทย์ใช้จริงหนึ่งแบบ โดยคงจำนวนคอนเทนต์เป็นขอบเขตทดลองไม่อ้างว่า MVP ครบ
