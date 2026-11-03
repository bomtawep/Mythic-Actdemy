return function(V2,V1,Schema)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local now=100
	local db={value=nil,fail=false,replay=false}
	function db:UpdateAsync(_,f)
		if self.fail then error("storage outage") end
		if self.replay then f(self.value) end
		local result=f(self.value)
		if result then self.value=result end
		return result
	end
	local function modern(token) return V2.new(db,"room_1",token,function() return now end) end
	local legacy=V1.new(db,"room_1","legacy",function() return now end)
	check(legacy.acquire()~=nil,"old writer initially acquires")
	check(legacy.save({x=2,z=-4,rotation=90,placed=true})~=nil,"old placement saved")
	local modernA=modern("modern-a")
	local blocked,why=modernA.acquire()
	check(not blocked and why=="Locked" and db.value.Version==1,"active v1 lease blocks migration")
	now=221; db.replay=true
	local acquired=modernA.acquire()
	check(acquired and db.value.Version==2,"expired lease migrates atomically")
	check(acquired.Lease.Token=="modern-a" and acquired.Lease.Expires==341,"migration and new lease together")
	check(#acquired.Items==1 and acquired.Items[1].x==2 and acquired.Items[1].z==-4,"migration preserves one bench")
	check(acquired.Items[1].rotation==90 and acquired.Items[1].placed,"migration preserves rotation and placed")
	check(legacy.save({x=0,z=0,rotation=0,placed=false})==nil and db.value.Version==2,"stale old writer cannot downgrade")
	local oldRejoin=V1.new(db,"room_1","old-rejoin",function() return now end)
	local oldValue,oldWhy=oldRejoin.acquire()
	check(not oldValue and oldWhy=="InvalidSchema","old build rejects new format")
	local items=Schema.decode(acquired).Items
	table.insert(items,{Id="stool-001",CatalogId="Stool",x=-6,z=0,rotation=0,placed=true})
	check(modernA.save(items)~=nil and #db.value.Items==2,"new writer persists two items")
	local before=db.value
	local overlap=Schema.decode(db.value).Items
	overlap[2].x=overlap[1].x; overlap[2].z=overlap[1].z
	check(modernA.save(overlap)==nil and db.value==before,"invalid overlap never writes")
	db.fail=true
	local failed,reason=modernA.save(items)
	check(not failed and reason=="StorageError" and db.value==before,"outage preserves record")
	db.fail=false
	local modernB=modern("modern-b")
	check(modernB.acquire()==nil,"second v2 writer locked out")
	check(modernA.release(items).Lease==nil,"v2 release saves and unlocks")
	local restored=modernB.acquire()
	check(#restored.Items==2 and restored.Items[1].Id=="starter-bench-001","reacquire and replay never duplicate starter")
	check(restored.Items[2].Id=="stool-001","new item identity preserved")
	now=342
	check(modernB.save(items)==nil,"expired v2 lease cannot save")
	local future={Version=3,Items={}}
	db.value=future
	check(modern("future-reader").acquire()==nil and db.value==future,"future schema not overwritten")
	print(`PASS: {n} atomic v2 migration/writer admission checks`)
end
