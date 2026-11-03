# Step 46 — บันทึกเวทที่เรียนผ่าน

ผู้ใช้เลือกเก็บถาวร "เฉพาะเวทที่เรียนผ่าน" (D54) เดิมผลแสงนำทางและม่านคุ้มกันหายเมื่อออกเกม ทำให้ต้องเรียนซ้ำ และผู้เล่นที่กลับมาใช้ม่านคุ้มกันกับผู้เฝ้าดันเจียนไม่ได้

## ข้อมูล

`src/server/ProgressSchema.luau` v2: `{Version=2, Stage=0..3, Spells={Light, Shield}}`

- merge = Stage สูงสุด และ Spells แบบ OR — writer ที่ล้าสมัยลดขั้นหรือลบเวทไม่ได้
- record v1 อ่านเป็น v2 ที่ยังไม่มีเวท และเขียนกลับเป็น v2 ในการเซฟถัดไป (store/key เดิม)
- ปฏิเสธ (ไม่เขียนทับ): Version อื่น, key เวทที่ไม่รู้จัก, ค่าที่ไม่ใช่ boolean, เวทก่อน Stage 3, โล่โดยไม่มีแสง
- ไม่มีของใช้หมดหรือรางวัลใหม่

## Service

- `ProgressService.Learn(player, "Light"|"Shield")`: ต้องโหลดแล้ว, Stage 3, โล่ต้องมีแสงก่อน
- ProgressService เฝ้า attribute ที่ service เวทตั้งอยู่แล้ว (`LightCompleted`, `ShieldPassed`) เมื่อเป็น true → Learn + Save; ตอนโหลดคืนค่า attribute ทั้งสอง; ตัด connection ตอน Close; สถานะ "รอบันทึก" รวมเวทที่ยังไม่เซฟ
- `LightPuzzleService` / `ShieldLessonService` ตอน PlayerAdded ไม่รีเซ็ตค่าที่เป็น true แล้ว — เดิมถ้าโหลดเสร็จก่อน (Studio อ่าน memory ไม่ yield) ค่าที่โหลดจะถูกล้าง
- ข้อความแสง/โล่ในสมุด, HUD, คำใบ้ เปลี่ยนเป็น "จะบันทึกไว้"; สวน/ดันเจียนคงข้อความ session-only

## ผลตรวจ

- check_luau ผ่าน: compiler 88 ไฟล์ tests 927 assertions (progress 84→117, light journal 10→12, reward flow 15→21)
- reward flow ใหม่: ผ่านบทแสงจริงผ่าน LightPuzzleService → store Spells.Light; ตั้ง ShieldPassed → Spells.Shield; ออก/เข้าใหม่โดย service แสง/โล่ initialize หลังโหลด → ค่ายังอยู่ และ trial ที่ค้างยังรีเซ็ต
- ทดลองทำให้พัง: ลบ guard ใน LightPuzzleService → ล้มที่ `rejoin keeps learned spells after spell services initialize`; ให้ merge ใช้ Light ของ writer ล่าสุด → รอบแรก **ไม่ล้ม** (test ตรวจแค่ Shield) เพิ่ม check ทั้งสองเวทและ decode ผล merge แล้วล้มที่ `stale writer cannot unlearn spells` คืนไฟล์แล้วผลเท่าเดิม
- Rojo build หลัก/experimental และ sourcemap ผ่าน; check_placeholders ผ่าน

## ข้อควรระวัง/ข้อจำกัด

- rollback: server ที่ยังรันโค้ด v1 จะเห็น record v2 เป็น schema ที่ไม่รู้จักและบล็อกโหลด (ไม่เขียนทับ) ต้องไม่ย้อนเวอร์ชันหลังมีผู้เล่นเซฟ v2 แล้ว
- เวทที่ผ่านระหว่างเซฟอื่นกำลังทำงานจะรอ autosave 30 วินาทีหรือตอนออก แบบเดียวกับ Stage เดิม
- ม่านคุ้มกันใน reward flow ตั้ง ShieldPassed ตรง ไม่ได้เล่น trial จริง (trial มี test แยกใน shield_service_flow)
- DataStore เป็น double ไม่เปิด Studio
