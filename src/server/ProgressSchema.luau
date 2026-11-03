--!strict
-- v4: monotonic lesson progress, learned spells, one-time milestones and pet bond, plus the chosen pet name.
-- Never merge spendable inventory this way.
local Schema = {}
Schema.MaxPetNames = 16 -- PetPolicy.Names must stay within this bound
export type Spells = {Light: boolean, Shield: boolean}
export type Milestones = {Dungeon: boolean}
export type Bond = {Play: boolean, Explore: boolean, Dungeon: boolean, Dorm: boolean}
export type Pet = {Name: number, Bond: Bond}
export type Data = {Version: number, Stage: number, Spells: Spells, Milestones: Milestones, Pet: Pet}
local BOND_KEYS = {"Play", "Explore", "Dungeon", "Dorm"}
local function flags(value: any, keys: {string}): {[string]: boolean}?
	if type(value) ~= "table" then return nil end
	for key in value do
		if not table.find(keys, key) then return nil end
	end
	local out = {}
	for _, key in keys do
		if type(value[key]) ~= "boolean" then return nil end
		out[key] = value[key]
	end
	return out
end
local function pet(value: any): Pet?
	if type(value) ~= "table" then return nil end
	for key in value do
		if key ~= "Name" and key ~= "Bond" then return nil end
	end
	local name = value.Name
	if type(name) ~= "number" or name % 1 ~= 0 or name < 1 or name > Schema.MaxPetNames then return nil end
	local bond: any = flags(value.Bond, BOND_KEYS)
	if not bond then return nil end
	return {Name = name, Bond = {Play = bond.Play, Explore = bond.Explore, Dungeon = bond.Dungeon, Dorm = bond.Dorm}}
end
local function newPet(): Pet
	return {Name = 1, Bond = {Play = false, Explore = false, Dungeon = false, Dorm = false}}
end
function Schema.decode(value: any): Data?
	if value == nil then return {Version = 4, Stage = 0, Spells = {Light = false, Shield = false}, Milestones = {Dungeon = false}, Pet = newPet()} end
	if type(value) ~= "table" or type(value.Stage) ~= "number" then return nil end
	local stage = value.Stage
	if stage ~= stage or stage % 1 ~= 0 or stage < 0 or stage > 3 then return nil end
	local version = value.Version
	if version ~= 1 and version ~= 2 and version ~= 3 and version ~= 4 then return nil end
	-- Older versions migrate on read and are written back as v4.
	local spells: any = {Light = false, Shield = false}
	local milestones: any = {Dungeon = false}
	local companion: Pet? = newPet()
	if version >= 2 then
		spells = flags(value.Spells, {"Light", "Shield"})
		if not spells then return nil end
	end
	if version >= 3 then
		milestones = flags(value.Milestones, {"Dungeon"})
		if not milestones then return nil end
	end
	if version >= 4 then companion = pet(value.Pet) end
	if not companion then return nil end
	local bonded = companion.Bond.Play or companion.Bond.Explore or companion.Bond.Dungeon or companion.Bond.Dorm
	-- Spells, the dungeon and the companion all come after the first lesson record; Shield only after Light.
	if ((spells.Light or milestones.Dungeon or bonded) and stage < 3) or (spells.Shield and not spells.Light) then return nil end
	return {Version = 4, Stage = stage, Spells = {Light = spells.Light, Shield = spells.Shield}, Milestones = {Dungeon = milestones.Dungeon}, Pet = companion}
end
-- Progress and bond only grow; the pet name is cosmetic and the latest writer's choice wins.
function Schema.merge(old: any, stage: number, spells: Spells?, milestones: Milestones?, companion: Pet?): Data?
	local decoded = Schema.decode(old)
	-- A writer that sends no pet keeps the stored name; the stored bond survives through the union below.
	local keep = newPet()
	if decoded then keep.Name = decoded.Pet.Name end
	local incoming = Schema.decode({Version = 4, Stage = stage, Spells = spells or {Light = false, Shield = false}, Milestones = milestones or {Dungeon = false}, Pet = companion or keep})
	if not decoded or not incoming then return nil end
	local bond = {}
	for _, key in BOND_KEYS do bond[key] = decoded.Pet.Bond[key] or incoming.Pet.Bond[key] end
	return {Version = 4, Stage = math.max(decoded.Stage, incoming.Stage), Spells = {
		Light = decoded.Spells.Light or incoming.Spells.Light,
		Shield = decoded.Spells.Shield or incoming.Spells.Shield,
	}, Milestones = {Dungeon = decoded.Milestones.Dungeon or incoming.Milestones.Dungeon},
		Pet = {Name = incoming.Pet.Name, Bond = bond :: any}}
end
return Schema
