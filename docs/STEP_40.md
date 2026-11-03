# Step 40 — ตัวตรวจดัมมี่เทียบทะเบียนสินทรัพย์

เพิ่ม `scripts/check_placeholders.py` ตามขั้นถัดไปของ Step 39 อ่านวัตถุทุกชิ้นใน `src/**/*.model.json` (ยกเว้น ProximityPrompt/Remote) และ literal `PH_` ใน Luau ที่ไม่ใช่การค้นวัตถุฉาก (รวมชื่อ runtime แบบ `PH_Dorm_{id}`, `"PH_Furniture_"..id` เป็น `*`) แล้วเทียบกับตาราง "ทะเบียนชื่อสำหรับตัวตรวจ" ท้าย `docs/ASSET_TRACKER.md`

ล้มเมื่อ: ชื่อใน source ไม่มีในทะเบียน, แถวทะเบียนไม่พบใน source (ย้าย/ลบแล้วไม่แก้), ID ไม่มีคำอธิบายในส่วนอื่นของ tracker, `PlaceholderId` ที่ตั้งในไฟล์ไม่ตรง ID ของแถวไฟล์นั้น, แถวซ้ำหรือไม่มี ID ผลเขียน `build/placeholder-scan.json`

เพิ่มทะเบียน 58 แถว 14 ID จากรายการ Step เดิม เดิมเขียนแบบย่อ (`PH_DungeonFloor/Wall/...`) ซึ่งเครื่องอ่านแน่นอนไม่ได้ ระหว่างทำพบ `PH_ExploreRuneLight` และ `PH_ExploreRuneStatus` (Step 32) ที่ tracker ไม่เคยระบุชื่อ จึงลงทะเบียนใต้ PH-EXP-002

## ผลตรวจ

`python3 scripts/check_placeholders.py` → PASS 36 ฉาก + 22 generator ตรง 58 แถว; `python3 -I tests/placeholder_scan_test.py` 7 tests ผ่าน รวมกรณีที่ต้องล้ม (ของใหม่ไม่ลงทะเบียน, แถวค้าง, ย้ายไฟล์, ID ผิด, ID ใน attribute ของ model, ทะเบียนหาย/ซ้ำ)

ไม่ได้รัน `check_luau.py` รอบนี้: เครื่องนี้ไม่มี luau tools และขั้นนี้ไม่ได้แก้ Luau

## ข้อจำกัด

เป็น source scan เท่านั้น ไม่เปิด Studio ไม่ตรวจภาพ/เสียง และไม่พิสูจน์ว่าแทนของจริงแล้ว ชื่อใน generator ที่ไม่ขึ้น `PH_` (เช่น Body/EyeLeft/EyeRight ของคู่หู, ข้อความ HUD) ยังต้องตรวจด้วยคน ผลผ่านไม่ได้แปลว่าไม่มีดัมมี่ค้างในพื้นที่เปิด

ขั้นถัดไปที่เสนอ: ให้ทะเบียนเก็บสถานะต่อแถวแล้วให้ตัวตรวจเตือนเมื่อ milestone มาถึงแต่ยังเป็นดัมมี่ หรือรวมคำสั่งนี้ในขั้นตรวจหลักเมื่อมี luau tools
