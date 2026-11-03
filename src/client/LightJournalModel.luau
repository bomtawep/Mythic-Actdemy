--!strict
local Model={}
function Model.describe(ready: any, unlocked: any, completed: any): string
	if ready~=true then return "แสงนำทาง • รอข้อมูลนักเรียน" end
	local state=if completed==true then "ผ่านปริศนาแล้ว" elseif unlocked==true then "เรียนแล้ว • ยังไม่ผ่านปริศนา" else "ยังไม่เรียน • จบแรงลอยตัวแล้วไปแท่นฝั่งซ้ายลาน"
	return `แสงนำทาง • {state}\nผ่านปริศนาแล้วจะบันทึกไว้หลังออกเกม`
end
function Model.discovery(ready: any, found: any): string
	if ready~=true then return "อักขระสวน • รอข้อมูลนักเรียน" end
	return `อักขระสวน • {if found==true then "ค้นพบแล้ว" else "ยังไม่ค้นพบ • ผ่านเวทแสงแล้วสำรวจลานฝั่งขวา"}\nการค้นพบนี้ไม่บันทึกหลังออกเกม`
end
return Model
