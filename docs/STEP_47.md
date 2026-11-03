# Step 47 — ดันเจียน 3 ห้อง

ตาม D55 (3 ห้องตายตัว: ปริศนา → ศัตรู → ห้องจบ) และ D56 (ห้อง 2 ผ่านได้สองทาง, ห้อง 3 แท่นจบ + สรุปผล) อ้างหลัก S05: สอนกลไกก่อนอันตราย ไม่วางปริศนาแบบเดิมซ้ำติดกัน มีทางกลับ ไม่ติดถาวร ผู้เล่นไม่ติดเพราะขาดเวทใดเวทหนึ่ง

## เส้นทาง

| ห้อง | สถานะ | สิ่งที่ต้องทำ | ทางต่อ |
|---|---|---|---|
| 1 (x=200) | Puzzle | ยกผลึกถึงระดับ 11 | `DungeonDoor1` เปิดหลังแก้ |
| 2 (x=300) | Encounter | ผ่านผู้เฝ้า: แท่นควบคุมระดับ 10 ช่วงพัก หรือกันด้วยม่านคุ้มกัน 2 ครั้ง | `DungeonDoor2` เปิดหลังผ่าน |
| 3 (x=400) | Reward → Complete | รับผลที่ `DungeonFinish` (ครั้งเดียวต่อรัน) | `DungeonExit3` |

- ห้องเป็นพื้นที่ร่วม สถานะแยกรายคน จึงใช้ประตู prompt วาร์ป (`DungeonRules.doorTarget`) ไม่ใช้ประตูกายภาพ
- ทุกห้องมีทางกลับ (`DungeonExit`, `DungeonExit2`, `DungeonExit3`)
- ตาย → รันพัก กลับเข้าประตูโรงเรียนแล้วไปจุดเริ่มของห้องที่ค้าง (`recoveryMarker`) ประตูไม่ทำงานขณะพัก
- ผู้เฝ้าทำงานเฉพาะสถานะ Encounter; แท่นควบคุมใช้ได้เฉพาะห้อง 2 และปริศนาผลึกเฉพาะห้อง 1 (LevitationRules)
- การนับกันด้วยโล่ (`EncounterBlocks`) รีเซ็ตทุกรันใหม่; ทั้งสองทางเรียก `clear` เดียวกันใน EncounterService → `DungeonService.Clear`
- ผลจบรันยัง session-only

## ไฟล์

- shared: `DungeonRules` (สถานะ/recovery/doorTarget), `EncounterRules` (Encounter, `BlocksToClear`)
- server: `DungeonService` (Clear, ประตู, ทางออกต่อห้อง), `EncounterService` (clear ร่วม, นับโล่), `ShieldGuard`, `LevitationRules`, `LessonService` (ข้อความ)
- client: `DungeonViewModel` (ห้อง x/3, checkpoint ต่อห้อง, สองทางผ่านผู้เฝ้า), `ShieldLessonController` (บริบทสู้ = Encounter)
- ฉาก: `src/world/Academy.model.json` เพิ่มห้อง 2/3 ย้ายผู้เฝ้า/แท่นควบคุม/checkpoint/แท่นจบ; ทะเบียนดัมมี่ +5 แถว

## ผลตรวจ

- check_luau ผ่าน: compiler 88 ไฟล์ tests 1028 assertions (dungeon rules 35→84, levitation 17→22, encounter 30→32, dungeon view 49→68, service flow +13 ต่อรอบ×2)
- service flow เดินจริง: ประตูปิดก่อนผ่าน, ผู้เฝ้า/แท่นควบคุมไม่ทำงานในห้อง 1, ห้อง 2 ผ่านด้วยแท่นควบคุม (รันแรก) และกันด้วยโล่ 2 ครั้ง (รันสอง ไม่เสีย HP), ตายแล้วกลับห้อง 2/ห้อง 3 พร้อมความคืบหน้า, จบครั้งเดียว, ออกจากห้อง 2/3
- ทดลองทำให้พัง: ประตู 1 เปิดในห้อง 1 → ล้มที่ `DungeonDoor1 in Puzzle`; ตัดการผ่านด้วยโล่ → ล้มที่ `two blocks clear room 2` (การเปลี่ยนค่าคงที่ `BlocksToClear` ถูกจับก่อนโดย check ค่าคงที่ จึงทดลองแบบที่สามเพื่อยืนยัน flow) คืนไฟล์แล้วผลเท่าเดิม
- Rojo build หลัก/experimental, sourcemap, check_placeholders (41 ฉาก + 22 generator = 63 แถว) ผ่าน

## ข้อจำกัด

ตรวจบน doubles ทั้งหมด ไม่เปิด Studio (D16) ยังไม่ตรวจภาพ ระยะเดินจริง ความยาก/เวลาต่อห้อง หรือหลายคนพร้อมกันในห้องร่วม ศัตรูบทบาทที่ 2–3 และบอสยังไม่ทำ
