--!strict
-- Keyboard shortcut labels only make sense with a keyboard; touch-only devices get the plain label (Step 54).
local UserInputService = game:GetService("UserInputService")
return function(label: string, key: string): string
	return if UserInputService.KeyboardEnabled then `{label} [{key}]` else label
end
