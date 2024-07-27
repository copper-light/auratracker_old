local CurSpec = 1
CurUnit = 'player'
local FLAG_ROW_CREATE = 1
local ROW_HEIGHT = 26
local ListFrame

local TAB_TAlENT
local TAB_UNIT

local EDIT_WIDTH_L = 182
local EDIT_WIDTH_S = 65

------------------------------------------
-- Animation
------------------------------------------

local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0

local function CrateAni(f)
	if f.ani then return end
	local ag = f:CreateAnimationGroup()
	f.ani = ag
	
	ani1 = ag:CreateAnimation("Translation")
	ag.a1 = ani1
	ani1:SetOrder(1)
	--ani1:SetDegrees(180)
	--ani1:SetChange(0.5) 
	ani1:SetDuration(0.3)
	ani1:SetSmoothing("OUT")   
	
	ag:SetScript("OnFinished",function()
			if ag.func then
				ag.func(unpack(ag.args))
			end
		end) 
	
	--[[
	ani1 = ag:CreateAnimation("Rotation")
	ani1:SetOrder(2)
	ani1:SetDegrees(-180)
	--ani1:SetChange(0.5) 
	ani1:SetDuration(0.5)
	ani1:SetSmoothing("OUT") 
	
	ani2 = ag:CreateAnimation("Alpha")
	--ani2:SetOrder(2)
	ani2:SetChange(-1) 
	ani2:SetDuration(0.5)
	ani2:SetSmoothing("OUT") 
	]]
end

local function StartAni(f, ani_type)
	if not f.ani then return end
	if ani_type == ANI_MOVE_UP then
		f.ani.a1:SetOffset(0, f:GetHeight())
		f.ani:Play()
	elseif ani_type== ANI_MOVE_DOWN then
		f.ani.a1:SetOffset(0, -f:GetHeight())
		f.ani:Play()
	end
end

------------------------------------------
-- control DB
------------------------------------------

function HDH_DB_SaveSpell(key, spec, no, id, name, fix, unit)
	local db = DB_AURA.Talent[spec][unit]
	for i = 1 , #db do
		if tonumber(db[i].ID) ==  tonumber(id) then
			return false
		end
	end
	
	db[tonumber(no)] = {}
	db[tonumber(no)].Key = tostring(key)
	db[tonumber(no)].No = no
	db[tonumber(no)].ID = id
	db[tonumber(no)].Name = name
	db[tonumber(no)].Fix = fix
	HDH_InitAuraIcon(unit)
	return true
end

function HDH_DB_DelSpell(spec, no, unit)
	local db = DB_AURA.Talent[spec][unit]
	if AuraPointer[unit] and db[no] then 
		if AuraPointer[unit][db[no].Key or tostring(db[no].ID)] then 
			AuraPointer[unit][db[no].Key or tostring(db[no].ID)] = nil
		end
	end
	for i = tonumber(no), #db do
		db[i] = db[i+1]
		if db[i] then db[i].No = i end
	end
	HDH_InitAuraIcon(unit)
end

-------------------------------------------
-- control list
-------------------------------------------
function HDH_AddRow(rowFrame)
	local listFrame = rowFrame:GetParent()
	local no = rowFrame:GetAttribute("no")
	local unit  = CurUnit
	
	local value = _G[rowFrame:GetName().."EditBoxID"]:GetText()
	local fix = _G[rowFrame:GetName().."CheckButtonFix"]:GetChecked()
	
	local name, id, icon = HDH_GetInfo(value)
	if name then
		if not HDH_DB_SaveSpell(value, CurSpec, no, id, name, fix, unit) then
			print("|cffff0000Error - |cffffff00'"..name.."("..id..")' is already registered.")
			return nil
		end
		HDH_SetRowData(rowFrame, value, no, id, name, fix)
	else
		print("|cffff0000Error - |cffffff00'"..value.."' is unknown spell.")
		return nil
	end
	return no
end

function HDH_DelRow(rowFrame)
	local listFrame = rowFrame:GetParent()
	local unit = CurUnit
	local no = rowFrame:GetAttribute("no")
	HDH_DB_DelSpell(CurSpec, no, unit)
	HDH_LoadListFrame(unit, no)
end

function HDH_SetRowData(rowFrame, key, no, id, name, fix)
	_G[rowFrame:GetName().."Texture"]:SetTexture(select(3,HDH_GetInfo(key or id)))
	_G[rowFrame:GetName().."TextNum"]:SetText(no)
	_G[rowFrame:GetName().."TextName"]:SetText(name)
	_G[rowFrame:GetName().."CheckButtonFix"]:SetChecked(fix)
	_G[rowFrame:GetName().."EditBoxID"]:SetText(id or "")
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Del")
	
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
end

function HDH_ClearRowData(rowFrame)
	_G[rowFrame:GetName().."Texture"]:SetTexture(nil)
	_G[rowFrame:GetName().."TextNum"]:SetText(nil)
	_G[rowFrame:GetName().."TextName"]:SetText(name)
	_G[rowFrame:GetName().."CheckButtonFix"]:SetChecked(true)
	_G[rowFrame:GetName().."EditBoxID"]:SetText("")
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Add")
	
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
end

function HDH_GetRowFrame(listFrame, index, flag)
	if not listFrame.row then 
		listFrame.row = {} 
	end
	index = tonumber(index)
	if not listFrame.row[index] and flag == FLAG_ROW_CREATE then
		listFrame.row[index] = CreateFrame("Button",(listFrame:GetName().."Row"..index), listFrame, "RowTemplate")
		
		local f = listFrame.row[index]
		if index == 1 then f:SetPoint("TOPLEFT",listFrame,"TOPLEFT")
					  else f:SetPoint("TOPLEFT",listFrame.row[index-1],"BOTTOMLEFT") end
		f:SetSize(listFrame:GetParent():GetWidth(), ROW_HEIGHT)
		f:SetAttribute("no", index)
		--[[if index%2 == 1 then
			_G[f:GetName().."BG"]:SetTexture(1,1,1)
			_G[f:GetName().."BG"]:SetAlpha(0.1)
		end]]
		f:Hide() -- 기본이 hide 중요!
	end
	
	return listFrame.row[index] 
end

function HDH_LoadListFrame(unit, startRowIdx, endRowIdx)
	local listFrame = ListFrame
	local aura = {}
	if not DB_AURA.Talent[CurSpec] then return end
	aura = DB_AURA.Talent[CurSpec][unit]
	
	local rowFrame
	local i = startRowIdx or 1
	if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
	while true do
		rowFrame = HDH_GetRowFrame(listFrame, i, FLAG_ROW_CREATE)-- row가 없으면 생성하고, 있으면 그거 재활용
		if not rowFrame:IsShown() then rowFrame:Show() end
		if aura and aura[i] then
			HDH_SetRowData(rowFrame, aura[i].Key, aura[i].No, aura[i].ID, aura[i].Name, aura[i].Fix)
		else-- add 를 위한 공백 row 지정
			HDH_ClearRowData(rowFrame)
			listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
			break
		end
		if endRowIdx and endRowIdx == i then return end
		i = i + 1
	end
	
	-- 불필요한 row 안보이게 
	i = i + 1
	while true do
		rowFrame = HDH_GetRowFrame(listFrame,i, nil) -- 불필요한 row가 있다면
		if rowFrame then HDH_ClearRowData(rowFrame) 
						 rowFrame:Hide() 
					else break end
		i = i + 1
	end
end


------------------------------------------
-- profile
------------------------------------------

function deepcopy(orig)
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

function HDH_OnClick_SaveProfile()
	DB_PROFILE = {}
	DB_PROFILE.OPTION = deepcopy(DB_OPTION)
	DB_PROFILE.ID_NAME = UnitName('player').." ("..date("%m/%d %H:%M")..")"
	_G["ProfileFrameTextCur"]:SetText(DB_PROFILE.ID_NAME)
end

function HDH_OnClick_LoadProfile()
	if DB_PROFILE and DB_PROFILE.OPTION then
		DB_OPTION = deepcopy(DB_PROFILE.OPTION)
		HDH_InitVaribles()
		HDH_UpdateSetting()
		HDH_MoveFrame(false)
		HDH_RefrashSettingUI()
		HDH_UpdateIconAlpha()
	else
		print("|cffff0000Error - |cffffff00'Not found the Profile")
	end
end

function HDH_OnClick_ResetProfile()
	DB_PROFILE = {}
	_G["ProfileFrameTextCur"]:SetText("(none)")
end

------------------------------------------
-- control Tab
------------------------------------------

function HDH_LoadTabSpec()
	local spec = GetSpecialization()
	if spec then
		CurSpec = spec
	end
	if not TAB_TAlENT then
		TAB_TAlENT = {BtnTalent1, BtnTalent2, BtnTalent3, BtnTalent4}
		local id, name, desc, icon
		for i = 1 , 4 do
			id, name, desc, icon = GetSpecializationInfo(i)
			if not id then 
				TAB_TAlENT[i]:Hide() 
				break 
			end
			TAB_TAlENT[i]:SetNormalTexture(icon)
		end
	end
	HDH_ChangeTalentTab(TAB_TAlENT[CurSpec], CurSpec)
end

function HDH_ChangeTalentTab(self, spec)
	local id, name, desc, icon = GetSpecializationInfo(spec)
	if not id then return end
	CurSpec = spec
	for i=1,#DB_AURA.Talent do
		local btn = TAB_TAlENT[i]
		if i ~= id then
			btn:SetChecked(false) 
			btn:GetNormalTexture():SetDesaturated(1)
		end
	end
	self:GetNormalTexture():SetDesaturated(nil)
	_G["TalentIcon"]:SetTexture(icon)
	--_G["TalentIcon"]:SetRotation(math.pi/180*180)
	_G["TalentText"]:SetText(name)
	
	self:SetChecked(true)
	HDH_LoadUnitUI(CurUnit)
	HDH_LoadListFrame(CurUnit)
end

function SetActiveUnitTab(self, bool)
	local name = self:GetName()
	if bool then
		self:Disable()
		self:SetNormalTexture([[Interface\BUTTONS\UI-DialogBox-Button-Disabled]])
		_G[name.."Text"]:SetPoint("CENTER",0,-3)
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		_G[name.."LeftDisabled"]:Show()
		_G[name.."MiddleDisabled"]:Show()
		_G[name.."RightDisabled"]:Show()
	else
		self:Enable()
		self:SetNormalTexture([[Interface\BUTTONS\UI-DialogBox-Button-Disabled]])
		t= self:GetNormalTexture():SetTexCoord(1,1,1,1)
		--t:SetTexCoord(1,1,1,1)
		--self:SetNormalTexture(t)
		_G[name.."Text"]:SetPoint("CENTER",0,3)
		_G[name.."Left"]:Show()
		_G[name.."Middle"]:Show()
		_G[name.."Right"]:Show()
		_G[name.."LeftDisabled"]:Hide()
		_G[name.."MiddleDisabled"]:Hide()
		_G[name.."RightDisabled"]:Hide()
	end
end

function HDH_CreateUnitTabButtons()
	for i = 1, #UNIT_LIST do
		HDH_AddUnitTabButton(UNIT_LIST[i])
	end
end

function HDH_AddUnitTabButton(unit)
	--create tab button : UnitOptionFrame 
	local parent = UnitOptionFrame
	
	if not parent.tablist then
		parent.tablist = {}
	end
	
	local btn = CreateFrame("Button", "BtnTab"..unit, parent, "CharacterFrameTabButtonTemplate")
	_G[btn:GetName().."Text"]:SetText(unit:upper())
	if #parent.tablist == 0 then btn:SetPoint("TOPLEFT", btn:GetParent(), "LEFTBOTTOM", 0, 4)
									 else btn:SetPoint("LEFT", parent.tablist[#parent.tablist], "RIGHT", -15, 0) end
	btn:SetScript("OnClick", HDH_ChangeUnitTab)
	btn.unit = unit
	if unit ~= 'player' and unit ~= 'pet' then
		btn.desc = "(Debuff)"
	end
	
	SetActiveUnitTab(btn, false)
	parent.tablist[#parent.tablist+1] =  btn
end

function HDH_LoadTabUnit()
	for i = 1, #UNIT_LIST do
		if UNIT_LIST[i] == CurUnit then
			HDH_ChangeUnitTab(parent.tablist[i])
			break
		end
	end
end

function HDH_ChangeUnitTab(self)
	CurUnit = self.unit
	if CurUnit == 'player' then _G["UnitOptionFrameCheckButtonPlayerDebuff"]:Show()
						   else _G["UnitOptionFrameCheckButtonPlayerDebuff"]:Hide() end
	
	for i=1, #UNIT_LIST do
		if UNIT_LIST[i] == CurUnit then
			SetActiveUnitTab(self, true)
			HDH_LoadListFrame(CurUnit)
			HDH_LoadUnitUI(CurUnit)
			UnitOptionFrameTextTitle:SetText(CurUnit:upper())
			UnitOptionFrameTextTitle2:SetText(self.desc or nil)
			local w = UnitOptionFrameTextTitle:GetStringWidth()
			UnitOptionFrameTextTitle2:SetPoint("LEFT",UnitOptionFrameTextTitle, "LEFT", w+5, 0)
		else
			SetActiveUnitTab(TAB_UNIT[i], false)
		end
	end
end

function HDH_OnLoadUnitTab(self)
	SetActiveUnitTab(self, false)
end

------------------------------------------
-- control DropDownMenu
------------------------------------------
function OnSeletedItem(self)
	self:GetID()
	UIDropDownMenu_SetSelectedID(UnitOptionFrameDDMCooldown, self:GetID())
	DB_OPTION[CurUnit].cooldown = self:GetID()
	if UI_LOCK then
		HDH_MoveFrame(UI_LOCK)
	else
		HDH_InitAuraIcon(CurUnit)
	end
end

local function GetCooldownDBToNumber()
	return DB_OPTION[CurUnit].cooldown
end

	--UnitOptionFrameDDMCooldown
local function InitializeDropDownCooldown(self, level)
	local items= {"위로", "아래로", "왼쪽으로", "오른쪽으로", "원형"}
	local info = UIDropDownMenu_CreateInfo()
	
	for k,v in pairs(items) do
		info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.value = v
		info.func = OnSeletedItem
		UIDropDownMenu_AddButton(info, level)
	end
	if self:GetID() == 0 then
		UIDropDownMenu_SetSelectedID(UnitOptionFrameDDMCooldown, GetCooldownDBToNumber())
	end
end

local function HDH_LoadDropDownCooldown()
	UIDropDownMenu_Initialize(UnitOptionFrameDDMCooldown, InitializeDropDownCooldown)
	UIDropDownMenu_SetWidth(UnitOptionFrameDDMCooldown, 100)
	UIDropDownMenu_SetButtonWidth(UnitOptionFrameDDMCooldown, 124)
	UIDropDownMenu_JustifyText(UnitOptionFrameDDMCooldown, "LEFT")
	UIDropDownMenu_SetSelectedID(UnitOptionFrameDDMCooldown, 1)
end

------------------------------------------
-- control UI 
------------------------------------------

function HDH_RefrashSettingUI()
	_G["OptionFrameCheckButtonMove"]:SetChecked(UI_LOCK)
	_G["OptionFrameCheckButtonIDShow"]:SetChecked(DB_OPTION.tooltip_id_show)
	_G["SettingFrameCheckButtonAlwaysShow"]:SetChecked(DB_OPTION.always_show)
	_G["SettingFrameSliderFont"]:SetValue(DB_OPTION.font.fontsize)
	_G["SettingFrameSliderIcon"]:SetValue(DB_OPTION.icon.size)
	_G["SettingFrameSliderOnAlpha"]:SetValue(DB_OPTION.icon.on_alpha*100)
	_G["SettingFrameSliderOffAlpha"]:SetValue(DB_OPTION.icon.off_alpha*100)
	_G["SettingFrameCheckButtonShowCooldown"]:SetChecked(DB_OPTION.icon.show_cooldown)
	_G["SettingFrameButtonColorBuffColor"]:SetTexture(unpack(DB_OPTION.icon.buff_color))
	_G["SettingFrameButtonColorDebuffColor"]:SetTexture(unpack(DB_OPTION.icon.debuff_color))
	_G["UnitOptionFrameCheckButtonPlayerDebuff"]:SetChecked(DB_OPTION["player"].check_debuff)
	--_G["UnitOptionFrameDDMCooldown"]:
	HDH_LoadUnitUI(CurUnit)
end

function HDH_LoadUnitUI(unit)
	if not unit then return end
	if not DB_OPTION[unit] then return end
	_G["UnitOptionFrameCheckButtonReversH"]:SetChecked(DB_OPTION[unit].revers_h)
	_G["UnitOptionFrameCheckButtonReversV"]:SetChecked(DB_OPTION[unit].revers_v)
	_G["UnitOptionFrameSliderLine"]:SetValue(DB_OPTION[unit].line)
	UIDropDownMenu_SetSelectedID(UnitOptionFrameDDMCooldown, GetCooldownDBToNumber())
end

------------------------------------------
-- Call back function
------------------------------------------

function HDH_OnRevers(t, unit, check)
	if t == 'h' then
		DB_OPTION[CurUnit].revers_h = check
	else
		DB_OPTION[CurUnit].revers_v = check
	end
	if UI_LOCK then
		HDH_MoveFrame(UI_LOCK)
	else
		HDH_UNIT_AURA(CurUnit)
	end
end

function HDH_OnFix(unit, no, check)
	local db = DB_AURA.Talent[CurSpec][CurUnit]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Fix = check
	HDH_InitAuraIcon(CurUnit)
end

function HDH_OnValueChanged(self, value, userInput)
	value = math.floor(value)
	if self == _G[self:GetParent():GetName().."SliderFont"] then
		DB_OPTION.font.fontsize = math.floor(value)
		HDH_UpdateSetting()
	elseif self == _G[self:GetParent():GetName().."SliderIcon"] then
		DB_OPTION.icon.size = math.floor(value)
		HDH_UpdateSetting()
		if UI_LOCK then
			HDH_MoveFrame(UI_LOCK)
		else
			for i = 1, #UNIT_LIST do
				HDH_InitAuraIcon(UNIT_LIST[i])
			end
		end
	elseif self == _G[self:GetParent():GetName().."SliderOnAlpha"] then
		DB_OPTION.icon.on_alpha = value/100
		HDH_UpdateIconAlpha()
	elseif self == _G[self:GetParent():GetName().."SliderOffAlpha"] then
		DB_OPTION.icon.off_alpha = value/100
		HDH_UpdateIconAlpha()
	elseif self == _G["UnitOptionFrameSliderLine"] then
		DB_OPTION[CurUnit].line = value
		if UI_LOCK then
			HDH_MoveFrame(UI_LOCK)
		else
			HDH_UNIT_AURA(CurUnit)
		end
	end
end

function HDH_OnSettingReset(panel_type)
	if panel_type =="UI" then
		DB_OPTION = nil
		HDH_InitVaribles()
		HDH_UpdateSetting()
		HDH_MoveFrame(false)
		HDH_RefrashSettingUI()
		HDH_UpdateIconAlpha()
	else
		DB_AURA = nil
		HDH_InitVaribles()
		for i = 1, #UNIT_LIST do
			HDH_InitAuraIcon(UNIT_LIST[i])
		end
		HDH_LoadListFrame(CurUnit)
	end
	
end

function HDH_OnCheckTooltipShow(checked)
	DB_OPTION.tooltip_id_show = checked
	HDH_UpdateSetting()
end

function HDH_OnAlwaysShow(bool)
	DB_OPTION.always_show = bool
	for i = 1, #UNIT_LIST do
		HDH_UNIT_AURA(UNIT_LIST[i])
	end
	--HDH_AlwaysShow(bool)
end

function HDH_OnMoveAble(bool)
	HDH_MoveFrame(bool)
end

local tmp_id
function HDH_OnEditFocusGained(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	if btn:GetText() == "Del" then
		btn:SetText("Modify")
		tmp_id = self:GetText()
	end
	self:SetWidth(EDIT_WIDTH_L)
end

function HDH_OnEditFocusLost(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	if btn:GetText() == "Modify" then
		btn:SetText("Del")
		tmp_id = nil
	end
	self:SetWidth(EDIT_WIDTH_S)
end

function HDH_OnEditEscape(self)
	self:SetText(tmp_id or "")
	self:ClearFocus()
end

function HDH_OnEnterPressed(self)
	--local input = string.gsub(self:GetText(), "%s+", "")
	--[[if string.len(input) ~= string.len(self:GetText()) then
		self:SetText(input)
	end]]
	if string.len(self:GetText()) > 0 then
		local ret = HDH_AddRow(self:GetParent()) -- 성공 하면 no 리턴
		if ret then 
			-- add 에 성공 했을 경우 다음 add 를 위해 가장 아래 공백 row 를 생성해야한다
			local listFrame = self:GetParent():GetParent()
			if ret == #(DB_AURA.Talent[CurSpec][CurUnit]) then
				local rowFrame = HDH_GetRowFrame(listFrame, ret+1, FLAG_ROW_CREATE)
				HDH_ClearRowData(rowFrame)
				rowFrame:Show() 
			end
		else
			self:SetText("") 
		end
	else
		print("|cffff0000Error - |cffffff00Please Input Spell ID.")
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
	local aura = DB_AURA.Talent[CurSpec][CurUnit]
	row = tonumber(row)
	if aura[row] and aura[row-1] then
		local tmp_no = aura[row].No
		aura[row].No = aura[row-1].No
		aura[row-1].No = tmp_no
		local tmp = aura[row]
		aura[row] = aura[row-1]
		aura[row-1] = tmp
		--HDH_LoadListFrame(CurUnit, row-1, row)
		
		local f1 = HDH_GetRowFrame(ListFrame, row)
		local f2 = HDH_GetRowFrame(ListFrame, row-1)
		CrateAni(f1)
		CrateAni(f2)
		f2.ani.func = HDH_LoadListFrame
		f2.ani.args = {CurUnit, row-1, row}
		StartAni(f1, ANI_MOVE_UP)
		StartAni(f2 , ANI_MOVE_DOWN)
	end
	HDH_InitAuraIcon(CurUnit)
end

function HDH_OnClickBtnDown(self, row)
	row = tonumber(row)
	local aura = DB_AURA.Talent[CurSpec][CurUnit]
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
		f2.ani.func = HDH_LoadListFrame
		f2.ani.args = {CurUnit, row, row+1}
		StartAni(f1, ANI_MOVE_DOWN)
		StartAni(f2 , ANI_MOVE_UP)
		--HDH_LoadListFrame(CurUnit, row, row+1)
	end
	HDH_InitAuraIcon(CurUnit)
end

function HDH_OnSelectedColor()
	local t = ColorPickerFrame.arg
	ColorPickerFrame.arg = nil
	if t == 'buff' then
		DB_OPTION.icon.buff_color = {ColorPickerFrame:GetColorRGB()}
		_G["SettingFrameButtonColorBuffColor"]:SetTexture(unpack(DB_OPTION.icon.buff_color))
	elseif t== 'debuff' then
		DB_OPTION.icon.debuff_color = {ColorPickerFrame:GetColorRGB()}
		_G["SettingFrameButtonColorDebuffColor"]:SetTexture(unpack(DB_OPTION.icon.debuff_color))
	end
	if UI_LOCK then
		HDH_MoveFrame(UI_LOCK)
	else
		for i = 1, #UNIT_LIST do
			HDH_UNIT_AURA(UNIT_LIST[i])
		end
	end
end

function HDH_OnCheckShowCooldown(checked)
	DB_OPTION.icon.show_cooldown = checked
	HDH_UpdateSetting()
end

function HDH_OnCheckedPlayerDebuff(checked)
	DB_OPTION["player"].check_debuff = checked
	HDH_UNIT_AURA("player")
end	

function HDH_Option_OnShow(self)
	if not GetSpecialization() then
		print("|cffff0000Error - |cffffff00Please Active a Specialization")
		self:Hide()
		return
	end
	
	if not DB_AURA or #DB_AURA.Talent == 0 then
		HDH_InitVaribles()
	end
	
	HDH_LoadDropDownCooldown()
	HDH_LoadTabSpec()
	HDH_LoadTabUnit()
	HDH_RefrashSettingUI()
end

function HDH_Option_OnLoad(self)
	ListFrame = _G[UnitOptionFrame:GetName().."SFContants"]
	self:SetPoint("CENTER")
	HDH_CreateUnitTabButtons()
end

-----------------------------------------
---------------------
SLASH_AURATRACKINGT1 = '/at'
SLASH_AURATRACKINGT2 = '/auratracking'
SLASH_AURATRACKINGT3 = '/ㅁㅅ'
SlashCmdList["AURATRACKINGT"] = function (msg, editbox)
	OptionFrame:Show()
end


