--!strict
return function(player: Player, gui: ScreenGui)
	local connections: {RBXScriptConnection} = {}
	local function connect(signal: any, callback: any)
		table.insert(connections, signal:Connect(callback))
	end
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local shared = ReplicatedStorage:WaitForChild("MythicAcademy")
	local remote = shared:WaitForChild("LevitationAction") :: RemoteEvent
	local Config = require(shared:WaitForChild("LevitationConfig"))
	local KeyHint = require(script.Parent:WaitForChild("KeyHint"))
	local academy = workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
	local controls = Instance.new("Frame")
	controls.Name = "PH_LevitationControls"
	controls:SetAttribute("IsPlaceholder", true)
	controls:SetAttribute("PlaceholderId", "PH-UI-001")
	controls.AnchorPoint = Vector2.new(0.5, 1)
	controls.Position = UDim2.new(0.5, 0, 1, -150)
	controls.Size = UDim2.new(0.92, 0, 0, 100)
	controls.BackgroundColor3 = Color3.fromRGB(27, 33, 43)
	controls.Visible = false
	controls.Parent = gui
	local maxSize = Instance.new("UISizeConstraint")
	maxSize.MaxSize = Vector2.new(560, 100)
	maxSize.Parent = controls
	local meter = Instance.new("TextLabel")
	meter.Size = UDim2.new(1, 0, 0, 40)
	meter.BackgroundTransparency = 1
	meter.TextColor3 = Color3.fromRGB(245, 240, 225)
	meter.TextSize = 18
	meter.Parent = controls

	local lastSent = -math.huge
	local function send(action: string)
		if not controls.Visible then return end
		local now = os.clock()
		if now - lastSent < Config.ActionInterval then return end
		lastSent = now
		remote:FireServer(action)
	end
	for index, entry in {{"Raise", KeyHint("ยก ↑", "R")}, {"Lower", KeyHint("ลด ↓", "F")}, {"Place", KeyHint("วาง", "G")}, {"Cancel", KeyHint("ยกเลิก", "X")}} do
		local button = Instance.new("TextButton")
		button.Name = entry[1]
		button.Position = UDim2.new((index - 1) / 4, 3, 0, 44)
		button.Size = UDim2.new(0.25, -6, 0, 50)
		button.Text = entry[2]
		button.TextSize = 15
		button.TextWrapped = true
		button.BackgroundColor3 = Color3.fromRGB(62, 73, 92)
		button.TextColor3 = Color3.fromRGB(245, 240, 225)
		button.Parent = controls
		connect(button.Activated, function() send(entry[1]) end)
	end
	connect(UserInputService.InputBegan, function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then return end
		local actions = {
			[Enum.KeyCode.R] = "Raise", [Enum.KeyCode.F] = "Lower",
			[Enum.KeyCode.G] = "Place", [Enum.KeyCode.X] = "Cancel",
		}
		local action = actions[input.KeyCode]
		if action then send(action) end
	end)

	local original: BasePart? = nil
	local crystal: BasePart? = nil
	local target: BasePart? = nil
	local tween: Tween? = nil
	local function clearVisuals()
		if tween then tween:Cancel(); tween = nil end
		if original then original.LocalTransparencyModifier = 0; original = nil end
		if crystal then crystal:Destroy(); crystal = nil end
		if target then target:Destroy(); target = nil end
	end
	local Lifetime = require(script.Parent:WaitForChild("VisualLifetime"))
	-- Practice visuals are shared by every station; tag them with that station's ASSET_TRACKER id.
	local placeholderIds = {Lesson = "PH-ACA-002", Puzzle = "PH-EXP-001", DungeonPuzzle = "PH-DUN-002", SentinelControl = "PH-DUN-001"}
	local visuals = Lifetime.new(function(name: string): boolean
		local found = academy:FindFirstChild(`PH_{name}Crystal`)
		if not found or not found:IsA("BasePart") then return false end
		original = found
		local source = original :: BasePart
		local copy = source:Clone()
		copy.Name = "PH_PersonalPracticeCrystal"
		copy:SetAttribute("IsPlaceholder", true)
		copy:SetAttribute("PlaceholderId", placeholderIds[name])
		copy.LocalTransparencyModifier = 0
		copy.CanCollide = false
		copy.CanTouch = false
		copy.CanQuery = false
		copy.Parent = workspace
		crystal = copy
		source.LocalTransparencyModifier = 1
		local frame = Instance.new("Part")
		frame.Name = "PH_PracticeTarget"
		frame:SetAttribute("IsPlaceholder", true)
		frame:SetAttribute("PlaceholderId", placeholderIds[name])
		frame.Anchored = true
		frame.CanCollide = false
		frame.CanTouch = false
		frame.CanQuery = false
		frame.Size = Vector3.new(3, 0.2, 3)
		frame.Color = Color3.fromRGB(235, 215, 130)
		frame.Transparency = 0.4
		frame.Parent = workspace
		target = frame
		return true
	end, clearVisuals)
	local function refreshPractice()
		local name = player:GetAttribute("LevitationStation")
		local active = name == "Lesson" or name == "Puzzle" or name == "DungeonPuzzle" or name == "SentinelControl"
		local available = visuals.select(if active then name :: string else "")
		controls.Visible = active
		if not available then
			meter.Text = "ยังไม่พบผลึก • กด X หรือยกเลิกเพื่อเริ่มใหม่"
			return
		end
		local height = player:GetAttribute("LevitationHeight") or Config.StartHeight
		local goal = player:GetAttribute("LevitationTarget") or Config.LessonTarget
		meter.Text = `ระดับ {height} / เป้าหมาย {goal} • กดทีละครั้ง แล้ววางให้ตรง`
		if crystal and original and target then
			local source = original :: BasePart
			if tween then tween:Cancel() end
			local runningTween = TweenService:Create(crystal :: BasePart, TweenInfo.new(0.12), {
				Position = Vector3.new(source.Position.X, height, source.Position.Z),
			})
			tween = runningTween
			runningTween:Play()
			local targetPart = target :: BasePart
			targetPart.Position = Vector3.new(source.Position.X, goal - 1.2, source.Position.Z)
		end
	end
	for _, attribute in {"LevitationStation", "LevitationHeight", "LevitationTarget"} do
		connect(player:GetAttributeChangedSignal(attribute), refreshPractice)
	end
	connect(academy.ChildAdded, refreshPractice)
	refreshPractice()

	gui.Destroying:Once(function()
		visuals.dispose()
		for _, connection in connections do connection:Disconnect() end
	end)
end
