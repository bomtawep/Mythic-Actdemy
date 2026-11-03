return function(Placement)
	local n=0
	local function check(v) n+=1; assert(v,"catalog placement failed") end
	check(Placement.inside("Stool",10,8,90))
	check(not Placement.inside("Bench",12,0,0))
	check(not Placement.inside("Unknown",0,0,0))
	local items={{Id="a",CatalogId="Bench",x=0,z=0,rotation=0,placed=false},{Id="b",CatalogId="Stool",x=6,z=0,rotation=0,placed=true}}
	local changed=Placement.replace(items,"b",{Id="forged",CatalogId="Bench",x=8,z=0,rotation=90,placed=true})
	check(changed[2].Id=="b" and changed[2].CatalogId=="Stool")
	check(changed[2].x==8 and items[2].x==6)
	check(changed[1]~=items[1] and changed[1].x==0)
	check(Placement.replace(items,"missing",{})==nil)
	check(Placement.replace(items,"a",false)==nil)
	print(`PASS: {n} catalog selection/placement checks`)
end
