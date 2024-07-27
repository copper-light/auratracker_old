--ATC_OptionFrame = CreateFrame("Frame", "ATC_Option", OptionFrame, "CooldownOptionTemplate")

--ATC_OptionFrame:Show()
---------------------------------------------------
local AT_VARS = {}
local AT_FUNC = {}
local function GetTabType() return CurTab end
local function SetTabType(t) CurTab = t end

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
AT_FUNC.GetTabUnitInfo = GetTabUnitInfo
--------------------------------------------------------

-------------------------------------------------------

function HDH_CT_ShowColorPicker()
	if ColorPickerFrame:IsShown() then return end
	local option
	if CURMODE == MODE_SET_EACH then
		if not AT_FUNC.GetTabUnitInfo(CurTab)then return end
		option = DB_OPTION[AT_FUNC.GetTabUnitInfo(CurTab)]
	else
		option = DB_OPTION
	end
	
	ColorPickerFrame.func = function() end
	ColorPickerFrame.opacityFunc = HDH_CT_OnSelectedColor
	ColorPickerFrame.cancelFunc = function() end
	ColorPickerFrame:SetColorRGB(unpack(option.icon.cooldown_color))
	ColorPickerFrame.hasOpacity = false
	ColorPickerFrame:Show();
end

function HDH_CT_OnSelectedColor()
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[AT_FUNC.GetTabUnitInfo(CurTab)]
		option.icon.cooldown_color = {ColorPickerFrame:GetColorRGB()}
		local t= HDH_TRACKER.Get(AT_FUNC.GetTabUnitInfo(CurTab))
		if t then 
			if UI_LOCK then
				t:SetMove(UI_LOCK)
			else
				t:Update()
			end
		end
	else
		option = DB_OPTION
		option.icon.cooldown_color = {ColorPickerFrame:GetColorRGB()}
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				if tracker.unit == 'cooldown' then
					tracker:Update()
				end
			end
		end
	end
	
	_G["CooldownSettingFrameButtonColorColor"]:SetTexture(unpack(option.icon.cooldown_color))
end

function HDH_CT_OnCheckDesaturation(checked)
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[AT_FUNC.GetTabUnitInfo(CurTab)]
		option.icon.desaturation = checked
		
		local t= HDH_TRACKER.Get(AT_FUNC.GetTabUnitInfo(CurTab))
		if t then 
			if UI_LOCK then
				t:SetMove(UI_LOCK)
			else
				t:Update()
			end
		end
	else
		option = DB_OPTION
		option.icon.desaturation = checked
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				if tracker.unit == 'cooldown' then
					tracker:Update()
				end
			end
		end
	end
	
	
end

function HDH_CT_OnValueChanged(self, value)
	value = math.floor(value)
	
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[AT_FUNC.GetTabUnitInfo(CurTab)]
		option.icon.max_time = value
		
		local t= HDH_TRACKER.Get(AT_FUNC.GetTabUnitInfo(CurTab))
		if t then 
			if UI_LOCK then
				t:SetMove(UI_LOCK)
			else
				t:Update()
			end
		end
	else
		option = DB_OPTION
		option.icon.max_time = value
		if UI_LOCK then
			HDH_TRACKER.SetMoveAll(UI_LOCK)
		else
			for k,tracker in pairs(HDH_TRACKER.GetList()) do
				if tracker.unit == 'cooldown' then
					tracker:Update()
				end
			end
		end
	end
	
end

---------------------------------------------
-- hook
---------------------------------------------
function hook_HDH_SetModeUI(mode)
	local option
	local colorf = _G["CooldownSettingFrameButtonColor"]
	local desatf = _G["CooldownSettingFrameCheckButtonDesaturation"]
	local maxtimef = _G["CooldownSettingFrameSliderMaxTime"]
	local parent_level = _G["SettingFrameButtonColorBuff"]:GetParent():GetFrameLevel()
	if mode == MODE_EDIT then
	elseif mode == MODE_SET_EACH then
		local name, unit = AT_FUNC.GetTabUnitInfo(CurTab)
		if unit ~= "cooldown" then
			CooldownSettingFrame:Hide()
			_G["SettingFrameButtonColorBuff"]:SetFrameLevel(parent_level+1)
			_G["SettingFrameButtonColorDebuff"]:SetFrameLevel(parent_level+1)
		else
			CooldownSettingFrame:Show()
			option = DB_OPTION[AT_FUNC.GetTabUnitInfo(CurTab)]
			_G[colorf:GetName().."Color"]:SetTexture(unpack(option.icon.cooldown_color))
			desatf:SetChecked(option.icon.desaturation)
			HDH_Adjust_Slider(maxtimef, option.icon.max_time, 0, 3000)
			_G["SettingFrameButtonColorBuff"]:SetFrameLevel(0)
			_G["SettingFrameButtonColorDebuff"]:SetFrameLevel(0)
		end
	elseif mode == MODE_SET_ALL then
		option = DB_OPTION
		CooldownSettingFrame:Show()
		if not option.icon.cooldown_color then
			option.icon.cooldown_color = {0,0,0}
			option.icon.desaturation = true
			option.icon.max_time = 0
		end
		_G[colorf:GetName().."Color"]:SetTexture(unpack(option.icon.cooldown_color))
		desatf:SetChecked(option.icon.desaturation)
		HDH_Adjust_Slider(maxtimef, option.icon.max_time, 0, 3000)
		_G["SettingFrameButtonColorBuff"]:SetFrameLevel(parent_level+1)
		_G["SettingFrameButtonColorDebuff"]:SetFrameLevel(parent_level+1)
	else -- mode == MODE_LIST
	
	end
end

function HDH_CT_OnShow_SettingFrame(self)
end

if SettingFrame:GetScript("OnShow") then
	hooksecurefunc(SettingFrame,"OnShow", HDH_CT_OnShow_SettingFrame)
else
	SettingFrame:SetScript("OnShow", HDH_CT_OnShow_SettingFrame)
end

hooksecurefunc("HDH_SetModeUI", hook_HDH_SetModeUI) 
--hooksecurefunc("HDH_ChangeUnitTab", HDH_ATC_ChangeCooldownTab)





---------------------------------------------------------
-- trinket func
---------------------------------------------------------
function HDH_ATC_OnClick_RegTrinket(self)--[[
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
	end]]
end

function HDH_ATC_LoadTrinketOptionFrame()--[[
	local data = ATC.DATA[TrinketOptionFrame.no]
	TrinketOptionFrame.data = data
	if data.trinket then
		_G[TrinketOptionFrame:GetName().."EditBoxBuff"]:SetText(data.trinket.key)
		_G[TrinketOptionFrame:GetName().."EditBoxDuration"]:SetText(data.trinket.duration)
		_G[TrinketOptionFrame:GetName().."EditBoxCooldown"]:SetText(data.trinket.cooldown)
	end
	TrinketOptionFrame:Show()]]
end

function HDH_ATC_OnClickRow(self)--[[
	if TrinketOptionFrame:IsShown() then return end
	
	if _G[self:GetName().."Texture"]:GetTexture() then
		TrinketOptionFrameTexture:SetTexture(_G[self:GetName().."Texture"]:GetTexture())
		TrinketOptionFrameTextName:SetText(_G[self:GetName().."TextName"]:GetText())
		TrinketOptionFrame.id = _G[self:GetName().."EditBoxID"]:GetText()
		TrinketOptionFrame.no = tonumber(_G[self:GetName().."TextNum"]:GetText())
		
		HDH_ATC_LoadTrinketOptionFrame()
	end]]
end
