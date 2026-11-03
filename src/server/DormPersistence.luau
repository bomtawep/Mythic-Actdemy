--!strict
local RunService=game:GetService("RunService")
local Repository=require(script.Parent:WaitForChild("DormRepository"))
local Manager=require(script.Parent:WaitForChild("DormDataManager"))
local studio=RunService:IsStudio()
local memory: {[string]: any}={}
local store: any
if studio then
	store={UpdateAsync=function(_,key,transform)
		local result=transform(memory[key])
		if result then memory[key]=result end
		return result
	end}
else
	store=game:GetService("DataStoreService"):GetDataStore("MythicAcademy_Dorm_v1")
end
local manager=Manager.new(function(player: Player)
	local token=game:GetService("HttpService"):GenerateGUID(false)
	return Repository.new(store,`room_{player.UserId}`,token,os.time)
end,os.time,task.wait,studio)
local started=false
local Service={Load=manager.load,Get=manager.get,Set=manager.set,Close=manager.close}
function Service.Start()
	if started then return end
	started=true
	local elapsed=0
	RunService.Heartbeat:Connect(function(dt)
		elapsed+=dt
		if elapsed<30 then return end
		elapsed=0
		for _,player in manager.keys() do task.spawn(manager.flush,player) end
	end)
	game:BindToClose(function()
		manager.shutdown()
		for _,player in manager.keys() do task.spawn(manager.close,player) end
		local deadline=os.clock()+25
		while #manager.keys()>0 and os.clock()<deadline do task.wait(0.1) end
	end)
end
return Service
