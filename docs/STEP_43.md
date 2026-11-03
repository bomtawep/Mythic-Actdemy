# Step 43 — attribute ดัมมี่ที่ generator

แก้ WARN สองรายการจาก Step 42 ให้ทุก generator ที่สร้าง `PH_` ตั้ง `IsPlaceholder` และ `PlaceholderId` ตามแนว metadata ใน ASSET_TRACKER

- `src/client/LightPresentationConfigs.luau`: เพิ่ม `PlaceholderId` ต่อชุด Lesson = PH-ACA-003, Explore = PH-EXP-002
- `src/client/LightPresentation.luau`: ตั้ง attribute ให้ PointLight และ BillboardGui ที่สร้างต่อแท่น
- `src/client/LevitationController.luau`: `PH_LevitationControls` = PH-UI-001; ผลึก/เป้าหมายฝึกใช้ร่วมทุกแท่น จึงเลือก ID ตามแท่น Lesson PH-ACA-002, Puzzle PH-EXP-001, DungeonPuzzle PH-DUN-002, SentinelControl PH-DUN-001 และแถวทะเบียนสองแถวนี้ระบุครบ 4 ID
- `scripts/check_placeholders.py`: ไฟล์ที่ตั้ง IsPlaceholder ต้องเรียก `SetAttribute("PlaceholderId", ...)` ค่าใดก็ได้ (เดิมต้องเป็น literal ซึ่ง LightPresentation ใช้ค่าจาก config)

ไม่เปลี่ยนชื่อ วัตถุ หรือพฤติกรรมเกม

## ผลตรวจ

- ค่าฐานก่อนแก้: check_luau ผ่าน compiler 86 ไฟล์ tests 808 assertions พร้อม WARN 2
- หลังแก้: check_luau ผ่าน ผลต่างจากค่าฐานมีแค่ WARN ที่หายไป fixture tests ของตัวตรวจ 11 ผ่าน
- Luau 0.745: `brew install luau` ล้มเพราะ clang ของ Command Line Tools 26.6 ไม่รับ `-march=westmere` จึง compile จาก source tarball ที่ brew ดาวน์โหลดไว้ (sha256 ตรงสูตร brew) ใน scratchpad ของ session ไม่ได้ติดตั้งลงระบบ

## ต่อ: assertion ค่า attribute

double ใน `tests/light_client_flow.luau` เก็บค่า SetAttribute แล้ว และตรวจว่าวัตถุ `PH_` ทั้ง 16 ชิ้นที่ HUD/แสง/สมุด/โล่สร้างมี IsPlaceholder และ PlaceholderId ตรงทะเบียน (เพิ่ม 33 checks: 33 → 66) พบ `PH_JournalToggle` ไม่มี attribute ทั้งที่ทะเบียนเป็น PH-UI-002 (ตัวตรวจระดับไฟล์ไม่เห็นเพราะสมุดในไฟล์เดียวกันตั้งไว้) จึงเพิ่มใน `src/client/JournalController.luau`

ทดลองเอา PlaceholderId ของปุ่มออกชั่วคราว → test ล้มที่ `placeholder attributes on PH_JournalToggle` ตามคาด แล้วคืนไฟล์ check_luau เต็มชุดผ่าน: compiler 86 ไฟล์ tests 841 assertions

## ข้อจำกัด

LevitationController ไม่มี flow test ตรวจแค่ compile; generator อื่นนอก flow นี้ (Pet/Dorm/Encounter) ยังไม่มี assertion ค่า attribute ไม่เปิด Studio/ไม่ตรวจภาพ
