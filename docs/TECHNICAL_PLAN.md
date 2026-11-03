# แนวทางพัฒนาและเชื่อมระบบ

สรุปแนวทางจาก S01, S05, S06, S13–S16 ไม่ใช่ผลตรวจว่ามี architecture นี้ในโค้ดแล้ว

## Rojo และฉาก

ฉากถาวรควรเป็นวัตถุใน Workspace ที่เห็นและจัดตำแหน่งได้ก่อน Play ตามแนวทางที่เสนอ Rojo จัดการโค้ด/โครงสร้างที่กำหนด; Script ที่ใช้ Instance.new ระหว่างเล่นไม่ได้สร้างฉากค้างในโหมดแก้ไข วัตถุใน Storage มีใน Explorer แต่ไม่ใช่วัตถุที่วางอยู่ในฉาก

ก่อนแก้ปัญหา “มองไม่เห็น map” ตรวจ project mapping ตำแหน่งวัตถุ และเวลาเรียกสร้างจริง ห้ามสรุปว่า Rojo ใช้ทำฉากไม่ได้ ตรวจคู่มือเวอร์ชันที่ใช้เมื่อเริ่ม implementation

## ความรับผิดชอบระบบ

Step 53: DungeonService ตั้ง `DungeonRoom` (0–3) ทุกครั้งที่ travel ตาม marker; DungeonViewModel.describe รับ `where` เพื่อแยก "ผ่านห้อง 2 แล้วแต่ยังอยู่ห้อง 2" กับ "อยู่ห้อง 3"; slot หอพัก (v1/v2) เริ่มที่ x=−1200 นอกกรอบ Academy

Step 51: Academy.model.json จัดตามผัง SCENE_DESIGN_SLICE (ชื่อชิ้นใหม่ PH_Plaza/PH_LightCore/PH_LakeBackdrop/PH_ZonePad); ดันเจียนอยู่นอกกรอบ Academy ที่ x≥1165 เข้าออกด้วยวาร์ปเท่านั้น; `EncounterRules.CasterRoomHalfWidth/CasterRoomDepth` (44/114) ใช้ร่วม server/client แทนตัวเลขฝัง

Step 50: ProgressSchema v4 เพิ่ม `Pet={Name 1..16, Bond={Play,Explore,Dungeon,Dorm}}` merge: Bond OR, Name ของผู้เขียน (ไม่ส่ง pet = คงชื่อเดิม); ProgressService flags PetPlay/PetExplore/PetDungeon/PetDorm ↔ PetBond* และ `SetPetName` ↔ `PetNameIndex` (ค่านอกช่วงถูกคืนค่า); PetService รับ remote "Play"/"Rename" (boolean ยังเป็นเรียก/เก็บ) และฟัง DungeonState=Complete, LightDiscovery, InDorm; PetPolicy มี Names/Activities/bondStage/tagText/journal ใช้ร่วม server/client

Step 49: EncounterRules เพิ่ม `casterStep`/`inCasterRoom` และ `shadeActive`/`nearShade` (ฟังก์ชันล้วน); EncounterService ขับผู้เฝ้า/ผู้ยิง/เงาใน heartbeat เดียว (`CasterPhase`/`CasterStrikeAt`/`CasterLane`, `ShadeRevealed`) และล้าง cast เมื่อเป้าหมายหมดเวลาหรือห้องไม่ active; ShieldGuard เลือกการโจมตีที่ถึงก่อนระหว่างผู้เฝ้า (ต้องอยู่ ≤15) กับลูกยิง; DungeonRules.doorTarget รับ `shadeRevealed` และ `DungeonDoor2Side`; DungeonService prompt `DungeonShadeRune`

Step 48: ProgressSchema v3 `{Version=3, Stage, Spells, Milestones={Dungeon}}` decode v1/v2 (migrate) ปฏิเสธ v4+ และ key/ค่าที่ไม่รู้จัก; ProgressService ใช้ flags Light/Shield/Dungeon ↔ LightCompleted/ShieldPassed/DungeonCompleted (`Service.Record` แทน `Learn`); client `ScrollModel` คิดหน้าคัมภีร์จาก attribute เท่านั้น; สมุดเพิ่ม Entry10 โดย Entry9 (สถานะเซฟ) LayoutOrder 11

Step 47: DungeonRules สถานะ Idle→Puzzle→Encounter→Reward→Complete และ `doorTarget`; EncounterService require DungeonService (ไม่มีวงกลับ) ใช้ `clear` ร่วมทั้งแท่นควบคุมและโล่ (`EncounterBlocks` ≥ `BlocksToClear`=2); LevitationRules ผูก DungeonPuzzle กับ Puzzle และ SentinelControl กับ Encounter; ประตู/ทางออกต่อห้องใน DungeonService

Step 46: ProgressSchema v2 `{Version=2, Stage, Spells={Light, Shield}}` merge = max stage + OR spells; decode รับ v1 (migrate) ปฏิเสธ v3+ และ record ที่ผิดเงื่อนไขเวท ProgressService.Learn และ watcher บน LightCompleted/ShieldPassed (disconnect ตอน Close); LightPuzzleService/ShieldLessonService initialize ไม่รีเซ็ตค่า true

Step 45: `tests/reward_persistence_flow.luau` ใช้ `loadFlowServices` กับ `newService` (ProgressService จริง) และ DataStore double แยก key ต่อผู้เล่น จำลอง PlayerAdded/PlayerRemoving สำหรับออก-เข้าใหม่

Step 44: `tests/placeholder_metadata_flow.luau` โหลด PetController/EncounterController/LevitationController ตัวจริงบน Instance doubles ตรวจ attribute ของ PH_ ทุกชิ้น และ ID ผลึก/เป้าหมายครบ 4 แท่น; check_placeholders เพิ่มกฎจับคู่ `x.Name = "PH_…"` กับ `x:SetAttribute("IsPlaceholder", …)`

Step 43: LightPresentationConfigs มี PlaceholderId ต่อชุด (Lesson PH-ACA-003, Explore PH-EXP-002) LightPresentation ตั้งให้แสง/ป้าย; LevitationController ใช้ตาราง station→ID ตัวตรวจยอมรับ `SetAttribute("PlaceholderId", <ค่าใดก็ได้>)` ส่วนการเทียบทะเบียนใช้ ID ที่เป็น literal ในไฟล์

Step 42: check_luau.py เรียก check_placeholders.py ก่อน compile (ล้มทันทีถ้าทะเบียนไม่ตรง) และ CI `placeholder-check` ใช้ Python อย่างเดียว ตรวจ `SetAttribute("IsPlaceholder", true)` ต้องคู่กับ PlaceholderId ในไฟล์เดียวกัน

Step 41: แถวทะเบียนมี สถานะ/ผ่านภายในระยะ; ลำดับระยะอ่านจากตาราง `| ระยะ |` ใน ROADMAP และระยะปัจจุบันจากบรรทัด "ระยะปัจจุบันสำหรับตัวตรวจดัมมี่:" ใช้ `--stage` จำลองก่อนเลื่อนระยะ

Step 40: `scripts/check_placeholders.py` อ่าน `src/**/*.model.json` และ literal `PH_` ใน Luau เทียบตาราง "ทะเบียนชื่อสำหรับตัวตรวจ" ใน ASSET_TRACKER ทั้งสองทาง (ไม่ลงทะเบียน/แถวค้าง) ตรวจ ID และ PlaceholderId ต่อไฟล์ เขียน build/placeholder-scan.json; fixture tests ที่ `tests/placeholder_scan_test.py`

Step 39: shield_combat_flow โหลดสามบริการจริงร่วมกัน ทดสอบการรับ remote และ damage สองผู้เล่นจาก permission ที่ได้ผ่าน trial ใน fixture ไม่ใช่การกำหนด ShieldPassed ให้คนกันโดยตรง ยังใช้ clock/network doubles

Step 38: ShieldGuard.Blocked ตรวจชีวิต/profile/run ซ้ำและ consume; EncounterService ใช้ Guard.Reset เมื่อ warning จบหรือบริบทไม่ active รวม clear enemy UI เพิ่ม profile/stage readiness

Step 37: ShieldGuard เก็บ accepted cast/target เป็น server attributes และ consume ที่ hit; EncounterService ใช้ GetServerTimeNow ส่ง strike deadline; ShieldLessonService route Cast ไป Guard เมื่อไม่มี trial UI ไม่ส่ง timestamp

Step 36: ShieldLessonService ทดสอบกับ deterministic server clock; ShieldLessonController/HUD/Journal ทดสอบร่วม Instance/input doubles ShieldJournalModel แสดงผล session-only ไม่มีการเซฟผลโล่

Step 35: ShieldLessonService ถือ session/เวลา cast และ strike กับผลเสีย HP; ShieldRules กำหนดช่วงกันและเกณฑ์ผ่าน; ShieldLessonController ส่ง Cast และนับถอยหลังด้วย server time เพื่อแสดงผล ไม่รับ client timestamp

Step 34: LightPresentation.new(config) ถือแสง/ป้ายและ ControllerScope ร่วมกัน wrappers เลือก config บทเรียน/สวน แทน duplication ของ client ใน Step 32–33 ชุดทดสอบโหลด wrappers และ presentation จริงร่วม HUD/สมุดบน doubles

Step 33 แทน server duplication ของ Step 32: LightPuzzleService.new(config) ถือ lifecycle ร่วม LightPuzzleConfigs ระบุเป้า/attributes/prerequisite/BlockedBy แต่ละกิจกรรม wrappers เดิมเรียก factory ส่วน client presentation ยังแยกอยู่

Step 32: LightExploreService/Controller ใช้ LightRules เดิมแต่ state/target แยกจากบทเรียน เป้าสำรวจ 010 และ LightDiscovery เป็น session-only ยังมีโค้ด lifecycle ซ้ำกับบริการบทเรียน ต้องรวมก่อนขยายหลายจุด

Step 31: LightLessonController ฟังบริบท profile/dorm/dungeon/levitation แล้วซ่อนไฟและป้าย ทดสอบร่วม HudController/JournalController ตัวจริงบน Instance doubles ยังไม่มีผล renderer/Input จริง

Step 30: LightLessonService ใช้ eligibility ร่วมใน prompt/Heartbeat รวม Health/Stage; LightJournalModel แสดงสถานะ session-only ใน JournalController ชุดทดสอบ service จริงครอบคลุมสองผู้เล่นบน doubles

Step 29: LightLessonService ตรวจ prompt/ข้อมูล/ระยะและเก็บ light state รายคน LightRules คำนวณสลับอักขระ LightLessonController แสดงแสง/ข้อความส่วนตัว มี cleanup ผ่าน ControllerScope ไม่มีข้อมูลถาวรหรือ remote ใหม่

Step 27 แทนสถานะ default v1 ของ Step 26: default.project.json local เปิด v2 แล้วหลัง service/UI flow tests บน doubles ผ่าน Runtime หลักเลือก DormServiceV2/DormControllerV2 ยังไม่มีผลทดสอบ Roblox/บริการจริง

Step 26: startup เลือก Dorm service/controller v1/v2 จาก BoolValue เดียวกัน experimental project เปิด v2 แยก ServiceV2 ตรวจ Commit Id ที่เลือก ใช้ FurniturePlacement คัดลอก placement แล้ว DormSchemaV2 ตรวจทั้ง Items ก่อน manager.Set

Step 25: DormDataManagerV2 candidate เก็บ Items พร้อม deep snapshots/revision และ inventory admission ห้าม set เปลี่ยนสิทธิ์ชิ้นงาน Runtime DormPersistence ยังใช้ manager v1 ไม่ได้เปลี่ยน reader/writer จริง

Step 24: DormRepositoryV2 candidate ใช้ DormSchemaV2.migrate เฉพาะ Acquire ภายใต้ lease admission ใน UpdateAsync เดียว Save/Release ต้องเป็น v2 และสิทธิ์ยังไม่หมด ยังไม่ถูก require โดย runtime DormPersistence

Step 23: FurnitureCatalog ให้ขนาดชิ้นงาน; DormSchemaV2 เป็น candidate validator/migrator พร้อม collision แบบ footprint ยังไม่แทน DormSchema v1 ใน repository/service ปัจจุบัน

Step 22: runner โหลด DormController จริงกับ Instance/event doubles เพื่อทดสอบการส่ง remote เฉพาะ explicit commit/store, server revision และการล้าง preview ไม่ตรวจ renderer/physics

Step 21: DormController เก็บ draft preview; DormService รับ Commit ผ่าน DormSchema และตรวจสิทธิ์/lease ก่อนเปลี่ยนจริง ส่ง state ผ่าน attributes และเพิ่ม revision เพื่อ reset draft ไม่มีการเชื่อ UI ว่าวางผ่านแล้ว

Step 20: runner โหลด DormPersistence + manager/repository/schema กับ DormService จริงใน test environment และใช้ coroutine ทดสอบ interleaving ของ load/close รวม callback timer/shutdown ไม่ใช่ scheduler หรือ DataStore ของ Roblox จริง

Step 19 แทนสถานะ Step 18: DormPersistence เลือก live store/Studio memory และจัด timer/shutdown; DormDataManager เก็บ snapshots/lease/retry; DormService โหลดก่อนสร้างและส่งการแก้ให้ manager โค้ดเชื่อมแล้วแต่ยังไม่ผ่าน DataStore จริง

Step 18: DormSchema ตรวจข้อมูล mutable furniture; DormRepository เป็น adapter UpdateAsync/lease 120 วินาที ยังไม่มี persistence manager หรือการเชื่อม DormService การบันทึกห้อง runtime ยังไม่เปิดใช้งาน

Step 17: runner เพิ่ม DormService ตัวจริงใน API doubles พร้อม geometry จาก Room.model.json ทดสอบสองผู้เล่นและ cleanup; CFrame double ไม่จำลอง rotation matrix การทดสอบนี้ยังไม่ใช่ Roblox runtime

Step 16: DormService เป็นเจ้าของ runtime room/ตำแหน่งม้านั่ง ตรวจ OwnerUserId และตำแหน่ง character รับเฉพาะคำสั่งที่ whitelist ใน DormRules; DormController แสดงปุ่มและส่งคำสั่ง ไม่มี persistence ห้องหรือ reuse monotonic Stage merge

Step 15: ControllerScope ผูก cleanup ของสมุด/คู่หู/คำเตือนกับ HUD.Destroying รวม disconnect และกัน callback หลัง dispose การทดสอบยังเป็น event doubles ไม่ใช่ actual client Instances

Step 14: Main.client ประกอบ controllers; HudController แสดงเป้าหมาย, LevitationController ดูแลอินพุตและภาพเวท, VisualLifetime ถืออายุภาพหนึ่ง station และ dispose ส่วน controllers อื่นยังมีงาน cleanup ต่อ

Step 13: DungeonViewModel ฝั่ง client แปลง server attributes เป็นข้อความเป้าหมาย/checkpoint/summary ใช้ร่วมกันใน HUD และสมุด ไม่เปลี่ยนแหล่งตัดสินผลที่ server

Step 12: `scripts/check_luau.py` โหลด source บริการจริงใน test environment และตำแหน่งจากฉาก JSON ทดสอบ callback ข้ามบริการใน `tests/service_flow.luau`; DungeonService.Start ป้องกันการลงทะเบียนซ้ำแล้ว

Step 11: LessonService ใช้ EncounterService.Clear หลัง session แท่นควบคุมวางสำเร็จ EncounterRules ตรวจสิทธิ์เริ่ม/หยุด Server เป็นเจ้าของ EncounterCleared และ DungeonService ล้างเมื่อเข้ารันใหม่ ไม่เปลี่ยน schema ข้อมูลถาวร

Step 10: EncounterService คำนวณวงจรเตือน/โจมตี/พักและความเสียหายฝั่ง server, EncounterRules เป็นกฎที่ทดสอบได้, EncounterController แสดงคำเตือนรายคน ไม่เพิ่ม RemoteEvent และยังไม่ใช่ระบบ combat เต็ม

Step 09 ทำแล้ว: Main เริ่มบริการ; LessonService เป็นเจ้าของบทเรียนและ session เวท; LevitationRules รวมกฎตรวจที่ remote/Heartbeat ใช้ร่วมกัน การแยกนี้แทนข้อความงานค้าง Step 08 ด้านล่าง ยังไม่ใช่ระบบ Spell อิสระครบทุกเวท

Step 08: DungeonService เก็บสถานะรัน/พักผ่าน attributes ฝั่ง server ใช้ DungeonRules เลือกจุด recovery ไม่เปลี่ยน ProgressSchema การแยกบทเรียน/เวทจาก Main ยังเป็นงานถัดไป

สถานะ implementation Step 03: `src/server/ProgressService.luau` เป็นเจ้าของขั้นบทเรียนและบันทึก `ProgressSchema.luau` ตรวจ schema/รวมความก้าวหน้าที่เพิ่มได้เท่านั้น รายละเอียดข้อจำกัดและแผนตรวจใน STEP_03.md ยังไม่ใช่ระบบข้อมูลผู้เล่นครบตาม architecture ด้านล่าง และยังไม่ผ่าน DataStore จริง

แยกข้อมูลผู้เล่น/ความก้าวหน้า, Lesson, Spell, Quest, Inventory/Collection, Pet, Dorm/Placement, Party/Travel, Dungeon Session/Layout/Encounter/Puzzle/Objective/Reward/Recovery, UI/Input และ Presentation

ระบบสำคัญเช่นสิทธิ์ของ รางวัล และผลการซื้อ ต้องตรวจจากฝั่งเซิร์ฟเวอร์ ป้องกันรับซ้ำ ข้อมูลห้องต้องตรวจเจ้าของและตำแหน่งวาง มีการจัดการโหลดไม่สำเร็จ/ออกกลางคัน/กลับเข้า ไม่ออกแบบให้ client เป็นผู้ตัดสินรางวัลเอง

## ต้องตรวจในเกมก่อนเรียกพร้อม

มือถือและคอมควบคุมได้, การเริ่มเรียน/ผ่าน/ลองใหม่, วาร์ปไปกลับและทีมหลุด, checkpoint และจบรัน, บันทึกของ/ชุด/ห้อง, รางวัลและใบเสร็จซ้ำ, สิทธิ์เข้าห้อง, หลาย Aura/สัตว์พร้อมกัน, กล้อง/การชนและฉากถาวร

เป้าหมายเดิม: เวทครั้งแรกไม่เกิน 60 วินาที, ผู้ทดสอบอย่างน้อย 80% เรียนคาบแรกได้เอง, มือถืออ้างอิง 30 FPS ขึ้นไป เป็นเป้าทดลอง ต้องกำหนดอุปกรณ์/กลุ่มทดสอบและบันทึกผลจริง
