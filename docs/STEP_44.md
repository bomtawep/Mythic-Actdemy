# Step 44 — test attribute ดัมมี่ทุก generator

ต่อจาก Step 43 ให้ทุก generator ที่สร้างชื่อ `PH_` มี test ตรวจค่า IsPlaceholder/PlaceholderId ตรงทะเบียน ASSET_TRACKER

## Luau tests

- `tests/dorm_service_flow.luau`, `tests/dorm_v2_service_flow.luau`: ห้อง `PH_Dorm_<UserId>` ต้องเป็น PH-DOR-001 และ (v2) เฟอร์นิเจอร์ `PH_Furniture_*` ทุกชิ้นด้วย
- `tests/dorm_controller_flow.luau` (รันทั้ง v1/v2): double เก็บ attribute ตรวจ PH_DormControls และ preview ทั้งชิ้นแรกและชิ้นที่สร้างใหม่
- ใหม่ `tests/placeholder_metadata_flow.luau`: โหลด PetController, EncounterController, LevitationController ตัวจริงบน Instance doubles ตรวจผลึก/เป้าหมายฝึกได้ ID ตามแท่นครบ 4 แท่น, คู่หู `PH_Companion_7` มี ID และ OwnerUserId, PH_ ทุกชิ้นมี attribute, และ cleanup เมื่อ HUD ถูกทำลาย (17 checks)

## สิ่งที่พบและแก้

- `PH_SentinelWarning` (EncounterController) ไม่มี attribute → PH-DUN-001
- `PH_Furniture_*` (DormServiceV2) ไม่มี attribute → PH-DOR-001
- ตัวตรวจ Python เดิมดูระดับไฟล์ จึงไม่เห็นทั้งสองจุด (และ PH_JournalToggle ใน Step 43) เพิ่มกฎ: `x.Name = "PH_…"` แบบ literal ต้องมี `x:SetAttribute("IsPlaceholder", …)` ในไฟล์เดียวกัน (FAIL) พร้อม fixture test

## ผลตรวจ

- check_luau เต็มชุดผ่าน: compiler 87 ไฟล์, tests 871 assertions (808 + 33 Step 43 + 13 หอพัก + 17 ใหม่)
- check_placeholders ผ่าน ไม่มี WARN; fixture tests 12 ผ่าน
- ทดลองทำให้พัง: ลบ PlaceholderId ของป้ายผู้เฝ้า → ล้มที่ `placeholder attributes on PH_SentinelWarning`; สลับ ID แท่น Puzzle → ล้มที่ `PH_PersonalPracticeCrystal tagged for Puzzle` คืนไฟล์แล้วผลเท่าเดิมทุกบรรทัด
- Luau 0.745 จาก scratchpad ของ session (ดู STEP_43)

## ข้อจำกัด

ทั้งหมดเป็น doubles ไม่เปิด Studio ไม่ตรวจภาพ/เครือข่าย ชิ้นส่วนลูกที่ไม่ขึ้น `PH_` (เช่น Body/EyeLeft ของคู่หู, ข้อความใน HUD) ไม่ได้ตั้ง attribute แยก ถือว่าอยู่ใต้ parent ที่ตั้งไว้ กฎระดับวัตถุตรวจเฉพาะชื่อ literal ชื่อจาก config (LightPresentation) ตรวจด้วย Luau test แทน
