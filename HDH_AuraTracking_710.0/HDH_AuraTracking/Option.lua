-----------------
---- #define ----
HDH_AT_OP = {};

local STR_TRACKER_BTN_FORMAT = "%s\r\n|cffaaaaaa%s"

local GRID_SIZE = 30;
local FRAME_W = 670
local FRAME_H = 500
local MAX_H = 550
local MIN_H = 350
local MAX_SPLIT_ADDFRAME = 5;
local ROW_HEIGHT = 26 -- 오라 row 높이
local EDIT_WIDTH_L = 145
local EDIT_WIDTH_S = 0
local FLAG_ROW_CREATE = 1 -- row 생성 모드
local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0
local DDM_COOLDOWN_LIST = {"위로", "아래로", "왼쪽으로", "오른쪽으로", "원형"}
local DDM_FONT_LOCATION_LIST = {"좌측 상단","좌측 하단","우측 상단", "우측 하단", "중앙", "아이콘 밖 위", "아이콘 밖 아래","아이콘 밖 왼쪽", "아이콘 밖 오른쪽", "바 왼쪽", "바 중앙", "바 오른쪽"}
local DDM_BAR_LOCATION_LIST = {"아이콘 위", "아이콘 아래", "아이콘 왼쪽", "아이콘 오른쪽"}
local DDM_BAR_TEXTURE_LIST = {"BantoBar","Minimalist","normTex","Smooth","Blizzard","None"};
local DDM_BAR_NAME_ALIGN_LIST = {"왼쪽","가운데","오른쪽","상단","하단"};
local DDM_ICON_ORDER_LIST = {"목록 순서","남은시간 적은 순","남은시간 많은 순"};
local DDM_TIME_TYPE = {"정수 올림 (소수점 첫번쨰)", "정수 내림 (소수점 첫번쨰)", "소수점 (10초 미만일 떄)"};

local BODY_TYPE = {CREATE_TRACKER = 0, AURA = 1, UI = 2, EDIT_TRACKER = 3, AURA_DETAIL = 4 };
HDH_AT_OP.BODY_TYPE = BODY_TYPE;

local UI_TYPE = { FONT = 1, ICON=2, BAR=3, PROFILE=4, ETC = 5, SHARE = 6 };
HDH_AT_OP.UI_TYPE = UI_TYPE;
HDH_AT_OP.DLG_TYPE = {OK =1, YES_NO=2, NONE= 3};
				 
-- FRAME --
local OPTION_FRAME = OptionFrame; -- parent
local TRACKER_LIST_FRAME;
local SETTING_CONTENTS_FRAME;
local BODY_TAB_BTN_LIST;
local UI_TAB_BTN_LIST; -- setting frame
local AURA_DETAIL_TAB_BTN_LIST;
local TRACKER_TAB_BTN_LIST;

local FRAME = {}
-- local FRAME.BODY_UNIT;
-- local FRAME.BODY_SET;
-- local FRAME.BODY_TRACKER;
	
	-- 기본 설정 --
-- local FRAME.CB_EACH ;
-- local FRAME.CB_SHOW_ID;
-- local FRAME.CB_ALWAYS_SHOW;

	-- 글자 설정 --
-- local FRAME.BTN_COLOR_FONT1;
-- local FRAME.BTN_COLOR_FONT2;
-- local FRAME.BTN_COLOR_FONT3;
-- local FRAME.BTN_COLOR_FONT4;
-- local FRAME.BTN_COLOR_FONT_CD5;
-- local FRAME.CB_SHOW_CD;
-- local FRAME.DDM_FONT_LOC1;
-- local FRAME.DDM_FONT_LOC2;
-- local FRAME.DDM_FONT_LOC3;
-- local FRAME.DDM_FONT_LOC4;
-- local FRAME.SL_FONT_SIZE1;
-- local FRAME.SL_FONT_SIZE2;
-- local FRAME.SL_FONT_SIZE3;
-- local FRAME.SL_FONT_SIZE4;

	-- 아이콘 설정 --
-- local FRAME.BTN_COLOR_BUFF;
-- local FRAME.BTN_COLOR_DEBUFF;
-- local FRAME.BTN_COLOR_CD_BG;
-- local FRAME.CB_COLOR_DEBUFF_DEFAULT;
-- local FRAME.SL_ICON_SIZE;
-- local FRAME.SL_ON_ALPHA;
-- local FRAME.SL_OFF_ALPHA;
-- local FRAME.SL_MARGIN_H;
-- local FRAME.SL_MARGIN_V;
-- local FRAME.CB_ABLE_BUFF_CANCEL;

	-- 바 설정--
-- local FRAME.CB_BAR_ENABLE;
-- local FRAME.CB_BAR_REVERSE;
-- local FRAME.CP_BAR_COLOR;
-- local FRAME.CP_BAR_BG_COLOR;
-- local FRAME.DDM_BAR_LOCATION;
-- local FRAME.DDM_BAR_TEXTURE;
-- local FRAME.SL_BAR_WIDTH;
-- local FRAME.SL_BAR_HEIGHT;
	
	-- 바 이름 설정
-- local FRAME.CB_BAR_NAME_SHOW;
-- local FRAME.DDM_BAR_NAME_ALIGN;
-- local FRAME.SL_BAR_NAME_TEXT_SIZE;
-- local FRAME.SL_BAR_NAME_MARGIN_LEFT;
-- local FRAME.SL_BAR_NAME_MARGIN_RIGHT;

	
	-- 트래커별 UI 설정 --
-- local FRAME.CB_REVERS_H;
-- local FRAME.CB_REVERS_V;
-- local FRAME.CB_ICON_FIX;
-- local FRAME.SL_LINE;
-- local FRAME.CB_SHOW_TOOLTIP;
-- local FRAME.DDM_CD_TYPE;
-- local FRAME.DDM_ORDER_BY;
-- local FRAME.CB_LIST_SHARE;


	-- 스킬 쿨다운 관련 설정 --
-- local FRAME.CP_CT_COLOR;
-- local FRAME.CP_CT_NOTENOUGHMANA;
-- local FRAME.CP_CT_OUTRANGE;
-- local FRAME.SL_CT_MAXTIME;
-- local FRAME.DDM_CT_RELATIVE_UNIT;
-- local FRAME.CB_CT_DESAT;
-- local FRAME.CB_CT_DESAT_NOTENOUGHMANA;
-- local FRAME.CB_CT_DESAT_OUTRANGE;

-- 트래커 추가 탭 --
-- local FRAME.DDM_TRACKER_LIST;
-- local FRAME.DDM_TRACKER_LIST;
-- local FRAME.DDM_TALENT_LIST;

---- #end def ----
------------------

g_CurMode = BODY_TYPE.AURA;
local CurSpec = 1 -- 현재 설정창 특성
local ListFrame;
local TAB_TALENT;

function HDH_OP_AlertDlgShow(msg, type, func, ...)
	if AlertDlg:IsShown() then return end
	AlertDlg.text = msg;
	AlertDlg.dlg_type = type;
	AlertDlg.func = func;
	AlertDlg.arg = {...};
	AlertDlg:Show();
end

function HDH_OP_AlertDlgHide()
	AlertDlg:Hide();
end

-- 프레임 변수와 db 키와 매칭하는 함수
local function InitFrame()
	FRAME.TOP_PARENT = OptionFrame
	FRAME.BODY_UNIT = UnitOptionFrame;
	FRAME.BODY_SET = SettingFrame;
	FRAME.BODY_TRACKER = AddTrackerFrame;
	
	FRAME.PROFILE = SettingFrameUIBodyProfile;
	
	-- 기본 설정 --
	FRAME.CB_MOVE = SettingFrameUIBottomCheckButtonMove;
	FRAME.CB_EACH = SettingFrameUIListSFContentsCheckButtonEachSet;
	FRAME.CB_EACH.key = "use_each";
	FRAME.CB_SHOW_ID = SettingFrameUIBottomCheckButtonIDShow;
	FRAME.CB_SHOW_ID.key = "tooltip_id_show";
	FRAME.CB_ALWAYS_SHOW = SettingFrameUIBodyIconSFContentsCheckButtonAlwaysShow;
	FRAME.CB_ALWAYS_SHOW.key = "always_show";

	-- 글자 설정 --
	FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyFontSFContentsButtonColorText1;
	FRAME.BTN_COLOR_FONT1.key = "textcolor";
	FRAME.BTN_COLOR_FONT2 = SettingFrameUIBodyFontSFContentsButtonColorText2;
	FRAME.BTN_COLOR_FONT2.key = "countcolor";
	FRAME.BTN_COLOR_FONT3 = SettingFrameUIBodyFontSFContentsButtonColorText3;
	FRAME.BTN_COLOR_FONT3.key = "v1_color";
	FRAME.BTN_COLOR_FONT4 = SettingFrameUIBodyFontSFContentsButtonColorText4;
	FRAME.BTN_COLOR_FONT4.key = "v2_color";
	FRAME.BTN_COLOR_FONT_CD5 = SettingFrameUIBodyFontSFContentsButtonColorCooldownText5;
	FRAME.BTN_COLOR_FONT_CD5.key = "textcolor_5s";
	FRAME.CB_SHOW_CD = SettingFrameUIBodyFontSFContentsCheckButtonShowCooldown;
	FRAME.CB_SHOW_CD.key = "show_cooldown";
	FRAME.DDM_TIME_TYPE = SettingFrameUIBodyFontSFContentsDDMTimeType;
	FRAME.DDM_TIME_TYPE.key = "time_type";
	FRAME.DDM_FONT_LOC1 = SettingFrameUIBodyFontSFContentsDDMFontLocation1;
	FRAME.DDM_FONT_LOC1.key = "cd_location";
	FRAME.DDM_FONT_LOC2 = SettingFrameUIBodyFontSFContentsDDMFontLocation2;
	FRAME.DDM_FONT_LOC2.key = "count_location";
	FRAME.DDM_FONT_LOC3 = SettingFrameUIBodyFontSFContentsDDMFontLocation3;
	FRAME.DDM_FONT_LOC3.key = "v1_location";
	FRAME.DDM_FONT_LOC4 = SettingFrameUIBodyFontSFContentsDDMFontLocation4;
	FRAME.DDM_FONT_LOC4.key = "v2_location";
	FRAME.SL_FONT_SIZE1 = SettingFrameUIBodyFontSFContentsSliderFont1;
	FRAME.SL_FONT_SIZE1.key = "fontsize";
	FRAME.SL_FONT_SIZE2 = SettingFrameUIBodyFontSFContentsSliderFont2;
	FRAME.SL_FONT_SIZE2.key = "countsize";
	FRAME.SL_FONT_SIZE3 = SettingFrameUIBodyFontSFContentsSliderFont3;
	FRAME.SL_FONT_SIZE3.key = "v1_size";
	FRAME.SL_FONT_SIZE4 = SettingFrameUIBodyFontSFContentsSliderFont4;
	FRAME.SL_FONT_SIZE4.key = "v2_size";

	-- 아이콘 설정 --
	FRAME.BTN_COLOR_BUFF = SettingFrameUIBodyIconSFContentsButtonColorBuff;
	FRAME.BTN_COLOR_BUFF.key = "buff_color";
	FRAME.BTN_COLOR_DEBUFF = SettingFrameUIBodyIconSFContentsButtonColorDebuff;
	FRAME.BTN_COLOR_DEBUFF.key  = "debuff_color";
	FRAME.BTN_COLOR_CD_BG = SettingFrameUIBodyIconSFContentsButtonColorCooldownBg;
	FRAME.BTN_COLOR_CD_BG.key  = "cooldown_bg_color";
	FRAME.CB_COLOR_DEBUFF_DEFAULT = SettingFrameUIBodyIconSFContentsCheckButtonDefaultColor;
	FRAME.CB_COLOR_DEBUFF_DEFAULT.key  = "default_color";
	FRAME.SL_ICON_SIZE = SettingFrameUIBodyIconSFContentsSliderIcon;
	FRAME.SL_ICON_SIZE.key  = "size";
	FRAME.SL_ON_ALPHA = SettingFrameUIBodyIconSFContentsSliderOnAlpha;
	FRAME.SL_ON_ALPHA.key  = "on_alpha";
	FRAME.SL_OFF_ALPHA = SettingFrameUIBodyIconSFContentsSliderOffAlpha;
	FRAME.SL_OFF_ALPHA.key  = "off_alpha";
	FRAME.SL_MARGIN_H = SettingFrameUIBodyIconSFContentsSliderMarginH;
	FRAME.SL_MARGIN_H.key  = "margin_h";
	FRAME.SL_MARGIN_V = SettingFrameUIBodyIconSFContentsSliderMarginV;
	FRAME.SL_MARGIN_V.key  = "margin_v";
	FRAME.CB_ABLE_BUFF_CANCEL = SettingFrameUIBodyIconSFContentsCheckButtonAbleAuraCancel;
	FRAME.CB_ABLE_BUFF_CANCEL.key = "able_buff_cancel";
	
	-- 바 설정 --
	FRAME.CB_BAR_ENABLE = SettingFrameUIBodyBarSFContentsCheckButtonShowBar;
	FRAME.CB_BAR_ENABLE.key = "enable";
	FRAME.CB_BAR_REVERSE = SettingFrameUIBodyBarSFContentsCheckButtonReverseProgress;
	FRAME.CB_BAR_REVERSE.key = "reverse_progress";
	FRAME.CP_BAR_COLOR = SettingFrameUIBodyBarSFContentsButtonBarColor;
	FRAME.CP_BAR_COLOR.key = "color";
	FRAME.CP_BAR_FULL_COLOR = SettingFrameUIBodyBarSFContentsButtonBarFullColor;
	FRAME.CP_BAR_FULL_COLOR.key = "full_color";
	FRAME.CP_BAR_BG_COLOR = SettingFrameUIBodyBarSFContentsButtonBarBgColor;
	FRAME.CP_BAR_BG_COLOR.key = "bg_color";
	FRAME.DDM_BAR_LOCATION = SettingFrameUIBodyBarSFContentsDDMBarLocation;
	FRAME.DDM_BAR_LOCATION.key = "location";
	FRAME.DDM_BAR_TEXTURE = SettingFrameUIBodyBarSFContentsDDMBarTexture;
	FRAME.DDM_BAR_TEXTURE.key = "texture";
	FRAME.SL_BAR_WIDTH = SettingFrameUIBodyBarSFContentsSliderPowerBarWidth;
	FRAME.SL_BAR_WIDTH.key = "width";
	FRAME.SL_BAR_HEIGHT = SettingFrameUIBodyBarSFContentsSliderPowerBarHeight;
	FRAME.SL_BAR_HEIGHT.key = "height";
	FRAME.CB_HIDE_ICON = SettingFrameUIBodyBarSFContentsCheckButtonHideIcon;
	FRAME.CB_HIDE_ICON.key = "hide_icon";
	FRAME.CB_BAR_USE_FULL_COLOR = SettingFrameUIBodyBarSFContentsCheckButtonUseFullColor;
	FRAME.CB_BAR_USE_FULL_COLOR.key = "use_full_color";
	
	-- 바 이름 설정
	FRAME.CB_BAR_NAME_SHOW = SettingFrameUIBodyBarSFContentsCheckButtonBarNameShow;
	FRAME.CB_BAR_NAME_SHOW.key = "show_name";
	FRAME.DDM_BAR_NAME_ALIGN = SettingFrameUIBodyBarSFContentsDDMBarNameAlign;
	FRAME.DDM_BAR_NAME_ALIGN.key = "name_align";
	FRAME.SL_BAR_NAME_TEXT_SIZE = SettingFrameUIBodyBarSFContentsSliderFont;
	FRAME.SL_BAR_NAME_TEXT_SIZE.key = "name_size";
	FRAME.SL_BAR_NAME_MARGIN_LEFT = SettingFrameUIBodyBarSFContentsSliderBarNameMarginLeft;
	FRAME.SL_BAR_NAME_MARGIN_LEFT.key = "name_margin_left";
	FRAME.SL_BAR_NAME_MARGIN_RIGHT = SettingFrameUIBodyBarSFContentsSliderBarNameMarginRight;
	FRAME.SL_BAR_NAME_MARGIN_RIGHT.key = "name_margin_right";
	FRAME.CP_BAR_NAME_COLOR = SettingFrameUIBodyBarSFContentsButtonBarNameColorOn;
	FRAME.CP_BAR_NAME_COLOR.key = "name_color"
	FRAME.CP_BAR_NAME_COLOR_OFF = SettingFrameUIBodyBarSFContentsButtonBarNameColorOff;
	FRAME.CP_BAR_NAME_COLOR_OFF.key = "name_color_off";
	FRAME.CB_BAR_FILL = SettingFrameUIBodyBarSFContentsCheckButtonFillBar;
	FRAME.CB_BAR_FILL.key = "fill_bar";
	FRAME.CB_BAR_SHOW_SPACK = SettingFrameUIBodyBarSFContentsCheckButtonShowSpark;
	FRAME.CB_BAR_SHOW_SPACK.key = "show_spark";
	
	-- 트래커별 UI 설정 --
	FRAME.CB_REVERS_H = UnitOptionFrameCheckButtonReversH;
	FRAME.CB_REVERS_H.key = "revers_h";
	FRAME.CB_REVERS_V = UnitOptionFrameCheckButtonReversV;
	FRAME.CB_REVERS_V.key = "revers_v";
	FRAME.CB_SHOW_TOOLTIP = UnitOptionFrameCheckButtonTooltip;
	FRAME.CB_SHOW_TOOLTIP.key = "show_spell_tooltip";
	FRAME.CB_ICON_FIX = UnitOptionFrameCheckButtonFix;
	FRAME.CB_ICON_FIX.key = "fix";
	FRAME.SL_LINE = UnitOptionFrameSliderLine;
	FRAME.SL_LINE.key = "line";
	FRAME.DDM_CD_TYPE = UnitOptionFrameDDMCooldown;
	FRAME.DDM_CD_TYPE.key = "cooldown";
	FRAME.DDM_ORDER_BY = UnitOptionFrameDDMOrder;
	FRAME.DDM_ORDER_BY.key = "order_by";
	FRAME.CB_LIST_SHARE = UnitOptionFrameCheckButtonListShare;
	FRAME.CB_LIST_SHARE.key = "list_share";
	
	--FRAME.CB_REVERS_H = SettingFrameUIBottomCheckButtonMove;
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonSet
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonLoad
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonReset
	FRAME.DDM_PROFILE = SettingFrameUIBodyProfileDDMProfile;
	
	-- 트래커 추가 탭 --
	FRAME.DDM_TALENT_LIST = AddTrackerFrameDDMSpecList;
	FRAME.DDM_TRACKER_LIST = AddTrackerFrameDDMTabList;
	FRAME.DDM_TRACKER_TYPE_LIST = AddTrackerFrameDDMTrackerTypeList
	-- FRAME.DDM_TRACKER_LIST.key = "unit";
	FRAME.DDM_UNIT_LIST = AddTrackerFrameDDMUnitList;
	-- FRAME.DDM_UNIT_LIST.key = "unit";
	FRAME.CB_TRACKER_BUFF = AddTrackerFrameCheckButtonBuff; 
	FRAME.CB_TRACKER_BUFF.key = "check_buff";
	FRAME.CB_TRACKER_DEBUFF = AddTrackerFrameCheckButtonDebuff;
	FRAME.CB_TRACKER_MINE = AddTrackerFrameCheckButtonMine; 
	FRAME.CB_TRACKER_MINE.key = "check_only_mine";
	FRAME.CB_TRACKER_ALL_AURA = AddTrackerFrameCheckButtonAllAura; 
	FRAME.CB_TRACKER_ALL_AURA.key = "tracking_all";
	FRAME.CB_TRACKER_BOSS_AURA = AddTrackerFrameCheckButtonBossAura; 
	FRAME.CB_TRACKER_BOSS_AURA.key = "tracking_boss_aura";
	FRAME.CB_TRACKER_MERGE_POWERICON = AddTrackerFrameCheckButtonMergePowerIcon;
	FRAME.CB_TRACKER_MERGE_POWERICON.key = "merge_power_icon";
	
	-- 스킬 쿨다운 관련 설정 --
	FRAME.CP_CT_COLOR = CooldownSettingFrameButtonColor;
	FRAME.CP_CT_COLOR.key = "cooldown_color";
	FRAME.CB_CT_DESAT = CooldownSettingFrameCheckButtonDesaturation;
	FRAME.CB_CT_DESAT.key = "desaturation";
	FRAME.CB_CT_DESAT_NOTENOUGHMANA = CooldownSettingFrameCheckButtonDesaturationNotEnoughMana;
	FRAME.CB_CT_DESAT_NOTENOUGHMANA.key = "desaturation_not_mana";
	FRAME.CB_CT_DESAT_OUTRANGE = CooldownSettingFrameCheckButtonDesaturationOutRange;
	FRAME.CB_CT_DESAT_OUTRANGE.key = "desaturation_out_range";
	FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN = CooldownSettingFrameCheckButtonShowGlobalCooldown;
	FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN.key = "show_global_cooldown";
	FRAME.SL_CT_MAXTIME = CooldownSettingFrameSliderMaxTime;
	FRAME.SL_CT_MAXTIME.key = "max_time";
	FRAME.CP_CT_NOTENOUGHMANA = CooldownSettingFrameButtonColorNotEnoughMana;
	FRAME.CP_CT_NOTENOUGHMANA.key = "not_enough_mana_color";
	FRAME.CP_CT_OUTRANGE = CooldownSettingFrameButtonColorOutRange;
	FRAME.CP_CT_OUTRANGE.key = "out_range_color";
end

-- 기본 공통 설정 디비 매칭
local function Match_Basic_DBForFrame()
	FRAME.CB_EACH.db = DB_OPTION;
	FRAME.CB_SHOW_ID.db = DB_OPTION;
end

-- 트래커별 디비 매칭
local function Match_Tracker_DBForFrame(curTracker)
	local tracker_name = HDH_AT_OP_GetTrackerInfo(curTracker);
	local db = DB_OPTION[tracker_name];
	if tracker_name and db then
		FRAME.CB_REVERS_H.db = db;
		FRAME.CB_REVERS_V.db = db;
		FRAME.CB_SHOW_TOOLTIP.db = db;
		FRAME.CB_ICON_FIX.db = db;
		FRAME.SL_LINE.db = db;
		FRAME.DDM_CD_TYPE.db = db;
		FRAME.DDM_ORDER_BY.db = db;
		FRAME.DDM_TRACKER_TYPE_LIST.db = db;
		FRAME.DDM_UNIT_LIST.db = db;
		FRAME.CB_TRACKER_BUFF.db = db;
		FRAME.CB_TRACKER_MINE.db = db;
		FRAME.CB_TRACKER_ALL_AURA.db = db;
		FRAME.CB_TRACKER_BOSS_AURA.db = db;
		FRAME.CB_TRACKER_MERGE_POWERICON.db = db;
		FRAME.CB_LIST_SHARE.db = db;
		return true;
	else
		return false;
	end
end

-- 폰트/아이콘/바 디비 매칭
local function Match_FontIcon_DBForFrame(curTracker)
	local icon, font, bar ;
	local tracker_name = HDH_AT_OP_GetTrackerInfo(curTracker);
	if tracker_name and DB_OPTION[tracker_name] then
		if DB_OPTION[tracker_name].use_each then
			icon = DB_OPTION[tracker_name].icon;
			font = DB_OPTION[tracker_name].font;
			bar = DB_OPTION[tracker_name].bar;
		else
			font = DB_OPTION.font;
			icon = DB_OPTION.icon;
			bar = DB_OPTION.bar;
		end
	else
		font = DB_OPTION.font;
		icon = DB_OPTION.icon;
		bar = DB_OPTION.bar;
	end
	FRAME.CB_EACH.db = DB_OPTION[tracker_name];
	FRAME.BTN_COLOR_FONT1.db = font;
	FRAME.BTN_COLOR_FONT2.db = font;
	FRAME.BTN_COLOR_FONT3.db = font;
	FRAME.BTN_COLOR_FONT4.db = font;
	FRAME.BTN_COLOR_FONT_CD5.db = font;
	FRAME.DDM_TIME_TYPE.db = font;
	FRAME.DDM_FONT_LOC1.db = font;
	FRAME.DDM_FONT_LOC2.db = font;
	FRAME.DDM_FONT_LOC3.db = font;
	FRAME.DDM_FONT_LOC4.db = font;
	FRAME.SL_FONT_SIZE1.db = font;
	FRAME.SL_FONT_SIZE2.db = font;
	FRAME.SL_FONT_SIZE3.db = font;
	FRAME.SL_FONT_SIZE4.db = font;
	FRAME.CB_SHOW_CD.db = icon;
	FRAME.BTN_COLOR_BUFF.db = icon;
	FRAME.BTN_COLOR_DEBUFF.db = icon;
	FRAME.BTN_COLOR_CD_BG.db = icon;
	FRAME.CB_COLOR_DEBUFF_DEFAULT.db = icon;
	FRAME.SL_ICON_SIZE.db = icon;
	FRAME.SL_ON_ALPHA.db = icon;
	FRAME.SL_OFF_ALPHA.db = icon;
	FRAME.SL_MARGIN_H.db = icon;
	FRAME.SL_MARGIN_V.db = icon;
	FRAME.CB_ABLE_BUFF_CANCEL.db = icon;
	FRAME.CB_HIDE_ICON.db = icon;
		
	FRAME.CB_ALWAYS_SHOW.db = icon;
	
	FRAME.CP_CT_COLOR.db = icon;
	FRAME.CB_CT_DESAT.db = icon;
	FRAME.CB_CT_DESAT_OUTRANGE.db = icon;
	FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN.db = icon;
	FRAME.CB_CT_DESAT_NOTENOUGHMANA.db = icon;
	FRAME.SL_CT_MAXTIME.db = icon;
	FRAME.CP_CT_NOTENOUGHMANA.db = icon;
	FRAME.CP_CT_OUTRANGE.db = icon;
	
	FRAME.CB_BAR_ENABLE.db = bar; 
	FRAME.CB_BAR_REVERSE.db = bar;  
	FRAME.CP_BAR_COLOR.db = bar;  
	FRAME.CP_BAR_FULL_COLOR.db = bar;  
	FRAME.CP_BAR_BG_COLOR.db = bar;  
	FRAME.DDM_BAR_LOCATION.db = bar;  
	FRAME.DDM_BAR_TEXTURE.db = bar;  
	FRAME.SL_BAR_WIDTH.db = bar;  
	FRAME.SL_BAR_HEIGHT.db = bar;
	FRAME.CB_BAR_FILL.db = bar;
	FRAME.CB_BAR_SHOW_SPACK.db = bar;
	FRAME.CB_BAR_USE_FULL_COLOR.db = bar;
	
	FRAME.CB_BAR_NAME_SHOW.db = bar;
	FRAME.DDM_BAR_NAME_ALIGN.db = bar;
	FRAME.SL_BAR_NAME_TEXT_SIZE.db = bar;
	FRAME.SL_BAR_NAME_MARGIN_LEFT.db = bar;
	FRAME.SL_BAR_NAME_MARGIN_RIGHT.db = bar; 
	FRAME.CP_BAR_NAME_COLOR.db = bar;
	FRAME.CP_BAR_NAME_COLOR_OFF.db = bar;
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
			frame:SetChecked(frame.db[frame.key]);
		end
	end
end

-- 프레임 데이터 업데이트함수 - 드롭다운메뉴
local function UpdateFrameDB_DDM(frame, items, value) -- drop down menu
	if frame.db then
		if value ~= nil then
			-- if frame == FRAME.DDM_TRACKER_LIST then
				-- frame.db[frame.key] = HDH_TRACKER_LIST[value];
			-- else
				frame.db[frame.key] = value;
			-- end
		else
			-- if frame == FRAME.DDM_TRACKER_LIST then
				-- local unit = frame.db[frame.key];
				-- local idx = 1;
				-- for i = 1, #HDH_TRACKER_LIST do
					-- if HDH_TRACKER_LIST[i] == unit then idx = i break end
				-- end
				-- HDH_AT_LoadDropDownButton(frame, idx, items);
			-- else
				HDH_AT_LoadDropDownButton(frame, frame.db[frame.key], items);
			-- end
		end
	end
end

-- 프레임 데이터 업데이트함수 - 컬러픽커
local function UpdateFrameDB_CP(frame, r, g, b, a) -- color
	if frame.db then
		if r and g and b then
			frame.db[frame.key] = {r, g, b, a};
		else
			if frame.db[frame.key] then
				local color = {unpack(frame.db[frame.key])};
				_G[frame:GetName().."Preview"]:SetVertexColor(color[1],color[2], color[3]);
			end
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

function HDH_GetSpec(tracker_name) -- 공유 특성이 있으면 공유 특성을 불러온다
	if tracker_name and DB_OPTION[tracker_name].list_share then
		return DB_OPTION[tracker_name].share_spec or CurSpec;
	else
		return CurSpec;
	end
end

function HDH_AT_OP_GetTrackerInfo(idx)
	if not idx then idx = GetTrackerIndex(); end
	if DB_FRAME_LIST[idx] then return DB_FRAME_LIST[idx].name, DB_FRAME_LIST[idx].type, DB_FRAME_LIST[idx].unit
						  else return nil end
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
	local tabname, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local no = rowFrame:GetAttribute("no")
	HDH_DB_DelSpell(HDH_GetSpec(tabname), no, GetTrackerIndex())
	HDH_LoadTrackerListFrame(GetTrackerIndex(), no)
end

local function HDH_AT_OP_SwapRowData(listframe, i1, i2)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local aura = DB_AURA.Talent[HDH_GetSpec(name)][name]
	
	if aura[i1] and aura[i2] then
		local tmp_no = aura[i1].No
		aura[i1].No = aura[i2].No
		aura[i2].No = tmp_no
		local tmp = aura[i1]
		aura[i1] = aura[i2]
		aura[i2] = tmp
		isSwap = true;
	end
	
	local tmp;
	tmp = listframe[i1];
	listframe[i1] = listframe[i2];
	listframe[i2] = tmp;
	
	tmp = listframe[i1].idx;
	listframe[i1].idx = listframe[i2].idx;
	listframe[i2].idx = tmp;
end

local function HDH_AT_OP_OnDragRow(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if self.elapsed < 0.2 then return end
	self.elapsed = 0;
	-- print(self:GetName())
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local aura = DB_AURA.Talent[HDH_GetSpec(name)][name]
	local x,y = self:GetCenter();
	local selfIdx = self.idx;
	local rowFrame;
	local listframe = self:GetParent().row;
	
	for i =1, (#listframe)-1 do
		rowFrame = listframe[i];
		if i ~= selfIdx and rowFrame.mode ~= "add" then 
			local left,bottom,w, h = rowFrame:GetBoundsRect();
			if x >= left and x <= (left+w) and y >=bottom and y<=(bottom+h) then
				if i > selfIdx then 
					for j = selfIdx+1, i do
						listframe[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j-2));
						HDH_AT_OP_SwapRowData(listframe, j-1, j);
						
					end	
				else
					for j = selfIdx-1, i, -1 do
						listframe[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j));
						HDH_AT_OP_SwapRowData(listframe, j+1, j);
					end
				end
				break;
			end
		end
	end
end

local function HDH_AT_OP_OnDragStartRow(self)
	if self.mode ~= "add" then 
		self:StartMoving()
		self:SetToplevel(true);
		self:SetScript('OnUpdate', HDH_AT_OP_OnDragRow)
	end
end

local function HDH_AT_OP_OnDragStopRow(self)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	self:StopMovingOrSizing();
	self:SetScript('OnUpdate', nil);
	HDH_LoadTrackerListFrame(GetTrackerIndex());
	HDH_TRACKER.Get(name):InitIcons();
end

function HDH_GetRowFrame(listFrame, index, flag)
	if not listFrame.row then listFrame.row = {} end
	local f = listFrame.row[index];
	index = tonumber(index)
	if not f and flag == FLAG_ROW_CREATE then
		f = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "RowTemplate")
		if index == 1 then f:SetPoint("TOPLEFT",listFrame,"TOPLEFT") f:SetPoint("TOPLEFT",listFrame,"TOPLEFT")
					  else f:SetPoint("TOPLEFT",listFrame,"TOPLEFT",0,(-f:GetHeight()*(index-1))) end
		f:SetWidth(listFrame:GetParent():GetWidth())
		f:Hide() -- 기본이 hide 중요!
		f:SetScript('OnDragStart', HDH_AT_OP_OnDragStartRow)
		f:SetScript('OnDragStop', HDH_AT_OP_OnDragStopRow)
		f:RegisterForDrag('LeftButton')
		f:EnableMouse(true);
		f:SetMovable(true);
		listFrame.row[index] = f;
	end
	if f then f:SetAttribute("no", index); f.idx = index; end
	return f 
end

function HDH_LoadTrackerListFrame(trackerIdx, startRowIdx, endRowIdx)
	local listFrame = ListFrame
	local aura = {}
	local tracker_name, type, unit = HDH_AT_OP_GetTrackerInfo(trackerIdx or 1)
	local spec = HDH_GetSpec(tracker_name);
	
	if not DB_AURA.Talent[spec] then return end
	aura = DB_AURA.Talent[spec][tracker_name]
	
	local rowFrame
	local i = startRowIdx or 1
	if DB_OPTION[tracker_name] 
		and (HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") or HDH_TRACKER.IsEqualClass(type, "HDH_T_TRACKER") or HDH_TRACKER.IsEqualClass(type, "HDH_USED_SKILL_TRACKER")) 
		and (DB_OPTION[tracker_name].tracking_all or DB_OPTION[tracker_name].tracking_boss_aura) then
		if DB_OPTION[tracker_name].tracking_all then 
			HDH_AT_NoticeAllTracker:Show()
			HDH_AT_NoticeBossTracker:Hide();
		elseif DB_OPTION[tracker_name].tracking_boss_aura then
			HDH_AT_NoticeBossTracker:Show();
			HDH_AT_NoticeAllTracker:Hide();
		end
		listFrame:SetSize(listFrame:GetParent():GetWidth(), ROW_HEIGHT);
		HDH_AT_OP_BtnCreateData:Hide();
	else
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = HDH_GetRowFrame(listFrame, i, FLAG_ROW_CREATE)-- row가 없으면 생성하고, 있으면 그거 재활용
			if not rowFrame:IsShown() then rowFrame:Show() end
			rowFrame:ClearAllPoints();
			if i == 1 	then rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT") 
					    else rowFrame:SetPoint("TOPLEFT",listFrame,"TOPLEFT",0,(-rowFrame:GetHeight()*(i-1))) end
			
			if aura and aura[i] then
				HDH_SetRowData(rowFrame, aura[i].Key, aura[i].No, aura[i].ID, aura[i].Name, aura[i].Always, aura[i].Texture, aura[i].IsItem)
				rowFrame.mode = "data";
			else-- add 를 위한 공백 row 지정
				HDH_ClearRowData(rowFrame)
				rowFrame.mode = "add";
				listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
				if HDH_TRACKER.IsEqualClass(type, "HDH_POWER_TRACKER") -- 자원
					or HDH_TRACKER.IsEqualClass(type, "HDH_COMBO_POINT_TRACKER") -- 콤보
					or HDH_TRACKER.IsEqualClass(type, "HDH_DK_RUNE_TRACKER") -- 죽기 룬
					or HDH_TRACKER.IsEqualClass(type, "HDH_STAGGER_TRACKER") -- 시간차
					or HDH_TRACKER.IsEqualClass(type, "HDH_HEALTH_TRACKER") then
					if HDH_TRACKER.Get(tracker_name):IsHaveData(spec) then
						HDH_AT_OP_BtnCreateData:Hide();
					else
						HDH_AT_OP_BtnCreateData:Show();
					end
					rowFrame:Hide()
				else HDH_AT_OP_BtnCreateData:Hide(); end
				break
			end
			if endRowIdx and endRowIdx == i then return end
			i = i + 1
		end
		HDH_AT_NoticeAllTracker:Hide();
		HDH_AT_NoticeBossTracker:Hide();
		--HDH_AT_NoticeAllTracker_Boss:Hide();
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
	local name, id, icon, isItem = HDH_AT_UTIL.GetInfo(key, item)
	local tracker_name, type = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if name then
		if not HDH_DB_SaveSpell(key, HDH_GetSpec(tracker_name), no, id, name, always, icon, isItem, GetTrackerIndex()) then
			HDH_OP_AlertDlgShow(name.."("..id..") 은(는) 이미 등록된 주문입니다.")
			return nil
		end
		if isItem then
			
			if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then
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
-- profile function
------------------------------------------

-- 전문화 매칭 기능 로드
function HDH_AT_OP_LoadProfileSpec(self, profile_name)
	local list
	if DB_PROFILE[profile_name].AURA_LIST then
		
		-- 프로필캐릭터 전문화 목록 버튼 만들 --
		list = self:GetParent().profileSpec;
		list:Show();
		local p_talent = DB_PROFILE[profile_name].AURA_LIST.Talent;
		if not list.row then list.row = {} end
		for i = 1, #p_talent do
			if not list.row[i] then
				local new = CreateFrame("Button", list:GetName()..i, list, "HDH_AT_ButtonTemplate");
				-- new.arrow = new:CreateFontString(nil,"OVERLAY","GAMEFONTNORMAL");
				-- new.arrow:SetText("----->");
				new.arrow = new:CreateTexture(nil,"OVERLAY");
				new.arrow:SetTexture("Interface\\Vehicles\\Arrow");
				new.arrow:SetBlendMode("ADD");
				new.arrow:SetSize(40,15);
				new.arrow:SetPoint("LEFT",new,"RIGHT",10,0);
				-- new.arrow:SetTextColor(1,1,1);
				if i == 1 then
					new:SetPoint("TOP",0,0);
				else
					new:SetPoint("TOP",list.row[i-1],"BOTTOM",0,0);
				end
				list.row[i] = new;
			end
			list.row[i]:Show();
			list.row[i]:SetText(p_talent[i].Name);
			list.row[i].id = p_talent[i].ID;
		end
		for i = #p_talent+1, #list.row do 
			list.row[i]:Hide();
		end
		
		-- 현재 전문화 목록 버튼 만들 --
		list = self:GetParent().curSpec;
		list:Show();
		if not list.row then list.row = {} end
		local id, talent
		for i =1, 4 do
			id, talent = GetSpecializationInfo(i)
			if id then
				if not list.row[i] then
					local new = CreateFrame("Frame", list:GetName()..i, list, "HDH_AT_ProfileSpceTemplate");
					new.spec = _G[new:GetName().."ButtonSpec"];
					if i == 1 then
						new:SetPoint("TOP",0,0);
					else
						new:SetPoint("TOP",list.row[i-1],"BOTTOM",0,0);
					end
					list.row[i] = new;
				end
				list.row[i]:Show();
				list.row[i].spec:SetText(talent);
				list.row[i].talent = { name = talent, id = id , index = i};
				list.row[i].index = i;
			end
		end
		self:GetParent().loadBtn:Show();
	end
end

local function SwapProfileSpec(v1, v2)
	local tmp = v1.talent;
	v1.talent = v2.talent;
	v2.talent = tmp;
	v1.spec:SetText(v1.talent.name);
	v2.spec:SetText(v2.talent.name);
end

function HDH_AT_OP_OnClickProSpecOrder(self, arrow)
	local list = self:GetParent():GetParent().row;
	local index = self:GetParent().index;
	local target;
	if arrow == 1 then -- up
		target = list[index-1];
	else -- down
		target = list[index+1];
	end
	if target then
		CrateAni(target);
		CrateAni(list[index]);
		list[index].ani.func = nil;
		list[index].ani.args = nil;
		target.ani.func = SwapProfileSpec
		target.ani.args = {target, list[index]}
		
		StartAni(list[index], (arrow == 1) and ANI_MOVE_UP or ANI_MOVE_DOWN);
		StartAni(target, (arrow == 1) and ANI_MOVE_DOWN or ANI_MOVE_UP)
	end
end

function HDH_OnShow_ProfileFrame(self, seleted_profile)
	local dataTable = {}
	local idx;
	if DB_PROFILE then
		for k,v in pairs(DB_PROFILE) do
			dataTable[#dataTable+1] = k
			if seleted_profile and seleted_profile == k then
				idx = #dataTable;
			end
		end
	end
	HDH_AT_LoadDropDownButton(FRAME.DDM_PROFILE, idx, dataTable, HDH_AT_OP_OnSelectedItem_DDM)
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE);
	-- print(name)
	self.profileSpec = _G[self:GetName().."ProfileSpecList"];
	self.curSpec = _G[self:GetName().."CurSpecList"];
	self.loadBtn = _G[self:GetName().."ButtonLoad"];
	self.profileSpec:Hide();
	self.curSpec:Hide();
	self.loadBtn:Hide();
end 

function HDH_OnClick_SaveProfile()
	if not DB_PROFILE then
		DB_PROFILE = {}
	end
	local ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M:%S")..")"
	DB_PROFILE[ID_NAME] = {}
	DB_PROFILE[ID_NAME].OPTION = HDH_AT_UTIL.Deepcopy(DB_OPTION)
	DB_PROFILE[ID_NAME].FRAME_LIST = HDH_AT_UTIL.Deepcopy(DB_FRAME_LIST)
	DB_PROFILE[ID_NAME].AURA_LIST = HDH_AT_UTIL.Deepcopy(DB_AURA)
	DB_PROFILE[ID_NAME].ID_NAME = ID_NAME
	HDH_OnShow_ProfileFrame(FRAME.PROFILE)
end

local cr;
local cnt  = 0;

local loadingText = {"+----","-+---","--+--","---+-","----+","---+-","--+--","-+---"};
loadingText.Idx =1;
local function serialize(o)
    local ret;
    if type(o) == "number" then
		if o % 1 > 0 then 
			ret = string.format("%.2f",o)
		else
			ret = o;
		end
    elseif type(o) == "string" then
        ret = string.format("\"%s\"",o);
	elseif type(o) == "boolean" then
		ret = string.format("%s", o and "true" or "false");
    elseif type(o) == "table" then
        ret = "{"
        for key, value in next, o, nil do
			local data = serialize(value);
			-- if data then
				-- ret = string.format("%s%s=%s,",ret,key,serialize(value) or "nil");
			-- end
			if type(key) == "number" then
				ret = string.format("%s[%s]=%s,",ret,key,serialize(value) or "nil");
			else
				ret = string.format("%s[\"%s\"]=%s,",ret,key,serialize(value) or "nil");
			end
        end
		ret = ret .. "}"
    end
	cnt = cnt + 1;
	if cnt % 10000 == 0 then
		-- print("progress..", cnt)
		HDH_OP_AlertDlgHide(); 
		HDH_OP_AlertDlgShow("데이터를 생성 중입니다.\r\n기다려 주세요\n"..loadingText[loadingText.Idx % #loadingText +1], HDH_AT_OP.DLG_TYPE.NONE);
		loadingText.Idx = loadingText.Idx +1;
		coroutine.yield()
	end
    return ret;
end

local function deserialize(str)
	return assert(loadstring("return "..str))();
end

function HDH_AT_LoadImportAndExportProfile(type)
	local body = HDH_AT_ImportAndExportProfileFrame;
	local edName = _G[body:GetName().."EditBoxName"];
	local edData = _G[body:GetName().."EditBoxData"];
	local btnImport = _G[body:GetName().."BtnImport"];
	local btnExport = _G[body:GetName().."BtnExport"];
	edName:SetText("");
	edData:SetText("");
	if type == "Export" then
		edName:Show();
		edData:Hide();
		btnImport:Hide();
		btnExport:Show();
		-- HDH_OnClick_ExportProfile();
	else -- import
		edName:Hide();
		edData:Show();
		btnImport:Show();
		btnExport:Hide();
	end
	HDH_AT_ImportAndExportProfileFrame:Show();
end

local Compresser 
local Serializer
local Encoder
function HDH_OnClick_ExportProfile()
	cr = coroutine.create(
		function()
			-- HDH_AT_ImportAndExportProfileFrame:Hide();
			-- HDH_OP_AlertDlgShow("데이터를 생성 중입니다.\r\n기다려 주세요", HDH_AT_OP.DLG_TYPE.NONE, function() HDH_AT_ImportAndExportProfileFrame:Show(); end);
			local body = HDH_AT_ImportAndExportProfileFrame;
			local edName = _G[body:GetName().."EditBoxName"];
			local edData = _G[body:GetName().."EditBoxData"];
			local btnExport = _G[body:GetName().."BtnExport"];
			local DB = {}
			local ID_NAME = edName:GetText().."("..date("%m/%d %H:%M:%S")..")"
			local name = edName:GetText();
			name = HDH_AT_UTIL.Trim(name);
			if not name or #name == 0 then 
				HDH_OP_AlertDlgHide();
				HDH_OP_AlertDlgShow("설정 이름을 입력해주세요", HDH_AT_OP.DLG_TYPE.OK, function() HDH_AT_ImportAndExportProfileFrame:Show(); end);
				return 1; 
			end
			DB.OPTION = HDH_AT_UTIL.Deepcopy(DB_OPTION)
			DB.FRAME_LIST = HDH_AT_UTIL.Deepcopy(DB_FRAME_LIST)
			DB.AURA_LIST = HDH_AT_UTIL.Deepcopy(DB_AURA)
			DB.ID_NAME = ID_NAME
			-- local serialized = serialize(DB);
			-- local data = string.gsub(serialized,"\\","\\\\"); 
			data = WeakAuraLib_TableToString(DB, true);
			-- edData:SetText(data);
			-- local str = edData:GetText();
			-- data = WeakAuraLib_StringToTable(data, true);
			if not data then 
				HDH_OP_AlertDlgHide();
				HDH_OP_AlertDlgShow("생성에 실패하였습니다.", HDH_AT_OP.DLG_TYPE.OK, function() HDH_AT_ImportAndExportProfileFrame:Show(); end);
				return 1;
			end
			
			btnExport:Hide();
			edName:Hide();
			edData:SetText(data);
			edData:Show();
			HDH_OP_AlertDlgHide();
			HDH_OP_AlertDlgShow("생성 되었습니다.\n\r[ Crtl + C ] 를 활용하여, 공유 하세요", HDH_AT_OP.DLG_TYPE.OK, function() HDH_AT_ImportAndExportProfileFrame:Show(); end);
			edData:SetFocus();
			return 1;
		end
	);
	coroutine.resume(cr);
end

local th = CreateFrame("Frame",nil,UIParent);
th:SetScript("OnUpdate",
	function()
		-- print(cr)
		if cr then
			if coroutine.status(cr) == "suspended" then
				local ret = coroutine.resume(cr);
				-- print(ret);
				if ret == 1 then
					cr = nil;
				end
			end
		end
	end
);

function HDH_OnClick_ImportProfile()
	local body = HDH_AT_ImportAndExportProfileFrame;
	local edData = _G[body:GetName().."EditBoxData"];
	local str = edData:GetText();
	-- local data = deserialize(str);
	local data = WeakAuraLib_StringToTable(str, true);
	edData:SetText(str);
	if data == nil then HDH_OP_AlertDlgShow("잘못된 설정값입니다. 다시 확인해주세요.") return end
	if data then
		if not DB_PROFILE then
			DB_PROFILE = {}
		end
		local ID_NAME = data.ID_NAME;
		DB_PROFILE[ID_NAME] = {}
		DB_PROFILE[ID_NAME].OPTION = HDH_AT_UTIL.Deepcopy(data.OPTION)
		DB_PROFILE[ID_NAME].FRAME_LIST = HDH_AT_UTIL.Deepcopy(data.FRAME_LIST)
		DB_PROFILE[ID_NAME].AURA_LIST = HDH_AT_UTIL.Deepcopy(data.AURA_LIST)
		DB_PROFILE[ID_NAME].ID_NAME = ID_NAME
		-- HDH_OnShow_ProfileFrame(FRAME.PROFILE, ID_NAME)
		-- HDH_AT_OP_LoadProfileSpec(FRAME.DDM_PROFILE, ID_NAME)
		HDH_OP_AlertDlgShow(ID_NAME.." (으)로\n\r새로운 프로필이 생성되었습니다.");
		OptionFrame:Hide();
		OptionFrame:Show();
	end
	-- local ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M:%S")..")"
end

function HDH_OnClick_LoadProfile(self)
	local parent = self:GetParent();
	local curSpeclist = parent.curSpec.row;
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE)
	if DB_PROFILE and DB_PROFILE[name] then
		DB_OPTION = HDH_AT_UTIL.Deepcopy(DB_PROFILE[name].OPTION)
		DB_FRAME_LIST = HDH_AT_UTIL.Deepcopy(DB_PROFILE[name].FRAME_LIST)
		
		if DB_PROFILE[name].AURA_LIST then
			DB_AURA = {}
			DB_AURA.Talent = {}
			local id, talent
			for i =1, 4 do
				if curSpeclist[i] then
					local cpyIdx = curSpeclist[i].talent.index;
					if DB_PROFILE[name].AURA_LIST.Talent[i] then
						DB_AURA.Talent[cpyIdx] = HDH_AT_UTIL.Deepcopy(DB_PROFILE[name].AURA_LIST.Talent[i]);
						id, talent = GetSpecializationInfo(cpyIdx);
						DB_AURA.Talent[cpyIdx].ID = id;
						DB_AURA.Talent[cpyIdx].Name = talent;
					else
						id, talent = GetSpecializationInfo(i);
						DB_AURA.Talent[i] = {ID = id, Name = talent} 
					end
				end
			end
			-- DB_AURA = HDH_AT_UTIL.Deepcopy(DB_PROFILE[name].AURA_LIST)
		else
			DB_AURA = nil;
		end
		
		ReloadUI() 
	else
		HDH_OP_AlertDlgShow("프로필 정보를 찾을 수 없습니다.")
	end
end

function HDH_OnClick_DelProfile()
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE)
	if not name then return end
	DB_PROFILE[name] = nil
	HDH_OnShow_ProfileFrame(FRAME.PROFILE)
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
				-- break 
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

local function HDH_AT_OP_SwapTrackerRowData(listframe, i1, i2)
	local tmp;
	tmp = listframe[i1];
	listframe[i1] = listframe[i2];
	listframe[i2] = tmp;
	
	tmp = listframe[i1].idx;
	listframe[i1].idx = listframe[i2].idx;
	listframe[i2].idx = tmp;
	
	tmp = DB_FRAME_LIST[listframe[i1].idx];
	DB_FRAME_LIST[listframe[i1].idx] = DB_FRAME_LIST[listframe[i2].idx];
	DB_FRAME_LIST[listframe[i2].idx] = tmp;
end

local function HDH_AT_OP_OnDragTrackerRow(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if self.elapsed < 0.2 then return end
	self.elapsed = 0;
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local aura = DB_AURA.Talent[HDH_GetSpec(name)][name]
	local x,y = self:GetCenter();
	local selfIdx = self.idx;
	local rowFrame;
	local listframe = TRACKER_TAB_BTN_LIST;
	
	for i =1, listframe.count do
		rowFrame = listframe[i];
		if i ~= selfIdx then 
			local left,bottom,w, h = rowFrame:GetBoundsRect();
			if x >= left and x <= (left+w) and y >=bottom and y<=(bottom+h) then
				if i > selfIdx then 
					for j = selfIdx+1, i do
						listframe[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j-2));
						HDH_AT_OP_SwapTrackerRowData(listframe, j-1, j);
						
					end	
				else
					for j = selfIdx-1, i, -1 do
						listframe[j]:SetPoint("TOPLEFT", 0, -self:GetHeight()*(j));
						HDH_AT_OP_SwapTrackerRowData(listframe, j+1, j);
					end
				end
				break;
			end
		end
	end
end

local function HDH_AT_OP_OnDragStartTrackerRow(self)
	self:StartMoving()
	self:SetToplevel(true);
	-- self:SetClampedToScreen(true)
	-- local left,bottom,w, h = self:GetParent():GetBoundsRect();
	-- self:SetClampRectInsets(-left, GetScreenWidth()-left-w, GetScreenHeight() - bottom-h, -bottom) 
	self:LockHighlight();
	HDH_AT_OP_ChangeTracker(self.idx);
	self:SetScript("OnUpdate",HDH_AT_OP_OnDragTrackerRow);
end

local function HDH_AT_OP_OnDragStopTrackerRow(self)
	self:StopMovingOrSizing();
	self:SetScript("OnUpdate",nil);
	-- self:SetClampedToScreen(false);
	self:UnlockHighlight();
	local selfIdx = self:GetID();
	local rowFrame;
	local listframe = TRACKER_TAB_BTN_LIST;
	for i =1, listframe.count do
		rowFrame = listframe[i];
		rowFrame:ClearAllPoints();
		rowFrame:SetPoint("TOPLEFT",self:GetParent(),"TOPLEFT", 0, -self:GetHeight()*(i-1));
	end
	HDH_RefreshFrameLevel_All();
	AddTrackerFrameTextTrackerOrder:SetText(selfIdx);
	HDH_AT_OP_ChangeTracker(self.idx);
end

function HDH_AT_OP_AddTrackerButton(name, type, unit, idx)
	local listFrame = TRACKER_LIST_FRAME;
	local count = TRACKER_TAB_BTN_LIST.count or 0;
	local newButton;
	if not name or not unit or not type then return; end
	if idx and TRACKER_TAB_BTN_LIST[idx] then
		newButton = TRACKER_TAB_BTN_LIST[idx];
	elseif not idx and TRACKER_TAB_BTN_LIST[count+1] then
		count = count + 1;
		newButton = TRACKER_TAB_BTN_LIST[count];
		listFrame:SetSize(listFrame:GetParent():GetWidth(), (count+1) * newButton:GetHeight()); -- 추가버튼 공간까지 +1
	else
		newButton = CreateFrame("BUTTON", listFrame:GetName().."BtnTracker"..(count+1), listFrame, "HDH_AT_RowTapBtnTemplate");
		newButton:SetScript("OnClick", HDH_AT_OP_OnChangeTracker);
		newButton:SetWidth(listFrame:GetParent():GetWidth());
		_G[newButton:GetName().."Text"]:SetPoint("LEFT",newButton,"LEFT", 10, 0);
		_G[newButton:GetName().."Text"]:SetPoint("RIGHT",newButton,"RIGHT", -10, 0);
		_G[newButton:GetName().."Text"]:SetJustifyH("RIGHT");
		count = count + 1;
		newButton.idx = count;
		TRACKER_TAB_BTN_LIST[count] = newButton;
		listFrame:SetSize(listFrame:GetParent():GetWidth(), (count+1) * newButton:GetHeight()); -- 추가버튼 공간까지 +1
		newButton:SetID(count);
		newButton:SetScript('OnDragStart', HDH_AT_OP_OnDragStartTrackerRow)
		newButton:SetScript('OnDragStop', HDH_AT_OP_OnDragStopTrackerRow)
		newButton:SetScript('OnEnter', HDH_AT_OP_OnEnterTrackerRow)
		newButton:RegisterForDrag('LeftButton')
		newButton:EnableMouse(true);
		newButton:SetMovable(true);
	end
	newButton:Show();
	if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then
		newButton:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,(type..":"..unit)));
	else
		newButton:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,type));
	end
	newButton.name = name;
	newButton.type = type;
	newButton.unit = unit;
	
	
	if not idx then idx = newButton.idx end
	if (idx == 1) then
		newButton:SetPoint("TOPLEFT",listFrame,"TOPLEFT");
	else
		newButton:SetPoint("TOPLEFT",listFrame,"TOPLEFT", 0, -newButton:GetHeight()*(idx-1));
	end
	
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
	
	local typeText;
	for i = idx , #list-1 do
		list[i].name = list[i+1].name;
		list[i].unit = list[i+1].unit;
		list[i].type = list[i+1].type;
		
		if HDH_TRACKER[list[i].type] then
			typeText = list[i].type..":"..list[i].unit;
		else
			typeText = list[i].type;
		end
		list[i]:SetText(string.format(STR_TRACKER_BTN_FORMAT, list[i].name, typeText));
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
		
		tmp = list[idx1]:GetText();
		list[idx1]:SetText(list[idx2]:GetText());
		list[idx2]:SetText(tmp);
		
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

-- 애드온 통합된 지금은 무의미 함.(v7)
function HDH_AT_OP_OnChangeTracker(self) -- script 펑션은 후킹이 안됨(v6)
	HDH_AT_OP_ChangeTracker(self.idx) -- hooking 가능 하도록(v6)
end

function HDH_OnClickCreateAndModifyTracker(self)
	local mode = self:GetParent().mode
	local ddm = FRAME.DDM_TRACKER_TYPE_LIST;
	local ed = _G[self:GetParent():GetName().."EditBoxName"]
	local err = _G[self:GetParent():GetName().."TextE"]
	local name = HDH_AT_UTIL.Trim(ed:GetText())
	local type = HDH_TRACKER_LIST[ddm.id];
	local unit = "player"; -- 기본값
	ed:SetText(name or "")
	if name and name ~= "" and type then
		if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then -- 오라면
			unit = HDH_UNIT_LIST[FRAME.DDM_UNIT_LIST.id];
			if unit == nil then
				HDH_OP_AlertDlgShow("추적 대상을 선택해주세요.")
				return 
			end
		end
		if mode == "add" then
			local tracker = HDH_TRACKER.Get(name)
			if not tracker then
				tracker = HDH_TRACKER.new(name, type, unit)
				HDH_DB_Add_FRAME_LIST(name, type, unit)
				g_CurMode = BODY_TYPE.AURA;
				local idx = HDH_AT_OP_AddTrackerButton(name, type, unit);
				Match_Tracker_DBForFrame(idx);
				UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA, FRAME.CB_TRACKER_ALL_AURA:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA, FRAME.CB_TRACKER_BOSS_AURA:GetChecked());
				-- UpdateFrameDB_CB(FRAME.CB_TRACKER_BUFF, FRAME.CB_TRACKER_BUFF:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_MINE, FRAME.CB_TRACKER_MINE:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_MERGE_POWERICON, FRAME.CB_TRACKER_MERGE_POWERICON:GetChecked());
				HDH_AT_OP_ChangeTracker(idx);
				if UI_LOCK then
					tracker:SetMove(true)
					tracker:CreateDummySpell(HDH_TRACKER.MAX_ICONS_COUNT)
					tracker.frame:Show()
					tracker:UpdateIcons()
				end
				if DB_OPTION[name].tracking_all or DB_OPTION[name].tracking_boss_aura then
					tracker:InitIcons()
				end
			else
				HDH_OP_AlertDlgShow(name.." 은(는) 이미 존재하는 이름입니다.")
				return
			end
		elseif mode =="modify" then
			local curName, curType, curUnit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
			local tracker = HDH_TRACKER.Get(curName);
			if not tracker then return end
			local isExist = HDH_TRACKER.Get(name) and true or false;
			if isExist and (name ~= curName) then -- 존재하는 이름인데, 현재 이름과 다르면, 이름을 수정하는 상태임
				ed:SetText(curName)
				HDH_OP_AlertDlgShow(name.." 은(는) 이미 존재하는 이름입니다.")
				return
			else 
				if (curName ~= name) or (type ~= curType) or (unit ~= curUnit) then
					tracker:Modify(name, type, unit);
					HDH_AT_OP_UpdateTitle();
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()].name = name;
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()].unit = unit;
					TRACKER_TAB_BTN_LIST[GetTrackerIndex()].type = type;
					if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then
						TRACKER_TAB_BTN_LIST[GetTrackerIndex()]:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,(type..":"..unit)));
					else
						TRACKER_TAB_BTN_LIST[GetTrackerIndex()]:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,type));
					end
				end
				
				UpdateFrameDB_CB(FRAME.CB_TRACKER_MERGE_POWERICON, FRAME.CB_TRACKER_MERGE_POWERICON:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA, FRAME.CB_TRACKER_ALL_AURA:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA, FRAME.CB_TRACKER_BOSS_AURA:GetChecked());
				-- UpdateFrameDB_CB(FRAME.CB_TRACKER_BUFF, FRAME.CB_TRACKER_BUFF:GetChecked());
				--FRAME.CB_TRACKER_DEBUFF:SetChecked(!FRAME.CB_TRACKER_BUFF:GetChecked());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_MINE, FRAME.CB_TRACKER_MINE:GetChecked());
				--self:GetParent():Hide()
				if UI_LOCK then tracker:SetMove(UI_LOCK);
				           else tracker:InitIcons(); end
			end
		end
	else
		if ddm.id == 0 then
			HDH_OP_AlertDlgShow("추적 종류를 선택해주세요.")
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
	local curSpec = HDH_GetSpec(srcName);
	if (srcSpec == curSpec) and (srcName == dstName) then return end
	
	DB_AURA.Talent[curSpec][dstName] = HDH_AT_UTIL.Deepcopy(DB_AURA.Talent[srcSpec][srcName])
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
	HDH_OP_AlertDlgShow("현재 추적 창의 오라 목록을 '"..name.."'의 목록으로\n|cffffffff교체 하시겠습니까?\n|cffff0000(기존 목록은 삭제 됩니다)", HDH_AT_OP.DLG_TYPE.YES_NO, 
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
-- Grid
------------------------------------------

local function DrawLine(frame, x, y, total, point1, point2)
	local i = 1;
	local size = math.abs(x) > math.abs(y) and x or y;
	size = math.abs(size);
	local t;
	while (total/2) > size*i do
		t = frame:CreateTexture(nil, "BACKGROUND");
		t:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg.blp");
		t:SetVertexColor(0,0,0, 0.45);
		if i % 5 == 0 then
			t:SetSize(3,3);
		else
			t:SetSize(1,1);
		end
		t:SetPoint(point1,UIParent,point1, x*i, y*i);
		t:SetPoint(point2,UIParent,point2,0,0);
		i = i+1;
	end
end

function HDH_AT_OP_ShowGrid(frame, show)
	local size = GRID_SIZE;
	if show then 
		if not frame.GridFrame then
			frame.GridFrame = CreateFrame("Frame",nil,UIParent);
			local t;
			local displayX, displayY = UIParent:GetSize();
			-- local space = 0;
			
			DrawLine(frame.GridFrame,size,0,displayX,"TOP","BOTTOM");
			DrawLine(frame.GridFrame,-size,0,displayX, "TOP","BOTTOM");
			DrawLine(frame.GridFrame,0,size,displayY,"LEFT","RIGHT");
			DrawLine(frame.GridFrame,0,-size,displayY,"LEFT","RIGHT");
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("LEFT",UIParent,"LEFT",0,0);
			t:SetPoint("RIGHT",UIParent,"RIGHT",0,0);
			
			t = frame.GridFrame:CreateTexture(nil, "BACKGROUND");
			t:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg.blp");
			t:SetVertexColor(1,0,0, 0.5);
			t:SetSize(3,3);
			t:SetPoint("TOP",UIParent,"TOP",0,0);
			t:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0);
		
		-- frame.hdh_at_option_move_line = t;
		end
		frame.GridFrame:Show();
	else
		if frame.GridFrame then frame.GridFrame:Hide(); end
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
	a = a and a or 1;
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
	
	UpdateFrameDB_CB(FRAME.CB_EACH);
	UpdateFrameDB_CB(FRAME.CB_SHOW_ID);
	FRAME.CB_MOVE:SetChecked(UI_LOCK);
	
	UpdateFrameDB_SL(FRAME.SL_ICON_SIZE, nil, 20, 400);
	UpdateFrameDB_SL(FRAME.SL_MARGIN_H, nil, 1, 300);
	UpdateFrameDB_SL(FRAME.SL_MARGIN_V, nil, 1, 300);
	UpdateFrameDB_SL(FRAME.SL_ON_ALPHA, nil, nil, nil, 100);
	UpdateFrameDB_SL(FRAME.SL_OFF_ALPHA, nil, nil, nil, 100);
	UpdateFrameDB_CB(FRAME.CB_COLOR_DEBUFF_DEFAULT);
	UpdateFrameDB_CB(FRAME.CB_ABLE_BUFF_CANCEL);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_BUFF);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_DEBUFF);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_CD_BG);
	UpdateFrameDB_CB(FRAME.CB_HIDE_ICON);
	UpdateFrameDB_CB(FRAME.CB_BAR_FILL);
	UpdateFrameDB_CB(FRAME.CB_BAR_SHOW_SPACK);
	
	--HDH_AT_OP_LoadFontSetting(curTracker);
	UpdateFrameDB_CB(FRAME.CB_SHOW_CD);
	UpdateFrameDB_CB(FRAME.CB_ALWAYS_SHOW);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_FONT_CD5);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_FONT1);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_FONT2);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_FONT3);
	UpdateFrameDB_CP(FRAME.BTN_COLOR_FONT4);
	UpdateFrameDB_DDM(FRAME.DDM_TIME_TYPE, DDM_TIME_TYPE);
	UpdateFrameDB_DDM(FRAME.DDM_FONT_LOC1, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_FONT_LOC2, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_FONT_LOC3, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_FONT_LOC4, DDM_FONT_LOCATION_LIST);
	UpdateFrameDB_SL(FRAME.SL_FONT_SIZE1, nil, 5, 32);
	UpdateFrameDB_SL(FRAME.SL_FONT_SIZE2, nil, 5, 32);
	UpdateFrameDB_SL(FRAME.SL_FONT_SIZE3, nil, 5, 32);
	UpdateFrameDB_SL(FRAME.SL_FONT_SIZE4, nil, 5, 32);
	
	-- bar--
	UpdateFrameDB_CB(FRAME.CB_BAR_ENABLE);
	UpdateFrameDB_CB(FRAME.CB_BAR_REVERSE);
	UpdateFrameDB_CB(FRAME.CB_BAR_USE_FULL_COLOR);
	UpdateFrameDB_SL(FRAME.SL_BAR_WIDTH , nil, 10, 400);
	UpdateFrameDB_SL(FRAME.SL_BAR_HEIGHT  , nil, 10, 400);
	UpdateFrameDB_CP(FRAME.CP_BAR_COLOR);
	UpdateFrameDB_CP(FRAME.CP_BAR_FULL_COLOR);
	UpdateFrameDB_CP(FRAME.CP_BAR_BG_COLOR);
	UpdateFrameDB_DDM(FRAME.DDM_BAR_LOCATION, DDM_BAR_LOCATION_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_BAR_TEXTURE, DDM_BAR_TEXTURE_LIST);
	--bar text--
	UpdateFrameDB_CB(FRAME.CB_BAR_NAME_SHOW );
	UpdateFrameDB_SL(FRAME.SL_BAR_NAME_TEXT_SIZE , nil, 5, 32);
	UpdateFrameDB_SL(FRAME.SL_BAR_NAME_MARGIN_LEFT  , nil, 2, 100);
	UpdateFrameDB_SL(FRAME.SL_BAR_NAME_MARGIN_RIGHT   , nil, 2, 100);
	UpdateFrameDB_DDM(FRAME.DDM_BAR_NAME_ALIGN, DDM_BAR_NAME_ALIGN_LIST);
	UpdateFrameDB_CP(FRAME.CP_BAR_NAME_COLOR);
	UpdateFrameDB_CP(FRAME.CP_BAR_NAME_COLOR_OFF);
	
	if ( not curTracker ) then
		FRAME.CB_EACH:SetChecked(false);
		FRAME.CB_EACH:Disable();
	else
		FRAME.CB_EACH:Enable();
	end
	
	local type = select(2,HDH_AT_OP_GetTrackerInfo(curTracker))
	
	if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then FRAME.CB_ABLE_BUFF_CANCEL:Show();
	else FRAME.CB_ABLE_BUFF_CANCEL:Hide(); end
	
	if curTracker and type and HDH_C_TRACKER and HDH_TRACKER.IsEqualClass(type, "HDH_C_TRACKER") then
		UpdateFrameDB_SL(FRAME.SL_CT_MAXTIME, nil, -1, 3000);
		UpdateFrameDB_CB(FRAME.CB_CT_DESAT);
		UpdateFrameDB_CB(FRAME.CB_CT_DESAT_NOTENOUGHMANA);
		UpdateFrameDB_CB(FRAME.CB_CT_DESAT_OUTRANGE);
		UpdateFrameDB_CB(FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN);
		UpdateFrameDB_CP(FRAME.CP_CT_COLOR);
		UpdateFrameDB_CP(FRAME.CP_CT_NOTENOUGHMANA);
		UpdateFrameDB_CP(FRAME.CP_CT_OUTRANGE);
		-- FRAME.SL_CT_MAXTIME:Show();
		-- FRAME.CB_CT_DESAT:Show();
		-- FRAME.CP_CT_COLOR:Show();
		CooldownSettingFrame:Show();
		FRAME.CB_COLOR_DEBUFF_DEFAULT:Hide();
		FRAME.BTN_COLOR_BUFF:Hide();
		FRAME.BTN_COLOR_DEBUFF:Hide();
		--FRAME.BTN_COLOR_CD_BG:Hide();
	else
		CooldownSettingFrame:Hide();
		-- FRAME.SL_CT_MAXTIME:Hide();
		-- FRAME.CB_CT_DESAT:Hide();
		-- FRAME.CP_CT_COLOR:Hide();
		FRAME.CB_COLOR_DEBUFF_DEFAULT:Show();
		FRAME.BTN_COLOR_BUFF:Show();
		FRAME.BTN_COLOR_DEBUFF:Show();
		--FRAME.BTN_COLOR_CD_BG:Show();
	end
end

function HDH_AT_OP_LoadTrackerBasicSetting(curTracker)	
	UpdateFrameDB_CB(FRAME.CB_REVERS_H);
	UpdateFrameDB_CB(FRAME.CB_REVERS_V);
	UpdateFrameDB_CB(FRAME.CB_ICON_FIX);
	UpdateFrameDB_SL(FRAME.SL_LINE);
	UpdateFrameDB_CB(FRAME.CB_SHOW_TOOLTIP);
	UpdateFrameDB_DDM(FRAME.DDM_CD_TYPE, DDM_COOLDOWN_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_ORDER_BY, DDM_ICON_ORDER_LIST);
	UpdateFrameDB_CB(FRAME.CB_LIST_SHARE);
	UpdateFrameDB_CB(FRAME.CB_TRACKER_MERGE_POWERICON);
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
		HDH_AT_OP_LoadSetting(idx); 	
		RowDetailSetFrame:Hide();
	elseif (bodyType == BODY_TYPE.AURA_DETAIL) then
	
	end
end

function HDH_AT_OP_UpdateTitle()
	local name, type = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	local w = TalentText:GetStringWidth()
	OptionFrameTitleFrameTextTracker:SetPoint("LEFT",TalentText, "LEFT", w+5, 0)
	
	if name then
		OptionFrameTitleFrameTextTracker:SetText("> "..name)
		OptionFrameTitleFrameTextUnit:SetText(("(%s)"):format(type:gsub("^%l", string.upper)))
		w = OptionFrameTitleFrameTextTracker:GetStringWidth()
		OptionFrameTitleFrameTextUnit:SetPoint("LEFT",OptionFrameTitleFrameTextTracker, "LEFT", w+5, 0)
	else
		OptionFrameTitleFrameTextUnit:SetText("");
		OptionFrameTitleFrameTextTracker:SetText("> New Tracker");
	end
end

function HDH_AT_OP_LoadAuraListFrame(trackerIdx)
	local name, type = HDH_AT_OP_GetTrackerInfo(trackerIdx);
	if name then
		HDH_LoadTrackerListFrame(trackerIdx);
		Match_Tracker_DBForFrame(trackerIdx);
		HDH_AT_OP_LoadTrackerBasicSetting(trackerIdx);
		--UnitOptionFrameTabModify:SetPoint("LEFT",UnitOptionFrameTextTitle2,"LEFT",UnitOptionFrameTextTitle2:GetStringWidth()+10,0)
	end
end

function HDH_AT_OP_LoadCreateTrackerFrame(trackerIdx)
	if trackerIdx then -- 인덱스가 있으면 수정모드
		local name, type, unit = HDH_AT_OP_GetTrackerInfo(trackerIdx)
		if not name then return; end
		_G[AddTrackerFrame:GetName().."EditBoxName"]:SetText(name)
		AddTrackerFrame.mode = "modify"
		AddTrackerFrameText1:SetText("추적 창 수정")
		AddTrackerFrameButtonCreateAndModifyTracker:SetText("적용")
		AddTrackerFrameButtonDeleteUnit:Enable()
		
		for i = 1 , #HDH_TRACKER_LIST do
			if type == HDH_TRACKER_LIST[i] then
				HDH_AT_LoadDropDownButton(FRAME.DDM_TRACKER_TYPE_LIST, i, HDH_TRACKER_LIST);
			end
		end
		
		if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then
			-- UpdateFrameDB_CB(FRAME.CB_TRACKER_BUFF);
			-- FRAME.CB_TRACKER_DEBUFF:SetChecked(not FRAME.CB_TRACKER_BUFF:GetChecked());
			UpdateFrameDB_CB(FRAME.CB_TRACKER_MINE);
			UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
			UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA);
			FRAME.CB_TRACKER_ALL_AURA:Show();
			FRAME.CB_TRACKER_BOSS_AURA:Show();
			-- FRAME.CB_TRACKER_DEBUFF:Show();
			-- FRAME.CB_TRACKER_BUFF:Show();
			FRAME.CB_TRACKER_MINE:Show();
			FRAME.DDM_UNIT_LIST:Show();
			
			for i = 1 , #HDH_UNIT_LIST do
				if unit == HDH_UNIT_LIST[i] then
					HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, i, HDH_UNIT_LIST);
				end
			end
		else
			FRAME.CB_TRACKER_ALL_AURA:Hide();
			FRAME.CB_TRACKER_BOSS_AURA:Hide();
			FRAME.CB_TRACKER_ALL_AURA:SetChecked(false);
			FRAME.CB_TRACKER_BOSS_AURA:SetChecked(false);
			
			-- FRAME.CB_TRACKER_DEBUFF:Hide();
			-- FRAME.CB_TRACKER_BUFF:Hide();
			FRAME.CB_TRACKER_MINE:Hide();
			FRAME.DDM_UNIT_LIST:Hide();
		end
		if HDH_TRACKER.IsEqualClass(type, "HDH_T_TRACKER") or HDH_TRACKER.IsEqualClass(type, "HDH_USED_SKILL_TRACKER") then
			FRAME.CB_TRACKER_ALL_AURA:Show();
			UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
		end
		
		if HDH_TRACKER.IsEqualClass(type, "HDH_COMBO_POINT_TRACKER") then
			FRAME.CB_TRACKER_MERGE_POWERICON:Show();
			UpdateFrameDB_CB(FRAME.CB_TRACKER_MERGE_POWERICON);
		else
			FRAME.CB_TRACKER_MERGE_POWERICON:Hide();
		end
		
		AddTrackerFrameButtonMoveLeft:Enable()
		AddTrackerFrameButtonMoveRight:Enable()
		UIDropDownMenu_EnableDropDown(AddTrackerFrameDDMSpecList)
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMTabList)
		AddTrackerFrameButtonCopy:Enable()
		AddTrackerFrameTextE:SetText(nil)
		
		
	else
		HDH_AT_LoadDropDownButton(FRAME.DDM_TRACKER_TYPE_LIST, nil, HDH_TRACKER_LIST);
		HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, nil, HDH_UNIT_LIST);
		--DDM_LoadUnitList(1)
		--DDM_LoadTabList()
		--DDB_LoadSpecList()
		AddTrackerFrame.mode = "add"
		AddTrackerFrameText1:SetText("추적 창 추가")
		AddTrackerFrameButtonCreateAndModifyTracker:SetText("추가")
		AddTrackerFrameButtonDeleteUnit:Disable()
		AddTrackerFrameButtonMoveLeft:Disable()
		AddTrackerFrameButtonMoveRight:Disable()
		FRAME.CB_TRACKER_ALL_AURA:SetChecked(false);
		FRAME.CB_TRACKER_BOSS_AURA:SetChecked(false);
		-- FRAME.CB_TRACKER_DEBUFF:SetChecked(false);
		-- FRAME.CB_TRACKER_BUFF:SetChecked(true);
		FRAME.CB_TRACKER_MINE:SetChecked(false);
		FRAME.CB_TRACKER_ALL_AURA:Hide();
		FRAME.CB_TRACKER_BOSS_AURA:Hide();
		-- FRAME.CB_TRACKER_DEBUFF:Show();
		-- FRAME.CB_TRACKER_BUFF:Show();
		FRAME.CB_TRACKER_MINE:Hide();
		FRAME.CB_TRACKER_MERGE_POWERICON:Hide();
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMSpecList)
		UIDropDownMenu_DisableDropDown(AddTrackerFrameDDMTabList)
		AddTrackerFrameButtonCopy:Disable()
		AddTrackerFrameTextE:SetText(nil)
		AddTrackerFrame:Show()
		AddTrackerFrameEditBoxName:SetText("")
		FRAME.DDM_UNIT_LIST:Hide();
	end
	
	local items = {}
	for i= 1, #DB_AURA.Talent do
		items[i] = DB_AURA.Talent[i].Name
	end
	HDH_AT_LoadDropDownButton(FRAME.DDM_TALENT_LIST, nil, items)
	
	items ={}
	for i = 1, #DB_FRAME_LIST do
		items[i] = DB_FRAME_LIST[i].name
	end
	HDH_AT_LoadDropDownButton(FRAME.DDM_TRACKER_LIST, nil, items)
end

function HDH_AT_OP_OnChangeUISetting(self, idx, value)
	--if idx == UI_TYPE.FONT and value then
	--	HDH_AT_OP_LoadFontSetting(value);
	--end
	HDH_AT_OP_ChangeTapState(UI_TAB_BTN_LIST, idx);

	if UI_TAB_BTN_LIST.CurIdx == HDH_AT_OP.UI_TYPE.SHARE then
		HDH_OnClick_GetProfileString()
	end
end

function HDH_AT_OP_ChangeTapState(tablist, idx)
	local btn = tablist[tablist.CurIdx];
	local body = tablist.Body[tablist.CurIdx];
	
	for i = 0, #tablist do --off : 포문으로 돌리는이유는 트래커 목록 드래그로 위치 이동할때, 잔상(?)이 남는 문제 때문.
		btn = tablist[i];
		if i ~= idx and btn then
			_G[btn:GetName().."BgLine2"]:Hide();
			_G[btn:GetName().."Text"]:SetTextColor(1,1,1);
			if body then body:Hide(); end
		end
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


------------------------------------------
-- Call back function
------------------------------------------

function HDH_AT_OP_OnValueChanged(self, value, userInput)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not name then return end
	value = math.floor(value)
	if (self == FRAME.SL_FONT_SIZE1) or (self == FRAME.SL_FONT_SIZE2) or (self == FRAME.SL_FONT_SIZE3) 
	or (self == FRAME.SL_FONT_SIZE4) or (self == FRAME.SL_BAR_NAME_TEXT_SIZE) 
	or (self == FRAME.SL_BAR_NAME_MARGIN_RIGHT ) or(self == FRAME.SL_BAR_NAME_MARGIN_LEFT )  then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == FRAME.SL_ICON_SIZE then
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
	elseif (self == FRAME.SL_ON_ALPHA) or (self == FRAME.SL_OFF_ALPHA) then
		UpdateFrameDB_SL(self, value/100);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif (self == FRAME.SL_LINE) then
		UpdateFrameDB_SL(self, value);
		local t = HDH_TRACKER.Get(name)
		if t then 
			if UI_LOCK then t:SetMove(UI_LOCK)
					   else t:Update() end
		end		
	elseif (self == FRAME.SL_MARGIN_H) or (self == FRAME.SL_MARGIN_V) then
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
	elseif (self == FRAME.SL_CT_MAXTIME) then
		UpdateFrameDB_SL(self, value);
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
					if HDH_C_TRACKER and HDH_C_TRACKER[tracker.type] then
						tracker:Update()
					end
				end
			end
		end
	elseif (self == FRAME.SL_BAR_WIDTH ) or (self == FRAME.SL_BAR_HEIGHT ) then
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
	local curMin, curMax = self:GetMinMaxValues();
	getglobal(self:GetName() .. 'Low'):SetText(newMin);
	getglobal(self:GetName() .. 'High'):SetText(newMax);
	self:SetMinMaxValues(newMin, newMax)
	if self:GetValue() ~= value then
		self:SetValue(value)
	end
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
	local str = HDH_AT_UTIL.Trim(self:GetText()) or ""
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
			if ret == #(DB_AURA.Talent[HDH_GetSpec(name)][name]) then
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
	local aura = DB_AURA.Talent[HDH_GetSpec(name)][name]
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
	local aura = DB_AURA.Talent[HDH_GetSpec(name)][name]
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
	if ColorPickerFrame:IsShown() then return end
	local r,g,b = ColorPickerFrame:GetColorRGB();
	UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b, ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue());
	UpdateFrameDB_CP(ColorPickerFrame.colorButton);
	-- ColorPickerFrame.colorButton = nil;
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

function HDH_OnAlways(_ , no, check)
	local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not name then return end
	local db = DB_AURA.Talent[HDH_GetSpec(name)][name]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Always = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_AT_OP_OnSelectedItem_DDM(self, btn, value, id)
	UIDropDownMenu_SetSelectedID(self, id);
	UIDropDownMenu_SetSelectedValue(self, value);
	self.value = value;
	self.id = id;
	if (self == FRAME.DDM_TALENT_LIST) then
		if id > 0 then
			UIDropDownMenu_EnableDropDown(FRAME.DDM_TRACKER_LIST)
		else
			UIDropDownMenu_DisableDropDown(FRAME.DDM_TRACKER_LIST)
		end
	elseif (self == FRAME.DDM_TRACKER_TYPE_LIST) then
		if HDH_TRACKER.IsEqualClass(self.value,"HDH_TRACKER") then
			-- FRAME.CB_TRACKER_BUFF:Show();
			-- FRAME.CB_TRACKER_DEBUFF:Show();
			FRAME.CB_TRACKER_MINE:Show();
			FRAME.CB_TRACKER_ALL_AURA:Show();
			FRAME.CB_TRACKER_BOSS_AURA:Show();
			FRAME.DDM_UNIT_LIST:Show();
			if AddTrackerFrame.mode == "modify" then
				local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()));
				UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
				UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA);
				local selected = nil;
				for i = 1 , #HDH_UNIT_LIST do
					if tracker.unit == HDH_UNIT_LIST[i] then
						selected = i; 
					end
				end
				HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, selected, HDH_UNIT_LIST);
			end
		else
			FRAME.DDM_UNIT_LIST:Hide();
			-- FRAME.CB_TRACKER_BUFF:Hide();
			-- FRAME.CB_TRACKER_DEBUFF:Hide();
			FRAME.CB_TRACKER_MINE:Hide();
			FRAME.CB_TRACKER_ALL_AURA:Hide();
			FRAME.CB_TRACKER_BOSS_AURA:Hide();
			FRAME.CB_TRACKER_ALL_AURA:SetChecked(false);
			FRAME.CB_TRACKER_BOSS_AURA:SetChecked(false);
		end
		
		if HDH_TRACKER.IsEqualClass(self.value,"HDH_T_TRACKER") or HDH_TRACKER.IsEqualClass(self.value, "HDH_USED_SKILL_TRACKER") then 
			FRAME.CB_TRACKER_ALL_AURA:Show();
			UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
		end
		
		if HDH_TRACKER.IsEqualClass(self.value,"HDH_COMBO_POINT_TRACKER") then
			FRAME.CB_TRACKER_MERGE_POWERICON:Show();
		else
			FRAME.CB_TRACKER_MERGE_POWERICON:Hide();
		end
	elseif (self == FRAME.DDM_CD_TYPE) then
		UpdateFrameDB_DDM(self, nil, id);
		local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()));
		if tracker then 
			tracker:UpdateSetting()
			if UI_LOCK then
				tracker:SetMove(UI_LOCK);
			else
				tracker:Update()
			end
		end
	elseif (self == FRAME.DDM_ORDER_BY) then
		UpdateFrameDB_DDM(self, nil, id);
		local tracker = HDH_TRACKER.Get(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()));
		if tracker then 
			if UI_LOCK then
				tracker:SetMove(UI_LOCK);
			else
				tracker:InitIcons();
			end
		end
	elseif (self == FRAME.DDM_FONT_LOC1) or (self == FRAME.DDM_FONT_LOC2) or (self == FRAME.DDM_FONT_LOC3) or (self == FRAME.DDM_FONT_LOC4)then
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
	elseif self == FRAME.DDM_BAR_LOCATION or self == FRAME.DDM_BAR_TEXTURE then
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
	elseif self == FRAME.DDM_BAR_NAME_ALIGN then
		UpdateFrameDB_DDM(self, nil, id);
		if HDH_AT_OP_IsEachSetting() then
			local name = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
			local t = HDH_TRACKER.Get(name)
			if t then 
				t:UpdateSetting() 
			end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == FRAME.DDM_PROFILE then
		HDH_AT_OP_LoadProfileSpec(self, value);
	elseif self == FRAME.DDM_TIME_TYPE then
		UpdateFrameDB_DDM(self, nil, id);
	end
end

-- 체크 버튼 핸들러
function HDH_AT_OP_OnChecked(self, checked)
	local name, type, unit = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	local tracker = HDH_TRACKER.Get(name);
	UpdateFrameDB_CB(self, checked);
	if self == FRAME.CB_LIST_SHARE then -- 추적 활성화
		if checked then
			DB_OPTION[name].share_spec = HDH_GetSpec(name);
			tracker:InitIcons();
		else
			DB_OPTION[name].share_spec = nil;
			tracker:InitIcons();
		end
		HDH_AT_OP_LoadAuraListFrame(GetTrackerIndex());
	elseif self == FRAME.CB_EACH then -- 개별 설정
		if not tracker then return; end
		if checked then
			if not DB_OPTION[name].icon then
				DB_OPTION[name].icon = HDH_AT_UTIL.Deepcopy(DB_OPTION.icon)
			end
			if not DB_OPTION[name].font then
				DB_OPTION[name].font = HDH_AT_UTIL.Deepcopy(DB_OPTION.font)
			end
			if not DB_OPTION[name].bar then
				DB_OPTION[name].bar = HDH_AT_UTIL.Deepcopy(DB_OPTION.bar)
			end
			tracker.option.icon = DB_OPTION[name].icon
			tracker.option.font = DB_OPTION[name].font
			tracker.option.bar = DB_OPTION[name].bar
		else
			tracker.option.icon = DB_OPTION.icon
			tracker.option.font = DB_OPTION.font
			tracker.option.bar = DB_OPTION.bar
		end
		HDH_AT_OP_LoadSetting(GetTrackerIndex());
		tracker:UpdateSetting()
		if UI_LOCK then
			tracker:SetMove(UI_LOCK)
		else
			tracker:InitIcons()
		end
	elseif self == FRAME.CB_COLOR_DEBUFF_DEFAULT then -- 디버프 테두리 기본색상
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
	elseif (self == FRAME.CB_MOVE) then -- 이동
		HDH_TRACKER.SetMoveAll(checked);
		HDH_AT_OP_ShowGrid(FRAME.TOP_PARENT, checked);
	elseif self ==  FRAME.CB_SHOW_ID then
	elseif self ==  FRAME.CB_CT_DESAT or self == FRAME.CB_CT_DESAT_NOTENOUGHMANA or self == FRAME.CB_CT_DESAT_OUTRANGE then
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
					if HDH_TRACKER.IsEqualClass(type, "HDH_C_TRACKER")then
						tracker:Update()
					end
				end
			end
		end
	elseif self == FRAME.CB_ICON_FIX then -- 아이콘 위치 고정
		if tracker then tracker:InitIcons() end
	elseif self == FRAME.CB_REVERS_H or self == FRAME.CB_REVERS_V then -- 상하/좌우 반전
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			if tracker then tracker:Update() end
		end
	elseif self == FRAME.CB_SHOW_TOOLTIP then -- 툴팁 표시
		if not UI_LOCK then
			if tracker then tracker:UpdateSetting() end
		end
	elseif self == ValueOptionFrameCheckButtonShowValue then -- 수치 활성화
		local parent = self:GetParent()
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
	elseif self == FRAME.CB_ALWAYS_SHOW then -- 항상 표시
		for k,tracker in pairs(HDH_TRACKER.GetList()) do
			tracker:Update()
		end
	elseif self == FRAME.CB_BAR_ENABLE then
		if tracker then
			if HDH_AT_OP_IsEachSetting() then
				tracker:UpdateSetting(f)
				if UI_LOCK then tracker:SetMove(UI_LOCK)
						   else tracker:InitIcons() end
			else
				HDH_TRACKER.UpdateSettingAll()
				if UI_LOCK then
					HDH_TRACKER.SetMoveAll(UI_LOCK)
				else
					for k,tracker in pairs(HDH_TRACKER.GetList()) do
						tracker:InitIcons()
					end
				end
			end
		end
	elseif self == FRAME.CB_ABLE_BUFF_CANCEL then
		if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER")and not UI_LOCK then
			if HDH_AT_OP_IsEachSetting() then
				if tracker then
					tracker:UpdateSetting()
				end
			else
				HDH_TRACKER.UpdateSettingAll()
			end
		end
	elseif self == FRAME.CB_BAR_FILL then
		if HDH_AT_OP_IsEachSetting() then
			if tracker then
				tracker:UpdateIcons();
			end
		else
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:UpdateIcons();
			end
		end
	elseif (self == FRAME.CB_HIDE_ICON or self == FRAME.CB_SHOW_CD or self == FRAME.CB_BAR_REVERSE or self == FRAME.CB_BAR_USE_FULL_COLOR or FRAME.CB_BAR_SHOW_SPACK or self == FRAME.CB_BAR_NAME_SHOW) then
		if HDH_AT_OP_IsEachSetting() then
			if tracker then
				tracker:UpdateSetting();
				tracker:InitIcons();
			end
		else
			HDH_TRACKER.UpdateSettingAll();
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				tracker:InitIcons();
			end
		end
	end
end

function HDH_AT_OP_OnClickCreateData(self)
	local name =  HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()); 
	local tracker = HDH_TRACKER.Get(name);
	local spec = HDH_GetSpec(name);
	HDH_OP_AlertDlgShow("현재 목록을 삭제하고 자원 데이터를 등록 하시겠습니까?\n|cffff0000(기존 목록은 삭제 됩니다. 일부 설정이 변경될 수 있습니다.)", HDH_AT_OP.DLG_TYPE.YES_NO, 
						function() tracker:CreateData(spec); tracker:InitIcons(); OptionFrame:Hide(); OptionFrame:Show();  end);
	
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
	--ed:SetText(HDH_AT_UTIL.Trim(ed) or "")
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
		-- if not data.defaultImg then data.defaultImg = data.Texture; end
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
	if data.defaultImg then
		parent.texture = data.defaultImg
		local icon = _G[self:GetParent():GetName().."Texture"]
		icon:SetTexture(parent.texture)
		icon:SetVertexColor(1,1,1);
		-- data.defaultImg = nil;
	end
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
	
	count = tonumber(HDH_AT_UTIL.Trim(count))
	v1 = tonumber(HDH_AT_UTIL.Trim(v1))
	--v2 = tonumber(HDH_AT_UTIL.Trim(v2))
	db[tonumber(parent.row)].GlowCount = count
	db[tonumber(parent.row)].GlowV1 = v1
	--db[tonumber(parent.row)].GlowV2 = v2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_LoadValueFrame(self, row, spec, tab) -------------------------------------------------------
	local name, type, unit = HDH_AT_OP_GetTrackerInfo(tab)
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
	--db.v1_type = HDH_AT_UTIL.Trim(text1) or "" 
	db.v1_hp = h1
	--db.v2 = v2 
	--db.v2_type = HDH_AT_UTIL.Trim(text2) or ""
	--db.v2_hp = h2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

local function HDH_path(path)
	if path and (path:len() > 0) then
		path = HDH_AT_UTIL.Trim(path)
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

local function HDH_GetBarSplitFrame(self, i, isCreateAndGet)
	if not self.AddFrame then self.AddFrame = {}  end
	if isCreateAndGet and not self.AddFrame[i] and i <= MAX_SPLIT_ADDFRAME and i > 0 then
		self.AddFrame[i] = CreateFrame("Frame", self:GetParent():GetName().."SplitFrame"..i, self, "HDH_AT_BarSplitTemplate");
		self.AddFrame[i].index = i;
		self.AddFrame[i].fontNo = _G[self.AddFrame[i]:GetName().."No"];
		self.AddFrame[i].ed = _G[self.AddFrame[i]:GetName().."EditBox1"];
		self.AddFrame[i].btnAdd = _G[self.AddFrame[i]:GetName().."ButtonAdd"];
		self.AddFrame[i].btnDel = _G[self.AddFrame[i]:GetName().."ButtonDel"];
		if i == 1 then
			self.AddFrame[i]:SetPoint("TOPLEFT",20,-100);
		else
			self.AddFrame[i]:SetPoint("TOP", self.AddFrame[i-1], "BOTTOM", 0, 0);
		end
		
		_G[self.AddFrame[i]:GetName().."No"]:SetText(i);
	end
	return self.AddFrame[i];
end

function HDH_AT_UpdatePreviewSplitBar(data)
	local name = SplitBarFrame.name;
	local tracker = HDH_TRACKER.Get(name);
	local powerMax = tracker.max or UnitPowerMax('player', HDH_POWER_TRACKER.POWER[tracker.type].power_index);
	local frame = SplitBarFramePreview;
	if not data then return end
	if not frame.bar then frame.bar = {}; frame.text={};end
	local margin = 3;
	local w,h,cnt;
	local option = HDH_TRACKER.Get(name).option;
	_G[frame:GetName().."MinValue"]:SetText("min 0");
	_G[frame:GetName().."MaxValue"]:SetText("max "..HDH_AT_UTIL.CommaValue(powerMax));
	for i =1 , #data+1 do
		if not frame.bar[i] then 
			frame.bar[i] = frame:CreateTexture(nil,"OVERLAY");
			frame.text[i] = frame:CreateFontString(nil, "OVERLAY","GAMEFONTNORMAL"); 
			frame.text[i]:SetTextColor(1,1,1);
			frame.text[i]:SetPoint("TOP",frame.bar[i],"BOTTOMRIGHT",0,-5);
			if i== 1 then
				frame.bar[i]:SetPoint("LEFT", 0,0);
			else
				frame.bar[i]:SetPoint("LEFT", frame.bar[i-1], "RIGHT", margin,0);
			end
		end
		h = frame:GetHeight();
		w = (frame:GetWidth() - (margin*#data)) * (((data[i] or powerMax )-(data[i-1] or 0))/powerMax);

		frame.bar[i]:SetTexture(HDH_TRACKER.BAR_TEXTURE[option.bar.texture].texture);
		frame.bar[i]:SetVertexColor(unpack(option.bar.color));
		frame.bar[i]:SetSize(w,h);
		frame.bar[i]:Show();
		frame.text[i]:SetText(HDH_AT_UTIL.CommaValue(data[i]));
		frame.text[i]:Show();
		cnt = i;
	end
	cnt = cnt + 1;
	while frame.bar[cnt] do
		frame.bar[cnt]:Hide();
		frame.text[cnt]:Hide();
		cnt = cnt + 1;
	end
end

function HDH_AT_OnClickBarSplit(self)
	local index = self:GetParent().index;
	local db = SplitBarFrame.db;
	local name = SplitBarFrame.name;
	local parent = self:GetParent():GetParent();
	local tracker = HDH_TRACKER.Get(name);
	local powerMax = tracker.max;
	local value;
	
	local rowFrame = self:GetParent();
	if self == rowFrame.btnAdd then
		value = tonumber(rowFrame.ed:GetText()) or 0;
		if (db[index-1] or 0) < value and value < powerMax then
			db[index] = tonumber(rowFrame.ed:GetText());
			-- rowFrame.btnDel:Hide();
			-- rowFrame.btnAdd:Hide();
			rowFrame.ed:ClearFocus();
			rowFrame = HDH_GetBarSplitFrame(parent,index+1, true);
			if rowFrame then rowFrame:Show();end
			HDH_TRACKER.Get(name):InitIcons();
		else
			HDH_OP_AlertDlgShow(format("%d ~ %d 의 사이값을 입력해주세요.", HDH_AT_OP.DLG_TYPE.YES_NO, (db[index-1] or 0), powerMax));
			rowFrame.ed:SetText("");
		end
		
	else
		rowFrame.ed:ClearFocus();
		for i = index, MAX_SPLIT_ADDFRAME do
			db[i] = db[i+1];
			rowFrame = HDH_GetBarSplitFrame(parent,i);
			if rowFrame then 
				rowFrame.ed:SetText(db[i] or ""); 
				if not db[i] then rowFrame:Hide(); end
			end
		end
		rowFrame = HDH_GetBarSplitFrame(parent, #db + 1);
		if rowFrame then rowFrame:Show() end
		HDH_TRACKER.Get(name):InitIcons();
	end
	HDH_AT_UpdatePreviewSplitBar(db);
end

function HDH_LoadTalentSpellFrame(self, row, spec, tracker_idx)  -----------------------------------------
	local prefix = self:GetName();
	local cbShow = _G[prefix.."CheckButtonShow"];
	local cbDontShow = _G[prefix.."CheckButtonDontShow"];
	local eb = _G[prefix.."EditBox"];
	local name, type, unit = HDH_AT_OP_GetTrackerInfo(tracker_idx);
	self.row = row
	self.spec = spec
	self.name = name
	self.tracker_idx = tracker_idx;
	local db = DB_AURA.Talent[spec][name]
	if not db[tonumber(row)] then return end
	db = db[tonumber(row)];
	if db.Ignore and db.Ignore[1] and db.Ignore[1].Spell then
		eb:SetText(db.Ignore[1].Spell);
		if db.Ignore[1].Show then
			cbShow:SetChecked(true);
			cbDontShow:SetChecked(false);
		else
			cbShow:SetChecked(false);
			cbDontShow:SetChecked(true);
		end
	else
		eb:SetText("");
		cbShow:SetChecked(true);
		cbDontShow:SetChecked(false);
	end
end

function HDH_OnClick_SaveTalentSpellFrame(self)
	local parent = self:GetParent();
	local prefix = parent:GetName();
	local cbShow = _G[prefix.."CheckButtonShow"];
	local cbDontShow = _G[prefix.."CheckButtonDontShow"];
	local eb = _G[prefix.."EditBox"];
	local spell;
	local name, tracker_type, unit = HDH_AT_OP_GetTrackerInfo(parent.tracker_idx);
	local db = DB_AURA.Talent[parent.spec][parent.name]
	if not db[tonumber(parent.row)] then return end
	db = db[tonumber(parent.row)];
	local text = HDH_AT_UTIL.Trim(eb:GetText());
	if not text or #text == 0 then
		eb:SetText("");
		cbShow:SetChecked(true);
		cbDontShow:SetChecked(false);
		db.Ignore = nil;
		HDH_TRACKER.Get(name):InitIcons();
		return 
	end
	local spellName
	if tonumber(text) then
		spellName = HDH_AT_UTIL.GetInfo(tonumber(text));
	else
		spellName = text;
	end
	if HDH_AT_UTIL.IsTalentSpell(spellName, HDH_GetSpec(name)) == nil then
		HDH_OP_AlertDlgShow("해당 주문을 특성 목록에서 찾을 수 없습니다.\n\r(ID 로 입력해보세요)");
		return
	end
	eb:SetText(spellName);
	
	if not db.Ignore then db.Ignore = {} end
	local ignore = {}
	ignore.Spell = spellName;
	ignore.Show = cbShow:GetChecked();
	db.Ignore[1] = ignore;
	
	HDH_TRACKER.Get(name):InitIcons();
end

function HDH_LoadSetBarFrame(self, row, spec, idx)  -----------------------------------------
	local name, type, unit = HDH_AT_OP_GetTrackerInfo(idx);
	local db = DB_AURA.Talent[spec][name]
	if not db[tonumber(row)] then return end
	db = db[tonumber(row)];
	SplitBarFrame.row = row
	SplitBarFrame.spec = spec
	SplitBarFrame.name = name
	if HDH_TRACKER.IsEqualClass(type, "HDH_POWER_TRACKER") then -- or HDH_TRACKER.IsEqualClass(type, "HDH_STAGGER_TRACKER")
		db.split_bar = db.split_bar or {};
		db = db.split_bar;
		local i = 1;
		local f;
		local last = 0;
		for i = 1 , MAX_SPLIT_ADDFRAME do
			f = HDH_GetBarSplitFrame(SplitBarFrame, i);
			if db[i] then
				if not f then f = HDH_GetBarSplitFrame(SplitBarFrame, i, true); end
				f:Show();
				f.ed:SetText(db[i] or "");
				last = i;
			else
				if f then 
					f:Hide()
					f.ed:SetText("");
				else
					break;
				end
			end
		end
		f = HDH_GetBarSplitFrame(SplitBarFrame, last+1, true);-- 추가 프레임 넣고 종료
		if f then f:Show() end
		SplitBarFrame.db = db;
		HDH_AT_UpdatePreviewSplitBar(db);
		RowDetailSetFrameListButton6:Enable();
		SplitBarFrame:Show();
	else
		RowDetailSetFrameListButton6:Disable();
		SplitBarFrame:Hide();
	end
end

function HDH_AT_OP_OnEnterPressedSplit(self)
	HDH_AT_OnClickBarSplit(self:GetParent().btnAdd);
end

function HDH_AT_OP_OnEscapePressedSplit(self)
	self:SetText(self:GetParent():GetParent().db[self:GetParent().index] or "");
end

function HDH_OnClick_RowDetailSet(self, row) ---------------------------------------------
	--HDH_AT_OP_ChangeBody(BODY_TYPE.AURA_DETAIL, GetTrackerIndex(), row);
	local idx = GetTrackerIndex()
	local name = HDH_AT_OP_GetTrackerInfo(idx)
	if not name then return end
	local spec = HDH_GetSpec(name);
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
	
	HDH_LoadSoundFrame(SoundFrame, row , spec, idx)
	HDH_LoadChangeIconFrame(ChangeIconFrame, row, spec, idx)
	HDH_LoadValueFrame(ValueOptionFrame, row, spec, idx)
	HDH_LoadGlowFrame(GlowOptionFrame, row, spec, idx)
	HDH_LoadSetBarFrame(SettingBarFrame, row, spec, idx)
	HDH_LoadTalentSpellFrame(TalentSpellFrame, row, spec, idx)
end

--------------------------------
-- end
--------------------------------

function HDH_Option_OnShow(self)
	if not HDH_TRACKER.IsLoaded then self:Hide(); return end
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
	
	if not DB_AURA or (DB_AURA.Talent and #DB_AURA.Talent == 0) then
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
			HDH_AT_OP_AddTrackerButton(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].type, DB_FRAME_LIST[i].unit, i);
		end
		if TRACKER_TAB_BTN_LIST.CurIdx == nil then 
			SetTrackerIndex(1);
			g_CurMode = BODY_TYPE.AURA;
		end
	end
	
	HDH_LoadTabSpec();
	
	if not DB_OPTION.v7_0_3_7_3 then
		HDH_OP_AlertDlgShow("[설정 팁]\r\n|cffffffff1.마우스 드래그로 추척 목록과 주문 목록의 순서를 변경 할 수 있습니다.\r\n2. 추척 목록의 순서에 따라 추척장 출력 우선 순위를 정할 수 있습니다.\r\n(두개의 아이콘을 겹쳐둘 때, 유용합니다)");
		DB_OPTION.v7_0_3_7_3 = true;
	end
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
	
	UI_TAB_BTN_LIST = {SettingFrameUIListSFContentsFont1,SettingFrameUIListSFContentsIcon1, SettingFrameUIListSFContentsBar, SettingFrameUIListSFContentsProfile,SettingFrameUIListSFContentsETC};
	UI_TAB_BTN_LIST.Body =  { SettingFrameUIBodyFont, SettingFrameUIBodyIcon, SettingFrameUIBodyBar, SettingFrameUIBodyProfile, SettingFrameUIBodyETC}; -- , SettingFrameUIBodyShare ,SettingFrameUIListSFContentsShare
	UI_TAB_BTN_LIST.CurIdx = 1;
	
	AURA_DETAIL_TAB_BTN_LIST = {RowDetailSetFrameListButton1, RowDetailSetFrameListButton2, RowDetailSetFrameListButton3, RowDetailSetFrameListButton4, RowDetailSetFrameListButton5, RowDetailSetFrameListButton6};
	AURA_DETAIL_TAB_BTN_LIST.Body = {GlowOptionFrame, ValueOptionFrame, ChangeIconFrame, SoundFrame, TalentSpellFrame, SettingBarFrame};
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
