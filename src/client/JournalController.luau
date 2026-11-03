--!strict
local UserInputService = game:GetService("UserInputService")
local DungeonView = require(script.Parent:WaitForChild("DungeonViewModel"))
local Scroll = require(script.Parent:WaitForChild("ScrollModel"))
local PetPolicy = require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("PetPolicy"))
local ShieldJournal = require(script.Parent:WaitForChild("ShieldJournalModel"))
local LightJournal = require(script.Parent:WaitForChild("LightJournalModel"))
local Model = require(script.Parent:WaitForChild("JournalModel"))
local Scope = require(script.Parent:WaitForChild("ControllerScope"))
local KeyHint = require(script.Parent:WaitForChild("KeyHint"))
return function(player: Player, gui: ScreenGui)
	local scope = Scope.new(function(err) warn(err) end)
	local toggle = Instance.new("TextButton")
	toggle.Name = "PH_JournalToggle"
	toggle:SetAttribute("IsPlaceholder", true)
	toggle:SetAttribute("PlaceholderId", "PH-UI-002")
	toggle.AnchorPoint = Vector2.new(1, 0)
	toggle.Position = UDim2.new(1, -16, 0, 132)
	toggle.Size = UDim2.fromOffset(144, 44)
	toggle.Text = KeyHint("สมุดนักเรียน", "B")
	toggle.TextSize = 16
	toggle.BackgroundColor3 = Color3.fromRGB(54, 65, 82)
	toggle.TextColor3 = Color3.fromRGB(245, 240, 225)
	toggle.Parent = gui

	local book = Instance.new("Frame")
	book.Name = "PH_StudentJournal"
	book:SetAttribute("IsPlaceholder", true)
	book:SetAttribute("PlaceholderId", "PH-UI-002")
	book.AnchorPoint = Vector2.new(0.5, 0.5)
	book.Position = UDim2.fromScale(0.5, 0.5)
	book.Size = UDim2.fromScale(0.92, 0.7)
	book.BackgroundColor3 = Color3.fromRGB(27, 33, 43)
	book.Visible = false
	book.ZIndex = 10
	book.Active = true
	book.Parent = gui
	local size = Instance.new("UISizeConstraint")
	size.MaxSize = Vector2.new(640, 560)
	size.Parent = book

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -8, 0, 8)
	close.Size = UDim2.fromOffset(84, 44)
	close.Text = KeyHint("ปิด", "B")
	close.TextSize = 16
	close.ZIndex = 12
	close.Parent = book

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -112, 0, 56)
	title.Position = UDim2.fromOffset(16, 0)
	title.BackgroundTransparency = 1
	title.Text = "สมุดนักเรียน"
	title.TextColor3 = toggle.TextColor3
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 11
	title.Parent = book

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Entries"
	scroll.Position = UDim2.fromOffset(12, 60)
	scroll.Size = UDim2.new(1, -24, 1, -72)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6
	scroll.ZIndex = 11
	scroll.Parent = book
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 16)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll
	local labels: {TextLabel} = {}
	for index = 1, 11 do
		local label = Instance.new("TextLabel")
		label.Name = `Entry{index}`
		label.LayoutOrder = index
		label.Size = UDim2.new(1, -12, 0, 0)
		label.AutomaticSize = Enum.AutomaticSize.Y
		label.BackgroundTransparency = 1
		label.TextColor3 = toggle.TextColor3
		label.TextSize = 18
		label.TextWrapped = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.ZIndex = 12
		label.Parent = scroll
		table.insert(labels, label)
	end
	labels[9].LayoutOrder = 12 -- save status stays the last line; Entry10 (scroll) and Entry11 (companion) sit above it
	local function refresh()
		local rows = Model.describe(player:GetAttribute("ProgressReady") == true, player:GetAttribute("LessonStage"))
		for index = 1, 4 do
			labels[index].Text = rows[index] or ""
			labels[index].Visible = rows[index] ~= nil
		end
		local dungeon = DungeonView.describe(player:GetAttribute("ProgressReady"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("EncounterCleared"), player:GetAttribute("DungeonRoom"))
		labels[5].Visible = dungeon ~= nil
		labels[5].Text = if dungeon then dungeon.summary else ""
		labels[6].Text = LightJournal.describe(player:GetAttribute("ProgressReady"),player:GetAttribute("LightUnlocked"),player:GetAttribute("LightCompleted"))
		labels[7].Text = LightJournal.discovery(player:GetAttribute("ProgressReady"),player:GetAttribute("LightDiscovery"))
		labels[8].Text = ShieldJournal.describe(player:GetAttribute("ProgressReady"),player:GetAttribute("ShieldUnlocked"),player:GetAttribute("ShieldPassed"))
		labels[9].Text = player:GetAttribute("ProgressStatus") or "กำลังโหลดข้อมูล…"
		labels[11].Text = PetPolicy.journal(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player)
		labels[10].Text = Scroll.describe(player:GetAttribute("ProgressReady"), player:GetAttribute("LessonStage"), player:GetAttribute("LightCompleted"), player:GetAttribute("ShieldPassed"), player:GetAttribute("DungeonCompleted"))
	end
	local function setOpen(open: boolean)
		-- Keep the practice controls available: the notebook cannot obscure an active lesson.
		if open and (player:GetAttribute("LevitationStation") or "") ~= "" then return end
		book.Visible = open
	end
	scope.connect(toggle.Activated, function() setOpen(not book.Visible) end)
	scope.connect(close.Activated, function() setOpen(false) end)
	scope.connect(UserInputService.InputBegan, function(input, processed)
		if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.B then
			setOpen(not book.Visible)
		end
	end)
	local function practiceChanged()
		local active = (player:GetAttribute("LevitationStation") or "") ~= ""
		toggle.Visible = not active
		if active then setOpen(false) end
	end
	scope.connect(player:GetAttributeChangedSignal("LevitationStation"), practiceChanged)
	for _, attribute in {"ProgressReady", "LessonStage", "ProgressStatus", "DungeonState", "DungeonPaused", "EncounterCleared", "DungeonRoom", "LightUnlocked", "LightCompleted", "LightDiscovery", "ShieldUnlocked", "ShieldPassed", "DungeonCompleted", "PetNameIndex", "PetBondPlay", "PetBondExplore", "PetBondDungeon", "PetBondDorm"} do
		scope.connect(player:GetAttributeChangedSignal(attribute), refresh)
	end
	refresh()
	practiceChanged()
	scope.connect(gui.Destroying, function() scope.dispose() end)
end
