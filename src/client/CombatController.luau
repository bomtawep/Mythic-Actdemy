--!strict
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Rules = require(shared:WaitForChild("CombatRules"))
local Scope = require(script.Parent:WaitForChild("ControllerScope"))
local KeyHint = require(script.Parent:WaitForChild("KeyHint"))
local Input = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
return function(player: Player, gui: ScreenGui)
	local scope = Scope.new(function(err) warn(err) end)
	local remote = shared:WaitForChild("CombatAction") :: RemoteEvent
	local shieldRemote = shared:WaitForChild("ShieldAction") :: RemoteEvent
	gui:SetAttribute("CombatHUDMounted", true)
	local frame = Instance.new("Frame")
	frame.Name = "PH_CombatControls"
	frame:SetAttribute("IsPlaceholder", true)
	frame:SetAttribute("PlaceholderId", "PH-UI-001")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 130)
	frame.Size = UDim2.new(0.85, 0, 0, 110)
	frame.BackgroundColor3 = Color3.fromRGB(27, 33, 43)
	frame.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(520, 110)
	limit.Parent = frame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 62)
	label.Position = UDim2.fromOffset(6, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(245, 240, 225)
	label.TextSize = 16
	label.TextWrapped = true
	label.TextScaled = true
	local labelSize = Instance.new("UITextSizeConstraint")
	labelSize.MinTextSize = 12
	labelSize.MaxTextSize = 16
	labelSize.Parent = label
	label.Parent = frame
	local button = Instance.new("TextButton")
	button.Position = UDim2.fromOffset(6, 64)
	button.Size = UDim2.new(0.5, -9, 0, 42)
	button.TextSize = 18
	button.Parent = frame
	local shield = Instance.new("TextButton")
	shield.Position = UDim2.new(0.5, 3, 0, 64)
	shield.Size = button.Size
	shield.TextSize = 18
	shield.Text = KeyHint("ม่านคุ้มกัน", "Q")
	shield.Parent = frame
	for _, control in {button, shield} do
		control.TextWrapped = true
		control.TextScaled = true
		local textSize = Instance.new("UITextSizeConstraint")
		textSize.MinTextSize = 12
		textSize.MaxTextSize = 18
		textSize.Parent = control
	end
	local function active(): boolean
		return player:GetAttribute("ProgressReady") == true and player:GetAttribute("DungeonState") == "Encounter"
			and player:GetAttribute("DungeonPaused") ~= true and player:GetAttribute("EncounterCleared") ~= true
			and (player:GetAttribute("LevitationStation") or "") == ""
	end
	local last = -math.huge
	local function cast()
		if not active() or player:GetAttribute("ShieldPassed") ~= true or os.clock() - last < 0.2 then return end
		last = os.clock()
		remote:FireServer("Cast")
	end
	scope.connect(button.Activated, cast)
	local lastShield = -math.huge
	scope.connect(shield.Activated, function()
		if not active() or player:GetAttribute("ShieldPassed") ~= true or os.clock() - lastShield < 0.2 then return end
		lastShield = os.clock()
		shieldRemote:FireServer("Cast")
	end)
	scope.connect(Input.InputBegan, function(input, processed)
		if not processed and not Input:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.C then cast() end
	end)
	local elapsed = 0
	scope.connect(RunService.RenderStepped, function(dt)
		elapsed += dt
		if elapsed < 0.1 then return end
		elapsed = 0
		frame.Visible = active()
		if not frame.Visible then return end
		local learned = player:GetAttribute("ShieldPassed") == true
		local remaining = math.max(0, (player:GetAttribute("CombatReadyAt") or 0) - workspace:GetServerTimeNow())
		button.Text = if not learned then "ยังไม่เรียนม่านคุ้มกัน" elseif remaining > 0 then `ร่ายใหม่ใน {string.format("%.1f", remaining)} วิ` else KeyHint("คลื่นเวท → ผู้เฝ้า", "C")
		shield.Active = learned
		shield.AutoButtonColor = learned
		button.Active = learned and remaining == 0
		button.AutoButtonColor = button.Active
		local defense = player:GetAttribute("ShieldCombatFeedback") or "หลบแนวโจมตี หรือกางม่านคุ้มกันให้ตรงจังหวะ"
		label.Text = `ผู้เฝ้า {player:GetAttribute("SentinelHealth") or Rules.MaxHealth}/{Rules.MaxHealth} • ระยะ 24 studs\n{player:GetAttribute("CombatFeedback") or "โจมตี 4 ครั้ง หรือใช้วิธีโล่/แท่นควบคุมเดิมได้"}\n{defense}`
	end)
	frame.Visible = false
	scope.add(function() gui:SetAttribute("CombatHUDMounted", nil); frame:Destroy() end)
	scope.connect(gui.Destroying, function() scope.dispose() end)
end
