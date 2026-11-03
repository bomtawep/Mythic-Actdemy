--!strict
local Schema = {}
local function integer(v: any): boolean
	return type(v) == "number" and v == v and math.abs(v) < math.huge and v % 1 == 0
end
function Schema.decode(value: any): any
	if value == nil then return {Version=1,Furniture={x=0,z=0,rotation=0,placed=false}} end
	if type(value) ~= "table" or value.Version ~= 1 or type(value.Furniture) ~= "table" then return nil end
	local f=value.Furniture
	if not integer(f.x) or not integer(f.z) or not integer(f.rotation) or type(f.placed) ~= "boolean" then return nil end
	if f.x % 2 ~= 0 or f.z % 2 ~= 0 or f.rotation < 0 or f.rotation >= 360 or f.rotation % 90 ~= 0 then return nil end
	local hx=if f.rotation % 180 == 0 then 2 else 1
	local hz=if f.rotation % 180 == 0 then 1 else 2
	if math.abs(f.x)+hx>12 or math.abs(f.z)+hz>10 then return nil end
	local lease=value.Lease
	if lease ~= nil and (type(lease) ~= "table" or type(lease.Token) ~= "string" or lease.Token == "" or not integer(lease.Expires) or lease.Expires < 0) then return nil end
	return {Version=1,Furniture={x=f.x,z=f.z,rotation=f.rotation,placed=f.placed},Lease=if lease then {Token=lease.Token,Expires=lease.Expires} else nil}
end
return Schema
