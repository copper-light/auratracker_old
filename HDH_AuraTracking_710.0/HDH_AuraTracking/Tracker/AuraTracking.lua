HDH_TRACKER = {} -- tracker class
HDH_TRACKER.LOCALE = GetLocale();
HDH_GET_CLASS = {}
HDH_GET_CLASS_NAME = {}
HDH_TRACKER.IsLoaded = false;
HDH_TRACKER.FONT_STYLE = "fonts\\2002.ttf";
HDH_AT_UTIL = {}
HDH_AT_DB_VERSION = 1.12
HDH_TRACKER.MAX_ICONS_COUNT = 10
HDH_TRACKER.ONUPDATE_FRAME_TERM = 0.03;

HDH_TRACKER.BOSS_DEBUFF = {}
HDH_TRACKER.BOSS_DEBUFF[206005] = true;

HDH_TRACKER.BAR_TEXTURE = {{name ="BantoBar", texture = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\BantoBar", texture_r = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\BantoBar_r"},
							{name ="Minimalist", texture = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\Minimalist", texture_r = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\Minimalist"},
							{name ="normTex", texture = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\normTex", texture_r = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\normTex"},
							{name ="Smooth", texture = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\Smooth", texture_r = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\Smooth"},
							{name ="Blizzard", texture = "Interface\\TARGETINGFRAME\\UI-StatusBar", texture_r = "Interface\\TARGETINGFRAME\\UI-StatusBar"},
							-- {name ="Blizzard", texture = "Interface\\Vehicles\\Vehicle_Target_Base_01", texture_r = "Interface\\Vehicles\\Vehicle_Target_Base_01"},
							{name ="None", texture = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg", texture_r = "Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg"}
						};
HDH_TRACKER.ALIGN_LIST = {"left","center","right","TOP","BOTTOM"};

HDH_TRACKER.ANI_HIDE = 1;
HDH_TRACKER.ANI_SHOW = 2;
HDH_TRACKER.COOLDOWN_UP     = 1
HDH_TRACKER.COOLDOWN_DOWN   = 2
HDH_TRACKER.COOLDOWN_LEFT   = 3
HDH_TRACKER.COOLDOWN_RIGHT  = 4
HDH_TRACKER.COOLDOWN_CIRCLE = 5

HDH_TRACKER.FONT_LOCATION_TL = 1
HDH_TRACKER.FONT_LOCATION_BL = 2
HDH_TRACKER.FONT_LOCATION_TR = 3
HDH_TRACKER.FONT_LOCATION_BR = 4
HDH_TRACKER.FONT_LOCATION_C  = 5
HDH_TRACKER.FONT_LOCATION_OT = 6
HDH_TRACKER.FONT_LOCATION_OB = 7
HDH_TRACKER.FONT_LOCATION_OL = 8
HDH_TRACKER.FONT_LOCATION_OR = 9
HDH_TRACKER.FONT_LOCATION_BAR_L = 10
HDH_TRACKER.FONT_LOCATION_BAR_C = 11
HDH_TRACKER.FONT_LOCATION_BAR_R = 12
--HDH_TRACKER.FONT_LOCATION_OT2 = 7
--HDH_TRACKER.FONT_LOCATION_OB2 = 9

HDH_TRACKER.BAR_LOCATION_T = 1
HDH_TRACKER.BAR_LOCATION_B = 2
HDH_TRACKER.BAR_LOCATION_L = 3
HDH_TRACKER.BAR_LOCATION_R = 4

HDH_TRACKER.ORDERBY_LIST 	  = 1 
HDH_TRACKER.ORDERBY_CD_ASC    = 2
HDH_TRACKER.ORDERBY_CD_DESC   = 3
HDH_TRACKER.ORDERBY_CAST_ASC  = 4
HDH_TRACKER.ORDERBY_CAST_DESC = 5

HDH_TRACKER.TIME_TYPE_RAISE = 1;
HDH_TRACKER.TIME_TYPE_DOWN = 2;
HDH_TRACKER.TIME_TYPE_FLOAT = 3;

-- local DDM_BAR_ICON_ORDER_LIST = {"목록 기준","남은시간 빠른순","남은시간 느린순","시전된 시간 빠른순","시전된 시간 느린순"};

local L_BUFF = "버프";
local L_DEBUFF= "디버프";

HDH_GET_CLASS[L_BUFF] = HDH_TRACKER; -- 클래스를 타입명에 맞춰 불러옴, cooldown 처럼 다른 클래스를 가져오기 위한 수단
HDH_GET_CLASS[L_DEBUFF] = HDH_TRACKER;
HDH_GET_CLASS_NAME[L_BUFF] = "HDH_TRACKER";
HDH_GET_CLASS_NAME[L_DEBUFF] = "HDH_TRACKER";

HDH_TRACKER_LIST = {L_BUFF, L_DEBUFF}

HDH_UNIT_LIST = {"player","target","focus","pet","boss1","boss2","boss3","boss4","boss5","party1","party2","party3","party4","arena1","arena2","arena3","arena4","arena5"};
HDH_IS_UNIT = {} -- cooldown 과 같은 다른 플러그인으로 인해 HDH_TRACKER_LIST 의 데이터의 카테고리 일관성이 사라질 때 이를 구분하기 위해서 사용함
HDH_OLD_TRACKER = {} -- 트래커 타입 이름 변경 되었을때 사용하는 변수

HDH_TRACKER.DefaultSetting = { db_ver = HDH_AT_DB_VERSION, 
						 tooltip_id_show = true,
						 icon   = { size = 40, margin_v = 4, margin_h = 4, 
									on_alpha = 1, off_alpha = 0.5,
									buff_color = {0,0,0}, debuff_color = {0,0,0},
									show_cooldown = true,
									cooldown_bg_color = {0,0,0,0.75},
									desaturation = true, always_show = false, able_buff_cancel = false, hide_icon = false, default_color = false
									}, 
						 font   = { fontsize= 15, cd_location = HDH_TRACKER.FONT_LOCATION_TR, textcolor={1,1,0}, textcolor_5s={1,0,0}, time_type = HDH_TRACKER.TIME_TYPE_RAISE, -- 쿨 다운
									countsize = 15, count_location =  HDH_TRACKER.FONT_LOCATION_BL, countcolor={1,1,1}, -- 중첩
									v1_size = 15, v1_location = HDH_TRACKER.FONT_LOCATION_BL, v1_color = {1,1,1}, v1_abbreviate = true, -- 1차
									v2_size = 15, v2_location = HDH_TRACKER.FONT_LOCATION_BL, v2_color = {1,1,1}, -- 2차
									}, -- 폰트 종류 FRIZQT__
						 bar    = { enable = false, reverse_progress = false, color = {0.3,1,0.3}, use_full_color = false, full_color = {0.3,1,0.3}, bg_color = {0,0,0,0.5}, 
									location = HDH_TRACKER.BAR_LOCATION_R, width = 150, height= 40, texture = 2,
									show_name = true, name_align=1, name_size=15, name_margin_left=5, name_margin_right=5, name_color = {1,1,1}, 
									name_color_off = {1,1,1,0.5}, fill_bar = false, show_spark = true}
						};
HDH_TRACKER.DefaultSettingTracker = { db_ver = HDH_AT_DB_VERSION,
							    -- unit = "player",
								list_share = false, share_spec = nil,
								x = UIParent:GetWidth()/2, 
								y = UIParent:GetHeight()/2, 
								revers_h = false, 
								revers_v = false,
								cooldown = HDH_TRACKER.COOLDOWN_UP , -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
								line = 5,
								check_debuff = true,
								check_buff = true,
								check_only_mine = true,
								check_pet = false,
								use_each = false,
								fix = false,
								tracking_all = false,
								tracking_boss_aura = false,
								merge_power_icon = true,
								order_by = HDH_TRACKER.ORDERBY_LIST}


HDH_PARSE_OLD_TRACKER = {} -- 버전 바뀌면서 유닛명 변경 되는경우를 위해 파싱해줌.

do
	for i = 1 , #HDH_UNIT_LIST do
		-- HDH_TRACKER_LIST[i] = HDH_UNIT_LIST[i];
		HDH_IS_UNIT[HDH_UNIT_LIST[i]] = true;
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

local function UpdateCooldown(f, elapsed)
	local spell = f.spell;
	local tracker = f:GetParent().parent;
	if not spell and not tracker then return end
	
	f.elapsed = (f.elapsed or 0) + elapsed;
	if f.elapsed < HDH_TRACKER.ONUPDATE_FRAME_TERM then  return end  -- 30프레임
	f.elapsed = 0
	spell.curTime = GetTime();
	spell.remaining = (spell.endTime or 0) - spell.curTime

	if spell.remaining > 0.0 and spell.duration > 0 then
		tracker:UpdateTimeText(f.timetext, spell.remaining);
		if tracker.option.base.cooldown ~= HDH_TRACKER.COOLDOWN_CIRCLE then
			if f.cd:GetObjectType() == "StatusBar" then f.cd:SetValue(spell.curTime) end
		end
		if tracker.option.bar.enable and f.bar then
			local minV, maxV = f.bar:GetMinMaxValues();
			f.bar:SetValue(tracker.option.bar.fill_bar and (maxV-spell.remaining) or (spell.remaining));
			tracker:moveSpark(tracker,f, spell);
		end
	end
	-- tracker:CheckCondition(f, spell.remaining);
end

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
local function OnUpdateCooldown(self, elapsed)
	UpdateCooldown(self:GetParent():GetParent(), elapsed);
end

-- 아이콘이 보이지 않도록 설정되면, 바에서 업데이트 처리를 한다
function HDH_TRACKER:OnUpdateBarValue(elapsed)
	UpdateCooldown(self:GetParent(), elapsed);
end

-- function HDH_TRACKER:CheckCondition(f, remaining)
	-- self:SetGlow(f, true);
-- end

function HDH_TRACKER:moveSpark(tracker,f, spell)
	if not tracker.option.bar.show_spark then return end
	if tracker.option.bar.fill_bar == tracker.option.bar.reverse_progress then
		if f.bar:GetOrientation() == "HORIZONTAL" then
			f.bar.spark:SetPoint("CENTER", f.bar,"LEFT", f.bar:GetWidth() * (spell.remaining/(spell.endTime-spell.startTime)), 0);
		else
			f.bar.spark:SetPoint("CENTER", f.bar,"BOTTOM", 0, f.bar:GetHeight() * (spell.remaining/(spell.endTime-spell.startTime)));
		end
	else
		if f.bar:GetOrientation() == "HORIZONTAL" then
			f.bar.spark:SetPoint("CENTER", f.bar,"RIGHT", -f.bar:GetWidth() * (spell.remaining/(spell.endTime-spell.startTime)), 0);
		else
			f.bar.spark:SetPoint("CENTER", f.bar,"TOP", 0, -f.bar:GetHeight() * (spell.remaining/(spell.endTime-spell.startTime)));
		end
	end
end

-------------------------------------------
-- timer
-------------------------------------------

local function AT_Timer_Func(self)
	if self and self.arg then
		local tracker = self.arg:GetParent() and self.arg:GetParent().parent or nil;
		if tracker then
			tracker:StartAni(self.arg,1);
		end
	end
end

local function AT_HasTImer(f)
	return f.timer and true or false
end	

local function AT_StopTimer(f)
	if f and f.timer then
		f.timer:Cancel()
		f.timer = nil
	end
end

local function AT_StartTimer(f, runTime)
	if UI_LOCK then return end
	if f then
		if f.timer and f.timer.runTime ~= runTime then
			AT_StopTimer(f);
		end
		if not f.timer then
			f:GetParent().parent:StopAni(f);
			local d = runTime- GetTime();
			if d > 0 then
				f.timer = C_Timer.NewTimer(d, AT_Timer_Func)
				f.timer.arg = f
				f.timer.runTime = runTime;
			end
		end
	end
end

-------------------------------------------
-- sound
-------------------------------------------

function HDH_PlaySoundFile(path, channel)
	if PLAY_SOUND then
		PlaySoundFile(path,channel)
	end
end
	
function HDH_OnShowCooldown(self)
	-- print("HDH_OnShowCooldown")
	local f = self:GetParent():GetParent();
	if f.spell and f.spell.startSound and not OptionFrame:IsShown() then
		-- print("HDH_OnShowCooldown")
		if (f.spell.duration - f.spell.remaining) < 0.5 then
			-- print("HDH_OnShowCooldown")
			HDH_PlaySoundFile(f.spell.startSound,"SFX")
		end
	end
end

function HDH_OnHideCooldown(self)
	local f = self:GetParent():GetParent();
	if f.spell and f.spell.endSound and not OptionFrame:IsShown() then
		HDH_PlaySoundFile(f.spell.endSound, "SFX")
	end
end

-------------------------------------------
-- icon frame struct
-------------------------------------------

local function frameBaseSettings(f)
	f:SetClampedToScreen(true)
	f:SetMouseClickEnabled(false);
	f.iconframe = CreateFrame("Frame", f:GetName().."Top", f);
	f.iconframe:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.iconframe:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.iconframe:Show();
	
	f.icon = f.iconframe:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	-- f.icon:SetTexCoord(0.08, 0.92, 0.92,0.08)
	f.icon:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.icon:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	
	f.cooldown1 = CreateFrame("StatusBar", nil, f.iconframe)
	f.cooldown1:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown1:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.cooldown1:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.cooldown1:Hide();
	f.cooldown1.parent=f;
	f.cd = f.cooldown1
	
	f.cooldown2 = CreateFrame("Cooldown", nil, f.iconframe) -- 원형
	f.cooldown2:SetPoint('TOPLEFT', f.iconframe, 'TOPLEFT', 0, 0)
	f.cooldown2:SetPoint('BOTTOMRIGHT', f.iconframe, 'BOTTOMRIGHT', 0, 0)
	f.cooldown2:SetMovable(true);
	f.cooldown2:SetScript('OnUpdate', OnUpdateCooldown)
	f.cooldown2:SetHideCountdownNumbers(true) 
	f.cooldown2:SetSwipeTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg.blp"); -- Interface\\AddOns\\HDH_AuraTracking\\cooldown_bg.blp
	f.cooldown2:SetDrawSwipe(true) 
	f.cooldown2:SetReverse(true)
	f.cooldown2:Hide();
	
	local tempf = CreateFrame("Frame", nil, f)
	f.counttext = tempf:CreateFontString(nil, 'OVERLAY')
	f.counttext:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.counttext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.counttext:SetNonSpaceWrap(false)
	f.counttext:SetJustifyH('RIGHT')
	f.counttext:SetJustifyV('TOP')
	
	f.timetext = tempf:CreateFontString(nil, 'OVERLAY');
	f.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', -10, -1)
	f.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 0)
	f.timetext:SetJustifyH('CENTER')
	f.timetext:SetJustifyV('CENTER')
	f.timetext:SetNonSpaceWrap(false)
	
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
	
	f.border = CreateFrame("Frame", nil, f.iconframe):CreateTexture(nil, 'OVERLAY')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/Texture/border.blp]])
	f.border:SetVertexColor(0,0,0)
	-- f.border:SetAllPoints(f);
end

--------------------------------------------
-- DB 연산
--------------------------------------------

function HDH_RefreshFrameLevel_All()
	local t
	for i= #DB_FRAME_LIST ,1 ,-1  do
		t = HDH_TRACKER.Get(DB_FRAME_LIST[i].name)
		if t and t.frame then
			t.frame:SetFrameLevel(i*5)
		end
	end
end

function HDH_DB_Add_FRAME_LIST(newName, newType, newUnit)
	DB_FRAME_LIST[#DB_FRAME_LIST+1] = { name = newName, type = newType, unit = newUnit }
end

function HDH_DB_Remove(name)
	local removedIdx = 0
	for i= 1 , #DB_FRAME_LIST do
		if DB_FRAME_LIST[i].name == name then
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

function HDH_DB_Modify(oldName, newName, newType, newUnit)
	for i = 1 , #DB_FRAME_LIST do
		if DB_FRAME_LIST[i].name == oldName then
			DB_FRAME_LIST[i].name = newName
			DB_FRAME_LIST[i].type = newType
			DB_FRAME_LIST[i].unit = newUnit
			break
		end
	end
	
	if DB_OPTION[oldName] then 
		DB_OPTION[oldName].unit = newUnit; 
		DB_OPTION[oldName].type = newType; 
	end;
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

	function HDH_TRACKER.new(name, type, unit)
		local obj = nil;
		if HDH_GET_CLASS[type] then
			obj = {};
			setmetatable(obj, HDH_GET_CLASS[type])
			obj:Init(name, type, unit)
			HDH_TRACKER.AddList(obj)
		end
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
		if not DB_OPTION then
			DB_OPTION = HDH_AT_UTIL.Deepcopy(HDH_TRACKER.DefaultSetting);
		else
			DB_OPTION = HDH_AT_UTIL.CheckToUpdateDB(HDH_TRACKER.DefaultSetting, DB_OPTION);
		end
		
		if not DB_AURA or not GetSpecialization() or not DB_AURA.Talent then
			DB_AURA = {} 
			-- DB_AURA.HDH_AT_DB_VERSION = HDH_AT_DB_VERSION
			-- local class = select(2, UnitClass("player"))
			-- DB_AURA.name = class
			DB_AURA.Talent = {}
			local id, talent
			for i =1, 4 do
				id, talent = GetSpecializationInfo(i)
				if id then
					DB_AURA.Talent[i] = {ID = id, Name = talent} 
				end
			end
		end
		
		-- 무결성 검사
		local cnt =1;
		for i,frame in pairs(DB_FRAME_LIST) do
			-- 1.0 이하버전 파싱 시작
			if not frame.type and frame.unit then
				if HDH_IS_UNIT[frame.unit] then
					if DB_OPTION[frame.name] and DB_OPTION[frame.name].check_buff then
						frame.type = HDH_TRACKER_LIST[1];
					else
						frame.type = HDH_TRACKER_LIST[2];
					end
				else
					frame.type = frame.unit;
					frame.unit = HDH_UNIT_LIST[1];
				end
			end -- 1.0 이하버전 파싱 끝 ---
			if not HDH_GET_CLASS[frame.type] then
				if HDH_OLD_TRACKER[frame.type] then
					frame.type = HDH_OLD_TRACKER[frame.type];
				else
					print(format('|cffff0000[AuraTracking 경고]|cffffff00 - %s(%s)의 추적대상이 %s(으)로 변경되었습니다.',frame.name,frame.type, HDH_TRACKER_LIST[1]));
					frame.type = HDH_TRACKER_LIST[1];
				end
			end
			if not HDH_IS_UNIT[frame.unit] then frame.unit = HDH_UNIT_LIST[1] end -- player;
			if cnt ~= i then
				DB_FRAME_LIST[cnt] = frame;
				DB_FRAME_LIST[i] = nil;
			end
			cnt = cnt + 1;
		end
		
		if DB_OPTION.db_ver < HDH_AT_DB_VERSION then
			-- DB 구 버전 설정 업데이트 --
			if DB_OPTION.icon.max_time and DB_OPTION.icon.max_time == 0 then
				DB_OPTION.icon.max_time = -1;
			end
			DB_OPTION.db_ver = HDH_AT_DB_VERSION;
			for i = 1, #DB_FRAME_LIST do
				local name = DB_FRAME_LIST[i].name;
				if name and DB_OPTION[name] and DB_OPTION[name].icon then
					if DB_OPTION[name].icon.max_time and DB_OPTION[name].icon.max_time == 0 then
						DB_OPTION[name].icon.max_time = -1;
					end
					DB_OPTION[name].db_ver = HDH_AT_DB_VERSION;
				end
			end
			
		end
		
		local tracker
		for i = 1, #DB_FRAME_LIST do
			tracker = HDH_TRACKER.Get(DB_FRAME_LIST[i].name)
			if not tracker then
				HDH_TRACKER.new(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].type, DB_FRAME_LIST[i].unit);
			else
				tracker:Init(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].type, DB_FRAME_LIST[i].unit);
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

	function HDH_TRACKER.IsEqualClass(type, className)
		local ret= false;
		if type and HDH_GET_CLASS_NAME[type] == className then ret = true; end
		return ret;
	end
	
------------------------------------------
end -- TRACKER Static function 
------------------------------------------

------------------------------------------
do -- TRACKER Class
--------------------------------------------
	function HDH_TRACKER:InitVariblesOption()
		if not DB_OPTION[self.name] then
			DB_OPTION[self.name] = HDH_AT_UTIL.Deepcopy(HDH_TRACKER.DefaultSettingTracker);
			-- DB_OPTION[self.name].unit = self.unit;
		else
			DB_OPTION[self.name] = HDH_AT_UTIL.CheckToUpdateDB(HDH_TRACKER.DefaultSettingTracker, DB_OPTION[self.name]);
		end
		self.option = {}
		self.option.base = DB_OPTION[self.name]
		if DB_OPTION[self.name].use_each then
			DB_OPTION[self.name].icon = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.icon, DB_OPTION[self.name].icon);
			DB_OPTION[self.name].font = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.font, DB_OPTION[self.name].font);
			DB_OPTION[self.name].bar = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.bar, DB_OPTION[self.name].bar);
			-- DB_OPTION[self.name] = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION, DB_OPTION[self.name]);
			self.option.icon = DB_OPTION[self.name].icon
			self.option.font = DB_OPTION[self.name].font
			self.option.bar = DB_OPTION[self.name].bar;
		else
			self.option.icon = DB_OPTION.icon
			self.option.font = DB_OPTION.font
			self.option.bar = DB_OPTION.bar
		end
		-- if self.option.base.boss_debuff == nil then
			-- self.option.base.boss_debuff = false;
		-- end
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

	function HDH_TRACKER:Init(name, type, unit)
		self.unit = unit
		self.name = name
		self.type = type
		if self.frame == nil then
			self.frame = CreateFrame("Frame", HDH_AT_ADDON_Frame:GetName()..name, HDH_AT_ADDON_Frame)
			self.frame:SetFrameStrata('MEDIUM')
			self.frame:SetClampedToScreen(true)
			self.frame.parent = self
			self.frame.icon = {}
			self.frame.pointer = {}
			
			setmetatable(self.frame.icon, {
				__index = function(t,k) 
					local f = CreateFrame('Button', self.frame:GetName()..k, self.frame)
					t[k] = f
					frameBaseSettings(f)
					self:UpdateIconSettings(f)
					return f
				end})
		end
		self.frame:Hide();
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
		if self.timer then
			for k,timer in ipairs(self.timer) do
				timer:Cancel();
				self.timer[k] = nil;
			end
		end
		self.timer = nil
	end

	function HDH_TRACKER:Modify(newName, newType, newUnit)
		HDH_DB_Modify(self.name, newName, newType, newUnit)
		HDH_TRACKER.ModifyList(self.name, newName)
		
		if newType ~= self.type then
			self:Release() -- 프레임 관련 메모리 삭제하고
			setmetatable(self, HDH_GET_CLASS[newType]) -- 클래스 변경하고
			self:Init(newName, newType, newUnit) -- 프레임 초기화 + DB 로드
			self:ModifyDB();
		else
			self.name = newName
			self.type = newType
			self.unit = newUnit
		end
		if UI_LOCK then
			self:SetMove(false)
			self:SetMove(true)
		end
	end
	
	function HDH_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local cnt;
			if self.option.base.tracking_all or self.option.base.tracking_boss_aura then
				cnt = HDH_TRACKER.MAX_ICONS_COUNT;
			else
				cnt = DB_AURA.Talent[spec][self.name] and #(DB_AURA.Talent[spec][self.name]) or 0;
			end
			return (cnt > 0) and cnt or false;
		end
		return false;
	end
	
	function HDH_TRACKER:ModifyDB() -- 다른 클래스에서 DB 업데이트할 수 있도록 인터페이스 준비.
		-- interface
	end
	
	local function ChangeFontLocation(f, fontf, location, op_font)
		local location_list = {op_font.count_location, op_font.cd_location, op_font.v2_location, op_font.v1_location}
		local size_list = {op_font.countsize, op_font.fontsize , op_font.v2_size, op_font.v2_size}
		local margin = 0
		parent = f.iconframe;
		fontf:ClearAllPoints();
		fontf:Show();
		if location == HDH_TRACKER.FONT_LOCATION_TL then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, -2)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 200, -30)
			fontf:SetJustifyH('LEFT')
			fontf:SetJustifyV('TOP')
		elseif location == HDH_TRACKER.FONT_LOCATION_BL then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', 1, 30)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 200, 1)
			fontf:SetJustifyV('BOTTOM')
			fontf:SetJustifyH('LEFT')
		elseif location == HDH_TRACKER.FONT_LOCATION_TR then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -200, -2)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -0, -30)
			fontf:SetJustifyV('TOP')
			fontf:SetJustifyH('RIGHT')
		elseif location == HDH_TRACKER.FONT_LOCATION_BR then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -200, 30)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -0, 1)
			fontf:SetJustifyV('BOTTOM')
			fontf:SetJustifyH('RIGHT')
		elseif location == HDH_TRACKER.FONT_LOCATION_C then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -100, 15)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 100, -15)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('CENTER')
		elseif location == HDH_TRACKER.FONT_LOCATION_OB then
			fontf:SetPoint('TOPLEFT', parent, 'BOTTOMLEFT', -100, -1)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 100, -40)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('TOP')
		elseif location == HDH_TRACKER.FONT_LOCATION_OT then
			fontf:SetPoint('TOPLEFT', parent, 'TOPLEFT', -100, 40)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT', 100, 0)
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('BOTTOM')
		elseif location == HDH_TRACKER.FONT_LOCATION_OL then
			fontf:SetPoint('TOPRIGHT', parent, 'TOPLEFT', -1, 0)
			fontf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMLEFT', -1, 0)
			fontf:SetWidth(parent:GetWidth()+200);
			fontf:SetJustifyH('RIGHT')
			fontf:SetJustifyV('CENTER')
		elseif location == HDH_TRACKER.FONT_LOCATION_OR then
			fontf:SetPoint('TOPLEFT', parent, 'TOPRIGHT', 1, 0)
			fontf:SetPoint('BOTTOMLEFT', parent, 'BOTTOMRIGHT', 1, 0)
			fontf:SetWidth(parent:GetWidth()+200);
			fontf:SetJustifyH('LEFT')
			fontf:SetJustifyV('RIGHT')
		elseif location == HDH_TRACKER.FONT_LOCATION_BAR_L then
			fontf:SetPoint('LEFT', f.bar or parent, 'LEFT', 2, 0)
			fontf:SetWidth(parent:GetWidth()+200);
			fontf:SetJustifyH('LEFT')
			fontf:SetJustifyV('CENTER')
		elseif location == HDH_TRACKER.FONT_LOCATION_BAR_C then
			fontf:SetPoint('CENTER', f.bar or parent, 'CENTER', 0, 0)
			fontf:SetWidth(parent:GetWidth()+200);
			fontf:SetJustifyH('CENTER')
			fontf:SetJustifyV('CENTER')
		elseif location == HDH_TRACKER.FONT_LOCATION_BAR_R then
			fontf:SetPoint('RIGHT', f.bar or parent, 'RIGHT', -2, 0)
			fontf:SetWidth(parent:GetWidth()+200);
			fontf:SetJustifyH('RIGHT')
			fontf:SetJustifyV('CENTER')
		end
	end

	-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
	function HDH_TRACKER:UpdateIconSettings(f)
		local op_icon, op_font, op_bar
		if DB_OPTION[self.name] and DB_OPTION[self.name].use_each then
			op_icon = DB_OPTION[self.name].icon
			op_font = DB_OPTION[self.name].font
			op_bar = DB_OPTION[self.name].bar
			self.option.icon = DB_OPTION[self.name].icon;
			self.option.font = DB_OPTION[self.name].font;
			self.option.bar = DB_OPTION[self.name].bar;
			-- self.option.base = DB_OPTION[self.name];
		else
			op_icon = DB_OPTION.icon
			op_font = DB_OPTION.font
			op_bar = DB_OPTION.bar
			self.option.bar = DB_OPTION.bar;
			self.option.icon = DB_OPTION.icon;
			self.option.font = DB_OPTION.font;
			-- self.option.base = DB_OPTION;
		end
		
		f:SetSize(op_icon.size,op_icon.size)
		f.iconframe:SetSize(op_icon.size,op_icon.size);
		self:SetGameTooltip(f, DB_OPTION[self.name].show_spell_tooltip or false)
		local icon = f.icon
		f.border:SetWidth(op_icon.size*1.3)
		f.border:SetHeight(op_icon.size*1.3)
		f.border:SetPoint('CENTER', f.iconframe, 'CENTER', 0, 0)
		f.cooldown1:SetStatusBarTexture(unpack(op_icon.cooldown_bg_color))
		
		--f.cooldown2:SetDrawEdge(false);
		--f.cooldown2.textureImg:SetTexture(unpack(op_icon.cooldown_bg_color));
		
		--f.cooldown2:SetSwipeTexture(f.cooldown2.textureImg:GetTexture(),1,1,1);
		--local tmp = f:CreateTexture(nil,"OVERLAY")
		--tmp:SetTexture();
		
		f.cooldown2:SetSwipeColor(unpack(op_icon.cooldown_bg_color));
		--f.overlay.animIn:Play()
		if 4 > op_icon.size*0.08 then
			op_icon.margin = 4
		else
			op_icon.margin = op_icon.size*0.08
		end
		self:UpdateArtBar(f);
		local counttext = f.counttext
		counttext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.countsize, "OUTLINE")
		--counttext:SetTextHeight(op_font.countsize)
		counttext:SetTextColor(unpack(op_font.countcolor))
		ChangeFontLocation(f, counttext, op_font.count_location, op_font)
		
		local v1Text = f.v1
		v1Text:SetFont(HDH_TRACKER.FONT_STYLE, op_font.v1_size, "OUTLINE")
		v1Text:SetTextColor(unpack(op_font.v1_color))
		ChangeFontLocation(f, v1Text, op_font.v1_location, op_font)
		
		local v2Text = f.v2
		v2Text:SetFont(HDH_TRACKER.FONT_STYLE, op_font.v2_size, "OUTLINE")
		v2Text:SetTextColor(unpack(op_font.v2_color))
		ChangeFontLocation(f, v2Text, op_font.v2_location, op_font)
		
		local timetext = f.timetext
		timetext:SetFont(HDH_TRACKER.FONT_STYLE, op_font.fontsize, "OUTLINE")
		timetext:SetTextColor(unpack(op_font.textcolor))
		ChangeFontLocation(f, timetext, op_font.cd_location, op_font)
		
		if op_icon.show_cooldown then f.timetext:Show()
								 else f.timetext:Hide() end
		
		self:ChangeCooldownType(f, DB_OPTION[self.name].cooldown)
		
		if HDH_TRACKER.IsEqualClass(self.type, "HDH_TRACKER") and self.option.icon.able_buff_cancel then
			f:SetMouseClickEnabled(true);
			f:RegisterForClicks("RightButtonUp");
			-- f:SetScript("OnClick",nil);
			f:SetScript("OnClick", function(self) 
				local tracker = self:GetParent().parent;
				if tracker and tracker.unit and tracker.filter and self.spell.index then
					CancelUnitBuff(tracker.unit, self.spell.index, tracker.filter); 
				end
			end);
		else
			f:SetMouseClickEnabled(false);
			f:SetScript("OnClick",nil);
		end
	end
	
	function HDH_TRACKER:UpdateArtBar(f)
		local op = self.option.bar;
		local hide_icon = self.option.icon.hide_icon;
		if op.enable then
			if (f.bar and f.bar:GetObjectType() ~= "StatusBar") then
				f.bar:Hide();
				f.bar:SetParent(nil);
				f.bar = nil;
			end
			if not f.bar then
				f.bar = CreateFrame("StatusBar", nil, f);
				local t= f.bar:CreateTexture(nil,"BACKGROUND");
				t:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg.blp");
				t:SetPoint('TOPLEFT', f.bar, 'TOPLEFT', -1, 1)
				t:SetPoint('BOTTOMRIGHT', f.bar, 'BOTTOMRIGHT', 1, -1)
				f.bar.bg = t;
				f.bar.spark = f.bar:CreateTexture(nil, "OVERLAY");
				f.bar.spark:SetBlendMode("ADD");
				f.name = f.bar:CreateFontString(nil,"OVERLAY");
			end
			f.bar.bg:SetVertexColor(unpack(op.bg_color));
			if op.show_name then
				f.name:Show();
			else
				f.name:Hide();
			end
			if op.name_align <= 3 then
				f.name:SetJustifyH(HDH_TRACKER.ALIGN_LIST[op.name_align]);
				f.name:SetJustifyV("CENTER");
			else
				f.name:SetJustifyV(HDH_TRACKER.ALIGN_LIST[op.name_align]);
				f.name:SetJustifyH("CENTER");
			end
			f.name:SetFont(HDH_TRACKER.FONT_STYLE, op.name_size, "OUTLINE");
			f.name:SetTextColor(unpack(op.name_color));
			f.name:SetPoint('TOPLEFT', f.bar, 'TOPLEFT', op.name_margin_left, -3)
			f.name:SetPoint('BOTTOMRIGHT', f.bar, 'BOTTOMRIGHT', -op.name_margin_right, 3)

			-- 아이콘 숨기기는 바와 연관되어 있기 때문에 바 설정쪽에 위치함.
			if hide_icon then
				f.iconframe:Hide();
				-- f.border:Hide();
				f.bar:SetScript("OnUpdate",self.OnUpdateBarValue);
			else
				f.iconframe:Show();
				-- f.border:Show();
				f.bar:SetScript("OnUpdate",nil);
			end
			
			if op.reverse_progress then f.bar:SetStatusBarTexture(HDH_TRACKER.BAR_TEXTURE[op.texture].texture_r); 
			else f.bar:SetStatusBarTexture(HDH_TRACKER.BAR_TEXTURE[op.texture].texture); end
			f.bar:ClearAllPoints();
			if op.location == HDH_TRACKER.BAR_LOCATION_T then     
				f.bar:SetSize(op.height,op.width);
				f.bar:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP",0,1); 
				f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark_v");
				f.bar.spark:SetSize(op.height*1.3, 19);
			elseif op.location == HDH_TRACKER.BAR_LOCATION_B then 
				f.bar:SetSize(op.height,op.width);
				f.bar:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM",0,-1); 
				f.bar:SetOrientation("Vertical"); f.bar:SetRotatesTexture(true);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark_v");
				f.bar.spark:SetSize(op.height*1.3, 19);
			elseif op.location == HDH_TRACKER.BAR_LOCATION_L then 
				f.bar:SetSize(op.width,op.height);
				f.bar:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT",-1,0); 
				f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark");
				f.bar.spark:SetSize(19, op.height*1.3);
			else 
				f.bar:SetSize(op.width,op.height);
				f.bar:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT",1,0); 
				f.bar:SetOrientation("Horizontal"); f.bar:SetRotatesTexture(false);
				f.bar.spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark");
				f.bar.spark:SetSize(19, op.height*1.3);
			end
			f.bar:SetStatusBarColor(unpack(op.color));
			-- f.bar:SetAlpha(0.5);
			f.bar:SetReverseFill(op.reverse_progress);
			-- f.bar:Show();
			
			f.bar.spark:Hide();
			-- f.bar.spark:SetPoint("CENTER",f.bar,"RIGHT",0,0);
			self:SetGameTooltip(f.bar, DB_OPTION[self.name].show_spell_tooltip or false);
			f.bar:SetMouseClickEnabled(false);
		else
			if f.bar then f.bar:Hide(); f.bar:SetScript("OnUpdate",nil); end
			if hide_icon then
				f.iconframe:Show();
			end
		end
	end
	
	function HDH_TRACKER:SetGameTooltip(f, show)
		f:EnableMouse(show)
		if show then
			f:SetScript("OnEnter",function(frame) 
				local spell = f.spell or (f:GetParent() and f:GetParent().spell)
				if not UI_LOCK and spell and spell.id then
					local isItem = spell.isItem
					local id = spell.id
					local link = isItem and select(2,GetItemInfo(id)) or GetSpellLink(id)
					if not link then return end
					GameTooltip:SetOwner(f, "ANCHOR_BOTTOMRIGHT");
					if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") and spell.index then
						GameTooltip:SetUnitAura(self.unit, spell.index, self.filter);
					else	
						GameTooltip:SetHyperlink(link)
						--GameTooltip:Show()
					end
				end
			end)
			f:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
		else
			f:SetScript("OnEnter", nil)
			f:SetScript("OnLeave", nil)
		end
	end
	
	function HDH_TRACKER:CreateData(spec)
		-- interface
	end
	
	function HDH_TRACKER:ReleaseIcons()
		if not self.frame.icon then return end
		for i=#self.frame.icon, 1, -1 do
			self:ReleaseIcon(i)
		end
	end
	
	local function OnMouseDown(self)
		local curT = HDH_TRACKER.Get(self:GetParent().name)
		if not curT then curT = HDH_TRACKER.Get(self:GetParent():GetParent().name) end
		for k,v in pairs(HDH_TRACKER.GetList()) do
			if v.frame.text then
				if v.frame ~= curT.frame then
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
	
	local function OnDragUpdate(self)
		local t = HDH_TRACKER.Get(self:GetParent().name)
		if not t then t = HDH_TRACKER.Get(self:GetParent():GetParent().name) end
		t.frame.text:SetText(("%s"):format(t.frame.text.text))
		-- t.frame.text:SetText(("%s\n|cffffffff(%d, %d)"):format(t.frame.text.text, t.frame:GetLeft(),t.frame:GetBottom()))
	end
	
	-- 프레임 이동 시킬때 드래그 시작 콜백 함수
	local function OnDragStart(self)
		local t = HDH_TRACKER.Get(self:GetParent().name)
		if not t then t = HDH_TRACKER.Get(self:GetParent():GetParent().name) end
		t.frame:StartMoving()
	end
	
	-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
	local function OnDragStop(self)
		local t = HDH_TRACKER.Get(self:GetParent().name)
		if not t then t = HDH_TRACKER.Get(self:GetParent():GetParent().name) end
		t.frame:StopMovingOrSizing()
		if t then
			t.option.base.x = t.frame:GetLeft()
			t.option.base.y = t.frame:GetBottom()
			t.frame:ClearAllPoints()
			t.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT" , t.option.base.x , t.option.base.y)
		end
		OnMouseUp(self)
	end
	
	function HDH_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local prevf, f, spell
		if icons then
			if #icons > count then count = #icons end
		end
		count = count or 1;
		for i=1, count do
			f = icons[i]
			f:SetMouseClickEnabled(false);
			if not f:GetParent() then f:SetParent(self.frame) end
			if f.icon:GetTexture() == nil then
				f.icon:SetTexture("Interface\\ICONS\\TEMP")
			end
			f:ClearAllPoints()
			prevf = f
			spell = f.spell
			if not spell then spell = {} f.spell = spell end
			spell.always = true
			spell.id = 0
			spell.count = 1+i
			spell.duration = 50*i
			spell.happenTime = 0;
			spell.glow = false
			spell.endTime = curTime + spell.duration
			spell.startTime = spell.endTime - spell.duration
			spell.remaining = spell.startTime+spell.duration
			if spell.showValue then
				if spell.showV1 then
					spell.v1 = 1000
				end
			end
			if self.type == L_BUFF then spell.isBuff = true
									  else spell.isBuff = false end
			if option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE then
				f.cd:SetCooldown(spell.startTime,spell.duration)
			else
				f.cd:SetMinMaxValues(spell.startTime, spell.remaining)
				f.cd:SetValue(spell.startTime+spell.duration);
			end
			if self.option.bar.enable and f.bar then
				f:SetScript("OnUpdate",nil);
				-- f.bar:SetMinMaxValues(spell.startTime, spell.endTime);
				-- f.bar:SetValue(spell.startTime+spell.duration);
				self:UpdateBarValue(f);
				f.bar:Show();
				spell.name = spell.name or ("NAME"..i);
			end
			f.counttext:SetText(i)
			f.icon:SetAlpha(option.icon.on_alpha)
			f.border:SetAlpha(option.icon.on_alpha)
			self:SetGameTooltip(f, false)
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
		return count;
	end
	
	function HDH_TRACKER:ReleaseIcon(idx)
		-- self:StopAni(self.frame.icon[idx]);
		-- AT_StopTimer(self.frame.icon[idx]);
		self.frame.icon[idx]:SetScript('OnDragStart', nil)
		self.frame.icon[idx]:SetScript('OnDragStop', nil)
		self.frame.icon[idx]:SetScript('OnMouseDown', nil)
		self.frame.icon[idx]:SetScript('OnMouseUp', nil)
		self.frame.icon[idx]:SetScript('OnUpdate', nil)
		self.frame.icon[idx]:RegisterForDrag(nil)
		self.frame.icon[idx]:EnableMouse(false);
		if self.frame.icon[idx].bar then 
			self.frame.icon[idx].bar:Hide();
			self.frame.icon[idx].bar:SetParent(nil)
			self.frame.icon[idx].bar = nil;
		end
		self.frame.icon[idx]:Hide()
		self.frame.icon[idx]:SetParent(nil)
		self.frame.icon[idx].spell = nil
		self.frame.icon[idx] = nil
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

	function HDH_TRACKER:ConnectMoveHandler(count)
		if not count then return end
		for i=1, count do
			f = self.frame.icon[i]
			f:SetScript('OnDragStart', OnDragStart)
			f:SetScript('OnDragStop', OnDragStop)
			f:SetScript('OnMouseDown', OnMouseDown)
			f:SetScript('OnMouseUp', OnMouseUp)
			f:SetScript('OnUpdate', OnDragUpdate)
			f:RegisterForDrag('LeftButton')
			f:EnableMouse(true);
			f:SetMovable(true);
			if f.bar then
				f = f.bar;
				f:SetScript('OnDragStart', OnDragStart)
				f:SetScript('OnDragStop', OnDragStop)
				f:SetScript('OnMouseDown', OnMouseDown)
				f:SetScript('OnMouseUp', OnMouseUp)
				f:SetScript('OnUpdate', OnDragUpdate)
				f:RegisterForDrag('LeftButton')
				f:EnableMouse(true);
				f:SetMovable(true);
			end
		end
	end
	
	function HDH_TRACKER:SetMove(move)
		if not self.frame then return end
		if move then
			local cnt = self:IsHaveData(self:GetSpec());
			if cnt then
				if not self.frame.text then
					local tf = CreateFrame("Frame",nil, self.frame)
					tf:SetFrameStrata("HIGH")
					--tf.SetAllPoints(frame)
					local text = tf:CreateFontString(nil, 'OVERLAY')
					self.frame.text = text
					text:ClearAllPoints()
					text:SetFont(HDH_TRACKER.FONT_STYLE, 13, "OUTLINE")
					text:SetTextColor(1,0,0)
					text:SetWidth(190)
					text:SetHeight(70)
					--text:SetAlpha(0.7)
					
					text:SetJustifyH("LEFT")
					text.text = ("|cffffff00["..self.name.."]")
					text:SetMaxLines(6) 
				end
				self.frame.text:ClearAllPoints();
				if self.option.base.revers_v then
					self.frame.text:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 0, 20)
				else
					self.frame.text:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, -20)
				end
				self.frame.name = self.name
				self.frame.text:Show()
				self.frame:EnableMouse(true)
				self.frame:SetMovable(true)
				cnt = self:CreateDummySpell(cnt);
				self:ConnectMoveHandler(cnt);
				self:ShowTracker();
				self:UpdateIcons()
			end
		else
			self.frame:Hide();
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
		if cooldown_type == HDH_TRACKER.COOLDOWN_UP then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_DOWN  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Vertical")
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_LEFT  then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(true)
			f.cooldown2:Hide()
		elseif cooldown_type == HDH_TRACKER.COOLDOWN_RIGHT then 
			f.cd = f.cooldown1
			f.cd:SetOrientation("Horizontal"); 
			f.cd:SetReverseFill(false)
			f.cooldown2:Hide()
		else 
			f.cd = f.cooldown2
			f.cooldown1:Hide()
		end
	end
	
	local function ValueFormat(value, v_type)
		if not value then return "" end
		if value < 1000 then
			value = string.format("%d%s", value, (v_type and "%" or ""))
		elseif value < 1000000 then
			value = value/1000
			value = string.format("%dk%s", value, (v_type and "%" or ""))
		else
			value = value/1000000
			value = string.format("%dm%s", value, (v_type and "%" or ""))
		end
		return value	
	end
	
	function HDH_TRACKER:UpdateTimeText(text, value)
		if self.option.font.time_type == HDH_TRACKER.TIME_TYPE_RAISE then value = value + 1; end
		if value > 5 then text:SetTextColor(unpack(self.option.font.textcolor)) 
				     else text:SetTextColor(unpack(self.option.font.textcolor_5s)) end
		if value <= 9.9 and self.option.font.time_type == HDH_TRACKER.TIME_TYPE_FLOAT then 
			text:SetText(('%.1f'):format(value))
		elseif value < 60 then text:SetText(('%d'):format(value))
		else text:SetText(('%d:%02d'):format((value)/60, (value)%60)) end
	end
	
	function HDH_TRACKER:UpdateBarValue(f, isEnding)
		if f.bar and f.name then
			if self.option.bar.fill_bar then
				if isEnding then
					f.bar:SetMinMaxValues(0,1); 
					f.bar:SetValue(1); 
					f.name:SetTextColor(unpack(self.option.bar.name_color_off));
					if not f.spell.is_buff and self.option.icon.default_color and HDH_IS_UNIT[self.unit] then
						f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
												DebuffTypeColor[f.spell.dispelType or ""].g,
												DebuffTypeColor[f.spell.dispelType or ""].b)
					elseif self.option.bar.use_full_color then
						f.bar:SetStatusBarColor(unpack(self.option.bar.full_color));
					end
					f.bar.spark:Hide();
				else
					if not f.spell.is_buff and self.option.icon.default_color and HDH_IS_UNIT[self.unit] then
						f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
												DebuffTypeColor[f.spell.dispelType or ""].g,
												DebuffTypeColor[f.spell.dispelType or ""].b)
					else
						f.bar:SetStatusBarColor(unpack(self.option.bar.color));
					end
					local maxV = f.spell.endTime - f.spell.startTime;
					f.bar:SetMinMaxValues(0, maxV); 
					f.bar:SetValue(maxV-f.spell.remaining); 
					f.name:SetTextColor(unpack(self.option.bar.name_color));
					if self.option.bar.show_spark and f.spell.duration > 0 then f.bar.spark:Show(); 
					else f.bar.spark:Hide(); end
				end
			else
				if isEnding then
					f.bar:SetMinMaxValues(0,1); 
					f.bar:SetValue(0); 
					f.name:SetTextColor(unpack(self.option.bar.name_color_off));
					if not f.spell.is_buff and self.option.icon.default_color and HDH_IS_UNIT[self.unit] then
						f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
												DebuffTypeColor[f.spell.dispelType or ""].g,
												DebuffTypeColor[f.spell.dispelType or ""].b)
					else
						f.bar:SetStatusBarColor(unpack(self.option.bar.full_color));
					end
					f.bar.spark:Hide();
				else
					local maxV = f.spell.endTime - f.spell.startTime;
					f.bar:SetMinMaxValues(0, maxV); 
					-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime); 
					f.bar:SetValue(f.spell.remaining); 
					if not f.spell.is_buff and self.option.icon.default_color and HDH_IS_UNIT[self.unit] then
						f.bar:SetStatusBarColor(DebuffTypeColor[f.spell.dispelType or ""].r,
												DebuffTypeColor[f.spell.dispelType or ""].g,
												DebuffTypeColor[f.spell.dispelType or ""].b)
					else
						f.bar:SetStatusBarColor(unpack(self.option.bar.color));
					end
					f.name:SetTextColor(unpack(self.option.bar.name_color));
					if self.option.bar.show_spark and f.spell.duration > 0 then f.bar.spark:Show(); 
					else f.bar.spark:Hide(); end
				end
			end
		end
	end
	
	function HDH_TRACKER:IsSwitchByRemining(icon1, icon2) 
		if not icon1.spell and not icon2.spell then return end
		local s1 = icon1.spell
		local s2 = icon2.spell
		local ret = false;
		if (not s1.isUpdate and s2.isUpdate) then
			ret = true;
		elseif (s1.isUpdate and s2.isUpdate and s1.duration > 0) then
			if (s1.remaining < s2.remaining) or (s2.duration == 0) then
				ret = true;
			end
		elseif (not s1.isUpdate and not s2.isUpdate) and (s1.no <s2.no) then
			ret = true;
		end
		return ret;
	end
	
	function HDH_TRACKER:InAsendingOrderByTime()
		local tmp
		local cnt = #self.frame.icon;
		-- local order
		for i = 1, cnt-1 do
			for j = i+1 , cnt do
				if self:IsSwitchByRemining(self.frame.icon[j], self.frame.icon[i]) then
					tmp = self.frame.icon[i];
					self.frame.icon[i] = self.frame.icon[j];
					self.frame.icon[j] = tmp;
				end
			end
		end
	end
	
	function HDH_TRACKER:InDesendingOrderByTime()
		local tmp
		local cnt = #self.frame.icon;
		-- local order
		for i = 1, cnt-1 do
			for j = i+1 , cnt do
				if self:IsSwitchByRemining(self.frame.icon[i], self.frame.icon[j]) then
					tmp = self.frame.icon[i];
					self.frame.icon[i] = self.frame.icon[j];
					self.frame.icon[j] = tmp;
				end
			end
		end
	end
	
	function HDH_TRACKER:IsSwitchByHappenTime(icon1, icon2) 
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
	
	function HDH_TRACKER:InAsendingOrderByCast()
		local tmp
		local cnt = #self.frame.icon;
		-- local order
		for i = 1, cnt-1 do
			for j = i+1 , cnt do
				if self:IsSwitchByHappenTime(self.frame.icon[i], self.frame.icon[j]) then
					tmp = self.frame.icon[i];
					self.frame.icon[i] = self.frame.icon[j];
					self.frame.icon[j] = tmp;
				end
			end
		end
	end
	
	function HDH_TRACKER:InDesendingOrderByCast()
		local tmp
		local cnt = #self.frame.icon;
		-- local order
		for i = 1, cnt-1 do
			for j = i+1 , cnt do
				if self:IsSwitchByHappenTime(self.frame.icon[j], self.frame.icon[i]) then
					tmp = self.frame.icon[i];
					self.frame.icon[i] = self.frame.icon[j];
					self.frame.icon[j] = tmp;
				end
			end
		end
	end
	
	function HDH_TRACKER:GetSpec()
		if self.option.base.list_share then
			return self.option.base.share_spec
		else
			return GetSpecialization()
		end
	end
	
	function HDH_TRACKER:LoadOrderFunc()
		if self.option.base.order_by == HDH_TRACKER.ORDERBY_LIST then
			self.OrderFunc = nil;
		elseif self.option.base.order_by == HDH_TRACKER.ORDERBY_CD_ASC then
			self.OrderFunc = self.InAsendingOrderByTime
		elseif self.option.base.order_by == HDH_TRACKER.ORDERBY_CD_DESC then
			self.OrderFunc = self.InDesendingOrderByTime
		elseif self.option.base.order_by == HDH_TRACKER.ORDERBY_CAST_ASC then
			self.OrderFunc = self.InAsendingOrderByCast;
		elseif self.option.base.order_by == HDH_TRACKER.ORDERBY_CAST_DESC then
			self.OrderFunc = self.InDesendingOrderByCast;
		end
	end
	
	function HDH_TRACKER:MatchBossUnit(target_unit)
		local ret = false;
		if self.boss_guid and target_unit then
			for i = 1, MAX_BOSS_FRAMES do
			local boss_unit = "boss"..i;
				if ExstisUnit(boss_unit) then
					local boss_guid = UnitGUID(boss_unit);
					if Uboss_guid and boss_guid == UnitGUID(target_unit) then
						return true;
					end
				end
			end
		end
		return ret;
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
		if self.OrderFunc then self:OrderFunc(self) end 
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate then
				f.spell.isUpdate = false
				
				if self.option.base.check_only_mine then
					if f.spell.count < 2 then f.counttext:SetText(nil)
										 else f.counttext:SetText(f.spell.count) end
				else
					if f.spell.count < 2 then if f.spell.overlay <= 1 then f.counttext:SetText(nil)
																      else f.counttext:SetText(f.spell.overlay) end
										 else f.counttext:SetText(f.spell.count)  end
				end
				
				if not f.spell.showValue then f.v1:SetText(nil) 
										 else f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, true)) end
				if f.spell.duration == 0 then 
					f.cd:Hide() f.timetext:SetText("");
				else 
					f.cd:Show()
					self:UpdateTimeText(f.timetext, f.spell.remaining);
				end
				f.icon:SetDesaturated(nil)
			    f.icon:SetAlpha(self.option.icon.on_alpha)
			    f.border:SetAlpha(self.option.icon.on_alpha)
				if f.spell.is_buff then f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
						  else if self.option.icon.default_color then f.border:SetVertexColor(DebuffTypeColor[f.spell.dispelType or ""].r,
																							 DebuffTypeColor[f.spell.dispelType or ""].g,
																							 DebuffTypeColor[f.spell.dispelType or ""].b)
								                                else f.border:SetVertexColor(unpack(self.option.icon.debuff_color)) end end
				if self.option.base.cooldown == HDH_TRACKER.COOLDOWN_CIRCLE then
					if HDH_TRACKER.startTime < f.spell.startTime or (f.spell.duration == 0) then
						f.cd:SetCooldown(f.spell.startTime, f.spell.duration)
					else
						f.cd:SetCooldown(HDH_TRACKER.startTime, f.spell.duration - (f.spell.startTime - HDH_TRACKER.startTime));
					end
				else
					f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
					f.cd:SetValue(GetTime());
				end
				if self.option.bar.enable and f.bar then
					-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
					if not f.bar:IsShown() then f.bar:Show(); end
					f.name:SetText(f.spell.name);
					-- f.name:SetTextColor(unpack(self.option.bar.name_color));
					if f.spell.duration == 0 then
						-- f.bar:SetMinMaxValues(0,1);
						-- f.bar:SetValue(1);
						f.spell.remaining = 1;
						f.spell.endTime = 1;
						f.spell.startTime = 0;
					else
						-- f.bar:SetMinMaxValues(f.spell.startTime, f.spell.endTime);
						-- f.bar:SetValue(f.spell.startTime+ f.spell.remaining);
						-- self:UpdateBarValue(f);
					end
					
						self:UpdateBarValue(f);
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then row = row + size + margin_v; col = 0
								 else col = col + size + margin_h end
				ret = ret + 1
				f:Show()
				self:SetGlow(f, true)
			else
				f.timetext:SetText(nil);
				if f.spell.always then 
					if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1)
													   f.icon:SetAlpha(self.option.icon.off_alpha)
													   f.border:SetAlpha(self.option.icon.off_alpha)
													   f.border:SetVertexColor(0,0,0) end
					f.v1:SetText(nil)
					f.counttext:SetText(nil)
					f.cd:Hide() 
					if self.option.bar.enable and f.bar then 
						if not f.bar:IsShown() then f.bar:Show(); end
						-- f.bar:SetMinMaxValues(0,1); 
						-- f.bar:SetValue(0); 
						f.name:SetText(f.spell.name);
						-- f.name:SetTextColor(1,1,1,0.35);
						self:UpdateBarValue(f, true);
					end--f.bar:Hide();
					f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
					i = i + 1
					if i % line == 0 then row = row + size + margin_v; col = 0
								     else col = col + size + margin_h end
					f:Show()
					self:SetGlow(f, false)
				else
					if self.option.base.fix then
						i = i + 1
						if i % line == 0 then row = row + size + margin_v; col = 0
										 else col = col + size + margin_h end
					end
					f:Hide()
				end
				f.spell.endTime = nil;
				f.spell.duration = 0;
				f.spell.duration = 0;
				f.spell.remaining = 0;
				f.spell.happenTime = nil;
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
	
	local function GetAuras(self)
		local curTime = GetTime()
		local name, count, duration, endTime, caster, id, v1, v2, v3
		local ret = 0;
		local f
		for i = 1, 40 do 
			name, _, _, count, dispelType, duration, endTime, caster, _, _, id, _, isBossDebuff, _,_, v1, v2, v3 = UnitAura(self.unit, i, self.filter)
			if not id then break end
			f = self.frame.pointer[tostring(id)] or self.frame.pointer[name]
			if f and f.spell then
				spell = f.spell
				spell.isUpdate = true
				if not StaggerID[id] then -- 시간차가 아니면
					-- if spell.v1_hp then
						-- spell.v1 = math.ceil((v2 / UnitHealthMax(self.unit)) *100)
					-- else
						spell.v1 = v2; 
					-- end
				else -- 시간차
					-- if spell.v1_hp then
						-- spell.v1 = math.ceil((v3 / UnitHealthMax(self.unit)) *100)
					-- else
						spell.v1 = v3; 
					-- end
				end
				spell.count = spell.count + count
				spell.id = id
				spell.dispelType = dispelType
				spell.overlay = (spell.overlay or 0) + 1
				if spell.endTime ~= endTime then spell.endTime = endTime; spell.happenTime = GetTime(); end
				if endTime > 0 then spell.remaining = spell.endTime - curTime
				else spell.remaining = 0; end
				spell.duration = duration
				spell.startTime = endTime - duration
				spell.index = i; -- 툴팁을 위해, 순서
				ret = ret + 1;
			end
		end
		return ret;
	end
	
	local function GetAurasAll(self) 
		local curTime = GetTime()
		local ret = 1;
		local f
		for i = 1, 40 do 
			name, _, icon, count, dispelType, duration, endTime, caster, _, _, id, canApplyAura, isBossDebuff = UnitAura(self.unit, i, self.filter)
			if not id then break end
			-- f = self.frame.pointer[name];
			-- if not f then 
				-- self.frame.pointer[id] = f;
			-- end
			if self.option.base.tracking_boss_aura then
				-- if isBossDebuff then
					-- print(name,caster )
					-- print(name,caster )
					-- print(name,caster )
				-- end
				if HDH_TRACKER.BOSS_DEBUFF[id] or (self.isRaiding and (not UnitIsPlayer(caster) or isBossDebuff)) then
				-- if i % 2 == 1 then
					-- print(name,ret)
					f = self.frame.icon[ret];
				else
					f = nil;
				end
			else
				f = self.frame.icon[ret];
			end
			
			if f then
				if not f.spell then f.spell = {} end
				spell = f.spell
				spell.no = i;
				spell.isUpdate = true
				spell.count = count
				spell.id = id
				spell.overlay = 0
				spell.endTime = endTime
				spell.name = name;
				spell.dispelType = dispelType
				spell.remaining = spell.endTime - curTime
				spell.duration = duration
				spell.startTime = endTime - duration
				spell.icon = icon
				spell.index = i; -- 툴팁을 위해, 순서
				spell.happenTime = GetTime();
				f.icon:SetTexture(icon)
				ret = ret + 1;
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
		
		self.GetAurasFunc(self);
		if (self:UpdateIcons(self) > 0) or self.option.icon.always_show or UnitAffectingCombat("player") then
			-- self.frame:Show()
			self:ShowTracker();
		else
			-- self.frame:Hide()
			self:HideTracker();
		end
	end
	
	function HDH_TRACKER:InitIcons()
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID
		local spell 
		local f
		local iconIdx = 0;
		local isBuff = (self.type == L_BUFF);
		self.frame.pointer = {}
		
		if self.option.base.tracking_all or self.option.base.tracking_boss_aura then
			self.GetAurasFunc = GetAurasAll
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
			for i = 1, #auraList do
				if not self:IsIgnoreSpellByTalentSpell(auraList[i]) then
					iconIdx = iconIdx + 1
					f = self.frame.icon[iconIdx]
					if f:GetParent() == nil then f:SetParent(self.frame) end
					self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
					spell = {}
					spell.glow = auraList[i].Glow
					spell.glowCount = auraList[i].GlowCount
					spell.glowV1= auraList[i].GlowV1
					spell.always = auraList[i].Always
					spell.showValue = auraList[i].ShowValue -- 수치표시
					spell.v1_hp =  auraList[i].v1_hp -- 수치 체력 단위표시
					spell.v1 = 0 -- 수치를 저장할 변수
					spell.aniEnable = true;
					spell.aniTime = 8;
					spell.aniOverSec = false;
					spell.no = auraList[i].No
					spell.name = auraList[i].Name
					spell.icon = auraList[i].Texture
					if not auraList[i].defaultImg then auraList[i].defaultImg = auraList[i].Texture; 
					elseif auraList[i].defaultImg ~= auraList[i].Texture then spell.fix_icon = true end
					spell.id = tonumber(auraList[i].ID)
					spell.count = 0
					spell.duration = 0
					spell.remaining = 0
					spell.overlay = 0
					spell.endTime = 0
					spell.is_buff = isBuff;
					spell.isUpdate = false
					spell.isItem =  auraList[i].IsItem
					f.spell = spell
					f.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
					-- f.icon:SetDesaturated(1)
					-- f.icon:SetAlpha(self.option.icon.off_alpha)
					-- f.border:SetAlpha(self.option.icon.off_alpha)
					self:ChangeCooldownType(f, self.option.base.cooldown)
					self:SetGlow(f, false)
					
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
			self.GetAurasFunc = GetAuras
			for i = #(self.frame.icon) ,iconIdx+1, -1  do
				self:ReleaseIcon(i)
			end
		end
		self:LoadOrderFunc();
		
		local filter;
		if isBuff then  filter = "HELPFUL";
		else filter = "HARMFUL"; end
		if self.option.base.check_only_mine then  filter = filter.."|PLAYER" end
		self.filter = filter;
		
		self.frame:SetScript("OnEvent", OnEventTracker)
		self.frame:UnregisterAllEvents()
		
		if self.option.base.tracking_boss_aura then
			self.frame:RegisterEvent("ENCOUNTER_START");
			self.frame:RegisterEvent("ENCOUNTER_END");
		end
		
		if #(self.frame.icon) > 0 or self.option.base.tracking_all or self.option.base.tracking_boss_aura then
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
		return iconIdx;
	end

	function HDH_TRACKER:IsIgnoreSpellByTalentSpell(DB_Spell)
		local ret = false;
		if not DB_Spell then return true end
		if DB_Spell.Ignore and DB_Spell.Ignore[1] then
			local name = DB_Spell.Ignore[1].Spell;
			local show = DB_Spell.Ignore[1].Show;
			local selected = HDH_AT_UTIL.IsTalentSpell(name); -- true / false / nil: not found talent
			if selected == true then
				ret = (not show);
			elseif selected == false then
				ret = show;
			end
		end
		-- print(DB_Spell.Name, ret)
		return ret;
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
		f = f.iconframe;
		if ( f.overlay ) then
			if ( f.overlay.animOut:IsPlaying() ) then f.overlay.animOut:Stop(); f.overlay.animIn:Play(); end
		else
			f.overlay = ActionButton_GetOverlayGlow();
			local frameWidth, frameHeight = f:GetSize();
			f.overlay:SetParent(f);
			f.overlay:ClearAllPoints();
			-- Make the height/width available before the next frame:
			f.overlay:SetSize(frameWidth * 1.30, frameHeight * 1.30);
			f.overlay:SetPoint("TOPLEFT", f, "TOPLEFT", -frameWidth * 0.30, frameHeight * 0.30);
			f.overlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", frameWidth * 0.30, -frameHeight * 0.30);
			f.overlay.animIn:Play();
			if f.spell and f.spell.conditionSound and not OptionFrame:IsShown() then
				HDH_PlaySoundFile(f.spell.conditionSound, "SFX")
			end
		end
	end
	
	function HDH_TRACKER:ActionButton_HideOverlayGlow(f)
		ActionButton_HideOverlayGlow(f.iconframe);
	end
	
	function HDH_TRACKER:IsGlowing(f)
		return f.overlay and true or false
	end

	function HDH_TRACKER:SetGlow(f, bool)
		if f.spell.ableGlow then -- 블리자드 기본 반짝임 효과면 무조건 적용
			self:ActionButton_ShowOverlayGlow(f) return
		end
		if bool and (f.spell and f.spell.glow) then
			if f.spell.glowCount 
				and (f.spell.count >= f.spell.glowCount 
				or (f.spell.charges and f.spell.charges.count >= f.spell.glowCount) ) then 
				self:ActionButton_ShowOverlayGlow(f)
			elseif f.spell.glowV1 and (f.spell.v1 >= f.spell.glowV1) then
				self:ActionButton_ShowOverlayGlow(f)
			elseif f.spell.glowTime then
				
				if (f.spell.glowTime >= f.spell.remaining) then
					self:ActionButton_ShowOverlayGlow(f)
				end
			else
				self:ActionButton_HideOverlayGlow(f)
			end
		else
			self:ActionButton_HideOverlayGlow(f)
		end
	end
	
	function HDH_TRACKER:GetAni(f, ani_type) -- row 이동 애니
		if ani_type == HDH_TRACKER.ANI_HIDE then
			if not f.aniHide then
				local ag = f:CreateAnimationGroup()
				f.aniHide = ag
				ag.a1 = ag:CreateAnimation("ALPHA")
				ag.a1:SetOrder(1)
				ag.a1:SetDuration(0.12) 
				ag.a1:SetFromAlpha(1);
				ag.a1:SetToAlpha(0.0);
				-- ag.a1:SetStartDelay(8);
				-- ag.a2 = ag:CreateAnimation("ALPHA")
				-- ag.a2:SetOrder(2)
				-- ag.a2:SetStartDelay(8);
				-- ag.a2:SetDuration(8) 
				-- ag.a2:SetFromAlpha(0.5);
				-- ag.a2:SetToAlpha(0);
				ag:SetScript("OnFinished",function() f:Hide(); end)
				-- ag:SetScript("OnStop",function() f:SetAlpha(1.0);  end)
			end	
			return f.aniHide;
		elseif ani_type == HDH_TRACKER.ANI_SHOW then
			if not f.aniShow then
				local ag = f:CreateAnimationGroup()
				f.aniShow = ag
				ag.a1 = ag:CreateAnimation("ALPHA")
				ag.a1:SetOrder(1)
				ag.a1:SetDuration(0.12)
				-- ag.a1:SetSmoothing("IN")   
				ag.a1:SetFromAlpha(0);
				ag.a1:SetToAlpha(1);
				ag:SetScript("OnFinished",function()
					-- f:SetAlpha(1);	
					end)
			end
			return f.aniShow;
		end
	end
	
	function HDH_TRACKER:ShowTracker()
		self:StartAni(self.frame, HDH_TRACKER.ANI_SHOW);
		-- self.frame:SetAlpha(1);
		self.frame:Show();
	end
	
	function HDH_TRACKER:HideTracker()
		self:StartAni(self.frame, HDH_TRACKER.ANI_HIDE);
		-- self.frame:Hide();
	end

	function HDH_TRACKER:StartAni(f, ani_type) -- row 이동 실행
		if ani_type == HDH_TRACKER.ANI_HIDE then
			if self:GetAni(f, HDH_TRACKER.ANI_SHOW):IsPlaying() then self:GetAni(f, HDH_TRACKER.ANI_SHOW):Stop() end
			if f:IsShown() and not self:GetAni(f, ani_type):IsPlaying() then
				self:GetAni(f, ani_type):Play();
			end
		elseif ani_type== HDH_TRACKER.ANI_SHOW then
			if self:GetAni(f, HDH_TRACKER.ANI_HIDE):IsPlaying() then
				self:GetAni(f, HDH_TRACKER.ANI_HIDE):Stop() 
				self:GetAni(f, ani_type):Play();
			end
			if not f:IsShown() and not self:GetAni(f, ani_type):IsPlaying() then
				f:Show();
				self:GetAni(f, ani_type):Play();
			end
		end
	end
	
	-- function HDH_TRACKER:OnEffectEvent(self, event, ...)
		-- if event == "AT_EVENT_START_SOUND" then
		
		-- elseif event == "AT_EVENT_END_SOUND" then
		
		-- elseif event == "AT_EVENT_CONDITION_SOUND" then
		
		-- elseif event == ""
	-- end
	
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
	if not HDH_TRACKER.IsLoaded then 
		print('|cffffff00HDH - AuraTracking |cffffffff(Setting: /at, /auratracking, /ㅁㅅ)')
		HDH_TRACKER.startTime = GetTime();
		HDH_AT_ADDON_Frame:RegisterEvent('VARIABLES_LOADED')
		HDH_AT_ADDON_Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
		HDH_AT_ADDON_Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
		HDH_AT_ADDON_Frame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	end

	HDH_TRACKER.InitVaribles()
	for i = 1, #DB_FRAME_LIST do
		if HDH_TRACKER.Get(DB_FRAME_LIST[i].name) then
			HDH_TRACKER.Get(DB_FRAME_LIST[i].name):PLAYER_ENTERING_WORLD()
		end
	end
	HDH_TRACKER.IsLoaded = true;
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
	elseif event == "ENCOUNTER_START" then
		self.parent.isRaiding = true;
	elseif event == "ENCOUNTER_END" then
		self.parent.isRaiding = false;
	end
end

-- 이벤트 콜백 함수
local function OnEvent(self, event, ...)
	if event =='ACTIVE_TALENT_GROUP_CHANGED' then
		HDH_AT_UTIL.IsTalentSpell(nil,nil,true);
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
		-- self:UnregisterEvent('PLAYER_ENTERING_WORLD')
		PLAY_SOUND = false
		C_Timer.After(3, PLAYER_ENTERING_WORLD)
		C_Timer.After(6, function() PLAY_SOUND = true end)
	elseif event =="GET_ITEM_INFO_RECEIVED" then
	end
end

-- 애드온 로드 시 가장 먼저 실행되는 함수
local function OnLoad(self)
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED")
end
	
HDH_AT_ADDON_Frame = CreateFrame("Frame", "HDH_AT_iconframe", UIParent) -- 애드온 최상위 프레임
HDH_AT_ADDON_Frame:SetScript("OnEvent", OnEvent)
OnLoad(HDH_AT_ADDON_Frame)


--------------------------------------------
-- 유틸
--------------------------------------------	


do 
	HDH_AT_UTIL.SpellCache = setmetatable({}, {
		__index=function(t,v) 
			local a = {GetSpellInfo(v)} 
			if GetSpellInfo(v) then t[v] = a end 
			return a 
		end})

	function HDH_AT_UTIL.GetCacheSpellInfo(a)
		return unpack(HDH_AT_UTIL.SpellCache[a])
	end	

	function HDH_AT_UTIL.GetInfo(value, isItem)
		if not value then return nil end
		if not isItem and HDH_AT_UTIL.GetCacheSpellInfo(value) then
			local name, rank, icon, castingTime, minRange, maxRange, spellID = HDH_AT_UTIL.GetCacheSpellInfo(value) 
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

	function HDH_AT_UTIL.Trim(str)
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

	function HDH_AT_UTIL.IsTalentSpell(talent_name, spec, isReload)
		spec = spec or GetSpecialization();
		if isReload or cashTalentSpell == nil then cashTalentSpell = {} end
		if cashTalentSpell[spec] == nil or #(cashTalentSpell[spec]) == 0 then
			cashTalentSpell[spec] = {};
			for tier = 1, MAX_TALENT_TIERS do
				for column = 1, NUM_TALENT_COLUMNS do
					local id, name,_,_,_,_,_,_,_,selected = GetTalentInfoBySpecialization(spec,tier,column)
					if name then
						cashTalentSpell[spec][name] = selected
					end
				end
			end
		end
		
		return cashTalentSpell[spec][talent_name] -- nil: not found talent
	end

	function HDH_AT_UTIL.Deepcopy(orig) -- cpy table
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[HDH_AT_UTIL.Deepcopy(orig_key)] = HDH_AT_UTIL.Deepcopy(orig_value)
			end
			setmetatable(copy, HDH_AT_UTIL.Deepcopy(getmetatable(orig)))
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end

	function HDH_AT_UTIL.CheckToUpdateDB(srcData, dstData)
		local orig_type = type(srcData)
		if dstData == nil then dstData = {}; end
		if orig_type == 'table' then
			if type(dstData) == 'table' then
				for orig_key, orig_value in next, srcData, nil do
					if dstData[orig_key] ~= nil and type(orig_value) == type(dstData[orig_key]) then
						dstData[orig_key] = HDH_AT_UTIL.CheckToUpdateDB(srcData[orig_key], dstData[orig_key]);
					else
						dstData[orig_key] = HDH_AT_UTIL.Deepcopy(orig_value);
					end
				end
			end
		end
		return dstData;
	end
	
		
	function HDH_AT_UTIL.CommaValue(amount)
		if amount == nil then return nil end
		local formatted = amount
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
	end
	
	function HDH_AT_UTIL.AbbreviateValue(amount, isShort, lengType)
		lengType = lengType or HDH_TRACKER.LOCALE;
		if amount == nil then return nil end
		if lengType == "koKR" then	
			if amount < 1000000 then
				if isShort then
					if amount < 10000 then
						return HDH_AT_UTIL.CommaValue(amount);
					elseif amount < 100000 then
						return format("%.1f만",amount/10000);
					else
						return format("%d만",amount/10000);
					end
				else
					return HDH_AT_UTIL.CommaValue(amount);
				end
			elseif  amount <= 100000000 then
				return format("%d만",amount/10000);
			elseif amount <= 100000000 then
				return format("%.1f억",amount/100000000);
			else
				return format("%d억",amount/100000000);
			end
		else
			if amount < 1000000 then
				if isShort and amount >= 1000 then
					return format("%.1fk",amount/1000);
				else
					return HDH_AT_UTIL.CommaValue(amount);
				end
			elseif  amount <= 100000000 then
				return format("%.1fm",amount/1000000);
			else
				return format("%.1fg",amount/1000000000);
			end
		end
	end
end