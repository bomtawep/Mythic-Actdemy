return function(Model)
	local n=0
	local function check(v) n+=1; assert(v,"Light journal state incorrect") end
	check(string.find(Model.describe(false,true,true),"รอข้อมูล",1,true)~=nil)
	check(string.find(Model.describe(true,false,false),"ยังไม่เรียน",1,true)~=nil)
	check(string.find(Model.describe(true,true,false),"ยังไม่ผ่าน",1,true)~=nil)
	check(string.find(Model.describe(true,true,true),"ผ่านปริศนาแล้ว",1,true)~=nil)
	for _,state in {{false,false},{true,false},{true,true}} do check(string.find(Model.describe(true,state[1],state[2]),"จะบันทึกไว้หลังออกเกม",1,true)~=nil) end
	for _,found in {false,true} do check(string.find(Model.discovery(true,found),"ไม่บันทึกหลังออกเกม",1,true)~=nil) end
	check(string.find(Model.discovery(false,true),"รอข้อมูล",1,true)~=nil)
	check(string.find(Model.discovery(true,false),"ยังไม่ค้นพบ",1,true)~=nil)
	check(string.find(Model.discovery(true,true),"ค้นพบแล้ว",1,true)~=nil)
	print(`PASS: {n} light journal checks`)
end
