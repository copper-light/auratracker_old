local CurSpec =1

-------------------------------------------
-- user function
-------------------------------------------

function HDH_AddRow(rowFrame)
	local no = rowFrame:GetAttribute("no")
	local button_ad = _G[rowFrame:GetName().."ButtonAddAndDel"]
	local editBox_id = _G[rowFrame:GetName().."EditBoxID"]
	local checkButton_fix = _G[rowFrame:GetName().."CheckButtonFix"]
	if not editBox_id:GetText() then return end
	
	local name,_,icon = GetCacheSpellInfo(editBox_id:GetText())
	if name then
		local ifBuff = false
		if rowFrame:GetParent():GetAttribute("type") == "Buff" then
			ifBuff = true
		end
		
		if not HDH_SaveSpell(CurSpec, no, editBox_id:GetText(), name, checkButton_fix:GetChecked(), ifBuff) then
			print("|cffff0000Error - |cffffff00'"..name.."("..editBox_id:GetText()..")' is already registered.")
			editBox_id:SetText("")
			return
		end
		_G[rowFrame:GetName().."Texture"]:SetTexture(icon)
		_G[rowFrame:GetName().."TextName"]:SetText(name)
		button_ad:SetText("Del")
		editBox_id:ClearFocus()
	else
		print("|cffff0000Error - |cffffff00'"..editBox_id:GetText().."' is unknown spell id.")
		return
	end
	
	local nextRow = _G[rowFrame:GetParent():GetName().."Row"..no+1]
	if nextRow then
		nextRow:Show()
	end
end

local function HDH_SetRowData(self, no, id, name, fix)
	_G[self:GetName().."Texture"]:SetTexture(select(3,GetCacheSpellInfo(id)))
	_G[self:GetName().."TextNum"]:SetText(no)
	_G[self:GetName().."TextName"]:SetText(name)
	_G[self:GetName().."EditBoxID"]:SetText(id or "")
	_G[self:GetName().."CheckButtonFix"]:SetChecked(fix)
end

function HDH_RefrashSettingUI()
	_G["SettingFrameCheckButtonAlwaysShow"]:SetChecked(DB_OPTION.always_show)
	_G["SettingFrameCheckButtonMove"]:SetChecked(UI_LOCK)
	_G["SettingFrameSliderFont"]:SetValue(DB_OPTION.font.fontsize)
	_G["SettingFrameSliderIcon"]:SetValue(DB_OPTION.icon.size)
	_G["SettingFrameSliderOnAlpha"]:SetValue(DB_OPTION.icon.on_alpha)
	_G["SettingFrameSliderOffAlpha"]:SetValue(DB_OPTION.icon.off_alpha)
	_G["SettingFrameCheckButtonIDShow"]:SetChecked(DB_OPTION.tooltip_id_show)
	_G["BuffListFrameCheckButtonRevers"]:SetChecked(DB_OPTION.buff.revers)
	_G["DebuffListFrameCheckButtonRevers"]:SetChecked(DB_OPTION.debuff.revers)
end

function HDH_RefrashList()
	local rowFrame
	local button_ad
	local editBox
	local cbFix
	local buff = {}
	local debuff ={}
	if DB_SPELL.Talent[CurSpec] then
		buff  = DB_SPELL.Talent[CurSpec].Buff
		debuff = DB_SPELL.Talent[CurSpec].Debuff
	end
	
	local row = {'BuffListFrameRow', 'DebuffListFrameRow'}
	local aura = {buff, debuff}
	for i=1 ,#row do
		local j= 1
		while true do
			rowFrame = _G[row[i]..j]
			if rowFrame then
				button_ad = _G[rowFrame:GetName().."ButtonAddAndDel"]
				editBox = _G[rowFrame:GetName().."EditBoxID"]
				cbFix = _G[rowFrame:GetName().."CheckButtonFix"]
				if aura[i][j] then
					HDH_SetRowData(rowFrame, j, aura[i][j].ID, aura[i][j].Name, aura[i][j].Fix)
					rowFrame:Show()
					button_ad:SetText("Del")
				else
					HDH_SetRowData(rowFrame, j, nil, nil, false)
					button_ad:SetText("Add")
					if aura[i] and #aura[i]+1 == j then 
						rowFrame:Show() 
					else
						rowFrame:Hide() 
					end
				end
			else
				break
			end
			j = j+1
		end
	end
	
end

function HDH_SaveSpell(spec, no, id, name, fix, isBuff)
	local db 
	if isBuff then
		db = DB_SPELL.Talent[spec].Buff
		if AuraPointer["player"][tonumber(id)] then return false end
	else
		db = DB_SPELL.Talent[spec].Debuff
		if AuraPointer["target"][tonumber(id)] then return false end
	end
	
	db[tonumber(no)] = {}
	db[tonumber(no)].No = no
	db[tonumber(no)].ID = id
	db[tonumber(no)].Name = name
	db[tonumber(no)].Fix = fix
	HDH_InitAuraIcon()
	return true
end

function HDH_DelSpell(spec, no, isBuff)
	local db 
	if isBuff then
		db = DB_SPELL.Talent[spec].Buff
	else
		db = DB_SPELL.Talent[spec].Debuff
	end
	local i
	for i=tonumber(no), #db do
		db[i] = db[i+1]
	end
	HDH_InitAuraIcon()
end

------------------------------------------
-- Call back funtion
------------------------------------------

function HDH_ChangeTalentFrame(self, id)
	CurSpec = id
	for i=1,#DB_SPELL.Talent do
		local btn = _G['TalentListFrameTalentButton'..i]
		if i == id then
			btn:Enable() 
		else
			btn:Disable() 
		end
	end
	HDH_RefrashList()
end

function HDH_OnRevers(list_type, check)
	if list_type == "Buff" then
		DB_OPTION.buff.revers = check
	else
		DB_OPTION.debuff.revers = check
	end
	if UI_LOCK then
		HDH_MoveFrame(UI_LOCK)
	else
		HDH_InitAuraIcon()
	end
end

function HDH_OnFix(list_type, no, check)
	local db 
	if list_type == "Buff" then
		db = DB_SPELL.Talent[CurSpec].Buff
	else
		db = DB_SPELL.Talent[CurSpec].Debuff
	end
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Fix = check
	HDH_InitAuraIcon()
end

function HDH_OnValueChanged(self, value, userInput)
	if self == _G[self:GetParent():GetName().."SliderFont"] then
		DB_OPTION.font.fontsize = value
		HDH_UpdateSetting()
	elseif self == _G[self:GetParent():GetName().."SliderIcon"] then
		DB_OPTION.icon.size = value
		HDH_UpdateSetting()
	elseif self == _G[self:GetParent():GetName().."SliderOnAlpha"] then
		DB_OPTION.icon.on_alpha = value
		HDH_UpdateIconAlpha()
	elseif self == _G[self:GetParent():GetName().."SliderOffAlpha"] then
		DB_OPTION.icon.off_alpha = value
		HDH_UpdateIconAlpha()
	end
end

function HDH_OnSettingReset(target)
	if target =="UI" then
		DB_OPTION = nil
		HDH_InitVaribles()
		HDH_UpdateSetting()
		HDH_MoveFrame(false)
		HDH_RefrashSettingUI()
		HDH_UpdateIconAlpha()
	else
		DB_SPELL = nil
		HDH_InitVaribles()
		HDH_InitAuraIcon()
		HDH_RefrashList()
	end
	
end

function HDH_OnCheckTooltipShow(checked)
	DB_OPTION.tooltip_id_show = checked
end

function HDH_OnAlwaysShow(bool)
	DB_OPTION.always_show = bool
	HDH_UNIT_AURA('player')
	HDH_UNIT_AURA('target')
	--HDH_AlwaysShow(bool)
end

function HDH_OnMoveAble(bool)
	HDH_MoveFrame(bool)
end

function HDH_OnEnterPressed(self)
	HDH_AddRow(self:GetParent())
end

function HDH_OnClickBtnAddAndDel(self, row)
	if self:GetText() == "Add" or self:GetText() == "Modify" then
		HDH_AddRow(self:GetParent())
	else
		local ifBuff = false
		if self:GetParent():GetParent():GetAttribute("type") == "Buff" then
			ifBuff = true
		end
		-- del 작업 수행
		HDH_DelSpell(CurSpec, row, ifBuff)
		HDH_RefrashList()
	end
end

function HDH_OnClickBtnUp(self, row)
	local aura
	if self:GetParent():GetParent():GetAttribute("type") == "Buff" then
		aura = DB_SPELL.Talent[CurSpec].Buff
	else
		aura = DB_SPELL.Talent[CurSpec].Debuff
	end
	
	if aura[tonumber(row)] and aura[tonumber(row)-1] then
		local tmp =  {} 
		tmp = aura[tonumber(row)]
		aura[tonumber(row)]= aura[tonumber(row)-1]
		aura[tonumber(row)-1] = tmp
		HDH_RefrashList()
	end
	HDH_InitAuraIcon()
end

function HDH_OnClickBtnDown(self, row)
	local aura
	if self:GetParent():GetParent():GetAttribute("type") == "Buff" then
		aura = DB_SPELL.Talent[CurSpec].Buff
	else
		aura = DB_SPELL.Talent[CurSpec].Debuff
	end
	if aura[tonumber(row)] and aura[tonumber(row)+1] then
		local tmp = {}
		tmp = aura[tonumber(row)]
		aura[tonumber(row)]= aura[tonumber(row)+1]
		aura[tonumber(row)+1] = tmp
		HDH_RefrashList()
	end
	HDH_InitAuraIcon()
end

function HDH_OnEditFocusGained(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	if btn:GetText() == "Del" then
		btn:SetText("Modify")
	end
end

function HDH_OnEditFocusLost(self)
	local btn = _G[self:GetParent():GetName().."ButtonAddAndDel"]
	if btn:GetText() == "Modify" then
		btn:SetText("Del")
	end
	HDH_RefrashList()
end

function HDH_Option_OnShow(self)
	CurSpec = GetSpecialization()
	if not GetSpecialization() then
		print("|cffff0000Error - |cffffff00Please Active a Specialization")
		self:Hide()
		return
	end
	
	if not DB_SPELL or #DB_SPELL.Talent == 0 then
		HDH_InitVaribles()
	end
	
	for i=1,#DB_SPELL.Talent do
		local btn = _G['TalentListFrameTalentButton'..i]
		btn:SetText(DB_SPELL.Talent[i].Name)
		if i == CurSpec then
			btn:Enable()
		else
			btn:Disable() 
		end
	end
	
	if #DB_SPELL.Talent < 4 then
		local btn = _G['TalentListFrameTalentButton4']:Hide()
	end
	HDH_RefrashSettingUI()
	HDH_RefrashList()
end

function HDH_Option_OnLoad(self)
	-- set talent
	-- TalentListFrameTalentButton1
end

-----------------------------------------
---------------------
SLASH_AURATRACKINGT1 = '/at'
SLASH_AURATRACKINGT2 = '/auratracking'
SLASH_AURATRACKINGT3 = '/ㅁㅅ'
SlashCmdList["AURATRACKINGT"] = function (msg, editbox)
	OptionFrame:Show()
end

