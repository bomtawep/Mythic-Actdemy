--!strict
local Catalog = require(script.Parent:WaitForChild("FurnitureCatalog"))
local Placement = {}
function Placement.inside(kind: string, x: number, z: number, rotation: number): boolean
	local d=Catalog[kind]
	if not d then return false end
	local hx=if rotation%180==0 then d.Width/2 else d.Depth/2
	local hz=if rotation%180==0 then d.Depth/2 else d.Width/2
	return math.abs(x)+hx<=12 and math.abs(z)+hz<=10
end
function Placement.replace(items: any, id: any, payload: any): any
	if type(id)~="string" or type(payload)~="table" then return nil end
	local result={}; local found=false
	for _,item in items do
		local copy=table.clone(item)
		if item.Id==id then
			found=true
			for _,key in {"x","z","rotation","placed"} do copy[key]=payload[key] end
		end
		table.insert(result,copy)
	end
	return if found then result else nil
end
return Placement
