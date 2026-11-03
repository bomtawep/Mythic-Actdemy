return function(Model,Rules)
	local n=0
	local function check(v) n+=1; assert(v,"Preview draft invalid") end
	local original={x=0,z=0,rotation=0,placed=false}
	local draft=Model.propose(original,"Right")
	check(original.x==0 and not original.placed)
	check(draft.x==2 and draft.placed)
	for _=1,6 do draft=Model.propose(draft,"Right") end
	check(draft.x==14 and not Rules.inside(draft.x,draft.z,draft.rotation))
	for _=1,4 do draft=Model.propose(draft,"Left") end
	check(Rules.inside(draft.x,draft.z,draft.rotation))
	for _=1,4 do draft=Model.propose(draft,"Rotate") end
	check(draft.rotation==0)
	for _=1,20 do draft=Model.propose(draft,"Forward") end
	check(draft.z==-16)
	print(`PASS: {n} furniture preview checks`)
end
