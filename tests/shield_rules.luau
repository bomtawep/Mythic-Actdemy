return function(R)
	local n=0
	local function check(v) n+=1; assert(v,"Shield timing rule failed") end
	check(R.blocked(9.5,10)); check(R.blocked(10,10)); check(not R.blocked(9,10)); check(not R.blocked(10.1,10))
	check(not R.blocked(-math.huge,10)); check(not R.blocked(0/0,10))
	for attempts=0,2 do check(R.result(0,attempts)=="Continue") end
	check(R.result(1,3)=="Retry"); check(R.result(2,3)=="Passed"); check(R.result(3,3)=="Passed")
	check(R.Interval>R.Window and R.Cooldown>R.Window)
	print(`PASS: {n} shield timing/progress checks`)
end
