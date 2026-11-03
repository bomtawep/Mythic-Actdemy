return function(Scope)
	local n=0
	local function check(v) n+=1; assert(v,"Controller scope failed") end
	local connected,disconnected,calls,resources=0,0,0,2
	local callbacks={}
	local signal={Connect=function(_,callback)
		connected+=1; table.insert(callbacks,callback)
		return {Disconnect=function() disconnected+=1 end}
	end}
	local scope=Scope.new()
	scope.connect(signal,function(value) calls+=value end)
	scope.connect(signal,function(value) calls+=value end)
	callbacks[1](2); callbacks[2](3)
	check(calls==5 and connected==2)
	scope.add(function() resources-=1 end)
	scope.add(function() resources-=1 end)
	check(scope.dispose())
	check(resources==0 and disconnected==2)
	callbacks[1](10); callbacks[2](10)
	check(calls==5)
	check(scope.dispose() and disconnected==2)
	scope.connect(signal,function() calls+=100 end)
	check(connected==2)
	scope.add(function() resources+=1 end)
	check(resources==1)
	local errors,cleared=0,false
	local broken=Scope.new(function() errors+=1 end)
	broken.add(function() cleared=true end)
	broken.add(function() error("cleanup failure") end)
	check(not broken.dispose())
	check(cleared and errors==1)
	check(broken.dispose())
	print(`PASS: {n} controller scope checks`)
end
