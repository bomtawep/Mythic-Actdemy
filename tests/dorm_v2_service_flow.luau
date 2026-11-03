return function(loadService, geometry)
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
	local parts={}
	local template={Clone=function()
		local children={}
		for name,pos in geometry do
			children[name]={Name=name,Position=vec(pos[1],pos[2],pos[3]),IsA=function(_,k) return k=="BasePart" end}
		end
		function children.PH_Bench:Clone()
			local part={destroyed=false}
			function part:SetAttribute(k,v) self[k]=v end
			function part:Destroy() self.destroyed=true end
			table.insert(parts,part)
			return part
		end
		function children.PH_Bench:Destroy() self.destroyed=true end
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
	local records={
		room_1={Version=2,Items={{Id="bench",CatalogId="Bench",x=0,z=0,rotation=0,placed=true},{Id="stool",CatalogId="Stool",x=6,z=0,rotation=0,placed=true}}},
		room_2={Version=1,Furniture={x=-2,z=0,rotation=90,placed=true}},
	}
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
	local start=loadService(env); start(); start()
	check(entry.Interact.Triggered:Count()==1,"idempotent startup")
	local function enter(p,root) now+=1; root.Position=entry.Position; entry.Interact.Triggered:Fire(p) end
	local function send(p,action,payload) now+=1; remote.OnServerEvent:Fire(p,action,payload) end
	enter(a,ar); enter(b,br)
	check(#clones==2 and #parts==3,"spawn exactly loaded inventory")
	for _,room in clones do check(room.Name=="PH_Dorm_"..room:GetAttribute("OwnerUserId") and room:GetAttribute("IsPlaceholder")==true and room:GetAttribute("PlaceholderId")=="PH-DOR-001","room placeholder metadata") end
	for _,part in parts do check(string.sub(part.Name,1,13)=="PH_Furniture_" and part.IsPlaceholder==true and part.PlaceholderId=="PH-DOR-001","furniture placeholder metadata") end
	check(a:GetAttribute("DormItemCount")==2 and b:GetAttribute("DormItemCount")==1,"per-owner counts")
	check(b:GetAttribute("DormSelectedId")=="starter-bench-001" and records.room_2.Version==2,"legacy migration through full stack")
	check(a:GetAttribute("DormSelectedId")=="bench","first selected")
	send(a,"Next")
	check(a:GetAttribute("DormSelectedId")=="stool" and a:GetAttribute("DormCatalogId")=="Stool","next selects exact ID/catalog")
	local revision=a:GetAttribute("DormRevision")
	send(a,"Commit",{Id="bench",x=-4,z=0,rotation=0,placed=true})
	check(a:GetAttribute("DormRevision")==revision,"stale selected ID rejected")
	send(a,"Commit",{Id="stool",x=0,z=0,rotation=0,placed=true})
	check(a:GetAttribute("Dorm_x")==6,"overlap rejected")
	send(a,"Commit",{Id="stool",CatalogId="Bench",x=8,z=0,rotation=90,placed=true})
	check(a:GetAttribute("Dorm_x")==8 and a:GetAttribute("DormCatalogId")=="Stool","commit cannot swap catalog")
	check(parts[2].Size.X==2 and parts[2].CFrame.X==-1192,"stool dimensions and location from catalog")
	check(b:GetAttribute("Dorm_x")==-2,"other owner unchanged")
	ar.Position=br.Position; revision=a:GetAttribute("DormRevision")
	send(a,"Store")
	check(a:GetAttribute("DormRevision")==revision,"cross-room edits rejected")
	enter(a,ar); send(a,"Store")
	check(a:GetAttribute("Dorm_placed")==false,"store selected item only")
	check(parts[1].Transparency==0 and parts[2].Transparency==1,"other item remains visible")
	now+=30; heartbeat:Fire(30)
	check(records.room_1.Items[2].x==8 and records.room_1.Items[2].CatalogId=="Stool","flush stores exact inventory")
	a.Parent=nil; players.PlayerRemoving:Fire(a)
	check(records.room_1.Lease==nil and clones[1].destroyed,"departure saves/releases and clears room")
	local c,cr=player(1); players.PlayerAdded:Fire(c); enter(c,cr)
	check(c:GetAttribute("DormItemCount")==2,"rejoin keeps count without duplication")
	send(c,"Next")
	check(c:GetAttribute("Dorm_x")==8 and c:GetAttribute("Dorm_placed")==false,"rejoin restores selected placement")
	closeCallback()
	check(records.room_1.Lease==nil and records.room_2.Lease==nil,"shutdown releases both profiles")
	print(`PASS: {n} v2 full-stack room selection checks`)
end
