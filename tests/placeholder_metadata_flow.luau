-- Pet/Encounter/Levitation controllers tag every PH_ object they create with its ASSET_TRACKER id.
return function(loadControllers)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local function signal()
		local handlers={}
		local s={}
		function s:Connect(f)
			local item={active=true,f=f}; table.insert(handlers,item)
			return {Disconnect=function() item.active=false end}
		end
		function s:Once(f)
			local connection
			connection=self:Connect(function(...) connection:Disconnect(); f(...) end)
			return connection
		end
		function s:Fire(...) for _,h in handlers do if h.active then h.f(...) end end end
		return s
	end
	local cfmt,pmt={},{}
	pmt.__sub=function(a,b) local d={X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z}; d.Magnitude=math.sqrt(d.X*d.X+d.Y*d.Y+d.Z*d.Z); return d end
	local function cframe(x,y,z) return setmetatable({Position=setmetatable({X=x or 0,Y=y or 0,Z=z or 0},pmt)},cfmt) end
	cfmt.__index={Lerp=function(a,b,t) local p,q=a.Position,b.Position; return cframe(p.X+(q.X-p.X)*t,p.Y+(q.Y-p.Y)*t,p.Z+(q.Z-p.Z)*t) end}
	cfmt.__mul=function(a,b) return cframe(a.Position.X+b.Position.X,a.Position.Y+b.Position.Y,a.Position.Z+b.Position.Z) end
	local function vec(x,y,z) return {X=x,Y=y,Z=z} end
	local objects={}
	local function instance(class)
		local o={ClassName=class,Activated=signal(),Destroying=signal(),destroyed=false,attributes={}}
		function o:SetAttribute(k,v) self.attributes[k]=v end
		function o:IsA(k) return k=="BasePart" and (self.ClassName=="Part") end
		function o:GetPivot() return self.pivot or cframe() end
		function o:PivotTo(cf) self.pivot=cf end
		function o:Destroy() if not self.destroyed then self.destroyed=true; self.Destroying:Fire() end end
		table.insert(objects,o); return o
	end
	local attrs={ProgressReady=true,LessonStage=3,DungeonState="Idle",DungeonPaused=false,LevitationStation="",PetEquipped=false}
	local signals={}
	local root={CFrame=cframe(10,3,10),IsA=function(_,k) return k=="BasePart" end}
	local character={FindFirstChild=function(_,k) return if k=="HumanoidRootPart" then root else nil end,FindFirstChildOfClass=function(_,k) return if k=="Humanoid" then {Health=100} else nil end}
	local player={UserId=7,Character=character,GetAttribute=function(_,k) return attrs[k] end,GetAttributeChangedSignal=function(_,k) if not signals[k] then signals[k]=signal() end; return signals[k] end}
	local function set(k,v) attrs[k]=v; if signals[k] then signals[k]:Fire() end end
	local render=signal()
	local remote={FireServer=function() end}
	local scene={}
	for _,name in {"PH_LessonCrystal","PH_PuzzleCrystal","PH_DungeonPuzzleCrystal","PH_SentinelControlCrystal"} do
		local crystal={Name=name,Position=vec(0,6,0),LocalTransparencyModifier=0}
		function crystal:IsA(k) return k=="BasePart" end
		function crystal:Clone() local copy=instance("Part"); copy.Position=self.Position; return copy end
		scene[name]=crystal
	end
	local sentinel={Name="PH_TrainingSentinel",Position=vec(0,3,40),LocalTransparencyModifier=0}
	scene.PH_DungeonCaster={Name="PH_DungeonCaster",Position=vec(0,3,-46),LocalTransparencyModifier=0}
	scene.PH_DungeonShade={Name="PH_DungeonShade",Position=vec(0,2,-33),LocalTransparencyModifier=0}
	local academy={ChildAdded=signal(),FindFirstChild=function(_,k) return scene[k] end,WaitForChild=function(_,k) return if k=="PH_TrainingSentinel" then sentinel else scene[k] end}
	local world={WaitForChild=function() return {WaitForChild=function() return academy end} end}
	local shared={WaitForChild=function(_,k) return if k=="PetAction" or k=="LevitationAction" then remote else k end}
	local services={
		Players={PlayerRemoving=signal(),GetPlayers=function() return {player} end},
		RunService={RenderStepped=render},
		UserInputService={InputBegan=signal(),GetFocusedTextBox=function() return nil end,KeyboardEnabled=false},
		TweenService={Create=function() return {Play=function() end,Cancel=function() end} end},
		ReplicatedStorage={WaitForChild=function() return shared end},
	}
	local function values(...) return {...} end
	local env={game={GetService=function(_,name) return assert(services[name],name) end},workspace=world,os={clock=function() return 10 end},
		Instance={new=instance},Vector2={new=values},Vector3={new=vec,zero=vec(0,0,0)},UDim2={new=values,fromOffset=values,fromScale=values},
		Color3={fromRGB=values},CFrame={new=cframe},TweenInfo={new=values},
		Enum={PartType={Ball="Ball",Block="Block"},KeyCode={P="P",R="R",F="F",G="G",X="X"}}}
	local pet,encounter,levitation=loadControllers(env)
	local gui=instance("ScreenGui")
	pet(player,gui); encounter(player,gui); levitation(player,gui)

	local function live(name) for _,o in objects do if o.Name==name and not o.destroyed then return o end end; return nil end
	for station,id in {Lesson="PH-ACA-002",Puzzle="PH-EXP-001",DungeonPuzzle="PH-DUN-002",SentinelControl="PH-DUN-001"} do
		set("LevitationStation",station)
		for _,name in {"PH_PersonalPracticeCrystal","PH_PracticeTarget"} do
			local o=live(name)
			check(o~=nil and o.attributes.IsPlaceholder==true and o.attributes.PlaceholderId==id,name.." tagged for "..station)
		end
	end
	set("LevitationStation","")
	check(live("PH_PersonalPracticeCrystal")==nil and live("PH_PracticeTarget")==nil,"leaving station clears practice visuals")
	set("PetEquipped",true); render:Fire(0.016)
	local companion=live("PH_Companion_7")
	check(companion~=nil and companion.attributes.PlaceholderId=="PH-PET-001" and companion.attributes.OwnerUserId==7,"companion tagged with owner")
	local tagLabel; for _,o in objects do if o.Name=="Label" and o.Parent and o.Parent.Name=="PH_CompanionName" then tagLabel=o end end
	check(tagLabel~=nil and string.find(tagLabel.Text,"ละอองหูใบ",1,true)~=nil and string.find(tagLabel.Text,"รู้จัก",1,true)~=nil,"name tag shows name, species and bond stage")
	set("PetNameIndex",3); set("PetBondPlay",true); set("PetBondDorm",true); render:Fire(0.016)
	check(string.find(tagLabel.Text,"คุ้นเคย",1,true)~=nil,"name tag follows bond")
	local earCount=0; for _,o in objects do if (o.Name=="EarLeft" or o.Name=="EarRight") and o.Parent==companion and o.Shape=="Block" then earCount+=1 end end
	check(earCount==2,"leaf-ear companion has two flat ears (a Ball shape renders them as dots)")
	check(live("PH_PetPlay").Visible and live("PH_PetRename").Visible,"play and rename show with the companion out")
	check(live("PH_PetToggle").Text=="เก็บคู่หู" and live("PH_LevitationControls")~=nil,"touch-only devices get labels without keyboard shortcuts")
	check(live("PH_PetPlay").Position[4]<=184 and live("PH_PetRename").Position[4]<=184,"companion buttons stay in the top-right grid, clear of the touch jump button")

	-- Caster lane marker follows the server's locked lane; the shade hides once revealed.
	local lane=live("PH_CasterLaneWarning")
	check(lane~=nil and lane.Transparency==1,"lane marker hidden until the caster aims")
	set("CasterLane",12); set("CasterPhase","Warning")
	check(lane.Transparency<1 and lane.Position.X==12,"lane marker shows the locked lane")
	set("CasterPhase","Cooldown")
	check(lane.Transparency==1,"lane marker clears after the volley")
	set("ShadeRevealed",true)
	check(scene.PH_DungeonShade.LocalTransparencyModifier==1,"revealed shade is hidden")
	local expectedIds={PH_PetToggle="PH-PET-001",PH_Companion_7="PH-PET-001",PH_PetPlay="PH-PET-001",PH_PetRename="PH-PET-001",PH_CompanionName="PH-PET-001",PH_PersonalAttackWarning="PH-DUN-001",PH_SentinelWarning="PH-DUN-001",PH_CasterLaneWarning="PH-DUN-001",PH_LevitationControls="PH-UI-001"}
	local tagged=0
	for _,o in objects do
		if type(o.Name)=="string" and string.sub(o.Name,1,3)=="PH_" and expectedIds[o.Name] then
			check(o.attributes.IsPlaceholder==true and o.attributes.PlaceholderId==expectedIds[o.Name],"placeholder attributes on "..o.Name)
			tagged+=1
		end
	end
	check(tagged==9,"pet/encounter/levitation fixed placeholders all seen")
	gui.Destroying:Fire()
	check(companion.destroyed and live("PH_PersonalAttackWarning")==nil and live("PH_SentinelWarning")==nil and live("PH_CasterLaneWarning")==nil,"HUD destruction cleans tagged visuals")
	check(scene.PH_DungeonShade.LocalTransparencyModifier==0,"cleanup restores the shade")
	print(`PASS: {n} pet/encounter/levitation placeholder metadata checks (Instance doubles)`)
end
