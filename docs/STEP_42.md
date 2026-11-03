# Step 42 — ตัวตรวจดัมมี่ในขั้นตรวจหลักและ CI

- `scripts/check_luau.py` เรียก `scripts/check_placeholders.py` ก่อน compile ทะเบียนไม่ตรงจะหยุดก่อนรัน Luau
- เพิ่ม `.github/workflows/placeholder-check.yml` รัน fixture tests และตัวตรวจบน push/PR ใช้ Python เท่านั้น ไม่ต้องมี luau tools
- กฎใหม่: ไฟล์ Luau ที่ `SetAttribute("IsPlaceholder", true)` ต้องตั้ง `PlaceholderId` ด้วย (FAIL); ไฟล์ที่สร้างชื่อ `PH_` แต่ไม่ตั้งทั้งสองได้ WARN

พบ WARN จริง 2 ไฟล์: `src/client/LevitationController.luau` (PH_PersonalPracticeCrystal/PH_PracticeTarget/PH_LevitationControls) และ `src/client/LightPresentationConfigs.luau` (แสง/ป้ายที่ LightPresentation สร้าง) ยังไม่แก้ Luau เพราะเครื่องนี้ไม่มี luau tools ให้รัน client flow tests หลังแก้ — ใส่เป็นงานใน ROADMAP

## ผลตรวจ

- `python3 scripts/check_placeholders.py` → PASS พร้อม WARN 2 รายการข้างต้น
- `python3 -I tests/placeholder_scan_test.py` → 11 tests ผ่าน
- `check_luau.py --bin-dir <ไม่มี>` → ส่วนดัมมี่รันและผ่านก่อน แล้วหยุดที่ luau-compile ตามคาด; ยังไม่ได้รัน Luau tests เต็ม
- workflow ตรวจไวยากรณ์ YAML ในเครื่องแล้ว ยังไม่เคยรันบน GitHub (ยังไม่ commit/push)
