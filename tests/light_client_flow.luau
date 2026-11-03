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
	local objects={}
	local function instance(class)
		local o={ClassName=class,Activated=signal(),Destroying=signal(),destroyed=false,attributes={}}
		function o:SetAttribute(k,v) self.attributes[k]=v end
		function o:GetAttribute(k) return self.attributes[k] end
		function o:Destroy()
			if self.destroyed then return end
			self.Destroying:Fire(); self.destroyed=true
			for _,child in objects do if child.Parent==self then child:Destroy() end end
		end
		table.insert(objects,o); return o
	end
	local attrs={ProgressReady=true,LessonStage=3,DungeonState="Idle",LightUnlocked=false,LightBits=0,LightTrialActive=false,LightCompleted=false}
	local signals={}
	local player={GetAttribute=function(_,k) return attrs[k] end,GetAttributeChangedSignal=function(_,k) if not signals[k] then signals[k]=signal() end; return signals[k] end,WaitForChild=function() return {} end}
	local function set(k,v) attrs[k]=v; if signals[k] then signals[k]:Fire() end end
	local input=signal()
	local render=signal()
	local now=10
	local requests={}
	local remote={FireServer=function(_,action) table.insert(requests,action) end}
	local inputService={InputBegan=input,GetFocusedTextBox=function() return nil end,KeyboardEnabled=true}
	local runes={LightRune1={},LightRune2={},LightRune3={},ExploreRune1={},ExploreRune2={},ExploreRune3={}}
	local world={GetServerTimeNow=function() return now end,WaitForChild=function() return {WaitForChild=function() return {WaitForChild=function(_,name) return runes[name] end} end} end}
	local function values(...) return {...} end
	local env={game={GetService=function(_,name)
		if name=="UserInputService" then return inputService end
		if name=="RunService" then return {RenderStepped=render} end
		return {WaitForChild=function() return {WaitForChild=function(_,k) return if (k=="ShieldAction" or k=="CombatAction") then remote else k end} end}
	end},os={clock=function() return now end},workspace=world,Instance={new=instance},Vector2={new=values},Vector3={new=values},UDim={new=values},UDim2={new=values,fromOffset=values,fromScale=values},Color3={fromRGB=values},Enum={Font={Gotham="Gotham"},TextXAlignment={Left="Left"},TextYAlignment={Top="Top"},AutomaticSize={Y="Y"},SortOrder={LayoutOrder="LayoutOrder"},KeyCode={B="B",Q="Q",C="C"}}}
	local hud,light,journal,explore,shield,combat=loadControllers(env)
	local gui=hud(player); light(player,gui); journal(player,gui); explore(player,gui); shield(player,gui)
	local function find(name) for _,o in objects do if o.Name==name then return o end end; error(name) end
	local lamps,exploreLamps={},{}; for _,o in objects do if o.ClassName=="PointLight" then if o.Name=="PH_PersonalRuneLight" then table.insert(lamps,o) else table.insert(exploreLamps,o) end end end
	-- Every PH_ object these controllers create carries its ASSET_TRACKER id.
	local expectedIds={PH_LessonHUD="PH-UI-001",PH_StudentJournal="PH-UI-002",PH_JournalToggle="PH-UI-002",PH_ShieldControls="PH-ACA-004",
		PH_PersonalRuneLight="PH-ACA-003",PH_LightRuneStatus="PH-ACA-003",PH_ExploreRuneLight="PH-EXP-002",PH_ExploreRuneStatus="PH-EXP-002"}
	local tagged=0
	for _,o in objects do
		if type(o.Name)=="string" and string.sub(o.Name,1,3)=="PH_" then
			check(expectedIds[o.Name]~=nil,"unexpected placeholder "..o.Name)
			check(o.attributes.IsPlaceholder==true and o.attributes.PlaceholderId==expectedIds[o.Name],"placeholder attributes on "..o.Name)
			tagged+=1
		end
	end
	check(tagged==16,"all light/HUD/journal/shield placeholders tagged")
	local objective=find("Objective")
	check(find("PH_JournalToggle").Text=="สมุดนักเรียน [B]","keyboard devices show the shortcut")
	local entry=find("Entry6")
	check(#lamps==3 and not lamps[1].Enabled,"three initially disabled lights")
	check(string.find(entry.Text,"ยังไม่เรียน",1,true)~=nil,"journal begins unlearned")
	set("LightUnlocked",true); set("LightHint","ร่ายที่อักขระ"); set("LightTrialActive",true)
	check(string.find(objective.Text,"แสงนำทาง",1,true)~=nil,"HUD shows light objective")
	check(string.find(entry.Text,"ยังไม่ผ่าน",1,true)~=nil,"journal learned not completed")
	set("LightBits",5)
	check(lamps[1].Enabled and not lamps[2].Enabled and lamps[3].Enabled,"pattern matches 101")
	set("LightCompleted",true); set("LessonHint","ผ่านแสงนำทางแล้ว"); set("LightTrialActive",false)
	check(string.find(entry.Text,"ผ่านปริศนาแล้ว",1,true)~=nil,"journal completion")
	check(string.find(entry.Text,"จะบันทึกไว้หลังออกเกม",1,true)~=nil,"persistence notice")
	check(string.find(objective.Text,"ผ่านแสงนำทางแล้ว",1,true)~=nil,"completion feedback")
	set("LightExploreUnlocked",true); set("LightExploreBits",2); set("LightExploreActive",true)
	check(#exploreLamps==3 and not exploreLamps[1].Enabled and exploreLamps[2].Enabled and not exploreLamps[3].Enabled,"exploration pattern is independent")
	check(not lamps[1].Enabled and not lamps[3].Enabled,"other active puzzle hides lesson lights")
	check(string.find(objective.Text,"สวนอักขระ",1,true)~=nil,"exploration objective priority")
	set("LightDiscovery",true); set("LightExploreActive",false)
	check(string.find(find("Entry7").Text,"ค้นพบแล้ว",1,true)~=nil,"exploration journal updated")
	set("DungeonState","Puzzle")
	check(string.find(objective.Text,"ดันเจียน",1,true)~=nil,"dungeon HUD priority")
	check(not lamps[1].Enabled and not lamps[3].Enabled,"lights disabled in other activity")
	set("DungeonState","Idle"); set("InDorm",true)
	check(not lamps[1].Enabled,"lights disabled in dorm")
	set("InDorm",false); set("ProgressReady",false)
	check(not lamps[1].Enabled and string.find(entry.Text,"รอข้อมูล",1,true)~=nil,"unready hides claim and light")
	set("ProgressReady",true)
	check(lamps[1].Enabled,"context restoration shows last pattern")
	find("PH_JournalToggle").Activated:Fire()
	check(find("PH_StudentJournal").Visible,"journal opens")
	set("LevitationStation","Lesson")
	check(not find("PH_StudentJournal").Visible,"practice closes journal")
	set("LevitationStation",""); set("ShieldUnlocked",true); set("ShieldStrikeAt",12); set("ShieldTrialActive",true)
	render:Fire(0.1)
	check(find("PH_ShieldControls").Visible,"shield panel active")
	check(string.find(objective.Text,"ม่านคุ้มกัน",1,true)~=nil,"HUD shield priority")
	input:Fire({KeyCode="Q"},false)
	check(#requests==1 and requests[1]=="Cast","Q sends only Cast")
	input:Fire({KeyCode="Q"},false)
	check(#requests==1,"client shield throttle")
	now+=0.3; input:Fire({KeyCode="Q"},true)
	check(#requests==1,"processed input ignored")
	set("ShieldPassed",true); set("ShieldTrialActive",false); render:Fire(0.1)
	check(not find("PH_ShieldControls").Visible and string.find(find("Entry8").Text,"ผ่านการฝึกแล้ว",1,true)~=nil,"shield result in journal and panel hides")
	check(string.find(find("Entry10").Text,"4/5 หน้า • ขั้นรวบรวม",1,true)~=nil and find("Entry10").LayoutOrder<find("Entry9").LayoutOrder,"scroll entry sits above save status")
	set("DungeonCompleted",true)
	check(string.find(find("Entry10").Text,"5/5 หน้า • ขั้นเข้าใจ",1,true)~=nil,"finishing the dungeon completes the scroll in the journal")
	set("PetBondPlay",true); set("PetNameIndex",2)
	check(string.find(find("Entry11").Text,"ขั้นรู้จัก 1/4",1,true)~=nil and find("Entry11").LayoutOrder<find("Entry9").LayoutOrder,"companion entry follows bond above save status")
	set("DungeonState","Encounter"); set("EncounterPhase","Warning"); set("EncounterStrikeAt",now+1.5); render:Fire(0.1)
	check(find("PH_ShieldControls").Visible,"combat warning shows shield UI")
	now+=0.3; input:Fire({KeyCode="Q"},false)
	check(requests[#requests]=="Cast" and #requests==2,"Q casts in combat context")
	set("ProgressReady",false); render:Fire(0.1)
	check(not find("PH_ShieldControls").Visible,"unready context hides combat shield")
	set("ProgressReady",true)
	set("EncounterPhase","Rest"); render:Fire(0.1)
	check(not find("PH_ShieldControls").Visible,"combat rest hides shield UI")
	combat(player,gui); render:Fire(0.1)
	local combatFrame=find("PH_CombatControls")
	check(combatFrame.Visible and combatFrame.attributes.IsPlaceholder and combatFrame.attributes.PlaceholderId=="PH-UI-001","combat panel is mounted and tagged")
	set("EncounterPhase","Warning"); render:Fire(0.1)
	check(combatFrame.Visible and not find("PH_ShieldControls").Visible,"combined panel replaces duplicate combat shield panel")
	local before=#requests
	now+=1; input:Fire({KeyCode="C"},false)
	check(#requests==before+1,"C sends a combat cast")
	input:Fire({KeyCode="C"},false)
	check(#requests==before+1,"combat client throttles repeat input")
	now+=1; input:Fire({KeyCode="C"},true)
	check(#requests==before+1,"processed combat input ignored")
	local buttons={}
	for _,o in objects do if o.Parent==combatFrame and o.ClassName=="TextButton" then table.insert(buttons,o) end end
	check(#buttons==2,"touch has attack and shield buttons")
	buttons[2].Activated:Fire()
	check(#requests==before+2,"touch shield sends a cast")
	set("CombatReadyAt",now+1); render:Fire(0.1)
	check(not buttons[1].Active and string.find(buttons[1].Text,"ร่ายใหม่",1,true)~=nil,"cooldown is visible")
	set("DungeonPaused",true); render:Fire(0.1)
	check(not combatFrame.Visible,"paused combat hides controls")
	now+=1; input:Fire({KeyCode="C"},false)
	check(#requests==before+2,"paused combat cannot cast")
	set("DungeonPaused",false); set("ShieldPassed",false); render:Fire(0.1)
	check(not buttons[1].Active and not buttons[2].Active,"unlearned controls disabled")
	set("ShieldPassed",true)
	local sent=#requests
	gui:Destroy()
	check(lamps[1].destroyed and lamps[2].destroyed and lamps[3].destroyed,"HUD destroys light resources")
	check(exploreLamps[1].destroyed and exploreLamps[2].destroyed and exploreLamps[3].destroyed,"HUD destroys exploration resources")
	local count=#objects
	set("LightBits",0); set("LightUnlocked",false); set("LightTrialActive",true)
	check(#objects==count,"disposed attributes do not recreate resources")
	now+=1; input:Fire({KeyCode="Q"},false); input:Fire({KeyCode="C"},false); render:Fire(0.1)
	check(combatFrame.destroyed and gui:GetAttribute("CombatHUDMounted")==nil,"combat UI cleans up on disposal")
	check(#requests==sent,"disposed shield input cannot send")
	print(`PASS: {n} light/HUD/journal client flow checks`)
end
