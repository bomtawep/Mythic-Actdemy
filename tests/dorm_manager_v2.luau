return function(Manager,Repository)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local now=100
	local db={value={Version=2,Items={{Id="bench",CatalogId="Bench",x=0,z=0,rotation=0,placed=true},{Id="stool",CatalogId="Stool",x=6,z=0,rotation=0,placed=true}}},fail=false,hook=nil}
	function db:UpdateAsync(_,f)
		if self.fail then error("outage") end
		if self.hook then self.hook() end
		local value=f(self.value); if value then self.value=value end; return value
	end
	local function player(id)
		local attrs={}; return {UserId=id,SetAttribute=function(_,k,v) attrs[k]=v end,attrs=attrs}
	end
	local function make(token)
		return Manager.new(function(p) return Repository.new(db,`room_{p.UserId}`,token,function() return now end) end,function() return now end,function() end,false)
	end
	local manager=make("a"); local p=player(1)
	local items=manager.load(p)
	check(#items==2,"load two items")
	items[1].x=-4
	check(manager.get(p)[1].x==0,"get returns deep copy")
	check(manager.set(p,items),"owned item can move")
	items[1].x=-6
	check(manager.get(p)[1].x==-4,"set owns deep copy")
	local forged=manager.get(p); table.insert(forged,{Id="free",CatalogId="Stool",x=0,z=6,rotation=0,placed=false})
	check(not manager.set(p,forged),"cannot mint item")
	forged=manager.get(p); table.remove(forged)
	check(not manager.set(p,forged),"cannot silently delete ownership")
	forged=manager.get(p); forged[2].CatalogId="Bench"
	check(not manager.set(p,forged),"cannot swap catalog entitlement")
	forged=manager.get(p); forged[2].Id="replacement"
	check(not manager.set(p,forged),"cannot replace identity")
	forged=manager.get(p); forged[2].x=-4
	check(not manager.set(p,forged),"overlapping placement rejected")
	db.hook=function()
		db.hook=nil
		local latest=manager.get(p); latest[2].z=4
		check(manager.set(p,latest),"edit while snapshot saves")
		check(not manager.flush(p),"no overlapping save")
	end
	check(manager.flush(p),"first snapshot save")
	check(db.value.Items[2].z==0 and manager.get(p)[2].z==4,"in-flight save preserves newer draft")
	check(string.find(p.attrs.DormSaveStatus,"รอบันทึก",1,true)~=nil,"dirty revision remains visible")
	check(manager.flush(p) and db.value.Items[2].z==4,"next snapshot flushes latest item")
	now=150; check(manager.flush(p) and db.value.Lease.Expires==270,"lease renewed")
	db.fail=true
	check(not manager.flush(p) and manager.get(p)~=nil,"outage keeps state while lease valid")
	db.fail=false
	manager.close(p)
	check(#manager.keys()==0 and db.value.Lease==nil,"close releases snapshot")
	local other=make("b"); local q=player(1)
	check(#other.load(q)==2 and other.get(q)[2].z==4,"reload preserves all items")
	now=271
	check(other.get(q)==nil and not other.set(q,items),"expired lock blocks edits")
	other.close(q)
	db.value={Version=1,Furniture={x=2,z=0,rotation=90,placed=true}}
	local legacy=make("migration"); local r=player(2)
	check(legacy.load(r)[1].Id=="starter-bench-001" and db.value.Version==2,"load migrates under repository lease")
	legacy.shutdown()
	check(not legacy.set(r,legacy.get(r)) and legacy.load(player(3))==nil,"shutdown blocks edits and admission")
	legacy.close(r)
	check(db.value.Lease==nil,"shutdown close releases migrated profile")
	print(`PASS: {n} v2 manager ownership/snapshot checks`)
end
