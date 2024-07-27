--ATC_OptionFrame = CreateFrame("Frame", "ATC_Option", OptionFrame, "CooldownOptionTemplate")

--ATC_OptionFrame:Show()
---------------------------------------------------
local AT_VARS = {}
local AT_FUNC = {}
local function GetTabType() return CurUnit end
local function SetTabType(t) CurUnit = t end

AT_VARS.UnitOptionFrame = UnitOptionFrame
AT_VARS.UnitOptionFrameTextTitle = UnitOptionFrameTextTitle
AT_VARS.UnitOptionFrameTextTitle2 = UnitOptionFrameTextTitle2
AT_VARS.ListFrame = UnitOptionFrameSFContants
AT_VARS.GetTabType = GetTabType
AT_VARS.SetTabType = SetTabType

AT_FUNC.HDH_LoadListFrame = HDH_LoadListFrame
AT_FUNC.HDH_LoadUnitUI	  = HDH_LoadUnitUI
AT_FUNC.SetActiveUnitTab  = SetActiveUnitTab --option
AT_FUNC.AddUnitTab = HDH_AddUnitTabButton
AT_FUNC.GetRowFrame = HDH_GetRowFrame
--------------------------------------------------------

-------------------------------------------------------

function HDH_ATC_OnAlwaysShow(checked)
	DB_OPTION.cooldown.always_show = checked
	ATC:SetVisible(UnitAffectingCombat("player") or checked)
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

function HDH_ATC_OnSelectedColorAlpha()
	local r,g,b = ColorPickerFrame:GetColorRGB()
	DB_OPTION.cooldown.cooldown_bg_color = {r, g, b, OpacitySliderFrame:GetValue()}
	_G["CooldownSettingFrameButtonColorCooldownBgColor"]:SetTexture(unpack(DB_OPTION.cooldown.cooldown_bg_color))
	ATC:UpdateSetting()
end

function HDH_ATC_OnSelectColorCancel()
	DB_OPTION.cooldown.cooldown_bg_color[1] = ColorPickerFrame.previousValues[1]
	DB_OPTION.cooldown.cooldown_bg_color[2] = ColorPickerFrame.previousValues[2]
	DB_OPTION.cooldown.cooldown_bg_color[3] = ColorPickerFrame.previousValues[3]
	DB_OPTION.cooldown.cooldown_bg_color[4] = ColorPickerFrame.previousValues[4]
	_G["CooldownSettingFrameButtonColorCooldownBgColor"]:SetTexture(unpack(DB_OPTION.cooldown.cooldown_bg_color))
	ATC:UpdateSetting()
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
	CooldownSettingFrameButtonColorColor:SetTexture(unpack(DB_OPTION.cooldown.icon.color))
	_G["CooldownSettingFrameButtonColorCooldownBgColor"]:SetTexture(unpack(DB_OPTION.cooldown.cooldown_bg_color))
end

----------------------------------------------------------
-- callback func
----------------------------------------------------------

function HDH_ATC_OnLoad(self)
	AT_FUNC.AddUnitTab("cooldown")
end


function HDH_ATC_OnClick_RegTrinket(self)
	local key = _G[self:GetName().."EditBoxBuff"]:GetText()
	local duration = tonumber(_G[self:GetName().."EditBoxDuration"]:GetText())
	local cooldown = tonumber(_G[self:GetName().."EditBoxCooldown"]:GetText())
	if not self.data.trinket then
		self.data.trinket = {}
	end
	if key and duration and cooldown then
		self.data.trinket.key = key
		self.data.trinket.duration = duration
		self.data.trinket.cooldown = cooldown
		ATC:InitIcons()
		ATC:UpdateIcons()
		self:Hide()
	end
end

function HDH_ATC_LoadTrinketOptionFrame()
	local data = ATC.DATA[TrinketOptionFrame.no]
	TrinketOptionFrame.data = data
	if data.trinket then
		_G[TrinketOptionFrame:GetName().."EditBoxBuff"]:SetText(data.trinket.key)
		_G[TrinketOptionFrame:GetName().."EditBoxDuration"]:SetText(data.trinket.duration)
		_G[TrinketOptionFrame:GetName().."EditBoxCooldown"]:SetText(data.trinket.cooldown)
	end
	TrinketOptionFrame:Show()
end

function HDH_ATC_OnClickRow(self)
	if TrinketOptionFrame:IsShown() then return end
	
	if _G[self:GetName().."Texture"]:GetTexture() then
		TrinketOptionFrameTexture:SetTexture(_G[self:GetName().."Texture"]:GetTexture())
		TrinketOptionFrameTextName:SetText(_G[self:GetName().."TextName"]:GetText())
		TrinketOptionFrame.id = _G[self:GetName().."EditBoxID"]:GetText()
		TrinketOptionFrame.no = tonumber(_G[self:GetName().."TextNum"]:GetText())
		
		HDH_ATC_LoadTrinketOptionFrame()
	end
end

local BtnTabCooldown
function HDH_ATC_ChangeCooldownTab(self)
	if self.unit == "cooldown" then
		BtnTabCooldown = self
		--AT_VARS.SetTabType("cooldown")
		--AT_VARS.UnitOptionFrameTextTitle:SetText("Cooldown")
		--AT_VARS.UnitOptionFrameTextTitle2:SetText("")
	--	CooldownOptionFrame:Show()
	--	UnitOptionFrame:Hide()
		--CurUnit="cooldown"
		--AT_FUNC.HDH_LoadListFrame(AT_VARS.GetTabType())
		--AT_FUNC.HDH_LoadUnitUI(AT_VARS.GetTabType())
		BtnShowCooldownSetting:Show()
		local i = 1
		local f
		while true do
			f = AT_FUNC.GetRowFrame(AT_VARS.ListFrame, i)
			if f == nil then break end
			f:SetScript("OnClick", HDH_ATC_OnClickRow)
			i = i + 1
		end
	else
		BtnShowCooldownSetting:Hide()
		local i = 1
		local f
		while true do
			f = AT_FUNC.GetRowFrame(AT_VARS.ListFrame, i)
			if f == nil then break end
			f:SetScript("OnClick", nil)
			i = i + 1
		end
	end
end

---------------------------------------------
-- hook
---------------------------------------------

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

function HDH_ATC_OnSelectedColor()
	DB_OPTION.cooldown.icon.color = {ColorPickerFrame:GetColorRGB()}
	CooldownSettingFrameButtonColorColor:SetTexture(unpack(DB_OPTION.cooldown.icon.color))
	if ATC_UI_LOCK then
		ATC:MoveFrame(ATC_UI_LOCK)
	else
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

function HDH_ATC_OnClick_LoadProfile()
	if ATC_UI_LOCK then
		ATC:UpdateSetting()
		ATC:MoveFrame(ATC_UI_LOCK)
	else
		ATC:UpdateIcons()
	end
	HDH_ATC_SetUI()
end

hooksecurefunc("HDH_OnSettingReset", HDH_ATC_Reset) 

hooksecurefunc("HDH_OnClick_LoadProfile", HDH_ATC_OnClick_LoadProfile)
hooksecurefunc("HDH_OnValueChanged", HDH_ATC_OnValueChanged)
hooksecurefunc("HDH_OnGlow", HDH_ATC_OnChangeTabSetting) 
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