CT_VERSION = 0.1
HDH_T_TRACKER = {}

CT_UI_LOCK = false

HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = "토템,꽃,마력룬,조각상" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
HDH_GET_CLASS["토템,꽃,마력룬,조각상"] = HDH_T_TRACKER -- 
HDH_GET_CLASS["토템류,버섯,마력룬"] = HDH_T_TRACKER 

-- 드루
--id[145205] = true

-- 수도사
local AdjustName= {}
local _, MyClass = UnitClass("player");
do
	if MyClass == "MONK" then
		AdjustName["흑우 조각상"] = "흑우 조각상 소환"
		AdjustName["옥룡 조각상"] = "옥룡 조각상 소환"
	end
end

function TT_UnregisterEventAll(frame)
	if not frame then return end
	frame:SetScript("OnEvent", nil)
	frame:UnregisterEvent("PLAYER_TOTEM_UPDATE");
end

------------------------------------
-- HDH_T_TRACKER class
------------------------------------
do 
	setmetatable(HDH_T_TRACKER, HDH_TRACKER) -- 상속
	HDH_T_TRACKER.__index = HDH_T_TRACKER
	local super = HDH_TRACKER
	
	function HDH_T_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		super.InitVariblesOption(self)
	end

	function HDH_T_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			TT_UnregisterEventAll(self.frame)
			self.frame.namePointer = nil
		end
		super.Release(self)
	end
	
	function HDH_T_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
		local icon = self.frame.icon[idx]
		--icon:SetScript("OnEvent", nil)
		icon:Hide()
		icon:SetParent(nil)
		icon.spell = nil
		self.frame.icon[idx] = nil
	end
	
	function HDH_T_TRACKER:UpdateIconSettings(f) -- HDH_TRACKER override
		super.UpdateIconSettings(self, f)
	end

	function HDH_T_TRACKER:UpdateSetting() -- HDH_TRACKER override
		super.UpdateSetting(self)
	end

	function HDH_T_TRACKER:UpdateIcons() -- HDH_TRACKER override
		return super.UpdateIcons(self)
	end

	function HDH_T_TRACKER:Update(...) -- HDH_TRACKER override
		local haveTotem, name, startTime, duration, icon
		local slot = ... or MAX_TOTEMS
		local option 
		local iconFrame
		if ( slot <= MAX_TOTEMS ) then
			for i =1, MAX_TOTEMS do
				haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
				if MyClass == "MONK" then
					name = AdjustName[name]
				end
				iconFrame =  self.frame.TotemPointer[name];
				option = self.frame.TotemPointer and self.frame.TotemPointer[name] or nil
				if haveTotem and option then
					if iconFrame.spell then
						iconFrame.spell.duration = duration
						iconFrame.spell.count = 0
						iconFrame.spell.overlay = 0
						iconFrame.spell.startTime = startTime
						iconFrame.spell.endTime = startTime + duration
						iconFrame.spell.isUpdate = true
					end
				end
			end
		end
		if (self:UpdateIcons() > 0) or self.option.icon.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end

	
	function HDH_T_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID, isItem
		local spell 
		local iconFrame
		local tempOption = {}
		self.frame.TotemPointer = {}
		for i = 1, #auraList do--[[
			name, spellID, icon = HDH_GetInfo(auraList[i].Key or auraList[i].ID, auraList[i].IsItem)
			if not name or not spellID or not icon then 
				HDH_GetInfo(auraList[i].ID, auraList[i].IsItem)
			end!
			if name then ]]
			iconFrame = self.frame.icon[i]
			if iconFrame:GetParent() == nil then iconFrame:SetParent(self.frame) end
			self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = iconFrame -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
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
			spell.endTime = 0
			spell.isUpdate = false
			spell.isItem =  auraList[i].IsItem
			iconFrame.spell = spell
			iconFrame.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
			iconFrame.icon:SetDesaturated(1)
			--f.border:SetVertexColor(0,0,0)
			iconFrame.icon:SetAlpha(self.option.icon.off_alpha)
			iconFrame.border:SetAlpha(self.option.icon.off_alpha)
			self:ChangeCooldownType(iconFrame, self.option.base.cooldown)
			self:SetGlow(iconFrame, false)
			
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
		--[[if ResolveID[spell.name] or ResolveID[spell.id] or StaggerID[spell.id] then
				isTanker = true
			elseif IgniteID[spell.id] then
				isIgnite = true
			end]]
			self.frame.TotemPointer[spell.name] = iconFrame;
		end
		self.GetAurasFunc = GetAuras
		
		if #(self.frame.icon) > #auraList then
			for i = #(self.frame.icon) ,#auraList+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		
		if #auraList > 0 then
			self.frame:SetScript("OnEvent", TT_OnEvent)
			self.frame:RegisterEvent("PLAYER_TOTEM_UPDATE");
			--self.frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		else
			TT_UnregisterEventAll(frame)
		end
		self:Update()
	end
	
	function HDH_T_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 
-----------------------------------------------------------------------------


function GetTimef()
	local cur = math.floor(GetTime())
	local s= cur%60;
	local m= (cur/60) % 60;
	local h= cur/360;
	
	return string.format("%d:%d %s", h, m, s)
end

function TT_OnEvent(self, event, ...)
	local tracker = self.parent
	if event == "PLAYER_TOTEM_UPDATE" then 
		if not UI_LOCK then
			tracker:Update(...)
		end
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
	
	end
end

-- 이벤트 콜백 함수
local function HDH_TT_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
	
HDH_TT_ADDON_Frame = CreateFrame("Frame") -- 애드온 최상위 프레임
HDH_TT_ADDON_Frame:SetScript("OnEvent", HDH_TT_OnEvent)
OnLoad(HDH_TT_ADDON_Frame)

-------------------------------------------
-------------------------------------------