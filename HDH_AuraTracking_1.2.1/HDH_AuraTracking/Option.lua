local CurSpec =1

-------------------------------------------
-- user function
-------------------------------------------

function HDH_AddRow(rowFrame)
	local no = rowFrame:GetAttribute("no")
	local button_ad = _G[rowFrame:GetName().."ButtonAddAndDel"]
	local editBox_id = _G[rowFrame:GetName().."EditBoxID"]
	if not editBox_id:GetText() then return end
	
	local name = GetSpellInfo(editBox_id:GetText())
	if name then
		local ifBuff = false
		if rowFrame:GetParent():GetAttribute("type") == "Buff" then
			ifBuff = true
		end
		_G[rowFrame:GetName().."TextName"]:SetText(name)
		button_ad:SetText("Del")
		HDH_SaveSpell(CurSpec, no, editBox_id:GetText(), name, true, ifBuff)
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
	_G[self:GetName().."TextNum"]:SetText(no)
	_G[self:GetName().."TextName"]:SetText(name)
	_G[self:GetName().."EditBoxID"]:SetText(id or "")
	--_G[self:GetName().."TextNum"]:SetText()
end

function HDH_RefrashSettingUI()
	_G["SettingFrameCheckButtonAlwaysShow"]:SetChecked(AuraTracking.always_show)
	_G["SettingFrameCheckButtonMove"]:SetChecked(UI_LOCK)
	_G["SettingFrameSliderFont"]:SetValue(AuraTracking.font.fontsize)
	_G["SettingFrameSliderIcon"]:SetValue(AuraTracking.icon.size)
	_G["SettingFrameCheckButtonIDShow"]:SetChecked(AuraTracking.tooltip_id_show)
end

function HDH_RefrashList()
	local rowFrame
	local button_ad
	local editBox
	local buff = {}
	local debuff ={}
	if AuraTrackingCharacter.Talent[CurSpec] then
		buff  = AuraTrackingCharacter.Talent[CurSpec].Buff
		debuff = AuraTrackingCharacter.Talent[CurSpec].Debuff
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

function HDH_SaveSpell(spec, no, id, name,fix, isBuff)
	local db 
	if isBuff then
		db = AuraTrackingCharacter.Talent[spec].Buff
	else
		db = AuraTrackingCharacter.Talent[spec].Debuff
	end
	db[tonumber(no)] = {}
	db[tonumber(no)].No = no
	db[tonumber(no)].ID = id
	db[tonumber(no)].Name = name
	db[tonumber(no)].Fix = fix
	HDH_InitAuraIcon()
end

function HDH_DelSpell(spec, no, isBuff)
	local db 
	if isBuff then
		db = AuraTrackingCharacter.Talent[spec].Buff
	else
		db = AuraTrackingCharacter.Talent[spec].Debuff
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
	for i=1,#AuraTrackingCharacter.Talent do
		local btn = _G['TalentListFrameTalentButton'..i]
		if i == id then
			btn:Enable() 
		else
			btn:Disable() 
		end
	end
	HDH_RefrashList()
end

function HDH_OnValueChanged(self, value, userInput)
	if self == _G[self:GetParent():GetName().."SliderFont"] then
		AuraTracking.font.fontsize = value
	else 
		AuraTracking.icon.size = value
	end
	HDH_UpdateSetting()
end

function HDH_OnSettingReset(target)
	if target =="UI" then
		AuraTracking = nil
		HDH_InitVaribles()
		HDH_UpdateSetting()
		HDH_MoveFrame(false)
		HDH_RefrashSettingUI()
	else
		AuraTrackingCharacter = nil
		HDH_InitVaribles()
		HDH_InitAuraIcon()
		HDH_RefrashList()
	end
	
end

function HDH_OnAlwaysShow(bool)
	HDH_AlwaysShow(bool)
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
		aura = AuraTrackingCharacter.Talent[CurSpec].Buff
	else
		aura = AuraTrackingCharacter.Talent[CurSpec].Debuff
	end
	
	if aura[tonumber(row)] and aura[tonumber(row)-1] then
		local tmp = {}
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
		aura = AuraTrackingCharacter.Talent[CurSpec].Buff
	else
		aura = AuraTrackingCharacter.Talent[CurSpec].Debuff
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
	
	if not AuraTrackingCharacter or #AuraTrackingCharacter.Talent == 0 then
		HDH_InitVaribles()
	end
	
	for i=1,#AuraTrackingCharacter.Talent do
		local btn = _G['TalentListFrameTalentButton'..i]
		btn:SetText(AuraTrackingCharacter.Talent[i].Name)
		if i == CurSpec then
			btn:Enable()
		else
			btn:Disable() 
		end
	end
	
	if #AuraTrackingCharacter.Talent < 4 then
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
-----------------------------------------
SLASH_HDH1 = '/at'
SLASH_HDH2 = '/auratracking'
SLASH_HDH3 = '/ㅁㅅ'
SlashCmdList["HDH"] = function (msg, editbox)
	OptionFrame:Show()
end
