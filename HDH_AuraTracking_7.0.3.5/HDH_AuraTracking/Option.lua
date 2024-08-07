﻿-----------------
---- #define ----
HDH_AT_OP = {};

local STR_TRACKER_BTN_FORMAT = "%s\r\n|cffaaaaaa%s"

local FRAME_W = 670
local FRAME_H = 500
local MAX_H = 499
local MIN_H = 300

local ROW_HEIGHT = 26 -- 오라 row 높이
local EDIT_WIDTH_L = 145
local EDIT_WIDTH_S = 0
local FLAG_ROW_CREATE = 1 -- row 생성 모드
local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0
local DDM_COOLDOWN_LIST = {"위로", "아래로", "왼쪽으로", "오른쪽으로", "원형"}
local DDM_FONT_LOCATION_LIST = {"좌측 상단","좌측 하단","우측 상단", "우측 하단", "중앙", "아이콘 밖 위", "아이콘 밖 아래"}

local BODY_TYPE = {CREATE_TRACKER = 0, AURA = 1, UI = 2, EDIT_TRACKER = 3, AURA_DETAIL = 4 };
HDH_AT_OP.BODY_TYPE = BODY_TYPE;

local FRAME_TYPE = {BTN = 1, CB=2, COLOR=3, DDM=4, SL=5};
local UI_TYPE = { FONT = 1, ICON=2, PROFILE=3, ETC = 4 };
HDH_AT_OP.UI_TYPE = UI_TYPE;
				 
-- FRAME --
local OPTION_FRAME = OptionFrame; -- parent
local TRACKER_LIST_FRAME;
local SETTING_CONTENTS_FRAME;
local BODY_TAB_BTN_LIST;
local UI_TAB_BTN_LIST; -- setting frame
local AURA_DETAIL_TAB_BTN_LIST;
local TRACKER_TAB_BTN_LIST;

local F_BODY_UNIT;
local F_BODY_SET;
local F_BODY_TRACKER;
	
	-- 기본 설정 --
local F_OP_CB_EACH ;
local F_OP_CB_SHOW_ID;
local F_OP_CB_ALWAYS_SHOW;

	-- 글자 설정 --
local F_OP_BTN_COLOR_FONT1;
local F_OP_BTN_COLOR_FONT2;
local F_OP_BTN_COLOR_FONT3;
local F_OP_BTN_COLOR_FONT4;
local F_OP_BTN_COLOR_FONT_CD5;
local F_OP_CB_SHOW_CD;
local F_OP_DDM_FONT_LOC1;
local F_OP_DDM_FONT_LOC2;
local F_OP_DDM_FONT_LOC3;
local F_OP_DDM_FONT_LOC4;
local F_OP_SL_FONT_SIZE1;
local F_OP_SL_FONT_SIZE2;
local F_OP_SL_FONT_SIZE3;
local F_OP_SL_FONT_SIZE4;

	-- 아이콘 설정 --
local F_OP_BTN_COLOR_BUFF;
local F_OP_BTN_COLOR_DEBUFF;
local F_OP_BTN_COLOR_CD_BG;
local F_OP_CB_COLOR_DEBUFF_DEFAULT;
local F_OP_SL_ICON_SIZE;
local F_OP_SL_ON_ALPHA;
local F_OP_SL_OFF_ALPHA;
local F_OP_SL_MARGIN_H;
local F_OP_SL_MARGIN_V;
	
	-- 트래커별 UI 설정 --
local F_OP_CB_REVERS_H;
local F_OP_CB_REVERS_V;
local F_OP_CB_ICON_FIX;
local F_OP_SL_LINE;
local F_OP_CB_SHOW_TOOLTIP;
local F_OP_DDM_CD_TYPE;
local F_OP_CB_TRACKER_ENABLE;

	-- 스킬 쿨다운 관련 설정 --
local F_OP_CP_CT_COLOR;
local F_OP_CB_CT_DESAT;
local F_OP_SL_CT_MAXTIME;
local F_OP_DDM_CT_RELATIVE_UNIT;


-- 트래커 추가 탭 --
local F_OP_DDM_TRACKER_LIST;
local F_OP_DDM_UNIT_LIST;
local F_OP_DDM_TALENT_LIST;

---- #end def ----
------------------

g_CurMode = BODY_TYPE.AURA;
local CurSpec = 1 -- 현재 설정창 특성
local ListFrame;
local TAB_TALENT;

function HDH_OP_AlertDlgShow(msg, func, ...)
	if AlertDlg:IsShown() then return end
	AlertDlg.text = msg;
	AlertDlg.func = func;
	AlertDlg.arg = {...};
	AlertDlg:Show();
end

-- 프레임 변수와 db 키와 매칭하는 함수
local function InitFrame()
	F_BODY_UNIT = UnitOptionFrame;
	F_BODY_SET = SettingFrame;
	F_BODY_TRACKER = AddTrackerFrame;
	
	-- 기본 설정 --
	F_OP_CB_MOVE = SettingFrameUIBottomCheckButtonMove;
	F_OP_CB_EACH = SettingFrameUIListSFContentsCheckButtonEachSet;
	F_OP_CB_EACH.key = "use_each";
	F_OP_CB_SHOW_ID = SettingFrameUIBottomCheckButtonIDShow;
	F_OP_CB_SHOW_ID.key = "tooltip_id_show";
	F_OP_CB_ALWAYS_SHOW = SettingFrameUIBodyIconSFContentsCheckButtonAlwaysShow;
	F_OP_CB_ALWAYS_SHOW.key = "always_show";

	-- 글자 설정 --
	F_OP_BTN_COLOR_FONT1 = SettingFrameUIBodyFontSFContentsButtonColorText1;
	F_OP_BTN_COLOR_FONT1.key = "textcolor";
	F_OP_BTN_COLOR_FONT2 = SettingFrameUIBodyFontSFContentsButtonColorText2;
	F_OP_BTN_COLOR_FONT2.key = "countcolor";
	F_OP_BTN_COLOR_FONT3 = SettingFrameUIBodyFontSFContentsButtonColorText3;
	F_OP_BTN_COLOR_FONT3.key = "v1_color";
	F_OP_BTN_COLOR_FONT4 = SettingFrameUIBodyFontSFContentsButtonColorText4;
	F_OP_BTN_COLOR_FONT4.key = "v2_color";
	F_OP_BTN_COLOR_FONT_CD5 = SettingFrameUIBodyFontSFContentsButtonColorCooldownText5;
	F_OP_BTN_COLOR_FONT_CD5.key = "textcolor_5s";
	F_OP_CB_SHOW_CD = SettingFrameUIBodyFontSFContentsCheckButtonShowCooldown;
	F_OP_CB_SHOW_CD.key = "show_cooldown";
	F_OP_DDM_FONT_LOC1 = SettingFrameUIBodyFontSFContentsDDMFontLocation1;
	F_OP_DDM_FONT_LOC1.key = "cd_location";
	F_OP_DDM_FONT_LOC2 = SettingFrameUIBodyFontSFContentsDDMFontLocation2;
	F_OP_DDM_FONT_LOC2.key = "count_location";
	F_OP_DDM_FONT_LOC3 = SettingFrameUIBodyFontSFContentsDDMFontLocation3;
	F_OP_DDM_FONT_LOC3.key = "v1_location";
	F_OP_DDM_FONT_LOC4 = SettingFrameUIBodyFontSFContentsDDMFontLocation4;
	F_OP_DDM_FONT_LOC4.key = "v2_location";
	F_OP_SL_FONT_SIZE1 = SettingFrameUIBodyFontSFContentsSliderFont1;
	F_OP_SL_FONT_SIZE1.key = "fontsize";
	F_OP_SL_FONT_SIZE2 = SettingFrameUIBodyFontSFContentsSliderFont2;
	F_OP_SL_FONT_SIZE2.key = "countsize";
	F_OP_SL_FONT_SIZE3 = SettingFrameUIBodyFontSFContentsSliderFont3;
	F_OP_SL_FONT_SIZE3.key = "v1_size";
	F_OP_SL_FONT_SIZE4 = SettingFrameUIBodyFontSFContentsSliderFont4;
	F_OP_SL_FONT_SIZE4.key = "v2_size";

	-- 아이콘 설정 --
	F_OP_BTN_COLOR_BUFF = SettingFrameUIBodyIconSFContentsButtonColorBuff;
	F_OP_BTN_COLOR_BUFF.key = "buff_color";
	F_OP_BTN_COLOR_DEBUFF = SettingFrameUIBodyIconSFContentsButtonColorDebuff;
	F_OP_BTN_COLOR_DEBUFF.key  = "debuff_color";
	F_OP_BTN_COLOR_CD_BG = SettingFrameUIBodyIconSFContentsButtonColorCooldownBg;
	F_OP_BTN_COLOR_CD_BG.key  = "cooldown_bg_color";
	F_OP_CB_COLOR_DEBUFF_DEFAULT = SettingFrameUIBodyIconSFContentsCheckButtonDefaultColor;
	F_OP_CB_COLOR_DEBUFF_DEFAULT.key  = "defaultColor";
	F_OP_SL_ICON_SIZE = SettingFrameUIBodyIconSFContentsSliderIcon;
	F_OP_SL_ICON_SIZE.key  = "size";
	F_OP_SL_ON_ALPHA = SettingFrameUIBodyIconSFContentsSliderOnAlpha;
	F_OP_SL_ON_ALPHA.key  = "on_alpha";
	F_OP_SL_OFF_ALPHA = SettingFrameUIBodyIconSFContentsSliderOffAlpha;
	F_OP_SL_OFF_ALPHA.key  = "off_alpha";
	F_OP_SL_MARGIN_H = SettingFrameUIBodyIconSFContentsSliderMarginH;
	F_OP_SL_MARGIN_H.key  = "margin_h";
	F_OP_SL_MARGIN_V = SettingFrameUIBodyIconSFContentsSliderMarginV;
	F_OP_SL_MARGIN_V.key  = "margin_v";
	
	-- 트래커별 UI 설정 --
	F_OP_CB_REVERS_H = UnitOptionFrameCheckButtonReversH;
	F_OP_CB_REVERS_H.key = "revers_h";
	F_OP_CB_REVERS_V = UnitOptionFrameCheckButtonReversV;
	F_OP_CB_REVERS_V.key = "revers_v";
	F_OP_CB_SHOW_TOOLTIP = UnitOptionFrameCheckButtonTooltip;
	F_OP_CB_SHOW_TOOLTIP.key = "show_spell_tooltip";
	F_OP_CB_ICON_FIX = UnitOptionFrameCheckButtonFix;
	F_OP_CB_ICON_FIX.key = "fix";
	F_OP_SL_LINE = UnitOptionFrameSliderLine;
	F_OP_SL_LINE.key = "line";
	F_OP_DDM_CD_TYPE = UnitOptionFrameDDMCooldown;
	F_OP_DDM_CD_TYPE.key = "cooldown";
	F_OP_CB_TRACKER_ENABLE = UnitOptionFrameCheckButtonTrackerEnable;
	F_OP_CB_TRACKER_ENABLE.key = "tracker_enable";
	
	--F_OP_CB_REVERS_H = SettingFrameUIBottomCheckButtonMove;
	--F_OP_BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonSet
	--F_OP_BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonLoad
	--F_OP_BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonReset
	F_OP_DDM_PROFILE = SettingFrameUIBodyProfileDDMProfile;
	
	-- 트래커 추가 탭 --
	F_OP_DDM_TALENT_LIST = AddTrackerFrameDDMSpecList;
	F_OP_DDM_TRACKER_LIST = AddTrackerFrameDDMTabList;
	F_OP_DDM_UNIT_LIST = AddTrackerFrameDDMUnitList;
	F_OP_DDM_UNIT_LIST.key = "unit";
	F_OP_CB_TRACKER_BUFF = AddTrackerFrameCheckButtonBuff; 
	F_OP_CB_TRACKER_BUFF.key = "check_buff";
	F_OP_CB_TRACKER_DEBUFF = AddTrackerFrameCheckButtonDebuff;
	F_OP_CB_TRACKER_MINE = AddTrackerFrameCheckButtonMine; 
	F_OP_CB_TRACKER_MINE.key = "check_only_mine";
	F_OP_CB_TRACKER_ALL_AURA = AddTrackerFrameCheckButtonAllAura; 
	F_OP_CB_TRACKER_ALL_AURA.key = "tracking_all";
	F_OP_CB_TRACKER_MERGE_POWERICON = AddTrackerFrameCheckButtonMergePowerIcon;
	F_OP_CB_TRACKER_MERGE_POWERICON.key = "merge_powericon";
	
	-- 스킬 쿨다운 관련 설정 --
	F_OP_CP_CT_COLOR = CooldownSettingFrameButtonColor;
	F_OP_CP_CT_COLOR.key = "cooldown_color";
	F_OP_CB_CT_DESAT = CooldownSettingFrameCheckButtonDesaturation;
	F_OP_CB_CT_DESAT.key = "desaturation";
	F_OP_SL_CT_MAXTIME = CooldownSettingFrameSliderMaxTime;
	F_OP_SL_CT_MAXTIME.key = "max_time";
end

-- 기본 공통 설정 디비 매칭
local function Match_Basic_DBForFrame()
	F_OP_CB_EACH.db = DB_OPTION;
	F_OP_CB_SHOW_ID.db = DB_OPTION;
end

-- 트래커별 디비 매칭
local function Match_Tracker_DBForFrame(curTracker)
	local tracker_name = HDH_AT_OP_GetTrackerInfo(curTracker);
	local db = DB_OPTION[tracker_name];
	if tracker_name and db then
		F_OP_CB_REVERS_H.db = db;
		F_OP_CB_REVERS_V.db = db;
		F_OP_CB_SHOW_TOOLTIP.db = db;
		F_OP_CB_ICON_FIX.db = db;
		F_OP_SL_LINE.db = db;
		F_OP_DDM_CD_TYPE.db = db;
		F_OP_DDM_UNIT_LIST.db = db;
		F_OP_CB_TRACKER_BUFF.db = db;
		F_OP_CB_TRACKER_MINE.db = db;
		F_OP_CB_TRACKER_ALL_AURA.db = db;
		F_OP_CB_TRACKER_MERGE_POWERICON.db = db;
		F_OP_CB_TRACKER_ENABLE.db = DB_AURA.Talent[HDH_GetSpec()][tracker_name];
		return true;
	else
		return false;
	end
end

-- 폰트/아이콘 디비 매칭
local function Match_FontIcon_DBForFrame(curTracker)
	local icon, font ;
	local tracker_name = HDH_AT_OP_GetTrackerInfo(curTracker);
	if tracker_name and DB_OPTION[tracker_name] then
		if DB_OPTION[tracker_name].use_each then
			icon = DB_OPTION[tracker_name].icon;
			font = DB_OPTION[tracker_name].font;
		else
			font = DB_OPTION.font;
			icon = DB_OPTION.icon;
		end
	else
		font = DB_OPTION.font;
		icon = DB_OPTION.icon;
	end
	F_OP_CB_EACH.db = DB_OPTION[tracker_name];
	F_OP_BTN_COLOR_FONT1.db = font;
	F_OP_BTN_COLOR_FONT2.db = font;
	F_OP_BTN_COLOR_FONT3.db = font;
	F_OP_BTN_COLOR_FONT4.db = font;
	F_OP_BTN_COLOR_FONT_CD5.db = font;
	F_OP_DDM_FONT_LOC1.db = font;
	F_OP_DDM_FONT_LOC2.db = font;
	F_OP_DDM_FONT_LOC3.db = font;
	F_OP_DDM_FONT_LOC4.db = font;
	F_OP_SL_FONT_SIZE1.db = font;
	F_OP_SL_FONT_SIZE2.db = font;
	F_OP_SL_FONT_SIZE3.db = font;
	F_OP_SL_FONT_SIZE4.db = font;
	F_OP_CB_SHOW_CD.db = icon;
	F_OP_BTN_COLOR_BUFF.db = icon;
	F_OP_BTN_COLOR_DEBUFF.db = icon;
	F_OP_BTN_COLOR_CD_BG.db = icon;
	F_OP_CB_COLOR_DEBUFF_DEFAULT.db = icon;
	F_OP_SL_ICON_SIZE.db = icon;
	F_OP_SL_ON_ALPHA.db = icon;
	F_OP_SL_OFF_ALPHA.db = icon;
	F_OP_SL_MARGIN_H.db = icon;
	F_OP_SL_MARGIN_V.db = icon;
	
	F_OP_CB_ALWAYS_SHOW.db = icon;
	
	F_OP_CP_CT_COLOR.db = icon;
	F_OP_CB_CT_DESAT.db = icon;
	F_OP_SL_CT_MAXTIME.db = icon;
end

--local function Match_CreateTracker_DBForFrame(curTracker)
--	local tracker_name = HDH_AT_OP_GetTrackerInfo(curTracker);
--	if tracker_name and DB_OPTION[tracker_name] then
--		
--	end
--end

-- 프레임 데이터 업데이트함수 - 체크박스
-- value를 넣으면 디비에 저장
-- value 값이 없으면 디비값에 맞춰 프레임값 업데이트
local function UpdateFrameDB_CB(frame, value) -- check button
	if frame.db then
		if value ~= nil then
			frame.db[frame.key] = value;
		else
			--print(frame:GetName().." "..frame.db[frame.key]);
			frame:SetChecked(frame.db[frame.key]);
		end
	end
end

-- 프레임 데이터 업데이트함수 - 드롭다운메뉴
local function UpdateFrameDB_DDM(frame, items, value) -- drop down menu
	if frame.db then
		if value ~= nil then
			if frame == F_OP_DDM_UNIT_LIST then
				frame.db[frame.key] = HDH_TRACKER_LIST[value];
			else
				frame.db[frame.key] = value;
			end
		else
			if frame == F_OP_DDM_UNIT_LIST then
				local unit = frame.db[frame.key];
				local idx = 1;
				for i = 1, #HDH_TRACKER_LIST do
					if HDH_TRACKER_LIST[i] == unit then idx = i break end
				end
				HDH_AT_LoadDropDownButton(frame, idx, items);
			else
				HDH_AT_LoadDropDownButton(frame, frame.db[frame.key], items);
			end
		end
	end
end

-- 프레임 데이터 업데이트함수 - 컬러픽커
local function UpdateFrameDB_CP(frame, r, g, b, a) -- color
	if frame.db then
		if r and g and b then
			frame.db[frame.key] = {r, g, b, a};
		else
			local color = {unpack(frame.db[frame.key])};
			_G[frame:GetName().."Preview"]:SetVertexColor(color[1],color[2], color[3]);
			--_G[frame:GetName().."Preview"]:SetTexture(1,0,0);
		end
	end
end

-- 프레임 데이터 업데이트함수 - 슬라이더
local function UpdateFrameDB_SL(frame, value, min, max, per) -- per: SL 소수점(0~1 사이) 값을 지원하지 않기에 보정을위해서 사용
	if frame.db then
		if value ~= nil then
			frame.db[frame.key] = value / (per or 1);
		else
			if min and max then
				HDH_Adjust_Slider(frame, frame.db[frame.key] * (per or 1), min ,max);
			else
				frame:SetValue(frame.db[frame.key] * (per or 1));
			end
		end
	end
end

-- 디비값 불러오기 - 컬러값 언팩하는 과정을 위해
local function GetFrameDB_CP(frame) -- color
	if frame.db then
		return unpack(frame.db[frame.key]);
	end
end

-------------------------------------------
-- util
-------------------------------------------

local function GetTrackerIndex()
	return TRACKER_TAB_BTN_LIST.CurIdx;
end

local function SetTrackerIndex(idx)
	TRACKER_TAB_BTN_LIST.CurIdx = idx;
end

function HDH_GetSpec()
	return CurSpec
end

function HDH_AT_OP_GetTrackerInfo(idx)
	if not idx then idx = GetTrackerIndex(); end
	if DB_FRAME_LIST[idx] then return DB_FRAME_LIST[idx].name, DB_FRAME_LIST[idx].unit
						  else return nil end
end

local function deepcopy(orig) -- cpy table
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function trim(s)
  return s:gsub("%s+", "")
end

function HDH_AT_LoadDropDownButton(frame, idx, dataTable, func)
	if not func then func = HDH_AT_OP_OnSelectedItem_DDM; end
	frame.id = idx or 0 -- 값을 캐싱 해놓고 init 호출시 불러와서 세팅한다
	UIDropDownMenu_Initialize(frame, function(self, level)
		local items = dataTable
		local info = UIDropDownMenu_CreateInfo();
		
		for k,v in pairs(items) do
			--info = 
			info.text = v
			info.value = v
			info.func = function(self) frame.id = self:GetID(); func(frame, self, self.value, self:GetID()) end
			UIDropDownMenu_AddButton(info, level)
		end
		UIDropDownMenu_SetSelectedID(frame, frame.id)
		if not frame.id or frame.id == 0 then
			UIDropDownMenu_SetText(frame, "선택") 
		end
	end)
	UIDropDownMenu_SetWidth(frame, 100)
	UIDropDownMenu_SetButtonWidth(frame, 120)
	UIDropDownMenu_JustifyText(frame, "LEFT")
end

------------------------------------------
-- Animation
------------------------------------------

local function CrateAni(f) -- row 이동 애니
	if f.ani then return end
	local ag = f:CreateAnimationGroup()
	f.ani = ag
	
	ag.a1 = ag:CreateAnimation("Translation")
	ag.a1:SetOrder(1)
	ag.a1:SetDuration(0.3)
	ag.a1:SetSmoothing("OUT")   
	
	ag:SetScript("OnFinished",function()
			if ag.func then
				ag.func(unpack(ag.args))
			end
		end) 
end

local function StartAni(f, ani_type) -- row 이동 실행
	if not f.ani then return end
	if ani_type == ANI_MOVE_UP then
		f.ani.a1:SetOffset(0, f:GetHeight())
		f.ani:Play()
	elseif ani_type== ANI_MOVE_DOWN then
		f.ani.a1:SetOffset(0, -f:GetHeight())
		f.ani:Play()
	end
end

--[[
function HDH_OptionFrame_ShowAni(self)
	if not self.ag then
		self.ag = self:CreateAnimationGroup()
		local ag = self.ag 
		ag.ap = ag:CreateAnimation("Alpha")
		ag.ap:SetOrder(1)
		ag.ap:SetDuration(0.1)
		ag.ap:SetSmoothing("OUT") 
		--ag.tl = ag:CreateAnimation("Translation")
		--ag.tl:SetOrder(1)
		--ag.tl:SetDuration(0.2)
		--ag.tl:SetSmoothing("OUT")  
	end
	
	if not self:IsShown() then
		self.ag.ap:SetFromAlpha(0)
		self.ag.ap:SetToAlpha(1) 
		--self.ag.tl:SetOffset(0,0)
		self.ag:SetScript("OnFinished",function()
			end) 
		self:Show()
		self.ag:Play()
	else
		self.ag:Stop()
		self:Show()
	end
	
end

function HDH_OptionFrame_HideAni(self)
	if self.ag and self:IsShown() then
		self.ag.ap:SetFromAlpha(1)
		self.ag.ap:SetToAlpha(0)
		--self.ag.tl:SetOffset(30,0)
		self.ag:SetScript("OnFinished",function()
				self:Hide()
			end) 
		self.ag:Play()
	end
end]]

------------------------------------------
-- control DB
------------------------------------------

local function HDH_DB_SaveSpell(key, spec, no, id, name, always, texture, isItem, tabIdx)
	local tabname = HDH_AT_OP_GetTrackerInfo(tabIdx)
	local db = DB_AURA.Talent[spec][tabname]
	for i = 1 , #db do
		if tonumber(db[i].ID) ==  tonumber(id) and db[i].IsItem == isItem then return false end
	end
	
	db[tonumber(no)] = {}
	db[tonumber(no)].Key = tostring(key)
	db[tonumber(no)].No = no
	db[tonumber(no)].ID = id
	db[tonumber(no)].Name = name
	db[tonumber(no)].Always = always
	db[tonumber(no)].Texture = texture
	db[tonumber(no)].IsItem = isItem
	local t = HDH_TRACKER.Get(tabname)
	if t then t:InitIcons() end
	return true
end

local function HDH_DB_DelSpell(spec, no, tabIdx)
	local tabname = HDH_AT_OP_GetTrackerInfo(tabIdx)
	local db = DB_AURA.Talent[spec][tabname]
	local pointer = HDH_TRACKER.Get(tabname) and HDH_TRACKER.Get(tabname).pointer or nil
	if pointer and db[no] then 
		if pointer[db[no].Key or tostring(db[no].ID)] then 
			pointer[db[no].Key or tostring(db[no].ID)] = nil
		end
	end
	for i = tonumber(no), #db do
		db[i] = db[i+1]
		if db[i] then db[i].No = i end
	end
	local t = HDH_TRACKER.Get(tabname)
	if t then t:InitIcons() end
end

-------------------------------------------
-- control list
-------------------------------------------

local function HDH_SetRowData(rowFrame, key, no, id, name, always, texture, isItem)
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(texture)
	_G[rowFrame:GetName().."ButtonIcon"]:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92);
	_G[rowFrame:GetName().."TextNum"]:SetText(no)
	_G[rowFrame:GetName().."TextName"]:SetText(name)
	_G[rowFrame:GetName().."TextID"]:SetText(id.."")
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(always)
	local tabname, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	_G[rowFrame:GetName().."EditBoxID"]:SetText(key or "")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(isItem)
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Del")
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
	_G[rowFrame:GetName().."RowDesc"]:Hide()
end

local function HDH_ClearRowData(rowFrame)
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(nil)
	_G[rowFrame:GetName().."TextNum"]:SetText(nil)
	_G[rowFrame:GetName().."TextName"]:SetText(nil)
	_G[rowFrame:GetName().."RowDesc"]:Show()
	_G[rowFrame:GetName().."TextID"]:SetText(nil)
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(true)
	local tabname, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	_G[rowFrame:GetName().."EditBoxID"]:SetText("")
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Add")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(false)
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
end

local function HDH_DelRow(rowFrame)
	local no = rowFrame:GetAttribute("no")
	HDH_DB_DelSpell(CurSpec, no, GetTrackerIndex())
	HDH_LoadTrackerListFrame(GetTrackerIndex(), no)
end

local function HDH_GetRowFrame(listFrame, index, flag)
	if not listFrame.row then listFrame.row = {} end
	index = tonumber(index)
	if not listFrame.row[index] and flag == FLAG_ROW_CREATE then
		listFrame.row[index] = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "RowTemplate")
		
		local f = listFrame.row[index]
		if index == 1 then f:SetPoint("TOPLEFT",listFrame,"TOPLEFT")
					  else f:SetPoint("TOPLEFT",listFrame.row[index-1],"BOTTOMLEFT") end
		f:SetWidth(listFrame:GetParent():GetWidth())
		f:SetAttribute("no", index)
		f:Hide() -- 기본이 hide 중요!
	end
	
	return listFrame.row[index] 
end

function HDH_LoadTrackerListFrame(trackerIdx, startRowIdx, endRowIdx)
	local listFrame = ListFrame
	local aura = {}
	local tracker_name,unit = HDH_AT_OP_GetTrackerInfo(trackerIdx or 1)
	if not DB_AURA.Talent[CurSpec] then return end
	aura = DB_AURA.Talent[CurSpec][tracker_name]
	local rowFrame
	local i = startRowIdx or 1
	if DB_OPTION[tracker_name] and HDH_IS_UNIT[unit] and DB_OPTION[tracker_name].tracking_all then
		HDH_AT_NoList:Show()
	-- elseif DB_OPTION[tracker_name] and DB_OPTION[tracker_name].boss_debuff then
		--HDH_AT_NoList_Boss:Show();
		-- HDH_AT_NoList:Hide();
		listFrame:SetSize(listFrame:GetParent():GetWidth(), ROW_HEIGHT);
	else
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = HDH_GetRowFrame(listFrame, i, FLAG_ROW_CREATE)-- row가 없으면 생성하고, 있으면 그거 재활용
			if not rowFrame:IsShown() then rowFrame:Show() end
			if aura and aura[i] then
				HDH_SetRowData(rowFrame, aura[i].Key, aura[i].No, aura[i].ID, aura[i].Name, aura[i].Always, aura[i].Texture, aura[i].IsItem)
			else-- add 를 위한 공백 row 지정
				HDH_ClearRowData(rowFrame)
				listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
				break
			end
			if endRowIdx and endRowIdx == i then return end
			i = i + 1
		end
		HDH_AT_NoList:Hide();
		--HDH_AT_NoList_Boss:Hide();
		i = i + 1 -- edd 를 위한인덱스
	end
	
	while true do -- 불필요한 row 안보이게 
		rowFrame = HDH_GetRowFrame(listFrame, i, nil) -- 불필요한 row가 있다면
		if rowFrame then HDH_ClearRowData(rowFrame) 
						 rowFrame:Hide() 
					else break end
		i = i + 1
	end
end

local function HDH_AddRow(rowFrame)
	local listFrame = rowFrame:GetParent()
	local no = rowFrame:GetAttribute("no")
	local key = _G[rowFrame:GetName().."EditBoxID"]:GetText()
	local always = _G[rowFrame:GetName().."CheckButtonAlways"]:GetChecked()
	--local glow = _G[rowFrame:GetName().."CheckButtonGlow"]:GetChecked()
	--local showValue = _G[rowFrame:GetName().."CheckButtonShowValue"]:GetChecked()
	local item = _G[rowFrame:GetName().."CheckButtonIsItem"]:GetChecked()
	local name, id, icon, isItem = HDH_GetInfo(key, item)
	
	if name then
		if not HDH_DB_SaveSpell(key, CurSpec, no, id, name, always, icon, isItem, GetTrackerIndex()) then
			HDH_OP_AlertDlgShow(name.."("..id..") 은(는) 이미 등록된 주문입니다.")
			return nil
		end
		if isItem then
			local tabname, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
			if HDH_IS_UNIT[unit] then
				HDH_OP_AlertDlgShow("오라 추척에 아이템을 등록하였습니다.\n아이템을 사용(발동) 했을 때, 발생되는\n|cffff0000버프(디버프)의 주문 ID로 등록|r하길 바랍니다.");
			end
		end
		HDH_SetRowData(rowFrame, key, no, id, name, always,  icon, isItem)
	else
		HDH_OP_AlertDlgShow(key.." 은(는) 알 수 없는 주문 입니다.")
		return nil
	end
	return no
end

------------------------------------------
-- profile
------------------------------------------

function HDH_OnShow_ProfileFrame(self)
	local dataTable = {}
	if DB_PROFILE then
		for k,v in pairs(DB_PROFILE) do
			dataTable[#dataTable+1] = k
		end
	end
	HDH_AT_LoadDropDownButton(SettingFrameUIBodyProfileDDMProfile, nil, dataTable, HDH_AT_OP_OnSelectedItem_DDM)
end 
function HDH_OnClick_SaveProfile()
	if not DB_PROFILE then
		DB_PROFILE = {}
	end
	local ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M:%S")..")"
	DB_PROFILE[ID_NAME] = {}
	DB_PROFILE[ID_NAME].OPTION = deepcopy(DB_OPTION)
	DB_PROFILE[ID_NAME].FRAME_LIST = deepcopy(DB_FRAME_LIST)
	DB_PROFILE[ID_NAME].ID_NAME = ID_NAME
	HDH_OnShow_ProfileFrame(SettingFrameUIBodyProfileDDMProfile)
end

function HDH_OnClick_LoadProfile()
	local name = UIDropDownMenu_GetSelectedValue(SettingFrameUIBodyProfileDDMProfile)
	if DB_PROFILE and DB_PROFILE[name] then
		DB_OPTION = deepcopy(DB_PROFILE[name].OPTION)
		DB_FRAME_LIST = deepcopy(DB_PROFILE[name].FRAME_LIST)
		DB_AURA = nil
		ReloadUI() 
	else
		HDH_OP_AlertDlgShow("프로필 정보를 찾을 수 없습니다.")
	end
end

function HDH_OnClick_DelProfile()
	local name = UIDropDownMenu_GetSelectedValue(SettingFrameUIBodyProfileDDMProfile)
	if not name then return end
	DB_PROFILE[name] = nil
	HDH_OnShow_ProfileFrame(SettingFrameUIBodyProfileDDMProfile)
end

------------------------------------------
-- control Tab : Spec
------------------------------------------

function HDH_LoadTabSpec()
	local spec = GetSpecialization()
	if spec then
		CurSpec = spec
	end
	if not TAB_TALENT then
		TAB_TALENT = {BtnTalent1, BtnTalent2, BtnTalent3, BtnTalent4}
		local id, name, desc, icon
		for i = 1 , MAX_TALENT_TABS do
			id, name, desc, icon = GetSpecializationInfo(i)
			if not id then 
				TAB_TALENT[i]:Hide() 
				break 
			end
			TAB_TALENT[i]:SetNormalTexture(icon)
		end
	end
	HDH_ChangeTalentTab(TAB_TALENT[CurSpec], CurSpec)
end

function HDH_ChangeTalentTab(self, spec)
	local id, name, desc, icon = GetSpecializationInfo(spec)
	if not id then return end
	CurSpec = spec
	for i=1,#DB_AURA.Talent do
		local btn = TAB_TALENT[i]
		if i ~= id then
			btn:SetChecked(false) 
			btn:GetNormalTexture():SetDesaturated(1)
		end
	end
	self:GetNormalTexture():SetDesaturated(nil)
	_G["TalentIcon"]:SetTexture(icon)
	--_G["TalentIcon"]:SetRotation(math.pi/180*180)
	_G["TalentText"]:SetText(name)
	HDH_AT_OP_UpdateTitle();
	self:SetChecked(true)
	if (g_CurMode == BODY_TYPE.AURA) then
		HDH_AT_OP_ChangeBody(g_CurMode, GetTrackerIndex());
	end
end

------------------------------------------
-- control Tracker List
------------------------------------------

function HDH_AT_OP_AddTrackerButton(name, unit, idx)
	local listFrame = TRACKER_LIST_FRAME;
	local count = TRACKER_TAB_BTN_LIST.count or 0;
	local newButton;
	if not name or not unit then return; end
	if idx and TRACKER_TAB_BTN_LIST[idx] then
		newButton = TRACKER_TAB_BTN_LIST[idx];
	elseif not idx and TRACKER_TAB_BTN_LIST[count+1] then
		count = count + 1;
		newButton = TRACKER_TAB_BTN_LIST[count];
		listFrame:SetSize(listFrame:GetParent():GetWidth(), (count+1) * newButton:GetHeight()); -- 추가버튼 공간까지 +1
	else
		newButton = CreateFrame("BUTTON", listFrame:GetName().."BtnTracker"..(count+1), listFrame, "HDH_AT_RowTapBtnTemplate");
		if (count == 0) then
			newButton:SetPoint("TOPLEFT",listFrame,"TOPLEFT");
		else
			newButton:SetPoint("TOPLEFT",TRACKER_TAB_BTN_LIST[count],"BOTTOMLEFT");
		end
		newButton:SetScript("OnClick", HDH_AT_OP_OnChangeTracker);
		newButton:SetWidth(listFrame:GetParent():GetWidth());
		_G[newButton:GetName().."Text"]:SetPoint("LEFT",newButton,"LEFT", 10, 0);
		_G[newButton:GetName().."Text"]:SetPoint("RIGHT",newButton,"RIGHT", -10, 0);
		_G[newButton:GetName().."Text"]:SetJustifyH("RIGHT");
		count = count + 1;
		newButton.idx = count;
		TRACKER_TAB_BTN_LIST[count] = newButton;
		listFrame:SetSize(listFrame:GetParent():GetWidth(), (count+1) * newButton:GetHeight()); -- 추가버튼 공간까지 +1
	end
	newButton:Show();
	newButton:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,unit));
	newButton.name = name;
	newButton.unit = unit;
	
	--TRACKER_TAB_BTN_LIST.Body[count] = UnitOptionFrame;
	TRACKER_TAB_BTN_LIST.count = count;
	
	return count;
end

function HDH_AT_OP_OnClickAddTracker(self)
	HDH_AT_OP_ChangeBody(BODY_TYPE.CREATE_TRACKER);
	HDH_AT_OP_UpdateTitle();
end

function HDH_AT_OP_RemoveTracker()
	local idx = GetTrackerIndex();
	local name = HDH_AT_OP_GetTrackerInfo(idx);
	if not name then return; end
	local list = TRACKER_TAB_BTN_LIST;
	if (not list.count or list.count == 0) then return; end
	
	for i = idx , #list-1 do
		list[i].name = list[i+1].name;
		list[i].unit = list[i+1].unit;
		list[i]:SetText(string.format(STR_TRACKER_BTN_FORMAT, list[i].name, list[i].unit));
	end
	
	list[list.count]:Hide();
	list.count = list.count - 1;
	TRACKER_LIST_FRAME:SetHeight(TRACKER_LIST_FRAME:GetHeight() - list[0]:GetHeight());
	HDH_TRACKER.RemoveList(name);
	HDH_AT_OP_ChangeTracker(idx-1);
	HDH_RefreshFrameLevel_All()
end

function HDH_AT_OP_ExchangeTrackerPriority(idx1, idx2) 
	local list = TRACKER_TAB_BTN_LIST;
	local max = #list or 0;
	if (idx1 ~= idx2) and (0 < idx1 and idx1 <= max) and (0 < idx2 and idx2 <= max) then
		local tmp = list[idx1].name;
		list[idx1].name = list[idx2].name;
		list[idx2].name = tmp;
		
		tmp = list[idx1].unit;
		list[idx1].unit = list[idx2].unit;
		list[idx2].unit = tmp;
		
		list[idx1]:SetText(string.format(STR_TRACKER_BTN_FORMAT,list[idx1].name, list[idx1].unit));
		list[idx2]:SetText(string.format(STR_TRACKER_BTN_FORMAT,list[idx2].name,list[idx2].unit));
		tmp = DB_FRAME_LIST[idx1] 
		DB_FRAME_LIST[idx1] = DB_FRAME_LIST[idx2]
		DB_FRAME_LIST[idx2] = tmp
		
		tmp = nil
		HDH_RefreshFrameLevel_All()
		AddTrackerFrameTextTrackerOrder:SetText(idx2);
		return true
	end
	return false
end

function HDH_AT_OP_ChangeTracker(idx) 
	if not HDH_AT_OP_GetTrackerInfo(idx) then
		g_CurMode = BODY_TYPE.CREATE_TRACKER;
	else
		if g_CurMode == BODY_TYPE.CREATE_TRACKER then
			g_CurMode = BODY_TYPE.EDIT_TRACKER;
		end
	end
	Match_Tracker_DBForFrame(idx);
	HDH_AT_OP_ChangeBody(g_CurMode, idx);
	HDH_AT_OP_UpdateTitle();
end

function HDH_AT_OP_OnChangeTracker(self) -- script 펑션은 후킹이 안됨
	HDH_AT_OP_ChangeTracker(self.idx) -- hooking 가능 하도록
end

function HDH_OnClickCreateAndModifyTracker(self)
	local mode = self:GetParent().mode
	local ddm = _G[self:GetParent():GetName().."DDMUnitList"]
	local ed = _G[self:GetParent():GetName().."EditBoxName"]
	local err = _G[self:GetParent():GetName().."TextE"]
	local name = trim(ed:GetText())
	local unit = HDH_TRACKER_LIST[ddm.id]
	ed:SetText(name)
	if name ~= "" and unit then
		if mode == "add" then
			local tracker = HDH_TRACKER.Get(name)
			if not tracker then
				tracker = HDH_TRACKER.new(name, unit)
				HDH_DB_Add_FRAME_LIST(name, unit)
				g_CurMode = BODY_TYPE.AURA;
				local idx = HDH_AT_OP_AddTrackerButton(name, unit);
				Match_Tracker_DBForFrame(idx);
				UpdateFrameDB_CB(F_OP_CB_TRACKER_ALL_AURA, F_OP_CB_TRACKER_ALL_AURA:GetChecked());
				UpdateFrameDB_CB(F_OP_CB_TRACKER_BUFF, F_OP_CB_TRACKER_BUFF:GetChecked());
				UpdateFrameDB_CB(F_OP_CB_TRACKER_MINE, F_OP_CB_TRACKER_MINE:GetChecked());
				HDH_AT_OP_ChangeTracker(idx);
				if UI_LOCK then
					tracker:SetMove(true)
					tracker:CreateDummySpell(HDH_TRACKER.MAX_ICONS_COUNT)
					tracker.frame:Show()
					tracker:UpdateIcons()
				end
				if DB_OPTION[name].tracking_all then
					tracker:InitIcons()
				end
			else
				HDH_OP_AlertDlgShow(name.." 은(는) 이미 존재하는 이름입니다.")
				return
			end
		elseif mode =="modify" then
			local curName, curUnit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
			local tracker = HDH_TRACKER.Get(curName);
			if not tracker then return end
			local isExist = HDH_TRACKER.Get(name) and true or false;
			if isExist and (name ~= curName) then -- 존재하는 이름인데, 현재 이름과 다르면, 이름을 수정하는 상태임
				ed:SetText(curName)
				HDH_OP_AlertDlgShow(name.." 은(는) 이미 존재하는 이름입니다.")
				return
			else 
				if (curName ~= name) or (unit ~= curUnit) then
					tracker:Modify(name, unit);
					HDH_AT_OP_UpdateTitle();
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()].name = name;
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()].unit = unit;
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()]:SetText(format("%s\r\n|cffaaaaaa%s",name,unit));
				end
				UpdateFrameDB_CB(F_OP_CB_TRACKER_ALL_AURA, F_OP_CB_TRACKER_ALL_AURA:GetChecked());
				UpdateFrameDB_CB(F_OP_CB_TRACKER_BUFF, F_OP_CB_TRACKER_BUFF:GetChecked());
				--F_OP_CB_TRACKER_DEBUFF:SetChecked(!F_OP_CB_TRACKER_BUFF:GetChecked());
				UpdateFrameDB_CB(F_OP_CB_TRACKER_MINE, F_OP_CB_TRACKER_MINE:GetChecked());
				--self:GetParent():Hide()
				if UI_LOCK then tracker:SetMove(UI_LOCK);
				           else tracker:InitIcons(); end
			end
		end
	else
		if ddm.id == 0 then
			HDH_OP_AlertDlgShow("추적 대상을 선택해주세요.")
			return
		end
		
		if mode == "modify" then ed:SetText(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())) end
		HDH_OP_AlertDlgShow("이름을 입력해주세요.")
		return
	end
	HDH_RefreshFrameLevel_All()
end

function HDH_CopyAuraList(srcSpec, srcName, dstName)
	if not srcName or not dstName then return end
	if (srcSpec == CurSpec) and (srcName == dstName) then return end
	
	DB_AURA.Talent[CurSpec][dstName] = deepcopy(DB_AURA.Talent[srcSpec][srcName])
	local t = HDH_TRACKER.Get(dstName)
	if t then t:InitIcons() end
end

function HDH_OnClickCopyAura(self)
	local name = UIDropDownMenu_GetSelectedValue(AddTrackerFrameDDMTabList)
	local spec = AddTrackerFrameDDMSpecList.id;
	if not name or not HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()) or not spec or spec == 0 then 
		HDH_OP_AlertDlgShow("특성과 추적 창 목록을 선택해주세요.")
		return 
	end
	HDH_OP_AlertDlgShow("현재 추적 창의 오라 목록을 '"..name.."'의 목록으로\n|cffffffff교체 하시겠습니까?\n|cffff0000(기존 목록은 삭제 됩니다)", 
				  HDH_CopyAuraList, 
				  spec, name, HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()));
end

function HDH_OnClickMoveUpTrackerPriority(self) -- up
	if HDH_AT_OP_ExchangeTrackerPriority(GetTrackerIndex(), GetTrackerIndex()-1) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, GetTrackerIndex() - 1);
	end
end

function HDH_OnClickMoveDownTrackerPriority(self) -- down
	if HDH_AT_OP_ExchangeTrackerPriority(GetTrackerIndex(), GetTrackerIndex()+1) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, GetTrackerIndex() + 1);
	end
end

------------------------------------------
-- ColorPicker 
------------------------------------------

function HDH_AT_OP_ShowColorPicker(self, isAlpha)
	isAlpha = isAlpha and true or false;
	if ColorPickerFrame:IsShown() then return end
	ColorPickerFrame.colorButton = self
	local r, g, b, a = GetFrameDB_CP(self);
	if isAlpha then
		ColorPickerFrame.opacity = a
		OpacitySliderFrame:SetValue(a)
	end
	ColorPickerFrame.previousValues = {r, g, b, a};
	ColorPickerFrame.hasOpacity = isAlpha;
	ColorPickerFrame.func = HDH_OnSelectedColor;
	ColorPickerFrame.opacityFunc = HDH_OnSelectedColor;
	ColorPickerFrame.cancelFunc = HDH_OnSelectColorCancel;
	ColorPickerFrame:SetColorRGB(r, g, b);
	ColorPickerFrame:Show();
end

------------------------------------------
-- control UI 
------------------------------------------

function HDH_AT_OP_LoadSetting(curTracker)
	Match_Basic_DBForFrame();
	Match_FontIcon_DBForFrame(curTracker);
	--Match_Tracker_DBForFrame_DBForFrame();
	
	UpdateFrameDB_CB(F_OP_CB_EACH);
	UpdateFrameDB_CB(F_OP_CB_SHOW_ID);
	F_OP_CB_MOVE:SetChecked(UI_LOCK);
	
	UpdateFrameDB_SL(F_OP_SL_ICON_SIZE, nil, 20, 400);
	UpdateFrameDB_SL(F_OP_SL_MARGIN_H, nil, 1, 100);
	UpdateFrameDB_SL(F_OP_SL_MARGIN_V, nil, 1, 100);
	UpdateFrameDB_SL(F_OP_SL_ON_ALPHA, nil, nil, nil, 100);
	UpdateFrameDB_SL(F_OP_SL_OFF_ALPHA, nil, nil, nil, 100);
	UpdateFrameDB_CB(F_OP_CB_COLOR_DEBUFF_DEFAULT);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_BUFF);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_DEBUFF);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_CD_BG);
	
	--HDH_AT_OP_LoadFontSetting(curTracker);
	UpdateFrameDB_CB(F_OP_CB_SHOW_CD);
	UpdateFrameDB_CB(F_OP_CB_ALWAYS_SHOW);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_FONT_CD5);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_FONT1);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_FONT2);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_FONT3);
	UpdateFrameDB_CP(F_OP_BTN_COLOR_FONT4);
	UpdateFrameDB_DDM(F_OP_DDM_FONT_LOC1, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(F_OP_DDM_FONT_LOC2, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(F_OP_DDM_FONT_LOC3, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(F_OP_DDM_FONT_LOC4, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_SL(F_OP_SL_FONT_SIZE1, nil, 12, 32);
	UpdateFrameDB_SL(F_OP_SL_FONT_SIZE2, nil, 12, 32);
	UpdateFrameDB_SL(F_OP_SL_FONT_SIZE3, nil, 12, 32);
	UpdateFrameDB_SL(F_OP_SL_FONT_SIZE4, nil, 12, 32);
	
	if ( not curTracker ) then
		F_OP_CB_EACH:SetChecked(false);
		F_OP_CB_EACH:Disable();
	else
		F_OP_CB_EACH:Enable();
	end
	
	local unit = select(2,HDH_AT_OP_GetTrackerInfo(curTracker))
	if not curTracker or string.find(unit, "cooldown") then
		UpdateFrameDB_SL(F_OP_SL_CT_MAXTIME, nil, 0, 3000);
		UpdateFrameDB_CB(F_OP_CB_CT_DESAT);
		UpdateFrameDB_CP(F_OP_CP_CT_COLOR);
		F_OP_SL_CT_MAXTIME:Show();
		F_OP_CB_CT_DESAT:Show();
		F_OP_CP_CT_COLOR:Show();
	else
		F_OP_SL_CT_MAXTIME:Hide();
		F_OP_CB_CT_DESAT:Hide();
		F_OP_CP_CT_COLOR:Hide();
	end
end

function HDH_AT_OP_LoadTrackerBasicSetting(curTracker)	
	UpdateFrameDB_CB(F_OP_CB_REVERS_H);
	UpdateFrameDB_CB(F_OP_CB_REVERS_V);
	UpdateFrameDB_CB(F_OP_CB_ICON_FIX);
	UpdateFrameDB_SL(F_OP_SL_LINE);
	UpdateFrameDB_CB(F_OP_CB_SHOW_TOOLTIP);
	UpdateFrameDB_DDM(F_OP_DDM_CD_TYPE, DDM_COOLDOWN_LIST);
	UpdateFrameDB_CB(F_OP_CB_TRACKER_ENABLE);
end

function HDH_AT_OP_OnChangeBody(self, body_type)
	HDH_AT_OP_ChangeBody(body_type, GetTrackerIndex());
end

function HDH_AT_OP_ChangeBody(bodyType, trackerIdx) -- type tracker, aura, ui
	local idx = HDH_AT_OP_GetTrackerInfo(trackerIdx) and trackerIdx;
	if (bodyType == BODY_TYPE.AURA and not idx) then
		bodyType = BODY_TYPE.CREATE_TRACKER;
	end
	g_CurMode = bodyType;
	if (bodyType == BODY_TYPE.CREATE_TRACKER) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, BODY_TYPE.CREATE_TRACKER);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, BODY_TYPE.EDIT_TRACKER); -- tab frame 로딩
		HDH_AT_OP_LoadCreateTrackerFrame();                    -- 데이터 로딩
		AddTrackerFrameTextTrackerOrder:SetText((TRACKER_TAB_BTN_LIST.count or 0) +1);
		RowDetailSetFrame:Hide();
	elseif (bodyType == BODY_TYPE.EDIT_TRACKER) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_LoadCreateTrackerFrame(idx);                 -- 데이터 로딩
		AddTrackerFrameTextTrackerOrder:SetText(idx);
		RowDetailSetFrame:Hide();
	elseif (bodyType == BODY_TYPE.AURA) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_LoadAuraListFrame(idx);                      -- 데이터 로딩
		RowDetailSetFrame:Hide();
	elseif (bodyType == BODY_TYPE.UI) then 
		if idx then
			HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		end
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_ChangeTapState(UI_TAB_BTN_LIST, UI_TAB_BTN_LIST.CurIdx);
		HDH_AT_OP_LoadSetting(idx); 				   -- 데이터 로딩
		RowDetailSetFrame:Hide();
	elseif (bodyType == BODY_TYPE.AURA_DETAIL) then
	
	end
end

function HDH_AT_OP_UpdateTitle()
	local name, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	local w = TalentText:GetStringWidth()
	OptionFrameTitleFrameTextTracker:SetPoint("LEFT",TalentText, "LEFT", w+5, 0)
	
	if name then
		OptionFrameTitleFrameTextTracker:SetText("> "..name)
		OptionFrameTitleFrameTextUnit:SetText(("(%s)"):format(unit:gsub("^%l", string.upper)))
		w = OptionFrameTitleFrameTextTracker:GetStringWidth()
		OptionFrameTitleFrameTextUnit:SetPoint("LEFT",OptionFrameTitleFrameTextTracker, "LEFT", w+5, 0)
	else
		OptionFrameTitleFrameTextUnit:SetText("");
		OptionFrameTitleFrameTextTracker:SetText("> New Tracker");
	end
end

function HDH_AT_OP_LoadAuraListFrame(trackerIdx)
	local name, unit = HDH_AT_OP_GetTrackerInfo(trackerIdx);
	if name then
		HDH_LoadTrackerListFrame(trackerIdx);
		Match_Tracker_DBForFrame(trackerIdx);
		HDH_AT_OP_LoadTrackerBasicSetting(trackerIdx);
		if F_OP_CB_TRACKER_ENABLE:GetChecked() then
			UnitOptionFrameSFContents:Show();
			HDH_AT_Disable:Hide();
		else
			UnitOptionFrameSFContents:Hide();
			HDH_AT_Disable:Show();
		end
		--UnitOptionFrameTabModify:SetPoint("LEFT",UnitOptionFrameTextTitle2,"LEFT",UnitOptionFrameTextTitle2:GetStringWidth()+10,0)
	end
end

function HDH_AT_OP_LoadCreateTrackerFrame(trackerIdx)
	if trackerIdx then -- 인덱스가 있으면 수정모드
		local name, unit = HDH_AT_OP_GetTrackerInfo(trackerIdx)
		if not name then return; end
		_G[AddTrackerFrame:GetName().."EditBoxName"]:SetText(name)
		UpdateFrameDB_DDM(F_OP_DDM_UNIT_LIST, HDH_TRACKER_LIST);
		--DDM_LoadUnitList(ddm_idx)
		--DDM_LoadTabList()
		--DDB_LoadSpecList()
		AddTrackerFrame.mode = "modify"
		AddTrackerFrameText1:SetText("추적 창 수정")
		AddTrackerFrameButtonCreateAndModifyTracker:SetText("적용")
		AddTrackerFrameButtonDeleteUnit:Enable()
		if HDH_IS_UNIT[unit] then
			UpdateFrameDB_CB(F_OP_CB_TRACKER_ALL_AURA);
			UpdateFrameDB_CB(F_OP_CB_TRACKER_BUFF);
			F_OP_CB_TRACKER_DEBUFF:SetChecked(not F_OP_CB_TRACKER_BUFF:GetChecked());
			UpdateFrameDB_CB(F_OP_CB_TRACKER_MINE);
			F_OP_CB_TRACKER_ALL_AURA:Show();
			F_OP_CB_TRACKER_DEBUFF:Show();
			F_OP_CB_TRACKER_BUFF:Show();
			F_OP_CB_TRACKER_MINE:Show();
		else
			F_OP_CB_TRACKER_ALL_AURA:Hide();
			F_OP_CB_TRACKER_DEBUFF:Hide();
			F_OP_CB_TRACKER_BUFF:Hide();
			F_OP_CB_TRACKER_MINE:Hide();
		end
		AddTrackerFrameButtonMoveLeft:Enable()
		AddTrackerFrameButtonMoveRight:Enable()
		UIDropDownMenu_EnableDropDown(AddTrackerFrameDDMSpecList)
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMTabList)
		AddTrackerFrameButtonCopy:Enable()
		AddTrackerFrameTextE:SetText(nil)
		
		
	else
		HDH_AT_LoadDropDownButton(F_OP_DDM_UNIT_LIST, nil, HDH_TRACKER_LIST);
		--DDM_LoadUnitList(1)
		--DDM_LoadTabList()
		--DDB_LoadSpecList()
		AddTrackerFrame.mode = "add"
		AddTrackerFrameText1:SetText("추적 창 추가")
		AddTrackerFrameButtonCreateAndModifyTracker:SetText("추가")
		AddTrackerFrameButtonDeleteUnit:Disable()
		AddTrackerFrameButtonMoveLeft:Disable()
		AddTrackerFrameButtonMoveRight:Disable()
		F_OP_CB_TRACKER_ALL_AURA:SetChecked(false);
		F_OP_CB_TRACKER_DEBUFF:SetChecked(false);
		F_OP_CB_TRACKER_BUFF:SetChecked(true);
		F_OP_CB_TRACKER_MINE:SetChecked(false);
		F_OP_CB_TRACKER_ALL_AURA:Show();
		F_OP_CB_TRACKER_DEBUFF:Show();
		F_OP_CB_TRACKER_BUFF:Show();
		F_OP_CB_TRACKER_MINE:Show();
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMSpecList)
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMTabList)
		AddTrackerFrameButtonCopy:Disable()
		AddTrackerFrameTextE:SetText(nil)
		AddTrackerFrame:Show()
		AddTrackerFrameEditBoxName:SetText("")
	end
	
	local items = {}
	for i= 1, #DB_AURA.Talent do
		items[i] = DB_AURA.Talent[i].Name
	end
	HDH_AT_LoadDropDownButton(F_OP_DDM_TALENT_LIST, nil, items)
	
	items ={}
	for i = 1, #DB_FRAME_LIST do
		items[i] = DB_FRAME_LIST[i].name
	end
	HDH_AT_LoadDropDownButton(F_OP_DDM_TRACKER_LIST, nil, items)
end

function HDH_AT_OP_OnChangeUISetting(self, idx, value)
	--if idx == UI_TYPE.FONT and value then
	--	HDH_AT_OP_LoadFontSetting(value);
	--end
	HDH_AT_OP_ChangeTapState(UI_TAB_BTN_LIST, idx);
end

------------------------------------------
-- Call back function
------------------------------------------

function HDH_AT_OP_OnValueChanged(self, value, userInput)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not name then return end
	value = math.floor(value)
	if (self == F_OP_SL_FONT_SIZE1) or (self == F_OP_SL_FONT_SIZE2) or (self == F_OP_SL_FONT_SIZE3) or (self == F_OP_SL_FONT_SIZE4)then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == F_OP_SL_ICON_SIZE then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then
				t:UpdateSetting()
				if UI_LOCK then t:SetMove(UI_LOCK)
						   else t:Update() end
			end
		else
			HDH_TRACKER.UpdateSettingAll()
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:Update()
			end
		end
	elseif (self == F_OP_SL_ON_ALPHA) or (self == F_OP_SL_OFF_ALPHA) then
		UpdateFrameDB_SL(self, value/100);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif (self == F_OP_SL_LINE) then
		UpdateFrameDB_SL(self, value);
		local t = HDH_TRACKER.Get(name)
		if t then 
			if UI_LOCK then t:SetMove(UI_LOCK)
					   else t:Update() end
		end		
	elseif (self == F_OP_SL_MARGIN_H) or (self == F_OP_SL_MARGIN_V) then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then
				t:UpdateSetting()
				if UI_LOCK then t:SetMove(UI_LOCK)
						   else t:Update() end
			end
		else
			HDH_TRACKER.UpdateSettingAll()
			if UI_LOCK then
				HDH_TRACKER.SetMoveAll(UI_LOCK)
			else
				for k,tracker in pairs(HDH_TRACKER.GetList()) do
					tracker:Update()
				end
			end
		end
	elseif (self == F_OP_SL_CT_MAXTIME) then
		UpdateFrameDB_SL(F_OP_SL_CT_MAXTIME, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name);
			if t then 
				if UI_LOCK then
					t:SetMove(UI_LOCK)
				else
					t:Update()
				end
			end
		else
			if UI_LOCK then
				HDH_TRACKER.SetMoveAll(UI_LOCK)
			else
				for k,tracker in pairs(HDH_TRACKER.GetList()) do
					if string.find(tracker.unit, "cooldown") then
						tracker:Update()
					end
				end
			end
		end
	end
end

function HDH_Adjust_Slider(self, value, min, max)
	local value = math.floor(value or self:GetValue())
	if min > value then value = min end
	if max < value then value = max end
	
	local newMin = value-20
	local newMax = value+20
	
	if newMin <= min then newMin = min end
	if newMax >= max then newMax = max end
	self:SetMinMaxValues(newMin, newMax)
	self:SetValue(value)
	getglobal(self:GetName() .. 'Low'):SetText(select(1,self:GetMinMaxValues()));
	getglobal(self:GetName() .. 'High'):SetText(select(2,self:GetMinMaxValues()));
end
								
function HDH_OnSettingReset(panel_type)
	if panel_type =="UI" then
		DB_OPTION = nil
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.UpdateSettingAll()
		HDH_TRACKER.SetMoveAll(false)
		HDH_AT_OP_LoadSetting(GetTrackerIndex())
	else
		DB_AURA = nil
		DB_FRAME_LIST = nil
		ReloadUI()
	end
end

local tmp_id
local tmp_chk
function HDH_OnEditFocusGained(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	local chk = _G[self:GetParent():GetName().."CheckButtonIsItem"]
	if btn:GetText() == "Del" then
		btn:SetText("Modify")
		tmp_id = self:GetText()
		tmp_chk = chk:GetChecked()
	end
	--self:SetWidth(EDIT_WIDTH_L)
end

function HDH_OnEditFocusLost(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	if btn:GetText() == "Modify" then
		btn:SetText("Del")
		tmp_id = nil
		tmp_chk = false
	end
	self:Hide()
end

function HDH_OnEditEscape(self)
	_G[self:GetParent():GetName().."CheckButtonIsItem"]:SetChecked(tmp_chk)
	self:SetText(tmp_id or "")
	self:ClearFocus()
end

function HDH_OnEnterPressed(self)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local str = HDH_trim(self:GetText()) or ""
	self:SetText(str)
	if tonumber(self:GetText()) and string.len(self:GetText()) > 7 then 
		HDH_OP_AlertDlgShow(self:GetText().." 은(는) 알 수 없는 주문입니다.")
		return
	end
	if string.len(self:GetText()) > 0 then
		local ret = HDH_AddRow(self:GetParent()) -- 성공 하면 no 리턴
		if ret then 
			-- add 에 성공 했을 경우 다음 add 를 위해 가장 아래 공백 row 를 생성해야한다
			local listFrame = self:GetParent():GetParent()
			if ret == #(DB_AURA.Talent[CurSpec][name]) then
				local rowFrame = HDH_GetRowFrame(listFrame, ret+1, FLAG_ROW_CREATE)
				HDH_ClearRowData(rowFrame)
				rowFrame:Show() 
			end
		else
			self:SetText("") 
		end
	else
		HDH_OP_AlertDlgShow("주문 ID/이름을 입력해주세요.")
	end
end

function HDH_OnClickBtnAddAndDel(self, row)
	local edBox= _G[self:GetParent():GetName().."EditBoxID"]
	if self:GetText() == "Add" or self:GetText() == "Modify" then
		HDH_OnEnterPressed(edBox)
	else
		local text = _G[self:GetParent():GetName().."TextName"]:GetText()
		if text then
			HDH_DelRow(self:GetParent())
		end
	end
end

function HDH_OnClickBtnUp(self, row)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local aura = DB_AURA.Talent[CurSpec][name]
	row = tonumber(row)
	if aura[row] and aura[row-1] then
		local tmp_no = aura[row].No
		aura[row].No = aura[row-1].No
		aura[row-1].No = tmp_no
		local tmp = aura[row]
		aura[row] = aura[row-1]
		aura[row-1] = tmp
		--HDH_LoadTrackerListFrame(CurUnit, row-1, row)
		
		local f1 = HDH_GetRowFrame(ListFrame, row)
		local f2 = HDH_GetRowFrame(ListFrame, row-1)
		CrateAni(f1)
		CrateAni(f2)
		f2.ani.func = HDH_LoadTrackerListFrame
		f2.ani.args = {GetTrackerIndex(), row-1, row}
		StartAni(f1, ANI_MOVE_UP)
		StartAni(f2 , ANI_MOVE_DOWN)
	end
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnClickBtnDown(self, row)
	row = tonumber(row)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local aura = DB_AURA.Talent[CurSpec][name]
	if aura[row] and aura[row+1] then
		local tmp_no = aura[row].No
		aura[row].No = aura[row+1].No
		aura[row+1].No = tmp_no
		local tmp = aura[row]
		aura[row]= aura[row+1]
		aura[row+1] = tmp
		
		local f1 = HDH_GetRowFrame(ListFrame, row)
		local f2 = HDH_GetRowFrame(ListFrame, row+1)
		CrateAni(f1)
		CrateAni(f2)
		f2.ani.func = HDH_LoadTrackerListFrame
		f2.ani.args = {GetTrackerIndex(), row, row+1}
		StartAni(f1, ANI_MOVE_DOWN)
		StartAni(f2 , ANI_MOVE_UP)
		--HDH_LoadTrackerListFrame(CurUnit, row, row+1)
	end
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnSelectedColor()
	local r,g,b = ColorPickerFrame:GetColorRGB();
	UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b, ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue());
	UpdateFrameDB_CP(ColorPickerFrame.colorButton);
	--ColorPickerFrame.colorButton = nil;
	if HDH_AT_OP_IsEachSetting() then
		local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
		if not tracker then return end
		tracker:UpdateSetting()
		if UI_LOCK then
			tracker:SetMove(UI_LOCK)
		else
			tracker:Update()
		end
	else
		HDH_TRACKER.UpdateSettingAll()
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:Update()
			end
		end
	end
end

function HDH_OnSelectColorCancel()
	local r,g,b,a = unpack(ColorPickerFrame.previousValues);
	a = (ColorPickerFrame.hasOpacity and a) or nil;
	UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b,a);
	UpdateFrameDB_CP(ColorPickerFrame.colorButton);
	ColorPickerFrame.colorButton = nil;
	if HDH_AT_OP_IsEachSetting() then
		local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
		if not tracker then return end
		tracker:UpdateSetting()
	else
		HDH_TRACKER.UpdateSettingAll()
	end
end

function HDH_AT_OP_IsEachSetting()
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	if name then
		return DB_OPTION[name].use_each;
	else
		return false;
	end
end

function HDH_OnAlways(unit, no, check)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Always = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_AT_OP_ChangeTapState(tablist, idx)
	local btn = tablist[tablist.CurIdx];
	local body = tablist.Body[tablist.CurIdx];
	
	if btn then -- off
		_G[btn:GetName().."BgLine2"]:Hide();
		_G[btn:GetName().."Text"]:SetTextColor(1,1,1);
		if body then body:Hide(); end
	end
	
	-- on
	idx = idx and idx or 0;
	btn = tablist[idx];
	body = tablist.Body[idx];
	if btn then
		_G[btn:GetName().."BgLine2"]:Show();
		_G[btn:GetName().."Text"]:SetTextColor(1,0.8,0);
		if body then body:Show(); end
		tablist.CurIdx = idx;
	end
end

function HDH_AT_OP_OnSelectedItem_DDM(self, btn, value, id)
	UIDropDownMenu_SetSelectedID(self, id);
	UIDropDownMenu_SetSelectedValue(self, value);
	self.value = value;
	self.id = id;
	if (self == F_OP_DDM_TALENT_LIST) then
		if id > 0 then
			UIDropDownMenu_EnableDropDown(F_OP_DDM_TRACKER_LIST)
		else
			UIDropDownMenu_DisableDropDown(F_OP_DDM_TRACKER_LIST)
		end
	elseif (self == F_OP_DDM_UNIT_LIST) then
		if HDH_IS_UNIT[value] then
			F_OP_CB_TRACKER_BUFF:Show();
			F_OP_CB_TRACKER_DEBUFF:Show();
			F_OP_CB_TRACKER_MINE:Show();
			F_OP_CB_TRACKER_ALL_AURA:Show();
		else
			F_OP_CB_TRACKER_BUFF:Hide();
			F_OP_CB_TRACKER_DEBUFF:Hide();
			F_OP_CB_TRACKER_MINE:Hide();
			F_OP_CB_TRACKER_ALL_AURA:Hide();
		end
		
		if value == "2차 자원" then
			F_OP_CB_TRACKER_MERGE_POWERICON:Show();
		else
			F_OP_CB_TRACKER_MERGE_POWERICON:Hide();
		end
	elseif (self == F_OP_DDM_CD_TYPE) then
		UpdateFrameDB_DDM(self, nil, id);
		local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()));
		if tracker then 
			tracker:UpdateSetting()
			if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK);
			else
				tracker:Update()
			end
		end
		
	elseif (self == F_OP_DDM_FONT_LOC1) or (self == F_OP_DDM_FONT_LOC2) or (self == F_OP_DDM_FONT_LOC3) or (self == F_OP_DDM_FONT_LOC4)then
		UpdateFrameDB_DDM(self, nil, id);
		if HDH_AT_OP_IsEachSetting() then
			local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
			local t = HDH_TRACKER.Get(name)
			if t then 
				t:UpdateSetting() 
				if UI_LOCK then t:SetMove(UI_LOCK)
						   else t:Update() end
			end
		else
			HDH_TRACKER.UpdateSettingAll()
			if UI_LOCK then
				HDH_TRACKER.SetMoveAll(UI_LOCK)
			else
				for k,tracker in pairs(HDH_TRACKER.GetList()) do
					tracker:Update()
				end
			end
		end
	end
end

-- 체크 버튼 핸들러
function HDH_AT_OP_OnChecked(self, checked)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	local tracker = HDH_TRACKER.Get(name);
	UpdateFrameDB_CB(self, checked);
	
	if self == F_OP_CB_TRACKER_ENABLE then -- 추적 활성화
		if checked then
			UnitOptionFrameSFContents:Show();
			HDH_AT_Disable:Hide();
		else
			UnitOptionFrameSFContents:Hide();
			HDH_AT_Disable:Show();
		end

		if tracker then 
			if UI_LOCK then UI_LOCK = false;
							tracker:InitIcons();
							UI_LOCK = true;
							tracker:SetMove(UI_LOCK)
			else
				tracker:InitIcons();
			end
		end
	elseif self == F_OP_CB_EACH then -- 개별 설정
		if not tracker then return; end
		if checked then
			if not DB_OPTION[name].icon then
				DB_OPTION[name].icon = deepcopy(DB_OPTION.icon)
			end
			if not DB_OPTION[name].font then
				DB_OPTION[name].font = deepcopy(DB_OPTION.font)
			end
			tracker.option.icon = DB_OPTION[name].icon
			tracker.option.font = DB_OPTION[name].font
		else
			tracker.option.icon = DB_OPTION.icon
			tracker.option.font = DB_OPTION.font
		end
		HDH_AT_OP_LoadSetting(GetTrackerIndex());
		tracker:UpdateSetting()
		if UI_LOCK then
			tracker:SetMove(UI_LOCK)
		else
			tracker:InitIcons()
		end
	elseif self == F_OP_CB_COLOR_DEBUFF_DEFAULT then -- 디버프 테두리 기본색상
		if tracker then
			if HDH_AT_OP_IsEachSetting() then
				if UI_LOCK then tracker:SetMove(UI_LOCK)
						   else tracker:InitIcons() end
			else
				HDH_TRACKER.UpdateSettingAll()
				if UI_LOCK then
					HDH_TRACKER.SetMoveAll(UI_LOCK)
				else
					for k,tracker in pairs(HDH_TRACKER.GetList()) do
						tracker:Update()
					end
				end
			end
		end
	elseif self == SettingFrameUIBottomCheckButtonMove then -- 이동
		HDH_TRACKER.SetMoveAll(checked);
	elseif self ==  F_OP_CB_SHOW_ID then
	elseif self ==  F_OP_CB_CT_DESAT then
		if HDH_AT_OP_IsEachSetting() then
			if tracker then 
				if UI_LOCK then
					tracker:SetMove(UI_LOCK)
				else
					tracker:Update()
				end
			end
		else
			if UI_LOCK then
				HDH_TRACKER.SetMoveAll(UI_LOCK)
			else
				for k,tracker in pairs(HDH_TRACKER.GetList()) do
					if string.find(tracker.unit, "cooldown") then
						tracker:Update()
					end
				end
			end
		end
	elseif self == F_OP_CB_SHOW_CD then -- 쿨다운 표시
		if HDH_AT_OP_IsEachSetting() then
			if tracker then
				tracker:UpdateSetting()
			end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == F_OP_CB_ICON_FIX then -- 아이콘 위치 고정
		if tracker then tracker:InitIcons() end
	elseif self == F_OP_CB_REVERS_H or self == F_OP_CB_REVERS_V then -- 상하/좌우 반전
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			if tracker then tracker:Update() end
		end
	elseif self == F_OP_CB_SHOW_TOOLTIP then -- 툴팁 표시
		if not UI_LOCK then
			if tracker then tracker:UpdateSetting() end
		end
	elseif self == ValueOptionFrameCheckButtonShowValue then -- 수치 활성화
		local parent = self:GetParent()
		print(parent.tab)
		local name = HDH_AT_OP_GetTrackerInfo(parent.tab)
		if not name then return end
		local db = DB_AURA.Talent[parent.spec][name]
		if not db[tonumber(parent.row)] then return end
		db[tonumber(parent.row)].ShowValue = checked
		local t = HDH_TRACKER.Get(name)
		if t then t:InitIcons() end
	elseif self == GlowOptionFrameCheckButtonGlow then -- 반짝임 활성화
		local parent = self:GetParent()
		local name = HDH_AT_OP_GetTrackerInfo(parent.tab)
		if not name then return end
		local db = DB_AURA.Talent[parent.spec][name]
		if not db[tonumber(parent.row)] then return end
		db[tonumber(parent.row)].Glow = checked
		local t = HDH_TRACKER.Get(name)
		if t then t:InitIcons() end
	elseif self == F_OP_CB_ALWAYS_SHOW then -- 항상 표시
		for k,tracker in pairs(HDH_TRACKER.GetList()) do
			tracker:Update()
		end
	end
end

--------------------------------------------------------------------------
-- row detail
--------------------------------------------------------------------------
function HDH_AT_OP_OnChangeAuraDetail(self, idx)
	HDH_AT_OP_ChangeTapState(AURA_DETAIL_TAB_BTN_LIST, idx);
end

function HDH_LoadChangeIconFrame(self, row, spec, tab) ---------------------------------------------------
	local icon = _G[self:GetName().."Texture"]
	local ed = _G[self:GetName().."EditBox"]
	--local name = _G[self:GetName().."TextName"]
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(false)
	local row = tonumber(row)
	if not row then return  end
	
	self.row = row
	self.id = id
	self.spec = spec
	self.tab = tab
	
	if ListFrame.row and (#ListFrame.row) <= row then return end
	local data = DB_AURA.Talent[self.spec][HDH_AT_OP_GetTrackerInfo(self.tab)][row]
	--name:SetText(data.Name)
	icon:SetTexture(data.Texture)
	ed:SetText("")
end

function HDH_OnEnterPressedChangeIcon(self)
	local icon = _G[self:GetParent():GetName().."Texture"]
	local ed = _G[self:GetParent():GetName().."EditBox"]
	local isItem = _G[self:GetParent():GetName().."CheckButtonIsItem"]:GetChecked()
	--ed:SetText(HDH_trim(ed) or "")
	local txt = ed:GetText()
	local texture = nil
	if tonumber(txt) then txt = tonumber(txt) end
	if isItem then
		texture = GetItemIcon(txt)
	else
		texture = GetSpellTexture(txt)
	end
	if texture then
		icon:SetTexture(texture)
		self:GetParent().texture = texture
	else
		self:GetParent().texture = nil
		--t2:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		HDH_OP_AlertDlgShow("알 수 없는 이름(ID) 입니다")
	end
end

function HDH_OnClickChangeIcon(self)
	local icon = _G[self:GetParent():GetName().."Texture"]
	local ed = _G[self:GetParent():GetName().."EditBox"]
	local row = tonumber(self:GetParent().row)
	local parent= self:GetParent()
	if not row then 
		HDH_OP_AlertDlgShow("아이콘 이미지 변경을 실패하였습니다")
	end
	if ListFrame.row and (#ListFrame.row) <= row then 
		HDH_OP_AlertDlgShow("아이콘 이미지 변경을 실패하였습니다")
	end
	local tabName = HDH_AT_OP_GetTrackerInfo(parent.tab)
	if not tabName then 
		HDH_OP_AlertDlgShow("아이콘 이미지 변경을 실패하였습니다")
	end
	local data = DB_AURA.Talent[parent.spec][tabName][row]
	if not data then return end
	if parent.texture then 
		data.Texture = parent.texture
		OptionFrame:Hide()
		OptionFrame:Show()
		local tracker = HDH_TRACKER.Get(tabName)
		if tracker then
			tracker:InitIcons()
		end
		_G[RowDetailSetFrame:GetName().."TopIcon"]:SetTexture(parent.texture)
	else
		parent.texture = nil
		HDH_OP_AlertDlgShow("알 수 없는 이름(ID) 입니다");
	end
end

function HDH_OnClickRestoreIcon(self)
	local parent = self:GetParent()
	local data = DB_AURA.Talent[parent.spec][HDH_AT_OP_GetTrackerInfo(parent.tab)][parent.row]
	if not data then return end
	if data.IsItem then
		parent.texture = GetItemIcon(data.ID)
	else
		parent.texture = GetSpellTexture(data.ID)
	end
	if not parent.texture and HDH_POWER_TEXTURE then
		parent.texture = HDH_POWER_TEXTURE[1];
	end
	local icon = _G[self:GetParent():GetName().."Texture"]
	icon:SetTexture(parent.texture)
end

function HDH_LoadGlowFrame(self, row, spec, tab)--------------------------------------------------------
	local name = HDH_AT_OP_GetTrackerInfo(tab)
	if not name then return end
	local db = DB_AURA.Talent[spec][name]
	if not db[tonumber(row)] then return end
	
	self.row = row
	self.spec = spec
	self.tab = tab
	_G[self:GetName().."CheckButtonGlow"]:SetChecked(db[tonumber(row)].Glow)
	_G[self:GetName().."EB"]:SetText(db[tonumber(row)].GlowCount or "")
	_G[self:GetName().."EB2"]:SetText(db[tonumber(row)].GlowV1 or "")
	--_G[self:GetName().."EB3"]:SetText(db[tonumber(row)].GlowV2 or "")
end

function HDH_OnClick_SaveGlowCount(self)
	local parent = self:GetParent()
	local count = _G[parent:GetName().."EB"]:GetText()
	local v1 = _G[parent:GetName().."EB2"]:GetText()
	--local v2 = _G[parent:GetName().."EB3"]:GetText()
	local name = HDH_AT_OP_GetTrackerInfo(parent.tab)
	if not name then return end
	local db = DB_AURA.Talent[parent.spec][name]
	if not parent.row then return end
	if not db[tonumber(parent.row)] then return end
	
	count = tonumber(HDH_trim(count))
	v1 = tonumber(HDH_trim(v1))
	--v2 = tonumber(HDH_trim(v2))
	db[tonumber(parent.row)].GlowCount = count
	db[tonumber(parent.row)].GlowV1 = v1
	--db[tonumber(parent.row)].GlowV2 = v2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_LoadValueFrame(self, row, spec, tab) -------------------------------------------------------
	local name, unit = HDH_AT_OP_GetTrackerInfo(tab)
	if not name then return end
	local db = DB_AURA.Talent[spec][name]
	if not db[tonumber(row)] then return end
	db = db[tonumber(row)]
	
	self.row = row
	self.spec = spec
	self.tab = tab
	--GlowOptionFrameEB:SetText(db[tonumber(id)].GlowCount or 0)
	_G[self:GetName().."CheckButtonShowValue"]:SetChecked(db.ShowValue)
	
	--_G[self:GetName().."CheckButtonValue1"]:SetChecked(db.v1)
	--_G[self:GetName().."CheckButtonValue2"]:SetChecked(db.v2)
	_G[self:GetName().."CheckButtonValuePerHp1"]:SetChecked(db.v1_hp or false)
	--_G[self:GetName().."CheckButtonValuePerHp2"]:SetChecked(db.v2_hp or false)
	--_G[self:GetName().."EB1"]:SetText(db.v1_type or "")
	--_G[self:GetName().."EB2"]:SetText(db.v2_type or "")
end

function HDH_OnClick_SaveShowValue(self)
	local v1 = _G[self:GetParent():GetName().."CheckButtonValue1"]:GetChecked()
	-- local v2 = _G[self:GetParent():GetName().."CheckButtonValue2"]:GetChecked()
	local h1 = _G[self:GetParent():GetName().."CheckButtonValuePerHp1"]:GetChecked()
	-- local h2 = _G[self:GetParent():GetName().."CheckButtonValuePerHp2"]:GetChecked()
	local text1 = _G[self:GetParent():GetName().."EB1"]:GetText()
	-- local text2 = _G[self:GetParent():GetName().."EB2"]:GetText()
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not name then return end
	local db = DB_AURA.Talent[ValueOptionFrame.spec][name]
	if not ValueOptionFrame.row then return end
	if not db[tonumber(ValueOptionFrame.row)] then return end
	db = db[tonumber(ValueOptionFrame.row)]
	--db.v1 = v1
	--db.v1_type = HDH_trim(text1) or "" 
	db.v1_hp = h1
	--db.v2 = v2 
	--db.v2_type = HDH_trim(text2) or ""
	--db.v2_hp = h2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

local function HDH_path(path)
	if path and (path:len() > 0) then
		path = HDH_trim(path)
		for i = 1, path:len() do
			if path:sub(i,i) ~= "\\" then
				return path:sub(i) or nil
			end
		end
	else
		return nil
	end
end

function HDH_LoadSoundFrame(self, row , spec, tab) ------------------------------------------------------
	local st = _G[self:GetName().."EditBox1"]
	local et = _G[self:GetName().."EditBox2"]
	local ct = _G[self:GetName().."EditBox3"]
	local db = DB_AURA.Talent[spec][HDH_AT_OP_GetTrackerInfo(tab)]
	if not db[tonumber(row)] then return end
	db = db[tonumber(row)]
	st:SetText(db.StartSound or "")
	et:SetText(db.EndSound or "")
	ct:SetText(db.ConditionSound or "")
	self.row = row
	self.spec = spec
	self.tab = tab
end

function HDH_OnClickPreviewSound(self, path)
	PlaySoundFile(HDH_path(path) or "","SFX")
end

function HDH_OnClickSaveSound(self)
	local parent = self:GetParent()
	local st = _G[parent:GetName().."EditBox1"]
	local et = _G[parent:GetName().."EditBox2"]
	local ct = _G[parent:GetName().."EditBox3"]
	local db = DB_AURA.Talent[parent.spec][HDH_AT_OP_GetTrackerInfo(parent.tab)]
	if not db[tonumber(parent.row)] then return end
	db = db[tonumber(parent.row)]
	
	local path = HDH_path(st:GetText())
	st:SetText(path or "")
	db.StartSound = path
	
	path = HDH_path(et:GetText())
	et:SetText(path or "")
	db.EndSound = path
	
	path = HDH_path(ct:GetText())
	ct:SetText(path or "")
	db.ConditionSound = path
	
	local t = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(parent.tab))
	if t then t:InitIcons() end
end

function HDH_OnClick_RowDetailSet(self, row) ---------------------------------------------
	--HDH_AT_OP_ChangeBody(BODY_TYPE.AURA_DETAIL, GetTrackerIndex(), row);
	local spec = CurSpec
	local tracker = GetTrackerIndex()
	local name = HDH_AT_OP_GetTrackerInfo(tracker)
	if not name then return end
	local db = DB_AURA.Talent[spec][name]
	if not row then return end
	if not db[tonumber(row)] then return end
	db = db[tonumber(row)]
	local frame = RowDetailSetFrame
	local name = _G[frame:GetName().."TopText"]
	local icon = _G[frame:GetName().."TopIcon"]
	name:SetText(db.Name)
	icon:SetTexture(db.Texture)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
	RowDetailSetFrame:Show()
	HDH_AT_OP_ChangeTapState(AURA_DETAIL_TAB_BTN_LIST, AURA_DETAIL_TAB_BTN_LIST.CurIdx);
	UnitOptionFrame:Hide()
	
	HDH_LoadSoundFrame(SoundFrame, row , spec, tracker)
	HDH_LoadChangeIconFrame(ChangeIconFrame, row, spec, tracker)
	HDH_LoadValueFrame(ValueOptionFrame, row, spec, tracker)
	HDH_LoadGlowFrame(GlowOptionFrame, row, spec, tracker)
end

--------------------------------
-- end
--------------------------------

function HDH_Option_OnShow(self)
	if not GetSpecialization() then
		print("|cffff0000AuraTracking:Error - |cffffff00직업 전문화를 활성화 해야합니다.(10렙 이상)")
		self:Hide()
		return
	end
	
	self:SetClampedToScreen(true)
	local x = self:GetLeft()
	local y = self:GetBottom()
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", x, y)
	self:SetClampedToScreen(false)
	self:SetWidth(FRAME_W)
	
	if self:GetHeight() < 410 then
		self:SetHeight(410)
	end
	
	if not DB_AURA or #DB_AURA.Talent == 0 then
		HDH_TRACKER.InitVaribles()
	end
	
	local listFrame = TRACKER_LIST_FRAME;
	local count = TRACKER_TAB_BTN_LIST.count or 0;
	
	for i = #DB_FRAME_LIST +1, count do -- 필요 없는것들부터 정리하고
		TRACKER_TAB_BTN_LIST[i]:Hide();
		count = #DB_FRAME_LIST;
	end
	
	if #DB_FRAME_LIST == 0 then
		listFrame:SetSize(listFrame:GetParent():GetWidth(), TRACKER_TAB_BTN_LIST.DefaultBtn:GetHeight());
	elseif count < #DB_FRAME_LIST then
		for i = 1, #DB_FRAME_LIST do
			HDH_AT_OP_AddTrackerButton(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].unit, i);
		end
		if TRACKER_TAB_BTN_LIST.CurIdx == nil then 
			SetTrackerIndex(1);
			g_CurMode = BODY_TYPE.AURA;
		end
	end
	
	HDH_LoadTabSpec();
end

function HDH_Option_OnLoad(self)
	self:SetMinResize(FRAME_W, MIN_H) 
	self:SetMaxResize(FRAME_W, MAX_H)
	
	SETTING_CONTENTS_FRAME = SettingFrameSFContents;
	ListFrame = _G[UnitOptionFrame:GetName().."SFContents"];
	
	TRACKER_LIST_FRAME = _G[OptionFrame:GetName().."TrackerListFrameSFContents"];
	TRACKER_LIST_FRAME:GetParent().scrollBarHideable = true;
	
	TRACKER_TAB_BTN_LIST = {};
	TRACKER_TAB_BTN_LIST.Body = {};
	--TRACKER_TAB_BTN_LIST.CurIdx;
	TRACKER_TAB_BTN_LIST[BODY_TYPE.CREATE_TRACKER] = _G[TRACKER_LIST_FRAME:GetName().."BtnAddTracker"];-- BODY_TYPE.CREATE_TRACKER = 0
	TRACKER_TAB_BTN_LIST.Body[BODY_TYPE.CREATE_TRACKER] = AddTrackerFrame;
	TRACKER_TAB_BTN_LIST.DefaultBtn = _G[TRACKER_LIST_FRAME:GetName().."BtnAddTracker"]; -- 리스트의 height 를 측정하는 토대가 되는 버튼의 크기를 얻기위해 사용.
	
	BODY_TAB_BTN_LIST = { OptionFrameTitleFrameAuraList, OptionFrameTitleFrameUIOption, OptionFrameTitleFrameTrackerOption};
	BODY_TAB_BTN_LIST.Body = { UnitOptionFrame, SettingFrame, AddTrackerFrame };
	BODY_TAB_BTN_LIST.CurIdx = 1;
	
	UI_TAB_BTN_LIST = {SettingFrameUIListSFContentsFont1,SettingFrameUIListSFContentsIcon1, SettingFrameUIListSFContentsProfile,SettingFrameUIListSFContentsETC};
	UI_TAB_BTN_LIST.Body =  { SettingFrameUIBodyFont, SettingFrameUIBodyIcon ,SettingFrameUIBodyProfile, SettingFrameUIBodyETC };
	UI_TAB_BTN_LIST.CurIdx = 1;
	
	AURA_DETAIL_TAB_BTN_LIST = {RowDetailSetFrameListButton1, RowDetailSetFrameListButton2, RowDetailSetFrameListButton3, RowDetailSetFrameListButton4};
	AURA_DETAIL_TAB_BTN_LIST.Body = {GlowOptionFrame, ValueOptionFrame, ChangeIconFrame, SoundFrame};
	AURA_DETAIL_TAB_BTN_LIST.CurIdx = 1;
	InitFrame();
end

-----------------------------------------
---------------------
SLASH_AURATRACKINGT1 = '/at'
SLASH_AURATRACKINGT2 = '/auratracking'
SLASH_AURATRACKINGT3 = '/ㅁㅅ'
SlashCmdList["AURATRACKINGT"] = function (msg, editbox)
	if OptionFrame:IsShown() then 
		OptionFrame:Hide()
	else
		OptionFrame:Show()
	end
end