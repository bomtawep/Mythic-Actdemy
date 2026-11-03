return function(Repository,Schema)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local now=100
	local db={value=nil,fail=false,hook=nil}
	function db:UpdateAsync(_,transform)
		if self.fail then error("simulated outage") end
		if self.hook then self.hook() end
		local result=transform(self.value)
		if result then self.value=result end
		return result
	end
	local function repo(token) return Repository.new(db,"room_1",token,function() return now end) end
	local a,b=repo("A"),repo("B")
	local value=a.acquire()
	check(value and value.Furniture.x==0 and value.Lease.Token=="A","new room acquires")
	local denied,err=b.acquire()
	check(not denied and err=="Locked","second server blocked")
	local f={x=2,z=0,rotation=90,placed=true}
	check(a.save(f).Furniture.x==2,"owner save")
	f.x=4
	check(db.value.Furniture.x==2,"stored snapshot does not alias caller")
	db.hook=function() local v,e=a.save(f); check(v==nil and e=="Unavailable","concurrent operation blocked") end
	check(a.save(f)~=nil,"outer save succeeds")
	db.hook=nil
	db.fail=true
	local failed,reason=a.save(f)
	check(not failed and reason=="StorageError" and db.value.Furniture.x==4,"outage preserves stored data")
	db.fail=false
	now=221
	local expired,expiredReason=a.save(f)
	check(not expired and expiredReason=="LeaseLost","expired lease cannot save even without a new owner")
	check(b.acquire()~=nil,"expired lease can transfer")
	local stale,staleReason=a.save({x=0,z=0,rotation=0,placed=false})
	check(not stale and (staleReason=="LeaseLost" or staleReason=="NotAcquired") and db.value.Lease.Token=="B","stale server cannot overwrite")
	local released=b.release({x=-2,z=0,rotation=0,placed=false})
	check(released and released.Lease==nil,"release saves and unlocks atomically")
	check(b.save(f)==nil,"released session cannot write")
	local c=repo("C")
	check(c.acquire().Furniture.x==-2,"new session restores last placement")
	check(c.save({x=12,z=0,rotation=0,placed=true})==nil,"reject out-of-bounds state")
	db.value={Version=2,Furniture={}}
	local d=repo("D")
	local invalid,invalidReason=d.acquire()
	check(not invalid and invalidReason=="InvalidSchema" and db.value.Version==2,"unknown version never replaced")
	for _,bad in {false,{}, {Version=1,Furniture={x=0/0,z=0,rotation=0,placed=false}}, {Version=1,Furniture={x=0,z=0,rotation=45,placed=false}}, {Version=1,Furniture={x=1,z=0,rotation=0,placed=false}}, {Version=1,Furniture={x=0,z=0,rotation=0,placed=false},Lease={Token="",Expires=2}}} do
		check(Schema.decode(bad)==nil,"reject invalid schema")
	end
	print(`PASS: {n} dorm schema/lease repository checks`)
end
