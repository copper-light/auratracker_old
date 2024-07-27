if select(2,UnitClass("player")) ~= "WARLOCK" then return end

local prevTime = 0
function ATC_OnUpdate_ForHaunt(self)
	--if (GetTime() - prevTime) < 0.01 then return end
	if not self:GetParent().spell or tonumber(self:GetParent().spell.id) ~= 48181 then 
		self:SetScript("OnUpdate",nil)
		return
	end
	--prevTime = GetTime()
	self:GetParent().counttext:SetText(UnitPower("player", 7))
end

hooksecurefunc(HDH_C_TRACKER, "InitIcons", function(self)
	if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
	local talent = DB_AURA.Talent[GetSpecialization()] 
	if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
	if not self.option then return end 	-- 설정 정보 없으면 패스
	local auraList = talent[self.name] or {}
	local name, icon, spellID, isItem
	local spell 
	local iconFrame
	
	for i = 1 , #auraList do
		iconFrame = self.frame.icon[i]
		if iconFrame.spell and tonumber(iconFrame.spell.id) == 48181 then -- 유령 출몰
			iconFrame.counttext:GetParent():SetScript("OnUpdate",ATC_OnUpdate_ForHaunt)
		else
			iconFrame.counttext:GetParent():SetScript("OnUpdate",nil)
		end
	end
end)

hooksecurefunc(HDH_TRACKER, "InitIcons", function(self)
	if self.unit == "target" or self.unit == "focus" or string.find(self.unit, "boss") then
		if not self.frame.pointer then return end
		local f = self.frame.pointer["유령 출몰"] or self.frame.pointer["48181"] or nil
		
		for k,v in pairs(self.frame.pointer) do
			v.counttext:GetParent():SetScript("OnUpdate",nil)
		end
		
		if f then
			f.counttext:GetParent():SetScript("OnUpdate",ATC_OnUpdate_ForHaunt)
		end
	end
end)