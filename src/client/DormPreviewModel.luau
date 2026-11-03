--!strict
local Model = {}
function Model.propose(state: any, action: string): any
	local s=table.clone(state)
	if action=="Left" then s.x-=2 elseif action=="Right" then s.x+=2
	elseif action=="Forward" then s.z-=2 elseif action=="Back" then s.z+=2
	elseif action=="Rotate" then s.rotation=(s.rotation+90)%360 end
	-- Bound the editor cursor itself while allowing invalid footprints to be shown.
	s.x=math.clamp(s.x,-14,14); s.z=math.clamp(s.z,-16,16)
	s.placed=true
	return s
end
return Model
