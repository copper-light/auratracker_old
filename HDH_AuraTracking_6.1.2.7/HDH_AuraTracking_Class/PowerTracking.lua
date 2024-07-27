CT_VERSION = 0.1
HDH_POWER_TRACKER = {}
local MyClassKor, MyClass = UnitClass("player");
if MyClass ~= "DRUID" and MyClass ~= "DEATHKNIGHT" then
	HDH_UNIT_LIST[#HDH_UNIT_LIST+1] = "2차 직업 자원" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
end

HDH_GET_CLASS["2차 직업 자원"] = HDH_POWER_TRACKER -- 

HDH_PT_KEY = "HDH_PT"
HDH_POWER_TYPE  = nil
HDH_POWER_NAME = nil
HDH_POWER_TEXTURE = nil
------------------------------------
do -- HDH_POWER_TRACKER class
------------------------------------
	setmetatable(HDH_POWER_TRACKER, HDH_TRACKER) -- 상속
	HDH_POWER_TRACKER.__index = HDH_POWER_TRACKER
	local super = HDH_TRACKER
	
	function HDH_POWER_TRACKER:UpdateTalentInfo()
		local id = DB_AURA.Talent[GetSpecialization()].ID
		if MyClass == "PALADIN" then
			HDH_POWER_TYPE = {HOLY_POWER = 9}
			HDH_POWER_KEY = {HDH_PT_KEY..1}
			HDH_POWER_NAME = {"신성한 힘"}
			HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Enchant_ShardBrilliantLarge"}
		elseif MyClass == "ROGUE" then
			HDH_POWER_TYPE = {COMBO_POINTS = 4}
			HDH_POWER_KEY = {HDH_PT_KEY..1}
			HDH_POWER_NAME = {"연계 점수"}
			HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Misc_Gem_Pearl_04"}
		elseif MyClass == "PRIEST" then
			if id == 258  then -- 암사
				HDH_POWER_TYPE = {SHADOW_ORBS = 13}
				HDH_POWER_KEY = {HDH_PT_KEY..1}
				HDH_POWER_NAME = {"어둠의 구슬"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Elemental_Primal_Shadow"}
			end
		--elseif MyClass == "DEATHKNIGHT" then

		elseif MyClass == "WARLOCK" then
			if id == 265  then -- 고통
				HDH_POWER_TYPE = {SOUL_SHARDS = 7}
				HDH_POWER_KEY = {HDH_PT_KEY..1}
				HDH_POWER_NAME = {"영혼의 수정"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Jewelcrafting_ShadowsongAmethyst_02"} -- Trade_Archaeology_NaaruCrystal
			elseif id == 266 then -- 악마
				HDH_POWER_TYPE = { DEMONIC_FURY = 15 }
				HDH_POWER_KEY = {HDH_PT_KEY..1}
				HDH_POWER_NAME = {"악마의 분노"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\Ability_Warlock_Eradication"}
			elseif id == 267 then -- 파괴
				HDH_POWER_TYPE = {BURNING_EMBERS = 14}
				HDH_POWER_KEY = {HDH_PT_KEY..1}
				HDH_POWER_NAME = {"타오르는 불씨"}
				HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_SummerFest_FireSpirit"}
			end
		elseif MyClass == "MONK" then
			HDH_POWER_TYPE = {CHI = 12}
			HDH_POWER_KEY = {HDH_PT_KEY..1}
			HDH_POWER_NAME = {"기"}
			HDH_POWER_TEXTURE = {"Interface\\Icons\\INV_Misc_Gem_Pearl_06"}
		end
	end
	
	function HDH_POWER_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		super.InitVariblesOption(self)
	end

	function HDH_POWER_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			self.frame:UnregisterAllEvents()
			self.frame.namePointer = nil
		end
		super.Release(self)
	end
	
	function HDH_POWER_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
		local icon = self.frame.icon[idx]
		--icon:SetScript("OnEvent", nil)
		icon:Hide()
		icon:SetParent(nil)
		icon.spell = nil
		self.frame.icon[idx] = nil
	end
	
	function HDH_POWER_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
		super.UpdateIconSettings(self,f)
		f.counttext:SetJustifyH('CENTER')
		f.counttext:SetJustifyV('CENTER')
		f.counttext:SetPoint('TOPLEFT', f, 'TOPLEFT', -20, 0)
		f.counttext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 20, 0)
	end

	function HDH_POWER_TRACKER:UpdateSetting() -- HDH_TRACKER override
		super.UpdateSetting(self)
	end

	function HDH_POWER_TRACKER:UpdateIcons()  -- HDH_TRACKER override
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size + self.option.icon.margin -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local icons = self.frame.icon
		
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				f.spell.isUpdate = false
				if f.spell.count == 0 then f.counttext:SetText(nil)
									 else f.counttext:SetText(f.spell.count) end
				if f.spell.duration == 0 then f.cd:Hide() 
										 else f.cd:Show() end
				f.icon:SetDesaturated(nil)
				f.icon:SetAlpha(self.option.icon.on_alpha)
				f.border:SetAlpha(self.option.icon.on_alpha)
				if f.spell.isBuff then 
					f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
				else
					f.border:SetVertexColor(unpack(self.option.icon.debuff_color)) 
				end
				if self.option.base.cooldown == COOLDOWN_CIRCLE then
					f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
				else
					f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then row = row + size; col = 0
								 else col = col + size end
				ret = ret + 1
				self:SetGlow(f, true)
				f:Show()
			else
				if not f.spell.hide and f.spell.always then 
					if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
					f.icon:SetAlpha(self.option.icon.off_alpha)
					f.border:SetAlpha(self.option.icon.off_alpha)
					f.border:SetVertexColor(0,0,0)
					if f.spell.count > 0 then
						f.counttext:SetText(f.spell.count)
					else
						f.counttext:SetText(nil)
					end
					f.cd:Hide() self:SetGlow(f, false)
					--f:ClearAllPoints()
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					i = i + 1
					if i % line == 0 then row = row + size; col = 0
									 else col = col + size end
					f:Show()
				else
					if self.option.base.fix then
						i = i + 1
						if i % line == 0 then row = row + size; col = 0
										 else col = col + size end
					end
					f:Hide()
				end
			end
		end
		return ret
	end

	function HDH_POWER_TRACKER:Update(power_idx) -- HDH_TRACKER override
		if not self.frame or UI_LOCK then return end
		if not power_idx then 
			for k,v in pairs(HDH_POWER_TYPE) do
				power_idx = v
				break
			end
		end
		if self.frame.icon and self.frame.icon[1] and self.frame.icon[1].spell  then
			local iconf = self.frame.icon[1] 
			local spell = iconf.spell
			if MyClass == "WARLOCK" and DB_AURA.Talent[GetSpecialization()].ID == 267 then
				spell.count = (UnitPower('player', power_idx, true) /10)
			else
				spell.count = UnitPower('player', power_idx)
			end
			if spell.count >= 1 then
				spell.isUpdate = true
			end
		end
		self:UpdateIcons()
		if DB_OPTION.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end
	
	function HDH_POWER_TRACKER:CreateData()
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 	
		talent[self.name] = {}
		local auraList = talent[self.name]
		for i = 1 , #HDH_POWER_NAME do
			local new = {}
			new.Key = HDH_POWER_KEY[i]
			new.Name = HDH_POWER_NAME[i]
			new.Texture = HDH_POWER_TEXTURE[i]
			new.No = i
			new.ID = 0
			new.Always = true
			new.Glow = false
			new.IsItem = false
			auraList[#auraList+1] = new
		end
	end

	function HDH_POWER_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		if not talent[self.name] then
			talent[self.name] = {}
		end
		local auraList = talent[self.name]
		local name, icon, spellID, isItem
		local spell 
		local iconFrame
		local ret = 0
		self:UpdateTalentInfo()
		self.frame.pointer = {}
		if HDH_POWER_TYPE then
			for i = 1, #auraList do
				if string.find(auraList[i].Key, HDH_PT_KEY)  then
					ret = ret +1
				end
			end
			if ret ~= #HDH_POWER_NAME then 
				self:CreateData()
				auraList = talent[self.name]
				if OptionFrame:IsShown() then
					OptionFrame:Hide()
					OptionFrame:Show()
				end
			end
			ret = 0
			for i = 1, #auraList do
				if string.find(auraList[i].Key, HDH_PT_KEY)  then
					ret = ret +1
					iconFrame = self.frame.icon[i]
					if iconFrame:GetParent() == nil then iconFrame:SetParent(self.frame) end
					spell = {}
					self.frame.pointer[auraList[i].Key] = self.frame.icon[i]
					spell.key = auraList[i].Key
					spell.id = auraList[i].ID
					spell.no = auraList[i].No
					spell.name = auraList[i].Name
					spell.icon = auraList[i].Texture
					spell.glow = auraList[i].Glow
					spell.glowCount = auraList[i].GlowCount or 0
					spell.always = auraList[i].Always
					spell.isBuff = auraList[i].isBuff or true
					spell.duration = 0
					spell.count = 0
					spell.remaining = 0
					spell.startTime = 0
					spell.endTime = 0
					
					spell.isItem = false
					
					iconFrame.spell = spell
					iconFrame.icon:SetTexture(spell.icon or "Interface\\ICONS\\TEMP")
					iconFrame.border:SetVertexColor(unpack(self.option.icon.buff_color))
					self:ChangeCooldownType(iconFrame, self.option.base.cooldown)
					ActionButton_HideOverlayGlow(iconFrame)
					iconFrame:Hide()
				end
			end
			
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterEvent('UNIT_POWER')
			self:Update()
		else
			self.frame:UnregisterAllEvents()
			self.frame:Hide()
		end
		
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		return ret
	end
	
	function HDH_POWER_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
	
	function HDH_POWER_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_POWER_TRACKER:OnEvent(event, unit, powerType)
		if self and self.parent and event == "UNIT_POWER" and unit == 'player' and HDH_POWER_TYPE[powerType] then 
			if not UI_LOCK then
				self.parent:Update(HDH_POWER_TYPE[powerType])
			end
		end
	end
------------------------------------
end -- HDH_POWER_TRACKER class
------------------------------------
