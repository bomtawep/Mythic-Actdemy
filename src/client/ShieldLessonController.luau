--!strict
local Scope=require(script.Parent:WaitForChild("ControllerScope"))
local KeyHint=require(script.Parent:WaitForChild("KeyHint"))
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local remote=game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("ShieldAction") :: RemoteEvent
return function(player: Player,gui: ScreenGui)
	local scope=Scope.new(function(err) warn(err) end)
	local frame=Instance.new("Frame")
	frame.Name="PH_ShieldControls"; frame:SetAttribute("IsPlaceholder",true); frame:SetAttribute("PlaceholderId","PH-ACA-004")
	frame.AnchorPoint=Vector2.new(0.5,1); frame.Position=UDim2.new(0.5,0,1,-150); frame.Size=UDim2.new(0.9,0,0,112)
	frame.BackgroundColor3=Color3.fromRGB(27,33,43); frame.Parent=gui
	local max=Instance.new("UISizeConstraint"); max.MaxSize=Vector2.new(600,112); max.Parent=frame
	local label=Instance.new("TextLabel"); label.Size=UDim2.new(1,0,0,62); label.TextWrapped=true; label.TextSize=17; label.TextColor3=Color3.fromRGB(245,240,225); label.BackgroundTransparency=1; label.Parent=frame
	local button=Instance.new("TextButton"); button.Size=UDim2.new(1,-12,0,44); button.Position=UDim2.fromOffset(6,64); button.Text=KeyHint("ม่านคุ้มกัน","Q"); button.TextSize=18; button.Parent=frame
	local last=-math.huge
	local function combatContext(): boolean
		return player:GetAttribute("ProgressReady")==true and player:GetAttribute("LessonStage")==3 and player:GetAttribute("ShieldPassed")==true and player:GetAttribute("DungeonState")=="Encounter" and player:GetAttribute("DungeonPaused")~=true and player:GetAttribute("EncounterCleared")~=true and (player:GetAttribute("LevitationStation") or "")=="" and (player:GetAttribute("EncounterPhase")=="Warning" or player:GetAttribute("CasterPhase")=="Warning")
	end
	local function cast()
		if (player:GetAttribute("ShieldTrialActive")~=true and not combatContext()) or os.clock()-last<0.2 then return end
		last=os.clock(); remote:FireServer("Cast")
	end
	scope.connect(button.Activated,cast)
	scope.connect(UserInputService.InputBegan,function(input,processed)
		if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.Q then cast() end
	end)
	local elapsed=0
	scope.connect(RunService.RenderStepped,function(dt)
		elapsed+=dt; if elapsed<0.05 then return end; elapsed=0
		local training=player:GetAttribute("ShieldTrialActive")==true
		frame.Visible=training or (combatContext() and gui:GetAttribute("CombatHUDMounted")~=true)
		if not frame.Visible then return end
		local strike=if training then player:GetAttribute("ShieldStrikeAt") else player:GetAttribute("EncounterStrikeAt")
		local remaining=math.max(0,(strike or 0)-workspace:GetServerTimeNow())
		if not training then
			label.Text=`ผู้เฝ้าโจมตีใน {string.format("%.1f",remaining)} วินาที • กันก่อนโจมตี 0.6 วินาที\n{player:GetAttribute("ShieldCombatFeedback") or "เดินหลบหรือกด Q เพื่อคุ้มกัน"}`
			return
		end
		label.Text=`โจมตีใน {string.format("%.1f",remaining)} วินาที • กันได้ {player:GetAttribute("ShieldBlocks") or 0}/2\n{player:GetAttribute("ShieldFeedback") or "กดก่อนโจมตี 0.6 วินาที"}`
	end)
	frame.Visible=false
	scope.connect(gui.Destroying,function() scope.dispose() end)
end
