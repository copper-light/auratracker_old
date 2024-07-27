local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;
local MAX_RUNES = 6;
local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0.6, 0.6},
	[RUNETYPE_UNHOLY] = {0.6, 1, 0.6},
	[RUNETYPE_FROST] = {0.6, 1, 1},
	[RUNETYPE_DEATH] = {1, 0.6, 1},
}

-- local runeTexture = {
	-- [RUNETYPE_BLOOD] = "Interface\\ICONS\\Priest_icon_Chakra_red",
	-- [RUNETYPE_UNHOLY] = "Interface\\ICONS\\Priest_icon_Chakra_green",
	-- [RUNETYPE_FROST] = "Interface\\ICONS\\Priest_icon_Chakra_blue",
	-- [RUNETYPE_DEATH] = "Interface\\AddOns\\HDH_AuraTracking_Class\\Priest_icon_Chakra_purple",
-- }

HDH_POWER_DK_TRACKER = {}


local MyClassKor, MyClass = UnitClass("player");

if MyClass == "DEATHKNIGHT" then
	HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = "DeathKnight_rune" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
end
HDH_GET_CLASS["DeathKnight_rune"] = HDH_POWER_DK_TRACKER
	
------------------------------------
do  -- HDH_POWER_DK_TRACKER class
------------------------------------
	setmetatable(HDH_POWER_DK_TRACKER, HDH_POWER_TRACKER) -- 상속
	HDH_POWER_DK_TRACKER.__index = HDH_POWER_DK_TRACKER
	local super = HDH_POWER_TRACKER
	
	-- 매 프레임마다 bar frame 그려줌, 콜백 함수
	function DK_OnUpdateCooldown(self)
		local spell = self:GetParent().spell
		if not spell then self:Hide() return end
		
		spell.curTime = GetTime()
		if spell.curTime - (spell.delay or 0) < 0.1 then return end -- 10프레임
		spell.delay = spell.curTime
		spell.remaining = spell.endTime - spell.curTime

		if spell.remaining > 0.1 and spell.duration > 0 then
			if spell.remaining > 5 then
				self.timetext:SetTextColor(unpack(self:GetParent():GetParent().parent.option.font.textcolor))
			else 
				self.timetext:SetTextColor(unpack(self:GetParent():GetParent().parent.option.font.textcolor_5s))
			end
			if spell.remaining > 60 then
				self.timetext:SetText(('%d:%02d'):format((spell.remaining)/60,spell.remaining%60))
			else
				self.timetext:SetText(('%d'):format(spell.remaining))
			end
			if  self:GetParent():GetParent().parent.option.base.cooldown ~= COOLDOWN_CIRCLE then
				self:SetValue(spell.endTime - (spell.curTime- spell.startTime))
			end
		end
	end
	
	function HDH_POWER_DK_TRACKER:UpdateTalentInfo()
		local id = DB_AURA.Talent[GetSpecialization()].ID
		if MyClass == "DEATHKNIGHT" then
			if id == 250 then -- blood
				HDH_POWER_INDEX = 5
				HDH_POWER_TYPE  = {RUNES = HDH_POWER_INDEX}
				HDH_POWER_KEY = {HDH_PT_KEY}
				HDH_POWER_NAME = {"Rune"}
				HDH_POWER_TEXTURE = { "Interface\\ICONS\\Spell_Deathknight_BloodPresence" }
			elseif id == 251 then -- frost
				HDH_POWER_INDEX = 5
				HDH_POWER_TYPE  = {RUNES = HDH_POWER_INDEX}
				HDH_POWER_KEY = {HDH_PT_KEY}
				HDH_POWER_NAME = {"Rune"}
				HDH_POWER_TEXTURE = { "Interface\\ICONS\\Spell_Deathknight_FrostPresence" }
			else -- unholy
				HDH_POWER_INDEX = 5
				HDH_POWER_TYPE  = {RUNES = HDH_POWER_INDEX}
				HDH_POWER_KEY = {HDH_PT_KEY}
				HDH_POWER_NAME = {"Rune"}
				HDH_POWER_TEXTURE = { "Interface\\ICONS\\Spell_Deathknight_UnholyPresence" }
			end
			
		end
	end
	
	function HDH_POWER_DK_TRACKER:UpdateIcon(rune)
		local f
		if type(rune) == "number" then f = self.frame.pointer[HDH_PT_KEY..rune]
								  else f = rune end
		if not f then return end
		
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size + self.option.icon.margin -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local icons = self.frame.icon
		
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		if not f.spell then return end
		if f.spell.remaining > 0 then
			if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
			if f.spell.count == 0 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count) end
			if f.spell.duration == 0 then f.cd:Hide() 
									 else f.cd:Show() end
			
			f.icon:SetAlpha(self.option.icon.off_alpha)
			f.border:SetAlpha(self.option.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
			if self.option.base.cooldown == COOLDOWN_CIRCLE then
				f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
			else
				f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
			end
			self:SetGlow(f, false)
			f:Show()
		else
			f.icon:SetDesaturated(nil)
			if not f.spell.hide and f.spell.always then 
				f.icon:SetAlpha(self.option.icon.on_alpha)
				f.border:SetAlpha(self.option.icon.on_alpha)
				if f.spell.isBuff then 
					f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
				else
					f.border:SetVertexColor(unpack(self.option.icon.debuff_color)) 
				end
				f.counttext:SetText(nil)
				f.cd:Hide() 
				self:SetGlow(f, true)
				f:Show()
			else
				f:Hide()
			end
		end
		self:Update_Layout()
	end
	
	function HDH_POWER_DK_TRACKER:UpdateIcons()
		for k,v in pairs(self.frame.icon) do
			self:UpdateIcon(v)
		end
		--self:Update_Layout()
	end
	
	function HDH_POWER_DK_TRACKER:UpdateSetting()
		if not self or not self.frame then return end
		self.frame:SetSize(self.option.icon.size, self.option.icon.size)
		if UI_LOCK then
			if self.frame.text then self.frame.text:SetPoint("TOPLEFT", self.frame, "BOTTOMRIGHT", -5, 12) end
		end
		if not self.frame.icon then return end
		for k,iconf in pairs(self.frame.icon) do
			self:UpdateIconSettings(iconf)
			if self:IsGlowing(iconf) then
				self:SetGlow(iconf, false)
				self:SetGlow(iconf, true)
			end
			self:ChangeCooldownType(iconf, self.option.base.cooldown)
			if iconf.spell and (iconf.spell.remaining or 0) > 0.1 then
				iconf.icon:SetAlpha(self.option.icon.off_alpha)
				iconf.border:SetAlpha(self.option.icon.off_alpha)
			else
				iconf.icon:SetAlpha(self.option.icon.on_alpha)
				iconf.border:SetAlpha(self.option.icon.on_alpha)
			end
		end	
		self.option.base.x = self.frame:GetLeft()
		self.option.base.y = self.frame:GetBottom()
	end
	
	function HDH_POWER_DK_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
		if f.cooldown1:GetScript("OnUpdate") ~= DK_OnUpdateCooldown or 
		   f.cooldown2:GetScript("OnUpdate") ~= DK_OnUpdateCooldown then
			f.cooldown1:SetScript("OnUpdate", DK_OnUpdateCooldown)
			f.cooldown2:SetScript("OnUpdate", DK_OnUpdateCooldown)
		end
		super.UpdateIconSettings(self, f)
	end
	
	function HDH_POWER_DK_TRACKER:ChangeCooldownType(f, cooldown_type)
		if cooldown_type == COOLDOWN_UP then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_DOWN  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_LEFT  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_RIGHT then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		else 
			f.cd = f.cooldown2
			f.cd:SetReverse(false)
			f.cooldown1:Hide()
		end
	end
	
	function HDH_POWER_DK_TRACKER:Update_Layout()
		if not self.option or not self.frame.icon then return end
		local f, spell
		local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size -- 아이콘 간격 띄우는 기본값
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		for i = 1 , #self.frame.icon do
			f = self.frame.icon[i]
			if f and f.spell then
				if f:IsShown() then
					f:ClearAllPoints()
					f:SetPoint('RIGHT', self.frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					show_index = show_index + 1
					if i % line == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					if f.spell.remaining > 0.1 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
				else
					if self.option.base.fix then
						f:ClearAllPoints()
						f:SetPoint('RIGHT', self.frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
						show_index = show_index + 1
						if i % line == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					end
				end
			end
		end
		if UI_LOCK or ret > 0 or self.option.icon.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end
	
	function HDH_POWER_DK_TRACKER:UpdateRune(runeIndex, isEnergize)
		local start, duration, runeReady = GetRuneCooldown(runeIndex);
		if self and self.frame.pointer[HDH_PT_KEY..runeIndex] then
			local spell = self.frame.pointer[HDH_PT_KEY..runeIndex].spell
			if not runeReady and spell then
				spell.duration = duration
				spell.startTime = start
				spell.endTime = start + duration
				spell.remaining = spell.endTime - GetTime()
			else
				spell.duration = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.remaining = 0 
			end
		end
	end
	
	function HDH_POWER_DK_TRACKER:UpdateRuneType(runeIndex)
		local runeType = GetRuneType(runeIndex)
		local iconf = self.frame.pointer[HDH_PT_KEY..runeIndex]
		if not iconf then return end
		iconf.spell.type = runeType
	end

	function HDH_POWER_DK_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or UI_LOCK then return end
		for i = 1 , MAX_RUNES do
			self:UpdateRune(i)
			--self:UpdateRuneType(i)
		end
		self:UpdateIcons()
	end
	
	function HDH_POWER_DK_TRACKER:CreateData(max)
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 	
		talent[self.name] = {}
		local auraList = talent[self.name]
	
		for i = 1 , MAX_RUNES do
			local new = {}
			new.Key = HDH_PT_KEY..i
			new.Name = HDH_POWER_NAME[1]..i
			new.Texture = HDH_POWER_TEXTURE[1]
			new.No = i
			new.ID = 0
			new.Always = true
			new.Glow = false
			new.IsItem = false
			auraList[#auraList+1] = new
		end
	end
	
	function HDH_POWER_DK_TRACKER:InitIcons()
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
			
			--local max = UnitPowerMax('player', HDH_POWER_INDEX);
			--self.unitPowerMax = max;
			if ret ~= MAX_RUNES then 
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
					spell.glowCount = auraList[i].GlowCount
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
					
					spell.startSound = auraList[i].StartSound
					spell.endSound = auraList[i].EndSound
					spell.conditionSound = auraList[i].ConditionSound
					if spell.startSound then
						iconFrame.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
						iconFrame.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
					end
					if spell.endSound then
						iconFrame.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
						iconFrame.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
					end
				end
			end
			
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterEvent("RUNE_POWER_UPDATE");
			self.frame:RegisterEvent("RUNE_TYPE_UPDATE");
			self.frame:RegisterEvent('UNIT_MAXPOWER')
			self:Update()
		else
			self.frame:UnregisterAllEvents()
			self.frame:Hide()
		end
		
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		return ret;
	end
	
	function HDH_POWER_DK_TRACKER:OnEvent(event, ...)
		if not self.parent then return end
		if ( event == "RUNE_POWER_UPDATE" ) then
			local runeIndex, isEnergize = ...;
			if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES then
				self.parent:UpdateRune(runeIndex, isEnergize)
				self.parent:UpdateIcon(runeIndex)
			end
		elseif ( event == "RUNE_TYPE_UPDATE" ) then
			local runeIndex = ...;
			if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
				self.parent:UpdateRuneType(runeIndex)
				self.parent:UpdateIcon(runeIndex)
			end
		end
	end
	
------------------------------------
end  -- HDH_POWER_DK_TRACKER class
------------------------------------