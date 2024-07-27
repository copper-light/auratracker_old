HDH_PRIST_TRACKER = {}

local ShadowID = { }
ShadowID[147193] = true
ShadowID[148859] = true 
ShadowID[78203] = true 
ShadowID[155271] = true 

local _, MyClass = UnitClass("player");
if MyClass == "PRIEST" then
	HDH_UNIT_LIST[#HDH_UNIT_LIST+1] = "그림자 원혼" -- 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
end
HDH_GET_CLASS["그림자 원혼"] = HDH_PRIST_TRACKER 

do 
	setmetatable(HDH_PRIST_TRACKER, HDH_TRACKER) -- 상속
	HDH_PRIST_TRACKER.__index = HDH_PRIST_TRACKER
	local super = HDH_TRACKER
	
	function HDH_PRIST_TRACKER:GetTotalShadowCount()
		if self.ShadowTarget then
			local count = 0
			for t,v in pairs(self.ShadowTarget) do
				count = count + v
			end
			return count
		end
		return 0
	end
	
	function HDH_PRIST_TRACKER:CombatLog_UpCounting(timestamp, destGUID, spellid)
		if not self or not self.ShadowTarget then return end
		self.ShadowTarget[destGUID] = (self.ShadowTarget[destGUID] or 0) + 1
		if self.timer then 
			self.timer:Cancel()
		end
		self.timer = C_Timer.NewTimer(10, function() if self:GetTotalShadowCount() > 0 then self.ShadowTarget = {}; self:Update() self.timer = nil end end)
		self:Update()
	end

	function HDH_PRIST_TRACKER:CombatLog_DownCounting(timestamp, destGUID, spellid, multistrike) 
		if not self or not self.ShadowTarget then return end
		if not multistrike and self.ShadowTarget[destGUID] and self.ShadowTarget[destGUID] > 0 then 
			self.ShadowTarget[destGUID] = self.ShadowTarget[destGUID] - 1
			if self.ShadowTarget[destGUID] == 0 then
				self.ShadowTarget[destGUID] = nil
			end
			self:Update()
		end
	end
	
	function HDH_PRIST_TRACKER:CombatLog_ClearCounting(timestamp, destGUID) -- 대상 죽으면 카운트 리셋
		if not self or not self.ShadowTarget then return end
		if self.ShadowTarget[destGUID] then
			self.ShadowTarget[destGUID] = nil
			self:Update()
		end
	end	

	local CombatLogEventList = {
		["SPELL_CAST_SUCCESS"] 	    = HDH_PRIST_TRACKER.CombatLog_UpCounting,
		["SPELL_DAMAGE"] 			= HDH_PRIST_TRACKER.CombatLog_DownCounting,
		["UNIT_DIED"]				= HDH_PRIST_TRACKER.CombatLog_ClearCounting,
	}

	function HDH_PRIST_TRACKER:COMBAT_LOG_EVENT_UNFILTERED(...)
		--        1           2       3      4      5 6 7   8         9           10        11            12       13    14     15      16           
		local timestamp, combatevent, _,sourceGUID, _,_,_,destGUID, destName, destFlags, destRaidFlag, spellid, spellname,_,auraType, stackCount = ...
		
		if combatevent == "UNIT_DIED" then
			local func = CombatLogEventList[combatevent]
			if func then func(self, timestamp, destGUID) end
		else
			if UnitGUID('player') == sourceGUID  then
				local func = CombatLogEventList[combatevent]
				if func and ShadowID[spellid] then
					func(self, timestamp, destGUID, spellid, select(25, ...))
				end
			end
		end
	end

	local function HDH_OnEvent(self, e, ...)
		if self.parent then
			self.parent:COMBAT_LOG_EVENT_UNFILTERED(...)
		end
	end
	
	function HDH_PRIST_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			self.frame:SetScript("OnEvent",nil)
			self.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		super.Release(self)
	end
	
	function HDH_PRIST_TRACKER:UpdateIcons()
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size + self.option.icon.margin -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
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
				if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
											   f.icon:SetAlpha(self.option.icon.on_alpha)
											   f.border:SetAlpha(self.option.icon.on_alpha)end
				f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
				if self.option.base.cooldown == COOLDOWN_CIRCLE then
					f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
				else
					f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then row = row + size + margin_v; col = 0
								 else col = col + size + margin_h end
				ret = ret + 1
				self:SetGlow(f, true)
				f:Show()
			else
				if f.spell.always then 
					if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
													   f.icon:SetAlpha(self.option.icon.off_alpha)
													   f.border:SetAlpha(self.option.icon.off_alpha)
													   f.border:SetVertexColor(0,0,0) end
					f.counttext:SetText(nil)
					f.cd:Hide() self:SetGlow(f, false)
					--f:ClearAllPoints()
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					i = i + 1
					if i % line == 0 then row = row + size + margin_v; col = 0
								 else col = col + size + margin_h end
					f:Show()
				else
					if self.option.base.fix then
						i = i + 1
						if i % line == 0 then row = row + size + margin_v; col = 0
								 else col = col + size + margin_h end
					end
					f:Hide()
				end
			end
		end
		return ret
	end

	function HDH_PRIST_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or UI_LOCK then return end
		local f
		local totalCount = self:GetTotalShadowCount()
		for i = 1, #self.frame.icon do
			f = self.frame.icon[i]
			if f.spell and ShadowID[f.spell.id] then
				f.spell.count = totalCount
				if f.spell.count > 0 then
					f.spell.isUpdate = true
					f.spell.duration = 0
				end
			end
		end
		self:UpdateIcons()
		if totalCount > 0 or DB_OPTION.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end
	
	function HDH_PRIST_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID
		local spell 
		local iconFrame
		local ret = 0
		self.frame.pointer = {}
		self.ShadowTarget = {}
		
		for i = 1, #auraList do
			if ShadowID[auraList[i].ID] then
				ret = ret + 1
			end
		end
		
		if ret == 0 and DB_AURA.Talent[GetSpecialization()].ID == 258 then
			talent[self.name] = {}
			auraList = talent[self.name]
			local name, _, icon, _, _, _, spellID  = GetSpellInfo(78203)
			newShadow = {}
			auraList[#auraList+1] = newShadow
			newShadow.Key = tostring(spellID)
			newShadow.No = 1
			newShadow.ID = spellID
			newShadow.Name = name
			newShadow.Always = true
			newShadow.Glow = false
			newShadow.Texture = icon
			newShadow.IsItem = false
			if OptionFrame:IsShown() then
				OptionFrame:Hide()
				OptionFrame:Show()
			end
		end
		ret = 0
		for i = 1, #auraList do
			if ShadowID[auraList[i].ID] then
				ret = ret + 1
				iconFrame = self.frame.icon[ret]
				if iconFrame:GetParent() == nil then iconFrame:SetParent(self.frame) end
				self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = iconFrame
				spell = {}
				spell.glow = auraList[i].Glow
				spell.glowCount = auraList[i].GlowCount
				spell.always = auraList[i].Always
				spell.no = auraList[i].No
				spell.name = auraList[i].Name
				spell.icon = auraList[i].Texture
				spell.id = tonumber(auraList[i].ID)
				spell.count = 0
				spell.duration = 0
				spell.remaining = 0
				spell.overlay = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.isBuff = true
				spell.isUpdate = false
				
				iconFrame.spell = spell
				iconFrame.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				iconFrame.icon:SetDesaturated(1)
				--f.border:SetVertexColor(0,0,0)
				iconFrame.icon:SetAlpha(self.option.icon.off_alpha)
				iconFrame.border:SetAlpha(self.option.icon.off_alpha)
				self:ChangeCooldownType(iconFrame, self.option.base.cooldown)
				self:SetGlow(iconFrame, false)
			end
		end
		
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		
		if #(self.frame.icon) > 0 then
			self.frame:SetScript("OnEvent",HDH_OnEvent)
			self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		else
			self.frame:SetScript("OnEvent",nil)
			self.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		self:Update()
	end
	
	function HDH_PRIST_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
end

-------------------------------------------------------------------
-------------------------------------------------------------------

