--!strict
local Manager = {}
function Manager.new(makeRepository: any, clock: any, waitForRetry: any, studio: boolean)
	local entries: {[any]: any} = {}
	local shuttingDown = false
	local manager = {}
	local function status(player: any, message: string) player:SetAttribute("DormSaveStatus",message) end
	local function retry(operation: any)
		local value,reason
		for attempt=1,3 do
			value,reason=operation()
			if value or reason~="StorageError" then break end
			if attempt<3 then waitForRetry(attempt) end
		end
		return value,reason
	end
	function manager.load(player: any): any
		if shuttingDown then return nil end
		if entries[player] then return manager.get(player) end
		local entry={repo=makeRepository(player),busy=true,closing=false,state=nil,expires=0}
		entries[player]=entry
		status(player,"กำลังโหลดห้อง…")
		local value=retry(entry.repo.acquire)
		if value then entry.state=value.Furniture; entry.expires=value.Lease.Expires end
		entry.busy=false
		if not value then
			status(player,"โหลดห้องไม่ได้หรือห้องถูกล็อก กรุณาเข้าใหม่ภายหลัง")
			-- Retain the failed entry: no blank profile, edits or writes.
			return nil
		end
		status(player,if studio then "Studio: จำห้องเฉพาะเซิร์ฟเวอร์นี้" else "โหลดห้องแล้ว")
		return manager.get(player)
	end
	function manager.get(player: any): any
		local e=entries[player]
		if shuttingDown or not e or e.closing or not e.state then return nil end
		if e.expires<=clock() then
			status(player,"ล็อกห้องหมดอายุ กรุณาออกแล้วเข้าใหม่เพื่อโหลดข้อมูลล่าสุด")
			return nil
		end
		return table.clone(e.state)
	end
	function manager.set(player: any, state: any): boolean
		local e=entries[player]
		if not manager.get(player) or shuttingDown then return false end
		e.state=table.clone(state)
		status(player,if studio then "Studio: มีการเปลี่ยนแปลงในเซิร์ฟเวอร์นี้" else "มีตำแหน่งห้องรอบันทึก…")
		return true
	end
	function manager.flush(player: any): boolean
		local e=entries[player]
		if not e or e.busy or e.closing or not manager.get(player) then return false end
		e.busy=true
		local snapshot=table.clone(e.state)
		local value,reason=retry(function() return e.repo.save(snapshot) end)
		if value then e.expires=value.Lease.Expires end
		if reason=="LeaseLost" or reason=="NotAcquired" or reason=="InvalidSchema" then e.expires=0 end
		e.busy=false
		status(player,if not value then "เซฟห้องไม่สำเร็จ จะลองใหม่; หากล็อกหมดอายุจะหยุดแก้ห้อง" elseif studio then "Studio: จำห้องเฉพาะเซิร์ฟเวอร์นี้" elseif e.state.x~=snapshot.x or e.state.z~=snapshot.z or e.state.rotation~=snapshot.rotation or e.state.placed~=snapshot.placed then "มีตำแหน่งห้องรอบันทึก…" else "บันทึกห้องแล้ว")
		return value~=nil
	end
	function manager.close(player: any)
		local e=entries[player]
		if not e or e.closing then return end
		e.closing=true
		while e.busy do waitForRetry(0.1) end
		if e.state then
			local value=retry(function() return e.repo.release(table.clone(e.state)) end)
			if not value then status(player,"เซฟตอนออกไม่สำเร็จ ตำแหน่งล่าสุดอาจไม่ถูกบันทึก") end
		end
		entries[player]=nil
	end
	function manager.keys() local keys={}; for p in entries do table.insert(keys,p) end; return keys end
	function manager.shutdown() shuttingDown=true end
	return manager
end
return Manager
