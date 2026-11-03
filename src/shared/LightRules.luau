--!strict
local Rules = {}
Rules.Target=5 -- I on, II off, III on; bit order follows rune numbers.
local masks={3,7,6}
function Rules.cast(bits: any, rune: any): number?
	if type(bits)~="number" or bits%1~=0 or bits<0 or bits>7 then return nil end
	if type(rune)~="number" or rune%1~=0 or not masks[rune] then return nil end
	return bit32.bxor(bits,masks[rune])
end
function Rules.lit(bits: number, rune: number): boolean
	return bit32.band(bits,bit32.lshift(1,rune-1))~=0
end
function Rules.describe(bits: number): string
	local text={}
	for i=1,3 do table.insert(text,`{i}:{if Rules.lit(bits,i) then "สว่าง" else "ดับ"}`) end
	return table.concat(text," • ")
end
return Rules
