--ATC_OptionFrame = CreateFrame("Frame", "ATC_Option", OptionFrame, "CooldownOptionTemplate")

--ATC_OptionFrame:Show()
---------------------------------------------------
local AT_VARS = {}
local AT_FUNC = {}
local function GetTabType() return CurUnit end
local function SetTabType(t) CurUnit = t end

AT_VARS.UnitOptionFrameTextTitle = UnitOptionFrameTextTitle
AT_VARS.GetTabType = GetTabType
AT_VARS.SetTabType = SetTabType

AT_FUNC.HDH_LoadListFrame = HDH_LoadListFrame
AT_FUNC.HDH_LoadUnitUI	  = HDH_LoadUnitUI
AT_FUNC.SetActiveUnitTab  = SetActiveUnitTab --option
--------------------------------------------------------

-------------------------------------------------------

function HDH_ATC_OnAlwaysShow(checked)
	DB_OPTION.cooldown.always_show = checked
	HDH_ATC_OnShareSetting()
end

function HDH_ATC_OnCheckShowCooldown(checked)
	DB_OPTION.cooldown.show_cooldown = checked
	HDH_ATC_OnShareSetting()
end

function HDH_ATC_OnCheckShowAble(checked)
	DB_OPTION.cooldown.use_able = checked
	HDH_ATC_OnShareSetting()
end

function HDH_ATC_OnValueChanged(self, value)
	value = math.floor(value)
	if self == CooldownSettingFrameSliderMaxTime then
		DB_OPTION.cooldown.max_time = value
	elseif self == CooldownSettingFrameSliderFont then
		DB_OPTION.cooldown.font.fontsize = value
	elseif self == CooldownSettingFrameSliderIcon then
		DB_OPTION.cooldown.icon.size = value
	elseif self == CooldownSettingFrameSliderOnAlpha then
		DB_OPTION.cooldown.icon.on_alpha = value/100
	elseif self == CooldownSettingFrameSliderOffAlpha then
		DB_OPTION.cooldown.icon.off_alpha = value/100
	elseif AT_VARS.GetTabType() ~= "cooldown" then
		return
	end
	HDH_ATC_OnShareSetting()
end

------------------------------------------
-- control UI 
------------------------------------------

function HDH_ATC_SetUI()
	CooldownSettingFrameCheckButtonAlwaysShow:SetChecked(DB_OPTION.cooldown.always_show)
	CooldownSettingFrameCheckButtonShowCooldown:SetChecked(DB_OPTION.cooldown.show_cooldown)
	CooldownSettingFrameCheckButtonShowAble:SetChecked(DB_OPTION.cooldown.use_able)
	CooldownSettingFrameSliderMaxTime:SetValue(DB_OPTION.cooldown.max_time or 0)
	CooldownSettingFrameSliderFont:SetValue(DB_OPTION.cooldown.font.fontsize)
	CooldownSettingFrameSliderIcon:SetValue(DB_OPTION.cooldown.icon.size)
	CooldownSettingFrameSliderOnAlpha:SetValue(DB_OPTION.cooldown.icon.on_alpha *100)
	CooldownSettingFrameSliderOffAlpha:SetValue(DB_OPTION.cooldown.icon.off_alpha *100)
end

------------------------------------------
-- control DropDownMenu
------------------------------------------

---------------------------------------------
-- hook
---------------------------------------------
local AT_TAB_UNIT = {BtnPlayer, BtnTarget, BtnFocus}
function HDH_ATC_ChangeTalentTab(self, spec)

end

function HDH_ATC_ChangeCooldownTab(self)
	if self == BtnCooldown then
		AT_VARS.SetTabType("cooldown")
		AT_VARS.UnitOptionFrameTextTitle:SetText("Cooldown")
		AT_FUNC.SetActiveUnitTab(AT_TAB_UNIT[1], false) 
		AT_FUNC.SetActiveUnitTab(AT_TAB_UNIT[2], false)
		AT_FUNC.SetActiveUnitTab(AT_TAB_UNIT[3], false)
		AT_FUNC.SetActiveUnitTab(self,true)
	--	CooldownOptionFrame:Show()
	--	UnitOptionFrame:Hide()
		--CurUnit="cooldown"
		AT_FUNC.HDH_LoadListFrame(AT_VARS.GetTabType())
		AT_FUNC.HDH_LoadUnitUI(AT_VARS.GetTabType())
		BtnShowCooldownSetting:Show()
	else
		AT_FUNC.SetActiveUnitTab(BtnCooldown,false)
		BtnShowCooldownSetting:Hide()
		--CooldownOptionFrame:Hide()
		--UnitOptionFrame:Show()
	end
end


function HDH_ATC_Option_OnShow(self)
	--HDH_LoadDropDownCooldown()
	--HDH_ATC_LoadUI()
end

function HDH_ATC_MOVE(bool)
	ATC:MoveFrame(bool)
end

function HDH_ATC_OnShareSetting()
	if ATC_UI_LOCK then
		ATC:UpdateSetting()
		ATC:MoveFrame(ATC_UI_LOCK)
	else
		ATC:UpdateSetting()
		ATC:InitIcons()
		ATC:UpdateIcons()
	end
end

function HDH_ATC_OnChangeTabSetting()
	if AT_VARS.GetTabType() == "cooldown" then
		if ATC_UI_LOCK then
			ATC:UpdateSetting()
			ATC:MoveFrame(ATC_UI_LOCK)
		else
			ATC:UpdateSetting()
			ATC:InitIcons()
			ATC:UpdateIcons()
		end
	end
end

function HDH_ATC_Reset()
	if DB_OPTION.cooldown then DB_OPTION.cooldown = nil end
	InitVariables()
	ATC:SetData(DB_AURA.Talent[GetSpecialization() or 1].cooldown)
	ATC:SetOption(DB_OPTION.cooldown)
	ATC:InitIcons()
	if ATC_UI_LOCK then
		ATC:UpdateSetting()
		ATC:MoveFrame(ATC_UI_LOCK)
	else
		ATC:UpdateIcons()
	end
	HDH_ATC_SetUI()
end


hooksecurefunc("HDH_OnClick_LoadProfile", HDH_ATC_Reset) 
hooksecurefunc("HDH_OnSettingReset", HDH_ATC_Reset) 

hooksecurefunc("HDH_OnValueChanged", HDH_ATC_OnValueChanged)
hooksecurefunc("HDH_OnFix", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("HDH_OnRevers", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("OnSeletedItem", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("HDH_OnClickBtnDown", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("HDH_OnClickBtnUp", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("HDH_OnClickBtnAddAndDel", HDH_ATC_OnChangeTabSetting) 
hooksecurefunc("HDH_OnEnterPressed", HDH_ATC_OnChangeTabSetting) 

hooksecurefunc("HDH_OnMoveAble", HDH_ATC_MOVE) 

hooksecurefunc("HDH_Option_OnShow", HDH_ATC_Option_OnShow) 
hooksecurefunc("HDH_ChangeUnitTab", HDH_ATC_ChangeCooldownTab)