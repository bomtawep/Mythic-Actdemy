--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Rules=require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("LightRules"))
local Factory={}
function Factory.new(config: any)
	local started=false
	return function()
		if started then return end
		started=true
		local academy=workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
		local lesson=academy:WaitForChild(config.StartName) :: BasePart
		local last: {[Player]: number}={}
		local function initialize(p: Player)
			p:SetAttribute(config.Attributes.Unlocked,false); p:SetAttribute(config.Attributes.Bits,0)
			-- Progress may have restored a saved pass before this runs; keep it.
			p:SetAttribute(config.Attributes.Active,false); if p:GetAttribute(config.Attributes.Completed)~=true then p:SetAttribute(config.Attributes.Completed,false) end
			p.CharacterRemoving:Connect(function() p:SetAttribute(config.Attributes.Active,false) end)
		end
		Players.PlayerAdded:Connect(initialize)
		for _,p in Players:GetPlayers() do initialize(p) end
		Players.PlayerRemoving:Connect(function(p) last[p]=nil end)
		local function eligible(p: Player,station: BasePart,range: number): boolean
			if config.RequiredAttribute and p:GetAttribute(config.RequiredAttribute)~=true then return false end
			local character=p.Character
			local root=if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid=if character then character:FindFirstChildOfClass("Humanoid") else nil
			if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 or (root.Position-station.Position).Magnitude>range then return false end
			if p:GetAttribute(config.BlockedBy)==true or p:GetAttribute("ProgressReady")~=true or p:GetAttribute("LessonStage")~=3 or p:GetAttribute("InDorm")==true or (p:GetAttribute("DungeonState") or "Idle")~="Idle" or (p:GetAttribute("LevitationStation") or "")~="" then return false end
			return true
		end
		local function connect(name: string, callback: (Player)->())
			local station=academy:WaitForChild(name) :: BasePart
			local prompt=station:WaitForChild("Interact") :: ProximityPrompt
			prompt.Triggered:Connect(function(p)
				if not eligible(p,station,15) then return end
				if os.clock()-(last[p] or -math.huge)<0.4 then return end
				last[p]=os.clock()
				callback(p)
			end)
		end
		connect(config.StartName,function(p)
			p:SetAttribute(config.Attributes.Unlocked,true); p:SetAttribute(config.Attributes.Bits,0)
			p:SetAttribute(config.Attributes.Hint,"ร่ายที่อักขระ: I เปลี่ยน 1+2 • II เปลี่ยนทั้งสาม • III เปลี่ยน 2+3")
			p:SetAttribute(config.Attributes.Active,true)
		end)
		for index=1,3 do
			connect(`{config.RunePrefix}{index}`,function(p)
				if p:GetAttribute(config.Attributes.Active)~=true or p:GetAttribute(config.Attributes.Unlocked)~=true then return end
				local bits=Rules.cast(p:GetAttribute(config.Attributes.Bits),index)
				if bits==nil then return end
				p:SetAttribute(config.Attributes.Bits,bits)
				if bits==config.Target then
					p:SetAttribute(config.Attributes.Completed,true); p:SetAttribute(config.Attributes.Active,false)
					p:SetAttribute("LessonHint",config.SuccessHint)
				else p:SetAttribute(config.Attributes.Hint,"ยังไม่ตรงเป้า ลองสลับต่อ หรือกลับแท่นเริ่มใหม่ได้") end
			end)
		end
		local elapsed=0
		RunService.Heartbeat:Connect(function(dt)
			elapsed+=dt; if elapsed<0.25 then return end; elapsed=0
			for _,p in Players:GetPlayers() do
				if p:GetAttribute(config.Attributes.Active)==true then
					if not eligible(p,lesson,35) then p:SetAttribute(config.Attributes.Active,false) end
				end
			end
		end)
	end
end
return Factory
