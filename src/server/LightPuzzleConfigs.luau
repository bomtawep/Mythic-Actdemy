--!strict
local function config(value: any)
	table.freeze(value.Attributes)
	return table.freeze(value)
end
return table.freeze({
	Lesson=config({
		StartName="LightLesson", RunePrefix="LightRune", Target=5,
		BlockedBy="LightExploreActive",
		Attributes={Unlocked="LightUnlocked",Bits="LightBits",Active="LightTrialActive",Completed="LightCompleted",Hint="LightHint"},
		SuccessHint="ผ่านแสงนำทางแล้ว: สว่าง–ดับ–สว่าง! บันทึกว่าเรียนเวทนี้แล้ว",
	}),
	Explore=config({
		StartName="LightExploreStart", RunePrefix="ExploreRune", Target=2,
		RequiredAttribute="LightCompleted", BlockedBy="LightTrialActive",
		Attributes={Unlocked="LightExploreUnlocked",Bits="LightExploreBits",Active="LightExploreActive",Completed="LightDiscovery",Hint="LightExploreHint"},
		SuccessHint="ค้นพบอักขระสวนแล้ว: ดับ–สว่าง–ดับ! บันทึกสำรวจเฉพาะรอบเล่น",
	}),
})
