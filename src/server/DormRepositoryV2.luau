--!strict
-- Candidate v2 writer. Acquire atomically migrates v1 only after lease admission.
local Schema = require(script.Parent:WaitForChild("DormSchemaV2"))
local Repository = {}
Repository.LeaseSeconds = 120
function Repository.new(store: any, key: string, token: string, clock: () -> number)
	assert(token ~= "", "Each session requires a unique token")
	local busy = false
	local closed = false
	local acquired = false
	local repository = {}
	local function update(operation: string, items: any): (any, string?)
		if busy or closed then return nil, "Unavailable" end
		if operation ~= "Acquire" and not acquired then return nil, "NotAcquired" end
		local snapshot = nil
		if operation ~= "Acquire" then
			snapshot = Schema.decode({Version=2,Items=items})
			if not snapshot then return nil,"InvalidFurniture" end
		end
		busy = true
		local rejection = "Cancelled"
		local ok, result = pcall(function()
			return store:UpdateAsync(key,function(old: any)
				local value = if operation == "Acquire" then Schema.migrate(old) else Schema.decode(old)
				if not value then rejection="InvalidSchema"; return nil end
				local now = clock()
				local lease = value.Lease
				if operation == "Acquire" then
					if lease and lease.Token ~= token and lease.Expires > now then rejection="Locked"; return nil end
				else
					if not lease or lease.Token ~= token or lease.Expires <= now then rejection="LeaseLost"; return nil end
					value.Items = snapshot.Items
				end
				value.Lease = if operation == "Release" then nil else {Token=token,Expires=now+Repository.LeaseSeconds}
				return value
			end)
		end)
		busy = false
		if not ok then return nil,"StorageError" end
		if not result then
			if rejection == "LeaseLost" then acquired=false end
			return nil,rejection
		end
		acquired = operation ~= "Release"
		if operation == "Release" then closed=true end
		return Schema.decode(result),nil
	end
	function repository.acquire() return update("Acquire",nil) end
	function repository.save(items: any) return update("Save",items) end
	function repository.release(items: any) return update("Release",items) end
	return repository
end
return Repository
