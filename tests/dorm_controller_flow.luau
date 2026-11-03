return function(loadController, v2)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local function signal()
		local handlers={}
		return {Connect=function(_,f)
			local item={active=true,f=f}; table.insert(handlers,item)
			return {Disconnect=function() item.active=false end}
		end,Fire=function(_,...) for _,item in handlers do if item.active then item.f(...) end end end}
	end
	local mt={}
	local function vec(x,y,z) return setmetatable({X=x,Y=y,Z=z,kind="Vector3"},mt) end
	mt.__add=function(a,b) return vec(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
	mt.__mul=function(a,_) return a end
	local objects={}
	local function instance(class)
		local o={ClassName=class,Activated=signal(),Destroying=signal(),destroyed=false,attributes={}}
		function o:SetAttribute(k,v) self.attributes[k]=v end
		function o:Destroy() self.destroyed=true; self.Destroying:Fire() end
		table.insert(objects,o); return o
	end
	local attrs={InDorm=true,DormCenter=vec(-200,0,80),Dorm_x=0,Dorm_z=0,Dorm_rotation=0,Dorm_placed=false,DormRevision=1,DormSelectedId="bench",DormCatalogId="Bench",DormItemCount=2}
	local signals={}
	local player={GetAttribute=function(_,k) return attrs[k] end,GetAttributeChangedSignal=function(_,k) if not signals[k] then signals[k]=signal() end; return signals[k] end}
	local function set(k,v) attrs[k]=v; if signals[k] then signals[k]:Fire() end end
	local now=10
	local requests={}
	local remote={FireServer=function(_,...) table.insert(requests,{...}) end}
	local shared={WaitForChild=function(_,name) if name=="DormAction" then return remote end; return name end}
	local gui=instance("ScreenGui")
	local env={game={GetService=function() return {WaitForChild=function() return shared end} end},workspace={},
		Instance={new=instance},Vector3={new=vec},CFrame={new=function(v) return v end,Angles=function() return vec(0,0,0) end},
		Vector2={new=function(...) return {...} end},UDim2={new=function(...) return {...} end},Color3={fromRGB=function(...) return {...} end},
		typeof=function(v) return if type(v)=="table" and v.kind=="Vector3" then "Vector3" else type(v) end,
		os={clock=function() return now end}}
	loadController(env)(player,gui)
	local function find(key,value)
		for _,o in objects do if not o.destroyed and o[key]==value then return o end end
		error(`missing {key}: {value}`)
	end
	local function click(text) now+=0.3; find("Text",text).Activated:Fire() end
	local frame=find("Name","PH_DormControls")
	local ghost=find("Name","PH_FurniturePreview")
	check(frame.Visible and ghost.Transparency==1,"stored initial furniture hides ghost")
	for _,o in {frame,ghost} do check(o.attributes.IsPlaceholder==true and o.attributes.PlaceholderId=="PH-DOR-001","placeholder metadata on "..o.Name) end
	click("ขวา"); click("หมุน")
	check(#requests==0,"draft controls never send remote")
	check(ghost.CFrame.X==-198 and ghost.Transparency==0.55,"draft updates ghost")
	click("ยืนยัน")
	check(#requests==1 and requests[1][1]=="Commit","confirm sends exactly one commit")
	check(requests[1][2].x==2 and requests[1][2].rotation==90 and requests[1][2].placed,"commit contains draft snapshot")
	find("Text","ยืนยัน").Activated:Fire()
	check(#requests==1,"throttle blocks duplicate click")
	click("ซ้าย")
	check(requests[1][2].x==2,"future edits do not mutate sent snapshot")
	click("ยกเลิก")
	check(ghost.CFrame.X==-200 and ghost.Transparency==1 and #requests==1,"cancel restores server state without sending")
	for _=1,7 do click("ขวา") end
	click("ยืนยัน")
	check(#requests==1,"invalid footprint never commits")
	local label=find("ClassName","TextLabel")
	check(string.find(label.Text,"วางไม่ได้",1,true)~=nil,"invalid placement has text feedback")
	click("ยกเลิก"); click("เก็บ")
	check(#requests==2 and requests[2][1]=="Store","store is explicit server operation")
	set("Dorm_x",4); set("Dorm_placed",true); set("DormRevision",2)
	check(ghost.CFrame.X==-196 and ghost.Transparency==0.55,"server revision resets draft")
	if v2 then
		check(requests[1][2].Id=="bench","commit uses selected ID")
		click("ชิ้นถัดไป")
		check(requests[#requests][1]=="Next","selection request is explicit")
		set("DormSelectedId","stool"); set("DormCatalogId","Stool"); set("Dorm_x",6); set("DormRevision",3)
		check(ghost.Size.X==2 and ghost.Size.Z==2,"preview uses stool dimensions")
		click("ยืนยัน")
		check(requests[#requests][2].Id=="stool","commit targets newly selected ID")
	end
	set("InDorm",false)
	check(not frame.Visible and ghost.destroyed,"exit destroys preview")
	local count=#requests
	click("ยืนยัน")
	check(#requests==count,"hidden controls cannot send")
	set("InDorm",true)
	local newGhost=find("Name","PH_FurniturePreview")
	check(newGhost~=ghost and newGhost.attributes.PlaceholderId=="PH-DOR-001","reenter creates one fresh tagged preview")
	gui:Destroy()
	check(newGhost.destroyed,"HUD destruction cleans preview")
	count=#requests
	click("ขวา"); click("ยืนยัน"); set("InDorm",false); set("InDorm",true)
	check(#requests==count,"disposed controller sends nothing")
	local alive=0
	for _,o in objects do if o.Name=="PH_FurniturePreview" and not o.destroyed then alive+=1 end end
	check(alive==0,"disposed attribute events do not recreate preview")
	print(`PASS: {n} {if v2 then "v2 " else ""}dorm controller flow checks (Instance/event doubles)`)
end
