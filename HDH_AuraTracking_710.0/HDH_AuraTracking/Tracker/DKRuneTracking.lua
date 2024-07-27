HDH_DK_RUNE_TRACKER = {}
local MyClassKor, MyClass = UnitClass("player");

local MAX_RUNES = 6;
local L_POWRE_RUNE = "자원:룬";
HDH_POWER = {}
HDH_POWER[L_POWRE_RUNE] 	= {power_type="RUNE", 	power_index = 5,	color={1.00, 0.50, 0.25}, texture = "Interface\\Icons\\Spell_Deathknight_FrostPresence"};

if MyClass == "DEATHKNIGHT" then
	HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = L_POWRE_RUNE -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
	HDH_GET_CLASS_NAME[L_POWRE_RUNE] = "HDH_DK_RUNE_TRACKER";
end 
HDH_GET_CLASS[L_POWRE_RUNE] = HDH_DK_RUNE_TRACKER

HDH_OLD_TRACKER["DeathKnight_rune"] = L_POWRE_RUNE; -- 예전 버전 이름
	
------------------------------------
do  -- HDH_DK_RUNE_TRACKER class
------------------------------------
	setmetatable(HDH_DK_RUNE_TRACKER, HDH_C_TRACKER) -- 상속
	HDH_DK_RUNE_TRACKER.__index = HDH_DK_RUNE_TRACKER
	local super = HDH_C_TRACKER
	
	-- 매 프레임마다 bar frame 그려줌, 콜백 함수
	local function DK_OnUpdateCooldown(self)
		local spell = self:GetParent():GetParent().spell
		if not spell then self:Hide() return end
		
		spell.curTime = GetTime()
		if spell.curTime - (spell.delay or 0) < HDH_TRACKER.ONUPDATE_FRAME_TERM then return end -- 10프레임
		spell.delay = spell.curTime
		spell.remaining = spell.endTime - spell.curTime

		if spell.remaining > 0 and spell.duration > 0 then
			self:GetParent():GetParent():GetParent().parent:UpdateTimeText(self:GetParent():GetParent().timetext, spell.remaining);
			if  self:GetParent():GetParent():GetParent().parent.option.base.cooldown ~= HDH_TRACKER.COOLDOWN_CIRCLE then
				self:SetValue(spell.endTime - (spell.curTime - spell.startTime))
			end
		end
		-- if self:GetParent():GetParent():GetParent().parent.option.bar.enable and self:GetParent():GetParent().spell.duration > HDH_C_TRACKER.GlobalCooldown then
			-- self:GetParent():GetParent().bar:SetValue(self:GetParent():GetParent():GetParent().parent.option.bar.fill_bar and GetTime() or spell.startTime+spell.remaining);
		-- end
	end
	
	function HDH_DK_RUNE_TRACKER:CreateData(spec)
		local talent = DB_AURA.Talent[spec] 
		if not talent then return end 	
		talent[self.name] = {}
		local auraList = talent[self.name]
	
		for i = 1 , MAX_RUNES do
			local new = {}
			new.Key = HDH_POWER[self.type].power_type..i
			new.Name = HDH_POWER[self.type].power_type..i
			new.Texture = HDH_POWER[self.type].texture
			new.No = i
			new.ID = 0
			new.Always = true
			new.Glow = false
			new.IsItem = false
			auraList[#auraList+1] = new
		end
		DB_OPTION[self.name].line = 6;
	end
	
	function HDH_DK_RUNE_TRACKER:IsHaveData(spec)
		local talent = DB_AURA.Talent[spec] 
		if not talent then return end 	
		local auraList = talent[self.name]
		local ret = 0;
		for i = 1, #auraList do
			if string.find(auraList[i].Key, HDH_POWER[self.type].power_type)  then
				ret = ret +1
			end
		end
		if MAX_RUNES == ret then
			return ret;
		else
			return false;
		end
	end
	
	function HDH_DK_RUNE_TRACKER:UpdateIcon(f)
		-- local f = rune;
		-- if type(rune) == "number" then f = self.frame.pointer[HDH_PT_KEY..rune]
								  -- else f = rune end
		if not f then return end
		
		-- local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		-- local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		-- local size = self.option.icon.size + self.option.icon.margin -- 아이콘 간격 띄우는 기본값
		-- local revers_v = self.option.base.revers_v -- 상하반전
		-- local revers_h = self.option.base.revers_h -- 좌우반전
		-- local icons = self.frame.icon
		
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		if not f.spell then return end
		if f.spell.startTime ~= 0 then
			if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
			if f.spell.count == 0 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count) end
			f.cd:Show()
			f.icon:SetAlpha(self.option.icon.off_alpha)
			f.border:SetAlpha(self.option.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
			if self.option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE then
				f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
			else
				f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
				f.cd:SetValue(f.spell.endTime - (GetTime() - f.spell.startTime))
			end
			self:SetGlow(f, false)
			f:Show()
			if self.option.bar.enable and f.bar then
				self:UpdateBarValue(f, false);
			end
		else
			if self.option.bar.enable and f.bar then self:UpdateBarValue(f, true); end
			f.icon:SetDesaturated(nil)
			f.timetext:SetText("");
			if not f.spell.hide_icon and f.spell.always then 
				f.icon:SetAlpha(self.option.icon.on_alpha)
				f.border:SetAlpha(self.option.icon.on_alpha)
				f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
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
	
	function HDH_DK_RUNE_TRACKER:UpdateIcons()
		for k,v in pairs(self.frame.icon) do
			self:UpdateIcon(v)
		end
		-- self:Update_Layout()
	end
	
	function HDH_DK_RUNE_TRACKER:UpdateSetting()
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
	
	-- function HDH_DK_RUNE_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
		-- super.UpdateIconSettings(self, f)
		-- if f.cooldown1:GetScript("OnUpdate") ~= DK_OnUpdateCooldown or 
		   -- f.cooldown2:GetScript("OnUpdate") ~= DK_OnUpdateCooldown then
			-- f.cooldown1:SetScript("OnUpdate", DK_OnUpdateCooldown)
			-- f.cooldown2:SetScript("OnUpdate", DK_OnUpdateCooldown)
		-- end
	-- end
	
	function HDH_DK_RUNE_TRACKER:Update_Layout()
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
		local cnt = #self.frame.icon;
		local reorder = {};
		local tmp;
		if self.OrderFunc then self:OrderFunc(self) end 
		for i = 1 , cnt do
			f = self.frame.icon[i]
			if f and f.spell then
				if f:IsShown() then
					f:ClearAllPoints()
					f:SetPoint('RIGHT', self.frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					show_index = show_index + 1
					if i % line == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					if f.spell.remaining > 0 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
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
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	function HDH_DK_RUNE_TRACKER:UpdateRune(runeIndex, isEnergize)
		local ret = false;
		local start, duration, runeReady = GetRuneCooldown(runeIndex);
		if self and self.frame.pointer[runeIndex] then
			local spell = self.frame.pointer[runeIndex].spell
			if start and spell then
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
		
		return ret;
	end
	
	function HDH_DK_RUNE_TRACKER:UpdateRuneType(runeIndex)
		local runeType = GetRuneType(runeIndex)
		local iconf = self.frame.pointer[runeIndex]
		if not iconf then return end
		iconf.spell.type = runeType
	end

	function HDH_DK_RUNE_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or UI_LOCK then return end
		for i = 1 , MAX_RUNES do
			self:UpdateRune(i)
			--self:UpdateRuneType(i)
		end
		self:UpdateIcons()
	end
	
	function HDH_DK_RUNE_TRACKER:InitIcons()
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		if not talent[self.name] then
			talent[self.name] = {}
		end
		local auraList = talent[self.name]
		local name, icon, spellID, isItem
		local spell 
		local f
		local ret = 0
		
		self.frame.pointer = {}
		if self:IsHaveData(self:GetSpec()) then 
			ret = 0
			for i = 1, #auraList do
				if string.find(auraList[i].Key, HDH_POWER[self.type].power_type) and not self:IsIgnoreSpellByTalentSpell(auraList[i])  then
					ret = ret +1
					f = self.frame.icon[ret]
					self.frame.pointer[i] = f
					if f:GetParent() == nil then f:SetParent(self.frame) end
					spell = {}
					spell.key = auraList[i].Key
					spell.id = auraList[i].ID
					spell.no = auraList[i].No
					spell.name = auraList[i].Name
					spell.icon = auraList[i].Texture
					spell.glow = auraList[i].Glow
					spell.glowCount = auraList[i].GlowCount
					spell.glowV1= auraList[i].GlowV1
					spell.always = auraList[i].Always
					spell.showValue = auraList[i].ShowValue;
					spell.startSound = auraList[i].StartSound
					spell.endSound = auraList[i].EndSound
					spell.conditionSound = auraList[i].ConditionSound
					spell.type = HDH_POWER[self.type].power_type;
					spell.power_index = HDH_POWER[self.type].power_index;
					spell.max = UnitPowerMax('player', spell.power_index);
					spell.v1 = 0
					spell.duration = 0
					spell.count = 0
					spell.remaining = 0
					spell.startTime = 0
					spell.endTime = 0
					spell.happenTime = 0;
					spell.isItem = false;
					spell.charges = {};
					spell.charges.duration = 0;
					spell.charges.count = 0
					spell.charges.remaining = 0
					spell.charges.startTime = 0
					spell.charges.endTime = 0
					f.spell = spell
					f.icon:SetTexture(spell.icon or "Interface\\ICONS\\TEMP")
					f.border:SetVertexColor(unpack(self.option.icon.buff_color))
					self:ChangeCooldownType(f, self.option.base.cooldown)
					self:ActionButton_HideOverlayGlow(f)
					f:Hide()
					spell.startSound = auraList[i].StartSound
					spell.endSound = auraList[i].EndSound
					spell.conditionSound = auraList[i].ConditionSound
					if spell.startSound then
						f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
						f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
					end
					if spell.endSound then
						f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
						f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
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
		self:LoadOrderFunc();
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		return ret;
	end
	
	function HDH_DK_RUNE_TRACKER:OnEvent(event, ...)
		if not self.parent then return end
		if ( event == "RUNE_POWER_UPDATE" ) then
			local runeIndex, isEnergize = ...;
			if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES then
				-- self.parent:UpdateRune(runeIndex, isEnergize)
				-- self.parent:UpdateIcon(runeIndex)
				self.parent:Update();
			end
		elseif ( event == "RUNE_TYPE_UPDATE" ) then
			local runeIndex = ...;
			if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
				-- self.parent:UpdateRuneType(runeIndex)
				-- self.parent:UpdateIcon(runeIndex)
				self.parent:Update();
			end
		end
	end
	
------------------------------------
end  -- HDH_DK_RUNE_TRACKER class
------------------------------------