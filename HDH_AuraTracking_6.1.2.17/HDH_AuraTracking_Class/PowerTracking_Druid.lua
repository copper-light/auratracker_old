HDH_POWER_DRUID_TRACKER = {}

local MyClassKor, MyClass = UnitClass("player");

if MyClass == "DRUID" then
	HDH_UNIT_LIST[#HDH_UNIT_LIST+1] = "드루이드 2차 자원" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
end
HDH_GET_CLASS["드루이드 2차 자원"] = HDH_POWER_DRUID_TRACKER -- 
	
------------------------------------
do  -- HDH_POWER_DRUID_TRACKER class
------------------------------------
	setmetatable(HDH_POWER_DRUID_TRACKER, HDH_POWER_TRACKER) -- 상속
	HDH_POWER_DRUID_TRACKER.__index = HDH_POWER_DRUID_TRACKER
	local super = HDH_POWER_TRACKER
	
	function HDH_POWER_DRUID_TRACKER_OnUpdate(self)
		local curTime = GetTime()
		if (curTime - (self.delay or 0)) > 0.13 then
			-- local count = UnitPower('player', HDH_POWER_TYPE["ECLIPSE"])
			-- if count > 0 then
				-- self.counttext:SetText(nil)
				-- self:GetParent().pointer[HDH_POWER_NAME[3]].counttext:SetText(count)
				-- if count == 1 then self:GetParent().parent:Update(HDH_POWER_TYPE["ECLIPSE"]) end
			-- elseif count == 0 then
				-- self.counttext:SetText(nil)
				-- self:GetParent().pointer[HDH_POWER_NAME[3]].counttext:SetText(nil)
				-- self:GetParent().parent:Update(HDH_POWER_TYPE["ECLIPSE"])
			-- else
				-- if count == -1 then self:GetParent().parent:Update(HDH_POWER_TYPE["ECLIPSE"]) end
				-- self.counttext:SetText((-count))
				-- self:GetParent().pointer[HDH_POWER_NAME[3]].counttext:SetText(nil)
			-- end 
			self:GetParent().parent:Update(HDH_POWER_TYPE["ECLIPSE"]) 
			self.delay = curTime
		end
	end
	
	function HDH_POWER_DRUID_TRACKER:UpdateTalentInfo()
		local id = DB_AURA.Talent[GetSpecialization()].ID
		if MyClass == "DRUID" then
			if id == 102 then -- 조화드루
				HDH_POWER_TYPE = {COMBO_POINTS = 4, ECLIPSE= 8}
				HDH_POWER_KEY = {HDH_PT_KEY..1, HDH_PT_KEY..2, HDH_PT_KEY..3}
				HDH_POWER_NAME = {"연계 점수", "조화 - 월식", "조화 - 일식"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Misc_Gem_Pearl_05", "Interface\\Icons\\INV_Misc_Gem_Pearl_07", "Interface\\Icons\\INV_Misc_Gem_Pearl_04"}
			else
				HDH_POWER_TYPE = {COMBO_POINTS = 4}
				HDH_POWER_KEY = {HDH_PT_KEY..1}
				HDH_POWER_NAME = {"연계 점수"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Misc_Gem_Pearl_05"}
			end
		end
	end
	
	function HDH_POWER_DRUID_TRACKER:Update(power_idx) -- HDH_TRACKER override
		if not self.frame or UI_LOCK then return end
		if not power_idx then power_idx = HDH_POWER_TYPE["ECLIPSE"] end
		local form = GetShapeshiftFormID()
		local count
		if form == MOONKIN_FORM then
			if power_idx and power_idx == 8 then -- 조화
				count = UnitPower('player', power_idx)
				local comboIcon = self.frame.pointer[HDH_POWER_KEY[1]]
				if comboIcon and comboIcon.spell then comboIcon.spell.hide = true end
				local iconf1, iconf2
				iconf1 = self.frame.pointer[HDH_POWER_KEY[2]] -- 월식 아이콘
				iconf2 = self.frame.pointer[HDH_POWER_KEY[3]] -- 일식 아이콘
				if iconf1 and iconf1.spell and iconf2 and iconf2.spell then
					if count < 0 then -- 월식
						iconf1.spell.count = -count; 
						iconf1.spell.isUpdate = true;
						iconf2.spell.count = 0; 
					elseif count == 0 then -- 중간
						iconf1.spell.count = 0
						iconf2.spell.count = 0 
					else -- 일식
						iconf1.spell.count = 0
						iconf2.spell.count = count; 
						iconf2.spell.isUpdate = true;
					end
					iconf1.spell.hide = false
					iconf2.spell.hide = false
				end
			end
		elseif form == CAT_FORM then
			if self.frame.pointer[HDH_POWER_KEY[2]] and self.frame.pointer[HDH_POWER_KEY[3]] then 
				if self.frame.pointer[HDH_POWER_KEY[2]].spell then self.frame.pointer[HDH_POWER_KEY[2]].spell.hide = true end
				if self.frame.pointer[HDH_POWER_KEY[3]].spell then self.frame.pointer[HDH_POWER_KEY[3]].spell.hide = true end
			end
			
			count = UnitPower('player', HDH_POWER_TYPE["COMBO_POINTS"])
			local iconf = self.frame.pointer[HDH_POWER_KEY[1]] -- 콤보 아이콘이고 콤보의 인덱스는 항상 마지막이다
			if iconf and iconf.spell then 
				iconf.spell.count = count 
				iconf.spell.hide = false
				if iconf.spell.count > 0 then
					iconf.spell.isUpdate = true
				end
			end
		else
			for i = 1, #self.frame.icon do
				if self.frame.icon[i].spell then self.frame.icon[i].spell.hide = true end
			end
		end
		-- 연계
		
		self:UpdateIcons()
		if ((count or 0) ~= 0) or DB_OPTION.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end
	
	function HDH_POWER_DRUID_TRACKER:CreateData()
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		talent[self.name] = {}
		auraList = talent[self.name]
		for i = 1 , #HDH_POWER_NAME do
			local new = {}
			auraList[#auraList+1] = new
			new.Key = HDH_POWER_KEY[i]
			new.No = i
			new.ID = 0
			new.Name = HDH_POWER_NAME[i]
			new.Always = true
			new.Glow = false
			new.Texture = HDH_POWER_TEXTURE[i]
			if i == 3 then
				new.IsBuff = false
			else
				new.IsBuff = true
			end
			new.IsItem = false
		end
	end
	
	function HDH_POWER_DRUID_TRACKER:InitIcons()
		local ret = super.InitIcons(self)
		if ret > 0 then
			self.frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
			if self.frame.pointer[HDH_POWER_KEY[2]] then
				self.frame.pointer[HDH_POWER_KEY[2]]:SetScript("OnUpdate", HDH_POWER_DRUID_TRACKER_OnUpdate)
			end
		end
	end
	
	function HDH_POWER_DRUID_TRACKER:OnEvent(event, unit, powerType)
		if event == "UPDATE_SHAPESHIFT_FORM" then
			if self.parent then
				self.parent:Update()
			end
		else
			super.OnEvent(self, event, unit, powerType)
		end
	end
------------------------------------
end  -- HDH_POWER_DRUID_TRACKER class
------------------------------------