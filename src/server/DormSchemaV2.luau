--!strict
-- Candidate schema/migration only; runtime repository still writes v1.
local Legacy = require(script.Parent:WaitForChild("DormSchema"))
local Catalog = require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("FurnitureCatalog"))
local Schema = {}
Schema.MaxItems=8
local function integer(v: any): boolean
	return type(v)=="number" and v==v and math.abs(v)<math.huge and v%1==0
end
local function extents(item: any): (number,number)
	local definition=Catalog[item.CatalogId]
	if item.rotation%180==0 then return definition.Width/2,definition.Depth/2 end
	return definition.Depth/2,definition.Width/2
end
function Schema.decode(value: any): any
	if type(value)~="table" or value.Version~=2 or type(value.Items)~="table" then return nil end
	local count=0
	for key in value.Items do
		if not integer(key) or key<1 or key>Schema.MaxItems then return nil end
		count+=1
	end
	if count~=#value.Items or count>Schema.MaxItems then return nil end
	for index=1,count do if value.Items[index]==nil then return nil end end
	local ids={}
	local result={Version=2,Items={}}
	for index=1,count do
		local item=value.Items[index]
		if type(item)~="table" or type(item.Id)~="string" or #item.Id<1 or #item.Id>40 or not string.match(item.Id,"^[%w_-]+$") or ids[item.Id] or type(item.CatalogId)~="string" or not Catalog[item.CatalogId] then return nil end
		if not integer(item.x) or not integer(item.z) or not integer(item.rotation) or item.x%2~=0 or item.z%2~=0 or item.rotation<0 or item.rotation>=360 or item.rotation%90~=0 or type(item.placed)~="boolean" then return nil end
		local hx,hz=extents(item)
		if math.abs(item.x)+hx>12 or math.abs(item.z)+hz>10 then return nil end
		for _,other in result.Items do
			if item.placed and other.placed then
				local ox,oz=extents(other)
				if math.abs(item.x-other.x)<hx+ox and math.abs(item.z-other.z)<hz+oz then return nil end
			end
		end
		ids[item.Id]=true
		table.insert(result.Items,{Id=item.Id,CatalogId=item.CatalogId,x=item.x,z=item.z,rotation=item.rotation,placed=item.placed})
	end
	local lease=value.Lease
	if lease~=nil then
		if type(lease)~="table" or type(lease.Token)~="string" or lease.Token=="" or not integer(lease.Expires) or lease.Expires<0 then return nil end
		result.Lease={Token=lease.Token,Expires=lease.Expires}
	end
	return result
end
function Schema.migrate(value: any): any
	if type(value)=="table" and value.Version==2 then return Schema.decode(value) end
	local old=Legacy.decode(value)
	if not old then return nil end
	local f=old.Furniture
	return Schema.decode({Version=2,Items={{Id="starter-bench-001",CatalogId="Bench",x=f.x,z=f.z,rotation=f.rotation,placed=f.placed}},Lease=old.Lease})
end
return Schema
