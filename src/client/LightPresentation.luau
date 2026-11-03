--!strict
local Scope=require(script.Parent:WaitForChild("ControllerScope"))
local Rules=require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("LightRules"))
local Presentation={}
function Presentation.new(config: any)
	return function(player: Player, gui: ScreenGui)
		local scope=Scope.new(function(err) warn(err) end)
		local academy=workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy")
		local lamps={}
		for i=1,3 do
			local rune=academy:WaitForChild(`{config.RunePrefix}{i}`) :: BasePart
			local light=Instance.new("PointLight")
			light.Name=config.LightName; light.Brightness=0.7; light.Range=8
			light.Color=Color3.fromRGB(240,220,150)
			light:SetAttribute("IsPlaceholder",true); light:SetAttribute("PlaceholderId",config.PlaceholderId); light.Parent=rune
			local sign=Instance.new("BillboardGui")
			sign.Name=config.SignName; sign.Adornee=rune
			sign:SetAttribute("IsPlaceholder",true); sign:SetAttribute("PlaceholderId",config.PlaceholderId)
			sign.Size=UDim2.fromOffset(120,44); sign.StudsOffset=Vector3.new(0,3,0); sign.MaxDistance=45; sign.Parent=rune
			local text=Instance.new("TextLabel")
			text.Size=UDim2.fromScale(1,1); text.TextSize=18
			text.TextColor3=Color3.fromRGB(245,240,225); text.BackgroundColor3=Color3.fromRGB(27,33,43); text.Parent=sign
			table.insert(lamps,{light=light,text=text,sign=sign,index=i})
			scope.add(function() light:Destroy(); sign:Destroy() end)
		end
		local function refresh()
			local unlocked=player:GetAttribute(config.BlockedBy)~=true and player:GetAttribute(config.Unlocked)==true and player:GetAttribute("ProgressReady")==true and player:GetAttribute("InDorm")~=true and (player:GetAttribute("DungeonState") or "Idle")=="Idle" and (player:GetAttribute("LevitationStation") or "")==""
			local bits=player:GetAttribute(config.Bits) or 0
			for _,lamp in lamps do
				local lit=Rules.lit(bits,lamp.index)
				lamp.light.Enabled=unlocked and lit; lamp.sign.Enabled=unlocked
				lamp.text.Text=`{lamp.index}: {if lit then "สว่าง" else "ดับ"}`
			end
		end
		for _,attribute in {config.Bits,config.Unlocked,config.BlockedBy,"ProgressReady","InDorm","DungeonState","LevitationStation"} do scope.connect(player:GetAttributeChangedSignal(attribute),refresh) end
		scope.connect(gui.Destroying,function() scope.dispose() end)
		refresh()
	end
end
return Presentation
