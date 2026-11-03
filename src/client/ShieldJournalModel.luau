--!strict
local Model={}
function Model.describe(ready: any,unlocked: any,passed: any): string
	if ready~=true then return "ม่านคุ้มกัน • รอข้อมูลนักเรียน" end
	local state=if passed==true then "ผ่านการฝึกแล้ว" elseif unlocked==true then "ฝึกแล้ว • ยังไม่ผ่าน" else "ยังไม่เรียน • ผ่านบทแสงแล้วไปแท่นใกล้จุดเกิด"
	return `ม่านคุ้มกัน • {state}\nผ่านการฝึกแล้วจะบันทึกไว้หลังออกเกม`
end
return Model
