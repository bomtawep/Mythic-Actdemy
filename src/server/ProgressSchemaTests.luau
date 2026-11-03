--!strict
-- Run in Studio Server Command Bar:
-- require(game.ServerScriptService.MythicAcademy.ProgressSchemaTests)()
local Schema = require(script.Parent:WaitForChild("ProgressSchema"))
return function()
	assert(Schema.decode(nil).Stage == 0)
	for _, bad in {false, "invalid", {}, {Version = 2, Stage = 1}, {Version = 1, Stage = -1}, {Version = 1, Stage = 4}, {Version = 1, Stage = 1.5}, {Version = 1, Stage = 0/0}, {Version = 1, Stage = math.huge}} do
		assert(Schema.decode(bad) == nil, "Invalid data must not become a new profile")
		assert(Schema.merge(bad, 0) == nil, "Invalid stored data must not be overwritten")
	end
	for old = 0, 3 do
		for incoming = 0, 3 do
			local merged = Schema.merge({Version = 1, Stage = old}, incoming)
			assert(merged and merged.Stage == math.max(old, incoming), "Stale saves must not regress progress")
			local repeated = Schema.merge(merged, incoming)
			assert(repeated and repeated.Stage == merged.Stage, "Retry must be idempotent")
		end
	end
	assert(Schema.merge(nil, 3).Stage == 3)
	assert(Schema.merge(nil, 4) == nil)
	print("PASS: progress schema validation, monotonic merge and retry idempotency")
end
