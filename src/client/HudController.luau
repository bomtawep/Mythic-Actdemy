--!strict
return function(player: Player): ScreenGui
	local connections: {RBXScriptConnection} = {}
	local function connect(signal: any, callback: any)
		table.insert(connections, signal:Connect(callback))
	end
	local DungeonView = require(script.Parent:WaitForChild("DungeonViewModel"))
	local gui = Instance.new("ScreenGui")
	gui.Name = "PH_LessonHUD"
	gui.ResetOnSpawn = false
	gui:SetAttribute("IsPlaceholder", true)
	gui:SetAttribute("PlaceholderId", "PH-UI-001")
	local panel = Instance.new("TextLabel")
	panel.Name = "Objective"
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 12)
	panel.Size = UDim2.new(0.9, 0, 0, 112)
	panel.BackgroundColor3 = Color3.fromRGB(27, 33, 43)
	panel.BackgroundTransparency = 0.1
	panel.TextColor3 = Color3.fromRGB(245, 240, 225)
	panel.TextWrapped = true
	panel.TextSize = 18
	panel.Font = Enum.Font.Gotham
	panel.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = panel
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(720, 112)
	constraint.Parent = panel
	local function update()
		local dungeon = DungeonView.describe(player:GetAttribute("ProgressReady"), player:GetAttribute("DungeonState"), player:GetAttribute("DungeonPaused"), player:GetAttribute("EncounterCleared"), player:GetAttribute("DungeonRoom"))
		if dungeon then
			local practicing = (player:GetAttribute("LevitationStation") or "") ~= ""
			local objective = if practicing then (player:GetAttribute("LessonHint") or dungeon.objective) else dungeon.objective
			panel.Text = `{dungeon.headline}\n{objective}\n{dungeon.status}`
			return
		end
		if player:GetAttribute("ShieldTrialActive")==true then
			panel.Text="ม่านคุ้มกัน • กันให้ได้ 2 จาก 3 ครั้ง\nกด Q หรือปุ่มเมื่อใกล้เวลาโจมตี • ออกพื้นที่เพื่อหยุดฝึก\nผ่านแล้วจะบันทึกไว้หลังออกเกม"
			return
		end
		if player:GetAttribute("LightExploreActive")==true and player:GetAttribute("InDorm")~=true and (player:GetAttribute("LevitationStation") or "")=="" then
			panel.Text=`สวนอักขระ • เป้าหมาย 1:ดับ 2:สว่าง 3:ดับ\n{player:GetAttribute("LightExploreHint") or "นำเวทแสงมาลองกับโจทย์ใหม่"}\nเดินออกได้ทุกเมื่อ • บันทึกเฉพาะรอบเล่น`
			return
		end
		if player:GetAttribute("LightTrialActive")==true and player:GetAttribute("InDorm")~=true and (player:GetAttribute("LevitationStation") or "")=="" then
			panel.Text=`แสงนำทาง • เป้าหมาย 1:สว่าง 2:ดับ 3:สว่าง\n{player:GetAttribute("LightHint") or "ร่ายที่อักขระเพื่อสลับแสง"}\nเริ่มใหม่ที่แท่นได้ • ผ่านแล้วจะบันทึกไว้`
			return
		end
		local stage = player:GetAttribute("LessonStage") or 0
		local hint = player:GetAttribute("LessonHint") or "กำลังเริ่มบททดลอง…"
		panel.Text = `MYTHIC ACADEMY • PROTOTYPE • {stage}/3\n{hint}\n{player:GetAttribute("ProgressStatus") or "กำลังโหลดข้อมูล…"}`
	end
	connect(player:GetAttributeChangedSignal("LessonStage"), update)
	connect(player:GetAttributeChangedSignal("LessonHint"), update)
	connect(player:GetAttributeChangedSignal("ProgressStatus"), update)
	for _, attribute in {"ProgressReady", "DungeonState", "DungeonPaused", "EncounterCleared", "DungeonRoom", "LevitationStation", "LightTrialActive", "LightHint", "LightExploreActive", "LightExploreHint", "ShieldTrialActive", "InDorm"} do
		connect(player:GetAttributeChangedSignal(attribute), update)
	end
	update()
	gui.Parent = player:WaitForChild("PlayerGui")


	gui.Destroying:Once(function()
		for _, connection in connections do connection:Disconnect() end
	end)
	return gui
end
