--!strict
-- One non-yielding visual owner at a time. Failed creates can be retried.
local Lifetime = {}
function Lifetime.new(create: (string) -> boolean, clear: () -> ())
	local current = ""
	local disposed = false
	local owner = {}
	function owner.select(name: string): boolean
		if disposed then return false end
		if name == current and name ~= "" then return true end
		if current ~= "" then clear(); current = "" end
		if name == "" then return false end
		if create(name) then current = name; return true end
		clear()
		return false
	end
	function owner.dispose()
		if disposed then return end
		disposed = true
		if current ~= "" then clear(); current = "" end
	end
	return owner
end
return Lifetime
