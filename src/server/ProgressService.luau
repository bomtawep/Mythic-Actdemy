--!strict
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Schema = require(script.Parent:WaitForChild("ProgressSchema"))
local Service = {}
type Flags = {[string]: boolean}
type Entry = {stage: number, saved: number, flags: Flags, savedFlags: Flags, petName: number, savedPetName: number, busy: boolean, closing: boolean, connections: {RBXScriptConnection}}
-- Gameplay services mark a pass with these attributes; Progress persists them and restores them on load.
-- Light/Shield are learned spells; Dungeon is the first finished three-room run (scroll field-test page);
-- Pet* are the companion's first shared activities (bond).
local FLAG_ATTRIBUTES = {Light = "LightCompleted", Shield = "ShieldPassed", Dungeon = "DungeonCompleted",
	PetPlay = "PetBondPlay", PetExplore = "PetBondExplore", PetDungeon = "PetBondDungeon", PetDorm = "PetBondDorm"}
local PET_NAME_ATTRIBUTE = "PetNameIndex"
local function flagsOf(data: Schema.Data): Flags
	local bond = data.Pet.Bond
	return {Light = data.Spells.Light, Shield = data.Spells.Shield, Dungeon = data.Milestones.Dungeon,
		PetPlay = bond.Play, PetExplore = bond.Explore, PetDungeon = bond.Dungeon, PetDorm = bond.Dorm}
end
local entries: {[Player]: Entry} = {}
local memory: {[number]: any} = {}
local studio = RunService:IsStudio()
-- Studio never opens the live store, even when Studio API access is enabled.
local store = if studio then nil else DataStoreService:GetDataStore("MythicAcademy_LessonProgress_v1")
local shuttingDown = false

local function sync(player: Player, entry: Entry)
	player:SetAttribute("LessonStage", entry.stage)
	player:SetAttribute("LevitationUnlocked", entry.stage >= 1)
	player:SetAttribute("LessonRecord", entry.stage >= 3)
	for flag, attribute in FLAG_ATTRIBUTES do
		player:SetAttribute(attribute, entry.flags[flag])
	end
	player:SetAttribute(PET_NAME_ATTRIBUTE, entry.petName)
end
local function dirty(entry: Entry): boolean
	if entry.saved < entry.stage or entry.petName ~= entry.savedPetName then return true end
	for flag in FLAG_ATTRIBUTES do
		if entry.flags[flag] and not entry.savedFlags[flag] then return true end
	end
	return false
end
local function write(userId: number, stage: number, flags: Flags, petName: number): any
	local invalid = false
	local function transform(old: any)
		local companion = {Name = petName, Bond = {Play = flags.PetPlay, Explore = flags.PetExplore, Dungeon = flags.PetDungeon, Dorm = flags.PetDorm}}
		local merged = Schema.merge(old, stage, {Light = flags.Light, Shield = flags.Shield}, {Dungeon = flags.Dungeon}, companion)
		if not merged then invalid = true end
		return merged
	end
	local result
	if studio then
		result = transform(memory[userId])
		if result then memory[userId] = result end
	else
		result = (store :: GlobalDataStore):UpdateAsync(`player_{userId}`, transform)
	end
	if invalid or not result then error("Unsupported or corrupt progress schema; write cancelled") end
	return result
end

function Service.Load(player: Player)
	player:SetAttribute("ProgressReady", false)
	player:SetAttribute("ProgressStatus", "กำลังโหลดข้อมูล…")
	local result = nil
	for attempt = 1, 3 do
		local ok, value = pcall(function()
			if studio then return memory[player.UserId] end
			return (store :: GlobalDataStore):GetAsync(`player_{player.UserId}`)
		end)
		if ok then
			result = Schema.decode(value)
			break -- Unknown schema is not a new profile and must never be overwritten.
		end
		if attempt < 3 then task.wait(attempt) end
	end
	if player.Parent ~= Players or shuttingDown then return end
	if not result then
		player:SetAttribute("ProgressStatus", "โหลดข้อมูลไม่สำเร็จ กรุณาออกแล้วเข้าใหม่ (ยังไม่เปิดการรับรางวัล)")
		return
	end
	local entry: Entry = {stage = result.Stage, saved = result.Stage, flags = flagsOf(result), savedFlags = flagsOf(result),
		petName = result.Pet.Name, savedPetName = result.Pet.Name, busy = false, closing = false, connections = {}}
	entries[player] = entry
	sync(player, entry)
	for flag, attribute in FLAG_ATTRIBUTES do
		table.insert(entry.connections, player:GetAttributeChangedSignal(attribute):Connect(function()
			if player:GetAttribute(attribute) == true and Service.Record(player, flag) then task.spawn(Service.Save, player) end
		end))
	end
	table.insert(entry.connections, player:GetAttributeChangedSignal(PET_NAME_ATTRIBUTE):Connect(function()
		if Service.SetPetName(player, player:GetAttribute(PET_NAME_ATTRIBUTE)) then task.spawn(Service.Save, player) end
	end))
	player:SetAttribute("ProgressStatus", if studio then "โหมด Studio: จำข้อมูลเฉพาะเซิร์ฟเวอร์นี้" else "โหลดข้อมูลแล้ว")
	local hints = {
		[0] = "เดินไปแท่นฝึกสีม่วง แล้วกดเริ่มฝึก",
		[1] = "ผ่านบทฝึกแล้ว ไปใช้เวทที่กลไกสีฟ้า",
		[2] = "กลไกทำงานแล้ว ไปรับบันทึกที่แท่นสีทอง",
		[3] = "คุณได้รับบันทึกแรงลอยตัวแล้ว",
	}
	player:SetAttribute("LessonHint", hints[entry.stage])
	player:SetAttribute("ProgressReady", true)
end

function Service.Advance(player: Player, expected: number): boolean
	local entry = entries[player]
	if not entry or entry.closing or shuttingDown or entry.stage ~= expected or expected >= 3 then return false end
	entry.stage += 1
	sync(player, entry)
	player:SetAttribute("ProgressStatus", if studio then "โหมด Studio: จำข้อมูลเฉพาะเซิร์ฟเวอร์นี้" else "มีความก้าวหน้ารอบันทึก…")
	return true
end

-- Records a learned spell or milestone once the first lesson record exists; Shield needs Light first.
function Service.Record(player: Player, flag: string): boolean
	local entry = entries[player]
	if not entry or entry.closing or shuttingDown or entry.stage < 3 or FLAG_ATTRIBUTES[flag] == nil then return false end
	if flag == "Shield" and not entry.flags.Light then return false end
	if entry.flags[flag] then return true end
	entry.flags[flag] = true
	sync(player, entry)
	player:SetAttribute("ProgressStatus", if studio then "โหมด Studio: จำข้อมูลเฉพาะเซิร์ฟเวอร์นี้" else "มีความก้าวหน้ารอบันทึก…")
	return true
end

-- The companion's name is cosmetic and changeable; anything outside the schema's range is put back.
function Service.SetPetName(player: Player, index: any): boolean
	local entry = entries[player]
	if not entry or entry.closing or shuttingDown then return false end
	if type(index) ~= "number" or index % 1 ~= 0 or index < 1 or index > Schema.MaxPetNames then
		player:SetAttribute(PET_NAME_ATTRIBUTE, entry.petName)
		return false
	end
	if entry.petName == index then return false end
	entry.petName = index
	return true
end

function Service.Save(player: Player): boolean
	local entry = entries[player]
	if not entry or entry.busy then return false end
	if not dirty(entry) then return true end
	entry.busy = true
	local snapshot = entry.stage
	local flagSnapshot = table.clone(entry.flags)
	local nameSnapshot = entry.petName
	local success = false
	for attempt = 1, 3 do
		local ok, result = pcall(write, player.UserId, snapshot, flagSnapshot, nameSnapshot)
		if ok then
			entry.saved = math.max(entry.saved, result.Stage)
			entry.stage = math.max(entry.stage, result.Stage)
			-- The stored record is the union of every server's writes, so it may hold flags this server missed.
			local stored = flagsOf(result)
			for flag in FLAG_ATTRIBUTES do
				entry.savedFlags[flag] = entry.savedFlags[flag] or stored[flag]
				entry.flags[flag] = entry.flags[flag] or stored[flag]
			end
			entry.savedPetName = result.Pet.Name
			sync(player, entry)
			success = true
			break
		end
		warn(`Progress save failed for {player.UserId}, attempt {attempt}`)
		if attempt < 3 then task.wait(attempt) end
	end
	entry.busy = false
	if player.Parent == Players then
		player:SetAttribute("ProgressStatus", if not success then "บันทึกไม่สำเร็จ จะลองใหม่; อย่าเพิ่งออกเกม" elseif studio then "โหมด Studio: จำข้อมูลเฉพาะเซิร์ฟเวอร์นี้" elseif dirty(entry) then "มีความก้าวหน้ารอบันทึก…" else "บันทึกข้อมูลแล้ว")
	end
	return success
end

function Service.Close(player: Player)
	local entry = entries[player]
	if not entry then return end
	-- Only one close owner; shutdown waits for entries instead of racing removal.
	if entry.closing then return end
	entry.closing = true
	player:SetAttribute("ProgressReady", false)
	for _, connection in entry.connections do connection:Disconnect() end
	while entry.busy do task.wait(0.1) end
	Service.Save(player)
	entries[player] = nil
end

function Service.Start()
	task.spawn(function()
		while not shuttingDown do
			task.wait(30)
			if shuttingDown then break end
			for player in entries do task.spawn(Service.Save, player) end
		end
	end)
	game:BindToClose(function()
		shuttingDown = true
		for player in entries do task.spawn(Service.Close, player) end
		local deadline = os.clock() + 25
		while next(entries) and os.clock() < deadline do task.wait(0.1) end
	end)
end
return Service
