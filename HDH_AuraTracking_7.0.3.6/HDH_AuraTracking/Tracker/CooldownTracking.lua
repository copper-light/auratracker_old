﻿HDH_C_TRACKER = {}
HDH_C_TRACKER.GlobalCooldown = 2;
HDH_C_TRACKER.EndCooldown = 0.12;

HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = "Player_cooldown" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
HDH_GET_CLASS["Player_cooldown"] = HDH_C_TRACKER -- at 의 new 함수에서 cooldown 의 클래스를 불러오는게 가능하도록 클래스 리스트에 추가해둠

HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = "Pet_cooldown" -- 팻 전용 쿨다운 - 팻이 소환 되었을때만 출력하려고 구분함.
HDH_GET_CLASS["Pet_cooldown"] = HDH_C_TRACKER; -- 팻 전용 쿨다운

--- 예전 이름들 호환성 위해서 ---
HDH_PARSE_OLD_TRACKER["cooldown"] = "Player_cooldown";

------------------------------------
-- spell timer
------------------------------------

local function CT_Timer_Func(self)
	if self and self.arg then
		local tracker = self.arg:GetParent() and self.arg:GetParent().parent or nil;
		if tracker then
			if( tracker:Update_Icon(self.arg)) or (not tracker.option.icon.always_show and not UnitAffectingCombat("player")) then
				tracker:Update_Layout()
			end
		end
		self.arg.timer = nil
	end
end

local function CT_HasTImer(f)
	return f.timer and true or false
end	

local function CT_StartTimer(f, maxtime)
	if f and not f.timer then
		f.timer = C_Timer.NewTimer(f.spell.remaining - (maxtime or 0), CT_Timer_Func)
		f.timer.arg = f
	end
end

local function CT_StopTimer(f)
	if f and f.timer then
		f.timer:Cancel()
		f.timer = nil
	end
end

------------------------------------
-- sound
------------------------------------
function HDH_C_OnShowCooldown(self)
	if self:GetParent().spell and self:GetParent().spell.startSound and not OptionFrame:IsShown() then
		if (self:GetParent().spell.duration - self:GetParent().spell.remaining) < 0.5 then
			if self:GetParent().spell.duration > HDH_C_TRACKER.GlobalCooldown then
				HDH_PlaySoundFile(self:GetParent().spell.startSound, "SFX")
			end
		end
	end
end

function HDH_C_OnHideCooldown(self)
	if self:GetParent().spell and self:GetParent().spell.endSound and not OptionFrame:IsShown() then
		if self:GetParent().spell.duration > HDH_C_TRACKER.GlobalCooldown then
			HDH_PlaySoundFile(self:GetParent().spell.endSound, "SFX")
		end
	end
end

-----------------------------------
-- OnUpdate icon
-----------------------------------
local spell
-- 매 프레임마다 bar frame 그려줌, 콜백 함수
function CT_OnUpdateCooldown(self)
	spell = self:GetParent().spell
	if not spell then self:Hide() return end
	
	spell.curTime = GetTime();
	if spell.curTime - (spell.delay or 0) < 0.025 then return end -- 10프레임
	spell.delay = spell.curTime;
	
	spell.remaining = spell.endTime - spell.curTime;
	if spell.remaining > 0.1 and spell.duration > 0 then
		if not spell.isCharging then
			if spell.remaining > 5 then
				self:GetParent().timetext:SetTextColor(unpack(self:GetParent():GetParent().parent.option.font.textcolor))
			else 
				self:GetParent().timetext:SetTextColor(unpack(self:GetParent():GetParent().parent.option.font.textcolor_5s))
			end
			if spell.remaining <= 60 then
				self:GetParent().timetext:SetText(('%d'):format(spell.remaining+1))
			else 
				self:GetParent().timetext:SetText(('%d:%02d'):format((spell.remaining+1)/60, (spell.remaining+1)%60))
			end
		end
		if  self:GetParent():GetParent().parent.option.base.cooldown ~= COOLDOWN_CIRCLE then
			self:SetValue(spell.endTime - (spell.curTime - spell.startTime))
		end
	else--[[
		self:GetParent():GetParent().parent:Update_Usable(self:GetParent())
		self:GetParent():GetParent().parent:SetChangeAble(self:GetParent(), true)
		self:GetParent():Show()]]
		--CT:Update_Layout()
		if not CT_HasTImer(self:GetParent()) then
			self:Hide()
			self:GetParent().timetext:SetText("");
			local t = {arg = self:GetParent()}
			CT_Timer_Func(t)
		end
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end 

function CT_OnUpdateIcon(self) -- 거리 체크는 onUpdate 에서 처리해야함
	if not self.spell then return end
	
	self.spell.curTime2 = GetTime();
	if self.spell.curTime2 - (self.spell.delay2 or 0) < 0.1 then return end -- 10프레임
	self.spell.delay2 = self.spell.curTime2;
	
	if self.spell.isCharging then
		self.spell.charges.remaining = self.spell.charges.endTime - self.spell.curTime2;
		if self.spell.charges.remaining > 5 then
			self.timetext:SetTextColor(unpack(self:GetParent().parent.option.font.textcolor))
		else 
			self.timetext:SetTextColor(unpack(self:GetParent().parent.option.font.textcolor_5s))
		end
		if self.spell.remaining <= 60 then
			self.timetext:SetText(('%d'):format(self.spell.charges.remaining+1))
		else 
			self.timetext:SetText(('%d:%02d'):format((self.spell.charges.remaining+1)/60, (self.spell.charges.remaining+1)%60))
		end
	end
	
	self.spell.newRange = IsSpellInRange(self.spell.name,"target"); -- 1 true, 0 false, nil not target
	if self.spell.preInRage ~= self.spell.newRange then
		self:GetParent().parent:Update_Usable(self);	
		self.spell.preInRage = self.spell.newRange;
	end
end

------------------------------------
-- HDH_C_TRACKER class
------------------------------------
do 
	setmetatable(HDH_C_TRACKER, HDH_TRACKER) -- 상속
	HDH_C_TRACKER.__index = HDH_C_TRACKER
	local super = HDH_TRACKER
	
	function HDH_C_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		super.InitVariblesOption(self)
		
		-- 쿨다운 테두리 컬러 설정 변수 추가
		if not DB_OPTION.icon.cooldown_color then DB_OPTION.icon.cooldown_color = {0,0,0} end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.cooldown_color then DB_OPTION[self.name].icon.cooldown_color = {0,0,0} end
	
		if DB_OPTION.icon.desaturation == nil then DB_OPTION.icon.desaturation = true end
		if DB_OPTION[self.name].icon and DB_OPTION[self.name].icon.desaturation == nil then DB_OPTION[self.name].icon.desaturation = true end
		
		if DB_OPTION.icon.max_time == nil then DB_OPTION.icon.max_time = 0 end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.max_time then DB_OPTION[self.name].icon.max_time = 0 end
		
		if DB_OPTION.icon.not_enough_mana_color == nil then DB_OPTION.icon.not_enough_mana_color = {0.5,0.5,1} end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.not_enough_mana_color then DB_OPTION[self.name].icon.not_enough_mana_color = {0.5,0.5,1} end
		
		if DB_OPTION.icon.out_range_color == nil then DB_OPTION.icon.out_range_color = {0.8,0.1,0.1} end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.out_range_color then DB_OPTION[self.name].icon.out_range_color = {0.8,0.1,0.1} end
	
		if DB_OPTION.icon.desaturation_not_mana == nil then DB_OPTION.icon.desaturation_not_mana = false end
		if DB_OPTION[self.name].icon and DB_OPTION[self.name].icon.desaturation_not_mana == nil then DB_OPTION[self.name].icon.desaturation_not_mana = false end
		
		if DB_OPTION.icon.desaturation_out_range == nil then DB_OPTION.icon.desaturation_out_range = false end
		if DB_OPTION[self.name].icon and DB_OPTION[self.name].icon.desaturation_out_range == nil then DB_OPTION[self.name].icon.desaturation_out_range = false end
	end

	function HDH_C_TRACKER:Release() -- HDH_TRACKER override
		super.Release(self)
	end
	
	function HDH_C_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
		local icon = self.frame.icon[idx]
		--icon:SetScript("OnEvent", nil)
		icon:UnregisterEvent("SPELL_UPDATE_CHARGES");
		icon:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
		icon:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
		icon:UnregisterEvent("BAG_UPDATE");
		icon:UnregisterEvent("BAG_UPDATE_COOLDOWN");
		icon:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
		icon:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
		icon:Hide()
		CT_StopTimer(icon)
		icon:SetParent(nil)
		icon.spell = nil
		self.frame.icon[idx] = nil
	end
	
	function HDH_C_TRACKER:ChangeCooldownType(f, cooldown_type)
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

	function HDH_C_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local prevf, f
		
		if icons then
			if #icons > 0 then count = #icons end
		end
		
		--local limit = 
		for i=1, count do
			f = icons[i]
			if not f:GetParent() then f:SetParent(self.frame) end
			if not f.icon:GetTexture() then
				f.icon:SetTexture("Interface\\ICONS\\TEMP")
			end
			f:ClearAllPoints()
			prevf = f
			local spell = {}
			spell.name = ""
			spell.icon = nil
			spell.always = true
			spell.id = 0
			spell.glow = false
			spell.count = 3+i
			spell.duration = 50*i
			spell.remaining = spell.duration
			spell.charges = {};
			spell.charges.duration = 0;
			spell.charges.endTime = 0;
			spell.endTime = curTime + spell.duration
			spell.startTime = curTime
			self:SetGameTooltip(f, false)
			self:ChangeCooldownType(f, option.base.cooldown)
			f.spell = spell
			f.counttext:SetText(i)
			f.timetext:Show();
			f.icon:SetVertexColor(1,1,1);
			spell.isCharging = false;
			spell.isAble = true
			if not f.cd:IsShown() then f.cd:Show(); end	
			if (option.base.cooldown == COOLDOWN_CIRCLE) then 
				f.cd:SetCooldown(spell.startTime, spell.duration or 0); 
				f.cd:SetDrawSwipe(spell.isCharging == false); 
			else 
				f.cd:SetMinMaxValues(spell.startTime, spell.endTime) 
				if spell.isCharging then f.cd:SetStatusBarColor(0,0,0,0) 
				else f.cd:SetStatusBarColor(1,1,1,1) end
			end
			f:Show()
		end
	end
	
	function HDH_C_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
		if f.cooldown1:GetScript("OnUpdate") ~= CT_OnUpdateCooldown or 
		   f.cooldown2:GetScript("OnUpdate") ~= CT_OnUpdateCooldown then
			f.cooldown1:SetScript("OnUpdate", CT_OnUpdateCooldown)
			f.cooldown2:SetScript("OnUpdate", CT_OnUpdateCooldown)
		end
		--if f.cg.cd1
		super.UpdateIconSettings(self, f)
	end
	
	function HDH_C_TRACKER:UpdateSetting()
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
	
	function HDH_C_TRACKER:UpdateIcons() -- HDH_TRACKER override
		local isUpdateLayout = false
		if not self.frame.icon then return end
		for i = 1 , #self.frame.icon do
			isUpdateLayout = self:Update_Icon(self.frame.icon[i]) -- icon frame
		end
		self:Update_Layout()
	end

	function HDH_C_TRACKER:Update() -- HDH_TRACKER override
		if not self.option or not self.option.base then return end
		if not UI_LOCK and self.unit == "Pet_Cooldown" and not UnitExists("pet") then
			self.frame:Hide() return 
		end
		self:UpdateIcons()
	end

	function HDH_C_TRACKER:IsOk(id, name, isItem) -- 특성 스킬의 변경에 따른 스킬 표시 여부를 결정하기 위함
		if not id or id == 0 then return false end
		if isItem then 
			local equipSlot = select(9,GetItemInfo(id)) -- 착용 가능한 장비인가요? (착용 불가능이면, nil)
			if equipSlot and equipSlot ~="" then 
				self.frame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
				return IsEquippedItem(id) -- 착용중인가요?
			else
				return true
			end
		end
		if IsPlayerSpell(id) then return true end
		if HDH_IsTalentSpell(name) then
			return IsTalentSpell(name)
		else
			return true
		end
	end
	
	function HDH_C_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 			-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID, isItem
		local spell 
		local iconFrame
		local iconIdx = 0
		local hasEquipItem = false
		
		self.enable = auraList.tracker_enable;
		if not self.enable then 
			self.frame:UnregisterAllEvents()
			self.frame:Hide() 
			for i = 1 , #auraList do
				self:ReleaseIcon(i);
			end
			self.frame:SetScript("OnEvent",nil);
			return 
		end
		
		self.frame:UnregisterAllEvents()
		for i = 1 , #auraList do
			if self:IsOk(auraList[i].ID, auraList[i].Name, auraList[i].IsItem) then 
				iconIdx = iconIdx + 1
				iconFrame = self.frame.icon[iconIdx]
				if iconFrame:GetParent() == nil then iconFrame:SetParent(self.frame) end
				--self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = iconFrame
				spell = {}
				if type(auraList[i].Key) == "number" then
					spell.key = tonumber(auraList[i].Key)
				else
					spell.key = auraList[i].Key
				end
				spell.id = tonumber(auraList[i].ID)
				spell.no = auraList[i].No
				spell.name = auraList[i].Name
				spell.icon = auraList[i].Texture
				spell.glow = auraList[i].Glow
				spell.glowCount = auraList[i].GlowCount
				spell.always = auraList[i].Always
				spell.duration = 0
				spell.count = 0
				spell.remaining = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.isItem = (auraList[i].IsItem or false)
				spell.charges = {};
				spell.charges.duration = 0;
				spell.charges.count = 0
				spell.charges.remaining = 0
				spell.charges.startTime = 0
				spell.charges.endTime = 0
				iconFrame.spell = spell
				iconFrame.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				iconFrame.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
				self:ChangeCooldownType(iconFrame, self.option.base.cooldown)
				ActionButton_HideOverlayGlow(iconFrame)
				iconFrame:SetScript("OnUpdate", CT_OnUpdateIcon);
				if iconFrame:GetScript("OnEvent") ~= CT_OnEventIcon then
					iconFrame:SetScript("OnEvent", CT_OnEventIcon)
				end
				
				if not iconFrame.charges then
					iconFrame.charges = CreateFrame("Cooldown", nil, iconFrame.topframe, "CooldownFrameTemplate");
					iconFrame.charges:SetDrawEdge(true);
					iconFrame.charges:SetDrawSwipe(false);
					iconFrame.charges:SetDrawBling(false);
					iconFrame.charges:SetHideCountdownNumbers(true);
					iconFrame.charges:SetAllPoints();
				end
				
				if spell.isItem then
					iconFrame:RegisterEvent("BAG_UPDATE");
					iconFrame:RegisterEvent("BAG_UPDATE_COOLDOWN");
				else
					iconFrame:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
					iconFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
					iconFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
					iconFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
				end
				
				spell.startSound = auraList[i].StartSound
				spell.endSound = auraList[i].EndSound
				spell.conditionSound = auraList[i].ConditionSound
				if spell.startSound then
					iconFrame.cooldown2:SetScript("OnShow", HDH_C_OnShowCooldown)
					iconFrame.cooldown1:SetScript("OnShow", HDH_C_OnShowCooldown)
				end
				if spell.endSound then
					iconFrame.cooldown1:SetScript("OnHide", HDH_C_OnHideCooldown)
					iconFrame.cooldown2:SetScript("OnHide", HDH_C_OnHideCooldown)
				end
			end
		end
		
		self.frame:SetScript("OnEvent", CT_OnEvent_Frame)
		self.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
		if #(self.frame.icon) > 0 and self.unit == "Pet_Cooldown" then
			self.frame:RegisterEvent('UNIT_PET');
		end
		
		for i = #self.frame.icon, iconIdx+1 , -1 do
			self:ReleaseIcon(i)
		end
		
		self:Update()
	end
	
	function HDH_C_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:RunTimer("PLAYER_TALENT_UPDATE", 0.2, self.InitIcons, self)
	end
	
	function HDH_C_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
------- HDH_C_TRACKER member function -----------	

	function HDH_C_TRACKER:Update_CountAndCooldown(iconf)
		local option = self.option
		local spell = iconf.spell
		local count, maxCharges, startTime, duration
		local isUpdate = false
		spell.isCharging = false

		if spell.isItem then
			startTime, duration = GetItemCooldown(spell.id)
			spell.count = GetItemCount(spell.id) or 0
			if spell.count == 0 then isUpdate = true end
		else
			startTime, duration = GetSpellCooldown(spell.key)
			spell.count = GetSpellCount(spell.key) or 0
		end
		if startTime then 
			spell.endTime = startTime + duration
			if (spell.endTime-GetTime()) > HDH_C_TRACKER.EndCooldown then
				spell.duration = duration
				spell.startTime = startTime
				spell.remaining = spell.endTime - GetTime()
			else
				spell.endTime = 0
				spell.duration = 0
				spell.startTime = 0
				spell.remaining  = 0
			end
			isUpdate = true;
		else
			spell.endTime = 0
			spell.duration = 0
			spell.startTime = 0
			spell.remaining  = 0
		end
		
		count, maxCharges, startTime, duration = GetSpellCharges(spell.key) -- 스킬의 중첩count과 충전charge은 다른 개념이다. 
		if count then -- 충전류 스킬
			spell.charges.count = count
			if count ~= maxCharges then -- 글로벌 쿨 무시
				spell.charges.duration = duration
				spell.charges.startTime = startTime
				spell.charges.endTime = spell.charges.startTime + spell.charges.duration
				spell.charges.remaining = spell.charges.endTime - GetTime()
				
			else
				spell.charges.duration = 0
				spell.charges.startTime = 0
				spell.charges.remaining  = -1
			end
			isUpdate = true;
		end
		if count and count > 0 then 
			if count ~= maxCharges then
				spell.isCharging = true;
			else
				spell.isCharging = false;
			end
			iconf.counttext:SetText(spell.charges.count);
			if (option.base.cooldown == COOLDOWN_CIRCLE) then
				iconf.charges:SetCooldown(spell.charges.startTime, spell.charges.duration or 0); 
			end
		else
			spell.isCharging = false;
			if spell.isItem and spell.count == 1 then
				iconf.counttext:SetText(nil)
			elseif not spell.isItem and spell.count == 0 then 
				iconf.counttext:SetText(nil)
			else 
				iconf.counttext:SetText(spell.count) 
			end
		end
		
		if (spell.duration < HDH_C_TRACKER.GlobalCooldown) and not spell.isCharging then
			iconf.timetext:Hide();
		else
			iconf.timetext:Show();
		end
			
		if spell.remaining <= HDH_C_TRACKER.EndCooldown then 
			iconf.cd:Hide()
		else 
			if not iconf.cd:IsShown() then iconf.cd:Show(); end	
			if (option.base.cooldown == COOLDOWN_CIRCLE) then 
				if HDH_TRACKER.startTime < iconf.spell.startTime or (spell.duration == 0) then
					iconf.cd:SetCooldown(spell.startTime, spell.duration or 0); 
				else
					iconf.cd:SetCooldown(HDH_TRACKER.startTime, iconf.spell.duration - (iconf.spell.startTime - HDH_TRACKER.startTime));
				end	
				--iconf.cd:SetDrawSwipe(spell.isCharging == false); 
			else iconf.cd:SetMinMaxValues(spell.startTime, spell.endTime) 
				if spell.isCharging then iconf.cd:SetStatusBarColor(0,0,0,0) 
				else iconf.cd:SetStatusBarColor(1,1,1,1)  end
			end
		end
		return isUpdate
	end

	function HDH_C_TRACKER:Update_Usable(f)
		local spell =  f.spell
		local preAble = spell.isAble
		local isUpdate= false
		local isAble, isNotEnoughMana;
		spell.inRange = IsSpellInRange(spell.name,"target"); -- 1:true,0:false,nil:non target
		
		if spell.inRange == 0 then
			if not self.option.icon.desaturation_out_range then
				f.icon:SetVertexColor(unpack(self.option.icon.out_range_color))
				f.icon:SetDesaturated(nil);
			else
				f.icon:SetDesaturated(1);
			end
			spell.inRange  = false;
		else
			spell.inRange  = true;
			if spell.isItem then
				spell.isAble = IsUsableItem(spell.key)
				spell.isNotEnoughMana = false;
			else
				isAble, isNotEnoughMana = IsUsableSpell(spell.key)
				spell.isAble = isAble or isNotEnoughMana -- 사용 불가능인데, 마나 때문이라면 -> 사용 가능한 걸로 본다.
				spell.isNotEnoughMana = isNotEnoughMana
			end
			-- if preAble ~= spell.isAble then
				-- isUpdate= true
			-- end
			
			if f.spell.isNotEnoughMana then
				if not self.option.icon.desaturation_not_mana then
					f.icon:SetVertexColor(unpack(self.option.icon.not_enough_mana_color))
					f.icon:SetDesaturated(nil);
				else
					f.icon:SetDesaturated(1);
				end
			end
		end
		if spell.isAble and spell.duration < HDH_C_TRACKER.GlobalCooldown then
			if not spell.isNotEnoughMana and spell.inRange then f.icon:SetDesaturated(nil) f.icon:SetVertexColor(1,1,1) end
		else
			if spell.inRange then 
				if spell.duration < HDH_C_TRACKER.GlobalCooldown then
					f.icon:SetVertexColor(0.4,0.4,0.4)
				end
				if self.option.icon.desaturation then f.icon:SetDesaturated(1)
												 else f.icon:SetDesaturated(nil) end
			end
		end
		if f.icon:IsDesaturated() then
			f.icon:SetVertexColor(1,1,1)
			f.icon:SetAlpha(self.option.icon.off_alpha)
			f.border:SetAlpha(self.option.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
		else
			f.icon:SetAlpha(self.option.icon.on_alpha)
			f.border:SetAlpha(self.option.icon.on_alpha)
			f.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
		end
		return isUpdate
	end
	
	function HDH_C_TRACKER:Update_Icon(f) -- f == iconFrame
		--if UI_LOCK then return false end
		if not f or not f.spell or not self or not self.option then return end
		local option = self.option
		local spell = f.spell
		local isUpdate = false;
		if not UI_LOCK then
			self:Update_CountAndCooldown(f)
			self:Update_Usable(f)
		else -- 이동 모드 일때, duration 이 업데이트 되지 않기 때문에 쿨다운 종료시 duration 을 0 으로 업데이트
			if spell.remaining < HDH_C_TRACKER.EndCooldown then -- 0.1 이하는 사실상 종료된것으로 본다.
				spell.duration = 0;
			end
		end
		if (spell.duration > 0) or (spell.charges.duration > 0) then -- 글로버 쿨다운 2초 포함
			---spell.Ticker = C_Timer.NewTicker(0.2,CT_Icon_OnTicker,nil)
			--if not CT_HasTimer() then CT_StartTimer() end
			
			if (option.icon.max_time == 0 and spell.always) 
				or (option.icon.max_time > spell.remaining or spell.always) 
				or (spell.duration < HDH_C_TRACKER.GlobalCooldown)then
				if not self.frame:IsShown() then self.frame:Show() end -- 비전투 상황일때 쿨다운 돈다고 하면, 화면 출력함.
				if (spell.duration > HDH_C_TRACKER.GlobalCooldown) then
					self:SetGlow(f, false)
				end
				CT_StartTimer(iconf, option.icon.max_time); 
				if not f:IsShown() then f:Show() isUpdate= true end
			else
				self:SetGlow(f, false)
				CT_StartTimer(f, option.icon.max_time);
				if f:IsShown() then f:Hide() isUpdate= true end
			end
		else -- 쿨 안도는 중
			-- if spell.isCharging then -- 충전 쿨은 도는 중
				-- if not self.frame:IsShown() then self.frame:Show() end -- 비전투 상황일때 쿨다운 돈다고 하면, 화면 출력함.	
			-- else
				-- if f.cd:IsShown() then f.cd:Hide() end
			-- end
			if f.cd:IsShown() then f.cd:Hide() end
			self:SetGlow(f, spell.glow)
			--self:SetChangeAble(f, true)
			if not f:IsShown() then f:Show() isUpdate= true end
		end
		
		if spell.isCharging then
			
		end
		
		return isUpdate;
	end

	function HDH_C_TRACKER:Update_Layout()
		if not self.option or not self.frame.icon then return end
		local f, spell
		local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size-- 아이콘 간격 띄우는 기본값
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		if not UI_LOCK and self.unit == "Pet_Cooldown" and not UnitExists("pet") then
			self.frame:Hide() return 
		end
		
		for i = 1 , #self.frame.icon do
			f = self.frame.icon[i]
			if f and f.spell then
				if UI_LOCK or f:IsShown() then
					f:ClearAllPoints()
					f:SetPoint('RIGHT', self.frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					show_index = show_index + 1
					if i % line == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					if f.spell.duration > 2 and f.spell.remaining > 0.5 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
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

	-- function HDH_C_TRACKER:SetChangeAble(f, value)
		-- if f.spell.inRange == 0 then
			-- f.icon:SetVertexColor(1,0,0)
			-- return
		-- end
		-- if value then
			-- if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil) end
			-- f.icon:SetAlpha(self.option.icon.on_alpha)
			-- f.border:SetAlpha(self.option.icon.on_alpha)
			-- f.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
			-- if f.spell.isNotEnoughMana then
				-- f.icon:SetVertexColor(0.4, 0.4, 1.0)
			-- else
				-- f.icon:SetVertexColor(1,1,1)
			-- end
		-- else
			-- if self.option.icon.desaturation then f.icon:SetDesaturated(1)
										 -- else f.icon:SetDesaturated(nil) end
			-- f.icon:SetAlpha(self.option.icon.off_alpha)
			-- f.border:SetAlpha(self.option.icon.off_alpha)
			-- f.border:SetVertexColor(0,0,0)
			-- f.icon:SetVertexColor(1,1,1)
		-- end
	-- end
end

function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_SHOW(f, id)
	if f and f.spell and f.spell.id == id then
		f.spell.ableGlow = true
		self:ActionButton_ShowOverlayGlow(f)
	end
end

function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_HIDE(f, id)
	if f and f.spell and f.spell.id == id then
		f.spell.ableGlow = false
		self:Update_Icon(f)
	end
end
--[[
function CT_PLAYER_ENTERING_WORLD()
	InitVariables()
	UNIT_LIST[#UNIT_LIST+1] = "cooldown"
	CT:Create("cooldown")
	CT:SetData(DB_AURA.Talent[GetSpecialization() or 1].cooldown)
	CT:SetOption(DB_OPTION.cooldown)
	CT:InitIcons()
	CT:UpdateIcons()
	CT_StartTimer()
	CT_Frame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
end]]

function GetTimef()
	local cur = math.floor(GetTime())
	local s= cur%60;
	local m= (cur/60) % 60;
	local h= cur/360;
	
	return string.format("%d:%d %s", h, m, s)
end

function CT_OnEvent_Frame(self, event, ...)
	local tracker = self.parent 
	if not tracker then return end
	if event =="PLAYER_TARGET_CHANGED" then
		tracker:Update()
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		tracker:Update()
	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		tracker:Update()
	elseif event == 'GROUP_ROSTER_UPDATE' then
		tracker:Update()
	elseif event == 'UNIT_PET' then
		tracker:RunTimer("UNIT_PET", 0.5, tracker.Update, self.parent) 
	elseif event == 'ARENA_OPPONENT_UPDATE' then
		tracker:RunTimer("ARENA_OPPONENT_UPDATE", 0.5, tracker.Update, self.parent) 
	elseif event == 'PLAYER_TALENT_UPDATE' then
		tracker:RunTimer("PLAYER_TALENT_UPDATE", 0.2, tracker.InitIcons, self.parent)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		tracker:RunTimer("PLAYER_EQUIPMENT_CHANGED", 0.5, tracker.InitIcons, self.parent)
	end
end

function CT_OnEventIcon(self, event, ...)
	local tracker = self:GetParent().parent
	if event =="BAG_UPDATE" then 
		if not UI_LOCK then
			if tracker:Update_CountAndCooldown(self) then
				CT_OnEventIcon(self, "ACTIONBAR_UPDATE_COOLDOWN")
			end
		end
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		if not UI_LOCK then
			--CT_OnEventIcon(self, "ACTIONBAR_UPDATE_COOLDOWN")
			tracker:Update_Usable(self);
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" or event =="BAG_UPDATE_COOLDOWN" then
		if not UI_LOCK and (tracker:Update_Icon(self) or (not tracker.option.icon.always_show and not UnitAffectingCombat("player"))) then
			tracker:Update_Layout(self)
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		tracker:ACTIVATION_OVERLAY_GLOW_SHOW(self, ...)
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		tracker:ACTIVATION_OVERLAY_GLOW_HIDE(self, ...)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		CT_COMBAT_LOG_EVENT_UNFILTERED(self, ...)
	end
end

--[[
local function PLAYER_ENTERING_WORLD()
	
end

-- 이벤트 콜백 함수
local function HDH_CT_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		C_Timer.After(4, PLAYER_ENTERING_WORLD)
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
	
HDH_CT_ADDON_Frame = CreateFrame("Frame") -- 애드온 최상위 프레임
HDH_CT_ADDON_Frame:SetScript("OnEvent", HDH_CT_OnEvent)
OnLoad(HDH_CT_ADDON_Frame)
]]

-------------------------------------------
-------------------------------------------