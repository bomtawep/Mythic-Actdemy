# Step 37 — ม่านคุ้มกันป้องกันผู้เฝ้า

เพิ่ม ShieldGuard ฝั่ง server รับ cast เมื่อผ่านบทโล่ อยู่รัน Puzzle ไม่พัก/ไม่ใช้แรงลอยตัว ผู้เฝ้า Warning ผู้เล่นมีชีวิตและใกล้ผู้เฝ้า ตรวจ cooldown และเวลาโจมตีจาก server

- ShieldAction/Cast เดิมส่งเข้า trial ถ้ากำลังฝึก ไม่เช่นนั้นลอง guard ใน encounter ไม่มี remote หรือตัวเลขเวลาจาก client ใหม่
- EncounterService เปลี่ยน clock เป็น GetServerTimeNow ส่ง EncounterStrikeAt เพื่อแสดง countdown และตรวจ ShieldGuard.Blocked ที่ strike จริง ถ้ากันผ่านไม่หัก HP
- cast ผูกกับ strike นั้นและถูก consume ไม่คุ้มกันการโจมตีรอบถัดไปอัตโนมัติ ไม่ได้หยุดผู้เฝ้าหรือแจกของ
- UI ปุ่ม Q/สัมผัสเดิมแสดงใน Warning สำหรับผู้ผ่านบทโล่ เมื่อ Rest/รันพัก/ใช้เวทอื่นปิดปุ่ม ยังเดินอ้อมหรือใช้แรงลอยตัวหยุดผู้เฝ้าได้

## ผลตรวจ

compiler 84 ไฟล์ผ่าน; tests เดิม 767 + guard encounter 3×2 flows + combat UI 3 = 776 assertions ผ่าน builds หลัก/experimental, sourcemap และ whitespace ผ่าน

ทดสอบ Guard/Encounter จริงร่วม service doubles และ UI กับ Instance/input doubles ไม่ใช่ latency/physics/TakeDamage/Input จริง เส้นทางฝึกโล่ยังผ่านชุดเดิม แต่ยังไม่จำลอง ShieldAction จาก client ผ่าน network จริง ไม่เปิด Studio ตาม D16 ไม่มี asset หรือ schema ใหม่

ขั้นถัดไปทดสอบ lifecycle ของ combat guard ในกรณีตาย/พักรัน/เปลี่ยนรัน/กดเร็วเกิน/ซ้ำ และปรับ feedback ให้สอดคล้องก่อนขยายศัตรู
