-----------------
---- #define ----
HDH_AT_OP = {};

local L = HDH_AT_L -- language

local STR_TRACKER_BTN_FORMAT = "%s\r\n|cffaaaaaa%s"

local GRID_SIZE = 30;
local FRAME_W = 400
local FRAME_H = 500
local MAX_H = 1000
local MIN_H = 260
local MAX_SPLIT_ADDFRAME = 5;
local ROW_HEIGHT = 26 -- 오라 row 높이
local EDIT_WIDTH_L = 145
local EDIT_WIDTH_S = 0
local FLAG_ROW_CREATE = 1 -- row 생성 모드
local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0
local DDM_COOLDOWN_LIST = {L.TO_UP, L.TO_DOWN, L.TO_LEFT, L.TO_RIGHT}
local DDM_FONT_LOCATION_LIST = { L.LOC_LT, 
								 L.LOC_TB, 
								 L.LOC_RT, 
								 L.LOC_RB, 
								 L.LOC_C, 
								 L.LOC_OT, 
								 L.LOC_OB, 
								 L.LOC_OL,
								 L.LOC_OR,
								 L.LOC_BL,
								 L.LOC_BC,
								 L.LOC_BR}
local DDM_BAR_LOCATION_LIST = {L.LOC_OT, L.LOC_OB, L.LOC_OL, L.LOC_OR}
local DDM_BAR_TEXTURE_LIST = {"BantoBar","Minimalist","normTex","Smooth","Blizzard","None"};
local DDM_BAR_NAME_ALIGN_LIST = {L.LEFT,L.LOC_C,L.RIGHT,L.TOP,L.BOTTOM};
local DDM_ICON_ORDER_LIST = {L.ORDER_NO, L.ORDER_TIME_ASC, L.ORDER_TIME_DESC};
local DDM_TIME_TYPE = {L.TIME_FORMAT1, L.TIME_FORMAT2, L.TIME_FORMAT3};
local DDM_GLOW_CONDITION_TYPE = {L.CONDITION_GT, L.CONDITION_LT, L.CONDITION_EQ};

local BODY_TYPE = {CREATE_TRACKER = 0, AURA = 1, EDIT_TRACKER = 2, UI = 3, AURA_DETAIL = 4 };
HDH_AT_OP.BODY_TYPE = BODY_TYPE;

local UI_TYPE = { FONT = 1, ICON=2, BAR=3, PROFILE=4, ETC = 5, SHARE = 6 };
HDH_AT_OP.UI_TYPE = UI_TYPE;
HDH_AT_OP.DLG_TYPE = {OK =1, YES_NO=2, NONE= 3};
				 
-- FRAME --
local BODY_TAB_BTN_LIST;
local UI_TAB_BTN_LIST; -- setting frame
local AURA_DETAIL_TAB_BTN_LIST;
local TRACKER_TAB_BTN_LIST;

local FRAME = {}

---- #end def ----
------------------

------------------------------
-----start--오리지널 코드----------
------------------------------
local MAX_TALENT_TABS = 4

local function GetSpecialization()
	return 1
end

local function GetSpecializationInfo(index)
	return 1, 1
end

------------------------------
---end ----오리지널 코드----------
------------------------------

g_CurMode = BODY_TYPE.AURA;
local CurSpec = 1 -- 현재 설정창 특성
local ListFrame;
local TAB_TALENT;

function HDH_OP_AlertDlgShow(msg, type, func, ...)
	if FRAME.F_ALERT:IsShown() then return end
	FRAME.F_ALERT.text = msg;
	FRAME.F_ALERT.dlg_type = type;
	FRAME.F_ALERT.func = func;
	FRAME.F_ALERT.arg = {...};
	FRAME.F_ALERT:Show();
end

function HDH_OP_AlertDlgHide()
	FRAME.F_ALERT:Hide();
end

local function CBSetText(frame, text, tooltip)
	_G[frame:GetName().."Text"]:SetText(text)
	frame.tooltip = tooltip
end

local function DDMSetText(frame, text, tooltip)
	_G[frame:GetName().."Name"]:SetText(text)
	frame.tooltip = tooltip
end

local function SLSetText(frame, text, tooltip)
	_G[frame:GetName().."Name"]:SetText(text)
	frame.tooltip = tooltip
end

local function CPSetText(frame, text, tooltip)
	_G[frame:GetName().."Text"]:SetText(text)
	frame.tooltip = tooltip
end

local function BTNSetText(frame, text, tooltip)
	frame:SetText(text)
	frame.tooltip = tooltip
end

-- 프레임 변수와 db 키와 매칭하는 함수
local function InitFrame()
	FRAME.F_MAIN = HDH_AT_ConfigFrame
	FRAME.F_MINIMUM = HDH_AT_MinimumFrame
	FRAME.F_HEADER = _G[FRAME.F_MAIN:GetName().."HeaderFrame"]
	
	FRAME.F_TRACKER_LIST = _G[FRAME.F_MAIN:GetName().."TrackerListFrame".."SF".."Contents"]
	FRAME.BTN_TRACKER_ADD = _G[FRAME.F_TRACKER_LIST:GetName().."BtnAddTracker"]
	BTNSetText(FRAME.BTN_TRACKER_ADD, L.ADD_TRACKER)

	FRAME.F_TALENT_LIST = _G[FRAME.F_MAIN:GetName().."TalentListFrame"]
	FRAME.F_BODY = _G[FRAME.F_MAIN:GetName().."BodyFrame"]
	FRAME.F_ALERT = _G[FRAME.F_MAIN:GetName().."AlertDlg"]
	FRAME.F_SHARE = _G[FRAME.F_MAIN:GetName().."ShareProfileFrame"]

	-- header
	FRAME.TAB_AURA = _G[FRAME.F_HEADER:GetName().."TabAuraList"]
	BTNSetText(FRAME.TAB_AURA, L.AURA_LIST)
	FRAME.TAB_TRACKER = _G[FRAME.F_HEADER:GetName().."TabTrackerConfig"]
	BTNSetText(FRAME.TAB_TRACKER, L.TRACKER_CONFIG)
	FRAME.TAB_UI = _G[FRAME.F_HEADER:GetName().."TabUIConfig"]
	BTNSetText(FRAME.TAB_UI, L.UI_CONFIG)

	-- body
	FRAME.F_TRACKER_CONFIG = _G[FRAME.F_BODY:GetName().."TrackerConfigFrame"]
	FRAME.F_UI_CONFIG = _G[FRAME.F_BODY:GetName().."UIConfigFrame"]
	FRAME.F_AURA_LIST = _G[FRAME.F_BODY:GetName().."AuraListFrame"]
	FRAME.F_AURA_CONFIG = _G[FRAME.F_BODY:GetName().."AuraConfigFrame"]

	-- body - trackerconfigframe
	FRAME.LABEL_TRACKER_ORDER = _G[FRAME.F_TRACKER_CONFIG:GetName().."TextTrackerOrder"]
	FRAME.DDM_SPEC_LIST = _G[FRAME.F_TRACKER_CONFIG:GetName().."DDMSpecList"]
	FRAME.DDM_TRACKER_LIST = _G[FRAME.F_TRACKER_CONFIG:GetName().."DDMTrackerList"]
	FRAME.DDM_TRACKER_TYPE_LIST = _G[FRAME.F_TRACKER_CONFIG:GetName().."DDMTrackerTypeList"]
	-- DDMSetText(FRAME.DDM_TRACKER_TYPE_LIST, L.TRACKER_TYPE_LIST, L.TRACKER_TYPE_LIST_TOOLTIP)
	-- FRAME.DDM_TRACKER_TYPE_LIST.tooltip = 
	-- FRAME.DDM_TRACKER_LIST.key = "unit";
	FRAME.DDM_UNIT_LIST = _G[FRAME.F_TRACKER_CONFIG:GetName().."DDMUnitList"]
	-- FRAME.DDM_UNIT_LIST.key = "unit";
	FRAME.CB_TRACKER_BUFF = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonBuff"]
	FRAME.CB_TRACKER_BUFF.key = "check_buff";
	FRAME.CB_TRACKER_DEBUFF = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonDebuff"]
	FRAME.CB_TRACKER_MINE = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonMine"]
	FRAME.CB_TRACKER_MINE.key = "check_only_mine";
	FRAME.CB_TRACKER_ALL_AURA = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonAllAura"]
	FRAME.CB_TRACKER_ALL_AURA.key = "tracking_all";
	FRAME.CB_TRACKER_BOSS_AURA = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonBossAura"]
	FRAME.CB_TRACKER_BOSS_AURA.key = "tracking_boss_aura";
	FRAME.CB_TRACKER_MERGE_POWERICON = _G[FRAME.F_TRACKER_CONFIG:GetName().."CheckButtonMergePowerIcon"]
	FRAME.CB_TRACKER_MERGE_POWERICON.key = "merge_power_icon";
	FRAME.EB_TRACKER_NAME = _G[FRAME.F_TRACKER_CONFIG:GetName().."EditBoxName"]
	FRAME.LABEL_TRACKER_TITLE = _G[FRAME.F_TRACKER_CONFIG:GetName().."Text1"]
	FRAME.LABEL_TRACKER_ERROR = _G[FRAME.F_TRACKER_CONFIG:GetName().."TextE"]
	FRAME.BTN_TRACKER_SAVE = _G[FRAME.F_TRACKER_CONFIG:GetName().."ButtonCreateAndModifyTracker"]
	FRAME.BTN_TRACKER_DELETE = _G[FRAME.F_TRACKER_CONFIG:GetName().."ButtonDeleteUnit"]
	FRAME.BTN_TRACKER_LEFT = _G[FRAME.F_TRACKER_CONFIG:GetName().."ButtonMoveLeft"]
	FRAME.BTN_TRACKER_RIGHT = _G[FRAME.F_TRACKER_CONFIG:GetName().."ButtonMoveRight"]
	FRAME.BTN_TRACKER_COPY = _G[FRAME.F_TRACKER_CONFIG:GetName().."ButtonCopy"]
	
	
	-- body - ui config --
	-- body - ui - header --
	FRAME.F_UI_HEADER = _G[FRAME.F_UI_CONFIG:GetName().."Header"]
	FRAME.CB_EACH = _G[FRAME.F_UI_HEADER:GetName().."CheckButtonEachSet"]
	FRAME.CB_EACH.key = "use_dont_common";
	FRAME.TAB_UI_FONT = _G[FRAME.F_UI_HEADER:GetName().."TabFont"]
	FRAME.TAB_UI_ICON = _G[FRAME.F_UI_HEADER:GetName().."TabIcon"]
	FRAME.TAB_UI_BAR = _G[FRAME.F_UI_HEADER:GetName().."TabBar"]
	FRAME.TAB_UI_PROFILE = _G[FRAME.F_UI_HEADER:GetName().."TabProfile"]
	FRAME.TAB_UI_ETC = _G[FRAME.F_UI_HEADER:GetName().."TabETC"]
	FRAME.TAB_UI_SHARE = _G[FRAME.F_UI_HEADER:GetName().."TabShare"]
	
	-- body - ui - bottom --
	FRAME.CB_MOVE = _G[FRAME.F_UI_CONFIG:GetName().."Bottom".."CheckButtonMove"]
	FRAME.CB_SHOW_ID = _G[FRAME.F_UI_CONFIG:GetName().."Bottom".."CheckButtonIDShow"]
	FRAME.CB_SHOW_ID.key = "tooltip_id_show";

	-- body - ui - body --
	FRAME.F_UI_BODY = _G[FRAME.F_UI_CONFIG:GetName().."Body".."SF".."Contents"]

	-- body - ui - body - font --
	FRAME.F_UI_BODY_FONT = _G[FRAME.F_UI_BODY:GetName().."Font"]
	FRAME.BTN_COLOR_FONT1 = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonColorText1"]
	FRAME.BTN_COLOR_FONT1.key = "textcolor";
	FRAME.BTN_COLOR_FONT2 = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonColorText2"]
	FRAME.BTN_COLOR_FONT2.key = "countcolor";
	FRAME.BTN_COLOR_FONT3 = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonColorText3"]
	FRAME.BTN_COLOR_FONT3.key = "v1_color";
	FRAME.BTN_COLOR_FONT4 = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonColorText4"]
	FRAME.BTN_COLOR_FONT4.key = "v2_color";
	FRAME.BTN_COLOR_FONT_CD5 = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonColorCooldownText5"]
	FRAME.BTN_COLOR_FONT_CD5.key = "textcolor_5s";
	FRAME.CB_SHOW_CD = _G[FRAME.F_UI_BODY_FONT:GetName().."CheckButtonShowCooldown"]
	FRAME.CB_SHOW_CD.key = "show_cooldown";
	FRAME.DDM_TIME_TYPE = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMTimeType"]
	FRAME.DDM_TIME_TYPE.key = "time_type";
	FRAME.DDM_FONT_LOC1 = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMFontLocation1"]
	FRAME.DDM_FONT_LOC1.key = "cd_location";
	FRAME.DDM_FONT_LOC2 = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMFontLocation2"]
	FRAME.DDM_FONT_LOC2.key = "count_location";
	FRAME.DDM_FONT_LOC3 = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMFontLocation3"]
	FRAME.DDM_FONT_LOC3.key = "v1_location";
	FRAME.DDM_FONT_LOC4 = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMFontLocation4"]
	FRAME.DDM_FONT_LOC4.key = "v2_location";
	FRAME.SL_FONT_SIZE1 = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderFont1"]
	FRAME.SL_FONT_SIZE1.key = "fontsize";
	FRAME.SL_FONT_SIZE2 = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderFont2"]
	FRAME.SL_FONT_SIZE2.key = "countsize";
	FRAME.SL_FONT_SIZE3 = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderFont3"]
	FRAME.SL_FONT_SIZE3.key = "v1_size";
	FRAME.SL_FONT_SIZE4 = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderFont4"]
	FRAME.SL_FONT_SIZE4.key = "v2_size";
	-- bar font --
	FRAME.CB_BAR_NAME_SHOW = _G[FRAME.F_UI_BODY_FONT:GetName().."CheckButtonBarNameShow"]
	FRAME.CB_BAR_NAME_SHOW.key = "show_name";
	FRAME.DDM_BAR_NAME_ALIGN = _G[FRAME.F_UI_BODY_FONT:GetName().."DDMBarNameAlign"]
	FRAME.DDM_BAR_NAME_ALIGN.key = "name_align";
	FRAME.SL_BAR_NAME_TEXT_SIZE = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderFont"]
	FRAME.SL_BAR_NAME_TEXT_SIZE.key = "name_size";
	FRAME.SL_BAR_NAME_MARGIN_LEFT = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderBarNameMarginLeft"]
	FRAME.SL_BAR_NAME_MARGIN_LEFT.key = "name_margin_left";
	FRAME.SL_BAR_NAME_MARGIN_RIGHT = _G[FRAME.F_UI_BODY_FONT:GetName().."SliderBarNameMarginRight"]
	FRAME.SL_BAR_NAME_MARGIN_RIGHT.key = "name_margin_right";
	FRAME.CP_BAR_NAME_COLOR = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonBarNameColorOn"]
	FRAME.CP_BAR_NAME_COLOR.key = "name_color"
	FRAME.CP_BAR_NAME_COLOR_OFF = _G[FRAME.F_UI_BODY_FONT:GetName().."ButtonBarNameColorOff"]
	FRAME.CP_BAR_NAME_COLOR_OFF.key = "name_color_off";

	-- body - ui - body - icon --
	FRAME.F_UI_BODY_ICON = _G[FRAME.F_UI_BODY:GetName().."Icon"]

	FRAME.CB_ALWAYS_SHOW = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonAlwaysShow"]
	FRAME.CB_ALWAYS_SHOW.key = "always_show";
	FRAME.BTN_COLOR_BUFF = _G[FRAME.F_UI_BODY_ICON:GetName().."ButtonColorBuff"]
	FRAME.BTN_COLOR_BUFF.key = "buff_color";
	FRAME.BTN_COLOR_DEBUFF = _G[FRAME.F_UI_BODY_ICON:GetName().."ButtonColorDebuff"]
	FRAME.BTN_COLOR_DEBUFF.key  = "debuff_color";
	FRAME.BTN_COLOR_CD_BG = _G[FRAME.F_UI_BODY_ICON:GetName().."ButtonColorCooldownBg"]
	FRAME.BTN_COLOR_CD_BG.key  = "cooldown_bg_color";
	FRAME.CB_COLOR_DEBUFF_DEFAULT = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonDefaultColor"]
	FRAME.CB_COLOR_DEBUFF_DEFAULT.key  = "default_color";
	FRAME.SL_ICON_SIZE = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderIcon"]
	FRAME.SL_ICON_SIZE.key  = "size";
	FRAME.SL_ON_ALPHA = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderOnAlpha"]
	FRAME.SL_ON_ALPHA.key  = "on_alpha";
	FRAME.SL_OFF_ALPHA = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderOffAlpha"]
	FRAME.SL_OFF_ALPHA.key  = "off_alpha";
	FRAME.SL_MARGIN_H = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderMarginH"]
	FRAME.SL_MARGIN_H.key  = "margin_h";
	FRAME.SL_MARGIN_V = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderMarginV"]
	FRAME.SL_MARGIN_V.key  = "margin_v";
	FRAME.CB_ABLE_BUFF_CANCEL = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonAbleAuraCancel"]
	FRAME.CB_ABLE_BUFF_CANCEL.key = "able_buff_cancel";
	FRAME.CB_REVERS_H = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonReversH"]
	FRAME.CB_REVERS_H.key = "revers_h";
	FRAME.CB_REVERS_V = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonReversV"]
	FRAME.CB_REVERS_V.key = "revers_v";
	FRAME.CB_SHOW_TOOLTIP = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonTooltip"]
	FRAME.CB_SHOW_TOOLTIP.key = "show_spell_tooltip";
	FRAME.CB_ICON_FIX = _G[FRAME.F_UI_BODY_ICON:GetName().."CheckButtonFix"]
	FRAME.CB_ICON_FIX.key = "fix";
	FRAME.SL_LINE = _G[FRAME.F_UI_BODY_ICON:GetName().."SliderLine"]
	FRAME.SL_LINE.key = "line";
	FRAME.DDM_CD_TYPE = _G[FRAME.F_UI_BODY_ICON:GetName().."DDMCooldown"]
	FRAME.DDM_CD_TYPE.key = "cooldown";
	FRAME.DDM_ORDER_BY = _G[FRAME.F_UI_BODY_ICON:GetName().."DDMOrder"]
	FRAME.DDM_ORDER_BY.key = "order_by";
	
	-- body - ui - body - bar --
	FRAME.F_UI_BODY_BAR = _G[FRAME.F_UI_BODY:GetName().."Bar"]
	FRAME.CB_BAR_ENABLE = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonShowBar"]
	FRAME.CB_BAR_ENABLE.key = "enable";
	FRAME.CB_BAR_REVERSE = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonReverseProgress"]
	FRAME.CB_BAR_REVERSE.key = "reverse_progress";
	FRAME.CP_BAR_COLOR = _G[FRAME.F_UI_BODY_BAR:GetName().."ButtonBarColor"]
	FRAME.CP_BAR_COLOR.key = "color";
	FRAME.CP_BAR_FULL_COLOR = _G[FRAME.F_UI_BODY_BAR:GetName().."ButtonBarFullColor"]
	FRAME.CP_BAR_FULL_COLOR.key = "full_color";
	FRAME.CP_BAR_BG_COLOR = _G[FRAME.F_UI_BODY_BAR:GetName().."ButtonBarBgColor"]
	FRAME.CP_BAR_BG_COLOR.key = "bg_color";
	FRAME.DDM_BAR_LOCATION = _G[FRAME.F_UI_BODY_BAR:GetName().."DDMBarLocation"]
	FRAME.DDM_BAR_LOCATION.key = "location";
	FRAME.DDM_BAR_TEXTURE = _G[FRAME.F_UI_BODY_BAR:GetName().."DDMBarTexture"]
	FRAME.DDM_BAR_TEXTURE.key = "texture";
	FRAME.SL_BAR_WIDTH = _G[FRAME.F_UI_BODY_BAR:GetName().."SliderPowerBarWidth"]
	FRAME.SL_BAR_WIDTH.key = "width";
	FRAME.SL_BAR_HEIGHT = _G[FRAME.F_UI_BODY_BAR:GetName().."SliderPowerBarHeight"]
	FRAME.SL_BAR_HEIGHT.key = "height";
	FRAME.CB_HIDE_ICON = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonHideIcon"]
	FRAME.CB_HIDE_ICON.key = "hide_icon";
	FRAME.CB_BAR_USE_FULL_COLOR = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonUseFullColor"]
	FRAME.CB_BAR_USE_FULL_COLOR.key = "use_full_color";
	FRAME.CB_BAR_FILL = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonFillBar"]
	FRAME.CB_BAR_FILL.key = "fill_bar";
	FRAME.CB_BAR_SHOW_SPACK = _G[FRAME.F_UI_BODY_BAR:GetName().."CheckButtonShowSpark"]
	FRAME.CB_BAR_SHOW_SPACK.key = "show_spark";
		
	-- body - ui - body - profile --
	FRAME.F_UI_BODY_PROFILE = _G[FRAME.F_UI_BODY:GetName().."Profile"]
	FRAME.DDM_PROFILE =  _G[FRAME.F_UI_BODY_PROFILE:GetName().."DDMProfile"]

	FRAME.F_UI_BODY_ETC = _G[FRAME.F_UI_BODY:GetName().."ETC"]

	-- 트래커별 UI 설정 --

	-- body - AuraListFrame --
	FRAME.F_AURA_LIST_BODY = _G[FRAME.F_AURA_LIST:GetName().."SF".."Contents"]
	FRAME.LABEL_NOTICE_ALL_TRACKING = _G[FRAME.F_AURA_LIST_BODY:GetName().."NoticeAllTracker"]
	FRAME.LABEL_NOTICE_BOSS_TRACKING = _G[FRAME.F_AURA_LIST_BODY:GetName().."NoticeBossTracker"]
	FRAME.BTN_CREATE_POWER_DATA = _G[FRAME.F_AURA_LIST:GetName().."ButtonCreateData"]
	FRAME.CB_LIST_SHARE = _G[FRAME.F_AURA_LIST:GetName().."CheckButtonListShare"]
	FRAME.CB_LIST_SHARE.key = "list_share";
	
	--FRAME.CB_REVERS_H = SettingFrameUIBottomCheckButtonMove;
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonSet
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonLoad
	--FRAME.BTN_COLOR_FONT1 = SettingFrameUIBodyProfileButtonReset
	
	
	-- 스킬 쿨다운 관련 설정 --
	FRAME.F_COOLDOWN_CONFIG = _G[FRAME.F_UI_BODY:GetName().."Cooldown"]
	FRAME.F_UI_COOLDOWN = _G[FRAME.F_UI_BODY:GetName().."Cooldown"]
	FRAME.CP_CT_COLOR = _G[FRAME.F_UI_COOLDOWN:GetName().."ButtonColor"]
	FRAME.CP_CT_COLOR.key = "cooldown_color";
	FRAME.CB_CT_DESAT = _G[FRAME.F_UI_COOLDOWN:GetName().."CheckButtonDesaturation"]
	FRAME.CB_CT_DESAT.key = "desaturation";
	FRAME.CB_CT_DESAT_NOTENOUGHMANA = _G[FRAME.F_UI_COOLDOWN:GetName().."CheckButtonDesaturationNotEnoughMana"]
	FRAME.CB_CT_DESAT_NOTENOUGHMANA.key = "desaturation_not_mana";
	FRAME.CB_CT_DESAT_OUTRANGE = _G[FRAME.F_UI_COOLDOWN:GetName().."CheckButtonDesaturationOutRange"]
	FRAME.CB_CT_DESAT_OUTRANGE.key = "desaturation_out_range";
	FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN = _G[FRAME.F_UI_COOLDOWN:GetName().."CheckButtonShowGlobalCooldown"]
	FRAME.CB_CT_SHOW_GLOBAL_COOLDOWN.key = "show_global_cooldown";
	FRAME.SL_CT_MAXTIME = _G[FRAME.F_UI_COOLDOWN:GetName().."SliderMaxTime"]
	FRAME.SL_CT_MAXTIME.key = "max_time";
	FRAME.CP_CT_NOTENOUGHMANA = _G[FRAME.F_UI_COOLDOWN:GetName().."ButtonColorNotEnoughMana"]
	FRAME.CP_CT_NOTENOUGHMANA.key = "not_enough_mana_color";
	FRAME.CP_CT_OUTRANGE = _G[FRAME.F_UI_COOLDOWN:GetName().."ButtonColorOutRange"]
	FRAME.CP_CT_OUTRANGE.key = "out_range_color";

	-- AuraConfig
	FRAME.F_AURA_CONFIG_HEADER = _G[FRAME.F_AURA_CONFIG:GetName().."Header"]
	FRAME.TEXTURE_AURA_CONFIG_HEADER_ICON = _G[FRAME.F_AURA_CONFIG_HEADER:GetName().."Icon"]
	FRAME.LABEL_AURA_CONFIG_HEADER_ICON = _G[FRAME.F_AURA_CONFIG_HEADER:GetName().."Text"]
	FRAME.BTN_AURA_CONFIG_HEADER_CLOSE = _G[FRAME.F_AURA_CONFIG_HEADER:GetName().."ButtonClose"]
	FRAME.TAB_AURA_CONFIG_GLOW = _G[FRAME.F_AURA_CONFIG:GetName().."TabList".."Button1"]
	FRAME.TAB_AURA_CONFIG_CHANGE_ICON = _G[FRAME.F_AURA_CONFIG:GetName().."TabList".."Button2"]
	FRAME.TAB_AURA_CONFIG_VALUE = _G[FRAME.F_AURA_CONFIG:GetName().."TabList".."Button3"]
	FRAME.TAB_AURA_CONFIG_TALENT = _G[FRAME.F_AURA_CONFIG:GetName().."TabList".."Button4"]
	FRAME.TAB_AURA_CONFIG_SPLIT_BAR = _G[FRAME.F_AURA_CONFIG:GetName().."TabList".."Button5"]

	FRAME.F_AURA_CONFIG_GLOW = _G[FRAME.F_AURA_CONFIG:GetName().."Body".."GlowOption"]
	FRAME.CB_AURA_CONFIG_GLOW_ENABLE = _G[FRAME.F_AURA_CONFIG_GLOW:GetName().."CheckButtonGlow"]
	FRAME.EB_AURA_CONFIG_GLOW1 = _G[FRAME.F_AURA_CONFIG_GLOW:GetName().."EB"]
	FRAME.EB_AURA_CONFIG_GLOW2 = _G[FRAME.F_AURA_CONFIG_GLOW:GetName().."EB2"]
	FRAME.EB_AURA_CONFIG_GLOW3 = _G[FRAME.F_AURA_CONFIG_GLOW:GetName().."EB3"]
	FRAME.BTN_AURA_CONFIG_GLOW_CLOSE = _G[FRAME.F_AURA_CONFIG_GLOW:GetName().."Close"]

	FRAME.F_AURA_CONFIG_VALUE = _G[FRAME.F_AURA_CONFIG:GetName().."Body".."ValueOption"]
	FRAME.CB_AURA_SHOW_VALUE_ENABLE =  _G[FRAME.F_AURA_CONFIG_VALUE:GetName().."CheckButtonShowValue"]
	FRAME.CB_AURA_SHOW_VALUE1 = _G[FRAME.F_AURA_CONFIG_VALUE:GetName().."CheckButtonValue1"]
	FRAME.CB_AURA_SHOW_VALUE_PER_HP = _G[FRAME.F_AURA_CONFIG_VALUE:GetName().."CheckButtonValuePerHp1"]
	FRAME.EB_AURA_SHOW_VALUE = _G[FRAME.F_AURA_CONFIG_VALUE:GetName().."EB1"]
	FRAME.BTN_AURA_SHOW_VALUE_SAVE = _G[FRAME.F_AURA_CONFIG_VALUE:GetName().."Save"]

	FRAME.F_AURA_CONFIG_CHANGE_ICON = _G[FRAME.F_AURA_CONFIG:GetName().."Body".."ChangeIcon"]
	FRAME.EB_AURA_CONFIG_CHANGE_ICON_SEARCH =  _G[FRAME.F_AURA_CONFIG_CHANGE_ICON:GetName().."EditBox"]
	FRAME.BTN_AURA_CONFIG_CHANGE_ICON_SEARCH =  _G[FRAME.F_AURA_CONFIG_CHANGE_ICON:GetName().."ButtonSearch"]
	FRAME.CB_AURA_CONFIG_CHANGE_ICON_IS_ITEM =  _G[FRAME.F_AURA_CONFIG_CHANGE_ICON:GetName().."CheckButtonIsItem"]
	FRAME.BTN_AURA_CONFIG_CHANGE_ICON_RETURN =  _G[FRAME.F_AURA_CONFIG_CHANGE_ICON:GetName().."ButtonReturn"]
	FRAME.BTN_AURA_CONFIG_CHANGE_ICON_OK =  _G[FRAME.F_AURA_CONFIG_CHANGE_ICON:GetName().."ButtonOK"]

	FRAME.F_AURA_CONFIG_SPLIT_BAR = _G[FRAME.F_AURA_CONFIG:GetName().."Body".."SplitBar"]
	FRAME.F_AURA_CONFIG_SPLIT_BAR = _G[FRAME.F_AURA_CONFIG_SPLIT_BAR:GetName().."SplitBarFrame"]
	FRAME.LABEL_AURA_CONFIG_SPLIT_BAR_MIN = _G[FRAME.F_AURA_CONFIG_SPLIT_BAR:GetName().."Preview".."MinValue"]
	FRAME.LABEL_AURA_CONFIG_SPLIT_BAR_MAX = _G[FRAME.F_AURA_CONFIG_SPLIT_BAR:GetName().."Preview".."MaxValue"]
	
	FRAME.F_AURA_CONFIG_TALENT = _G[FRAME.F_AURA_CONFIG:GetName().."Body".."TalentSpell"]
	FRAME.EB_AURA_CONFIG_TALENT = _G[FRAME.F_AURA_CONFIG_TALENT:GetName().."EditBox"]
	FRAME.CB_AURA_CONFIG_TALENT_SHOW = _G[FRAME.F_AURA_CONFIG_TALENT:GetName().."CheckButtonShow"]
	FRAME.CB_AURA_CONFIG_TALENT_HIDE = _G[FRAME.F_AURA_CONFIG_TALENT:GetName().."CheckButtonDontShow"]
	FRAME.BTN_AURA_CONFIG_TALENT_SAVE = _G[FRAME.F_AURA_CONFIG_TALENT:GetName().."ButtonSave"]
end

local MARGIN_Y = 30

local PADDING = 10

UI_TYPE_COLOR = 1
UI_TYPE_CHECK_BUTTON = 2
UI_TYPE_DROPDOWN = 3
UI_TYPE_SLIDER = 4
UI_TYPE_SPLITER = 5
UI_TYPE_LABEL = 6

local COL_X = {}
COL_X[1] = PADDING
COL_X[2] = 60
COL_X[3] = 200
COL_X[4] = 260

local function LocateRePoint(parent, frame, frame_type, row, col, text, margin_x, margin_y)
	local x = COL_X[col]
	local y = -(MARGIN_Y * (row - 1)) - PADDING

	margin_x = margin_x or 0
	margin_y = margin_y or 0

	if frame_type == UI_TYPE_SPLITER then
		local fontString = parent:CreateFontString(nil,  "ARTWORK", "HDH_AT_GameFontNormal_YELLOW_M"); 
		fontString:SetPoint("TOPLEFT", x, y-6);
		-- parent.SPLIT:SetWidth(300)
		fontString:SetHeight(20)
		fontString:SetJustifyH('CENTER')
		fontString:SetJustifyV('CENTER')
		fontString:SetText(text);

		split = parent:CreateTexture(nil,  "ARTWORK", "videoUnderline"); 
		split:ClearAllPoints()
		split:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", 0, 0);
		split:SetPoint("RIGHT", parent, "RIGHT", -PADDING * 2, 0);
		split:SetHeight(2)
		-- parent.SPLIT:SetSize()
		return
	elseif frame_type == UI_TYPE_LABEL then
		local fontString = parent:CreateFontString(nil,  "ARTWORK", "HDH_AT_GameFontNormal_White"); 
		fontString:SetPoint("TOPLEFT", x + margin_x, y + margin_y + 2);
		-- parent.SPLIT:SetWidth(300)
		fontString:SetHeight(MARGIN_Y)
		fontString:SetJustifyH('LEFT')
		fontString:SetJustifyV('CENTER')
		fontString:SetText(text);
		return
	end

	frame:ClearAllPoints()
	if frame_type == UI_TYPE_COLOR then
		frame:SetPoint("TOPLEFT", x+3, y)
	elseif frame_type == UI_TYPE_CHECK_BUTTON then
		frame:SetPoint("TOPLEFT", x, y-1)
	elseif frame_type == UI_TYPE_DROPDOWN then
		frame:SetPoint("TOPLEFT", x-14, y + 1)
	elseif frame_type == UI_TYPE_SLIDER then
		frame:SetPoint("TOPLEFT", x+9, y-5)
	end
end

local function LocateFrame()
	parent = FRAME.BTN_COLOR_FONT1:GetParent()
	-- layout_width = parent:GetWidth()
	-- layout_height = parent:GetHeight()
	-- parent.margin_x1 = 10
	-- parent.margin_x2 = layout_width / 2 - 10
	-- parent.margin_y1 = parent.margin_x1
	-- parent.margin_y2 = parent.margin_x1

	--   1   |    2    |    3    |    4
	-- Label : content : label : content
	LocateRePoint(parent, nil, UI_TYPE_SPLITER, 				   1, 1, "시간")

	LocateRePoint(parent, FRAME.CB_SHOW_CD, UI_TYPE_CHECK_BUTTON,  2, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   2, 3, "시간 형식")
	LocateRePoint(parent, FRAME.DDM_TIME_TYPE, UI_TYPE_DROPDOWN,   2, 4)

	LocateRePoint(parent, FRAME.BTN_COLOR_FONT1, UI_TYPE_COLOR,    3, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   3, 3, "글자 위치")
	LocateRePoint(parent, FRAME.DDM_FONT_LOC1, UI_TYPE_DROPDOWN,   3, 4)

	LocateRePoint(parent, FRAME.BTN_COLOR_FONT_CD5, UI_TYPE_COLOR, 4, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   4, 3, "글자 크기")
	LocateRePoint(parent, FRAME.SL_FONT_SIZE1, UI_TYPE_SLIDER,     4, 4)
	
	LocateRePoint(parent, nil, UI_TYPE_SPLITER, 				   5, 1, "중첩(마나)")
	LocateRePoint(parent, FRAME.BTN_COLOR_FONT2, UI_TYPE_COLOR,    6, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   6, 3, "글자 위치")
	LocateRePoint(parent, FRAME.DDM_FONT_LOC2, UI_TYPE_DROPDOWN,   6, 4)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   7, 3, "글자 크기")
	LocateRePoint(parent, FRAME.SL_FONT_SIZE2, UI_TYPE_SLIDER,     7, 4)

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                    8, 1, "수치(직업자원)")
	LocateRePoint(parent, FRAME.BTN_COLOR_FONT3, UI_TYPE_COLOR,    9, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   9, 3, "글자 위치")
	LocateRePoint(parent, FRAME.DDM_FONT_LOC3, UI_TYPE_DROPDOWN,   9, 4)
	LocateRePoint(parent, FRAME.BTN_COLOR_FONT4, UI_TYPE_COLOR,    10, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   10, 3, "글자 크기")
	LocateRePoint(parent, FRAME.SL_FONT_SIZE3, UI_TYPE_SLIDER,     10, 4)
	
	-- LocateRePoint(parent, FRAME.DDM_FONT_LOC4, UI_TYPE_DROPDOWN, 2)
	-- LocateRePoint(parent, FRAME.SL_FONT_SIZE4, UI_TYPE_SLIDER, 2)
	FRAME.DDM_FONT_LOC4:Hide()
	FRAME.SL_FONT_SIZE4:Hide()

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                          11, 1, "바 이름(바 사용 시)")
	LocateRePoint(parent, FRAME.CB_BAR_NAME_SHOW, UI_TYPE_CHECK_BUTTON,  12, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					         12, 3, "글자 위치")
	LocateRePoint(parent, FRAME.DDM_BAR_NAME_ALIGN, UI_TYPE_DROPDOWN,    12, 4)
	LocateRePoint(parent, FRAME.CP_BAR_NAME_COLOR, UI_TYPE_COLOR,        13, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					         13, 3, "글자 크기")
	LocateRePoint(parent, FRAME.SL_BAR_NAME_TEXT_SIZE, UI_TYPE_SLIDER,   13, 4)
	LocateRePoint(parent, FRAME.CP_BAR_NAME_COLOR_OFF, UI_TYPE_COLOR,    14, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					         14, 3, "왼쪽 여백")
	LocateRePoint(parent, FRAME.SL_BAR_NAME_MARGIN_LEFT, UI_TYPE_SLIDER, 14, 4)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					         15, 3, "오른쪽 여백")
	LocateRePoint(parent, FRAME.SL_BAR_NAME_MARGIN_RIGHT, UI_TYPE_SLIDER,15, 4)

	LocateRePoint(parent, nil, UI_TYPE_SPLITER, 16, 1, "")

	parent = FRAME.CB_ALWAYS_SHOW:GetParent()
	-- layout_width = parent:GetWidth()
	-- layout_height = parent:GetHeight()
	-- parent.margin_x1 = 10
	-- parent.margin_x2 = layout_width / 2 - 10
	-- parent.margin_y1 = parent.margin_x1
	-- parent.margin_y2 = parent.margin_x1

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                            1, 1, "기본")
	LocateRePoint(parent, FRAME.CB_ALWAYS_SHOW, UI_TYPE_CHECK_BUTTON,      2, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					           2, 3, "쿨다운 방향")
	LocateRePoint(parent, FRAME.DDM_CD_TYPE, UI_TYPE_DROPDOWN,             2, 4)
	LocateRePoint(parent, FRAME.CB_SHOW_TOOLTIP, UI_TYPE_CHECK_BUTTON,     3, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					           3, 3, "아이콘 크기")
	LocateRePoint(parent, FRAME.SL_ICON_SIZE, UI_TYPE_SLIDER,              3, 4)
	LocateRePoint(parent, FRAME.CB_ABLE_BUFF_CANCEL, UI_TYPE_CHECK_BUTTON, 4, 1)

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                                5, 1, "아이콘 색상 및 불투명도")
	LocateRePoint(parent, FRAME.BTN_COLOR_BUFF, UI_TYPE_COLOR,                 6, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					               6, 3, "컬러 불투명")
	LocateRePoint(parent, FRAME.SL_ON_ALPHA, UI_TYPE_SLIDER,                   6, 4)
	LocateRePoint(parent, FRAME.BTN_COLOR_DEBUFF, UI_TYPE_COLOR,               7, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					               7, 3, "흑백 불투명")
	LocateRePoint(parent, FRAME.SL_OFF_ALPHA, UI_TYPE_SLIDER,                  7, 4)
	LocateRePoint(parent, FRAME.CB_COLOR_DEBUFF_DEFAULT, UI_TYPE_CHECK_BUTTON, 8, 1)
	
	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                     9, 1, "아이콘 정렬")
	LocateRePoint(parent, FRAME.CB_REVERS_H, UI_TYPE_CHECK_BUTTON, 10, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   10, 3, "정렬 기준")
	LocateRePoint(parent, FRAME.DDM_ORDER_BY, UI_TYPE_DROPDOWN,    10, 4)
	LocateRePoint(parent, FRAME.CB_REVERS_V, UI_TYPE_CHECK_BUTTON, 11, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   11, 3, "행X열 정렬")
	LocateRePoint(parent, FRAME.SL_LINE, UI_TYPE_SLIDER,           11, 4)
	LocateRePoint(parent, FRAME.CB_ICON_FIX, UI_TYPE_CHECK_BUTTON, 12, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   12, 3, "가로 간격")
	LocateRePoint(parent, FRAME.SL_MARGIN_H, UI_TYPE_SLIDER,       12, 4)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					   13, 3, "세로 간격")
	LocateRePoint(parent, FRAME.SL_MARGIN_V, UI_TYPE_SLIDER,       13, 4)

	LocateRePoint(parent, nil, UI_TYPE_SPLITER, 14, 1, "")
	
	parent = FRAME.CB_BAR_ENABLE:GetParent()
	-- layout_width = parent:GetWidth()
	-- layout_height = parent:GetHeight()
	-- parent.margin_x1 = 10
	-- parent.margin_x2 = layout_width / 2 - 10
	-- parent.margin_y1 = parent.margin_x1
	-- parent.margin_y2 = parent.margin_x1

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                       1, 1, "바 사용 여부")
	LocateRePoint(parent, FRAME.CB_BAR_ENABLE, UI_TYPE_CHECK_BUTTON,  2, 1)
	LocateRePoint(parent, FRAME.CB_HIDE_ICON, UI_TYPE_CHECK_BUTTON,   2, 3)

	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                          3, 1, "바 진행 애니메이션")
	LocateRePoint(parent, FRAME.CB_BAR_REVERSE, UI_TYPE_CHECK_BUTTON,    4, 1)
	LocateRePoint(parent, FRAME.CB_BAR_SHOW_SPACK, UI_TYPE_CHECK_BUTTON, 4, 3)
	LocateRePoint(parent, FRAME.CB_BAR_FILL, UI_TYPE_CHECK_BUTTON,       5, 1)
	
	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                              6, 1, "바 색상 및 위치")
	LocateRePoint(parent, FRAME.CP_BAR_COLOR, UI_TYPE_COLOR,                 7, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					             7, 3, "바 위치")
	LocateRePoint(parent, FRAME.DDM_BAR_LOCATION, UI_TYPE_DROPDOWN,          7, 4)
	LocateRePoint(parent, FRAME.CP_BAR_BG_COLOR, UI_TYPE_COLOR,              8, 1)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  					             8, 3, "바 배경")
	LocateRePoint(parent, FRAME.DDM_BAR_TEXTURE, UI_TYPE_DROPDOWN,           8, 4)
	LocateRePoint(parent, FRAME.CB_BAR_USE_FULL_COLOR, UI_TYPE_CHECK_BUTTON, 9, 1)
	LocateRePoint(parent, FRAME.CP_BAR_FULL_COLOR, UI_TYPE_COLOR,           10, 1)
	
	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                11, 1, "바 크기")
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  				   12, 1, "바 길이")
	LocateRePoint(parent, FRAME.SL_BAR_WIDTH, UI_TYPE_SLIDER,  12, 2)
	LocateRePoint(parent, nil, UI_TYPE_LABEL,  				   12, 3, "바 두께")
	LocateRePoint(parent, FRAME.SL_BAR_HEIGHT, UI_TYPE_SLIDER, 12, 4)
	LocateRePoint(parent, nil, UI_TYPE_SPLITER,                13, 1, "")

end

-- 기본 공통 설정 디비 매칭
local function Match_Basic_DBForFrame()
	FRAME.CB_SHOW_ID.db =  HDH_AT_GetCommonDB();
end

-- 트래커별 디비 매칭
local function Match_Tracker_DBForFrame(curTracker)
	local db = HDH_AT_OP_GetTrackerInfo(curTracker);
	if db then
		FRAME.CB_EACH.db = db.ui;

		db = db.tracker
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
	-- HDH_AT_GetCommonDB().icon
	local icon, font, bar;
	local db = HDH_AT_OP_GetTrackerInfo(curTracker);
	if db and db.ui and db.ui.use_dont_common then 
		font = db.ui.font
		bar = db.ui.bar
		icon = db.ui.icon
	else
		db = HDH_AT_GetCommonDB()
		font = db.font
		bar = db.bar
		icon = db.icon
	end

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
	FRAME.CB_SHOW_CD.db = font;
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
	
	FRAME.CB_REVERS_H.db = icon;
	FRAME.CB_REVERS_V.db = icon;
	FRAME.CB_SHOW_TOOLTIP.db = icon;
	FRAME.CB_ICON_FIX.db = icon;
	FRAME.SL_LINE.db = icon;
	FRAME.DDM_CD_TYPE.db = icon;
	FRAME.DDM_ORDER_BY.db = icon;

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
local function UpdateFrameDB_CB(frame, value, text) -- check button
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

local function HDH_AT_OP_GetTracker(tracker_idx)
	if not tracker_idx then
		tracker_idx = GetTrackerIndex()
	end
	return HDH_TRACKER.Get(tracker_idx)
end

function HDH_GetSpec(tracker_name) -- 공유 특성이 있으면 공유 특성을 불러온다
	-- if tracker_name and DB_OPTION[tracker_name].list_share then
	-- 	return DB_OPTION[tracker_name].share_spec or CurSpec;
	-- else
	-- 	return CurSpec;
	-- end
end

function HDH_AT_OP_GetTrackerInfo(idx)
	if not idx then idx = GetTrackerIndex(); end
	local db = HDH_AT_GetTrackerDB(1, idx)
	if db then return db 
	      else return nil end
end

function HDH_AT_LoadDropDownButton(frame, idx, dataTable, func, btn_width, popup_width)
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
		else
			frame.selectedValue = dataTable[idx]
		end
	end)
	UIDropDownMenu_SetWidth(frame, popup_width or 100)
	UIDropDownMenu_SetButtonWidth(frame, btn_width or 100)
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
	local db = HDH_AT_OP_GetTrackerInfo(tabIdx)
	local tabname = db.name
	local spell_list = db.spell_list
	for i = 1 , #spell_list do
		if tonumber(spell_list[i].ID) ==  tonumber(id) and spell_list[i].IsItem == isItem then return false end
	end
	
	spell_list[tonumber(no)] = {}
	spell_list[tonumber(no)].Key = tostring(key)
	spell_list[tonumber(no)].No = no
	spell_list[tonumber(no)].ID = id
	spell_list[tonumber(no)].Name = name
	spell_list[tonumber(no)].Always = always
	spell_list[tonumber(no)].Texture = texture
	spell_list[tonumber(no)].IsItem = isItem
	local t = HDH_AT_OP_GetTracker(tabname)
	if t then t:InitIcons() end
	return true
end

local function HDH_DB_DelSpell(spec, no, tabIdx)
	local db = HDH_AT_OP_GetTrackerInfo(tabIdx)
	local tracker = HDH_AT_OP_GetTracker(tabIdx)
	local tabname = db.name
	local spell_list = db.spell_list
	local pointer = tracker and tracker.pointer or nil
	if pointer and spell_list[no] then 
		if pointer[spell_list[no].Key or tostring(spell_list[no].ID)] then 
			pointer[spell_list[no].Key or tostring(spell_list[no].ID)] = nil
		end
	end
	for i = tonumber(no), #spell_list do
		spell_list[i] = spell_list[i+1]
		if spell_list[i] then spell_list[i].No = i end
	end
	if tracker then tracker:InitIcons() end
end

-------------------------------------------
-- control list
-------------------------------------------

local function HDH_SetRowData(rowFrame, key, no, id, name, always, texture, isItem)
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local tabname = db.name
	local unit = db.unit
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(texture)
	_G[rowFrame:GetName().."ButtonIcon"]:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92);
	_G[rowFrame:GetName().."TextNum"]:SetText(no)
	_G[rowFrame:GetName().."TextName"]:SetText(name)
	_G[rowFrame:GetName().."TextID"]:SetText(id.."")
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(always)
	_G[rowFrame:GetName().."EditBoxID"]:SetText(key or "")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(isItem)
	-- _G[rowFrame:GetName().."ButtonAdd"]:SetText("삭제")
	-- _G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("등록")
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
	_G[rowFrame:GetName().."RowDesc"]:Hide()
end

local function HDH_ClearRowData(rowFrame)
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local tabname = db.name
	local unit = db.unit
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(0)
	_G[rowFrame:GetName().."TextNum"]:SetText(nil)
	_G[rowFrame:GetName().."TextName"]:SetText(nil)
	_G[rowFrame:GetName().."RowDesc"]:Show()
	_G[rowFrame:GetName().."TextID"]:SetText(nil)
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(true)
	_G[rowFrame:GetName().."EditBoxID"]:SetText("")
	_G[rowFrame:GetName().."ButtonAdd"]:SetText("등록")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(false)
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
end

local function HDH_DelRow(rowFrame)
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local tabname = db.name
	local unit = db.unit
	local no = rowFrame:GetAttribute("no")
	HDH_DB_DelSpell(HDH_GetSpec(tabname), no, GetTrackerIndex())
	HDH_LoadAuraListFrame(GetTrackerIndex(), no)
end

local function HDH_AT_OP_SwapRowData(listframe, i1, i2)
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local name = db.name
	local aura = db.spell_list
	
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
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local name = db.name
	local aura = db.spell_list
	local x, y = self:GetCenter();
	local selfIdx = self.idx;
	local rowFrame;
	local listframe = self:GetParent().row;
	for i =1, (#listframe)-1 do
		rowFrame = listframe[i];
		if i ~= selfIdx and rowFrame.mode ~= "add" then 
			local left, bottom, w, h = rowFrame:GetBoundsRect();
			if x >= left and x <= (left+w) and y >= bottom and y<=(bottom+h) then
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
	local idx = GetTrackerIndex()
	self:StopMovingOrSizing();
	self:SetScript('OnUpdate', nil);
	HDH_LoadAuraListFrame(idx);
	HDH_AT_OP_GetTracker(idx):InitIcons();
end

function HDH_GetRowFrame(listFrame, index, flag)
	if not listFrame.row then listFrame.row = {} end
	local f = listFrame.row[index];
	index = tonumber(index)
	if not f and flag == FLAG_ROW_CREATE then
		f = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "HDH_AT_RowTemplate")
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

function HDH_LoadAuraListFrame(trackerIdx, startRowIdx, endRowIdx)
	local listFrame = FRAME.F_AURA_LIST_BODY
	local aura = {}
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local tracker_name = db.name
	local type = db.type
	local unit = db.unit
	-- local spec = HDH_GetSpec(tracker_name);
	-- if not DB_AURA.Talent[spec] then return end
	aura = db.spell_list
	
	local rowFrame
	local i = startRowIdx or 1
	if db 
		and (HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") or HDH_TRACKER.IsEqualClass(type, "HDH_T_TRACKER") or HDH_TRACKER.IsEqualClass(type, "HDH_USED_SKILL_TRACKER")) 
		and (db.tracker.tracking_all or db.tracker.tracking_boss_aura) then
		if db.tracker.tracking_all then 
			FRAME.LABEL_NOTICE_ALL_TRACKING:Show()
			FRAME.LABEL_NOTICE_BOSS_TRACKING:Hide();
		elseif db.tracker.tracking_boss_aura then
			FRAME.LABEL_NOTICE_BOSS_TRACKING:Show();
			FRAME.LABEL_NOTICE_ALL_TRACKING:Hide();
		end
		listFrame:SetSize(listFrame:GetParent():GetWidth(), ROW_HEIGHT);
		FRAME.BTN_CREATE_POWER_DATA:Hide();
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
					if HDH_AT_OP_GetTracker(tracker_name):IsHaveData(spec) then
						FRAME.BTN_CREATE_POWER_DATA:Hide();
					else
						FRAME.BTN_CREATE_POWER_DATA:Show();
					end
					rowFrame:Hide()
				else FRAME.BTN_CREATE_POWER_DATA:Hide(); end
				break
			end
			if endRowIdx and endRowIdx == i then return end
			i = i + 1
		end
		FRAME.LABEL_NOTICE_ALL_TRACKING:Hide();
		FRAME.LABEL_NOTICE_BOSS_TRACKING:Hide();
		--FRAME.LABEL_NOTICE_ALL_TRACKING_Boss:Hide();
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
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local tracker_name = db.name
	local type = db.type
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
		HDH_SetRowData(rowFrame, key, no, id, name, always, icon, isItem)
		rowFrame.mode="data"
		listFrame:SetSize(listFrame:GetParent():GetWidth(), (no + 1) * ROW_HEIGHT)
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
	-- local list
	-- if DB_PROFILE[profile_name].AURA_LIST then
		
	-- 	-- 프로필캐릭터 전문화 목록 버튼 만들 --
	-- 	list = self:GetParent().profileSpec;
	-- 	list:Show();
	-- 	local p_talent = DB_PROFILE[profile_name].AURA_LIST.Talent;
	-- 	if not list.row then list.row = {} end
	-- 	for i = 1, #p_talent do
	-- 		if not list.row[i] then
	-- 			local new = CreateFrame("Button", list:GetName()..i, list, "HDH_AT_ButtonTemplate");
	-- 			-- new.arrow = new:CreateFontString(nil,"OVERLAY","GAMEFONTNORMAL");
	-- 			-- new.arrow:SetText("----->");
	-- 			new.arrow = new:CreateTexture(nil,"OVERLAY");
	-- 			new.arrow:SetTexture("Interface\\Vehicles\\Arrow");
	-- 			new.arrow:SetBlendMode("ADD");
	-- 			new.arrow:SetSize(40,15);
	-- 			new.arrow:SetPoint("LEFT",new,"RIGHT",10,0);
	-- 			-- new.arrow:SetTextColor(1,1,1);
	-- 			if i == 1 then
	-- 				new:SetPoint("TOP",0,0);
	-- 			else
	-- 				new:SetPoint("TOP",list.row[i-1],"BOTTOM",0,0);
	-- 			end
	-- 			list.row[i] = new;
	-- 		end
	-- 		list.row[i]:Show();
	-- 		list.row[i]:SetText(p_talent[i].Name);
	-- 		list.row[i].id = p_talent[i].ID;
	-- 	end
	-- 	for i = #p_talent+1, #list.row do 
	-- 		list.row[i]:Hide();
	-- 	end
		
	-- 	-- 현재 전문화 목록 버튼 만들 --
	-- 	list = self:GetParent().curSpec;
	-- 	list:Show();
	-- 	if not list.row then list.row = {} end
	-- 	local id, talent
	-- 	for i =1, 4 do
	-- 		id, talent = GetSpecializationInfo(i)
	-- 		if id then
	-- 			if not list.row[i] then
	-- 				local new = CreateFrame("Frame", list:GetName()..i, list, "HDH_AT_ProfileSpceTemplate");
	-- 				new.spec = _G[new:GetName().."ButtonSpec"];
	-- 				if i == 1 then
	-- 					new:SetPoint("TOP",0,0);
	-- 				else
	-- 					new:SetPoint("TOP",list.row[i-1],"BOTTOM",0,0);
	-- 				end
	-- 				list.row[i] = new;
	-- 			end
	-- 			list.row[i]:Show();
	-- 			list.row[i].spec:SetText(talent);
	-- 			list.row[i].talent = { name = talent, id = id , index = i};
	-- 			list.row[i].index = i;
	-- 		end
	-- 	end
	-- 	self:GetParent().loadBtn:Show();
	-- end
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
	if HDH_AT_PROFILE_DB then
		for k,v in pairs(HDH_AT_PROFILE_DB) do
			dataTable[#dataTable+1] = k
			if seleted_profile and seleted_profile == k then
				idx = #dataTable;
			end
		end
	end
	HDH_AT_LoadDropDownButton(FRAME.DDM_PROFILE, idx, dataTable, HDH_AT_OP_OnSelectedItem_DDM)
	-- self.profileSpec = _G[self:GetName().."ProfileSpecList"];
	-- self.curSpec = _G[self:GetName().."CurSpecList"];
	-- self.loadBtn = _G[self:GetName().."ButtonLoad"];
	-- self.profileSpec:Hide();
	-- self.curSpec:Hide();
	-- self.loadBtn:Hide();
end 

function HDH_OnClick_SaveProfile()
	if not HDH_AT_PROFILE_DB then
		HDH_AT_PROFILE_DB = {}
	end
	local ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M:%S")..")"
	HDH_AT_PROFILE_DB[ID_NAME] = {}
	HDH_AT_PROFILE_DB[ID_NAME].HDH_AT_COMMON_DB = HDH_AT_UTIL.Deepcopy(HDH_AT_COMMON_DB)
	HDH_AT_PROFILE_DB[ID_NAME].HDH_AT_DB = HDH_AT_UTIL.Deepcopy(HDH_AT_DB)
	HDH_AT_PROFILE_DB[ID_NAME].ID_NAME = ID_NAME
	HDH_OnShow_ProfileFrame(FRAME.PROFILE)
end

local cr;
local cnt  = 0;

local th = CreateFrame("Frame", nil, UIParent);
th:SetScript("OnUpdate",
	function()
		if cr then
			if coroutine.status(cr) == "suspended" then
				local ret = coroutine.resume(cr);
				if ret == 1 then
					cr = nil;
				end
			end
		end
	end
);

function HDH_OnClick_ExportProfile()
	cr = coroutine.create(
		function()
			-- HDH_AT_ImportAndExportProfileFrame:Hide();
			-- HDH_OP_AlertDlgShow("데이터를 생성 중입니다.\r\n기다려 주세요", HDH_AT_OP.DLG_TYPE.NONE, function() HDH_AT_ImportAndExportProfileFrame:Show(); end);
			local body = FRAME.F_UI_BODY_PROFILE;
			local edData = _G[body:GetName().."EBString"];
			local _, class = UnitClass("player")
			local ID_NAME = class.."("..date("%m/%d %H:%M:%S")..")"
			edData:ClearFocus();
			local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE)
			if HDH_AT_PROFILE_DB and HDH_AT_PROFILE_DB[name] then
				local db = HDH_AT_UTIL.Deepcopy(HDH_AT_PROFILE_DB[name])
				db.ID_NAME = ID_NAME
				local data = WeakAuraLib_TableToString(db, true);
				if not data then 
					HDH_OP_AlertDlgHide();
					HDH_OP_AlertDlgShow("생성에 실패하였습니다.", HDH_AT_OP.DLG_TYPE.OK);
					return 1;
				end

				HDH_OP_AlertDlgHide();
				HDH_OP_AlertDlgShow("생성된 되었습니다.\n\r[ Crtl + C ] 를 활용하여, 문자열을 공유 하세요", HDH_AT_OP.DLG_TYPE.OK);
				edData:SetText(data);
				edData:SetFocus();
			else
				HDH_OP_AlertDlgShow("공유할 프로필을 선택해주세요.", HDH_AT_OP.DLG_TYPE.OK);
				return 1;
			end
			-- local serialized = serialize(DB);
			-- local data = string.gsub(serialized,"\\","\\\\"); 
			
			-- edData:SetText(data);
			-- local str = edData:GetText();
			-- data = WeakAuraLib_StringToTable(data, true);
			return 1;
		end
	);
	coroutine.resume(cr);
end

function HDH_OnClick_ImportProfile()
	local body = FRAME.F_UI_BODY_PROFILE;
	local edData = _G[body:GetName().."EBString"];
	local str = edData:GetText();
	-- local data = deserialize(str);
	local data = WeakAuraLib_StringToTable(str, true);
	if data and data.ID_NAME and data.HDH_AT_COMMON_DB and data.HDH_AT_DB then
		if not HDH_AT_PROFILE_DB then
			HDH_AT_PROFILE_DB = {}
		end

		local ID_NAME = data.ID_NAME;
		HDH_AT_PROFILE_DB[ID_NAME] = {}
		HDH_AT_PROFILE_DB[ID_NAME].HDH_AT_COMMON_DB = HDH_AT_UTIL.Deepcopy(data.HDH_AT_COMMON_DB)
		HDH_AT_PROFILE_DB[ID_NAME].HDH_AT_DB = HDH_AT_UTIL.Deepcopy(data.HDH_AT_DB)
		HDH_AT_PROFILE_DB[ID_NAME].ID_NAME = ID_NAME
		-- HDH_OnShow_ProfileFrame(FRAME.PROFILE, ID_NAME)
		-- HDH_AT_OP_LoadProfileSpec(FRAME.DDM_PROFILE, ID_NAME)
		HDH_OP_AlertDlgShow(ID_NAME.." (으)로\n\r새로운 프로필이 생성되었습니다.")

		HDH_OnShow_ProfileFrame(nil, ID_NAME)
	else
		HDH_OP_AlertDlgShow("잘못된 설정값입니다. 다시 확인해주세요.")
	end
	-- local ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M:%S")..")"
end

function HDH_OnClick_LoadProfile(self)
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE)
	if HDH_AT_PROFILE_DB and HDH_AT_PROFILE_DB[name] then
		HDH_AT_COMMON_DB = HDH_AT_UTIL.Deepcopy(HDH_AT_PROFILE_DB[name].HDH_AT_COMMON_DB)
		HDH_AT_DB = HDH_AT_UTIL.Deepcopy(HDH_AT_PROFILE_DB[name].HDH_AT_DB)
		ReloadUI() 
	else
		HDH_OP_AlertDlgShow("프로필 정보를 찾을 수 없습니다.")
	end
end

function HDH_OnClick_DelProfile()
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_PROFILE)
	if not name then return end
	HDH_AT_PROFILE_DB[name] = nil
	HDH_OnShow_ProfileFrame(FRAME.PROFILE)
end

------------------------------------------
-- control Tab : Spec
------------------------------------------

function HDH_LoadTabSpec()
	local spec = GetSpecialization()
	if spec then
		CurSpec = 1
	end
	if not TAB_TALENT then
		TAB_TALENT = {BtnTalent1, BtnTalent2, BtnTalent3, BtnTalent4}
		local id, name, desc, icon
		for i = 1 , MAX_TALENT_TABS do
			TAB_TALENT[i]:Hide()
			-- id, name, desc, icon = GetSpecializationInfo(i)
			-- if not id then 
			-- 	TAB_TALENT[i]:Hide() 
			-- 	-- break 
			-- end
			--TAB_TALENT[i]:SetNormalTexture(icon)
		end
	end
	-- HDH_ChangeTalentTab(TAB_TALENT[CurSpec], CurSpec)
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
	
	HDH_AT_SwapDBTrackerIndex(listframe[i1].idx, listframe[i2].idx)
end

local function HDH_AT_OP_OnDragTrackerRow(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed;
	if self.elapsed < 0.2 then return end
	self.elapsed = 0;
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
	FRAME.LABEL_TRACKER_ORDER:SetText(selfIdx);
	HDH_AT_OP_ChangeTracker(self.idx);
end

function HDH_AT_OP_AddTrackerButton(name, type, unit, idx)
	local listFrame = FRAME.F_TRACKER_LIST
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
		newButton = CreateFrame("BUTTON", listFrame:GetName().."BtnTracker"..(count+1), listFrame, "HDH_AT_TrackerTapBtnTemplate");
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
		newButton:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,(HDH_TRACKER_LIST_L[type]..":"..HDH_AT_L[unit:upper()])));
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
	-- HDH_AT_OP_UpdateTitle();
end

function HDH_AT_OP_RemoveTracker()
	local idx = GetTrackerIndex();
	local name = HDH_AT_OP_GetTrackerInfo(idx).name;
	if not name then return; end
	local list = TRACKER_TAB_BTN_LIST;
	if (not list.count or list.count == 0) then return; end
	
	local typeText;
	for i = idx , #list-1 do
		list[i].name = list[i+1].name;
		list[i].unit = list[i+1].unit;
		list[i].type = list[i+1].type;

		if HDH_TRACKER.IsEqualClass(list[i].type, "HDH_TRACKER") then
			list[i]:SetText(string.format(STR_TRACKER_BTN_FORMAT,list[i].name,(HDH_TRACKER_LIST_L[list[i].type]..":"..HDH_AT_L[list[i].unit:upper()])));
		else
			list[i]:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,HDH_TRACKER_LIST_L[list[i].type]));
		end
	end
	
	list[list.count]:Hide();
	list.count = list.count - 1;
	FRAME.F_TRACKER_LIST:SetHeight(FRAME.F_TRACKER_LIST:GetHeight() - list[0]:GetHeight());
	HDH_TRACKER.RemoveList(idx);
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
		
		HDH_AT_SwapDBTrackerIndex(idx1, idx2)
		
		tmp = nil
		HDH_RefreshFrameLevel_All()
		FRAME.LABEL_TRACKER_ORDER:SetText(idx2);
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
	local type = ddm.id;
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
			if not HDH_AT_IsExistsTrackerName(name) then
				local newTrackerDB = HDH_DB_Add_Tracker(name, type, unit)
				tracker = HDH_TRACKER.new(newTrackerDB)
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
				local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
				if db.tracker.tracking_all or db.tracker.tracking_boss_aura then
					tracker:InitIcons()
				end
			else
				HDH_OP_AlertDlgShow(name.." 은(는) 이미 존재하는 이름입니다.")
				return
			end
		elseif mode =="modify" then
			local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
			local curName = db.name
			local curType = db.type
			local curUnit = db.unit
			local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex());
			if not tracker then return end
			local isExist = HDH_AT_IsExistsTrackerName(name)
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
						TRACKER_TAB_BTN_LIST[GetTrackerIndex()]:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,(HDH_TRACKER_LIST_L[type]..":"..HDH_AT_L[unit:upper()])));
					else
						TRACKER_TAB_BTN_LIST[GetTrackerIndex()]:SetText(string.format(STR_TRACKER_BTN_FORMAT,name,HDH_TRACKER_LIST_L[type]));
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
	local t = HDH_AT_OP_GetTracker(dstName)
	if t then t:InitIcons() end
end

function HDH_OnClickCopyAura(self)
	local name = UIDropDownMenu_GetSelectedValue(FRAME.DDM_TRACKER_LIST)
	local spec = FRAME.DDM_SPEC_LIST.id;
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
	
	UpdateFrameDB_CB(FRAME.CB_REVERS_H);
	UpdateFrameDB_CB(FRAME.CB_REVERS_V);
	UpdateFrameDB_CB(FRAME.CB_ICON_FIX);
	UpdateFrameDB_SL(FRAME.SL_LINE);
	UpdateFrameDB_CB(FRAME.CB_SHOW_TOOLTIP);
	UpdateFrameDB_DDM(FRAME.DDM_CD_TYPE, DDM_COOLDOWN_LIST);
	UpdateFrameDB_DDM(FRAME.DDM_ORDER_BY, DDM_ICON_ORDER_LIST);
	
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
	
	local db = HDH_AT_OP_GetTrackerInfo(curTracker)
	local type = db and db.type or nil
	
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
		FRAME.F_COOLDOWN_CONFIG:Show();
		FRAME.CB_COLOR_DEBUFF_DEFAULT:Hide();
		FRAME.BTN_COLOR_BUFF:Hide();
		FRAME.BTN_COLOR_DEBUFF:Hide();
		--FRAME.BTN_COLOR_CD_BG:Hide();
	else
		FRAME.F_COOLDOWN_CONFIG:Hide();
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
	UpdateFrameDB_CB(FRAME.CB_LIST_SHARE);
	UpdateFrameDB_CB(FRAME.CB_TRACKER_MERGE_POWERICON);
end

function HDH_AT_OP_OnChangeBody(self, body_type)
	HDH_AT_OP_ChangeBody(body_type, GetTrackerIndex());
end

function HDH_AT_OP_ChangeBody(bodyType, trackerIdx) -- type tracker, aura, ui
	local idx = HDH_AT_OP_GetTrackerInfo(trackerIdx) and trackerIdx
	if (bodyType == BODY_TYPE.AURA and not idx) then
		bodyType = BODY_TYPE.CREATE_TRACKER;
	end
	g_CurMode = bodyType;
	if (bodyType == BODY_TYPE.CREATE_TRACKER) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, BODY_TYPE.CREATE_TRACKER);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, BODY_TYPE.EDIT_TRACKER); -- tab frame 로딩
		HDH_AT_OP_LoadCreateTrackerFrame();                    -- 데이터 로딩
		FRAME.LABEL_TRACKER_ORDER:SetText((TRACKER_TAB_BTN_LIST.count or 0) +1);
		FRAME.F_AURA_CONFIG:Hide();
	elseif (bodyType == BODY_TYPE.EDIT_TRACKER) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_LoadCreateTrackerFrame(idx);                 -- 데이터 로딩
		FRAME.LABEL_TRACKER_ORDER:SetText(idx);
		FRAME.F_AURA_CONFIG:Hide();
	elseif (bodyType == BODY_TYPE.AURA) then
		HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_LoadAuraListFrame(idx);                      -- 데이터 로딩
		FRAME.F_AURA_CONFIG:Hide();
	elseif (bodyType == BODY_TYPE.UI) then 
		if idx then
			HDH_AT_OP_ChangeTapState(TRACKER_TAB_BTN_LIST, idx);
		end
		HDH_AT_OP_ChangeTapState(BODY_TAB_BTN_LIST, bodyType); -- tab frame 로딩
		HDH_AT_OP_ChangeTapState(UI_TAB_BTN_LIST, UI_TAB_BTN_LIST.CurIdx);
		HDH_AT_OP_LoadSetting(idx); 	
		FRAME.F_AURA_CONFIG:Hide();
	elseif (bodyType == BODY_TYPE.AURA_DETAIL) then
	
	end
end

function HDH_AT_OP_UpdateTitle()
	-- local name, type = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	-- local w = TalentText:GetStringWidth()
	-- OptionFrameTitleFrameTextTracker:SetPoint("LEFT",TalentText, "LEFT", w+5, 0)
	
	-- if name then
	-- 	OptionFrameTitleFrameTextTracker:SetText("> "..name)
	-- 	OptionFrameTitleFrameTextUnit:SetText(("(%s)"):format(type:gsub("^%l", string.upper)))
	-- 	w = OptionFrameTitleFrameTextTracker:GetStringWidth()
	-- 	OptionFrameTitleFrameTextUnit:SetPoint("LEFT",OptionFrameTitleFrameTextTracker, "LEFT", w+5, 0)
	-- else
	-- 	OptionFrameTitleFrameTextUnit:SetText("");
	-- 	OptionFrameTitleFrameTextTracker:SetText("> New Tracker");
	-- end
end

function HDH_AT_OP_LoadAuraListFrame(trackerIdx)
	local db = HDH_AT_OP_GetTrackerInfo(trackerIdx)
	if db.name then
		HDH_LoadAuraListFrame(trackerIdx);
		Match_Tracker_DBForFrame(trackerIdx);
		HDH_AT_OP_LoadTrackerBasicSetting(trackerIdx);
		--UnitOptionFrameTabModify:SetPoint("LEFT",UnitOptionFrameTextTitle2,"LEFT",UnitOptionFrameTextTitle2:GetStringWidth()+10,0)
	end
end

function HDH_AT_OP_LoadCreateTrackerFrame(trackerIdx)
	if trackerIdx then -- 인덱스가 있으면 수정모드
		local db = HDH_AT_OP_GetTrackerInfo(trackerIdx)
		local name = db.name
		local type = db.type
		local unit = db.unit
		if not name then return; end
		FRAME.F_TRACKER_CONFIG.mode = "modify"
		FRAME.LABEL_TRACKER_TITLE:SetText("추적 창 수정")
		FRAME.EB_TRACKER_NAME:SetText(name)
		FRAME.BTN_TRACKER_SAVE:SetText("적용")

		for i = 1 , #HDH_TRACKER_LIST do
			if type == HDH_TRACKER_LIST[i] then
				HDH_AT_LoadDropDownButton(FRAME.DDM_TRACKER_TYPE_LIST, i, HDH_TRACKER_LIST_L);
			end
		end
		
		if HDH_TRACKER.IsEqualClass(type, "HDH_TRACKER") then
			-- UpdateFrameDB_CB(FRAME.CB_TRACKER_BUFF);
			-- FRAME.CB_TRACKER_DEBUFF:SetChecked(not FRAME.CB_TRACKER_BUFF:GetChecked());
			UpdateFrameDB_CB(FRAME.CB_TRACKER_MINE);
			UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
			UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA);
			FRAME.CB_TRACKER_ALL_AURA:Show();
			FRAME.CB_TRACKER_BOSS_AURA:Hide();
			-- FRAME.CB_TRACKER_BOSS_AURA:Show();
			-- FRAME.CB_TRACKER_DEBUFF:Show();
			-- FRAME.CB_TRACKER_BUFF:Show();
			FRAME.CB_TRACKER_MINE:Show();
			FRAME.DDM_UNIT_LIST:Show();
			
			for i = 1 , #HDH_UNIT_LIST do
				if unit == HDH_UNIT_LIST[i] then
					HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, i, HDH_UNIT_LIST_L);
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
		FRAME.BTN_TRACKER_DELETE:Enable()
		FRAME.BTN_TRACKER_LEFT:Enable()
		FRAME.BTN_TRACKER_RIGHT:Enable()
		FRAME.BTN_TRACKER_COPY:Enable()
		FRAME.LABEL_TRACKER_ERROR:SetText(nil)
		UIDropDownMenu_EnableDropDown(FRAME.DDM_SPEC_LIST)
		UIDropDownMenu_DisableDropDown(FRAME.DDM_TRACKER_LIST)
		
	else
		FRAME.F_TRACKER_CONFIG.mode = "add"
		FRAME.F_TRACKER_CONFIG:Show()
		
		HDH_AT_LoadDropDownButton(FRAME.DDM_TRACKER_TYPE_LIST, nil, HDH_TRACKER_LIST_L);
		HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, nil, HDH_UNIT_LIST_L);
		--DDM_LoadUnitList(1)
		--DDM_LoadTabList()
		--DDB_LoadSpecList()
		
		FRAME.LABEL_TRACKER_TITLE:SetText("추적 창 추가")
		FRAME.BTN_TRACKER_SAVE:SetText("추가")
		FRAME.BTN_TRACKER_DELETE:Disable()
		FRAME.BTN_TRACKER_LEFT:Disable()
		FRAME.BTN_TRACKER_RIGHT:Disable()
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
		UIDropDownMenu_DisableDropDown(FRAME.DDM_SPEC_LIST)
		UIDropDownMenu_DisableDropDown(FRAME.DDM_TRACKER_LIST)
		FRAME.BTN_TRACKER_COPY:Disable()
		FRAME.LABEL_TRACKER_ERROR:SetText(nil)
		FRAME.EB_TRACKER_NAME:SetText("")
		FRAME.DDM_UNIT_LIST:Hide();
	end
	
	local config_list = HDH_AT_GetDB()
	local items = {}
	for i= 1, #config_list do
		items[i] = config_list[i].Name
	end
	HDH_AT_LoadDropDownButton(FRAME.DDM_SPEC_LIST, nil, items)
	
	local tracker_list = HDH_AT_GetDBIndex().tracker_list
	items ={}
	for i = 1, #tracker_list do
		items[i] = tracker_list[i].name
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
			if _G[btn:GetName().."Border1"] then
				_G[btn:GetName().."Bg"]:SetVertexColor(0,0,0,0.5);
				_G[btn:GetName().."Border1"]:Hide();
				_G[btn:GetName().."Border2"]:Hide();
				_G[btn:GetName().."Border3"]:Hide();
				_G[btn:GetName().."Border4"]:Hide();
				_G[btn:GetName().."Border5"]:Hide();
				_G[btn:GetName().."Border6"]:Hide();
				_G[btn:GetName().."Border7"]:Hide();
			end
			-- _G[btn:GetName().."On"]:Hide();
			if body then body:Hide(); end
		end
	end
	
	-- on
	idx = idx and idx or 0;
	btn = tablist[idx];
	body = tablist.Body[idx];
	if btn then
		_G[btn:GetName().."BgLine2"]:Show();
		if _G[btn:GetName().."Border1"] then
			_G[btn:GetName().."Bg"]:SetVertexColor(0,0,0,1);
			_G[btn:GetName().."Border1"]:Show();
			_G[btn:GetName().."Border2"]:Show();
			_G[btn:GetName().."Border3"]:Show();
			_G[btn:GetName().."Border4"]:Show();
			_G[btn:GetName().."Border5"]:Show();
			_G[btn:GetName().."Border6"]:Show();
			_G[btn:GetName().."Border7"]:Show();
		end
		
		_G[btn:GetName().."Text"]:SetTextColor(1,0.8,0);
		-- _G[btn:GetName().."On"]:Show();
		if body then body:Show(); end
		tablist.CurIdx = idx;
	end
end


------------------------------------------
-- Call back function
------------------------------------------

function HDH_AT_OP_OnValueChanged(self, value, userInput)
	local index = GetTrackerIndex()
	local db = HDH_AT_OP_GetTrackerInfo(index)
	if not db then return end
	value = math.floor(value)
	if (self == FRAME.SL_FONT_SIZE1) or (self == FRAME.SL_FONT_SIZE2) or (self == FRAME.SL_FONT_SIZE3) 
	or (self == FRAME.SL_FONT_SIZE4) or (self == FRAME.SL_BAR_NAME_TEXT_SIZE) 
	or (self == FRAME.SL_BAR_NAME_MARGIN_RIGHT ) or(self == FRAME.SL_BAR_NAME_MARGIN_LEFT )  then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_AT_OP_GetTracker(index)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == FRAME.SL_ICON_SIZE then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_AT_OP_GetTracker(index)
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
				for k, tracker in pairs(HDH_TRACKER.GetList()) do
					tracker:Update()
				end
			end
		end
	elseif (self == FRAME.SL_ON_ALPHA) or (self == FRAME.SL_OFF_ALPHA) then
		UpdateFrameDB_SL(self, value/100);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_AT_OP_GetTracker(index)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif (self == FRAME.SL_LINE) then
		UpdateFrameDB_SL(self, value);
		local t = HDH_AT_OP_GetTracker(index)
		if t then 
			if UI_LOCK then t:SetMove(UI_LOCK)
					   else t:Update() end
		end		
	elseif (self == FRAME.SL_MARGIN_H) or (self == FRAME.SL_MARGIN_V) then
		UpdateFrameDB_SL(self, value);
		if HDH_AT_OP_IsEachSetting() then
			local t = HDH_AT_OP_GetTracker(index)
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
			local t = HDH_AT_OP_GetTracker(index);
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
			local t = HDH_AT_OP_GetTracker(index)
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
		HDH_AT_DB_UI_Reset()
		HDH_TRACKER.InitVaribles()
		HDH_TRACKER.UpdateSettingAll()
		HDH_TRACKER.SetMoveAll(false)
		HDH_AT_OP_LoadSetting(GetTrackerIndex())
	else
		HDH_AT_DB_Release()
		ReloadUI()
	end
end

local tmp_id
local tmp_chk
function HDH_OnEditFocusGained(self)
	local btn = _G[self:GetParent():GetName().."ButtonAdd"]
	local chk = _G[self:GetParent():GetName().."CheckButtonIsItem"]
	if(self:GetText() == "") then
		btn:SetText("등록")
	else
		btn:SetText("수정")
	end
	tmp_id = self:GetText()
	tmp_chk = chk:GetChecked()
	--self:SetWidth(EDIT_WIDTH_L)
end

function HDH_OnEditFocusLost(self)
	local btn = _G[self:GetParent():GetName().."ButtonAdd"]
	tmp_id = nil
	tmp_chk = false
	self:Hide()
end

function HDH_OnEditEscape(self)
	_G[self:GetParent():GetName().."CheckButtonIsItem"]:SetChecked(tmp_chk)
	self:SetText(tmp_id or "")
	self:ClearFocus()
end

function HDH_OnEnterPressed(self)
	local index = GetTrackerIndex()
	local db = HDH_AT_OP_GetTrackerInfo(index)
	local name = db.name
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
			if ret == #(db.spell_list) then
				local rowFrame = HDH_GetRowFrame(listFrame, ret+1, FLAG_ROW_CREATE)
				HDH_ClearRowData(rowFrame)
				rowFrame:Show() 
			end
			local t = HDH_AT_OP_GetTracker(index)
			if t then t:InitIcons() end
		else
			self:SetText("") 
		end
	else
		HDH_OP_AlertDlgShow("주문 ID/이름을 입력해주세요.")
	end
end

function HDH_OnClickBtnAddAndDel(self, row)
	local edBox= _G[self:GetParent():GetName().."EditBoxID"]
	if self:GetText() == "등록" or self:GetText() == "수정" then
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
		--HDH_LoadAuraListFrame(CurUnit, row-1, row)
		
		local f1 = HDH_GetRowFrame(ListFrame, row)
		local f2 = HDH_GetRowFrame(ListFrame, row-1)
		CrateAni(f1)
		CrateAni(f2)
		f2.ani.func = HDH_LoadAuraListFrame
		f2.ani.args = {GetTrackerIndex(), row-1, row}
		StartAni(f1, ANI_MOVE_UP)
		StartAni(f2 , ANI_MOVE_DOWN)
	end
	local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
		f2.ani.func = HDH_LoadAuraListFrame
		f2.ani.args = {GetTrackerIndex(), row, row+1}
		StartAni(f1, ANI_MOVE_DOWN)
		StartAni(f2 , ANI_MOVE_UP)
		--HDH_LoadAuraListFrame(CurUnit, row, row+1)
	end
	local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
	if t then t:InitIcons() end
end

function HDH_OnSelectedColor()
	if ColorPickerFrame:IsShown() then return end
	local r,g,b = ColorPickerFrame:GetColorRGB();
	UpdateFrameDB_CP(ColorPickerFrame.colorButton, r,g,b, ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue());
	UpdateFrameDB_CP(ColorPickerFrame.colorButton);
	-- ColorPickerFrame.colorButton = nil;
	if HDH_AT_OP_IsEachSetting() then
		local tracker = HDH_AT_OP_GetTracker(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
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
		local tracker = HDH_AT_OP_GetTracker(HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()))
		if not tracker then return end
		tracker:UpdateSetting()
	else
		HDH_TRACKER.UpdateSettingAll()
	end
end

function HDH_AT_OP_IsEachSetting()
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex());
	if db then
		return db.ui.use_dont_common;
	else
		return false;
	end
end

function HDH_OnAlways(_ , no, check)
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	local spell_list = db.spell_list
	spell_list[tonumber(no)].Always = check
	local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
	if t then t:InitIcons() end
end

function HDH_AT_OP_OnSelectedItem_DDM(self, btn, value, id)
	UIDropDownMenu_SetSelectedID(self, id);
	UIDropDownMenu_SetSelectedValue(self, value);
	self.value = value;
	self.id = id;
	if (self == FRAME.DDM_SPEC_LIST) then
		if id > 0 then
			UIDropDownMenu_EnableDropDown(FRAME.DDM_TRACKER_LIST)
		else
			UIDropDownMenu_DisableDropDown(FRAME.DDM_TRACKER_LIST)
		end
	elseif (self == FRAME.DDM_TRACKER_TYPE_LIST) then
		if HDH_TRACKER.IsEqualClass(self.id, "HDH_TRACKER") then
			-- FRAME.CB_TRACKER_BUFF:Show();
			-- FRAME.CB_TRACKER_DEBUFF:Show();
			FRAME.CB_TRACKER_MINE:Show();
			FRAME.CB_TRACKER_ALL_AURA:Show();
			-- FRAME.CB_TRACKER_BOSS_AURA:Show();
			FRAME.DDM_UNIT_LIST:Show();
			if FRAME.F_TRACKER_CONFIG.mode == "modify" then
				local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex());
				UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
				UpdateFrameDB_CB(FRAME.CB_TRACKER_BOSS_AURA);
				local selected = nil;
				for i = 1 , #HDH_UNIT_LIST do
					if tracker.db.unit == HDH_UNIT_LIST[i] then
						selected = i; 
						break;
					end
				end
				HDH_AT_LoadDropDownButton(FRAME.DDM_UNIT_LIST, selected, HDH_UNIT_LIST_L);
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
		
		if HDH_TRACKER.IsEqualClass(self.id,"HDH_T_TRACKER") or HDH_TRACKER.IsEqualClass(self.id, "HDH_USED_SKILL_TRACKER") then 
			FRAME.CB_TRACKER_ALL_AURA:Show();
			UpdateFrameDB_CB(FRAME.CB_TRACKER_ALL_AURA);
		end
		
		if HDH_TRACKER.IsEqualClass(self.id,"HDH_COMBO_POINT_TRACKER") then
			FRAME.CB_TRACKER_MERGE_POWERICON:Show();
		else
			FRAME.CB_TRACKER_MERGE_POWERICON:Hide();
		end
	elseif (self == FRAME.DDM_CD_TYPE) then
		UpdateFrameDB_DDM(self, nil, id);
		local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex());
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
		local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex());
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
			local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
			local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
			local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
	local idx = GetTrackerIndex()
	local db = HDH_AT_OP_GetTrackerInfo(idx)
	local name = db.name
	local unit = db.unit
	local type = db.type
	local tracker = HDH_AT_OP_GetTracker(idx);
	UpdateFrameDB_CB(self, checked);
	if self == FRAME.CB_LIST_SHARE then -- 추적 활성화
		if checked then
			db.tracker.share_spec = HDH_GetSpec(name);
			tracker:InitIcons();
		else
			db.tracker.share_spec = nil;
			tracker:InitIcons();
		end
		HDH_AT_OP_LoadAuraListFrame(GetTrackerIndex());
	elseif self == FRAME.CB_EACH then -- 개별 설정
		if checked then
			db.ui.icon = HDH_AT_UTIL.Deepcopy(HDH_AT_GetCommonDB().icon)
			db.ui.font = HDH_AT_UTIL.Deepcopy(HDH_AT_GetCommonDB().font)
			db.ui.bar = HDH_AT_UTIL.Deepcopy(HDH_AT_GetCommonDB().bar)
			HDH_AT_OP_LoadSetting(idx)
			if not tracker then return; end
			tracker:UpdateSetting()
			if UI_LOCK then
				tracker:SetMove(UI_LOCK)
			else
				tracker:InitIcons()
			end
		else
			FRAME.CB_EACH:SetChecked(true)
			UpdateFrameDB_CB(FRAME.CB_EACH, true)
			HDH_OP_AlertDlgShow("공용 UI 설정으로 전환하시겠습니까?\n기존 개별 설정은 삭제 됩니다.", 
				HDH_AT_OP.DLG_TYPE.YES_NO, 
				function ()
					local idx = GetTrackerIndex()
					local db = HDH_AT_OP_GetTrackerInfo(idx)
					db.ui.icon = HDH_AT_GetCommonDB().icon
					db.ui.font = HDH_AT_GetCommonDB().font
					db.ui.bar = HDH_AT_GetCommonDB().bar
					FRAME.CB_EACH:SetChecked(false)
					UpdateFrameDB_CB(FRAME.CB_EACH, false)
					HDH_AT_OP_LoadSetting(idx)
					local tracker = HDH_AT_OP_GetTracker(idx)
					if not tracker then return; end
					tracker:UpdateSetting()
					if UI_LOCK then
						tracker:SetMove(UI_LOCK)
					else
						tracker:InitIcons()
					end
				end
			);
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
		HDH_AT_OP_ShowGrid(FRAME.F_MAIN, checked);
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
	elseif self == FRAME.CB_AURA_SHOW_VALUE_ENABLE then -- 수치 활성화
		local parent = self:GetParent()
		local spell_list = db.spell_list
		if not spell_list[tonumber(parent.row)] then return end
		spell_list[tonumber(parent.row)].ShowValue = checked
		if tracker then tracker:InitIcons() end
	elseif self == FRAME.CB_AURA_CONFIG_GLOW_ENABLE then -- 반짝임 활성화
		local parent = self:GetParent()
		local spell_list = db.spell_list
		if not spell_list[tonumber(parent.row)] then return end
		spell_list[tonumber(parent.row)].Glow = checked
		if tracker then tracker:InitIcons() end
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
	-- local name =  HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()); 
	-- local tracker = HDH_AT_OP_GetTracker(name);
	-- local spec = HDH_GetSpec(name);
	-- HDH_OP_AlertDlgShow("현재 목록을 삭제하고 자원 데이터를 등록 하시겠습니까?\n|cffff0000(기존 목록은 삭제 됩니다. 일부 설정이 변경될 수 있습니다.)", HDH_AT_OP.DLG_TYPE.YES_NO, 
	-- 					function() tracker:CreateData(spec); tracker:InitIcons(); OptionFrame:Hide(); OptionFrame:Show();  end);
	
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
	
	if FRAME.F_AURA_LIST.row and (#FRAME.F_AURA_LIST.row) <= row then return end
	local data = HDH_AT_OP_GetTrackerInfo(self.tab).spell_list[row]
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
	if FRAME.F_AURA_LIST.row and (#FRAME.F_AURA_LIST.row) <= row then 
		HDH_OP_AlertDlgShow("아이콘 이미지 변경을 실패하였습니다")
	end
	local db = HDH_AT_OP_GetTrackerInfo(parent.tab)
	if not db then 
		HDH_OP_AlertDlgShow("아이콘 이미지 변경을 실패하였습니다")
	end
	local data = db.spll_list[row]
	if not data then return end
	if parent.texture then 
		-- if not data.defaultImg then data.defaultImg = data.Texture; end
		data.Texture = parent.texture
		OptionFrame:Hide()
		OptionFrame:Show()
		local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
	local data = HDH_AT_OP_GetTrackerInfo(self.tab).spell_list[parent.row]
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
	local spell = HDH_AT_OP_GetTrackerInfo(self.tab).spell_list[tonumber(row)]
	if not spell then return end
	
	self.row = row
	self.spec = spec
	self.tab = tab

	if not spell.Glow then
		spell.Glow = {{}, {}}
	end

	_G[self:GetName().."CheckButtonGlowWhenCount"]:SetChecked(spell.Glow[1].enable or false)
	HDH_AT_LoadDropDownButton(_G[self:GetName().."DDMGlowWhenCount"], spell.Glow[1].condition or 1, DDM_GLOW_CONDITION_TYPE, nil, 50, 50);
	_G[self:GetName().."EBGlowWhenCount"]:SetText(spell.Glow[1].value or "1")

	_G[self:GetName().."CheckButtonGlowWhenTime"]:SetChecked(spell.Glow[2].enable or false)
	HDH_AT_LoadDropDownButton(_G[self:GetName().."DDMGlowWhenTime"], spell.Glow[2].condition or 1, DDM_GLOW_CONDITION_TYPE, nil, 50, 50);
	_G[self:GetName().."EBGlowWhenTime"]:SetText(spell.Glow[2].value or "0")
end

function HDH_OnClick_SaveGlowCount(self)
	local parent = self:GetParent()

	local countEnable = _G[parent:GetName().."CheckButtonGlowWhenCount"]:GetChecked()
	local countCondition = UIDropDownMenu_GetSelectedID(_G[parent:GetName().."DDMGlowWhenCount"])
	local countValue = _G[parent:GetName().."EBGlowWhenCount"]:GetText()
	_G[parent:GetName().."EBGlowWhenCount"]:ClearFocus()

	local timeEnable = _G[parent:GetName().."CheckButtonGlowWhenTime"]:GetChecked()
	local timeCondition = UIDropDownMenu_GetSelectedID(_G[parent:GetName().."DDMGlowWhenTime"])
	local timeValue = _G[parent:GetName().."EBGlowWhenTime"]:GetText()
	_G[parent:GetName().."EBGlowWhenTime"]:ClearFocus()

	--local v2 = _G[parent:GetName().."EB3"]:GetText()
	if not parent.row then return end
	local spell = HDH_AT_OP_GetTrackerInfo(self.tab).spell_list[tonumber(parent.row)]
	if not spell then return end

	spell.Glow[1] = {type = "count", enable = countEnable, condition = countCondition, value = tonumber(countValue)}
	spell.Glow[2] = {type = "remaining", enable = timeEnable, condition = timeCondition, value = tonumber(timeValue)}

	local t = HDH_AT_OP_GetTracker()
	if t then t:InitIcons() end
end

function HDH_LoadValueFrame(self, row, spec, tab) -------------------------------------------------------
	local data = HDH_AT_OP_GetTrackerInfo(tab).spell_list[tonumber(row)]
	if not data then return end
	
	self.row = row
	self.spec = spec
	self.tab = tab
	--GlowOptionFrameEB:SetText(db[tonumber(id)].GlowCount or 0)
	_G[self:GetName().."CheckButtonShowValue"]:SetChecked(data.ShowValue)
	
	--_G[self:GetName().."CheckButtonValue1"]:SetChecked(db.v1)
	--_G[self:GetName().."CheckButtonValue2"]:SetChecked(db.v2)
	_G[self:GetName().."CheckButtonValuePerHp1"]:SetChecked(data.v1_hp or false)
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
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex())
	if not db then return end
	if not FRAME.F_AURA_CONFIG_VALUE.row then return end
	if not db.spell_list[tonumber(FRAME.F_AURA_CONFIG_VALUE.row)] then return end
	db = db.spell_list[tonumber(FRAME.F_AURA_CONFIG_VALUE.row)]
	--db.v1 = v1
	--db.v1_type = HDH_AT_UTIL.Trim(text1) or "" 
	db.v1_hp = h1
	--db.v2 = v2 
	--db.v2_type = HDH_AT_UTIL.Trim(text2) or ""
	--db.v2_hp = h2
	local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()).spell_list
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
	local db = HDH_AT_OP_GetTrackerInfo(GetTrackerIndex()).spell_list
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
	
	local t = HDH_AT_OP_GetTracker(GetTrackerIndex())
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
	local name = FRAME.F_AURA_CONFIG_SPLIT_BAR.name;
	local tracker = HDH_AT_OP_GetTracker(GetTrackerIndex());
	local powerMax = tracker.max or UnitPowerMax('player', HDH_POWER_TRACKER.POWER[tracker.type].power_index);
	local frame = FRAME.F_AURA_CONFIG_SPLIT_BAR
	if not data then return end
	if not frame.bar then frame.bar = {}; frame.text={};end
	local margin = 3;
	local w,h,cnt;
	local option = HDH_AT_OP_GetTracker(name).option;
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
	local db = FRAME.F_AURA_CONFIG_SPLIT_BAR.db;
	local name = FRAME.F_AURA_CONFIG_SPLIT_BAR.name;
	local parent = self:GetParent():GetParent();
	local tracker = HDH_AT_OP_GetTracker();
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
			HDH_AT_OP_GetTracker(index):InitIcons();
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
		HDH_AT_OP_GetTracker(index):InitIcons();
	end
	HDH_AT_UpdatePreviewSplitBar(db);
end

function HDH_LoadTalentSpellFrame(self, row, spec, tracker_idx)  -----------------------------------------
	local prefix = self:GetName();
	local cbShow = _G[prefix.."CheckButtonShow"];
	local cbDontShow = _G[prefix.."CheckButtonDontShow"];
	local eb = _G[prefix.."EditBox"];
	local db = HDH_AT_OP_GetTrackerInfo(tracker_idx);
	self.row = row
	self.spec = spec
	self.name = db.name
	self.tracker_idx = tracker_idx;
	if not db.spell_list[tonumber(row)] then return end
	db = db.spell_list[tonumber(row)];
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
	local db = HDH_AT_OP_GetTrackerInfo(parent.tracker_idx);
	local name = db.name
	db = db.spell_list[tonumber(parent.row)];
	if not db then return end
	local text = HDH_AT_UTIL.Trim(eb:GetText());
	if not text or #text == 0 then
		eb:SetText("");
		cbShow:SetChecked(true);
		cbDontShow:SetChecked(false);
		db.Ignore = nil;
		HDH_AT_OP_GetTracker(name):InitIcons();
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
	
	HDH_AT_OP_GetTracker(GetTrackerIndex()):InitIcons();
end

function HDH_LoadSetBarFrame(self, row, spec, idx)  -----------------------------------------
	local db = HDH_AT_OP_GetTrackerInfo(idx);
	local name = db.name
	db = db.spell_list[tonumber(row)] 
	if not db then return end
	FRAME.F_AURA_CONFIG_SPLIT_BAR.row = row
	FRAME.F_AURA_CONFIG_SPLIT_BAR.spec = spec
	FRAME.F_AURA_CONFIG_SPLIT_BAR.name = name
	if HDH_TRACKER.IsEqualClass(type, "HDH_POWER_TRACKER") then -- or HDH_TRACKER.IsEqualClass(type, "HDH_STAGGER_TRACKER")
		db.split_bar = db.split_bar or {};
		db = db.split_bar;
		local i = 1;
		local f;
		local last = 0;
		for i = 1 , MAX_SPLIT_ADDFRAME do
			f = HDH_GetBarSplitFrame(FRAME.F_AURA_CONFIG_SPLIT_BAR, i);
			if db[i] then
				if not f then f = HDH_GetBarSplitFrame(FRAME.F_AURA_CONFIG_SPLIT_BAR, i, true); end
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
		f = HDH_GetBarSplitFrame(FRAME.F_AURA_CONFIG_SPLIT_BAR, last+1, true);-- 추가 프레임 넣고 종료
		if f then f:Show() end
		FRAME.F_AURA_CONFIG_SPLIT_BAR.db = db;
		HDH_AT_UpdatePreviewSplitBar(db);
		-- RowDetailSetFrameListButton6:Enable();
		FRAME.F_AURA_CONFIG_SPLIT_BAR:Show();
	else
		-- RowDetailSetFrameListButton6:Disable();
		FRAME.F_AURA_CONFIG_SPLIT_BAR:Hide();
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
	local db = HDH_AT_OP_GetTrackerInfo(idx).spell_list
	db = db[tonumber(row)]
	if not db then return end
	local frame = FRAME.F_AURA_CONFIG
	local name = _G[frame:GetName().."HeaderText"]
	local icon = _G[frame:GetName().."HeaderIcon"]
	name:SetText(db.Name)
	icon:SetTexture(db.Texture)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92);
	frame:Show()
	HDH_AT_OP_ChangeTapState(AURA_DETAIL_TAB_BTN_LIST, AURA_DETAIL_TAB_BTN_LIST.CurIdx);
	FRAME.F_AURA_LIST:Hide()
	
	-- HDH_LoadSoundFrame(SoundFrame, row , spec, idx)
	HDH_LoadChangeIconFrame(FRAME.F_AURA_CONFIG_CHANGE_ICON, row, spec, idx)
	HDH_LoadValueFrame(FRAME.F_AURA_CONFIG_VALUE, row, spec, idx)
	HDH_LoadGlowFrame(FRAME.F_AURA_CONFIG_GLOW, row, spec, idx)
	HDH_LoadSetBarFrame(FRAME.F_AURA_CONFIG_SPLIT_BAR, row, spec, idx)
	HDH_LoadTalentSpellFrame(FRAME.F_AURA_CONFIG_TALENT, row, spec, idx)
end

function HDH_AT_OP_OnClick_AuraConfigFrameClose(self)
	FRAME.F_AURA_LIST:Show()
	FRAME.F_AURA_CONFIG:Hide()
end

--------------------------------
-- end
--------------------------------

function HDH_Option_OnShow(self)
	if not HDH_TRACKER.IsLoaded then self:Hide(); return end
	-- if not GetSpecialization() then
	-- 	print("|cffff0000AuraTracking:Error - |cffffff00직업 전문화를 활성화 해야합니다.(10렙 이상)")
	-- 	self:Hide()
	-- 	return
	-- end
	
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
	
	-- if not DB_AURA or (DB_AURA.Talent and #DB_AURA.Talent == 0) then
	-- 	HDH_TRACKER.InitVaribles()
	-- end
	
	local listFrame = FRAME.F_TRACKER_LIST
	local count = TRACKER_TAB_BTN_LIST.count or 0;
	
	
	local tracker_list = HDH_AT_GetDBIndex().tracker_list
	for i = #tracker_list+1, count do -- 필요 없는것들부터 정리하고
		TRACKER_TAB_BTN_LIST[i]:Hide();
		count = #tracker_list;
	end
	
	
	if #tracker_list == 0 then
		listFrame:SetSize(listFrame:GetParent():GetWidth(), TRACKER_TAB_BTN_LIST.DefaultBtn:GetHeight());
	elseif count < #tracker_list then
		for i = 1, #tracker_list do
			HDH_AT_OP_AddTrackerButton(tracker_list[i].name, tracker_list[i].type, tracker_list[i].unit, i);
		end
		if TRACKER_TAB_BTN_LIST.CurIdx == nil then 
			SetTrackerIndex(1);
			g_CurMode = BODY_TYPE.AURA;
		end
	end
	
	HDH_LoadTabSpec();
	HDH_AT_OP_ChangeBody(g_CurMode, GetTrackerIndex());
end

function HDH_Option_OnLoad(self)
	InitFrame();

	self:SetResizeBounds(FRAME_W, MIN_H, FRAME_W, MAX_H) 
	
	-- SETTING_CONTENTS_FRAME = SettingFrameSFContents;
	-- ListFrame = _G[UnitOptionFrame:GetName().."SFContents"];
	
	FRAME.F_TRACKER_LIST:GetParent().scrollBarHideable = true;
	
	TRACKER_TAB_BTN_LIST = {};
	TRACKER_TAB_BTN_LIST.Body = {};
	--TRACKER_TAB_BTN_LIST.CurIdx;
	TRACKER_TAB_BTN_LIST[BODY_TYPE.CREATE_TRACKER] = FRAME.BTN_TRACKER_ADD-- BODY_TYPE.CREATE_TRACKER = 0
	TRACKER_TAB_BTN_LIST.Body[BODY_TYPE.CREATE_TRACKER] = FRAME.F_TRACKER_CONFIG
	TRACKER_TAB_BTN_LIST.DefaultBtn = FRAME.BTN_TRACKER_ADD -- 리스트의 height 를 측정하는 토대가 되는 버튼의 크기를 얻기위해 사용.
	
	BODY_TAB_BTN_LIST 	   = { FRAME.TAB_AURA, 	  FRAME.TAB_TRACKER,      FRAME.TAB_UI};
	BODY_TAB_BTN_LIST.Body = { FRAME.F_AURA_LIST, FRAME.F_TRACKER_CONFIG, FRAME.F_UI_CONFIG };
	BODY_TAB_BTN_LIST.CurIdx = 1;
	
	UI_TAB_BTN_LIST 	 = {FRAME.TAB_UI_FONT,    FRAME.TAB_UI_ICON,    FRAME.TAB_UI_BAR,    FRAME.TAB_UI_PROFILE,    FRAME.TAB_UI_ETC   };
	UI_TAB_BTN_LIST.Body = {FRAME.F_UI_BODY_FONT, FRAME.F_UI_BODY_ICON, FRAME.F_UI_BODY_BAR, FRAME.F_UI_BODY_PROFILE, FRAME.F_UI_BODY_ETC}; -- , SettingFrameUIBodyShare ,SettingFrameUIListSFContentsShare
	UI_TAB_BTN_LIST.CurIdx = 1;
	
	AURA_DETAIL_TAB_BTN_LIST 	  = {FRAME.TAB_AURA_CONFIG_GLOW, FRAME.TAB_AURA_CONFIG_CHANGE_ICON } -- , FRAME.TAB_AURA_CONFIG_TALENT, FRAME.TAB_AURA_CONFIG_SPLIT_BAR 
	AURA_DETAIL_TAB_BTN_LIST.Body = {FRAME.F_AURA_CONFIG_GLOW,   FRAME.F_AURA_CONFIG_CHANGE_ICON   } -- , FRAME.F_AURA_CONFIG_TALENT,   FRAME.F_AURA_CONFIG_SPLIT_BAR   
	AURA_DETAIL_TAB_BTN_LIST.CurIdx = 1;
	-- 동적 버튼 width 적용
	tab_width = ((FRAME_W-10) / table.getn(AURA_DETAIL_TAB_BTN_LIST))
	for i = 1, table.getn(AURA_DETAIL_TAB_BTN_LIST) do
		AURA_DETAIL_TAB_BTN_LIST[i]:SetWidth(tab_width)
	end
	
	LocateFrame();
end

-----------------------------------------
---------------------
SLASH_AURATRACKING1 = '/at'
SLASH_AURATRACKING2 = '/auratracking'
SLASH_AURATRACKING3 = '/ㅁㅅ'
SlashCmdList["AURATRACKING"] = function (msg, editbox)
	if HDH_AT_ConfigFrame:IsShown() then 
		HDH_AT_ConfigFrame:Hide()
	else
		HDH_AT_ConfigFrame:Show()
	end
end
