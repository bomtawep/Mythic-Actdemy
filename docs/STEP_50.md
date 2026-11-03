# Step 50 — คู่หูละอองหูใบ

D55 ล็อกสัตว์เลี้ยง slice เป็น 1 ชนิด + ความผูกพันพื้นฐานที่บันทึกได้ ผู้ใช้เลือก (D59): สายพันธุ์ "ละอองหูใบ" จาก S10, ชื่อเลือกจากรายการ, ความผูกพัน 3 ขั้นจากกิจกรรมร่วมครั้งแรก หลัก S10: ไม่อดตาย ไม่หนี ไม่ลดเมื่อออฟไลน์ อาหาร/กิจกรรมไม่ใช่ภาระบังคับ กดซ้ำไม่คุ้ม สีแรร์ไม่เพิ่มพลัง

## ระบบ

| ส่วน | slice |
|---|---|
| สายพันธุ์ | ละอองหูใบ (ชื่อทำงาน) ตัวกลม หูใบไม้ — primitive |
| ชื่อ | เลือกวนจาก 6 ชื่อด้วยปุ่ม "เปลี่ยนชื่อ" (ไม่พิมพ์เอง จึงไม่ต้องกรองข้อความ) |
| ความผูกพัน | รู้จัก (0–1) → คุ้นเคย (2–3) → ไว้ใจ (4) |
| กิจกรรม | เล่นด้วย (ปุ่ม), ค้นพบอักขระสวน, จบดันเจียน, เข้าหอพัก — นับเมื่อพาคู่หูออกมาและครั้งแรกเท่านั้น |
| แสดงผล | ป้ายเหนือคู่หู ชื่อ • สายพันธุ์ • ขั้น (+ข้อความกิจกรรม 3 วิ), สมุด Entry11 พร้อม ✓/○ |

ไม่มีค่าพลัง ไม่มีการลดค่า ไม่มีเวลาบังคับ

## ข้อมูลและโค้ด

- `ProgressSchema` v4: `Pet={Name, Bond}` — Bond monotonic ต้องหลัง Stage 3; Name เป็นของผู้เขียนล่าสุด (ความสวยงาม ยอมให้ server ค้างเขียนชื่อเก่ากลับได้); writer ที่ไม่ส่ง pet คงชื่อเดิม; v1–v3 migrate ตอนอ่าน ปฏิเสธ v5+, ชื่อนอก 1..16, key/ค่าไม่รู้จัก
- `ProgressService`: flag `PetPlay/PetExplore/PetDungeon/PetDorm` ↔ `PetBond*`; `SetPetName` ↔ `PetNameIndex` ค่านอกช่วงถูกคืนค่าเดิม
- `PetService`: remote `"Play"` (ต้องพาออกมา), `"Rename"` (วนชื่อ), boolean = เรียก/เก็บเหมือนเดิม; ฟัง `DungeonState`=Complete, `LightDiscovery`, `InDorm` จาก service ที่มีอยู่
- `PetPolicy` (shared): Names, Activities, bondStage, tagText, journal ใช้ร่วม server/client
- client: `PetController` หูใบไม้, `PH_CompanionName`, `PH_PetPlay`, `PH_PetRename`; `JournalController` Entry11 (สถานะเซฟยังท้ายสุด LayoutOrder 12)
- ทะเบียนดัมมี่ +3 แถว (71)

## ผลตรวจ

- check_luau ผ่าน: compiler 90 ไฟล์ tests 1227 assertions (progress 132→155, pet policy 28→44, metadata 23→30, reward flow 23→32, light client 68→69)
- reward flow ใช้ PetService + Progress ตัวจริง: เล่นโดยไม่พาออกไม่นับ, เล่นครั้งแรกบันทึก, เล่นซ้ำไม่เขียน, เปลี่ยนชื่อบันทึก, เข้าหอพักโดยไม่พาออกไม่นับ/พาออกนับ, จบดันเจียนนับ, เข้าใหม่ได้ชื่อและความผูกพันคืน คู่หูเริ่มแบบเก็บไว้
- ทดลองทำให้พัง 3 แบบ: นับกิจกรรมโดยไม่พาออก → ล้มที่ `activities without the companion do not count`; merge ใช้ชื่อเก่า / merge ลบความผูกพัน → ล้มที่ `rename keeps bond; stale writer cannot erase bond` คืนไฟล์แล้วผลเท่าเดิม
- Rojo build หลัก/experimental, sourcemap, check_placeholders ผ่าน

## ข้อควรระวัง/ข้อจำกัด

- rollback: server โค้ด v3 บล็อกโหลด record v4 (ไม่เขียนทับ)
- ภาพคู่หูเป็น primitive ดัมมี่ (PH-PET-001) ยังไม่ตรวจภาพ ท่าทาง ป้ายชื่อบังจอ หรือปุ่ม 3 ปุ่มซ้อนบนมือถือ
- ชื่อสายพันธุ์และ 6 ชื่อเป็นชื่อทำงาน ยังไม่ตรวจชื่อ
- ไม่เปิด Studio
