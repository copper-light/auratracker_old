HDH_AT_VERSION = 0.64
HDH_AT_SETTING_VERSION = 0.65

MAX_ICON_COUNT = 10

local unpack = _G.unpack
local GetTime = _G.GetTime
local table_sort = _G.table.sort
local pairs = _G.pairs
local ipairs = _G.ipairs

local HDHFrame = CreateFrame("Frame") -- 애드온 최상위 프레임
local HDHBuffFrame = CreateFrame("Frame","BuffFrame",HDHFrame)
local HDHDebuffFrame = CreateFrame("Frame","DebuffFrame",HDHFrame)

local Buffs = {}-- 표시할 버프 목록  
local Debuffs = {}-- 표시할 타겟 디버프 목록
AuraPointer = {}
DB_SPELL= {}
DB_OPTION = {}
UI_LOCK = false -- 프레임 이동 가능 여부 플래그
SpellCache = setmetatable({}, {
	__index=function(t,v) 
		local a = {GetSpellInfo(tonumber(v))} 
		if GetSpellInfo(tonumber(v)) then t[v] = a end 
		return a 
	end})
	
function GetCacheSpellInfo(a)
    return unpack(SpellCache[a])
end	

function HDH_InitVaribles()
	-- 세팅 정보 저장하는 세이브인스턴스
	if not DB_OPTION or not DB_OPTION.HDH_AT_SETTING_VERSION or (tonumber(DB_OPTION.HDH_AT_SETTING_VERSION) < HDH_AT_SETTING_VERSION) then
		local center_x = UIParent:GetWidth()/3
		local center_y = UIParent:GetHeight()/3
		DB_OPTION = { always_show = false, 
						 tooltip_id_show = true,
						 buff   = { x = center_x, y = center_y, revers = true}, -- 버프 아이콘 위치 
						 debuff = { x = center_x, y = center_y, revers = false}, -- 디버프 아이콘 위치 
						 icon   = { size = 30, margin = 4, on_alpha = 1, off_alpha = 0.5 },   -- 아이콘 크기
						 font   = { fontsize= 12,  -- 폰트 사이즈
									countcolor={1,1,1},
									textcolor={1,1,0},  -- 6초 이상 남았을때, 폰트 색상
									textcolor_5s={1,0,0}, -- 5초 이하 남았을때, 폰트 색상
									style=[[fonts\FRIZQT__.ttf]]}, -- 폰트 종류
					   }
		DB_OPTION.HDH_AT_SETTING_VERSION = HDH_AT_SETTING_VERSION
	end
	
	if AuraTrackingCharacter then
		DB_SPELL = AuraTrackingCharacter
		AuraTrackingCharacter = nil
	end
	
	if not DB_SPELL 
			or (DB_SPELL.Talent and (#DB_SPELL.Talent == 0))
			or not DB_SPELL.HDH_AT_VERSION 
			or (tonumber(DB_SPELL.HDH_AT_VERSION) < HDH_AT_VERSION) then 
		DB_SPELL = {}
		DB_SPELL.HDH_AT_VERSION = HDH_AT_VERSION
		local class = select(2, UnitClass("player"))
		local inspect, pet = false, false
		local currentSpec = GetSpecialization()
		local id, talent
		if currentSpec then
			curTalentId = GetSpecializationInfo(currentSpec)
			else
			curTalentId = 1
		end
		DB_SPELL.name = class
		DB_SPELL.Talent = {}
		for i =1, 4 do
			local id, talent = GetSpecializationInfo(i)
			if id then
				DB_SPELL.Talent[i] = {ID = id, Name = talent, Buff = {}, Debuff = {}}
			end
		end
	end
	
	HDHBuffFrame:ClearAllPoints()
	HDHBuffFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , DB_OPTION.buff.x, DB_OPTION.buff.y)
	HDHBuffFrame:SetWidth(DB_OPTION.icon.size)
	HDHBuffFrame:SetHeight(DB_OPTION.icon.size)
	
	HDHDebuffFrame:ClearAllPoints()
	HDHDebuffFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , DB_OPTION.debuff.x, DB_OPTION.debuff.y)
	HDHDebuffFrame:SetWidth(DB_OPTION.icon.size)
	HDHDebuffFrame:SetHeight(DB_OPTION.icon.size)
	--HDH_AlwaysShow(AuraTracking.always_show)
end

local Icons = {Buff = {}, Debuff = {}} -- 아이콘 프레임의 묶음 테이블

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
		self.bar:SetHeight(DB_OPTION.icon.size * ((spell.duration - spell.remaining) / spell.duration))
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end

-- 프레임 이동 시킬때 드래그 시작 콜백 함수
function OnDragStart(self)
	self:StartMoving()
end

-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
function OnDragStop(self)
	if self == HDHBuffFrame then
		DB_OPTION.buff.x = self:GetLeft()
		DB_OPTION.buff.y = self:GetBottom()
	else
		DB_OPTION.debuff.x = self:GetLeft()
		DB_OPTION.debuff.y = self:GetBottom()
	end
	self:StopMovingOrSizing()
end

local function frameBaseSettings(f)
	f:SetFrameStrata('MEDIUM')
	f:SetClampedToScreen(true)
	
	f.icon = f:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.icon:SetPoint('LEFT', f, 'LEFT', 0, 0)
	
	f.border = f:CreateTexture(nil, 'BORDER')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/border.tga]])
	
	f.cooldown = CreateFrame("Frame", nil, f)
	f.cooldown:SetScript('OnUpdate', OnUpdateCooldown)
	
	f.cooldown.bar = f.cooldown:CreateTexture(nil, 'OVERLAY')
	f.cooldown.bar:SetTexture(0,0,0,0.75)
	f.cooldown.bar:SetPoint('BOTTOM', f, 'BOTTOM', 0,0)
	
	f.cooldown.timetext = f.cooldown:CreateFontString(nil, 'OVERLAY')
	
	f.counttext = CreateFrame("Frame", nil, f):CreateFontString(nil, 'OVERLAY')
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
local function HDH_UserCustomFrameSettings(f)
	f:SetSize(DB_OPTION.icon.size,DB_OPTION.icon.size)
	f:EnableMouse(false)
	f:SetMovable(false)
	--f:SetBackdropColor(unpack(SettingsInfo.buff.bgcolor))
	
	local icon = f.icon
	icon:SetWidth(DB_OPTION.icon.size)
	icon:SetHeight(DB_OPTION.icon.size)
	--icon:SetTexCoord(1, 1, 1, 1)
	icon:Show()
	
	f.border:SetWidth(DB_OPTION.icon.size*1.3)
	f.border:SetHeight(DB_OPTION.icon.size*1.3)
	f.border:SetPoint('CENTER', f, 'CENTER', 0, 0)
	
	local bar = f.cooldown.bar
	bar:SetWidth(DB_OPTION.icon.size)
	bar:SetHeight(DB_OPTION.icon.size/100)
	--bar:SetTexCoord(0.2, 0.8, 0.2, 0.8)
	--bar:SetBackdropColor(1.0,0,0)
	
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

function HDH_UpdateSetting()
	if UI_LOCK then
		HDHBuffFrame:SetWidth(DB_OPTION.icon.size)
		HDHBuffFrame:SetHeight(DB_OPTION.icon.size)
		if HDHBuffFrame.text then HDHBuffFrame.text:SetPoint("BOTTOM", HDHBuffFrame, "TOP", 0,0) end
		
		HDHDebuffFrame:SetWidth(DB_OPTION.icon.size)
		HDHDebuffFrame:SetHeight(DB_OPTION.icon.size)
		if HDHDebuffFrame.text then HDHDebuffFrame.text:SetPoint("BOTTOM", HDHDebuffFrame, "TOP", 0,0) end
	end

	for k,frame in pairs(Icons.Buff) do
		HDH_UserCustomFrameSettings(frame)
	end	
	
	for k,frame in pairs(Icons.Debuff) do
		HDH_UserCustomFrameSettings(frame)
	end	
end

-- 해당 데이터가 존재하지 않을때, 실행되는 함수로서  bar 객체를 생성하고 기본 설정을 함
local framefactory_debuff = {
	__index = function(t,k) 
		local f = CreateFrame('Button', nil, HDHDebuffFrame )
		t[k] = f
		frameBaseSettings(f)
		HDH_UserCustomFrameSettings(f)
		return f
	end
}

local framefactory_buff = {
	__index = function(t,k) 
		local f = CreateFrame('Button', nil, HDHBuffFrame)
		t[k] = f
		frameBaseSettings(f)
		HDH_UserCustomFrameSettings(f)
		return f
	end
}

setmetatable(Icons.Buff, framefactory_buff)
setmetatable(Icons.Debuff, framefactory_debuff)


local function SetVisibleUnit(unit, show)
	if(show) then
		if unit == 'player' then  
			if not HDHBuffFrame:IsShown() then HDHBuffFrame:Show() end
		elseif unit == 'target'  then 
			if not HDHDebuffFrame:IsShown() then HDHDebuffFrame:Show() end
		end
	else 
		if unit == 'player' then 
			if HDHBuffFrame:IsShown() then HDHBuffFrame:Hide() end
		elseif unit == 'target'  then 
			if HDHDebuffFrame:IsShown() then HDHDebuffFrame:Hide() end
		end
	end						
end

function HDH_UpdateIconAlpha()
	for i = 1, #(Icons.Debuff) do
		if not Icons.Debuff[i].icon:IsDesaturated() then
			Icons.Debuff[i].icon:SetAlpha(DB_OPTION.icon.on_alpha)
			Icons.Debuff[i].border:SetAlpha(DB_OPTION.icon.on_alpha)
		else
			Icons.Debuff[i].icon:SetAlpha(DB_OPTION.icon.off_alpha)
			Icons.Debuff[i].border:SetAlpha(DB_OPTION.icon.off_alpha)
		end
	end
	
	for i = 1, #(Icons.Buff) do
		if not Icons.Buff[i].icon:IsDesaturated() then
			Icons.Buff[i].icon:SetAlpha(DB_OPTION.icon.on_alpha)
			Icons.Buff[i].border:SetAlpha(DB_OPTION.icon.on_alpha)
		else
			Icons.Buff[i].icon:SetAlpha(DB_OPTION.icon.off_alpha)
			Icons.Buff[i].border:SetAlpha(DB_OPTION.icon.off_alpha)
		end
	end
end

function HDH_CreateDummyIcon(unit, count)
	local icons = {}
	local options = {}
	if     unit == 'player' then icons = Icons.Buff
								 options = DB_OPTION.buff
	elseif unit == 'target' then icons = Icons.Debuff
								 options = DB_OPTION.debuff end
	
	local prevf
	for i=1, count do
		--AllFrameVisible(true)
		f = icons[i]
		f.icon:SetTexture("Interface\\Icons\\TEMP")
		f.cooldown:Show()
		f:ClearAllPoints()
		if options.revers then
			if i > 1 then
				f:SetPoint('RIGHT', prevf, 'LEFT', -DB_OPTION.icon.margin, 0)
				f.icon:SetDesaturated(1)
			else
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0)
				f.icon:SetDesaturated(nil)
			end
		else
			if i > 1 then
				f:SetPoint('LEFT', prevf, 'RIGHT', DB_OPTION.icon.margin, 0)
				f.icon:SetDesaturated(1)
			else
				f:SetPoint('LEFT', f:GetParent(), 'LEFT', 0, 0)
				f.icon:SetDesaturated(nil)
			end
		end
		prevf = f
		local spell = {}
		spell.name = name
		spell.icon = icon
		spell.id = 0
		spell.count = 5
		spell.duration = 10
		spell.reamaining = 0
		spell.endTime = GetTime()+spell.duration
		spell.isBuff = true
		spell.isUpdate = true
		f.spell = spell
		f.counttext:SetText(i)
		f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
		f.border:SetAlpha(DB_OPTION.icon.on_alpha)
		if i == 1 then f.cooldown:Show() 
					   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.on_alpha) 
				  else f.cooldown:Hide()
					   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
					   f.border:SetAlpha(DB_OPTION.icon.off_alpha) end
		f:Show()
	end
end

function HDH_RealeseDummyIcon(unit, count)
	local icons = {}
	if     unit == 'player' then icons = Icons.Buff
	elseif unit == 'target' then icons = Icons.Debuff end
	for i=1, count do
		f = icons[i]
		if f.spell then f.spell = nil end
	end
end

function HDH_SetMoveFrame(unit, move)
	local frame
	if     unit == 'player' then frame = HDHBuffFrame
	elseif unit == 'target' then frame = HDHDebuffFrame end

	if move then
		if not frame.text then
			local text = frame:CreateFontString(nil, 'OVERLAY')
			frame.text = text
			text:ClearAllPoints()
			text:SetFont(DB_OPTION.font.style, 9, "OUTLINE")
			text:SetWidth(100)
			text:SetHeight(40)
			text:SetPoint("BOTTOM", text:GetParent(), "TOP", 0,0)
			text:SetText(("[%s]\n Move this icon\n|\nV"):format(unit:upper()))
			text:SetMaxLines(4) 
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

-- 바 프레임 이동시키는 플래그 및 이동바 생성+출력
function HDH_MoveFrame(lock)
	local dummy_data_count = 10
	if lock then
		UI_LOCK = true
		HDH_SetMoveFrame('player', true)
		HDH_SetMoveFrame('target', true)
		HDH_CreateDummyIcon('player', dummy_data_count)
		HDH_CreateDummyIcon('target', dummy_data_count)
		SetVisibleUnit('player', true)
		SetVisibleUnit('target', true)
	else
		UI_LOCK = false
		HDH_SetMoveFrame('player', false)
		HDH_SetMoveFrame('target', false)
		HDH_RealeseDummyIcon('player',dummy_data_count)
		HDH_RealeseDummyIcon('target',dummy_data_count)
		
		HDH_InitAuraIcon()
	end
end

function HDH_UpdateAuraIcons(unit)
	local prevf, revers, aura
	local ret = 0
	if unit == "player" then revers = DB_OPTION.buff.revers
							 aura = Icons.Buff
						else revers = DB_OPTION.debuff.revers
							 aura = Icons.Debuff end 
	local i = 0
	for k,f in ipairs(aura) do
		if not f.spell then break end
		if f.spell.isUpdate then
			i = i + 1
			if f.spell.count < 2 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count ) end
			if f.spell.duration == 0 then f.cooldown:Hide()
							         else f.cooldown.bar:SetHeight(1)
									      f.cooldown:Show() end
			if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
										   f.icon:SetAlpha(DB_OPTION.icon.on_alpha)
										   f.border:SetAlpha(DB_OPTION.icon.on_alpha)end
			f.spell.isUpdate = false
			if not f:IsShown() then f:Show() end
			if revers then
				if i > 1 then f:SetPoint('RIGHT', prevf, 'LEFT', -DB_OPTION.icon.margin, 0)
						 else f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0) end
			else
				if i > 1 then f:SetPoint('LEFT', prevf, 'RIGHT', DB_OPTION.icon.margin, 0)
						 else f:SetPoint('LEFT', f:GetParent(), 'LEFT', 0, 0) end
			end
			prevf = f
			ret = ret + 1
		else
			if f.spell.fix then 
				i = i + 1
				if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
												   f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
												   f.border:SetAlpha(DB_OPTION.icon.off_alpha)end
				f.counttext:SetText(nil)
				f.cooldown:Hide()
				if revers then
					if i > 1 then f:SetPoint('RIGHT', prevf, 'LEFT', -DB_OPTION.icon.margin, 0)
							 else f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0) end
				else
					if i > 1 then f:SetPoint('LEFT', prevf, 'RIGHT', DB_OPTION.icon.margin, 0)
							 else f:SetPoint('LEFT', f:GetParent(), 'LEFT', 0, 0) end
				end
				prevf = f
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
	if UI_LOCK then return 0 end
	local list, filter
	if unit == 'target' then
		list = Icons.Debuff
		filter = "HARMFUL | PLAYER"
	elseif unit == 'player' then
		list = Icons.Buff
		filter = "HELPFUL"
	else
		return 0
	end
	local name, count, duration, endTime, caster
	local spell
	local f
	if not AuraPointer[unit] then return 0 end
	for i = 1, 40 do 
		name, _, _, count, _, duration, endTime, caster, _, _, id = UnitAura(unit, i, filter)
		if not id then break end
		f = AuraPointer[unit][id]
		if f then
			spell = f.spell
			spell.count = count
			spell.id = id
			spell.remaining = endTime - GetTime()
			spell.duration = duration
			spell.endTime = endTime
			spell.isUpdate = true
		end
	end
	
	return HDH_UpdateAuraIcons(unit)
end

function HDH_InitAuraIcon()
	if UI_LOCK then return end
	if not DB_SPELL.Talent then return end
	local talent = DB_SPELL.Talent[GetSpecialization()]
	if not talent then return end
	
	Buffs = talent.Buff
	Debuffs = talent.Debuff
	AuraPointer = {}
	AuraPointer["player"] = {}
	AuraPointer["target"] = {}
	local prevf
	
	for i = 1, #Buffs do
		local name, rank, icon, castingTime, minRange, maxRange, spellID =  GetCacheSpellInfo(Buffs[i].ID)
		local spell = {}
		local f = Icons.Buff[i]
		AuraPointer["player"][tonumber(Buffs[i].ID)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
		spell.fix = Buffs[i].Fix
		spell.no = Buffs[i].No
		spell.name = name
		spell.icon = icon
		spell.id = tonumber(Buffs[i].ID)
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
		f.border:SetAlpha(DB_OPTION.icon.off_alpha)
		f:ClearAllPoints()
		if DB_OPTION.buff.revers then
			if i > 1 then f:SetPoint('RIGHT', prevf, 'LEFT', -DB_OPTION.icon.margin, 0)
					 else f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0) end
		else
			if i > 1 then f:SetPoint('LEFT', prevf, 'RIGHT', DB_OPTION.icon.margin, 0)
					 else f:SetPoint('LEFT', f:GetParent(), 'LEFT', 0, 0) end
		end
		f:Show()
		prevf = f
	end
	if #(Icons.Buff) > #Buffs then
		for i = #Buffs+1 , #(Icons.Buff) do
			Icons.Buff[i]:Hide()
			Icons.Buff[i].spell = nil
		end
	end
	
	for i = 1, #Debuffs do
		local name, rank, icon, castingTime, minRange, maxRange, spellID = GetCacheSpellInfo(Debuffs[i].ID)
		local spell = {}
		local f = Icons.Debuff[i]
		AuraPointer["target"][tonumber(Debuffs[i].ID)] = f
		
		spell.fix = Debuffs[i].Fix
		spell.no = Debuffs[i].No
		spell.name = name
		spell.icon = icon
		spell.id = tonumber(Debuffs[i].ID)
		spell.count = 0
		spell.duration = 0
		spell.remaining = 0
		spell.endTime = 0
		spell.isBuff = false
		spell.isUpdate = false
		f.spell = spell
		f.icon:SetTexture(icon)
		f.icon:SetDesaturated(1)
		f.icon:SetAlpha(DB_OPTION.icon.off_alpha)
		f.border:SetAlpha(DB_OPTION.icon.off_alpha)
		f:ClearAllPoints()
		if DB_OPTION.debuff.revers then
			if i > 1 then f:SetPoint('RIGHT', prevf, 'LEFT', -DB_OPTION.icon.margin, 0)
					 else f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0) end
		else
			if i > 1 then f:SetPoint('LEFT', prevf, 'RIGHT', DB_OPTION.icon.margin, 0)
					 else f:SetPoint('LEFT', f:GetParent(), 'LEFT', 0, 0) end
		end
		
		f:Show()
		prevf = f
	end
	if #(Icons.Debuff) > #Debuffs then
		for i = #Debuffs+1 , #(Icons.Debuff) do
			Icons.Debuff[i]:Hide()
			Icons.Debuff[i].spell = nil
		end
	end
	
	HDH_UNIT_AURA('player')
	HDH_UNIT_AURA('target')
	--AllFrameVisible(UnitAffectingCombat("player"))
end

function HDH_UNIT_AURA(unit)
	if UI_LOCK then return end
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
		HDH_InitAuraIcon()
	elseif event == 'PLAYER_REGEN_ENABLED' then
		if not UI_LOCK then
			HDH_UNIT_AURA('player')
			HDH_UNIT_AURA('target')
		end
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not UI_LOCK then
			HDH_UNIT_AURA('player')
			HDH_UNIT_AURA('target')
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		HDH_InitVaribles()
		HDH_InitAuraIcon()
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
