# ติดตามดัมมี่และสินทรัพย์

รายการต่อไปนี้เป็นรายการงานตั้งต้นจากแผน S02 ยังไม่ใช่ผลสแกน Roblox Studio และยังไม่ได้ระบุตัววัตถุจริง

| ID | โซน/ชิ้นงาน | เปลี่ยนเมื่อ | ตรวจหลังเปลี่ยน | ผู้รับผิดชอบ | สถานะ |
|---|---|---|---|---|---|
| PH-ACA-001 | จุดเกิด/ลาน/ทางเข้า | ระยะเดินและกล้องผ่าน | ทางหลัก ขอบตก ฉากหลัง | ยังไม่ระบุ | ต้องสำรวจ |
| PH-ACA-002 | อาจารย์/บทเรียนแรก | เรียนและรับรางวัลครบ | ระยะคุย มือ ท่าสอน เสียง ข้อความ | ยังไม่ระบุ | ต้องสำรวจ |
| PH-DOR-001 | ห้อง/เฟอร์นิเจอร์ | วาง บันทึก โหลดผ่าน | ภาพสินค้า จุดนั่ง จุดเกิด สิทธิ์ | ยังไม่ระบุ | ต้องสำรวจ |
| PH-DUN-001 | ศัตรู/บอส | จบรันและท่าหลักผ่าน | hitbox เตือนโจมตี ตาย รางวัล | ยังไม่ระบุ | ต้องสำรวจ |
| PH-EXP-001 | ปริศนา/ห้องลับ | แก้ได้และออกได้ | ใบ้ เสียง สถานะหลังผ่าน | ยังไม่ระบุ | ต้องสำรวจ |
| PH-PET-001 | สัตว์เลี้ยง | ตาม/เรียกกลับ/ผ่านประตู | ไอคอน idle ระยะตาม | ยังไม่ระบุ | ต้องสำรวจ |
| PH-COS-001 | ชุด/เครื่องประดับ | ใส่ถอดบันทึกได้ | preview การทะลุ อุปกรณ์ถือ | ยังไม่ระบุ | ต้องสำรวจ |
| PH-VFX-001 | Aura | สรุป rarity แล้ว | วิ่ง หลายคน preview | ยังไม่ระบุ | ต้องสำรวจ |
| PH-COL-001 | คัมภีร์/การ์ด/บันทึก | รับ เปิดดู บันทึกผ่าน | ภาพย่อ คำบรรยาย รายการล็อก | ยังไม่ระบุ | ต้องสำรวจ |
| PH-TRV-001 | วาร์ป/หน้าจอโหลด | ไปกลับผ่าน | ปลายทาง เกิดใหม่ ล้มเหลว | ยังไม่ระบุ | ต้องสำรวจ |
| PH-SHP-001 | ร้าน/รางวัล | ก่อนเปิดใช้งาน | ราคา รูป ข้อความ ของที่ได้จริง | ยังไม่ระบุ | ต้องสำรวจ |

เมื่อสำรวจแล้วเพิ่มตำแหน่งจริง Place/path, ของชั่วคราว, asset ทดแทน, deadline ตาม milestone และหลักฐานตรวจ สถานะงานใช้ ดัมมี่ → พร้อมแทน → เปลี่ยนแล้วรอตรวจ → ผ่าน

ข้อเสนอ metadata: IsPlaceholder=true, PlaceholderId="PH-ACA-001" และชื่อขึ้น PH_ ตั้งแต่ Step 40 มีตัวตรวจ source `scripts/check_placeholders.py` เทียบกับ "ทะเบียนชื่อสำหรับตัวตรวจ" ท้ายไฟล์ แต่ยังไม่ใช่ scanner ใน Studio ต้องตรวจ UI/เสียง/ข้อความ/ข้อมูลในโค้ดด้วย ไม่ใช่ค้นหาโมเดลอย่างเดียว

จุดเสี่ยงลืม: หลังคา ใต้บันได ฉากสำเนา template ที่สุ่มได้ ไอคอนเก่า hitbox เดิม รางวัลทดสอบ และ script ที่สร้างดัมมี่คืนตอนเริ่มเกม

## Asset ที่พบในเครื่อง

## ดัมมี่ที่เพิ่มใน Step 01 (2026-11-02)

Step 55 — blockout รอบ 2 ใน `src/world/Academy.model.json`: วัสดุ/สีตามโทนภาพ SCENE_DESIGN_SLICE §5 บนชิ้นเดิม (หญ้า, ลานหิน Slate, ทาง Cobblestone, ขอบเขตแนวพุ่ม LeafyGrass, ทะเลสาบกระจก, พื้นไม้ห้องเรียน, ทรายสนามฝึก, ดันเจียนพื้นดิน/ผนังโลหะ) และโฟลเดอร์ `Academy.PH_Decor`: ผนัง `PH_ClassWall` + หลังคา `PH_ClassRoof` ของห้องเรียนสองห้อง (ประตูหันเข้าลาน), ยอดผลึก `PH_LightCoreCrystal`, `PH_RuinPillar`/`PH_RuinArch` ที่ซากวิหาร, `PH_Hedge` รอบสวน, ป้ายบอกทาง `PH_Signpost` (BillboardGui `Sign`/TextLabel `Label`) 5 จุด และ `PH_DungeonCeiling` เพดานกระจกเรือนกระจก 3 ห้อง ทั้งหมด primitive/วัสดุ Roblox ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยงานภาพต้นฉบับก่อนปิด vertical slice ตรวจทางเข้าออกห้องเรียน กล้องใต้หลังคา ป้ายอ่านบนมือถือ ไม่บังกัน สถานะดัมมี่

Step 51 — PH-ACA-001 และกลุ่มโซน: blockout ตาม SCENE_DESIGN_SLICE.md ใน `src/world/Academy.model.json` พื้น 800×680 + `PH_LakeBackdrop` (ฉากหลังหลังกำแพง z=280), `PH_Plaza` 220×220, `PH_LightCore` (เสา 10×120 แทนหอแกนแสง), `PH_ZonePad` 6 แผ่น (ห้องเรียน L1/L2, โถงแท่นบันทึก, สวนอักขระ, ซากวิหาร, สนามฝึก), `PH_Path` 6 เส้น และย้ายแท่นทั้งหมดตามผัง ดันเจียน 3 ห้องย้ายไป x=1200–1460 ขยายเป็น 70×90/90×120/60×70 ทุกชิ้นยังเป็นกล่องสี ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนตามตารางข้อ 6 ของเอกสารผัง ก่อนปิด vertical slice ตรวจเวลาเดินจริง กล้อง ชนเสาแกนแสงบนทางหลัก ขอบตก มือถือ สถานะดัมมี่ ยังไม่ตรวจภาพ

Step 50 ต่อ PH-PET-001: คู่หู "ละอองหูใบ" (ชื่อทำงาน) ใน `src/client/PetController.luau` — ตัวกลม + หูใบไม้ (EarLeft/EarRight) + ตา เป็น primitive, ป้ายชื่อ `PH_CompanionName`, ปุ่ม `PlayerGui.PH_LessonHUD.PH_PetPlay`/`PH_PetRename` และข้อความสมุด Entry11 จาก PetPolicy.journal ชื่อให้เลือก 6 ชื่อเป็นชื่อทำงาน ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยโมเดล/ท่าทาง/ไอคอนคู่หูต้นฉบับ (mesh ได้ตาม D06) ก่อนปิด vertical slice ตรวจหลายมุม ป้ายชื่อไม่บังจอ มือถือ ปุ่มไม่ทับกัน หลายคน สถานะดัมมี่ ตรวจบน doubles ยังไม่ตรวจภาพ

Step 49 — PH-DUN-001 / PH-DUN-002: ศัตรูบทบาท 2–3 ในห้อง 2 `src/world/Academy.model.json`: `PH_DungeonCaster` (ผู้ยิงระยะไกลที่ผนังท้าย), `PH_DungeonShade` (เงาหน้าประตูหลัก ทะลุได้ โปร่ง 0.6), prompt `DungeonShadeRune` และ `DungeonDoor2Side`; client `Workspace.PH_CasterLaneWarning` จาก `src/client/EncounterController.luau` เป็น primitive/แถบสีชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยศัตรู/ท่าเตือน/เอฟเฟกต์ต้นฉบับก่อนปิด vertical slice ตรวจอ่านแนวยิงบนมือถือ ความต่างสีกับโซนผู้เฝ้า (ไม่พึ่งสีอย่างเดียว ต้องมีข้อความ) เงาเห็นพอให้หลบ ระยะทางอ้อม หลายคน สถานะดัมมี่ ตรวจบน doubles ยังไม่ตรวจภาพ

Step 48 ต่อ PH-COL-001 / PH-UI-002: ข้อความคัมภีร์ `PlayerGui.PH_LessonHUD.PH_StudentJournal.Entries.Entry10` จาก `src/client/ScrollModel.luau` + JournalController (สถานะเซฟยังเป็น Entry9 แต่อยู่ท้ายด้วย LayoutOrder 11) เป็นข้อความ/สัญลักษณ์ ✓/○ ชั่วคราว ชื่อ "คัมภีร์เวทพื้นฐาน" เป็นชื่อทำงาน ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยหน้าคัมภีร์ภาพ/สารบัญตาม S10 ก่อนปิด vertical slice ตรวจภาษาไทยไม่ตัด อ่านบนมือถือ ปุ่มอ่านต่อ ไม่มี object `PH_` ใหม่ ยังไม่ตรวจภาพ

Step 47 — PH-DUN-002 / PH-TRV-001 / PH-DUN-001: ดันเจียน 3 ห้องตายตัวใน `src/world/Academy.model.json` ห้อง 1 (x=200) เดิม แท่นจบเดิมเปลี่ยนเป็น `DungeonDoor1`; ห้อง 2 (x=300) พื้น/กำแพงใหม่, `PH_DungeonRoom2Arrival`, `DungeonExit2`, `DungeonDoor2` และย้าย `PH_TrainingSentinel`/`SentinelControl`/`PH_SentinelControlCrystal` มาไว้; ห้อง 3 (x=400, 64×60) พื้น/กำแพงใหม่, ย้าย `PH_DungeonCheckpoint`/`DungeonFinish` และ `DungeonExit3` ทั้งหมดเป็น primitive/prompt วาร์ปชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยห้อง/ประตู/ผู้เฝ้าต้นฉบับก่อนปิด vertical slice ตรวจทางเดิน ระยะ prompt การวาร์ประหว่างห้อง ตาย/กลับ checkpoint หลายคน มือถือ สถานะดัมมี่ ตรวจ flow บน doubles ยังไม่ตรวจภาพ ไม่มี asset ภายนอก

Step 36 ต่อ PH-UI-002: ShieldJournalModel แสดงผลม่านคุ้มกันที่ Entry8 สถานะเซฟเป็น Entry9 ผู้รับผิดชอบและ milestone ตรวจข้อความ/มือถือก่อน vertical slice ตามเดิม ไม่มี asset ใหม่ ยังไม่ตรวจภาพ

Step 35 — PH-ACA-004: `Academy.ShieldLesson` ใน `src/world/Academy.model.json`, `PlayerGui.PH_LessonHUD.PH_ShieldControls` และข้อความ HUD จาก ShieldLessonController/HudController เป็นแท่น/UI ชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยอุปกรณ์/ท่า/เอฟเฟกต์คุ้มกันต้นฉบับหลัง timing/flow ผ่าน ก่อนปิด vertical slice ตรวจอ่านจังหวะ/latency/โดน hit/ตาย/ออกพื้นที่/มือถือ/cleanup สถานะดัมมี่ rules/export ผ่าน ยังไม่ตรวจภาพ ไม่มี asset ภายนอก

Step 34 เปลี่ยน generator แสง/ป้าย PH-ACA-003 และ PH-EXP-002 ไป `src/client/LightPresentation.luau` + LightPresentationConfigs ผ่าน wrappers เดิม ชื่อวัตถุ ผู้รับผิดชอบ และ milestone แทนของจริงเดิมยังใช้ ไม่มี asset ใหม่ ยังไม่ตรวจภาพ

Step 32 — PH-EXP-002: `Academy.LightExploreStart/ExploreRune1/2/3` ใน `src/world/Academy.model.json`, PointLight/ป้ายจาก LightExploreController และสมุด Entry7 (สถานะเซฟย้าย Entry8) เป็น primitive/แสง/ข้อความชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยลานสวน/อักขระต้นฉบับหลังวงจรเรียน→สำรวจผ่าน ก่อนปิด vertical slice ตรวจระยะ/ข้อความ/แสง/ผู้เล่นหลายคน/มือถือ/เริ่มใหม่/ตาย/cleanup สถานะดัมมี่ service/export ผ่าน ยังไม่ตรวจภาพ ไม่มี asset ภายนอก

Step 30 ต่อ PH-UI-002: `PH_StudentJournal.Entries.Entry6` เป็นสถานะเวทแสงจาก LightJournalModel; สถานะเซฟเดิมย้ายไป Entry7 ผู้รับผิดชอบ/จุดแทนก่อน vertical slice ตามเดิม ตรวจ model/service แล้ว ยังไม่ตรวจภาพภาษาไทยหรือมือถือ ไม่มี asset ใหม่

Step 29 — PH-ACA-003: `Workspace.AcademyPrototype.Academy.LightLesson/LightRune1/2/3` ใน `src/world/Academy.model.json`, PointLight `PH_PersonalRuneLight` และ BillboardGui `PH_LightRuneStatus` จาก `LightLessonController.luau` เป็นแท่น primitive/ข้อความ/แสงชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยอุปกรณ์วิชาแสงต้นฉบับหลัง flow แก้โจทย์ผ่าน ก่อนปิด vertical slice ตรวจอ่านสว่าง/ดับ ภาษาไทย แสงไม่บังฉาก สองคน มือถือเริ่มใหม่/ตาย/ออกพื้นที่/cleanup สถานะดัมมี่ กฎ/export ผ่าน ยังไม่ตรวจภาพ ไม่มี asset ภายนอกเพิ่ม

Step 26 ต่อ PH-DOR-001: `DormServiceV2.luau` สร้าง `PH_Dorm_<UserId>.PH_Furniture_<Id>` เป็น primitive ตาม FurnitureCatalog (Bench/Stool), `DormControllerV2.luau` สร้าง preview/ปุ่มเลือกชิ้น ไม่มี mesh/asset ภายนอก ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยภาพแต่ละชนิด/preview ตรงชิ้นจริงหลัง v2 selection/collision/เซฟโหลดผ่าน ก่อนปิด vertical slice ตรวจขนาด หมุน หลายชิ้น ทับกัน มือถือ cleanup สถานะดัมมี่ ยังไม่ตรวจภาพหรือ v2 flow ครบตัว

Step 21 ต่อ PH-DOR-001: `Workspace.PH_FurniturePreview` และข้อความ/ปุ่มใน PH_DormControls จาก `src/client/DormController.luau`, draft ใน DormPreviewModel เป็นม้านั่งกล่องโปร่งแสงชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วย preview ใช้ mesh/ขนาดชิ้นจริงหลัง UX วางผ่าน ก่อนปิด vertical slice ตรวจย้าย/หมุน/ยืนยัน/ยกเลิก สี+ข้อความ invalid มือถือ การทับภาพเดิมและ cleanup สถานะดัมมี่ ตรวจ model/Commit flow แล้ว ยังไม่ตรวจภาพ ไม่มี asset ภายนอก

Step 19 อัปเดต PH-DOR-001: UI แสดงสถานะเซฟจาก DormSaveStatus เพิ่ม และโค้ดห้องเชื่อม persistence แล้ว เกณฑ์เซฟ/โหลดจริงยังไม่ผ่าน จึงยังไม่เลื่อนสถานะพร้อมแทน/ผ่าน ไม่มี asset ใหม่ ผู้รับผิดชอบและ milestone เดิม

Step 16 — PH-DOR-001: template `ServerStorage.MythicAcademy.Room` จาก `src/dorm/Room.model.json`, runtime `Workspace.PH_Dorm_<UserId>` (พื้น/กำแพง/Exit/PH_Bench), `Academy.DormEntry` และ `PlayerGui.PH_LessonHUD.PH_DormControls` จาก DormService/DormController เป็น primitive/ข้อความดัมมี่ ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยห้อง/ม้านั่ง/UI ต้นฉบับหลังสิทธิ์/วาง/เซฟโหลดผ่าน ก่อนปิด vertical slice ตรวจกล้อง avatar หลายขนาด ย้าย/หมุน/เก็บ ประตู/ตาย/สองคน มือถือและข้อมูลหลังออกเข้าใหม่ สถานะดัมมี่ ตรวจ export/กฎแล้ว ยังไม่ตรวจภาพ ไม่มี asset ภายนอกเพิ่ม

Step 14 เปลี่ยนตำแหน่ง generator เดิม PH-UI-001 และภาพผลึก/เป้าหมายใน PH-ACA-002/PH-EXP-001/PH-DUN-001: จาก Main.client ไป `src/client/HudController.luau` และ `LevitationController.luau` ชื่อวัตถุและผู้รับผิดชอบ/milestone แทนเดิมไม่เปลี่ยน ไม่มี asset ใหม่ ยังไม่ตรวจภาพจริง

Step 13 — ต่อ PH-UI-001/002: ข้อความ `PlayerGui.PH_LessonHUD.Objective` และ `PH_StudentJournal.Entries.Entry5` จาก `src/client/DungeonViewModel.luau`, Main.client และ JournalController เป็น objective/checkpoint/summary ต้นแบบ ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) เก็บงานข้อความและ layout หลัง state/flow ผ่าน ก่อนปิด vertical slice ตรวจภาษาไทย HUD ไม่ตัด/ไม่บังเกม/ปุ่ม มือถือ การพัก/กู้คืน/จบและการเลื่อนสมุด สถานะดัมมี่ model tests ผ่าน ยังไม่ตรวจภาพ ไม่มี asset ภายนอกเพิ่ม

Step 11 — ต่อ PH-DUN-001: `Workspace.AcademyPrototype.Academy.SentinelControl` และ `PH_SentinelControlCrystal` ใน `src/world/Academy.model.json`; ภาพผลึกส่วนตัวใช้ generator เดิม ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยอุปกรณ์ควบคุมผู้เฝ้าต้นฉบับหลังวงจรหลบ/เริ่มช่วงพัก/วางหยุดผ่าน ก่อนจบ vertical slice ตรวจระยะ prompt การอ่านเป้า ท่าหยุด/ข้อความ รายคน ตาย/กู้คืน/เข้ารันใหม่ สถานะดัมมี่ ตรวจ export/กฎแล้ว ยังไม่ตรวจภาพหรือ runtime ไม่มี asset ภายนอก

Step 10 — PH-DUN-001: `Workspace.AcademyPrototype.Academy.PH_TrainingSentinel` ใน `src/world/Academy.model.json`, `Workspace.PH_PersonalAttackWarning` และ BillboardGui `PH_SentinelWarning` จาก `src/client/EncounterController.luau` เป็น primitive/ข้อความชั่วคราว ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยศัตรูต้นฉบับ/ท่าเตือน/ท่าโจมตีเมื่อ encounter ผ่าน ก่อนปิด vertical slice ตรวจ silhouette ระยะ/พื้นที่โจมตี จังหวะเตือน เครือข่าย มือถือ หลายคน ตาย/กลับ/ใช้เวท สถานะดัมมี่ ตรวจ export/กฎแล้ว ยังไม่ตรวจภาพหรือ runtime ไม่มี asset ภายนอกเพิ่ม

Step 08 เพิ่มใน PH-DUN-002: `Workspace.AcademyPrototype.Academy.PH_DungeonCheckpoint` เป็นแผ่น primitive ใน `src/world/Academy.model.json` ผู้รับผิดชอบผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยจุดพักต้นฉบับเมื่อ recovery ผ่าน ก่อนปิด vertical slice ตรวจจุดยืน character หลายขนาด ระยะ prompt กล้อง ตาย/กู้คืนทั้งก่อนและหลังรับผล สถานะดัมมี่ ตรวจ export แล้ว ยังไม่ตรวจภาพ/เกมจริง

Step 07 — PH-DUN-002 / PH-TRV-001: `Workspace.AcademyPrototype.Academy` มี DungeonEntry/Exit/Puzzle/Finish, PH_DungeonFloor/Wall/Arrival/Return และ PH_DungeonPuzzleCrystal ใน `src/world/Academy.model.json` เป็น primitive/ข้อความต้นแบบ ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยฉาก/แท่น/ประตูต้นฉบับหลังวงจรปริศนาและกลับผ่าน ก่อนจบ vertical slice ตรวจกล้อง ชน ขอบตก วาร์ป ตาย/กลับระหว่างฝึก หลายคน/มือถือ และภาพผลึกส่วนตัว สถานะดัมมี่ ตรวจ export แล้ว ยังไม่ตรวจภาพ/runtime ไม่มี asset ภายนอกเพิ่ม

Step 06 — PH-PET-001: โมเดล runtime `Workspace.PH_Companion_<UserId>` (Body/EyeLeft/EyeRight) และ `PlayerGui.PH_LessonHUD.PH_PetToggle` จาก `src/client/PetController.luau` เป็น primitive/ข้อความที่เขียนในโครงการ ไม่มี asset ภายนอก ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยคู่หูต้นฉบับรูปทรงธรรมชาติพร้อม motion/ไอคอนหลังระบบเรียกและตามผ่าน ก่อนจบ vertical slice ตรวจหลายมุม การตาม/วาร์ปกลับ ตาย/เกิดใหม่ ประตู ผนัง หลายคนและมือถือ สถานะดัมมี่ ทดสอบสิทธิ์ผ่าน ยังไม่ตรวจภาพ/เกมจริง

Step 05 — PH-UI-002: `PlayerGui.PH_LessonHUD.PH_StudentJournal` และ `PH_JournalToggle` จาก `src/client/JournalController.luau`; ข้อความจาก `JournalModel.luau` เป็นสมุดบทเรียนต้นแบบ ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยงานภาพ/ข้อความสมุดต้นฉบับหลังขอบเขตข้อมูลผ่าน ก่อนปิด vertical slice ต้องตรวจข้อความไทย การเลื่อน จอแนวตั้ง/แนวนอน เปิดปิดขณะฝึกและเกิดใหม่ สถานะดัมมี่; model tests ผ่าน ยังไม่ตรวจภาพ ไม่มี asset ภายนอกเพิ่ม

อัปเดต Step 03: PH-COL-001 ใช้ Stage ใน ProgressService เป็นแหล่งข้อมูลแทน attribute session-only เดิม รางวัลยังเป็นบันทึกต้นแบบ ไม่มีภาพ/สมุดจริง ต้องผ่านเซฟ/โหลดใน experience ทดสอบก่อนสถานะพร้อมแทน ผู้รับผิดชอบและ milestone ก่อน vertical slice ตามเดิม; HUD PH-UI-001 เพิ่มข้อความสถานะข้อมูล ยังต้องตรวจภาษาไทย/มือถือจริง

ทุกชิ้นด้านล่างเป็น primitive/ข้อความที่เขียนในโครงการ ไม่มี asset ภายนอกเพิ่ม ผู้รับผิดชอบงานแทน: ผู้พัฒนาโครงการ; ยังไม่กำหนดบุคคล ต้องแทนและตรวจจริงก่อนเปิดให้ผู้เล่นทั่วไป

| ID | ตำแหน่งจริง/ของชั่วคราว | เงื่อนไขและของแทน | เกณฑ์ตรวจ | สถานะ |
|---|---|---|---|---|
| PH-ACA-001 | `Workspace.AcademyPrototype.Academy`: PH_Floor/Path/Spawn/Boundary ใน `src/world/Academy.model.json` | ระยะเดิน/กล้องผ่าน → ฉากโรงเรียนต้นฉบับ | ชน ขอบตก กล้อง เวลาเดิน ภาพหลายมุม | ดัมมี่ |
| PH-ACA-002 | `Academy.Lesson`, PH_LessonCrystal | บทฝึกผ่าน → แท่น/อุปกรณ์สอนต้นฉบับ; ไม่ใช้โมเดลพ่อมดอัตโนมัติ | prompt ท่า/ผลึก การอ่านโจทย์ | ดัมมี่ |
| PH-EXP-001 | `Academy.Puzzle`, PH_PuzzleCrystal | วงจรเวทผ่าน → กลไกสวนต้นฉบับ | ภาพก่อน/หลัง ลองใหม่ หลายคน | ดัมมี่ |
| PH-COL-001 | `Academy.Reward` และ attribute LessonRecord ใน `src/server/Main.server.luau` | บันทึก/โหลดผ่าน → บันทึกนักเรียนจริง | รับซ้ำ ออกเข้าใหม่ ภาพและข้อมูลตรงกัน | ดัมมี่ |
| PH-UI-001 | `PlayerGui.PH_LessonHUD` จาก `src/client/Main.client.luau` | ลำดับบทเรียนและมือถือผ่าน → HUD ผลิตจริง | ภาษาไทยไม่ตัด อ่านง่าย ไม่ทับปุ่ม | ดัมมี่ |

จุดเตือน: ก่อนจบ blockout ตรวจรายการนี้; ก่อน vertical slice ตรวจ UI/เสียง/VFX/รางวัลอีกครั้ง (รุ่นนี้ยังไม่มีเสียง); ก่อนเผยแพร่ห้ามมีรายการดัมมี่ที่เข้าถึงได้ค้าง

Step 02 เพิ่มของชั่วคราวภายใต้ PH-ACA-002 / PH-EXP-001: `Workspace.PH_PersonalPracticeCrystal`, `Workspace.PH_PracticeTarget` เป็นภาพส่วนตัวระหว่างฝึกจาก `src/client/Main.client.luau`; PH-UI-001 เพิ่ม `PlayerGui.PH_LessonHUD.PH_LevitationControls` ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยงานภาพอุปกรณ์/เป้าหมาย/HUD ต้นฉบับหลังวงจรควบคุมผ่าน ก่อนปิด vertical slice ต้องตรวจยก/ลด/วาง ยกเลิก ตาย ออกระยะ สองคน และมือถือ พร้อมเก็บวัตถุคืนครบ สถานะ: ดัมมี่ ยังไม่ตรวจภาพ

Wizard v1–v4: ดู STATUS.md และ output/wizard-model-* ต้นทางของ workspace เป็นของจริงที่พบไฟล์ แต่ยังไม่ยืนยันให้เป็น asset production แทน PH ใดโดยอัตโนมัติ

## ทะเบียนชื่อสำหรับตัวตรวจ

Step 40 เพิ่มตารางนี้ให้ `scripts/check_placeholders.py` เทียบกับ source โดยตรง หนึ่งแถวต่อชื่อ/ไฟล์ ใช้ `*` แทนส่วนชื่อที่สร้างตอน runtime ID ต้องมีรายละเอียดในส่วนอื่นของไฟล์นี้ก่อน ตัวตรวจนับวัตถุทุกชิ้นใน `*.model.json` (ยกเว้น ProximityPrompt/Remote) และ literal `PH_` ใน Luau ที่ไม่ใช่การค้นวัตถุในฉาก ผลผ่านหมายถึงรายการตรงกันเท่านั้น ไม่ใช่ตรวจภาพหรือแทนของจริงแล้ว ชื่อที่ไม่ขึ้น `PH_` ใน generator (เช่น Body/EyeLeft ของคู่หู) ยังต้องตรวจด้วยคน สถานะใช้ลำดับ ดัมมี่ → พร้อมแทน → เปลี่ยนแล้วรอตรวจ → ผ่าน คอลัมน์ "ผ่านภายในระยะ" ใช้ชื่อระยะในตารางของ ROADMAP ตัวตรวจเตือน (WARN) เมื่อ ROADMAP อยู่ในระยะนั้นแต่แถวยังไม่ผ่าน และล้มเมื่อเลยระยะแล้ว แถวที่ผ่านต้องไม่เหลือชื่อ `PH_` ใน source Step 42: ไฟล์ที่สร้าง `PH_` โดยไม่ตั้ง IsPlaceholder/PlaceholderId ได้ WARN Step 43 แก้ LevitationController/LightPresentation แล้ว ตอนนี้ไม่มี WARN; Step 44 ทุกวัตถุที่ตั้งชื่อ `PH_` ตรง ๆ ต้องตั้ง IsPlaceholder ของตัวเอง (เพิ่มให้ PH_SentinelWarning และ PH_Furniture_*); ผลึก/เป้าหมายฝึกใช้ ID ตามแท่น จึงมี 4 ID ในแถว ค่าเริ่ม Step 41 ทุกแถวเป็นดัมมี่และกำหนด Vertical slice ตามข้อความ "ก่อนปิด/จบ vertical slice" ใน Step เดิม ไม่มีแถวใดตรวจแทนแล้ว

| ชื่อ | ID | แหล่ง | สถานะ | ผ่านภายในระยะ |
|---|---|---|---|---|
| `PH_Floor` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Path` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Spawn` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Boundary` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Plaza` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_LightCore` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_LakeBackdrop` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_ZonePad` | PH-ACA-001, PH-ACA-002, PH-ACA-003, PH-ACA-004, PH-EXP-002, PH-COL-001, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Decor` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_ClassWall` | PH-ACA-002, PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_ClassRoof` | PH-ACA-002, PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_LightCoreCrystal` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_RuinPillar` | PH-TRV-001, PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_RuinArch` | PH-TRV-001, PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Hedge` | PH-ACA-001, PH-EXP-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Signpost` | PH-ACA-001, PH-UI-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `Sign` | PH-UI-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `Label` | PH-UI-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonCeiling` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `Lesson` | PH-ACA-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_LessonCrystal` | PH-ACA-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `Puzzle` | PH-EXP-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_PuzzleCrystal` | PH-EXP-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `Reward` | PH-COL-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonEntry` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonExit` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonArrival` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonReturn` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonFloor` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonWall` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonPuzzle` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonPuzzleCrystal` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonFinish` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonDoor1` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonDoor2` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonExit2` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonExit3` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonRoom2Arrival` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonCaster` | PH-DUN-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonShade` | PH-DUN-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonShadeRune` | PH-DUN-001, PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DungeonDoor2Side` | PH-DUN-002, PH-TRV-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_DungeonCheckpoint` | PH-DUN-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_TrainingSentinel` | PH-DUN-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `SentinelControl` | PH-DUN-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_SentinelControlCrystal` | PH-DUN-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `DormEntry` | PH-DOR-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `LightLesson` | PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `LightRune1` | PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `LightRune2` | PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `LightRune3` | PH-ACA-003 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `LightExploreStart` | PH-EXP-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `ExploreRune1` | PH-EXP-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `ExploreRune2` | PH-EXP-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `ExploreRune3` | PH-EXP-002 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `ShieldLesson` | PH-ACA-004 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Floor` | PH-DOR-001 | `src/dorm/Room.model.json` | ดัมมี่ | Vertical slice |
| `PH_Wall` | PH-DOR-001 | `src/dorm/Room.model.json` | ดัมมี่ | Vertical slice |
| `Exit` | PH-DOR-001 | `src/dorm/Room.model.json` | ดัมมี่ | Vertical slice |
| `PH_Bench` | PH-DOR-001 | `src/dorm/Room.model.json` | ดัมมี่ | Vertical slice |
| `PH_Dorm_<UserId>` | PH-DOR-001 | `src/server/DormService.luau` | ดัมมี่ | Vertical slice |
| `PH_Dorm_<UserId>` | PH-DOR-001 | `src/server/DormServiceV2.luau` | ดัมมี่ | Vertical slice |
| `PH_Furniture_<Id>` | PH-DOR-001 | `src/server/DormServiceV2.luau` | ดัมมี่ | Vertical slice |
| `PH_DormControls` | PH-DOR-001 | `src/client/DormController.luau` | ดัมมี่ | Vertical slice |
| `PH_FurniturePreview` | PH-DOR-001 | `src/client/DormController.luau` | ดัมมี่ | Vertical slice |
| `PH_DormControls` | PH-DOR-001 | `src/client/DormControllerV2.luau` | ดัมมี่ | Vertical slice |
| `PH_FurniturePreview` | PH-DOR-001 | `src/client/DormControllerV2.luau` | ดัมมี่ | Vertical slice |
| `PH_PersonalAttackWarning` | PH-DUN-001 | `src/client/EncounterController.luau` | ดัมมี่ | Vertical slice |
| `PH_SentinelWarning` | PH-DUN-001 | `src/client/EncounterController.luau` | ดัมมี่ | Vertical slice |
| `PH_CasterLaneWarning` | PH-DUN-001 | `src/client/EncounterController.luau` | ดัมมี่ | Vertical slice |
| `PH_LessonHUD` | PH-UI-001 | `src/client/HudController.luau` | ดัมมี่ | Vertical slice |
| `PH_StudentJournal` | PH-UI-002 | `src/client/JournalController.luau` | ดัมมี่ | Vertical slice |
| `PH_JournalToggle` | PH-UI-002 | `src/client/JournalController.luau` | ดัมมี่ | Vertical slice |
| `PH_LevitationControls` | PH-UI-001 | `src/client/LevitationController.luau` | ดัมมี่ | Vertical slice |
| `PH_PersonalPracticeCrystal` | PH-ACA-002, PH-EXP-001, PH-DUN-002, PH-DUN-001 | `src/client/LevitationController.luau` | ดัมมี่ | Vertical slice |
| `PH_PracticeTarget` | PH-ACA-002, PH-EXP-001, PH-DUN-002, PH-DUN-001 | `src/client/LevitationController.luau` | ดัมมี่ | Vertical slice |
| `PH_PersonalRuneLight` | PH-ACA-003 | `src/client/LightPresentationConfigs.luau` | ดัมมี่ | Vertical slice |
| `PH_LightRuneStatus` | PH-ACA-003 | `src/client/LightPresentationConfigs.luau` | ดัมมี่ | Vertical slice |
| `PH_ExploreRuneLight` | PH-EXP-002 | `src/client/LightPresentationConfigs.luau` | ดัมมี่ | Vertical slice |
| `PH_ExploreRuneStatus` | PH-EXP-002 | `src/client/LightPresentationConfigs.luau` | ดัมมี่ | Vertical slice |
| `PH_Companion_<UserId>` | PH-PET-001 | `src/client/PetController.luau` | ดัมมี่ | Vertical slice |
| `PH_PetToggle` | PH-PET-001 | `src/client/PetController.luau` | ดัมมี่ | Vertical slice |
| `PH_PetPlay` | PH-PET-001 | `src/client/PetController.luau` | ดัมมี่ | Vertical slice |
| `PH_PetRename` | PH-PET-001 | `src/client/PetController.luau` | ดัมมี่ | Vertical slice |
| `PH_CompanionName` | PH-PET-001 | `src/client/PetController.luau` | ดัมมี่ | Vertical slice |
| `PH_ShieldControls` | PH-ACA-004 | `src/client/ShieldLessonController.luau` | ดัมมี่ | Vertical slice |

| `PH_Landscape` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_TreeTrunk` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_TreeCanopy` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Planter` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Shrub` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_Lantern` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_GardenBench` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_ArchitectureTrim` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_StoneEdging` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |
| `PH_ShoreRock` | PH-ACA-001 | `src/world/Academy.model.json` | ดัมมี่ | Vertical slice |

| `PH_CombatControls` | PH-UI-001 | `src/client/CombatController.luau` | ดัมมี่ | Vertical slice |

## งานภูมิทัศน์ / 3 พฤศจิกายน 2026

PH-ACA-001: `Workspace.AcademyPrototype.Academy.PH_Landscape` ใน `src/world/Academy.model.json` สร้างซ้ำด้วย `scripts/landscape_academy.py` หลัง blockout_round2.py: ต้นไม้ พุ่ม กระบะ ม้านั่ง โคม กรอบอาคาร ขอบลานและหินริมทะเลสาบ ยังเป็นงาน primitive study ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทนด้วยโมเดลต้นฉบับที่ตรวจสิทธิ์เมื่อรูปทรง/กล้องผ่าน ก่อนปิด Vertical slice ตรวจภาพมุมผู้เล่น ใบไม้บังสถานี/ป้าย การเดิน กล้อง มือถือและงบชิ้นส่วน; ม้านั่งยังนั่งไม่ได้ โคมยังไม่มีแสงจริง ทุกชิ้นไม่ชน/ไม่รับ query ไม่มีเสียงหรือรางวัลใหม่



## UI ต่อสู้ D64

PH-UI-001: PlayerGui.PH_LessonHUD.PH_CombatControls จาก src/client/CombatController.luau ปุ่มคลื่นเวท C/สัมผัส แถบ HP และ feedback เป็นดัมมี่ ผู้รับผิดชอบ: ผู้พัฒนาโครงการ (ยังไม่ระบุบุคคล) แทน HUD ผลิตจริงหลัง combat loop ผ่าน ก่อนปิด Vertical slice ตรวจมือถือไม่ทับ HUD/โล่/จอย/ปุ่มกระโดด, ตัวอักษรไทย, คูลดาวน์, ตาย/กลับ checkpoint/สองผู้เล่น และ cleanup ไม่มีเสียงหรือ VFX กระสุนใหม่; ข้อความโจมตีและ HP เป็น feedback ชั่วคราว ไม่ถือว่า combat presentation เสร็จ
