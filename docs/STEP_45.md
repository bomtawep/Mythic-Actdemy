# Step 45 — รางวัลกับข้อมูลจริงร่วมกัน

ROADMAP "ทำวงจรข้อมูลและรางวัล พร้อมทดสอบออกเข้าใหม่/รับซ้ำ": เดิม `tests/service_flow.luau` กดรับรางวัลผ่าน LessonService แต่ใช้ ProgressService ปลอม และ `tests/progress_service.luau` ทดสอบ ProgressService จริงแต่ไม่ผ่านปุ่มรับรางวัล ยังไม่มีหลักฐานว่าทั้งสองทำงานร่วมกัน

เพิ่ม `tests/reward_persistence_flow.luau`: LessonService + ProgressService ตัวจริง, DataStore double เก็บ record แยก key ต่อผู้เล่นและรัน transform ของ service, ออก/เข้าใหม่ผ่าน PlayerRemoving/PlayerAdded

ตรวจ 15 ข้อ:

- ผู้เล่นใหม่โหลด Stage 0 จาก store ว่าง; เรียนและกลไกเซฟ Stage 2 ก่อนรับ
- รับบันทึก → store Stage 3 ทันที; กดซ้ำไม่เลื่อนและไม่เขียน พร้อมข้อความ "รับได้ครั้งเดียว"
- ออกโดยไม่มีข้อมูลค้าง ไม่เขียนซ้ำ; เข้าใหม่ได้ Stage 3/LessonRecord/LevitationUnlocked คืน และรับอีกไม่ได้
- store ล่มตอนรับ: session ถือ Stage 3 แต่ store คง Stage 2 และแจ้งผู้เล่นว่าบันทึกไม่สำเร็จ; ออกระหว่างล่ม record เดิมไม่เสียหาย; เข้าใหม่เห็น Stage 2 (ไม่แสดงว่าได้ของที่ยังไม่บันทึก) แล้วรับได้ครั้งเดียว
- record ของผู้เล่นอื่นไม่ถูกแตะ

ไม่ได้แก้โค้ดเกม

## ผลตรวจ

- check_luau ผ่าน: compiler 88 ไฟล์ tests 886 assertions (871 + 15); Rojo build ผ่าน
- ทดลองลบ `task.spawn(Progress.Save, player)` หลังรับรางวัล → ล้มที่ `reward claim is saved immediately` คืนไฟล์แล้วผลเท่าเดิม

## ข้อจำกัด

DataStore เป็น double: ไม่มี latency จริง, throttling, session lock ข้าม server หรือ BindToClose จริง ไม่เปิด Studio ผลเวทแสง/โล่/สวน/ดันเจียนยังเป็น session-only ตาม D41/D44/D47 — การเก็บถาวรต้องตัดสินใจ schema v2 ก่อน
