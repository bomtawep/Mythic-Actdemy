return function(Schema,Catalog)
	local n=0
	local function check(v,msg) n+=1; assert(v,msg) end
	local old={Version=1,Furniture={x=2,z=-4,rotation=90,placed=true},Lease={Token="session-a",Expires=200}}
	local converted=Schema.migrate(old)
	check(converted.Version==2 and #converted.Items==1,"one legacy item")
	local bench=converted.Items[1]
	check(bench.Id=="starter-bench-001" and bench.CatalogId=="Bench","stable legacy identity")
	check(bench.x==2 and bench.z==-4 and bench.rotation==90 and bench.placed,"preserve placement")
	check(converted.Lease.Token=="session-a" and converted.Lease.Expires==200,"preserve lease")
	check(old.Version==1 and old.Items==nil,"migration never mutates source")
	local repeated=Schema.migrate(converted)
	check(#repeated.Items==1 and repeated.Items[1].Id==bench.Id,"repeat migration never duplicates")
	repeated.Items[1].x=0
	check(converted.Items[1].x==2,"decoded data has no shared item aliases")
	check(#Schema.migrate(nil).Items==1 and not Schema.migrate(nil).Items[1].placed,"new profile starts with stored bench")
	check(Schema.migrate({Version=3})==nil,"future schema rejected")
	check(Schema.migrate({Version=1,Furniture={}})==nil,"invalid legacy not replaced")
	local function item(id,x,z,kind,placed) return {Id=id,CatalogId=kind or "Bench",x=x,z=z,rotation=0,placed=placed~=false} end
	check(Schema.decode({Version=2,Items={item("a",0,0),item("b",6,0,"Stool")}})~=nil,"two kinds supported")
	check(Schema.decode({Version=2,Items={item("a",0,0),item("b",0,0)}})==nil,"placed overlaps rejected")
	check(Schema.decode({Version=2,Items={item("a",0,0),item("a",6,0)}})==nil,"duplicate instance IDs rejected")
	check(Schema.decode({Version=2,Items={item("a",0,0,"Unknown")}})==nil,"unknown catalog IDs rejected")
	check(Schema.decode({Version=2,Items={item("a",12,0)}})==nil,"footprint bounds")
	check(Schema.decode({Version=2,Items={item("a",0,0),item("b",0,0,"Stool",false)}})~=nil,"stored furniture may share draft location")
	check(Schema.decode({Version=2,Items={item("a",0,0),item("b",4,0)}})~=nil,"touching footprints allowed")
	check(Schema.decode({Version=2,Items={[2]=item("a",0,0)}})==nil,"sparse array rejected")
	check(Schema.decode({Version=2,Items={bad=item("a",0,0)}})==nil,"dictionary rejected")
	local items={}; for i=1,9 do items[i]=item(`i{i}`,0,0,"Stool",false) end
	check(Schema.decode({Version=2,Items=items})==nil,"item cap enforced")
	check(table.isfrozen(Catalog) and table.isfrozen(Catalog.Bench),"catalog immutable")
	print(`PASS: {n} furniture catalog/migration checks`)
end
