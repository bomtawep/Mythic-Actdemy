--!strict
local Guard=require(script.Parent:WaitForChild("ShieldGuard"))
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local shared=game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Rules=require(shared:WaitForChild("ShieldRules"))
local remote=shared:WaitForChild("ShieldAction") :: RemoteEvent
local started=false
return function()
	if started then return end; started=true
	local station=workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy"):WaitForChild("ShieldLesson") :: BasePart
	local sessions: {[Player]: any}={}
	local last: {[Player]: number}={}
	local function stop(p: Player,message: string)
		sessions[p]=nil; p:SetAttribute("ShieldTrialActive",false); p:SetAttribute("LessonHint",message)
	end
	local function eligible(p: Player,range: number): Humanoid?
		local char=p.Character
		local root=if char then char:FindFirstChild("HumanoidRootPart") else nil
		local humanoid=if char then char:FindFirstChildOfClass("Humanoid") else nil
		if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 or (root.Position-station.Position).Magnitude>range then return nil end
		if p:GetAttribute("ProgressReady")~=true or p:GetAttribute("LessonStage")~=3 or p:GetAttribute("LightCompleted")~=true or p:GetAttribute("InDorm")==true or (p:GetAttribute("DungeonState") or "Idle")~="Idle" or (p:GetAttribute("LevitationStation") or "")~="" or p:GetAttribute("LightTrialActive")==true or p:GetAttribute("LightExploreActive")==true then return nil end
		return humanoid
	end
	local function initialize(p: Player)
		-- Progress may have restored a saved pass before this runs; keep it.
		p:SetAttribute("ShieldTrialActive",false); p:SetAttribute("ShieldUnlocked",false); if p:GetAttribute("ShieldPassed")~=true then p:SetAttribute("ShieldPassed",false) end
		p.CharacterRemoving:Connect(function() if sessions[p] then stop(p,"หยุดฝึกคุ้มกันแล้ว กลับแท่นเพื่อเริ่มใหม่ได้") end end)
	end
	Players.PlayerAdded:Connect(initialize)
	for _,p in Players:GetPlayers() do initialize(p) end
	Players.PlayerRemoving:Connect(function(p) sessions[p]=nil; last[p]=nil end)
	local prompt=station:WaitForChild("Interact") :: ProximityPrompt
	prompt.Triggered:Connect(function(p)
		if not eligible(p,15) or sessions[p] then return end
		local now=workspace:GetServerTimeNow()
		if now-(last[p] or -math.huge)<0.3 then return end; last[p]=now
		local session={strike=now+Rules.FirstWarning,cast=-math.huge,attempts=0,blocks=0}
		sessions[p]=session
		p:SetAttribute("ShieldUnlocked",true); p:SetAttribute("ShieldStrikeAt",session.strike)
		p:SetAttribute("ShieldAttempts",0); p:SetAttribute("ShieldBlocks",0)
		p:SetAttribute("ShieldFeedback","กด Q หรือปุ่มคุ้มกันก่อนโจมตีไม่เกิน 0.6 วินาที")
		p:SetAttribute("ShieldTrialActive",true)
	end)
	remote.OnServerEvent:Connect(function(p: Player,action: unknown)
		local now=workspace:GetServerTimeNow()
		if now-(last[p] or -math.huge)<0.15 then return end; last[p]=now
		local s=sessions[p]
		if action~="Cast" then return end
		if not s then Guard.Cast(p,now); return end
		if not eligible(p,22) then return end
		if now>=s.strike or now-s.cast<Rules.Cooldown then return end
		s.cast=now; p:SetAttribute("ShieldUntil",now+Rules.Window)
	end)
	local elapsed=0
	RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt; if elapsed<0.05 then return end; elapsed=0
		local now=workspace:GetServerTimeNow()
		for p,s in sessions do
			local humanoid=eligible(p,22)
			if not humanoid then stop(p,"หยุดฝึกคุ้มกันแล้ว กลับแท่นเพื่อเริ่มใหม่ได้"); continue end
			if now<s.strike then continue end
			local blocked=Rules.blocked(s.cast,s.strike)
			s.attempts+=1
			if blocked then s.blocks+=1 else humanoid:TakeDamage(Rules.Damage) end
			p:SetAttribute("ShieldAttempts",s.attempts); p:SetAttribute("ShieldBlocks",s.blocks)
			p:SetAttribute("ShieldFeedback",if blocked then "ป้องกันสำเร็จ" else "พลาดจังหวะ • เสียพลังชีวิต 10")
			local result=Rules.result(s.blocks,s.attempts)
			if result=="Continue" then
				s.strike=now+Rules.Interval; s.cast=-math.huge; p:SetAttribute("ShieldStrikeAt",s.strike)
			else
				if result=="Passed" then p:SetAttribute("ShieldPassed",true) end
				stop(p,if result=="Passed" then "ผ่านม่านคุ้มกันแล้ว! บันทึกว่าเรียนเวทนี้แล้ว" else "ยังไม่ผ่านม่านคุ้มกัน กลับแท่นลองใหม่ได้ ต้องกันได้ 2 จาก 3 ครั้ง")
			end
		end
	end)
end
