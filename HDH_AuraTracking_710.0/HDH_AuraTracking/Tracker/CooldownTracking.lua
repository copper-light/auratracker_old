HDH_C_TRACKER = {}
HDH_C_TRACKER.GlobalCooldown = 2;
HDH_C_TRACKER.EndCooldown = 0.0;

-- 아이콘 변경을 위한 아이디 보정
local ADJUST_ID = {};
ADJUST_ID[202767] = 202767;--new moon
ADJUST_ID[202768] = 202767;--half monn -> new moon
ADJUST_ID[202771] = 202767;--full moon -> new moon

ADJUST_ID[137639] = 137639;
ADJUST_ID[221771] = 137639;--storm earth fire:targeting -> storm earth fire

ADJUST_ID[157153] = 157153;--폭우토템
ADJUST_ID[201764] = 157153;--폭우토템

local L_TYPE_PLAYER = "스킬쿨다운:player";

HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = L_TYPE_PLAYER -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
HDH_GET_CLASS[L_TYPE_PLAYER] = HDH_C_TRACKER -- at 의 new 함수에서 cooldown 의 클래스를 불러오는게 가능하도록 클래스 리스트에 추가해둠
HDH_GET_CLASS_NAME[L_TYPE_PLAYER] = "HDH_C_TRACKER";


local PET_TYPE = "스킬쿨다운:pet";
HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = PET_TYPE -- 팻 전용 쿨다운 - 팻이 소환 되었을때만 출력하려고 구분함.
HDH_GET_CLASS[PET_TYPE] = HDH_C_TRACKER; -- 팻 전용 쿨다운

HDH_OLD_TRACKER["Player_cooldown"] = L_TYPE_PLAYER;
HDH_OLD_TRACKER["Pet_cooldown"] = PET_TYPE;
HDH_OLD_TRACKER["cooldown"] = L_TYPE_PLAYER;



--- 예전 이름들 호환성 위해서 ---
-- HDH_PARSE_OLD_TRACKER["cooldown"] = "Player_cooldown";

------------------------------------
-- cooldown db
------------------------------------

local DefaultCooldownDB = {icon = {cooldown_color = {0,0,0}, 
								   desaturation = true, 
								   max_time = -1, 
								   not_enough_mana_color = {0.5,0.5,1}, 
								   not_enough_mana_color = {0.5,0.5,1}, 
								   out_range_color = {0.8,0.1,0.1},
								   desaturation_not_mana = false,
								   desaturation_out_range = false,
								   show_global_cooldown = true}
						  };

------------------------------------
-- HDH_C_TRACKER class
------------------------------------
do 
	setmetatable(HDH_C_TRACKER, HDH_TRACKER) -- 상속
	HDH_C_TRACKER.__index = HDH_C_TRACKER
	local super = HDH_TRACKER
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
			if (f.spell.remaining > (maxtime or 0)) then
				f.timer = C_Timer.NewTimer(f.spell.remaining - (maxtime or 0), CT_Timer_Func)
			else
				f.timer = C_Timer.NewTimer(f.spell.remaining, CT_Timer_Func)
			end
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
	function HDH_C_CheckStartSound(self)
		local f = self;
		if f.spell and f.spell.startSound and not OptionFrame:IsShown() then
			-- print(f.spell.duration, f.spell.remaining)
			if (f.spell.duration - f.spell.remaining) < 0.15 then
				if f.spell.duration > HDH_C_TRACKER.GlobalCooldown then
					HDH_PlaySoundFile(f.spell.startSound, "SFX")
				end
			end
		end
	end

	function HDH_C_CheckEndSound(self)
		local f = self;
		-- print(f.spell.duration)
		if f.spell and f.spell.endSound and not OptionFrame:IsShown() then
			if f.spell.duration > HDH_C_TRACKER.GlobalCooldown then
				HDH_PlaySoundFile(f.spell.endSound, "SFX")
			end
		end
	end

	-----------------------------------
	-- OnUpdate icon
	-----------------------------------
	
	local function CT_UpdateCooldown(f, elapsed)
		local spell = f.spell;
		local tracker = f:GetParent().parent;
		if not spell then return end
		
		f.elapsed = (f.elapsed or 0) + elapsed;
		if f.elapsed < HDH_TRACKER.ONUPDATE_FRAME_TERM  then return end  -- 30프레임
		f.elapsed = 0
		spell.curTime = GetTime();
		spell.remaining = spell.endTime - spell.curTime;
		if spell.remaining > HDH_C_TRACKER.EndCooldown and spell.duration > 0 then
			if not spell.isCharging and spell.duration > HDH_C_TRACKER.GlobalCooldown then
				tracker:UpdateTimeText(f.timetext, spell.remaining);
			end
			if tracker.option.base.cooldown ~= HDH_TRACKER.COOLDOWN_CIRCLE then
				if f.cd:GetObjectType() == "StatusBar" then f.cd:SetValue(spell.startTime + spell.remaining) end
			end
			if tracker.option.bar.enable and spell.duration > HDH_C_TRACKER.GlobalCooldown then
				local minV, maxV = f.bar:GetMinMaxValues();
				f.bar:SetValue(tracker.option.bar.fill_bar and (maxV-spell.remaining) or (spell.remaining));
				tracker:moveSpark(tracker, f, spell);
			end
		elseif HDH_TRACKER.IsEqualClass(tracker.type, "HDH_C_TRACKER") then
			if( tracker:Update_Icon(f)) or (not tracker.option.icon.always_show and not UnitAffectingCombat("player")) then
				tracker:Update_Layout()
			end
		end
	end

	-- 매 프레임마다 bar frame 그려줌, 콜백 함수
	function CT_OnUpdateCooldown(self, elapsed)
		CT_UpdateCooldown(self:GetParent():GetParent(), elapsed)
	end 
	
	-- 아이콘이 보이지 않도록 설정되면, 바에서 업데이트 처리를 한다
	function HDH_C_TRACKER:OnUpdateBarValue(elapsed)
		CT_UpdateCooldown(self:GetParent(), elapsed)
	end

	function CT_OnUpdateIcon(self) -- 거리 체크는 onUpdate 에서 처리해야함
		if not self.spell then return end
		
		self.spell.curTime2 = GetTime();
		if self.spell.curTime2 - (self.spell.delay2 or 0) < 0.1  then return end -- 10프레임
		self.spell.delay2 = self.spell.curTime2;
		
		if self.spell.isCharging then --and self.spell.charges.duration > HDH_C_TRACKER.GlobalCooldown
			self.spell.charges.remaining = self.spell.charges.endTime - self.spell.curTime2;
			self:GetParent().parent:UpdateTimeText(self.timetext, self.spell.charges.remaining);
		end
		if self.spell.slot then
			self.spell.newRange = IsActionInRange(self.spell.slot) 
		else
			self.spell.newRange = IsSpellInRange(self.spell.name,"target"); -- 1 true, 0 false, nil not target
		end
		if self.spell.preInRage ~= self.spell.newRange then
			self:GetParent().parent:Update_Usable(self);	
			self.spell.preInRage = self.spell.newRange;
		end
	end
	
	function HDH_C_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		super.InitVariblesOption(self)
		
		HDH_AT_UTIL.CheckToUpdateDB(DefaultCooldownDB, DB_OPTION);
		if DB_OPTION[self.name].use_each then
			HDH_AT_UTIL.CheckToUpdateDB(DefaultCooldownDB, DB_OPTION[self.name]);
		end
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
		if cooldown_type == HDH_TRACKER.COOLDOWN_UP then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_DOWN  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_LEFT  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_RIGHT then 
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
			spell.happenTime = 0
			spell.remaining = spell.duration
			spell.charges = {};
			spell.charges.duration = 0;
			spell.charges.endTime = 0;
			spell.endTime = curTime + spell.duration
			spell.startTime = curTime
			self:SetGameTooltip(f,  false)
			self:ChangeCooldownType(f, option.base.cooldown)
			f.spell = spell
			f.counttext:SetText(i)
			f.timetext:Show();
			f.icon:SetVertexColor(1,1,1);
			spell.isCharging = false;
			spell.isAble = true
			if not f.cd:IsShown() then f.cd:Show(); end	
			if (option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE) then 
				f.cd:SetCooldown(spell.startTime, spell.duration or 0); 
				f.cd:SetDrawSwipe(spell.isCharging == false); 
			else 
				f.cd:SetMinMaxValues(spell.startTime, spell.endTime) 
				if spell.isCharging then f.cd:SetStatusBarColor(0,0,0,0) 
				else f.cd:SetStatusBarColor(1,1,1,1) end
			end
			
			if self.option.bar.enable then
				f.bar:SetMinMaxValues(0, spell.duration);
				f.bar:SetValue(spell.remaining);
			end
			f:Show()
		end
		return count;
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
			if iconf.spell and (iconf.spell.remaining or 0) > HDH_C_TRACKER.EndCooldown then
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
		if self.OrderFunc then self:OrderFunc(self); self:Update_Layout(); end 
	end

	function HDH_C_TRACKER:Update() -- HDH_TRACKER override
		if not self.option or not self.option.base then return end
		if not UI_LOCK and self.type == PET_TYPE and not UnitExists("pet") then
			self.frame:Hide(); return 
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
		local selected = HDH_AT_UTIL.IsTalentSpell(name); -- true / false / nil: not found talent
		if selected == nil then
			return true;
		else
			return selected;
		end
	end
	
	function HDH_C_TRACKER:IsSwitchByHappenTime(icon1, icon2) 
		if not icon1.spell and not icon2.spell then return end
		local s1 = icon1.spell
		local s2 = icon2.spell
		local ret = false;
		if (not s1.isUpdate and s2.isUpdate) then
			ret = true;
		elseif (s1.isUpdate and s2.isUpdate) then
			if (s1.happenTime < s2.happenTime) then
				ret = true;
			end
		elseif (not s1.isUpdate and not s2.isUpdate) and (s1.no < s2.no) then
			ret = true;
		end
		return ret;
	end

	function HDH_C_TRACKER:IsSwitchByRemining(icon1, icon2) 
		if not icon1.spell and not icon2.spell then return end
		local s1 = icon1.spell
		local s2 = icon2.spell
		local ret = false;
		if (s1.duration > HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) and (s1.remaining < s2.remaining) then
			ret = true;
		elseif (s1.remaining == 0 and s2.remaining == 0) and (s1.no <s2.no) then
			ret = true;
		elseif (s1.duration < HDH_C_TRACKER.GlobalCooldown and s2.duration > HDH_C_TRACKER.GlobalCooldown) then
			ret = true;
		end
		return ret;
	end
	
	function HDH_C_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 			-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID, isItem
		local spell 
		local f
		local iconIdx = 0
		local hasEquipItem = false
		self.frame.pointer = {};
		self.frame:UnregisterAllEvents()
		for i = 1 , #auraList do
			if self:IsOk(auraList[i].ID, auraList[i].Name, auraList[i].IsItem) and not self:IsIgnoreSpellByTalentSpell(auraList[i]) then 
				iconIdx = iconIdx + 1
				f = self.frame.icon[iconIdx]
				if f:GetParent() == nil then f:SetParent(self.frame) end
				
				local id = ADJUST_ID[auraList[i].ID] or auraList[i].ID;
				self.frame.pointer[id] = f
				spell = {}
				if type(auraList[i].Key) == "number" then
					spell.key = tonumber(auraList[i].Key)
				else
					spell.key = auraList[i].Key
				end
				spell.id = tonumber(id)
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
				spell.happenTime = 0
				spell.isItem = (auraList[i].IsItem or false)
				spell.charges = {};
				spell.charges.duration = 0;
				spell.charges.count = 0
				spell.charges.remaining = 0
				spell.charges.startTime = 0
				spell.charges.endTime = 0
				
				spell.slot = nil -- self:GetSlot(spell.id);
				if not auraList[i].defaultImg then auraList[i].defaultImg = auraList[i].Texture; 
				elseif auraList[i].defaultImg ~= auraList[i].Texture then spell.fix_icon = true end
				if self.option.bar.enable then f.name:SetText(spell.name); end
				f.spell = spell
				f.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				f.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
				self:ChangeCooldownType(f, self.option.base.cooldown)
				self:SetGlow(f, false)
				f:SetScript("OnUpdate", CT_OnUpdateIcon);
				if f:GetScript("OnEvent") ~= CT_OnEventIcon then
					f:SetScript("OnEvent", CT_OnEventIcon)
				end
				
				if not f.charges then
					f.charges = CreateFrame("Cooldown", nil, f.iconframe, "CooldownFrameTemplate");
					f.charges:SetDrawEdge(true);
					f.charges:SetDrawSwipe(false);
					f.charges:SetDrawBling(false);
					f.charges:SetHideCountdownNumbers(true);
					f.charges:SetAllPoints();
				end
				
				if spell.isItem then
					f:RegisterEvent("BAG_UPDATE");
					f:RegisterEvent("BAG_UPDATE_COOLDOWN");
				else
					f:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
					f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
					f:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
					f:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
					-- f:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
				end
				
				spell.startSound = auraList[i].StartSound
				spell.endSound = auraList[i].EndSound
				spell.conditionSound = auraList[i].ConditionSound
				-- if spell.startSound then
					-- f.cooldown2:SetScript("OnShow", HDH_C_OnShowCooldown)
					-- f.cooldown1:SetScript("OnShow", HDH_C_OnShowCooldown)
				-- end
				-- if spell.endSound then
					-- f.cooldown1:SetScript("OnHide", HDH_C_OnHideCooldown)
					-- f.cooldown2:SetScript("OnHide", HDH_C_OnHideCooldown)
				-- end
			end
		end
		self:UpdateAllSlot();
		for i = 1 , #self.frame.icon do
			self:UpdateSlot(self.frame.icon[i].spell.slot);
		end
		self:LoadOrderFunc();
		self.frame:SetScript("OnEvent", CT_OnEvent_Frame)
		self.frame:RegisterEvent('PLAYER_TALENT_UPDATE')
		self.frame:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		if #(self.frame.icon) > 0 and self.type == PET_TYPE then
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

	function HDH_C_TRACKER:Update_CountAndCooldown(f)
		local option = self.option
		local spell = f.spell
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
				if (not option.icon.show_global_cooldown and duration < HDH_C_TRACKER.GlobalCooldown) then
					spell.endTime = 0
					spell.duration = 0
					spell.startTime = 0
					spell.remaining  = 0
				else
					spell.duration = duration
					spell.startTime = startTime
					spell.remaining = spell.endTime - GetTime()
				end
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
		if maxCharges and (maxCharges > 1) then 
			if count ~= maxCharges then
				spell.isCharging = true;
			else
				spell.isCharging = false;
			end
			f.counttext:SetText(spell.charges.count);
			if (option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE) then
				f.charges:SetCooldown(spell.charges.startTime, spell.charges.duration or 0); 
			end
		else
			spell.isCharging = false;
			if spell.isItem and spell.count == 1 	     then f.counttext:SetText(nil)
			elseif not spell.isItem and spell.count == 0 then f.counttext:SetText(nil)
										                 else f.counttext:SetText(spell.count)  end
		end
		
		if (spell.duration < HDH_C_TRACKER.GlobalCooldown) and not spell.isCharging then f.timetext:SetText(nil) end	
		if spell.remaining <= HDH_C_TRACKER.EndCooldown then 
			f.cd:Hide()
			if f.bar then 
				self:UpdateBarValue(f, true);
			end--f.bar:Hide() 
		else 
			if not f.cd:IsShown() then f.cd:Show(); end	
			if (option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE) then 
				if HDH_TRACKER.startTime < f.spell.startTime or (spell.duration == 0) then
					f.cd:SetCooldown(spell.startTime, spell.duration or 0); 
				else
					f.cd:SetCooldown(HDH_TRACKER.startTime, f.spell.duration - (f.spell.startTime - HDH_TRACKER.startTime));
				end	
			else 
				f.cd:SetMinMaxValues(spell.startTime, spell.endTime); f.cd:SetValue(spell.remaining + spell.startTime);
			end
			
			if self.option.bar.enable and f.spell.duration > HDH_C_TRACKER.GlobalCooldown and f.bar then
				f.bar:Show();
				if f.spell.duration == 0 then 
					self:UpdateBarValue(f, true);
				else 
					self:UpdateBarValue(f, false);
				end --spell.startTime+spell.remaining
				
			else
				self:UpdateBarValue(f, true);
			end
		end
		return isUpdate
	end

	function HDH_C_TRACKER:Update_Usable(f)
		local spell =  f.spell
		local preAble = spell.isAble
		local isUpdate= false
		local isAble, isNotEnoughMana;
		if spell.slot then
			spell.inRange = IsActionInRange(spell.slot); -- 1:true,0:false,nil:non target
		else
			spell.inRange = IsSpellInRange(spell.name,"target"); -- 1:true,0:false,nil:non target
		end
		if spell.inRange == false or  spell.inRange == 0 then
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
	
	function HDH_C_TRACKER:Update_Icon(f) -- f == f
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
			if (spell.duration < HDH_C_TRACKER.GlobalCooldown) and spell.charges.duration == 0 then
				-- CT_StartTimer(f, option.icon.max_time); 
				if f:IsShown() then
					CT_StartTimer(f, option.icon.max_time); 
					self:SetGlow(f, spell.glow);
				end
				-- if spell.isAble and spell.always then 
					-- self:SetGlow(f, spell.glow);
					-- CT_StartTimer(f, option.icon.max_time); 
					-- if not f:IsShown() then f:Show() isUpdate= true end
				-- else
					-- self:SetGlow(f, false)
					-- if f:IsShown() then f:Hide() isUpdate= true print("1") end
				-- end
			else
				if UI_LOCK or (option.icon.max_time == -1) or (option.icon.max_time > spell.remaining) then
					if (spell.duration > HDH_C_TRACKER.GlobalCooldown) or not spell.isAble then self:SetGlow(f, false)
					else self:SetGlow(f, spell.glow) end
					-- if spell.isAble then 
					HDH_C_CheckStartSound(f);
					CT_StartTimer(f, option.icon.max_time); 
					if not f:IsShown() then f:Show() isUpdate= true end
					-- end
				else
					self:SetGlow(f, false)
					CT_StartTimer(f, option.icon.max_time);
					if f:IsShown() then f:Hide() isUpdate= true end
				end
			end
		else -- 쿨 안도는 중
			if f.cd:IsShown() then f.cd:Hide() end
			HDH_C_CheckEndSound(f);
			if spell.always then 	
				if spell.isAble then
					self:SetGlow(f, spell.glow);
				else
					self:SetGlow(f, false);
				end
				if not f:IsShown() then f:Show() isUpdate= true end
			else 
				if f:IsShown() then f:Hide() self:SetGlow(f, false); isUpdate= true end 
			end
		end
		if self.OrderFunc then self:OrderFunc(self) end 
		self:Update_Layout();
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
		
		if not UI_LOCK and self.type == PET_TYPE and not UnitExists("pet") then
			self:HideTracker(); return 
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
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	function HDH_C_TRACKER:UpdateAllSlot()
		self.slot_pointer = {}
		for i=1,120 do
			local type,id,subtype = GetActionInfo(i)
			id = ADJUST_ID[id] or id;
			if type and self.frame.pointer[id] then
				-- print(id,i)
				self.frame.pointer[id].spell.slot = i;
				self.slot_pointer[i] = self.frame.pointer[id];
			end
		end
	end
	
	function HDH_C_TRACKER:UpdateSlot(slot)
		if not slot then return end
		local f = self.slot_pointer[slot];
		local _, slot_id = GetActionInfo(slot);
		slot_id = ADJUST_ID[slot_id] or slot_id;
		if f then
			local f_id = f.spell.id;
			f_id = ADJUST_ID[f_id] or f_id;
			if slot_id == f_id then
				f.spell.slot = slot;
				if not f.spell.fix_icon then
					local texture = GetActionTexture(slot);
					if (texture) and f.icon:GetTexture() ~= texture then
						f.icon:SetTexture(texture);
					end
				else
					if f.spell.icon ~= f.icon:GetTexture() then
						f.icon:SetTexture(f.spell.icon);
					end
				end
			else
				self:UpdateAllSlot();
				self.slot_pointer[slot] = nil;
				if slot == f.spell.slot then 
					f.spell.slot = nil;
					if f.spell.icon ~= f.icon:GetTexture() then
						f.icon:SetTexture(f.spell.icon);
					end
				else
					if self.slot_pointer[f.spell.slot] then
						self:UpdateSlot(f.spell.slot);
					end	
				end				
			end
		else
			if slot_id and self.frame.pointer[slot_id] then
				f = self.frame.pointer[slot_id];
				f.spell.slot = slot;
				self.slot_pointer[slot] = f;
				if not f.spell.fix_icon then
					local texture = GetActionTexture(slot);
					if (texture) and f.icon:GetTexture() ~= texture then
						f.icon:SetTexture(texture);
					end
				end
			end
		end
	end
	
	function HDH_C_TRACKER:GetSlot(id)
		return self.frame.pointer[id].slot;
	end

	function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_SHOW(f, id)
		if f and f.spell and f.spell.id == id then
			f.spell.ableGlow = true
			if not f:IsShown() then
				if self:Update_Icon(f) then
					self:Update_Layout(f)
				end
			else
				self:ActionButton_ShowOverlayGlow(f)
			end
		end
	end

	function HDH_C_TRACKER:ACTIVATION_OVERLAY_GLOW_HIDE(f, id)
		if f and f.spell and f.spell.id == id then
			f.spell.ableGlow = false
			self:Update_Icon(f)
		end
	end
end

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
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		tracker:UpdateSlot(...);
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
			-- tracker:Update_Usable(self);
			tracker:Update_Icon(self);
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
	-- elseif event == "UPDATE_SHAPESHIFT_FORM" then
		-- local texture = GetActionTexture(tracker:GetSlot(self.spell.id));
		-- if (texture) then
			-- self.icon:SetTexture(texture);
		-- end
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
