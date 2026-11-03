--!strict
-- Cosmetic floating blockout, rendered locally for every replicated equipped player.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy")
local Policy = require(shared:WaitForChild("PetPolicy"))
local remote = shared:WaitForChild("PetAction") :: RemoteEvent
local Scope = require(script.Parent:WaitForChild("ControllerScope"))
local KeyHint = require(script.Parent:WaitForChild("KeyHint"))
return function(player: Player, gui: ScreenGui)
	local scope = Scope.new(function(err) warn(err) end)
	local button = Instance.new("TextButton")
	button.Name = "PH_PetToggle"
	button:SetAttribute("IsPlaceholder", true)
	button:SetAttribute("PlaceholderId", "PH-PET-001")
	button.AnchorPoint = Vector2.new(1, 0)
	button.Position = UDim2.new(1, -16, 0, 184)
	button.Size = UDim2.fromOffset(144, 52)
	button.BackgroundColor3 = Color3.fromRGB(54, 65, 82)
	button.TextColor3 = Color3.fromRGB(245, 240, 225)
	button.TextSize = 15
	button.TextWrapped = true
	button.Parent = gui
	-- Play and rename form a second column left of the journal/companion buttons: stacked below them they
	-- covered the touch jump button in the iPhone XR simulator (Step 53). The server decides whether either counts.
	local function smallButton(name: string, text: string, y: number): TextButton
		local b = Instance.new("TextButton")
		b.Name = name
		b:SetAttribute("IsPlaceholder", true)
		b:SetAttribute("PlaceholderId", "PH-PET-001")
		b.AnchorPoint = Vector2.new(1, 0)
		b.Position = UDim2.new(1, -168, 0, y)
		b.Size = UDim2.fromOffset(144, 44)
		b.BackgroundColor3 = button.BackgroundColor3
		b.TextColor3 = button.TextColor3
		b.TextSize = 15
		b.Text = text
		b.Parent = gui
		return b
	end
	local play = smallButton("PH_PetPlay", "เล่นด้วย", 184)
	local rename = smallButton("PH_PetRename", "เปลี่ยนชื่อ", 132)
	local function refresh()
		local unlocked = Policy.unlocked(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"))
		button.Text = if not unlocked then "คู่หู: จบบทเรียนก่อน" elseif player:GetAttribute("PetEquipped") == true then KeyHint("เก็บคู่หู", "P") else KeyHint("เรียกคู่หู", "P")
		button.Visible = (player:GetAttribute("LevitationStation") or "") == ""
		button.AutoButtonColor = unlocked
		play.Visible = button.Visible and unlocked and player:GetAttribute("PetEquipped") == true
		rename.Visible = button.Visible and unlocked
	end
	local lastRequest = -math.huge
	local function toggle()
		if not button.Visible or not Policy.unlocked(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage")) then return end
		if os.clock() - lastRequest < 0.4 then return end
		lastRequest = os.clock()
		remote:FireServer(player:GetAttribute("PetEquipped") ~= true)
	end
	scope.connect(button.Activated, toggle)
	local function request(action: string)
		if os.clock() - lastRequest < 0.4 then return end
		lastRequest = os.clock()
		remote:FireServer(action)
	end
	scope.connect(play.Activated, function() if play.Visible then request("Play") end end)
	scope.connect(rename.Activated, function() if rename.Visible then request("Rename") end end)
	scope.connect(UserInputService.InputBegan, function(input, processed)
		if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.P then toggle() end
	end)
	for _, attribute in {"ProgressReady", "LessonStage", "PetEquipped", "LevitationStation"} do
		scope.connect(player:GetAttributeChangedSignal(attribute), refresh)
	end
	refresh()

	local visuals: {[Player]: Model} = {}
	local tags: {[Player]: TextLabel} = {}
	-- Bond feedback shows briefly over the local player's own companion.
	local feedbackUntil = -math.huge
	scope.connect(player:GetAttributeChangedSignal("PetFeedback"), function() feedbackUntil = os.clock() + 3 end)
	local function remove(owner: Player)
		local model = visuals[owner]
		if model then model:Destroy(); visuals[owner] = nil end
		tags[owner] = nil
	end
	local function create(owner: Player): Model
		local model = Instance.new("Model")
		model.Name = `PH_Companion_{owner.UserId}`
		model:SetAttribute("IsPlaceholder", true)
		model:SetAttribute("PlaceholderId", "PH-PET-001")
		model:SetAttribute("OwnerUserId", owner.UserId)
		local function part(name: string, size: Vector3, position: Vector3, color: Color3, shape: Enum.PartType?)
			local p = Instance.new("Part")
			p.Name = name
			p.Shape = shape or Enum.PartType.Ball
			p.Size = size
			p.Position = position
			p.Color = color
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.CastShadow = false
			p.Parent = model
			return p
		end
		-- Leaf-ear sprite (ละอองหูใบ): round body, two leaf ears, dot eyes. Primitive stand-in only.
		local body = part("Body", Vector3.new(1.8, 1.5, 1.5), Vector3.zero, Color3.fromRGB(196, 214, 170))
		-- Flat slabs read as leaves; a Ball shape shrinks to its smallest axis and showed as dots in Studio.
		part("EarLeft", Vector3.new(0.15, 0.9, 0.6), Vector3.new(-0.6, 0.9, 0), Color3.fromRGB(110, 175, 90), Enum.PartType.Block)
		part("EarRight", Vector3.new(0.15, 0.9, 0.6), Vector3.new(0.6, 0.9, 0), Color3.fromRGB(110, 175, 90), Enum.PartType.Block)
		part("EyeLeft", Vector3.new(0.18, 0.18, 0.18), Vector3.new(-0.4, 0.2, -0.68), Color3.fromRGB(30, 40, 38))
		part("EyeRight", Vector3.new(0.18, 0.18, 0.18), Vector3.new(0.4, 0.2, -0.68), Color3.fromRGB(30, 40, 38))
		model.PrimaryPart = body
		local tag = Instance.new("BillboardGui")
		tag.Name = "PH_CompanionName"
		tag:SetAttribute("IsPlaceholder", true)
		tag:SetAttribute("PlaceholderId", "PH-PET-001")
		tag.Adornee = body
		tag.Size = UDim2.fromOffset(240, 64)
		tag.StudsOffset = Vector3.new(0, 2, 0)
		tag.MaxDistance = 40
		tag.Parent = model
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(245, 240, 225)
		label.TextSize = 15
		label.TextWrapped = true
		label.Parent = tag
		tags[owner] = label
		visuals[owner] = model
		return model
	end
	scope.connect(Players.PlayerRemoving, remove)
	scope.connect(RunService.RenderStepped, function(dt)
		for _, owner in Players:GetPlayers() do
			local character = owner.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			local active = owner:GetAttribute("PetEquipped") == true
				and Policy.unlocked(owner:GetAttribute("ProgressReady"), owner:GetAttribute("LessonStage"))
			if not active or not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
				remove(owner)
				continue
			end
			local existing = visuals[owner]
			local model = existing or create(owner)
			local label = tags[owner]
			if label then
				local feedback = if owner == player and os.clock() < feedbackUntil then player:GetAttribute("PetFeedback") else nil
				local text = Policy.tagText(owner:GetAttribute("PetNameIndex"), Policy.bondCount(owner), feedback)
				if label.Text ~= text then label.Text = text end
			end
			local goal = root.CFrame * CFrame.new(3, -0.6, 3)
			local current = model:GetPivot()
			if not existing or (current.Position - goal.Position).Magnitude > 24 then
				model:PivotTo(goal)
			else
				model:PivotTo(current:Lerp(goal, 1 - math.exp(-8 * dt)))
			end
			-- Parent after initial placement to avoid a flash at the world origin.
			if not model.Parent then model.Parent = workspace end
		end
	end)
	scope.add(function()
		for owner in visuals do remove(owner) end
	end)

	scope.connect(gui.Destroying, function() scope.dispose() end)
end
