return function(Model)
	local n = 0
	local function check(v, message) n += 1; assert(v, message or "Dungeon view must reflect current run") end
	check(Model.describe(false,"Complete",false,true)==nil)
	check(Model.describe(true,"Idle",false,true)==nil)
	check(Model.describe(true,"invalid",false,false)==nil)
	check(Model.describe(true,nil,false,false)==nil)
	for _, state in {"Puzzle","Encounter","Reward","Complete"} do
		for _, paused in {false,true} do
			for _, cleared in {false,true} do
				local view=Model.describe(true,state,paused,cleared)
				check(type(view.objective)=="string" and #view.objective>0)
				local passed = cleared or state=="Reward" or state=="Complete"
				check(string.find(view.summary, if passed then "ผ่านผู้เฝ้าแล้ว" else "ม่านคุ้มกัน 2 ครั้ง",1,true)~=nil, "sentinel line shows both ways until passed")
				check(string.find(view.status,if paused or state~="Complete" then "Checkpoint" else "ไม่มีไอเทมถาวร",1,true)~=nil)
				if paused then check(string.find(view.headline,"พักอยู่",1,true)~=nil) end
			end
		end
	end
	for state, room in {Puzzle=1, Encounter=2, Reward=3} do
		check(string.find(Model.describe(true,state,false,false).headline,`ห้อง {room}/3`,1,true)~=nil, "headline shows room number")
	end
	check(string.find(Model.describe(true,"Puzzle",false,false).objective,"11",1,true)~=nil)
	check(string.find(Model.describe(true,"Encounter",false,false).objective,"ผู้เฝ้า",1,true)~=nil)
	check(string.find(Model.describe(true,"Reward",false,false).objective,"รับผล",1,true)~=nil)
	check(string.find(Model.describe(true,"Complete",false,false).objective,"ประตูกลับ",1,true)~=nil)
	check(string.find(Model.describe(true,"Encounter",true,false).status,"ห้อง 2",1,true)~=nil, "paused room 2 resumes at room 2")
	check(string.find(Model.describe(true,"Encounter",true,false).objective,"ซากวิหาร",1,true)~=nil, "paused run points to the dungeon gate at the ruins")
	local inRoom2 = Model.describe(true,"Reward",false,true,2)
	check(string.find(inRoom2.headline,"ห้อง 2/3",1,true)~=nil and string.find(inRoom2.objective,"เงา",1,true)~=nil, "cleared but still in room 2 talks about the shade")
	local inRoom3 = Model.describe(true,"Reward",false,true,3)
	check(string.find(inRoom3.headline,"ห้อง 3/3",1,true)~=nil and string.find(inRoom3.objective,"เงา",1,true)==nil and string.find(inRoom3.objective,"แท่นจบ",1,true)~=nil, "room 3 only asks for the finish altar")
	check(Model.describe(true,"Puzzle",false,false,9).headline==Model.describe(true,"Puzzle",false,false).headline, "unknown room falls back to the state")
	print(`PASS: {n} dungeon view checks`)
end
