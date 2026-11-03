return function(Manager,Repository)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local now=100
	local db={data={},fail=false,hook=nil,calls=0}
	function db:UpdateAsync(key,f)
		self.calls+=1
		if self.fail then error("outage") end
		if self.hook then self.hook() end
		local result=f(self.data[key]); if result then self.data[key]=result end; return result
	end
	local function player(id)
		local attrs={}; return {UserId=id,SetAttribute=function(_,k,v) attrs[k]=v end,attrs=attrs}
	end
	local function manager(prefix)
		return Manager.new(function(p) return Repository.new(db,`room_{p.UserId}`,prefix,function() return now end) end,function() return now end,function() end,false)
	end
	local a,b=manager("A"),manager("B")
	local p,q=player(1),player(1)
	check(a.load(p).x==0,"new room loaded")
	check(b.load(q)==nil,"other session blocked")
	check(not b.set(q,{x=2}),"failed load cannot edit")
	check(a.set(p,{x=2,z=0,rotation=0,placed=true}),"owner edits")
	db.hook=function() db.hook=nil; check(a.set(p,{x=4,z=0,rotation=0,placed=true}),"edit while save in flight") end
	check(a.flush(p),"save snapshot")
	check(db.data.room_1.Furniture.x==2 and a.get(p).x==4,"snapshot must not erase newer change")
	check(a.flush(p) and db.data.room_1.Furniture.x==4,"next flush saves latest")
	now=150; check(a.flush(p) and db.data.room_1.Lease.Expires==270,"renew even without dirty change")
	db.fail=true
	local before=db.calls
	check(not a.flush(p) and db.calls-before==3,"storage error retries three times")
	check(a.get(p).x==4,"temporary failure retains local state")
	db.fail=false
	check(a.flush(p),"retry succeeds later")
	a.close(p)
	check(#a.keys()==0 and db.data.room_1.Lease==nil,"close releases lease")
	local c=manager("C")
	check(c.load(player(1)).x==4,"rejoin restores latest placement")
	local d=manager("D"); local r=player(2)
	db.fail=true
	check(d.load(r)==nil and not d.set(r,{x=0}),"load outage blocks edits")
	d.close(r); check(db.data.room_2==nil,"failed load close writes no defaults")
	db.fail=false
	local e=manager("E"); local s=player(3)
	e.load(s); now+=121
	check(e.get(s)==nil and not e.set(s,{x=0}),"expired lease blocks mutation")
	e.close(s)
	check(#e.keys()==0,"close lost lease completes locally")
	local f=manager("F"); local t=player(4)
	f.load(t); f.shutdown()
	check(not f.set(t,{x=0}) and f.load(player(5))==nil,"shutdown blocks new loads and edits")
	f.close(t); check(#f.keys()==0,"shutdown close releases loaded profile")
	print(`PASS: {n} dorm persistence manager checks`)
end
