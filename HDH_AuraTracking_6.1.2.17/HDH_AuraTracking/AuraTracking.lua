HDH_AT_DB_VERSION = 1.0
MAX_COUNT_AURAFRAME = 20 -- 오라 프레임 최대 개수
MAX_ICONS_COUNT = 1

COOLDOWN_UP     = 1
COOLDOWN_DOWN   = 2
COOLDOWN_LEFT   = 3
COOLDOWN_RIGHT  = 4
COOLDOWN_CIRCLE = 5

FONT_LOCATION_TL = 1
FONT_LOCATION_BL = 2
FONT_LOCATION_TR = 3
FONT_LOCATION_BR = 4
FONT_LOCATION_C = 5
FONT_LOCATION_OT = 6
FONT_LOCATION_OT2 = 7
FONT_LOCATION_OB = 8
FONT_LOCATION_OB2 = 9


HDH_UNIT_LIST = {"player","target","focus","pet","boss1","boss2","boss3","boss4","boss5","party1","party2","party3","party4","arena1","arena2","arena3","arena4","arena5"}
HDH_IS_UNIT = {} -- cooldown 과 같은 다른 플러그인으로 인해 HDH_UNIT_LIST 의 데이터의 카테고리 일관성이 사라질 때 이를 구분하기 위해서 사용함
HDH_GET_CLASS = {} -- 클래스를 unit 명에 맞춰 불러옴, cooldown 처럼 다른 플러그인의 클래스를 가져오기 위한 수단

HDH_TRACKER = {} -- tracker class

do
	for i = 1 , #HDH_UNIT_LIST do
		HDH_IS_UNIT[HDH_UNIT_LIST[i]] = true;
		HDH_GET_CLASS[HDH_UNIT_LIST[i]] = HDH_TRACKER
	end
end

DB_FRAME_LIST = {}
DB_AURA= {}
DB_OPTION = {}
UI_LOCK = false -- 프레임 이동 가능 여부 플래그

local PLAY_SOUND = false

--------------------------------------------
-- OnUpdate
--------------------------------------------

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
local function OnUpdateCooldown(self)
	local spell = self:GetParent().spell
	if not spell then self:Hide() return end

	spell.curTime = GetTime()
	if spell.curTime - (spell.delay or 0) < 0.1 then return end  -- 10프레임
	spell.delay = spell.curTime
	spell.remaining = spell.endTime - spell.curTime

	if spell.remaining > 0.0 and spell.duration > 0 then
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
			self:SetValue(spell.curTime)
		end
	end
end

-------------------------------------------
-- sound
-------------------------------------------

local function HDH_PlaySoundFile(path, channel)
	if PLAY_SOUND then
		PlaySoundFile(path,channel)
	end
end

function HDH_OnShowCooldown(self)
	if self:GetParent().spell and self:GetParent().spell.startSound and not OptionFrame:IsShown() then
		if (self:GetParent().spell.duration - self:GetParent().spell.remaining) < 0.5 then
			HDH_PlaySoundFile(self:GetParent().spell.startSound,"SFX")
		end
	end
end

function HDH_OnHideCooldown(self)
	if self:GetParent().spell and self:GetParent().spell.endSound and not OptionFrame:IsShown() then
		HDH_PlaySoundFile(self:GetParent().spell.endSound, "SFX")
	end
end



-------------------------------------------
-- icon frame struct
-------------------------------------------

local function frameBaseSettings(f)
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
	f.cooldown2 = CreateFrame("Cooldown", nil, f) -- 원형
	f.cooldown2:SetPoint('LEFT', f, 'LEFT', 0,0)
	f.cooldown2:SetScript('OnUpdate', OnUpdateCooldown)
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
	
	f.v1 = tempf:CreateFontString(nil, 'OVERLAY')
	f.v1:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.v1:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.v1:SetNonSpaceWrap(false)
	f.v1:SetJustifyH('RIGHT')
	f.v1:SetJustifyV('TOP')
	
	f.v2 = tempf:CreateFontString(nil, 'OVERLAY')
	f.v2:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.v2:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.v2:SetNonSpaceWrap(false)
	f.v2:SetJustifyH('RIGHT')
	f.v2:SetJustifyV('TOP')
	
	tempf:SetFrameLevel(f.cooldown2:GetFrameLevel()+1)
	
	f.border = CreateFrame("Frame", nil, f):CreateTexture(nil, 'OVERLAY')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/border.blp]])
	f.border:SetVertexColor(0,0,0)
end

--------------------------------------------
-- DB 연산
--------------------------------------------

function HDH_RefreshFrameLevel_All()
	local t
	for i= #DB_FRAME_LIST ,1 ,-1  do
		t = HDH_TRACKER.Get(DB_FRAME_LIST[i].name)
		if t and t.frame then
			t.frame:SetFrameLevel((MAX_COUNT_AURAFRAME-i)*5)
		end
	end
end

function HDH_DB_Add_FRAME_LIST(newName, newUnit)
	DB_FRAME_LIST[#DB_FRAME_LIST+1] = { name = newName, unit = newUnit }
end

function HDH_DB_Remove(name)
	local removedIdx = 0
	for i= 1 , #DB_FRAME_LIST do
		if DB_FRAME_LIST[i].name == name then
			DB_FRAME_LIST[i] = nil
			removedIdx = i
			break
		end
	end
	if removedIdx > 0 then
		for i = removedIdx , #DB_FRAME_LIST do -- 순서 정렬
			DB_FRAME_LIST[i] = DB_FRAME_LIST[i+1]
		end
	end
	
	DB_OPTION[name] = nil
	local id, talent
	for i = 1, 4 do
		id, talent = GetSpecializationInfo(i)
		if id and DB_AURA.Talent[i] and DB_AURA.Talent[i][name] then 
			DB_AURA.Talent[i][name] = nil
		end
	end
end

function HDH_DB_Modify(oldName, oldUnit, newName, newUnit)
	for i = 1 , #DB_FRAME_LIST do
		if DB_FRAME_LIST[i].name == oldName then
			DB_FRAME_LIST[i].name = newName
			DB_FRAME_LIST[i].unit = newUnit
			break
		end
	end
	
	DB_OPTION[oldName].unit = newUnit
	if oldName ~= newName then
		DB_OPTION[newName] = DB_OPTION[oldName]
		DB_OPTION[oldName] = nil
		local id, talent
		for i =1, 4 do
			id, talent = GetSpecializationInfo(i)
			if id and DB_AURA.Talent[i] and DB_AURA.Talent[i][oldName] then 
				DB_AURA.Talent[i][newName] = DB_AURA.Talent[i][oldName]
				DB_AURA.Talent[i][oldName] = nil	
			end
		end
	end
end


--------------------------------------------
-- TRACKER Class 
--------------------------------------------

HDH_TRACKER.objList = {}
HDH_TRACKER.__index = HDH_TRACKER

--------------------------------------------
do -- TRACKER Static function
--------------------------------------------

	function HDH_TRACKER.new(name, unit)
		local obj = {}
		setmetatable(obj, HDH_GET_CLASS[unit])
		obj:Init(name, unit)
		HDH_TRACKER.AddList(obj)
		return obj
	end

	function HDH_TRACKER.ClearAll()
		for k,v in ipairs(HDH_TRACKER.objList) do
			HDH_TRACKER.RemoveList(v)

		end
	end

	function HDH_TRACKER.RemoveList(t) -- t = (string) or (tracker obj)
		if type(t) == "string" then
			t = HDH_TRACKER.Get(t) -- 객체로 바꿔서
		end
		if not t then return end
		HDH_DB_Remove(t.name)
		t:Release()
		HDH_TRACKER.objList[t.name] = nil
	end

	function HDH_TRACKER.AddList(tracker)
		HDH_TRACKER.objList[tracker.name] = tracker
	end

	function HDH_TRACKER.ModifyList(oldName, newName)
		if oldName == newName then return end
		HDH_TRACKER.objList[newName] = HDH_TRACKER.objList[oldName]
		HDH_TRACKER.objList[oldName] = nil
	end

	function HDH_TRACKER.Get(name)
		return HDH_TRACKER.objList[name] or nil
	end

	function HDH_TRACKER.GetList()
		return HDH_TRACKER.objList
	end

	function HDH_TRACKER.InitVaribles()
		-- 세팅 정보 저장하는 세이브인스턴스
		if not DB_OPTION or not DB_OPTION.HDH_AT_DB_VERSION or (tonumber(DB_OPTION.HDH_AT_DB_VERSION) ~= HDH_AT_DB_VERSION) then
			DB_OPTION = { always_show = false, 
							 tooltip_id_show = true,
							 icon   = { size = 40, margin_v = 4, margin_h = 4, 
										on_alpha = 1, off_alpha = 0.5,
										buff_color = {0,0,0}, debuff_color = {0,0,0},
										show_cooldown = true,
										cooldown_bg_color = {0,0,0,0.75}}, 
							 font   = { fontsize= 15, cd_location = FONT_LOCATION_TR, textcolor={1,1,0}, textcolor_5s={1,0,0}, -- 쿨 다운
										countsize = 15, count_location =  FONT_LOCATION_BL, countcolor={1,1,1}, -- 중첩
										v1_size = 15, v1_location = FONT_LOCATION_BL, v1_color = {1,1,1}, -- 1차
										v2_size = 15, v2_location = FONT_LOCATION_BL, v2_color = {1,1,1}, -- 2차
										style=[[fonts\FRIZQT__.ttf]]}, -- 폰트 종류
						   }
			DB_OPTION.HDH_AT_DB_VERSION = HDH_AT_DB_VERSION
		end
		if DB_OPTION.font.v1_size == nil then
			DB_OPTION.font.v1_size = 15;
			DB_OPTION.font.v1_location = FONT_LOCATION_BL;
			DB_OPTION.font.v1_color = {1,1,1}
			DB_OPTION.font.v2_size = 15;
			DB_OPTION.font.v2_location = FONT_LOCATION_BL;
			DB_OPTION.font.v2_color = {1,1,1};
		end
		
		if DB_OPTION.icon.margin_v == nil then
			DB_OPTION.icon.margin_v = 4;
			DB_OPTION.icon.margin_h = 4;
		end
		
		if not DB_AURA or not GetSpecialization() or not DB_AURA.HDH_AT_DB_VERSION or (tonumber(DB_AURA.HDH_AT_DB_VERSION) ~= HDH_AT_DB_VERSION) then
			DB_AURA = {} 
			DB_AURA.HDH_AT_DB_VERSION = HDH_AT_DB_VERSION
			local class = select(2, UnitClass("player"))
			DB_AURA.name = class
			
			DB_AURA.Talent = {}
			local id, talent
			for i =1, 4 do
				id, talent = GetSpecializationInfo(i)
				if id then
					DB_AURA.Talent[i] = {ID = id, Name = talent} 
				end
			end
		end
		
		local tracker
		for i = 1, #DB_FRAME_LIST do
			tracker = HDH_TRACKER.Get(DB_FRAME_LIST[i].name)
			if not tracker then
				HDH_TRACKER.new(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].unit)
			else
				tracker:Init(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].unit)
			end
		end
		HDH_RefreshFrameLevel_All()
	end

	function HDH_TRACKER.UpdateSettingAll()
		for k, tracker in pairs(HDH_TRACKER.GetList()) do
			tracker:UpdateSetting()
		end
	end

	-- 바 프레임 이동시키는 플래그 및 이동바 생성+출력
	function HDH_TRACKER.SetMoveAll(lock)
		local dummy_data_count = 10
		if lock then
			UI_LOCK = true
			for k, tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:SetMove(true)
			end
		else
			UI_LOCK = false
			for k, tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:SetMove(false)
				
			end
		end
	end

------------------------------------------
end -- TRACKER Static function 
------------------------------------------

------------------------------------------
do -- TRACKER Class
--------------------------------------------

	function HDH_TRACKER:InitVariblesOption()
		if not DB_OPTION[self.name] then
			DB_OPTION[self.name]={	unit = self.unit,
										x = UIParent:GetWidth()/2, 
										y = UIParent:GetHeight()/2, 
										revers_h = false, 
										revers_v = false,
										cooldown = 1, -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
										line = 5,
										check_debuff = true,
										check_buff = true,
										check_only_mine = true,
										check_pet = false,
										use_each = false,
										fix = false,
										tracking_all = false}
		end
		self.option = {}
		self.option.base = DB_OPTION[self.name]
		if DB_OPTION[self.name].use_each then
			self.option.icon = DB_OPTION[self.name].icon
			self.option.font = DB_OPTION[self.name].font
		else
			self.option.icon = DB_OPTION.icon
			self.option.font = DB_OPTION.font
		end
		
		if self.option.font.countsize == nil then -- 6.1.2.10 + count size, count/cooldown location
			self.option.font.countsize = self.option.font.fontsize
			if self.option.base == COOLDOWN_CIRCLE then
				self.option.font.cd_location = FONT_LOCATION_C
			else
				self.option.font.cd_location = FONT_LOCATION_BL
			end
			self.option.font.count_location =  FONT_LOCATION_TR
		end
		
		if self.option.font.v1_size == nil then
			self.option.font.v1_size = 15;
			self.option.font.v1_location = FONT_LOCATION_BL;
			self.option.font.v1_color = {1,1,1};
			self.option.font.v2_size = 15;
			self.option.font.v2_location = FONT_LOCATION_BL;
			self.option.font.v2_color = {1,1,1};
		end
		
		if self.option.icon.margin_v == nil then
			self.option.icon.margin_v = 4;
			self.option.icon.margin_h = 4;
		end
	end

	function HDH_TRACKER:InitVariblesAura()
		local id, talent
		for i =1, 4 do
			id, talent = GetSpecializationInfo(i)
			if id then
				if not DB_AURA.Talent[i] then 
					DB_AURA.Talent[i] = {ID = id, Name = talent} 
				end
				if not DB_AURA.Talent[i][self.name] then
					DB_AURA.Talent[i][self.name] = {}
				end
			end
		end
	end

	function HDH_TRACKER:Init(name,unit)
		self.unit = unit
		self.name = name
		if self.frame == nil then
			self.frame = CreateFrame("Frame", nil, HDH_AT_ADDON_Frame)
			self.frame:SetFrameStrata('MEDIUM')
			self.frame:SetClampedToScreen(true)
			self.frame.parent = self
			self.frame.icon = {}
			self.frame.pointer = {}
			
			setmetatable(self.frame.icon, {
				__index = function(t,k) 
					local f = CreateFrame('Button', nil, self.frame)
					
					t[k] = f
					frameBaseSettings(f)
					self:UpdateIconSettings(f)
					return f
				end})
		end
		
		self:InitVariblesOption()
		self:InitVariblesAura()
		self.frame:ClearAllPoints()
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , DB_OPTION[name].x, DB_OPTION[name].y)
		self.frame:SetSize(self.option.icon.size, self.option.icon.size)
		self:InitIcons()
	end
	
	function HDH_TRACKER:Release()
		self:ReleaseIcons()
		self.frame:Hide()
		self.frame:SetParent(nil)
		self.frame.parent = nil
		self.frame = nil
		self.timer = nil
	end

	function HDH_TRACKER:Modify(newName, newUnit)
		HDH_DB_Modify(self.name, self.unit, newName, newUnit)
		HDH_TRACKER.ModifyList(self.name, newName)
		
		if newUnit ~= self.unit then
			self:Release() -- 프레임 관련 메모리 삭제하고
			setmetatable(self, HDH_GET_CLASS[newUnit]) -- 클래스 변경하고
			self:Init(newName, newUnit) -- 프레임 초기화 + DB 로드
		end
		self.name = newName
		self.unit = newUnit
		if UI_LOCK then
			self:SetMove(false)
			self:SetMove(true)
		else
			self:InitIcons()
		end
	end
	
	local function ChangeFontLocation(parent, fontf, location, op_font)
		local location_list = {op_font.count_location, op_font.cd_location, op_font.v2_location, op_font.v1_location}
		local size_list = {op_font.countsize, op_font.fontsize , op_font.v2_size, op_font.v2_size}
		local margin = 0
		
		if location == FONT_LOCATION_TL then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 2, -2)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 50, -30)
			fontf:SetJustifyH('LEFT')
			fontf:SetJustifyV('TOP')
		elseif location == FONT_LOCATION_BL then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 2, 30)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 50, 2)
			fontf:SetJustifyV('BOTTOM')
			fontf:SetJustifyH('LEFT')
		elseif location == FONT_LOCATION_TR then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -50, -2)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -2, -30)
			fontf:SetJustifyV('TOP')
			fontf:SetJustifyH('RIGHT')
		elseif location == FONT_LOCATION_BR then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -50, 30)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -2, 2)
			fontf:SetJustifyV('BOTTOM')
			fontf:SetJustifyH('RIGHT')
		elseif location == FONT_LOCATION_C then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -25, 15)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 25, -15)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('CENTER')
		elseif location == FONT_LOCATION_OB then
			fontf:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', -25, -1)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 25, -40)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('TOP')
		elseif location == FONT_LOCATION_OB2 then
			for i = 1, #location_list do
				if location_list[i] == FONT_LOCATION_OB then
					margin = size_list[i]
				end
			end
			fontf:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', -25, -margin)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 25, -(40+margin))
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('TOP')
		elseif location == FONT_LOCATION_OT then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -25, 40)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', 25, 0)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('BOTTOM')
		elseif location == FONT_LOCATION_OT2 then
			for i = 1, #location_list do
				if location_list[i] == FONT_LOCATION_OT then
					margin = size_list[i]
				end
			end
		
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -25, 40+margin)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', 25, margin)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('BOTTOM')
		end
	end

	-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
	function HDH_TRACKER:UpdateIconSettings(f)
		local op_icon, op_font
		if DB_OPTION[self.name].use_each then
			op_icon = DB_OPTION[self.name].icon
			op_font = DB_OPTION[self.name].font
		else
			op_icon = DB_OPTION.icon
			op_font = DB_OPTION.font
		end
		f:SetSize(op_icon.size,op_icon.size)
		f:EnableMouse(false)
		f:SetMovable(false)
		
		local icon = f.icon
		f.border:SetWidth(op_icon.size*1.3)
		f.border:SetHeight(op_icon.size*1.3)
		f.border:SetPoint('CENTER', f, 'CENTER', 0, 0)
		f.cooldown1:SetStatusBarTexture(unpack(op_icon.cooldown_bg_color))
		f.cooldown2:SetSwipeColor(unpack(op_icon.cooldown_bg_color))
		--f.overlay.animIn:Play()
		if 4 > op_icon.size*0.08 then
			op_icon.margin = 4
		else
			op_icon.margin = op_icon.size*0.08
		end
		
		local counttext = f.counttext
		counttext:SetFont(op_font.style, op_font.countsize, "OUTLINE")
		--counttext:SetTextHeight(op_font.countsize)
		counttext:SetTextColor(unpack(op_font.countcolor))
		ChangeFontLocation(f, counttext, op_font.count_location, op_font)
		if op_icon.show_cooldown then
			f.cooldown2.timetext:Show()
			f.cooldown1.timetext:Show()
		else
			f.cooldown2.timetext:Hide()
			f.cooldown1.timetext:Hide()
		end
		
		local v1Text = f.v1
		v1Text:SetFont(op_font.style, op_font.v1_size, "OUTLINE")
		v1Text:SetTextColor(unpack(op_font.v1_color))
		ChangeFontLocation(f, v1Text, op_font.v1_location, op_font)
		
		local v2Text = f.v2
		v2Text:SetFont(op_font.style, op_font.v2_size, "OUTLINE")
		v2Text:SetTextColor(unpack(op_font.v2_color))
		ChangeFontLocation(f, v2Text, op_font.v2_location, op_font)
		
		local timetext = f.cooldown1.timetext
		--timetext:SetTextHeight(op_font.fontsize)
		timetext:SetFont(op_font.style, op_font.fontsize, "OUTLINE")
		timetext:SetTextColor(unpack(op_font.textcolor))
		ChangeFontLocation(f, timetext, op_font.cd_location, op_font)
		timetext = f.cooldown2.timetext
		--timetext:SetTextHeight(op_font.fontsize)
		timetext:SetFont(op_font.style, op_font.fontsize, "OUTLINE")
		timetext:SetTextColor(unpack(op_font.textcolor))
		ChangeFontLocation(f, timetext, op_font.cd_location, op_font)
		
		self:ChangeCooldownType(f, DB_OPTION[self.name].cooldown)
	end

	function HDH_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local prevf, f, spell
		if icons then
			if #icons > 0 then count = #icons end
		end
		for i=1, count do
			f = icons[i]
			if not f:GetParent() then f:SetParent(self.frame) end
			if f.icon:GetTexture() == nil then
				f.icon:SetTexture("Interface\\ICONS\\TEMP")
			end
			f:ClearAllPoints()
			prevf = f
			spell = f.spell
			if not spell then spell = {} end
			spell.always = true
			spell.id = 0
			spell.count = 3+i
			spell.duration = 70
			spell.remaining = 0
			spell.glow = false
			spell.endTime = curTime + spell.duration
			spell.startTime = spell.endTime - spell.duration
			if spell.showValue then
				if spell.showV1 then
					spell.v1 = 10
				end
				if spell.showV2 then
					spell.v2 = 20
				end
			end
			if option.base.check_buff	then spell.isBuff = true
									else spell.isBuff = false end
			if option.base.cooldown == COOLDOWN_CIRCLE then
					f.cd:SetCooldown(spell.startTime,spell.duration)
				else
					f.cd:SetMinMaxValues(spell.startTime, spell.endTime)
				end
			f.spell = spell
			f.counttext:SetText(i)
			f.icon:SetAlpha(option.icon.on_alpha)
			f.border:SetAlpha(option.icon.on_alpha)
			if i <=	100 then  f.cd:Show() 
						   f.icon:SetAlpha(option.icon.on_alpha)
						   f.border:SetAlpha(option.icon.on_alpha) 
						   spell.isUpdate = true
					  else f.cd:Hide()
						   f.icon:SetAlpha(option.icon.off_alpha)
						   f.border:SetAlpha(option.icon.off_alpha)
						   spell.isUpdate = false end
			f:Show()
		end
	end

	function HDH_TRACKER:ReleaseIcons()
		if not self.frame.icon then return end
		for i=#self.frame.icon, 1, -1 do
			self:ReleaseIcon(i)
		end
	end
	
	function HDH_TRACKER:ReleaseIcon(idx)
		self.frame.icon[idx]:Hide()
		self.frame.icon[idx]:SetParent(nil)
		self.frame.icon[idx].spell = nil
		self.frame.icon[idx] = nil
	end
	
	-- 프레임 이동 시킬때 드래그 시작 콜백 함수
	local function OnDragStart(self)
		self:StartMoving()
	end
	
	local function OnMouseDown(self)
		for k,v in pairs(HDH_TRACKER.GetList()) do
			if v.frame.text then
				if v.frame ~= self then
					v.frame.text:Hide()
				end
			end
		end
	end
	
	local function OnMouseUp(self)
		for k,v in pairs(HDH_TRACKER.GetList()) do
			if v.frame.text then
				v.frame.text:Show()
			end
		end
	end
	
	-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
	local function OnDragStop(self)
		local t = HDH_TRACKER.Get(self.name)
		self:StopMovingOrSizing()
		if t then
			t.option.base.x = self:GetLeft()
			t.option.base.y = self:GetBottom()
			t.frame:ClearAllPoints()
			t.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , t.option.base.x , t.option.base.y)
		end
		OnMouseUp(self)
	end

	local function OnDragUpdate(self)
		self.text:SetText(("%s\n  |cffffffff(%d, %d)"):format(self.text.text, self:GetLeft(),self:GetBottom()))
		
		--self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , math.floor(self:GetLeft()) , math.floor(self:GetBottom()))
	end

	function HDH_TRACKER:UpdateSetting()
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
			if not iconf.icon:IsDesaturated() then
				iconf.icon:SetAlpha(self.option.icon.on_alpha)
				iconf.border:SetAlpha(self.option.icon.on_alpha)
			else
				iconf.icon:SetAlpha(self.option.icon.off_alpha)
				iconf.border:SetAlpha(self.option.icon.off_alpha)
			end
		end	
		self.option.base.x = self.frame:GetLeft()
		self.option.base.y = self.frame:GetBottom()
	end

	function HDH_TRACKER:SetMove(move)
		if not self.frame then return end
		if move then
			if not self.frame.text then
				local tf = CreateFrame("Frame",nil, self.frame)
				tf:SetFrameStrata("HIGH")
				--tf.SetAllPoints(frame)
				local text = tf:CreateFontString(nil, 'OVERLAY')
				self.frame.text = text
				text:ClearAllPoints()
				text:SetFont([[fonts\2002.ttf]], 13, "THICKOUTLINE")
				text:SetTextColor(1,0,0)
				text:SetWidth(190)
				text:SetHeight(70)
				text:SetAlpha(0.7)
				text:SetPoint("TOPLEFT", self.frame, "BOTTOMRIGHT", -5, 12)
				text:SetJustifyH("LEFT")
				text.text = ("▶\n|cffaaaaaa  첫번째 아이콘을 움직이세요\n|cffffff00   ["..self.name.."]")
				text:SetMaxLines(6) 
			end
			self.frame.name = self.name
			self.frame.text:Show()
			self.frame:SetScript('OnDragStart', OnDragStart)
			self.frame:SetScript('OnDragStop', OnDragStop)
			self.frame:SetScript('OnMouseDown', OnMouseDown)
			self.frame:SetScript('OnMouseUp', OnMouseUp)
			self.frame:SetScript('OnUpdate', OnDragUpdate)
			self.frame:SetScript('OnReceiveDrag', OnReceiveDrag)
			self.frame:RegisterForDrag('LeftButton')
			self.frame:EnableMouse(true)
			self.frame:SetMovable(true)
			local cnt = (self.option.base.tracking_all and 10) or MAX_ICONS_COUNT
			self:CreateDummySpell(cnt)
			self.frame:Show()
			self:UpdateIcons()
		else
			self.frame.name = nil
			self.frame:EnableMouse(false)
			self.frame:SetMovable(false)
			self.frame:SetScript('OnUpdate', nil)
			if self.frame.text then 
				self.frame.text:Hide() 
				self.frame.text:GetParent():SetParent(nil) 
				self.frame.text = nil
			end
			self:ReleaseIcons()
			self:InitIcons()
		end
	end

	function HDH_TRACKER:ChangeCooldownType(f, cooldown_type)
		if cooldown_type == COOLDOWN_UP then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_DOWN  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_LEFT  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == COOLDOWN_RIGHT then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		else 
			f.cd = f.cooldown2
			f.cooldown1:Hide()
		end
	end
	
	local function numWithCommas(n)
		return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
	end
	
	local function ValueFormat(value, v_type)
		if not value then return "" end
		if value < 1000 then
			value = string.format("%d%s", value, (v_type or nil))
		elseif value < 1000000 then
			value = value/1000
			value = string.format("%dk%s", value, (v_type or nil))
		else
			value = value/1000000
			value = string.format("%dm%s", value, (v_type or nil))
		end
		--value = string.format("%s%s", numWithCommas(value), (v_type or nil))
		return value	
	end
	
	function HDH_TRACKER:UpdateIcons()
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
		local size = self.option.icon.size -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local icons = self.frame.icon
		
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				f.spell.isUpdate = false
				
				if self.option.base.check_only_mine then
					if f.spell.count < 2 then f.counttext:SetText(nil)
										 else f.counttext:SetText(f.spell.count) end
				else
					if f.spell.count < 2 then if f.spell.overlay == 1 then f.counttext:SetText(nil)
																      else f.counttext:SetText(f.spell.overlay) end
										 else f.counttext:SetText(f.spell.count)  end
				end
			
				if not f.spell.showV1 or f.spell.v1 == 0 then f.v1:SetText(nil)
														 else f.v1:SetText(ValueFormat(f.spell.v1, f.spell.v1_type)) end
				if not f.spell.showV1 or f.spell.v2 == 0 then f.v2:SetText(nil)
														 else f.v2:SetText(ValueFormat(f.spell.v2, f.spell.v2_type)) end
				
				if f.spell.duration == 0 then f.cd:Hide() 
										 else f.cd:Show() end
				if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil)
											   f.icon:SetAlpha(self.option.icon.on_alpha)
											   f.border:SetAlpha(self.option.icon.on_alpha)end
				if f.spell.isBuff then f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
								  else if self.option.base.defaultColor then f.border:SetVertexColor(DebuffTypeColor[f.spell.dispelType or ""].r,
																									 DebuffTypeColor[f.spell.dispelType or ""].g,
																									 DebuffTypeColor[f.spell.dispelType or ""].b)
								                                        else f.border:SetVertexColor(unpack(self.option.icon.debuff_color)) end end
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
					f.v1:SetText(nil)
					f.v2:SetText(nil)
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
			f.spell.overlay = 0
			f.spell.count = 0
		end
		return ret
	end

	local StaggerID = { }
	StaggerID[124275] = true
	StaggerID[124274] = true
	StaggerID[124273] = true 
	local ResolveID = {}
	ResolveID[158300] = true
	ResolveID["결의"] = true
	local IgniteID = {}
	IgniteID[12654] = true
	IgniteID[83853] = true
	IgniteID["발화"] = true
	
	local function GetAuras(self, filter, isbuff)
		local curTime = GetTime()
		local name, count, duration, endTime, caster, id, v2, v3
		for i = 1, 40 do 
			name, _, _, count, dispelType, duration, endTime, caster, _, _, id, _, _, _, v2, v3 = UnitAura(self.unit, i, filter)
			if not id then break end
			f = self.frame.pointer[tostring(id)] or self.frame.pointer[name]
			if f and f.spell then
				spell = f.spell
				spell.isUpdate = true
				if spell.showValue then
					if spell.showV1 then 
						if spell.v1_hp then
							spell.v1 = math.ceil((v2 / UnitHealthMax(self.unit)) *100)
						else
							spell.v1 = v2; 
						end
						if ResolveID[id] and v2 == 0 then spell.isUpdate = false end 
					end
					if spell.showV2 then
						if spell.v2_hp then
							spell.v2 = math.ceil((v3 / UnitHealthMax(self.unit)) *100)
						else
							spell.v2 = v3; 
						end
						if ResolveID[id] and v3 == 0 then spell.isUpdate = false end 
					end 
				end
				spell.count = spell.count + count
				spell.id = id
				spell.dispelType = dispelType
				spell.overlay = (spell.overlay or 0) + 1
				spell.endTime = endTime
				spell.remaining = spell.endTime - curTime
				spell.duration = duration
				spell.startTime = endTime - duration
				spell.isBuff = isbuff
			end
		end
	end
	
	local function GetAurasAll(self, filter, isbuff) 
		local curTime = GetTime()
		local ret = 1
		for i = ret, 40 do 
			name, _, icon, count, dispelType, duration, endTime, caster, _, _, id, canApplyAura, isBossDebuff, v1,v2,v3 = UnitAura(self.unit, i, filter)
			if not id then ret = i break end
			f = self.frame.icon[i]
			if f then
				if not f.spell then
					f.spell = {}
				end
				spell = f.spell
				spell.isUpdate = true
				spell.count = count
				spell.id = id
				spell.overlay = 0
				spell.endTime = endTime
				spell.dispelType = dispelType
				spell.remaining = spell.endTime - curTime
				spell.duration = duration
				spell.startTime = endTime - duration
				spell.isBuff = isbuff
				spell.icon = icon
				f.icon:SetTexture(icon)
			end
		end
		for i = ret, #(self.frame.icon) do
			self.frame.icon[i]:Hide()
		end
	end

	-- 버프, 디버프의 상태가 변경 되었을때 마다 실행되어, 데이터 리스트를 업데이트 하는 함수
	function HDH_TRACKER:Update()
		if not self.frame or UI_LOCK then return end
		if not UnitExists(self.unit) or not self.frame.pointer or not self.option then 
			self.frame:Hide() return 
		end
		
		local mine
		if self.option.base.check_only_mine then 
			mine = "|PLAYER"
		end
		
		if self.option.base.check_debuff then 
			self.GetAurasFunc(self, "HARMFUL"..(mine or ""), false)
		end
		
		if self.option.base.check_buff then 
			self.GetAurasFunc(self, "HELPFUL", true)
		end
		
		if (self:UpdateIcons(self) > 0) or DB_OPTION.always_show or UnitAffectingCombat("player") then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	end

	function HDH_TRACKER:InitIcons()
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[GetSpecialization()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID
		local spell 
		local iconFrame
		local isTanker = false
		local isIgnite = false
		self.frame.pointer = {}
		if self.option.base.tracking_all then
			self.GetAurasFunc = GetAurasAll
		else
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
				spell.glowV1= auraList[i].GlowV1
				spell.glowV2 = auraList[i].GlowV2
				spell.always = auraList[i].Always
				spell.showValue = auraList[i].ShowValue
				spell.showV1 = auraList[i].v1
				spell.v1_hp =  auraList[i].v1_hp
				spell.v2_hp =  auraList[i].v2_hp
				spell.v1 = 0
				spell.v1_type = auraList[i].v1_type
				spell.showV2 = auraList[i].v2
				spell.v2 = 0
				spell.v2_type = auraList[i].v2_type
				spell.no = auraList[i].No
				spell.name = auraList[i].Name
				spell.icon = auraList[i].Texture
				spell.id = tonumber(auraList[i].ID)
				spell.count = 0
				spell.duration = 0
				spell.remaining = 0
				spell.overlay = 0
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
			end
			self.GetAurasFunc = GetAuras
		end
		if #(self.frame.icon) > #auraList then
			for i = #(self.frame.icon) ,#auraList+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		
		self.frame:SetScript("OnEvent", OnEventTracker)
		self.frame:UnregisterAllEvents()
		if #(self.frame.icon) > 0 or self.option.base.tracking_all then
			self.frame:RegisterEvent('UNIT_AURA')
			if self.unit == 'target' then
				self.frame:RegisterEvent('PLAYER_TARGET_CHANGED')
			elseif self.unit == 'focus' then
				self.frame:RegisterEvent('PLAYER_FOCUS_CHANGED')
			elseif string.find(self.unit, "boss") then 
				self.frame:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT')
			elseif string.find(self.unit, "party") then
				self.frame:RegisterEvent('GROUP_ROSTER_UPDATE')
			elseif self.unit == 'pet' then
				self.frame:RegisterEvent('UNIT_PET')
			elseif string.find(self.unit, 'arena') then
				self.frame:RegisterEvent('ARENA_OPPONENT_UPDATE')
			end
		else
			return 
		end
		
		self:Update()
		--AllFrameVisible(UnitAffectingCombat("player"))
	end

	function HDH_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
	
	function HDH_TRACKER:PLAYER_ENTERING_WORLD()
	
	end
	
	-------------------------------------------
	-- 애니메이션 관련
	-------------------------------------------
	function HDH_TRACKER:ActionButton_ShowOverlayGlow(f)
		if ( f.overlay ) then
			if ( f.overlay.animOut:IsPlaying() ) then
				f.overlay.animOut:Stop();
				f.overlay.animIn:Play();
			end
		else
			f.overlay = ActionButton_GetOverlayGlow();
			local frameWidth, frameHeight = f:GetSize();
			f.overlay:SetParent(f);
			f.overlay:ClearAllPoints();
			--Make the height/width available before the next frame:
			f.overlay:SetSize(frameWidth * 1.64, frameHeight * 1.64);
			f.overlay:SetPoint("TOPLEFT", f, "TOPLEFT", -frameWidth * 0.36, frameHeight * 0.36);
			f.overlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", frameWidth * 0.36, -frameHeight * 0.36);
			f.overlay.animIn:Play();
			if f.spell.conditionSound and not OptionFrame:IsShown() then
				HDH_PlaySoundFile(f.spell.conditionSound, "SFX")
			end
		end
	end
	
	function HDH_TRACKER:IsGlowing(f)
		return f.overlay and true or false
	end

	function HDH_TRACKER:SetGlow(f, bool)
		if f.spell.ableGlow then -- 블리자드 기본 반짝임 효과면 무조건 적용
			self:ActionButton_ShowOverlayGlow(f)
			return
		end
		if bool and (f.spell and f.spell.glow) then
			if f.spell.glowCount and (f.spell.count >= f.spell.glowCount) then
				self:ActionButton_ShowOverlayGlow(f)
				return
			elseif f.spell.glowV1 and (f.spell.v1 >= f.spell.glowV1) then
				self:ActionButton_ShowOverlayGlow(f)
				return
			elseif f.spell.glowV2 and (f.spell.v2 >= f.spell.glowV2) then
				self:ActionButton_ShowOverlayGlow(f)
				return
			end
		end
		ActionButton_HideOverlayGlow(f)
	end
	
	-------------------------------------------
	-- timer 
	-------------------------------------------
	function HDH_TRACKER:RunTimer(timerName, time, func, ...)
		if not self.timer then self.timer = {} end
		if self.timer[timerName] then
			self.timer[timerName]:Cancel()
		end
		local args = {...}
		self.timer[timerName] = C_Timer.NewTimer(time, function() self.timer[timerName] = nil func(unpack(args)) end)
	end
------------------------------------------
end -- TRACKER class
------------------------------------------




-------------------------------------------
-- 이벤트 메세지 function
-------------------------------------------
local function HDH_UNIT_AURA(self)
	if self then
		self:Update()
	end
end

local function PLAYER_ENTERING_WORLD()
	print('|cffffff00HDH - AuraTracking |cffffffff(Setting: /at, /auratracking, /ㅁㅅ)')
	HDH_AT_ADDON_Frame:RegisterEvent('VARIABLES_LOADED')
	--HDHFrame:RegisterEvent('PLAYER_LOGIN')
	--HDHFrame:RegisterEvent('ADDON_LOADED')
	HDH_AT_ADDON_Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
	HDH_AT_ADDON_Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
	HDH_AT_ADDON_Frame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')

	HDH_TRACKER.InitVaribles()
	for i = 1, #DB_FRAME_LIST do
		if HDH_TRACKER.Get(DB_FRAME_LIST[i].name) then
			HDH_TRACKER.Get(DB_FRAME_LIST[i].name):PLAYER_ENTERING_WORLD()
		end
	end
end

function OnEventTracker(self, event, ...)
	if event == 'UNIT_AURA' then
		local unit = select(1,...)
		if self.parent and unit == self.parent.unit then
			HDH_UNIT_AURA(self.parent)
		end
	elseif event =="PLAYER_TARGET_CHANGED" then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'INSTANCE_ENCOUNTER_ENGAGE_UNIT' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'GROUP_ROSTER_UPDATE' then
		HDH_UNIT_AURA(self.parent)
	elseif event == 'UNIT_PET' then
		self.parent:RunTimer("UNIT_PET", 0.5, HDH_UNIT_AURA, self.parent) 
	elseif event == 'ARENA_OPPONENT_UPDATE' then
		self.parent:RunTimer("ARENA_OPPONENT_UPDATE", 0.5, HDH_UNIT_AURA, self.parent) 
	end
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	if event =='ACTIVE_TALENT_GROUP_CHANGED' then
		for i = 1, #DB_FRAME_LIST do
			if HDH_TRACKER.Get(DB_FRAME_LIST[i].name) then
				HDH_TRACKER.Get(DB_FRAME_LIST[i].name):ACTIVE_TALENT_GROUP_CHANGED()
			end
		end
		if OptionFrame and OptionFrame:IsShown() then 
			HDH_LoadTabSpec()
		end
		HDH_cashTalentSpell = nil
	elseif event == 'PLAYER_REGEN_ENABLED' then
		if not UI_LOCK then
			for i = 1 , #DB_FRAME_LIST do
				(HDH_TRACKER.Get(DB_FRAME_LIST[i].name)):Update()
			end
		end
	elseif event == 'PLAYER_REGEN_DISABLED' then
		if not UI_LOCK then
			for i = 1 , #DB_FRAME_LIST do
				(HDH_TRACKER.Get(DB_FRAME_LIST[i].name)):Update()
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		PLAY_SOUND = false
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
		C_Timer.After(10, function() PLAY_SOUND = true end)
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
	
HDH_AT_ADDON_Frame = CreateFrame("Frame", nil, UIParent) -- 애드온 최상위 프레임
HDH_AT_ADDON_Frame:SetScript("OnEvent", OnEvent)
OnLoad(HDH_AT_ADDON_Frame)


--------------------------------------------
-- 유틸
--------------------------------------------	

HDH_SpellCache = setmetatable({}, {
	__index=function(t,v) 
		local a = {GetSpellInfo(v)} 
		if GetSpellInfo(v) then t[v] = a end 
		return a 
	end})

function GetCacheSpellInfo(a)
    return unpack(HDH_SpellCache[a])
end	

function HDH_GetInfo(value, isItem)
	if not value then return nil end
	if not isItem and GetCacheSpellInfo(value) then
		local name, rank, icon, castingTime, minRange, maxRange, spellID = GetCacheSpellInfo(value) 
		return name, spellID, icon
	elseif GetItemInfo(value) then
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(value)
		if name then
			-- linkType, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId
			local linkType, itemId = strsplit(":", link)
			return name, itemId, texture, true, maxStack -- 마지막 인자 아이템 이냐?
		end
	end
	return nil
end

function HDH_trim(str)
	if not str then return nil end
	local front, near
	for i =1, str:len() do
		if str:sub(i,i) ~= " " then
			front = i
			break
		end
	end
	for i =str:len(), 1, -1 do
		if str:sub(i,i) ~= " " then
			near = i
			break
		end
	end
	if front and near and front <= near then
		return str:sub(front, near)
	else
		return nil
	end
end


HDH_cashTalentSpell = nil
function HDH_IsTalentSpell(name)
	if cashTalentSpell == nil or #cashTalentSpell == 0 then
		cashTalentSpell= {}
		for tier = 1, MAX_TALENT_TIERS do
			for column = 1, NUM_TALENT_COLUMNS do
				local id, name = GetTalentInfo(tier, column, GetActiveSpecGroup())
				cashTalentSpell[name] = true
			end
		end
	end
	
	return cashTalentSpell[name] or false
end