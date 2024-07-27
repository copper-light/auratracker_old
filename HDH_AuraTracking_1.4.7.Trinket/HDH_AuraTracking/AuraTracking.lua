HDH_AT_AURA_VERSION = 1.0
HDH_AT_SETTING_VERSION = 1.2

MAX_ICONS_COUNT = 10

COOLDOWN_UP     = 1
COOLDOWN_DOWN   = 2
COOLDOWN_LEFT   = 3
COOLDOWN_RIGHT  = 4
COOLDOWN_CIRCLE = 5

local HDHFrame = CreateFrame("Frame") -- 애드온 최상위 프레임
UNIT_LIST = {"player","target","focus"}
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
		local a = {GetSpellInfo(v)} 
		if GetSpellInfo(v) then t[v] = a end 
		return a 
	end})

function GetCacheSpellInfo(a)
    return unpack(SpellCache[a])
end	

function HDH_GetInfo(value)
	if not value then return nil end
	if GetCacheSpellInfo(value) then
		local name, rank, icon, castingTime, minRange, maxRange, spellID = GetCacheSpellInfo(value) 
		return name, spellID, icon
	elseif GetItemInfo(value) then
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(value)
		if name then
			-- linkType, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId
			local linkType, itemId = strsplit(":", link)
			return name, itemId, texture, true -- 마지막 인자 아이템 이냐?
		end
	end
	return nil
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
									cooldown = 1, -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
									line = 10,
									check_debuff = false,
									check_pet = false }, -- 한줄당 아이콘 표시 갯수
						 target = { x = center_x, y = center_y, 
									revers_h = false, revers_v = false,
									cooldown = 1, -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
									line = 10 }, -- 디버프 아이콘 위치 
						 focus  = { x = center_x, y = center_y+100, revers_h = false, revers_v = false,
									cooldown = 1, -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
									line = 10  }, -- 디버프 아이콘 위치 
						 icon   = { size = 30, margin = 4, 
									on_alpha = 1, off_alpha = 0.5,
									buff_color = {0,0,0}, debuff_color = {0,0,0},
									show_cooldown = true,
									cooldown_bg_color = {0,0,0,0.75}}, 
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
				DB_AURA.Talent[i].ID = DB_SPELL.Talent[i].ID
				DB_AURA.Talent[i].Name = DB_SPELL.Talent[i].Name
				DB_AURA.Talent[i].target = DB_SPELL.Talent[i].Debuff
				DB_AURA.Talent[i].player = DB_SPELL.Talent[i].Buff
			end
		end
		DB_SPELL= nil
	end
	
	if DB_OPTION["player"].cooldown == nil then 
		DB_OPTION["player"].cooldown = 1
		DB_OPTION["target"].cooldown = 1
	end
	
	if DB_OPTION["focus"].cooldown == nil then
		DB_OPTION["focus"].cooldown = 1
		DB_OPTION["focus"].line = 10
	end
	
	if DB_OPTION.icon.show_cooldown == nil then
		DB_OPTION.icon.show_cooldown = true
	end
	
	if DB_OPTION.player.check_debuff == nil then -- 체크 기능 생기면서 색상 변경 기능 들어감
		DB_OPTION.player.check_debuff = false
		DB_OPTION.icon.buff_color = {0,0,0}
		DB_OPTION.icon.debuff_color = {0,0,0}
	end
	
	if DB_OPTION["player"].check_pet == nil then 
		DB_OPTION["player"].check_pet = false
	end
	
	if DB_OPTION.icon.cooldown_bg_color == nil then
		DB_OPTION.icon.cooldown_bg_color = {0,0,0,0.75}
	end	
	
	-- 파싱 끝
	
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
	if not spell then self:Hide() end
	
	spell.curTime = GetTime()
	if spell.curTime - (spell.delay or 0) < 0.1 then return end -- 10프레임
	spell.delay = spell.curTime
	spell.remaining = spell.endTime - spell.curTime
	
	if spell.remaining > 0.0 and spell.duration > 0 then
		if spell.remaining > 5 then
			--self.bar:SetTexture(0,0,0,0.75)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
		else 
			--self.bar:SetTexture(1,0.1,0.1,0.4)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor_5s))
		end
		if spell.remaining > 60 then
			self.timetext:SetText(('%d:%02d'):format((spell.remaining)/60,spell.remaining%60))
		else
			self.timetext:SetText(('%d'):format(spell.remaining+1))
		end
		self:SetValue(GetTime())
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end

local function OnUpdateCooldown2(self)
	local spell = self:GetParent().spell
	if not spell then self:Hide() end

	spell.curTime = GetTime()
	if spell.curTime - (spell.delay or 0) < 0.1 then return end  -- 10프레임
	spell.delay = spell.curTime
	spell.remaining = spell.endTime - spell.curTime

	if spell.remaining > 0.0 and spell.duration > 0 then
		if spell.remaining > 5 then
			--self.bar:SetTexture(0,0,0,0.75)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
		else 
			--self.bar:SetTexture(1,0.1,0.1,0.4)
			self.timetext:SetTextColor(unpack(DB_OPTION.font.textcolor_5s))
		end
		if spell.remaining > 60 then
			self.timetext:SetText(('%d:%02d'):format((spell.remaining)/60,spell.remaining%60))
		else
			self.timetext:SetText(('%d'):format(spell.remaining+1))
		end
	end
end


---------------------------------------------
-- 아이콘 세팅 
---------------------------------------------

function frameBaseSettings(f)
	f:SetFrameStrata('MEDIUM')
	f:SetClampedToScreen(true)
	
	f.icon = f:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.icon:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.icon:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	
	f.cooldown1 = CreateFrame("StatusBar", nil, f)
	f.cooldown1:SetPoint('LEFT', f, 'LEFT', 0, 0)
	f.cooldown1:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown1.timetext = f.cooldown1:CreateFontString(nil, 'OVERLAY')
	f.cooldown1:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.cooldown1:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.cooldown1.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', 1, 0)
	f.cooldown1.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 2)
	f.cooldown1.timetext:SetJustifyH('LEFT')
	f.cooldown1.timetext:SetJustifyV('BOTTOM')
	f.cooldown1.timetext:SetNonSpaceWrap(false)
	f.cd = f.cooldown1
	
	f.cooldown2 = CreateFrame("Cooldown", "hdh",f) -- 원형
	f.cooldown2:SetPoint('LEFT', f, 'LEFT', 0,0)
	f.cooldown2:SetScript('OnUpdate', OnUpdateCooldown2)
	f.cooldown2:SetHideCountdownNumbers(true) 
	local tmp = f:CreateTexture(nil,"OVERLAY")
	tmp:SetTexture(1,1,1)
	f.cooldown2:SetSwipeTexture(tmp:GetTexture())
	f.cooldown2:SetDrawSwipe(true) 
	f.cooldown2:SetReverse(true)
	f.cooldown2:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.cooldown2:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.cooldown2.timetext = f.cooldown2:CreateFontString(nil, 'OVERLAY')
	f.cooldown2.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', -10, -1)
	f.cooldown2.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 0)
	f.cooldown2.timetext:SetJustifyH('CENTER')
	f.cooldown2.timetext:SetJustifyV('CENTER')
	f.cooldown2.timetext:SetNonSpaceWrap(false)
	
	local tempf = CreateFrame("Frame", nil, f)
	
	f.counttext = tempf:CreateFontString(nil, 'OVERLAY')
	f.counttext:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.counttext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.counttext:SetNonSpaceWrap(false)
	f.counttext:SetJustifyH('RIGHT')
	f.counttext:SetJustifyV('TOP')
	
	f.border = tempf:CreateTexture(nil, 'OVERLAY')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/border.tga]])
	f.border:SetVertexColor(0,0,0)
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
function HDH_UserCustomFrameSettings(f)
	f:SetSize(DB_OPTION.icon.size,DB_OPTION.icon.size)
	f:EnableMouse(false)
	f:SetMovable(false)
	
	local icon = f.icon
	f.border:SetWidth(DB_OPTION.icon.size*1.3)
	f.border:SetHeight(DB_OPTION.icon.size*1.3)
	f.border:SetPoint('CENTER', f, 'CENTER', 0, 0)
	f.cooldown1:SetStatusBarTexture(unpack(DB_OPTION.icon.cooldown_bg_color))
	f.cooldown2:SetSwipeColor(unpack(DB_OPTION.icon.cooldown_bg_color))
	--f.overlay.animIn:Play()
	
	local counttext = f.counttext
	counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	counttext:SetTextColor(unpack(DB_OPTION.font.countcolor))
	if DB_OPTION.icon.show_cooldown then
		f.cooldown2.timetext:Show()
		f.cooldown1.timetext:Show()
	else
		f.cooldown2.timetext:Hide()
		f.cooldown1.timetext:Hide()
	end
	
	local timetext = f.cooldown1.timetext
	timetext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
	timetext = f.cooldown2.timetext
	timetext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	timetext:SetTextColor(unpack(DB_OPTION.font.textcolor))
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
	local cooldown_type = DB_OPTION[unit].cooldown
	for i=1, count do
		--AllFrameVisible(true)
		f = icons[i]
		f.icon:SetTexture("Interface\\ICONS\\TEMP")
		f:ClearAllPoints()
		prevf = f
		local spell = {}
		spell.name = name
		spell.icon = icon
		spell.fix = true
		spell.id = 0
		spell.count = 3
		spell.duration = 100
		spell.reamaining = 0
		spell.endTime = curTime + spell.duration
		spell.startTime = spell.endTime - spell.duration
		if unit == 'player' then spell.isBuff = true
							else spell.isBuff = false end
		
		HDH_ChangeCooldownType(f, cooldown_type)
		if cooldown_type == COOLDOWN_CIRCLE then
				f.cd:SetCooldown(spell.startTime,spell.duration)
			else
				f.cd:SetMinMaxValues(spell.startTime, spell.endTime)
			end
		f.spell = spell
		f.counttext:SetText(i)
		f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
		f.border:SetAlpha(DB_OPTION.icon.on_alpha)
		if i <=	1 then  f.cd:Show() 
					   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.on_alpha) 
					   spell.isUpdate = true
				  else f.cd:Hide()
					   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.off_alpha)
					   spell.isUpdate = false end
		f:Show()
	end
end

function HDH_RealeseDummyIcon(unit, count)
	for i=1, count do
		ICONS[unit][i]:Hide()
		ICONS[unit][i]:SetParent(nil)
		if ICONS[unit][i].spell then ICONS[unit][i].spell = nil end
		ICONS[unit][i] = nil
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

function OnDragUpdate(self)
	self.text:SetText(("|cffffffff(%d, %d)\n%s"):format(self:GetLeft(),self:GetBottom(),self.text.text))
end

local function SetVisibleUnit(unit, show)
	if not AuraFrame[unit] then return end
	if(show) then
		AuraFrame[unit]:Show()
	else 
		AuraFrame[unit]:Hide()
	end					
end

function HDH_UpdateSettingUnit(unit)
	if UI_LOCK then
		AuraFrame[unit]:SetSize(DB_OPTION.icon.size, DB_OPTION.icon.size)
		if AuraFrame[unit].text then AuraFrame[unit].text:SetPoint("BOTTOM", AuraFrame[unit], "CENTER", 0,0) end
	end
	for k,frame in pairs(ICONS[unit]) do
		HDH_UserCustomFrameSettings(frame)
	end	
end

function HDH_UpdateSetting()
	for i =1 , #UNIT_LIST do
		local unit = UNIT_LIST[i]
		HDH_UpdateSettingUnit(unit)
	end
end

function HDH_SetMoveFrame(unit, move)
	local frame = AuraFrame[unit]
	if not frame then return end
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
			text.text = ("|cffffff00[%s]\n |cffff0000Move this icon\n|\nV"):format(unit:upper())
			text:SetMaxLines(6) 
		end
		frame.text:Show()
		frame:SetScript('OnDragStart', OnDragStart)
		frame:SetScript('OnDragStop', OnDragStop)
		frame:SetScript('OnUpdate', OnDragUpdate)
		frame:RegisterForDrag('LeftButton')
		frame:EnableMouse(true)
		frame:SetMovable(true)
	else
		frame:EnableMouse(false)
		frame:SetMovable(false)
		frame:SetScript('OnUpdate', nil)
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

function HDH_ChangeCooldownType(f, cooldown_type)
	if cooldown_type == COOLDOWN_UP then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(false)
		f.cooldown2:Hide()
		f.counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_DOWN  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(true)
		f.cooldown2:Hide()
		f.counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_LEFT  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(true)
		f.cooldown2:Hide()
		f.counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_RIGHT then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(false)
		f.cooldown2:Hide()
		f.counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize, "OUTLINE")
	else 
		f.cd = f.cooldown2
		f.cooldown1:Hide()
		f.counttext:SetFont(DB_OPTION.font.style, DB_OPTION.font.fontsize-2, "OUTLINE") -- 쿨다운이 중앙으로 가면서 폰트가 겹쳐서 살짝 작게 만들어줌 귀차니즘임..
	end
end

-------------------------------------------
-- 애니메이션 관련
-------------------------------------------

function HDH_ActionButton_ShowOverlayGlow(self)
	if ( self.overlay ) then
		if ( self.overlay.animOut:IsPlaying() ) then
			self.overlay.animOut:Stop();
			self.overlay.animIn:Play();
		end
	else
		self.overlay = ActionButton_GetOverlayGlow();
		local frameWidth, frameHeight = self:GetSize();
		self.overlay:SetParent(self);
		self.overlay:ClearAllPoints();
		--Make the height/width available before the next frame:
		--self.overlay:SetSize(frameWidth * 1.2, frameHeight * 1.2);
		self.overlay:SetPoint("TOPLEFT", self, "TOPLEFT", -frameWidth * 0.36, frameHeight * 0.36);
		self.overlay:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", frameWidth * 0.36, -frameHeight * 0.36);
		self.overlay.animIn:Play();
	end
end

function HDH_AniShow(f, bool)
	if bool and (f.spell and f.spell.glow) then
		HDH_ActionButton_ShowOverlayGlow(f)
	else
		ActionButton_HideOverlayGlow(f)
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
	local cooldown_type = DB_OPTION[unit].cooldown
	local aura = ICONS[unit]
	
	local i = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	for k,f in ipairs(aura) do
		if not f.spell then break end
		if f.spell.isUpdate then
			f.spell.isUpdate = false
			
			if f.spell.count < 2 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count ) end
			if f.spell.duration == 0 then f.cd:Hide() HDH_AniShow(f, false)
							         else f.cd:Show() HDH_AniShow(f, true) end
			if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
										   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
										   f.border:SetAlpha(DB_OPTION.icon.on_alpha)end
			if f.spell.isBuff then f.border:SetVertexColor(unpack(DB_OPTION.icon.buff_color)) 
							  else f.border:SetVertexColor(unpack(DB_OPTION.icon.debuff_color)) end
			if cooldown_type == COOLDOWN_CIRCLE then
				f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
			else
				f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
			end
			--f:ClearAllPoints()
			f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
			i = i + 1
			if i % line == 0 then row = row + size; col = 0
							 else col = col + size end
			ret = ret + 1
			f:Show()
		else
			if f.spell.fix then 
				if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
												   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
												   f.border:SetAlpha(DB_OPTION.icon.off_alpha)
												   f.border:SetVertexColor(0,0,0) end
				f.counttext:SetText(nil)
				f.cd:Hide() HDH_AniShow(f, false)
				--f:ClearAllPoints()
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then row = row + size; col = 0
								 else col = col + size end
				f:Show()
			else
				f:Hide()
			end
		end
	end
	return ret
end

function HDH_GetAuras(unit, filter, isbuff, pointer)
	local curTime = GetTime()
	for i = 1, 40 do 
		name, _, _, count, _, duration, endTime, caster, _, _, id = UnitAura(unit, i, filter)
		--if unit == 'player' then print(name) end
		if not id then break end
		f = pointer[tostring(id)] or pointer[name]
		--if f and not f.spell then print("f.spell is nil") end
		if f and f.spell then
			spell = f.spell
			spell.count = count
			spell.id = id
			spell.remaining = endTime - curTime
			spell.duration = duration
			spell.endTime = endTime
			spell.startTime = endTime - duration
			spell.isUpdate = true
			spell.isBuff = isbuff
		end
	end
end

-- 버프, 디버프의 상태가 변경 되었을때 마다 실행되어, 데이터 리스트를 업데이트 하는 함수
function HDH_UpdateAura(unit)
	if UI_LOCK then return 0  end
	local filter, buff
	local pointer = AuraPointer[unit]
	local onwer_unit
	if unit == 'target'     then filter = "HARMFUL | PLAYER" buff = false
	elseif unit == 'player' then filter = "HELPFUL" buff = true
	elseif unit == 'focus'  then filter = "HARMFUL | PLAYER" buff = false
	elseif unit == 'pet'  	then filter = "HELPFUL"; buff = true; pointer = AuraPointer['player']; onwer_unit = 'player'
					        else return 0 end
	local name, count, duration, endTime, caster
	local spell
	local f
	
	if not pointer then return 0 end
	HDH_GetAuras(unit, filter, buff, pointer)
	
	if (unit == 'player' or unit == 'pet') then -- 플레이어 버프창에 팻 버프도 포함 했기 때문에 이런식으로 표현
		if DB_OPTION.player.check_pet then
			HDH_GetAuras(onwer_unit or 'pet', filter, buff, pointer) 
		end
		
		if DB_OPTION.player.check_debuff then
			HDH_GetAuras('player', "HARMFUL", false, pointer)
			if DB_OPTION.player.check_pet then 
				HDH_GetAuras('pet', "HARMFUL", false, pointer)
			end
		end
		return HDH_UpdateAuraICONS('player')
	end
	
	return HDH_UpdateAuraICONS(unit)
end

local timer_gap = 3
function HDH_InitAuraIcon(unit)
	if UI_LOCK then return end
	if not AuraFrame[unit] then return end
	if not DB_AURA.Talent then return end
	local talent = DB_AURA.Talent[GetSpecialization()]
	if not talent then return end
	if not DB_OPTION[unit] then return end
	local cooldown_type = DB_OPTION[unit].cooldown
	local revers_v = DB_OPTION[unit].revers_v -- 상하반전
	local revers_h = DB_OPTION[unit].revers_h -- 좌우반전
	local auraList = talent[unit] or {}
	local prevf = nil
	local name, rank, icon, castingTime, minRange, maxRange, spellID
	local spell 
	local f
	AuraPointer[unit] = {}
	for i = 1, #auraList do
		name, spellID, icon = HDH_GetInfo(auraList[i].Key or auraList[i].ID)
		--print(name, auraList[i].Key )
		if name then 
			f = ICONS[unit][i]
			AuraPointer[unit][auraList[i].Key or tostring(auraList[i].ID)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
			spell = {}
			spell.glow = auraList[i].Glow
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
			--f.border:SetVertexColor(0,0,0)
			f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
			f.border:SetAlpha(DB_OPTION.icon.off_alpha)
			HDH_ChangeCooldownType(f, cooldown_type)
			HDH_AniShow(f, false)
			prevf = f
		end
	end
	if #(ICONS[unit]) > #auraList then
		for i = #auraList+1 , #(ICONS[unit]) do
			ICONS[unit][i]:Hide()
			ICONS[unit][i].spell = nil
			ICONS[unit][i]:SetParent(nil)
			ICONS[unit][i] = nil
		end
	end
	HDH_UNIT_AURA(unit)
	--AllFrameVisible(UnitAffectingCombat("player"))
end

function HDH_UNIT_AURA(unit)
	if UI_LOCK then return end
	
	if not AuraFrame[unit] then 
		if not unit =='pet' or not DB_OPTION.player.check_pet then return end -- 프레임이 없지만 pet 이고 체크하겠다 하면 진행하겠다
	end 
	if UnitExists(unit) then
		if (HDH_UpdateAura(unit) > 0) or DB_OPTION.always_show or UnitAffectingCombat("player") then
			SetVisibleUnit(unit, true) 
		else
			SetVisibleUnit(unit, false) 
		end
	else
		SetVisibleUnit(unit, false) 
	end
end

local function PLAYER_ENTERING_WORLD()
	HDHFrame:RegisterEvent('VARIABLES_LOADED')
	--HDHFrame:RegisterEvent('PLAYER_LOGIN')
	--HDHFrame:RegisterEvent('ADDON_LOADED')
	HDHFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
	HDHFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
	HDHFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
	HDHFrame:RegisterEvent('UNIT_AURA')
	HDHFrame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	HDHFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
	
	HDH_InitVaribles()
	for i = 1, #UNIT_LIST do
		HDH_InitAuraIcon(UNIT_LIST[i])
	end
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	if event == 'PLAYER_TARGET_CHANGED'	then
		HDH_UNIT_AURA('target')
	elseif event == 'UNIT_AURA' then
		HDH_UNIT_AURA(select(1,...))
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		HDH_UNIT_AURA('focus')
	elseif event =='ACTIVE_TALENT_GROUP_CHANGED' then
		for i = 1, #UNIT_LIST do
			HDH_InitAuraIcon(UNIT_LIST[i])
		end
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
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
	elseif event =="VARIABLES_LOADED" then
		self:UnregisterEvent('VARIABLES_LOADED')
		HDH_InitVaribles()
		for i = 1, #UNIT_LIST do
			HDH_InitAuraIcon(UNIT_LIST[i])
		end
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	print('|cffffff00HDH - AuraTracking |cffffffff(Setting: /at, /auratracking, /ㅁㅅ)')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

-- 애드온 진입점을 온로드 이벤트로 지정
OnLoad(HDHFrame)
HDHFrame:SetScript("OnEvent", OnEvent)
