HDH_AT_AURA_VERSION = 1.0
HDH_AT_SETTING_VERSION = 1.2

MAX_ICONS_COUNT = 10

local HDHFrame = CreateFrame("Frame") -- 애드온 최상위 프레임
UNIT_LIST = {"player","target"}
local AuraFrame = {} -- Aura 유닛별 프레임
local ICONS = {} -- AuraFrame 들에 속하는 각각의 아이콘 프레임의 묶음 테이블
AuraPointer = {} -- Aura 포인터; 기본 데이터들이 순차 인덱스 기반이기 때문에 Aura 포인터가 필요함
do -- 아이콘 목록 초기화
	local unit 
	for i = 1, #UNIT_LIST do
		unit = UNIT_LIST[i]
		ICONS[unit] = {}
		AuraFrame[unit] = CreateFrame("Frame", nil, HDHFrame)
		AuraFrame[unit].unit = unit
		AuraPointer[unit] = {}
	end
end

DB_AURA= {}
DB_OPTION = {}
UI_LOCK = false -- 프레임 이동 가능 여부 플래그
	
--------------------------------------------
-- 유틸
--------------------------------------------	

SpellCache = setmetatable({}, {
	__index=function(t,v) 
		local a = {GetSpellInfo(tonumber(v))} 
		if GetSpellInfo(tonumber(v)) then t[v] = a end 
		return a 
	end})

function GetCacheSpellInfo(a)
    return unpack(SpellCache[a])
end	

-------------------------------------------
-- Animation
-------------------------------------------


--------------------------------------------
-- DB 관련
--------------------------------------------

function HDH_InitVaribles()
	-- 세팅 정보 저장하는 세이브인스턴스
	if not DB_OPTION or not DB_OPTION.HDH_AT_SETTING_VERSION or (tonumber(DB_OPTION.HDH_AT_SETTING_VERSION) < HDH_AT_SETTING_VERSION) then
		local center_x = UIParent:GetWidth()/3
		local center_y = UIParent:GetHeight()/3
		DB_OPTION = { always_show = false, 
						 tooltip_id_show = true,
						 player = { x = center_x, y = center_y-100, 
									revers_h = false, revers_v = false,
									cooldown_h = false, cooldown_v = true,
									line = 10 }, -- 한줄당 아이콘 표시 갯수
						 target = { x = center_x, y = center_y, 
									revers_h = false, revers_v = false,
									cooldown_h = false, cooldown_v = true, --1 위로, 2아래로 3왼쪽으로 4오른쪽으로
									line = 10 }, -- 디버프 아이콘 위치 
						 focus  = { x = center_x, y = center_y, revers_h = false, revers_v = false }, -- 디버프 아이콘 위치 
						 icon   = { size = 30, margin = 4, on_alpha = 1, off_alpha = 0.5 },   -- 아이콘 크기
						 font   = { fontsize= 12,  -- 폰트 사이즈
									countcolor={1,1,1},
									textcolor={1,1,0},  -- 6초 이상 남았을때, 폰트 색상
									textcolor_5s={1,0,0}, -- 5초 이하 남았을때, 폰트 색상
									style=[[fonts\FRIZQT__.ttf]]}, -- 폰트 종류
					   }
		DB_OPTION.HDH_AT_SETTING_VERSION = HDH_AT_SETTING_VERSION
	end
	
	if not DB_AURA 
			or (DB_AURA.Talent and (#DB_AURA.Talent == 0))
			or not DB_AURA.HDH_AT_AURA_VERSION 
			or (tonumber(DB_AURA.HDH_AT_AURA_VERSION) < HDH_AT_AURA_VERSION) then 
		DB_AURA = {}
		DB_AURA.HDH_AT_AURA_VERSION = HDH_AT_AURA_VERSION
		local class = select(2, UnitClass("player"))
		local inspect, pet = false, false
		local currentSpec = GetSpecialization()
		local id, talent
		if currentSpec then
			curTalentId = GetSpecializationInfo(currentSpec)
			else
			curTalentId = 1
		end
		DB_AURA.name = class
		DB_AURA.Talent = {}
		for i =1, 4 do
			local id, talent = GetSpecializationInfo(i)
			if id then
				DB_AURA.Talent[i] = {ID = id, Name = talent, player = {}, target = {}, focus = {}}
			end
		end
	end
	
	-- 구버전 파싱
	if DB_SPELL then
		for i = 1, 4 do
			local id, talent = GetSpecializationInfo(i)
			if id then
				print(DB_AURA.Talent[i].Name, DB_SPELL.Talent[i].Name)
				DB_AURA.Talent[i].ID = DB_SPELL.Talent[i].ID
				DB_AURA.Talent[i].Name = DB_SPELL.Talent[i].Name
				DB_AURA.Talent[i].target = DB_SPELL.Talent[i].Debuff
				DB_AURA.Talent[i].player = DB_SPELL.Talent[i].Buff
			end
		end
		DB_SPELL= nil
	end
	
	local unit 
	for i = 1, #UNIT_LIST do
		unit = UNIT_LIST[i]
		AuraFrame[unit]:ClearAllPoints()
		AuraFrame[unit]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , DB_OPTION[unit].x, DB_OPTION[unit].y)
		AuraFrame[unit]:SetWidth(DB_OPTION.icon.size)
		AuraFrame[unit]:SetHeight(DB_OPTION.icon.size)
	end
	--HDH_AlwaysShow(AuraTracking.always_show)
end

--------------------------------------------
-- OnUpdate
--------------------------------------------

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
local function OnUpdateCooldown(self)
	local spell = self:GetParent().spell
	spell.remaining = spell.endTime - GetTime()
	
	if spell.remaining > 0.0 and spell.duration > 0 then
		if spell.remaining > 6 then
			--self.bar:SetTexture(0,0,0,0.75)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
		else 
			--self.bar:SetTexture(1,0.1,0.1,0.4)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor_5s))
		end
		if spell.remaining > 60 then
			self.timetext:SetText(('%dm'):format(spell.remaining/60))
		else
			self.timetext:SetText(('%d'):format(spell.remaining))
		end
		self:SetValue(GetTime())
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end


---------------------------------------------
-- 아이콘 세팅 
---------------------------------------------

function frameBaseSettings(f)
	f:SetFrameStrata('MEDIUM')
	f:SetClampedToScreen(true)
	
	f.icon = f:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.icon:SetPoint('CENTER', f, 'CENTER', 0, 0)
	
	f.border = f:CreateTexture(nil, 'BORDER')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/border.tga]])
	
	f.cooldown = CreateFrame("StatusBar", nil, f)
	f.cooldown:SetPoint('LEFT', f, 'LEFT', 0, 0)
	f.cooldown:SetScript('OnUpdate', OnUpdateCooldown)
	
	f.cooldown.bar = f.cooldown:CreateTexture(nil, 'OVERLAY')
	f.cooldown.bar:SetTexture(0,0,0,0.75)
	f.cooldown.bar:SetPoint('BOTTOM', f, 'BOTTOM', 0,0)
	f.cooldown:SetStatusBarTexture(f.cooldown.bar)
	
	f.cooldown.timetext = f.cooldown:CreateFontString(nil, 'OVERLAY')
	
	f.counttext = CreateFrame("Frame", nil, f):CreateFontString(nil, 'OVERLAY')
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
function HDH_UserCustomFrameSettings(f)
	f:SetSize(DB_OPTION.icon.size,DB_OPTION.icon.size)
	f:EnableMouse(false)
	f:SetMovable(false)
	--f:SetBackdropColor(unpack(SettingsInfo.player.bgcolor))
	
	local icon = f.icon
	icon:SetWidth(DB_OPTION.icon.size)
	icon:SetHeight(DB_OPTION.icon.size)
	--icon:SetTexCoord(1, 1, 1, 1)
	icon:Show()
	
	f.border:SetWidth(DB_OPTION.icon.size*1.3)
	f.border:SetHeight(DB_OPTION.icon.size*1.3)
	f.border:SetPoint('CENTER', f, 'CENTER', 0, 0)
	
	f.cooldown:SetSize(DB_OPTION.icon.size,DB_OPTION.icon.size)
	
	local counttext = f.counttext
	counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE ")
	counttext:SetWidth(DB_OPTION.icon.size)
	counttext:SetHeight(DB_OPTION.icon.size/2)
	counttext:SetTextColor(unpack(DB_OPTION.font.countcolor))
	counttext:SetNonSpaceWrap(false)
	counttext:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, -2)
	counttext:SetJustifyH('RIGHT')
	counttext:SetJustifyV('TOP')
	counttext:Show()
	
	local timetext = f.cooldown.timetext
	timetext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE ")
	timetext:SetWidth(DB_OPTION.icon.size)
	timetext:SetHeight(DB_OPTION.icon.size/2)
	--timetext:SetShadowColor( 0, 0, 0, 1)
	--timetext:SetShadowOffset( 0.8, -0.8 )
	timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
	timetext:SetNonSpaceWrap(false)
	timetext:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 1, 2)
	timetext:SetJustifyH('LEFT')
	timetext:SetJustifyV('BOTTOM')
	timetext:Show()
end

-- 해당 데이터가 존재하지 않을때, 실행되는 함수로서  bar 객체를 생성하고 기본 설정을 함
do
	for i =1, #UNIT_LIST do
		setmetatable(ICONS[UNIT_LIST[i]], {
			__index = function(t,k) 
				local f = CreateFrame('Button', nil, AuraFrame[UNIT_LIST[i]])
				t[k] = f
				frameBaseSettings(f)
				HDH_UserCustomFrameSettings(f)
				return f
			end})
	end	
end

function HDH_CreateDummyIcon(unit, count)
	local icons =  ICONS[unit]
	local options = DB_OPTION[unit]
	local curTime = GetTime()
	local prevf
	for i=1, count do
		--AllFrameVisible(true)
		f = icons[i]
		f.icon:SetTexture("Interface\\ICONS\\TEMP")
		f.cooldown:Show()
		f:ClearAllPoints()
		prevf = f
		local spell = {}
		spell.name = name
		spell.icon = icon
		spell.fix = true
		spell.id = 0
		spell.count = 3
		spell.duration = 13
		spell.reamaining = 0
		spell.endTime = curTime + spell.duration
		spell.startTime = spell.endTime - spell.duration
		spell.isBuff = true
		f.cooldown:SetOrientation(options.cooldown_v and "VERTICAL" or "HORIZONTAL")
		f.cooldown:SetReverseFill(options.cooldown_h and true or false)
		f.cooldown:SetMinMaxValues(spell.startTime, spell.endTime)
		f.spell = spell
		f.counttext:SetText(i)
		f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
		f.border:SetAlpha(DB_OPTION.icon.on_alpha)
		if i <=	1 then  f.cooldown:Show() 
					   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.on_alpha) 
					   spell.isUpdate = true
				  else f.cooldown:Hide()
					   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.off_alpha)
					   spell.isUpdate = false end
		f:Show()
	end
end

function HDH_RealeseDummyIcon(unit, count)
	for i=1, count do
		f = ICONS[unit][i]
		if f.spell then f.spell = nil end
	end
end

--------------------------------------------
-- 설정 변경 관련
--------------------------------------------

-- 프레임 이동 시킬때 드래그 시작 콜백 함수
function OnDragStart(self)
	self:StartMoving()
end

-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
function OnDragStop(self)
	DB_OPTION[self.unit].x = self:GetLeft()
	DB_OPTION[self.unit].y = self:GetBottom()
	self:StopMovingOrSizing()
end

local function SetVisibleUnit(unit, show)
	if(show) then
		if not AuraFrame[unit]:IsShown() then AuraFrame[unit]:Show() end
	else 
		if AuraFrame[unit]:IsShown() then AuraFrame[unit]:Hide() end
	end						
end

function HDH_UpdateSetting()
	for i =1 , #UNIT_LIST do
		local unit = UNIT_LIST[i]
		if UI_LOCK then
			AuraFrame[unit]:SetSize(DB_OPTION.icon.size, DB_OPTION.icon.size)
			if AuraFrame[unit].text then AuraFrame[unit].text:SetPoint("BOTTOM", AuraFrame[unit], "CENTER", 0,0) end
		end
		for k,frame in pairs(ICONS[unit]) do
			HDH_UserCustomFrameSettings(frame)
		end	
	end
end

function HDH_SetMoveFrame(unit, move)
	local frame = AuraFrame[unit]
	if move then
		if not frame.text then
			local tf = CreateFrame("Frame",nil, frame)
			tf:SetFrameStrata("HIGH")
			--tf.SetAllPoints(frame)
			local text = tf:CreateFontString(nil, 'OVERLAY')
			frame.text = text
			text:ClearAllPoints()
			text:SetFont(DB_OPTION.font.style, 12, "THICKOUTLINE")
			text:SetTextColor(1,0,0)
			text:SetWidth(150)
			text:SetHeight(70)
			text:SetPoint("BOTTOM", frame, "CENTER", 0,0)
			text:SetText(("|cffffff00[%s]\n |cffff0000Move this icon\n|\nV"):format(unit:upper()))
			text:SetMaxLines(6) 
		end
		frame.text:Show()
		frame:SetScript('OnDragStart', OnDragStart)
		frame:SetScript('OnDragStop', OnDragStop)
		frame:RegisterForDrag('LeftButton')
		frame:EnableMouse(true)
		frame:SetMovable(true)
	else
		frame:EnableMouse(false)
		frame:SetMovable(false)
		if frame.text then frame.text:Hide() end
	end
end

function HDH_UpdateIconAlpha()
	local unit 
	for i = 1, #UNIT_LIST do
		unit =  UNIT_LIST[i]
		for i = 1, #(ICONS[unit]) do
			if not ICONS[unit][i].icon:IsDesaturated() then
				ICONS[unit][i].icon:SetAlpha(DB_OPTION.icon.on_alpha)
				ICONS[unit][i].border:SetAlpha(DB_OPTION.icon.on_alpha)
			else
				ICONS[unit][i].icon:SetAlpha(DB_OPTION.icon.off_alpha)
				ICONS[unit][i].border:SetAlpha(DB_OPTION.icon.off_alpha)
			end
		end
	end
end

-- 바 프레임 이동시키는 플래그 및 이동바 생성+출력
function HDH_MoveFrame(lock)
	local dummy_data_count = 10
	if lock then
		UI_LOCK = true
		for i = 1, #UNIT_LIST do
			HDH_SetMoveFrame(UNIT_LIST[i], true)
			HDH_CreateDummyIcon(UNIT_LIST[i], MAX_ICONS_COUNT)
			SetVisibleUnit(UNIT_LIST[i], true)
			HDH_UpdateAuraICONS(UNIT_LIST[i])
		end
	else
		UI_LOCK = false
		for i = 1, #UNIT_LIST do
			HDH_SetMoveFrame(UNIT_LIST[i], false)
			HDH_RealeseDummyIcon(UNIT_LIST[i], MAX_ICONS_COUNT)
			HDH_InitAuraIcon(UNIT_LIST[i])
		end
	end
end

-------------------------------------------
-- 핵심 오라 데이터 갱신 및 아이콘 갱신
-------------------------------------------

function HDH_UpdateAuraICONS(unit)
	local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
	local line = DB_OPTION[unit].line or 10-- 한줄에 몇개의 아이콘 표시
	local size = DB_OPTION.icon.size + DB_OPTION.icon.margin -- 아이콘 간격 띄우는 기본값
	local revers_v = DB_OPTION[unit].revers_v -- 상하반전
	local revers_h = DB_OPTION[unit].revers_h -- 좌우반전
	local aura = ICONS[unit]
	
	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	for k,f in ipairs(aura) do
		if not f.spell then break end
		if f.spell.isUpdate then
			if f.spell.count < 2 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count ) end
			if f.spell.duration == 0 then f.cooldown:Hide()
							         else f.cooldown.bar:SetHeight(1)
									      f.cooldown:Show() end
			if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
										   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
										   f.border:SetAlpha(DB_OPTION.icon.on_alpha)end
			f.spell.isUpdate = false
			
			f.cooldown:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
			if not f:IsShown() then f:Show() end
			--f:ClearAllPoints()
			f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
			i = i + 1
			if i % line == 0 then
				row = row + size
				col = 0
			else
				col = col + size
			end
			ret = ret + 1
		else
			if f.spell.fix then 
				
				if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
												   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
												   f.border:SetAlpha(DB_OPTION.icon.off_alpha)end
				f.counttext:SetText(nil)
				f.cooldown:Hide()
				--f:ClearAllPoints()
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then
					row = row + size
					col = 0
				else
					col = col + size
				end
				if not f:IsShown() then f:Show() end
			else
				if f:IsShown() then f:Hide() end
			end
		end
	end
	return ret
end

-- 버프, 디버프의 상태가 변경 되었을때 마다 실행되어, 데이터 리스트를 업데이트 하는 함수
function HDH_UpdateAura(unit)
	if UI_LOCK then return 0  end
	local list, filter
	if unit == 'target'     then filter = "HARMFUL | PLAYER"
	elseif unit == 'player' then filter = "HELPFUL"
	elseif unit == 'focus'  then filter = "HELPFUL"
					        else return 0 end
	local name, count, duration, endTime, caster
	local spell
	local f
	local curTime = GetTime()
	if not AuraPointer[unit] then return 0 end
	for i = 1, 40 do 
		name, _, _, count, _, duration, endTime, caster, _, _, id = UnitAura(unit, i, filter)
		if not id then break end
		f = AuraPointer[unit][id]
		if f then
			spell = f.spell
			spell.count = count
			spell.id = id
			spell.remaining = endTime - curTime
			spell.duration = duration
			spell.endTime = endTime
			spell.startTime = endTime - duration
			spell.isUpdate = true
		end
	end
	
	return HDH_UpdateAuraICONS(unit)
end

function HDH_InitAuraIcon(unit)
	if UI_LOCK then return end
	if not DB_AURA.Talent then return end
	local talent = DB_AURA.Talent[GetSpecialization()]
	if not talent then return end
	
	local revers_v = DB_OPTION[unit].revers_v -- 상하반전
	local revers_h = DB_OPTION[unit].revers_h -- 좌우반전
	local cooldown_v = DB_OPTION[unit].cooldown_v -- 
	local cooldown_h = DB_OPTION[unit].cooldown_h -- 
	local auraList = talent[unit] or {}
	local prevf = nil
	local name, rank, icon, castingTime, minRange, maxRange, spellID
	local spell 
	local f
	for i = 1, #auraList do
		name, rank, icon, castingTime, minRange, maxRange, spellID =  GetCacheSpellInfo(auraList[i].ID)
		
		f = ICONS[unit][i]
		AuraPointer[unit][tonumber(auraList[i].ID)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
		spell = {}
		spell.fix = auraList[i].Fix
		spell.no = auraList[i].No
		spell.name = name
		spell.icon = icon
		spell.id = tonumber(auraList[i].ID)
		spell.count = 0
		spell.duration = 0
		spell.remaining = 0
		spell.endTime = 0
		spell.isBuff = true
		spell.isUpdate = false
		f.spell = spell
		f.icon:SetTexture(icon)
		f.icon:SetDesaturated(1)
		f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
		f.cooldown:SetOrientation(cooldown_v and "VERTICAL" or "HORIZONTAL")
		f.cooldown:SetReverseFill(cooldown_h and true or false)
		f.border:SetAlpha(DB_OPTION.icon.off_alpha)
		f:Show()
		prevf = f
	end
	if #(ICONS[unit]) > #auraList then
		for i = #auraList+1 , #(ICONS[unit]) do
			ICONS[unit][i]:Hide()
			ICONS[unit][i].spell = nil
		end
	end
	HDH_UNIT_AURA(unit)
	--AllFrameVisible(UnitAffectingCombat("player"))
end

function HDH_UNIT_AURA(unit)
	if UI_LOCK then return end
	if not AuraFrame[unit] then return end
	if UnitExists(unit) then
		local aura_count = HDH_UpdateAura(unit)
		if (aura_count > 0) or DB_OPTION.always_show or UnitAffectingCombat("player") then
			SetVisibleUnit(unit, true) 
		else
			SetVisibleUnit(unit, false) 
		end
	else
		SetVisibleUnit(unit, false) 
	end
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	if event == 'ADDON_LOADED' then
		HDHFrame:UnregisterEvent("ADDON_LOADED")
	elseif event == 'PLAYER_TARGET_CHANGED'	then
		HDH_UNIT_AURA('target')
	elseif event == 'UNIT_AURA' then
		HDH_UNIT_AURA(select(1,...))
	elseif event =='PLAYER_TALENT_UPDATE' then
		HDH_InitAuraIcon("player")
		HDH_InitAuraIcon("target")
		if OptionFrame and OptionFrame:IsShown() then 
			HDH_LoadTabSpec()
		end
	elseif event == 'PLAYER_REGEN_ENABLED' then
		if not UI_LOCK then
			for i = 1 , #UNIT_LIST do
				HDH_UNIT_AURA(UNIT_LIST[i])
			end
		end
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not UI_LOCK then
			for i = 1 , #UNIT_LIST do
				HDH_UNIT_AURA(UNIT_LIST[i])
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		HDH_InitVaribles()
		HDH_InitAuraIcon("player")
		HDH_InitAuraIcon("target")
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	print('|cffffff00HDH - AuraTracking |cffffffff(Setting: /at, /auratracking, /ㅁㅅ)')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_TARGET_CHANGED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('UNIT_AURA')
	self:RegisterEvent('PLAYER_TALENT_UPDATE')
end

-- 애드온 진입점을 온로드 이벤트로 지정
OnLoad(HDHFrame)
HDHFrame:SetScript("OnEvent", OnEvent)
