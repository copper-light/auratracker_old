CT_VERSION = 0.1
HDH_C_TRACKER = {}

CT_UI_LOCK = false

HDH_UNIT_LIST[#HDH_UNIT_LIST+1] = "cooldown" -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
HDH_GET_CLASS["cooldown"] = HDH_C_TRACKER -- at 의 new 함수에서 cooldown 의 클래스를 불러오는게 가능하도록 클래스 리스트에 추가해둠

------------------------------------
-- update event timer
------------------------------------

local UpdateTimer = nil
local function UpdateTalent()
	for i = 1, #DB_FRAME_LIST do
		if DB_FRAME_LIST[i].unit == "cooldown" then
			if HDH_TRACKER.Get(DB_FRAME_LIST[i].name) then
				HDH_TRACKER.Get(DB_FRAME_LIST[i].name):InitIcons(DB_FRAME_LIST[i].name,DB_FRAME_LIST[i].unit)
			end
		end
	end
	UpdateTimer = nil
end

local function UpdateTimerStart()
	if UpdateTimer then UpdateTimer:Cancel() end
	UpdateTimer = C_Timer.NewTimer(0.2, UpdateTalent) -- 특성 전문화 변경시 여러번 호출되는걸 방지하기 위해서
end

local function CT_Timer_Func(self)
	if self and self.arg then
		if self.arg:GetParent() and self.arg:GetParent().parent then
			if(self.arg:GetParent().parent:Update_Icon(self.arg)) or (not DB_OPTION.always_show and not UnitAffectingCombat("player")) then
				self.arg:GetParent().parent:Update_Layout()
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


-----------------------------------
-- OnUpdate icon
-----------------------------------
-- 매 프레임마다 bar frame 그려줌, 콜백 함수
function CT_OnUpdateCooldown(self)
	local spell = self:GetParent().spell
	if not spell then self:Hide() return end
	
	spell.curTime = GetTime()
	if spell.curTime - (spell.delay or 0) < 0.1 then return end -- 10프레임
	spell.delay = spell.curTime
	spell.remaining = spell.endTime - spell.curTime

	if spell.remaining > 0.1 and spell.duration > 0 then
		if spell.remaining > 5 then
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
		else 
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor_5s))
		end
		if spell.remaining > 60 then
			self.timetext:SetText(('%d:%02d'):format((spell.remaining)/60,spell.remaining%60))
		else
			self.timetext:SetText(('%d'):format(spell.remaining))
		end
		if  self:GetParent():GetParent().parent.option.base.cooldown ~= COOLDOWN_CIRCLE then
			self:SetValue(spell.curTime)
		end
	else--[[
		self:GetParent():GetParent().parent:Update_Usable(self:GetParent())
		self:GetParent():GetParent().parent:SetChangeAble(self:GetParent(), true)
		self:GetParent():Show()]]
		--CT:Update_Layout()
		if not CT_HasTImer(self:GetParent()) then
			self:Hide()
			local t = {arg = self}
			CT_Timer_Func(t)
		end
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end 

------------------------------------
-- HDH_C_TRACKER class
------------------------------------
do 
	setmetatable(HDH_C_TRACKER, HDH_TRACKER) -- 상속
	HDH_C_TRACKER.__index = HDH_C_TRACKER
	super = HDH_TRACKER
	
	function HDH_C_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		super.InitVariblesOption(self)
		
		-- 쿨다운 테두리 컬러 설정 변수 추가
		if not DB_OPTION.icon.cooldown_color then DB_OPTION.icon.cooldown_color = {0,0,0} end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.cooldown_color then DB_OPTION[self.name].icon.cooldown_color = {0,0,0} end
	
		if DB_OPTION.icon.desaturation == nil then DB_OPTION.icon.desaturation = true end
		if DB_OPTION[self.name].icon and DB_OPTION[self.name].icon.desaturation == nil then DB_OPTION[self.name].icon.desaturation = true end
		
		if DB_OPTION.icon.max_time == nil then DB_OPTION.icon.max_time = 0 end
		if DB_OPTION[self.name].icon and not DB_OPTION[self.name].icon.max_time then DB_OPTION[self.name].icon.max_time = 0 end
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

	function HDH_C_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local prevf, f
		
		if icons then
			if #icons > 0 then count = #icons end
		end
		for i=1, count do
			f = icons[i]
			if not f:GetParent() then f:SetParent(self.frame) end
			if not f.icon:GetTexture() then
				f.icon:SetTexture("Interface\\ICONS\\TEMP")
			end
			f:ClearAllPoints()
			prevf = f
			local spell = {}
			spell.name = name
			spell.icon = icon
			spell.always = true
			spell.id = 0
			spell.glow = false
			spell.count = 3
			spell.duration = 30 * i
			spell.remaining = 0
			spell.endTime = curTime + spell.duration
			spell.startTime = spell.endTime - spell.duration
			
			self:ChangeCooldownType(f, option.base.cooldown)
			f.spell = spell
			f.counttext:SetText(i)
			if i ==	1 then 
						   spell.isCharging = true
					  else 
						   spell.isCharging = false
					  end	  
			if spell.duration <= 2  then f.cd:Hide()
						else if not f.cd:IsShown() then f.cd:Show(); end	
							 if (option.base.cooldown == COOLDOWN_CIRCLE) 
								then f.cd:SetCooldown(spell.startTime, spell.duration or 0); 
									 f.cd:SetDrawSwipe(spell.isCharging == false); 
								else f.cd:SetMinMaxValues(spell.startTime, spell.endTime) 
									 if spell.isCharging then
										f.cd:SetStatusBarColor(0,0,0,0) 
									 else
										f.cd:SetStatusBarColor(1,1,1,1) 
									 end
								end
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
		super.UpdateIconSettings(self, f)
	end

	function HDH_C_TRACKER:UpdateSetting() -- HDH_TRACKER override
		super.UpdateSetting(self)
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
		self:UpdateIcons()
	end

	local function IsOk(id, name, isItem) -- 특성 스킬의 변경에 따른 스킬 표시 여부를 결정하기 위함
		if isItem then return true end
		if IsPlayerSpell(id) then return true end
		if HDH_IsTalentSpell(name) then
			return IsTalentSpell(name)
		else
			return true
		end
	end
	
	function HDH_C_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID, isItem
		local spell 
		local iconFrame
		local iconIdx = 0
		for i = 1 , #auraList do
			if IsOk(auraList[i].ID, auraList[i].Name, auraList[i].IsItem) then 
				iconIdx = iconIdx + 1
				iconFrame = self.frame.icon[iconIdx]
				if iconFrame:GetParent() == nil then iconFrame:SetParent(self.frame) end
				self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = iconFrame
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
				spell.always = auraList[i].Always
				spell.duration = 0
				spell.count = 0
				spell.remaining = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.isItem = (auraList[i].IsItem or false)
				iconFrame.spell = spell
				iconFrame.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				iconFrame.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
				self:ChangeCooldownType(iconFrame, self.option.base.cooldown)
				ActionButton_HideOverlayGlow(iconFrame)
				
				if iconFrame:GetScript("OnEvent") ~= CT_OnEventIcon then
					iconFrame:SetScript("OnEvent", CT_OnEventIcon)
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
				
			end
		end
		for i = #self.frame.icon, iconIdx+1 , -1 do
			self:ReleaseIcon(i)
		end
		
		self:Update()
	end

	
	function HDH_C_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		UpdateTimerStart()
	end
	
	function HDH_C_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
------- HDH_C_TRACKER member function -----------	

	function HDH_C_TRACKER:Update_CountAndCooldown(iconf)
		local option = self.option
		local spell = iconf.spell
		local count, maxCharges, startTime, duration = GetSpellCharges(spell.key) -- 스킬의 중첩count과 충전charge은 다른 개념이다. 
		local isUpdate = false
		spell.isCharging = false
		if count then -- 충전류 스킬 (ex구르기
			spell.count = count
			if count ~= maxCharges and duration > 2 then -- 글로벌 쿨 무시
				spell.duration = duration
				spell.startTime = startTime
				spell.endTime = spell.startTime + spell.duration
				spell.remaining = spell.endTime - GetTime()
				if count > 0 then spell.isCharging = true end
			else
				spell.duration = 0
				spell.startTime = 0
				spell.remaining  = -1
			end
		else	
			if spell.isItem then
				startTime, duration = GetItemCooldown(spell.id)
				spell.count = GetItemCount(spell.id) or 0
				if spell.count == 0 then isUpdate = true end
			else
				startTime, duration = GetSpellCooldown(spell.key)
				spell.count = GetSpellCount(spell.key) or 0
			end
			if startTime == nil then return false end
			spell.duration = duration
			spell.startTime = startTime
			spell.endTime = spell.startTime + spell.duration
			spell.remaining = spell.endTime - GetTime()
			
		end
		
		if not spell.isCharging and not spell.isItem and spell.count < 2  
			then iconf.counttext:SetText(nil)
			else iconf.counttext:SetText(spell.count) end
			
		if spell.isItem and spell.count == 1 then
			iconf.counttext:SetText(nil)
		elseif not spell.isCharging and not spell.isItem and spell.count < 2  then 
			iconf.counttext:SetText(nil)
		else 
			iconf.counttext:SetText(spell.count) 
		end
			
		if spell.duration <= 2  then iconf.cd:Hide()
								else if not iconf.cd:IsShown() then iconf.cd:Show(); CT_StartTimer(iconf); end	
									 if (option.base.cooldown == COOLDOWN_CIRCLE) 
										then iconf.cd:SetCooldown(spell.startTime, spell.duration or 0); 
										     iconf.cd:SetDrawSwipe(spell.isCharging == false); 
										else iconf.cd:SetMinMaxValues(spell.startTime, spell.endTime) 
											 if spell.isCharging then
												iconf.cd:SetStatusBarColor(0,0,0,0) 
											 else
												iconf.cd:SetStatusBarColor(1,1,1,1) 
											 end
										end
								end
		return isUpdate
	end

	function HDH_C_TRACKER:Update_Usable(iconf)
		local spell =  iconf.spell
		local preAble = spell.isAble
		local isUpdate= false
		if spell.isItem then
			spell.isAble = IsUsableItem(spell.key)
		else
			local isAble, isNotEnoughMana = IsUsableSpell(spell.key)
			spell.isAble = isAble or isNotEnoughMana -- 사용 불가능인데, 마나 때문이라면 -> 사용 가능한 걸로 본다.
			spell.isNotEnoughMana = isNotEnoughMana
		end
		if preAble ~= spell.isAble then
			isUpdate= true
		end
		return isUpdate
	end
	
	function HDH_C_TRACKER:Update_Icon(f) -- f == iconFrame
		--if UI_LOCK then return false end
		if not f or not f.spell or not self or not self.option then return end
		local option = self.option
		local spell = f.spell
		
		if not UI_LOCK then
			self:Update_CountAndCooldown(f)
			self:Update_Usable(f)
		end
		if ((spell.duration > 2) or not spell.isAble) and not spell.isCharging then -- 글로버 쿨다운 2초  무시
			---spell.Ticker = C_Timer.NewTicker(0.2,CT_Icon_OnTicker,nil)
			--if not CT_HasTimer() then CT_StartTimer() end
			if (option.icon.max_time == 0 and spell.always) or (option.icon.max_time > spell.remaining or spell.always) then
				if not self.frame:IsShown() then self.frame:Show() end -- 비전투 상황일때 쿨다운 돈다고 하면, 화면 출력함.
				ActionButton_HideOverlayGlow(f)
				self:SetChangeAble(f, false)
				if not f:IsShown() then f:Show() return true end
			else
				ActionButton_HideOverlayGlow(f)
				CT_StartTimer(f, option.icon.max_time);
				if f:IsShown() then f:Hide() return true end
			end
		else -- 쿨 안도는 중
			if spell.isCharging then -- 충전 쿨은 도는 중
				if not self.frame:IsShown() then self.frame:Show() end -- 비전투 상황일때 쿨다운 돈다고 하면, 화면 출력함.	
			else
				if f.cd:IsShown() then f.cd:Hide() end
			end
			if spell.glow then
				HDH_ActionButton_ShowOverlayGlow(f)
			end
			self:SetChangeAble(f, true)
			if not f:IsShown() then f:Show() return true end
		end
		return false
	end

	function HDH_C_TRACKER:Update_Layout()
		if not self.option or not self.frame.icon then return end
		local f, spell
		local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size + self.option.icon.margin -- 아이콘 간격 띄우는 기본값
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
					if show_index % line == 0 then row = row + size; col = 0
											  else col = col + size end
					if f.spell.duration > 2 and f.spell.remaining > 0.5 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
				else
					if self.option.base.fix then
						f:ClearAllPoints()
						f:SetPoint('RIGHT', self.frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
						show_index = show_index + 1
						if show_index % line == 0 then row = row + size; col = 0
												  else col = col + size end
					end
				end
			end
		end
		if not UI_LOCK and ret == 0 and not DB_OPTION.always_show and not UnitAffectingCombat("player") then 
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end

	function HDH_C_TRACKER:SetChangeAble(f, value)
		if value then
			if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil) end
			f.icon:SetAlpha(self.option.icon.on_alpha)
			f.border:SetAlpha(self.option.icon.on_alpha)
			f.border:SetVertexColor(unpack(self.option.icon.cooldown_color))
			if f.spell.isNotEnoughMana then
				f.icon:SetVertexColor(0.6, 0.6, 1.0)
			else
				f.icon:SetVertexColor(1,1,1)
			end
		else
			if self.option.icon.desaturation then f.icon:SetDesaturated(1)
										 else f.icon:SetDesaturated(nil) end
			f.icon:SetAlpha(self.option.icon.off_alpha)
			f.border:SetAlpha(self.option.icon.off_alpha)
			f.border:SetVertexColor(0,0,0)
			f.icon:SetVertexColor(1,1,1)
		end
	end
end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 
-----------------------------------------------------------------------------



--[[function CT:UpdateIcons()
	local isUpdateLayout = false
	for i = 1 , #self.ICONS do
		if self.ICONS[i].spell.trinket then
			isUpdateLayout = self:UpdateIcon_Trinket(self.ICONS[i])
		else
			isUpdateLayout = self:Update_Icon(self.ICONS[i])
		end
	end
	if isUpdateLayout then
		self:Update_Layout()
	end
end
]]
-- 개별 아이콘 갱신
-- return 아이콘의 위치가 변경 되었는가?

function CT_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(f, id)
	if f and f.spell and f.spell.id == id then
		HDH_ActionButton_ShowOverlayGlow(f)
	end
end

function CT_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(f, id)
	if f and f.spell and f.spell.id == id then
		ActionButton_HideOverlayGlow(f)
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

function CT_OnEventIcon(self, event, ...)
	local tracker = self:GetParent().parent
	if event =="BAG_UPDATE" then -- 층전, 중첩  변경
		if not UI_LOCK then
			if tracker:Update_CountAndCooldown(self) then
				CT_OnEventIcon(self, "ACTIONBAR_UPDATE_COOLDOWN")
			end
		end
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		if not UI_LOCK then
			if tracker:Update_Usable(self) then
				CT_OnEventIcon(self, "ACTIONBAR_UPDATE_COOLDOWN")
			end
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" or event =="BAG_UPDATE_COOLDOWN" then
		if not UI_LOCK and (tracker:Update_Icon(self) or (not DB_OPTION.always_show and not UnitAffectingCombat("player"))) then
			tracker:Update_Layout(self)
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		CT_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self, ...)
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		CT_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self, ...)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		CT_COMBAT_LOG_EVENT_UNFILTERED(self, ...)
	end
end

local function PLAYER_ENTERING_WORLD()
	HDH_CT_ADDON_Frame:RegisterEvent('PLAYER_TALENT_UPDATE')
end

-- 이벤트 콜백 함수
local function HDH_CT_OnEvent(self, event, ...)
	if event =='PLAYER_TALENT_UPDATE' and not UnitAffectingCombat("player") then
		UpdateTimerStart()
	elseif event == "PLAYER_ENTERING_WORLD" then
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


-------------------------------------------
-------------------------------------------