# Step 33 — บริการปริศนาแสงร่วม

ย้าย lifecycle ที่ซ้ำใน LightLessonService/LightExploreService ไป LightPuzzleService factory และ LightPuzzleConfigs แบบ immutable wrappers เดิมเหลือเลือก config แล้วสร้าง starter ที่ป้องกันเริ่มซ้ำ

- config แยกชื่อแท่น/rune, เป้าหมาย 101/010, กลุ่ม attributes, prerequisite และกิจกรรมที่ห้ามเปิดซ้อน
- เงื่อนไข profile/Stage/ชีวิต/ระยะ/กิจกรรม, throttle, รีเซ็ต, cast, สำเร็จ และหยุดจาก Heartbeat ใช้ implementation เดียวกัน
- พฤติกรรมเดิมคงอยู่ ไม่เปลี่ยน schema, รางวัล, scene หรือ remote ไม่มี asset ใหม่

## ผลตรวจ

compiler 75 ไฟล์ผ่าน; tests เดิม 723 + mutual exclusion ร่วมสอง config 3 = 726 assertions ผ่าน รัน service flow บทเรียน 24 และสำรวจ 12 รวมชุดเดิมทั้งหมด Build หลัก/experimental และ sourcemap ผ่าน

ไม่เปิด Studio ตาม D16 ยังไม่ตรวจ client สำรวจครบตัว/ภาพ/physics/Input/บริการจริง ผล config/service doubles ไม่ใช่การเล่นจริง

ขั้นถัดไปรวม presentation ของอักขระแสงที่ยังซ้ำและทดสอบการสลับบทเรียน↔สำรวจบน client ก่อนขยายจุดใหม่
