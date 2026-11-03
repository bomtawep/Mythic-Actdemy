return function(R)
	local n=0
	local function check(v) n+=1; assert(v,"Light spell rule failed") end
	for bits=0,7 do
		for rune=1,3 do
			local changed=R.cast(bits,rune)
			check(changed>=0 and changed<=7)
			check(R.cast(changed,rune)==bits)
		end
	end
	check(R.cast(R.cast(0,1),3)==R.Target)
	check(R.lit(R.Target,1) and not R.lit(R.Target,2) and R.lit(R.Target,3))
	for _,bad in {-1,8,1.5,0/0,math.huge,"0",false} do check(R.cast(bad,1)==nil) end
	for _,bad in {0,4,1.5,"1",false} do check(R.cast(0,bad)==nil) end
	check(string.find(R.describe(5),"2:ดับ",1,true)~=nil)
	print(`PASS: {n} light spell/puzzle checks`)
end
