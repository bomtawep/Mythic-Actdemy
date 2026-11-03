--!strict
local Rules=require(game:GetService("ReplicatedStorage"):WaitForChild("MythicAcademy"):WaitForChild("ShieldRules"))
local Guard={}
local anchor=workspace:WaitForChild("AcademyPrototype"):WaitForChild("Academy"):WaitForChild("PH_TrainingSentinel") :: BasePart
-- The next strike one cast can meet: the sentinel's (only within its reach) or the caster's volley anywhere in room 2.
local function incoming(p: Player, now: number, root: BasePart): number?
	local best: number? = nil
	local sentinel=p:GetAttribute("EncounterStrikeAt")
	if p:GetAttribute("EncounterPhase")=="Warning" and type(sentinel)=="number" and now<sentinel and (root.Position-anchor.Position).Magnitude<=15 then best=sentinel end
	local volley=p:GetAttribute("CasterStrikeAt")
	if p:GetAttribute("CasterPhase")=="Warning" and type(volley)=="number" and now<volley and (best==nil or volley<best) then best=volley end
	return best
end
function Guard.Cast(p: Player, now: number): boolean
	if p:GetAttribute("ShieldPassed")~=true or p:GetAttribute("ProgressReady")~=true or p:GetAttribute("LessonStage")~=3 or p:GetAttribute("DungeonState")~="Encounter" or p:GetAttribute("DungeonPaused")==true or p:GetAttribute("EncounterCleared")==true or (p:GetAttribute("LevitationStation") or "")~="" then return false end
	if now-(p:GetAttribute("ShieldCombatLastAt") or -math.huge)<Rules.Cooldown then return false end
	local char=p.Character
	local root=if char then char:FindFirstChild("HumanoidRootPart") else nil
	local humanoid=if char then char:FindFirstChildOfClass("Humanoid") else nil
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 then return false end
	local strike=incoming(p,now,root)
	if not strike then return false end
	p:SetAttribute("ShieldCombatCastAt",now); p:SetAttribute("ShieldCombatTarget",strike)
	p:SetAttribute("ShieldCombatFeedback","ร่ายม่านคุ้มกันแล้ว • รอผลโจมตีจากเซิร์ฟเวอร์")
	p:SetAttribute("ShieldCombatLastAt",now); p:SetAttribute("ShieldUntil",now+Rules.Window)
	return true
end
function Guard.Reset(p: Player)
	p:SetAttribute("ShieldCombatCastAt",nil); p:SetAttribute("ShieldCombatTarget",nil)
end
function Guard.Blocked(p: Player,strike: number): boolean
	local cast=p:GetAttribute("ShieldCombatCastAt")
	local target=p:GetAttribute("ShieldCombatTarget")
	Guard.Reset(p)
	local humanoid=if p.Character then p.Character:FindFirstChildOfClass("Humanoid") else nil
	return humanoid~=nil and humanoid.Health>0 and p:GetAttribute("ProgressReady")==true and p:GetAttribute("LessonStage")==3 and p:GetAttribute("DungeonState")=="Encounter" and p:GetAttribute("DungeonPaused")~=true and p:GetAttribute("EncounterCleared")~=true and (p:GetAttribute("LevitationStation") or "")=="" and p:GetAttribute("ShieldPassed")==true and target==strike and type(cast)=="number" and Rules.blocked(cast,strike)
end
return Guard
