--!strict
local Scope = {}
function Scope.new(onError: ((any) -> ())?)
	local disposed = false
	local cleanups: {() -> ()} = {}
	local owner = {}
	function owner.add(cleanup: () -> ())
		if disposed then cleanup() else table.insert(cleanups, cleanup) end
	end
	function owner.connect(signal: any, callback: any)
		if disposed then return end
		local connection = signal:Connect(function(...)
			if not disposed then callback(...) end
		end)
		owner.add(function() connection:Disconnect() end)
	end
	function owner.dispose(): boolean
		if disposed then return true end
		disposed = true
		local success = true
		for i = #cleanups, 1, -1 do
			local ok, err = pcall(cleanups[i])
			if not ok then
				success = false
				if onError then pcall(onError, err) end
			end
		end
		table.clear(cleanups)
		return success
	end
	return owner
end
return Scope
