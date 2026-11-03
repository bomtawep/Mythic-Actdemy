# Step 20 — ทดสอบหอพักกับ persistence ครบชุด

ขยาย DormService flow ให้ใช้ DormPersistence, DormDataManager, DormRepository และ DormSchema ตัวจริงร่วมกัน มีเพียง Roblox/storage services เป็น API doubles ใช้ coroutine จำลองการรอโหลดจริงใน test

## ผลที่รัน

- ทำ flow สิทธิ์/ผู้เล่นสองคนเดิมซ้ำด้วย persistence จริงในโค้ด
- ออกแล้วเซฟและปล่อย lease; เข้าใหม่โหลดตำแหน่งและสถานะวางเดิม
- Heartbeat เรียก save/renew ตาม timer ที่ต่อไว้
- ผู้เล่นออกระหว่าง UpdateAsync ค้าง: Close รอโหลดจบ ไม่สร้างห้องให้ผู้เล่นที่ออกแล้ว และปล่อย lease ที่รับมา
- BindToClose callback ที่ลงทะเบียนจริงเรียกปิด profile เซฟตำแหน่งล่าสุด ปล่อย lease และปฏิเสธแก้ห้องหลังเริ่ม shutdown

compiler 46 ไฟล์ผ่าน; tests เดิม 393 + full persistence flow 32 = 425 assertions ผ่าน Rojo build/sourcemap และ whitespace ผ่าน

ไม่ได้เพิ่ม production feature หรือ asset ในขั้นนี้ และไม่พบ production failure ในกรณีที่ทดสอบ ห้ามตีความว่าครบทุก race: task scheduler/clock/storage เป็น deterministic doubles, CFrame ไม่จำลอง rotation matrix, ยังไม่ตรวจเครือข่ายจริง/throttling ของ Roblox/crash/ภาพ/client UI ไม่เปิด Studio ตาม D16

ขั้นถัดไปทำ preview ก่อนวางเฟอร์นิเจอร์และ feedback ตำแหน่งที่วางไม่ได้ โดยให้ server ตรวจการวางจริงเหมือนเดิมก่อนขยายชนิดเฟอร์นิเจอร์
