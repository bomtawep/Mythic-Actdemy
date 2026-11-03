return function(loadService, geometry, persistent)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local function signal()
		local list={}
		return {Connect=function(_,f) table.insert(list,f) end, Fire=function(_,...) for _,f in list do f(...) end end, Count=function() return #list end}
	end
	local mt={}
	local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z},mt) end
	mt.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
	mt.__sub=function(a,b) return vec(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
	mt.__mul=function(a,_) return a end -- rotation math is covered in DormRules, not this API double
	mt.__index=function(a,k) if k=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end
	local now=10
	local players={list={},PlayerAdded=signal(),PlayerRemoving=signal()}
	function players:GetPlayers() return self.list end
	local function player(id)
		local attrs={ProgressReady=true,DungeonState="Idle",LevitationStation=""}
		local root={Position=vec(0,0,0),IsA=function(_,k) return k=="BasePart" end}
		local humanoid={Health=100}
		local char={FindFirstChild=function() return root end,FindFirstChildOfClass=function() return humanoid end}
		function char:PivotTo(pos) root.Position=pos end
		local p={UserId=id,Character=char,CharacterRemoving=signal(),Parent=players}
		function p:GetAttribute(k) return attrs[k] end
		function p:SetAttribute(k,v) attrs[k]=v end
		table.insert(players.list,p)
		return p,root,humanoid
	end
	local a,ar,ah=player(1)
	local b,br=player(2)
	local clones={}
	local template={Clone=function()
		local children={}
		for name,pos in geometry do
			children[name]={Name=name,Position=vec(pos[1],pos[2],pos[3]),IsA=function(_,k) return k=="BasePart" end}
		end
		children.Exit.Interact={Triggered=signal()}
		function children.Exit:WaitForChild(k) return self[k] end
		local attrs={}
		local model={children=children,destroyed=false}
		function model:GetDescendants() local list={}; for _,v in children do table.insert(list,v) end; return list end
		function model:WaitForChild(k) return assert(children[k],k) end
		function model:SetAttribute(k,v) attrs[k]=v end
		function model:GetAttribute(k) return attrs[k] end
		function model:Destroy() self.destroyed=true end
		table.insert(clones,model)
		return model
	end}
	local remote={OnServerEvent=signal()}
	local entry={Position=vec(-22,2,-66),Interact={Triggered=signal()}}
	function entry:WaitForChild(k) return self[k] end
	local academy={WaitForChild=function() return entry end}
	local world={WaitForChild=function() return {WaitForChild=function() return academy end} end}
	local shared={WaitForChild=function(_,name) if name=="DormAction" then return remote end; return name end}
	local heartbeat=signal()
	local records={}
	local pauseNext=false
	local store={UpdateAsync=function(_,key,transform)
		if pauseNext then pauseNext=false; coroutine.yield("storage paused") end
		local value=transform(records[key]); if value then records[key]=value end; return value
	end}
	local guid=0
	local closeCallback=nil
	local services={RunService={Heartbeat=heartbeat,IsStudio=function() return false end},DataStoreService={GetDataStore=function() return store end},HttpService={GenerateGUID=function() guid+=1; return `token_{guid}` end},Players=players,ReplicatedStorage={WaitForChild=function() return shared end},ServerStorage={WaitForChild=function() return {WaitForChild=function() return template end} end}}
	local env={game={GetService=function(_,name) return services[name] end,BindToClose=function(_,f) closeCallback=f end},workspace=world,Vector3={new=vec,zero=vec(0,0,0)},CFrame={new=function(v) return v end,Angles=function() return vec(0,0,0) end},os={clock=function() return now end,time=function() return math.floor(now) end},task={spawn=function(f,...)
		local co=coroutine.create(f); local ok,err=coroutine.resume(co,...); assert(ok,err); return co
	end,wait=function() coroutine.yield("wait") end}}
	local start=loadService(env)
	start(); start()
	check(entry.Interact.Triggered:Count()==1,"start must not duplicate callbacks")
	local function enter(p,root) now+=1; root.Position=entry.Position; entry.Interact.Triggered:Fire(p) end
	local function send(p,action) now+=1; remote.OnServerEvent:Fire(p,action) end
	enter(a,ar); enter(b,br)
	check(#clones==2 and a:GetAttribute("InDorm") and b:GetAttribute("InDorm"),"two owners enter")
	check(ar.Position.Z~=br.Position.Z,"rooms are separated")
	check(clones[1]:GetAttribute("OwnerUserId")==1 and clones[2]:GetAttribute("OwnerUserId")==2,"owner metadata")
	for _,room in clones do check(room.Name=="PH_Dorm_"..room:GetAttribute("OwnerUserId") and room:GetAttribute("IsPlaceholder")==true and room:GetAttribute("PlaceholderId")=="PH-DOR-001","room placeholder metadata") end
	send(a,"Place")
	check(clones[1].children.PH_Bench.Transparency==0,"owner places")
	check(clones[2].children.PH_Bench.Transparency==1,"other furniture untouched")
	now+=1; remote.OnServerEvent:Fire(a,"Commit",{x=0,z=0,rotation=0,placed=true})
	check(a:GetAttribute("Dorm_x")==0 and a:GetAttribute("DormRevision")>=2,"commit publishes authoritative state")
	now+=1; remote.OnServerEvent:Fire(a,"Commit",{x=12,z=0,rotation=0,placed=true})
	check(a:GetAttribute("Dorm_x")==0,"out-of-bounds commit rejected")
	now+=1; remote.OnServerEvent:Fire(a,"Commit",{x=0/0,z=0,rotation=0,placed=true})
	check(a:GetAttribute("Dorm_x")==0,"non-finite commit rejected")
	send(a,"Right")
	local saved=clones[1].children.PH_Bench.CFrame
	check(saved.X==-1198,"move in owner room")
	remote.OnServerEvent:Fire(a,"Right")
	check(clones[1].children.PH_Bench.CFrame==saved,"throttle blocks immediate repeat")
	ar.Position=br.Position
	send(a,"Store")
	check(clones[1].children.PH_Bench.Transparency==0 and clones[2].children.PH_Bench.Transparency==1,"cross-room edits denied")
	send(b,{owner=1,action="Place"})
	check(clones[2].children.PH_Bench.Transparency==1,"forged payload denied")
	enter(a,ar)
	a:SetAttribute("ProgressReady",false); send(a,"Store")
	check(clones[1].children.PH_Bench.Transparency==0,"unready cannot edit")
	a:SetAttribute("ProgressReady",true); ah.Health=0; send(a,"Store")
	check(clones[1].children.PH_Bench.Transparency==0,"dead cannot edit")
	a.CharacterRemoving:Fire(); ah.Health=100
	check(not a:GetAttribute("InDorm") and not clones[1].destroyed,"death leaves room saved in session")
	enter(a,ar)
	check(#clones==2 and clones[1].children.PH_Bench.CFrame==saved,"reentry restores room")
	ar.Position=clones[1].children.Exit.Position; now+=1
	clones[1].children.Exit.Interact.Triggered:Fire(a)
	check(not a:GetAttribute("InDorm") and ar.Position.X==-22,"exit returns to school")
	send(a,"Store")
	check(clones[1].children.PH_Bench.Transparency==0,"outside cannot edit")
	a:SetAttribute("DungeonState","Puzzle"); enter(a,ar)
	check(not a:GetAttribute("InDorm"),"active dungeon blocks entry")
	players.PlayerRemoving:Fire(a)
	check(clones[1].destroyed and not clones[2].destroyed,"removal cleans only owner room")
	local c,cr=player(3); players.PlayerAdded:Fire(c); enter(c,cr)
	check(cr.Position.Z==90,"freed slot reused")
	check(#clones==3 and clones[3].children.PH_Bench.Transparency==1,"new owner receives empty room")
	if persistent then
		check(records.room_1 and records.room_1.Furniture.x==2 and records.room_1.Lease==nil,"departure saved actual repository and released lease")
		local d,dr=player(1); players.PlayerAdded:Fire(d); enter(d,dr)
		check(clones[4].children.PH_Bench.Transparency==0 and clones[4].children.PH_Bench.CFrame.X==-1198,"rejoin loads furniture through full stack")
		check(records.room_1.Lease~=nil,"rejoin takes fresh lease")
		now+=30; heartbeat:Fire(30)
		check(records.room_1.Lease.Expires==math.floor(now)+120,"runtime heartbeat renews lease")
		send(d,"Right")
		local latest=clones[4].children.PH_Bench.CFrame.X
		local e,er=player(9); players.PlayerAdded:Fire(e)
		now+=1; er.Position=entry.Position; pauseNext=true
		local loading=coroutine.create(function() entry.Interact.Triggered:Fire(e) end)
		check(coroutine.resume(loading) and coroutine.status(loading)=="suspended","load yields in storage")
		e.Parent=nil
		local removing=coroutine.create(function() players.PlayerRemoving:Fire(e) end)
		check(coroutine.resume(removing) and coroutine.status(removing)=="suspended","close waits for load")
		check(coroutine.resume(loading) and coroutine.status(loading)=="dead","pending load completes safely")
		check(coroutine.resume(removing) and coroutine.status(removing)=="dead","close releases completed load")
		check(#clones==4 and records.room_9.Lease==nil,"departed loader gets no room and no retained lease")
		check(type(closeCallback)=="function","shutdown callback registered")
		closeCallback()
		check(records.room_1.Lease==nil and records.room_1.Furniture.x==4,"shutdown flushes latest furniture and releases lock")
		send(d,"Right")
		check(clones[4].children.PH_Bench.CFrame.X==latest,"shutdown rejects new edits")
	end
	print(`PASS: {n} dorm service flow checks ({if persistent then "full persistence stack" else "two-player API doubles"})`)
end
