# Step 41 — กำหนดแทนดัมมี่ตามระยะ

ต่อจาก Step 40: ทะเบียนใน `docs/ASSET_TRACKER.md` เพิ่มคอลัมน์ "สถานะ" (ดัมมี่ → พร้อมแทน → เปลี่ยนแล้วรอตรวจ → ผ่าน) และ "ผ่านภายในระยะ" (ชื่อระยะจากตารางใน `docs/ROADMAP.md`) ROADMAP มีบรรทัด "ระยะปัจจุบันสำหรับตัวตรวจดัมมี่: `Prototype`"

`scripts/check_placeholders.py` เพิ่มกฎ:

- ระยะปัจจุบัน = ระยะกำหนดของแถวที่ยังไม่ผ่าน → WARN (ไม่ล้ม) รวมเป็นกลุ่มต่อ ID
- ระยะปัจจุบันเลยระยะกำหนดแล้วยังไม่ผ่าน → FAIL overdue
- แถวสถานะ "ผ่าน" ที่ชื่อยังขึ้น `PH_` ใน source → FAIL (แทนแล้วต้องเปลี่ยนชื่อ แถวเดิมจะกลายเป็นแถวค้างให้แก้ทะเบียน)
- สถานะ/ระยะที่ไม่รู้จัก, คอลัมน์ไม่ครบ, ไม่มีบรรทัดระยะปัจจุบัน → FAIL
- `--stage "<ระยะ>"` จำลองก่อนเลื่อนระยะ รายงาน `build/placeholder-scan.json` มี stage, status_counts, warnings

ค่าตั้งต้น: ทั้ง 58 แถวเป็นดัมมี่ กำหนด Vertical slice ตามข้อความ "ก่อนปิด/จบ vertical slice" ใน Step เดิม ระยะปัจจุบัน Prototype เพราะรายการ Prototype ใน ROADMAP ยังไม่ปิด (D52) ทั้งสองค่าเปลี่ยนได้

## ผลตรวจ

- `python3 scripts/check_placeholders.py` → PASS stage Prototype, ดัมมี่ 58
- `--stage "Vertical slice"` → WARN 14 ID ผ่าน (exit 0); `--stage ระบบหลัก` → FAIL overdue 14 ID ตามคาด
- `python3 -I tests/placeholder_scan_test.py` → 10 tests ผ่าน
- ไม่ได้รัน `check_luau.py` (ไม่มี luau tools ในเครื่องนี้ และไม่ได้แก้ Luau)

## ข้อจำกัด

ต้องรันเอง ยังไม่อยู่ใน CI หรือ hook และไม่แจ้งตามวัน สถานะ "ผ่าน" เป็นสิ่งที่คนบันทึก ตัวตรวจพิสูจน์ได้เพียงว่าชื่อ `PH_` หายจาก source ไม่ได้ตรวจภาพ/เสียงหรือเกณฑ์ตรวจของแต่ละ ID
