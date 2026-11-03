return function(R)
	local n=0
	local function check(v) n+=1; assert(v,"Dorm placement rule failed") end
	local state={x=0,z=0,rotation=0,placed=false}
	check(R.apply(state,"Place",false)==nil)
	check(R.apply(state,{},true)==nil)
	check(R.apply(state,"unknown",true)==nil)
	check(R.apply(state,"Place",true).placed and not state.placed)
	check(not R.apply(R.apply(state,"Place",true),"Store",true).placed)
	check(R.apply(state,"Right",true).x==2)
	check(R.apply(state,"Forward",true).z==-2)
	check(R.apply(state,"Left",true).x==-2)
	check(R.apply(state,"Back",true).z==2)
	for _=1,4 do state=R.apply(state,"Rotate",true) end
	check(state.rotation==0)
	check(R.inside(10,9,0))
	check(not R.inside(12,0,0))
	check(not R.inside(0,10,0))
	check(R.apply({x=10,z=0,rotation=0,placed=true},"Right",true)==nil)
	check(R.apply({x=0,z=9,rotation=0,placed=true},"Rotate",true)==nil)
	print(`PASS: {n} dorm placement checks`)
end
