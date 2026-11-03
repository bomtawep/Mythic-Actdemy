# Step 48 — คัมภีร์เวทพื้นฐาน

D55 ล็อกระบบสะสม slice เป็นคัมภีร์สายเดียว ผู้ใช้เลือกให้มีหน้าจากการจบดันเจียน (D57) อ้างโครงสร้าง S10: เล่มละ 4–6 หน้า หน้าทักษะหลักได้จากความสำเร็จที่แน่นอน ขั้น ค้นพบ → รวบรวม → เข้าใจ ไม่ให้จำนวนคัมภีร์เพิ่มพลัง

## หน้า (ชื่อทำงาน "คัมภีร์เวทพื้นฐาน")

| หน้า | ได้เมื่อ | ข้อมูลที่ใช้ |
|---|---|---|
| ปกและบทนำ | จบบทฝึกแรก | Stage ≥ 1 |
| แรงลอยตัว | รับบันทึกแรงลอยตัว | Stage 3 |
| แสงนำทาง | ผ่านปริศนาแสง | Spells.Light (D54) |
| ม่านคุ้มกัน | ผ่านการฝึกโล่ | Spells.Shield (D54) |
| บททดสอบภาคสนาม | จบดันเจียน 3 ห้อง | Milestones.Dungeon (ใหม่) |

ขั้น: ค้นพบ = มีหน้าใดหน้าหนึ่ง; รวบรวม = หน้า 1–4 ครบ; เข้าใจ = ครบและผ่านภาคสนาม ทุกหน้าได้แน่นอนจึงไม่มีหน้าซ้ำ/หมึกใน slice

## ข้อมูลและ service

- `ProgressSchema` v3 เพิ่ม `Milestones={Dungeon}` monotonic ต้องหลัง Stage 3; v1/v2 migrate ตอนอ่าน; ปฏิเสธ v4+, key ไม่รู้จัก, ค่าไม่ใช่ boolean ขึ้นเวอร์ชันเพราะ server v2 จะเขียนทับโดยทิ้งฟิลด์ใหม่
- `ProgressService` รวมเวทกับ milestone เป็น flag ชุดเดียว (`Light`/`Shield`/`Dungeon` ↔ `LightCompleted`/`ShieldPassed`/`DungeonCompleted`) `Service.Record` แทน `Learn`
- `DungeonService` ไม่ล้าง `DungeonCompleted` ที่โหลดแล้ว ความหมายเปลี่ยนเป็น "เคยจบ" (ใช้เฉพาะที่นี่และ test)
- client `ScrollModel` คิดหน้าจาก attribute เท่านั้น ใช้ ✓/○ + ข้อความวิธีได้ ไม่พึ่งสี; สมุดเพิ่ม Entry10 เหนือสถานะเซฟ

## ผลตรวจ

- check_luau ผ่าน: compiler 90 ไฟล์ tests 1070 assertions (progress 117→132, scroll ใหม่ 23, light client 66→68, reward flow 21→23)
- reward flow เริ่ม DungeonService หลังโหลดข้อมูล (ลำดับเสี่ยงที่สุด) → การจบดันเจียนยังอยู่หลังเข้าใหม่ และรันใหม่เริ่ม Idle
- ทดลองทำให้พัง: ลบ guard ใน DungeonService → ล้มที่ `rejoin keeps the dungeon milestone…`; merge ใช้ค่าล่าสุด → ล้มที่ `stale writer cannot erase a finished dungeon` คืนไฟล์แล้วผลเท่าเดิม
- Rojo build หลัก/experimental, sourcemap, check_placeholders ผ่าน

## ข้อควรระวัง/ข้อจำกัด

- rollback: server โค้ด v2 จะบล็อกโหลด record v3 (ไม่เขียนทับ) ห้ามย้อนเวอร์ชันหลังมีผู้เล่นเซฟ v3
- ข้อความคัมภีร์ยาว 7 บรรทัดในสมุด ยังไม่ตรวจการตัดคำ/อ่านบนมือถือ ไม่เปิด Studio
- ชื่อคัมภีร์/หน้าเป็นชื่อทำงาน ยังไม่ตรวจชื่อ
