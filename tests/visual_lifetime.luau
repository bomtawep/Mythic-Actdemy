return function(Lifetime)
	local n, creates, clears, alive = 0, 0, 0, 0
	local function check(v) n+=1; assert(v,"Visual ownership failed") end
	local owner=Lifetime.new(function(name)
		creates+=1
		if name=="missing" then return false end
		alive+=1
		return true
	end,function() clears+=1; alive=0 end)
	check(owner.select("Lesson") and alive==1)
	check(owner.select("Lesson") and creates==1 and clears==0)
	check(owner.select("Puzzle") and creates==2 and clears==1 and alive==1)
	check(not owner.select("") and alive==0)
	check(not owner.select("missing") and alive==0)
	check(not owner.select("missing") and creates==4)
	check(owner.select("DungeonPuzzle") and alive==1)
	owner.dispose()
	check(alive==0)
	local previous=clears
	owner.dispose()
	check(clears==previous)
	check(not owner.select("Lesson") and alive==0)
	local empty=Lifetime.new(function() error("must not create") end,function() error("must not clear empty owner") end)
	empty.dispose()
	check(not empty.select("Lesson"))
	print(`PASS: {n} visual lifetime checks`)
end
