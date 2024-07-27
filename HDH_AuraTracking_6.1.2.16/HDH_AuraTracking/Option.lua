-----------------
---- #define ----
local FRAME_W = 620
local FRAME_H = 500

local ROW_HEIGHT = 26 -- 오라 row 높이
local EDIT_WIDTH_L = 258
local EDIT_WIDTH_S = 0
local FLAG_ROW_CREATE = 1 -- row 생성 모드
local ANI_MOVE_UP = 1
local ANI_MOVE_DOWN = 0
local TAB_TOP_LEVEL = 5 -- 탭버튼 여러줄일때, 위아래 겹치는 level을 위한
local DDM_COOLDOWN_LIST = {"위로", "아래로", "왼쪽으로", "오른쪽으로", "원형"}
local DDM_FONT_LOCATION_LIST = {"좌측 상단","좌측 하단","우측 상단", "우측 하단", "중앙", "아이콘 밖 위1", "아이콘 밖 위2", "아이콘 밖 아래1","아이콘 밖 아래2"}
local DDM_FONT_LIST = {"쿨다운 글자", "중첩 글자", "1차 수치 글자", "2차 수치 글자"}
local SET_KEY_FONT = {}
SET_KEY_FONT[1] = {size = "fontsize", location = "cd_location",  color = "textcolor"}
SET_KEY_FONT[2] = {size = "countsize", location = "count_location",  color = "countcolor"}
SET_KEY_FONT[3] = {size = "v1_size", location = "v1_location",  color = "v1_color"}
SET_KEY_FONT[4] = {size = "v2_size", location = "v2_location",  color = "v2_color"}
local FONT_SETTING_INDEX = 1

-- 현재 설청창 모드 --
MODE_EDIT = 1 
MODE_SET_ALL = 2
MODE_SET_EACH = 3
MODE_LIST = 4

---- #end def ----
------------------

CURMODE = MODE_LIST
local CurSpec = 1 -- 현재 설정창 특성
CurTab = 1 -- 현재 설정창 유닛탭 위치

local ListFrame
local TAB_TALENT
local TAB_UNIT


local SetFrameContents

-------------------------------------------
-- util
-------------------------------------------

function HDH_GetSpec()
	return CurSpec
end

function GetTabUnitInfo(idx)
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

function LoadDropDownButton(frame, idx, dataTable, onClickFunc)
	frame.id = idx -- 값을 캐싱 해놓고 init 호출시 불러와서 세팅한다
	UIDropDownMenu_Initialize(frame, function(self, level)
		local items = dataTable
		local info = UIDropDownMenu_CreateInfo()
		
		for k,v in pairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = function(self) frame.id = self:GetID(); onClickFunc(self) end
			UIDropDownMenu_AddButton(info, level)
		end
		UIDropDownMenu_SetSelectedID(frame, frame.id)
		if not frame.id then
			UIDropDownMenu_SetText(frame, "선택") 
		end
	end)
	UIDropDownMenu_SetWidth(frame, 100)
	UIDropDownMenu_SetButtonWidth(frame, 100)
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
end

------------------------------------------
-- control DB
------------------------------------------

function HDH_DB_SaveSpell(key, spec, no, id, name, always, glow, showValue, texture, isItem, tabIdx)
	local tabname = GetTabUnitInfo(tabIdx)
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
	db[tonumber(no)].Glow = glow
	db[tonumber(no)].ShowValue = showValue
	db[tonumber(no)].Texture = texture
	db[tonumber(no)].IsItem = isItem
	local t = HDH_TRACKER.Get(tabname)
	if t then t:InitIcons() end
	return true
end

function HDH_DB_DelSpell(spec, no, tabIdx)
	local tabname = GetTabUnitInfo(tabIdx)
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

function HDH_AddRow(rowFrame)
	local listFrame = rowFrame:GetParent()
	local no = rowFrame:GetAttribute("no")
	local key = _G[rowFrame:GetName().."EditBoxID"]:GetText()
	local always = _G[rowFrame:GetName().."CheckButtonAlways"]:GetChecked()
	local glow = _G[rowFrame:GetName().."CheckButtonGlow"]:GetChecked()
	local showValue = _G[rowFrame:GetName().."CheckButtonShowValue"]:GetChecked()
	local item = _G[rowFrame:GetName().."CheckButtonIsItem"]:GetChecked()
	local name, id, icon, isItem = HDH_GetInfo(key, item)
	
	if name then
		if not HDH_DB_SaveSpell(key, CurSpec, no, id, name, always, glow, showValue, icon, isItem, CurTab) then
			print("|cffff0000AuraTracking:Error - |cffffff00'"..name.."("..id..")' 은(는) 이미 등록된 주문입니다.")
			return nil
		end
		if isItem then
			local tabname, unit = GetTabUnitInfo(CurTab)
			if HDH_IS_UNIT[unit] then
				AlertDlg.func = nil
				AlertDlg.text = "오라 추척에 아이템을 등록하였습니다.\n아이템을 사용(발동) 했을 때, 발생되는\n버프(디버프)의 |cffff0000주문 ID로 등록|r하길 권장합니다."
				AlertDlg:Show()
			end
		end
		HDH_SetRowData(rowFrame, key, no, id, name, always, glow, showValue, icon, isItem)
	else
		print("|cffff0000AuraTracking:Error - |cffffff00'"..key.."' 은(는) 알 수 없는 주문 입니다.")
		return nil
	end
	return no
end

function HDH_DelRow(rowFrame)
	local no = rowFrame:GetAttribute("no")
	HDH_DB_DelSpell(CurSpec, no, CurTab)
	HDH_LoadListFrame(CurTab, no)
end

local tmp_color
function HDH_SetRowData(rowFrame, key, no, id, name, always, glow, showValue, texture, isItem)
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(texture)
	_G[rowFrame:GetName().."ButtonIcon"]:SetPushedTexture(texture)
	_G[rowFrame:GetName().."ButtonIcon"]:GetPushedTexture():SetTexCoord(-0.03,1.03,-0.03,1.03)
	_G[rowFrame:GetName().."TextNum"]:SetText(no)
	_G[rowFrame:GetName().."TextName"]:SetText(name)
	_G[rowFrame:GetName().."TextID"]:SetText(id.."")
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(always)
	_G[rowFrame:GetName().."CheckButtonGlow"]:SetChecked(glow)
	local tabname, unit = GetTabUnitInfo(CurTab)
	if HDH_IS_UNIT[unit] then
		_G[rowFrame:GetName().."CheckButtonShowValue"]:SetChecked(showValue)
		_G[rowFrame:GetName().."CheckButtonShowValue"]:Enable()
		local c = {_G[rowFrame:GetName().."CheckButtonGlowText"]:GetTextColor()}
		_G[rowFrame:GetName().."CheckButtonShowValueText"]:SetTextColor(unpack(c))
	else
		_G[rowFrame:GetName().."CheckButtonShowValue"]:SetChecked(false)
		_G[rowFrame:GetName().."CheckButtonShowValue"]:Disable()
		_G[rowFrame:GetName().."CheckButtonShowValueText"]:SetTextColor(0.5,0.5,0.5)
	end
	
	_G[rowFrame:GetName().."EditBoxID"]:SetText(key or "")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(isItem)
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Del")
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
	_G[rowFrame:GetName().."RowDesc"]:Hide()
end

function HDH_ClearRowData(rowFrame)
	_G[rowFrame:GetName().."ButtonIcon"]:SetNormalTexture(nil)
	_G[rowFrame:GetName().."ButtonIcon"]:SetPushedTexture(nil)
	_G[rowFrame:GetName().."TextNum"]:SetText(nil)
	_G[rowFrame:GetName().."TextName"]:SetText(nil)
	_G[rowFrame:GetName().."RowDesc"]:Show()
	_G[rowFrame:GetName().."TextID"]:SetText(nil)
	_G[rowFrame:GetName().."CheckButtonAlways"]:SetChecked(true)
	_G[rowFrame:GetName().."CheckButtonGlow"]:SetChecked(false)
	local tabname, unit = GetTabUnitInfo(CurTab)
	if HDH_IS_UNIT[unit] then
		_G[rowFrame:GetName().."CheckButtonShowValue"]:SetChecked(false)
		_G[rowFrame:GetName().."CheckButtonShowValue"]:Enable()
		local c = {_G[rowFrame:GetName().."CheckButtonGlowText"]:GetTextColor()}
		_G[rowFrame:GetName().."CheckButtonShowValueText"]:SetTextColor(unpack(c))
	else
		_G[rowFrame:GetName().."CheckButtonShowValue"]:SetChecked(false)
		_G[rowFrame:GetName().."CheckButtonShowValue"]:Disable()
		_G[rowFrame:GetName().."CheckButtonShowValueText"]:SetTextColor(0.5,0.5,0.5)
	end
	
	_G[rowFrame:GetName().."EditBoxID"]:SetText("")
	_G[rowFrame:GetName().."ButtonAddAndDel"]:SetText("Add")
	_G[rowFrame:GetName().."CheckButtonIsItem"]:SetChecked(false)
	_G[rowFrame:GetName().."EditBoxID"]:ClearFocus() -- ButtonAddAndDel 의 값때문에 순서 굉장히 중요함
end

function HDH_GetRowFrame(listFrame, index, flag)
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

function HDH_LoadListFrame(tabIdx, startRowIdx, endRowIdx)
	local listFrame = ListFrame
	local aura = {}
	if not DB_AURA.Talent[CurSpec] then return end
	aura = DB_AURA.Talent[CurSpec][GetTabUnitInfo(tabIdx)]
	local rowFrame
	local i = startRowIdx or 1
	
	if DB_OPTION[GetTabUnitInfo(tabIdx)].tracking_all then
		HDH_AT_NoList:Show()
	else
		if startRowIdx and endRowIdx and (startRowIdx > endRowIdx) then return end
		while true do
			rowFrame = HDH_GetRowFrame(listFrame, i, FLAG_ROW_CREATE)-- row가 없으면 생성하고, 있으면 그거 재활용
			if not rowFrame:IsShown() then rowFrame:Show() end
			if aura and aura[i] then
				HDH_SetRowData(rowFrame, aura[i].Key, aura[i].No, aura[i].ID, aura[i].Name, aura[i].Always, aura[i].Glow, aura[i].ShowValue, aura[i].Texture, aura[i].IsItem)
			else-- add 를 위한 공백 row 지정
				HDH_ClearRowData(rowFrame)
				listFrame:SetSize(listFrame:GetParent():GetWidth(), i * ROW_HEIGHT)
				break
			end
			if endRowIdx and endRowIdx == i then return end
			i = i + 1
		end
		HDH_AT_NoList:Hide()
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
	LoadDropDownButton(ProfileFrameDDMProfile, nil, dataTable, HDH_OnSelectItem_DDM_Profile)
end 

function HDH_OnSelectItem_DDM_Profile(self)
	UIDropDownMenu_SetSelectedValue(ProfileFrameDDMProfile, self.value);
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
	HDH_OnShow_ProfileFrame(ProfileFrameDDMProfile)
end

function HDH_OnClick_LoadProfile()
	local name = UIDropDownMenu_GetSelectedValue(ProfileFrameDDMProfile)
	if DB_PROFILE[name] then
		DB_OPTION = deepcopy(DB_PROFILE[name].OPTION)
		DB_FRAME_LIST = deepcopy(DB_PROFILE[name].FRAME_LIST)
		DB_AURA = nil
		ReloadUI() 
	else
		print("|cffff0000AuraTracking:Error - |cffffff00프로필 정보를 찾을 수 없습니다.")
	end
end

function HDH_OnClick_DelProfile()
	local name = UIDropDownMenu_GetSelectedValue(ProfileFrameDDMProfile)
	if not name then return end
	DB_PROFILE[name] = nil
	HDH_OnShow_ProfileFrame(ProfileFrameDDMProfile)
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
	
	self:SetChecked(true)
	HDH_LoadUnitUI(CurTab)
	HDH_LoadListFrame(CurTab)
end

------------------------------------------
-- control Tab : unit
------------------------------------------

local function SetActiveUnitTab(self, bool)
	local name = self:GetName()
	if bool then
		self:Disable()
		--self:SetNormalTexture([[Interface\BUTTONS\UI-DialogBox-Button-Disabled]])
		_G[name.."Text"]:SetPoint("CENTER",0,-3)
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		_G[name.."LeftDisabled"]:Show()
		_G[name.."MiddleDisabled"]:Show()
		_G[name.."RightDisabled"]:Show()
	else
		self:Enable()
		--self:SetNormalTexture([[Interface\BUTTONS\UI-DialogBox-Button-Disabled]])
		--self:GetNormalTexture():SetTexCoord(1,1,1,1)
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


local function DDM_LoadUnitList(value)
	LoadDropDownButton(AddUnitTabFrameDDMUnitList, value, HDH_UNIT_LIST, OnSelectedItem_UnitList)
end

local function DDB_LoadSpecList(value)
	local items = {}
	for i= 1, #DB_AURA.Talent do
		items[i] = DB_AURA.Talent[i].Name
	end
	LoadDropDownButton(AddUnitTabFrameDDMSpecList, value, items, OnSelectedItem_SpecList)
end

local function DDM_LoadTabList(value)
	local items ={}
	for i = 1, #DB_FRAME_LIST do
		items[i] = DB_FRAME_LIST[i].name
	end
	LoadDropDownButton(AddUnitTabFrameDDMTabList, value, items, OnSelectedItem_TabList)
end

local function ShowAddFrame(bool, isModify)
	if isModify then
		if bool then
			local name, unit = GetTabUnitInfo(CurTab)
			_G[AddUnitTabFrame:GetName().."EditBoxName"]:SetText(name)
			
			local idx = 1
			for i = 1, #HDH_UNIT_LIST do
				if HDH_UNIT_LIST[i] == unit then idx = i break end
			end
			DDM_LoadUnitList(idx)
			DDM_LoadTabList()
			DDB_LoadSpecList()
			AddUnitTabFrame.mode = "modify"
			AddUnitTabFrameText1:SetText("추적 창 수정")
			AddUnitTabFrameButtonAddUnit:SetText("적용")
			if HDH_IS_UNIT[unit] then
				AddUnitTabFrameCheckButtonBuff:SetChecked(DB_OPTION[name].check_buff)
				AddUnitTabFrameCheckButtonDebuff:SetChecked(DB_OPTION[name].check_debuff)
				AddUnitTabFrameCheckButtonMine:SetChecked(DB_OPTION[name].check_only_mine)
				AddUnitTabFrameCheckButtonAllAura:SetChecked(DB_OPTION[name].tracking_all)
				AddUnitTabFrameCheckButtonBuff:Show()
				AddUnitTabFrameCheckButtonDebuff:Show()
				AddUnitTabFrameCheckButtonMine:Show()
				AddUnitTabFrameCheckButtonAllAura:Show()
			else
				AddUnitTabFrameCheckButtonBuff:Hide()
				AddUnitTabFrameCheckButtonDebuff:Hide()
				AddUnitTabFrameCheckButtonMine:Hide()
				AddUnitTabFrameCheckButtonAllAura:Hide()
			end
			AddUnitTabFrameButtonCancel:Enable()
			AddUnitTabFrameButtonMoveLeft:Enable()
			AddUnitTabFrameButtonMoveRight:Enable()
			UIDropDownMenu_EnableDropDown(AddUnitTabFrameDDMSpecList)
			UIDropDownMenu_DisableDropDown(AddUnitTabFrameDDMTabList)
			AddUnitTabFrameButtonCopy:Enable()
			AddUnitTabFrameTextE:SetText(nil)
			AddUnitTabFrame:Show()
		else
			AddUnitTabFrame:Hide()
		end
	else
		if bool then
			UnitOptionFrameTextTitle:Hide()
			UnitOptionFrameTextTitle2:Hide()
			UnitOptionFrameTabModify:Hide()
			UnitOptionFrameButtonDeleteUnit:Hide()
			
			DDM_LoadUnitList(1)
			DDM_LoadTabList()
			DDB_LoadSpecList()
			AddUnitTabFrame.mode = "add"
			AddUnitTabFrameText1:SetText("추적 창 추가")
			AddUnitTabFrameButtonAddUnit:SetText("추가")
			AddUnitTabFrameButtonCancel:Disable()
			AddUnitTabFrameButtonMoveLeft:Disable()
			AddUnitTabFrameButtonMoveRight:Disable()
			AddUnitTabFrameCheckButtonBuff:SetChecked(true)
			AddUnitTabFrameCheckButtonDebuff:SetChecked(true)
			AddUnitTabFrameCheckButtonMine:SetChecked(true)
			AddUnitTabFrameCheckButtonAllAura:SetChecked(false)
			AddUnitTabFrameCheckButtonBuff:Show()
			AddUnitTabFrameCheckButtonDebuff:Show()
			AddUnitTabFrameCheckButtonMine:Show()
			AddUnitTabFrameCheckButtonAllAura:Show()
			UIDropDownMenu_DisableDropDown(AddUnitTabFrameDDMSpecList)
			UIDropDownMenu_DisableDropDown(AddUnitTabFrameDDMTabList)
			AddUnitTabFrameButtonCopy:Disable()
			AddUnitTabFrameTextE:SetText(nil)
			AddUnitTabFrame:Show()
			_G[AddUnitTabFrame:GetName().."EditBoxName"]:SetText("")
			
			CurTab = 0
		else
			UnitOptionFrameTextTitle:Show()
			UnitOptionFrameTextTitle2:Show()
			UnitOptionFrameTabModify:Show()
			UnitOptionFrameButtonDeleteUnit:Show()
			AddUnitTabFrame:Hide()
		end
	end
	HDH_SetModeUI(bool and MODE_EDIT or MODE_LIST)
end

function HDH_TabUnit_Load()
	HDH_TabUnit_Init_TabButtons()
	HDH_TabUnit_ChangeTab(UnitOptionFrame.tablist and UnitOptionFrame.tablist[CurTab] or nil)
end

function HDH_TabUnit_Init_TabButtons()
	local count = UnitOptionFrame.tablist and #UnitOptionFrame.tablist or 0
	
	if count < #DB_FRAME_LIST then
		for i = 1, #DB_FRAME_LIST do
			HDH_TabUnit_Add_TabButton(DB_FRAME_LIST[i].name, DB_FRAME_LIST[i].unit)
		end
	end
	HDH_TabUnit_Adjust_AddTabButton()
end

function HDH_TabUnit_Adjust_TabButton(startIdx) -- start index 로 효율적인 로직이 되어야 하는데, 다중 row 에 대해 margin 을 조절하는 명확한 아이디어가 떠오르지 않음................
	if not UnitOptionFrame.tablist then return end
	local list = UnitOptionFrame.tablist
	local btn
	local row = 0
	for i = 1 or 1, #list do
		btn = list[i]
		btn.no = i
		btn:ClearAllPoints()
		if i == 1 then 
			btn:SetPoint("TOPLEFT", btn:GetParent(), "BOTTOMLEFT", 0, 4)
			btn:SetFrameLevel(UnitOptionFrame:GetFrameLevel()+TAB_TOP_LEVEL)
			UnitOptionFrame:SetPoint("BOTTOMRIGHT",-20,70)
		else
			btn:SetFrameLevel(list[i-1]:GetFrameLevel())
			btn:SetPoint("LEFT", list[i-1], "RIGHT", -17, 0)
			if UnitOptionFrame:GetRight()-5 < btn:GetRight() then
				row = row+1
				btn:SetFrameLevel(list[i-1]:GetFrameLevel()-1)
				btn:SetPoint("TOP", list[i-1], "BOTTOM", 0, 7) 
				btn:SetPoint("LEFT", list[1], "LEFT", 0, 0)
				UnitOptionFrame:SetPoint("BOTTOMRIGHT",-20,70 +(row*25))
			end
		end
	end
	HDH_TabUnit_Adjust_AddTabButton()
end

function HDH_TabUnit_Adjust_AddTabButton()
	if not UnitOptionFrame.AddBtn then 
		UnitOptionFrame.AddBtn = CreateFrame("Button", "AddTabBtn", UnitOptionFrame, "CharacterFrameTabButtonTemplate")
		--_G["AddTabBtnText"]:SetText("|cffffffffAdd")
		UnitOptionFrame.AddBtn:SetScript("OnClick", HDH_OnClick_AddTabButton)
		AddTabBtnMiddle:SetWidth(20)
		AddTabBtnMiddleDisabled:SetWidth(20)
		UnitOptionFrame.AddBtn:SetAlpha(0.6)
		UnitOptionFrame.AddBtn:SetWidth(60)
		local t = UnitOptionFrame.AddBtn:CreateTexture(nil, "OVERLAY")
		t:SetTexture([[Interface\BUTTONS\UI-PlusMinus-Buttons]])
		--t:SetAlpha(0.7)
		t:SetSize(11,11)
		t:SetPoint("CENTER",0,2)
		t:SetTexCoord(0,0.5,0,0.5)
		SetActiveUnitTab(UnitOptionFrame.AddBtn, false)
	end
	local btn = UnitOptionFrame.AddBtn
	local count = UnitOptionFrame.tablist and #UnitOptionFrame.tablist or 0
	btn:ClearAllPoints()
	
	if count == MAX_COUNT_AURAFRAME then btn:Hide() return end
	btn:Show()
	if count == 0 then
		btn:SetPoint("TOPLEFT", UnitOptionFrame, "BOTTOMLEFT", 0, 4)
		btn:SetFrameLevel(UnitOptionFrame:GetFrameLevel()+TAB_TOP_LEVEL)
	else
		btn:SetPoint("LEFT", UnitOptionFrame.tablist[#UnitOptionFrame.tablist], "RIGHT", -17, 0)
		btn:SetFrameLevel(UnitOptionFrame.tablist[#UnitOptionFrame.tablist]:GetFrameLevel())
		if UnitOptionFrame:GetRight()-5 < btn:GetRight() then
			btn:SetFrameLevel(UnitOptionFrame.tablist[#UnitOptionFrame.tablist]:GetFrameLevel()-1)
			btn:SetPoint("TOP", UnitOptionFrame.tablist[#UnitOptionFrame.tablist], "BOTTOM", 0, 7) 
			btn:SetPoint("LEFT", UnitOptionFrame.tablist[1], "LEFT", 0, 0)
			
		end
	end
end

local _idx = 1
function HDH_TabUnit_Add_TabButton(name, unit)
	--create tab button : UnitOptionFrame 
	local parent = UnitOptionFrame
	
	if not parent.tablist then
		parent.tablist = {}
	end
	
	local btn = CreateFrame("Button", "BtnTabUnit".._idx, parent, "CharacterFrameTabButtonTemplate")
	_idx = _idx +1
	_G[btn:GetName().."Text"]:SetText(name)
	btn:ClearAllPoints()
	btn:SetScript("OnClick", HDH_OnClickTabUnit)
	btn.unit = unit
	btn.name = name
	btn.no = #parent.tablist+1
	btn:Hide()
	btn:Show()
	SetActiveUnitTab(btn, false)
	parent.tablist[#parent.tablist+1] = btn
	HDH_TabUnit_Adjust_TabButton(#parent.tablist)
	HDH_TabUnit_ChangeTab(btn)
end

function HDH_TabUnit_Del_TabButton(idx)
	if not UnitOptionFrame.tablist then return end
	
	UnitOptionFrame.tablist[idx]:Hide()
	UnitOptionFrame.tablist[idx]:SetParent(nil)
	local btn
	for i = idx , #UnitOptionFrame.tablist do
		UnitOptionFrame.tablist[i] = UnitOptionFrame.tablist[i+1]
		btn = UnitOptionFrame.tablist[i]
		if btn == nil then break end
		btn.no = i
	end
	HDH_TabUnit_Adjust_TabButton(idx)
end

function HDH_TabUnit_Exchange_TabButton(idx1, idx2)
	local max = UnitOptionFrame.tablist and #UnitOptionFrame.tablist or 0
	if (0 < idx1 and idx1 <= max) and (0 < idx2 and idx2 <= max) and (idx1 ~= idx2) then
		local tmp = UnitOptionFrame.tablist[idx1]
		UnitOptionFrame.tablist[idx1] = UnitOptionFrame.tablist[idx2]
		UnitOptionFrame.tablist[idx2] = tmp
		
		tmp = DB_FRAME_LIST[idx1] 
		DB_FRAME_LIST[idx1] = DB_FRAME_LIST[idx2]
		DB_FRAME_LIST[idx2] = tmp
		
		tmp = nil
		
		HDH_TabUnit_Adjust_TabButton()
		HDH_RefreshFrameLevel_All()
		return true
	end
	return false
end

function HDH_TabUnit_ChangeTab(self, idx)
	self = self or (UnitOptionFrame.tablist and UnitOptionFrame.tablist[idx]) or nil
	if self then CurTab = self.no or CurTab end
	if UnitOptionFrame.AddBtn then
		ShowAddFrame(UnitOptionFrame.AddBtn == self)
		SetActiveUnitTab(UnitOptionFrame.AddBtn, UnitOptionFrame.AddBtn == self)
	end
	if not UnitOptionFrame.tablist or #UnitOptionFrame.tablist == 0 then 
		ShowAddFrame(true)
		SetActiveUnitTab(UnitOptionFrame.AddBtn, true)
		return 
	end
	for i=1, #UnitOptionFrame.tablist do
		if UnitOptionFrame.tablist[i] == self then
			SetActiveUnitTab(self, true)
			HDH_LoadListFrame(i)
			HDH_LoadUnitUI(i)
			local name, unit = GetTabUnitInfo(CurTab)
			UnitOptionFrameTextTitle:SetText(name)
			UnitOptionFrameTextTitle2:SetText(("(%s)"):format(unit:gsub("^%l", string.upper)))
			local w = UnitOptionFrameTextTitle:GetStringWidth()
			UnitOptionFrameTextTitle2:SetPoint("LEFT",UnitOptionFrameTextTitle, "LEFT", w+5, 0)
			UnitOptionFrameTabModify:SetPoint("LEFT",UnitOptionFrameTextTitle2,"LEFT",UnitOptionFrameTextTitle2:GetStringWidth()+10,0)
		else
			SetActiveUnitTab(UnitOptionFrame.tablist[i], false)
		end
	end
end

function HDH_OnClickTabUnit(self) -- script 펑션은 후킹이 안됨
	HDH_TabUnit_ChangeTab(self) -- hooking 가능 하도록
end

function HDH_OnClickAddUnit(self)
	local mode = self:GetParent().mode
	local ddm = _G[self:GetParent():GetName().."DDMUnitList"]
	local ed = _G[self:GetParent():GetName().."EditBoxName"]
	local err = _G[self:GetParent():GetName().."TextE"]
	local name = trim(ed:GetText())
	local unit = HDH_UNIT_LIST[ddm.id]
	ed:SetText(name)
	if name ~= "" and unit then
		if mode == "add" then
			local tracker = HDH_TRACKER.Get(name)
			if not tracker then
				tracker = HDH_TRACKER.new(name, unit)
				HDH_DB_Add_FRAME_LIST(name, unit)
				if UI_LOCK then
					tracker:SetMove(true)
					tracker:CreateDummySpell(MAX_ICONS_COUNT)
					tracker.frame:Show()
					tracker:UpdateIcons()
				end
				HDH_TabUnit_Add_TabButton(name, unit)
				HDH_SetModeUI(MODE_LIST)
				DB_OPTION[name].check_buff = AddUnitTabFrameCheckButtonBuff:GetChecked()
				DB_OPTION[name].check_debuff = AddUnitTabFrameCheckButtonDebuff:GetChecked()
				DB_OPTION[name].check_only_mine = AddUnitTabFrameCheckButtonMine:GetChecked()
				DB_OPTION[name].tracking_all = AddUnitTabFrameCheckButtonAllAura:GetChecked()
				if DB_OPTION[name].tracking_all then
					tracker:InitIcons()
				end
			else
				err:SetText("|cffffffff(|r'"..name.."' |cffffffff : 이미 존재하는 이름입니다)")
				return
			end
		elseif mode =="modify" then
			local oldName, oldUnit = GetTabUnitInfo(CurTab)
			local tracker = HDH_TRACKER.Get(oldName)
			if tracker and tracker.name ~= oldName then
				ed:SetText(oldName)
				err:SetText("|cffffffff(|r'"..name.."' |cffffffff : 이미 존재하는 이름입니다)")
				return
			else
				if not tracker then return end
				tracker:Modify(name, unit)
				_G[UnitOptionFrame.tablist[CurTab]:GetName().."Text"]:SetText(name)
				UnitOptionFrame.tablist[CurTab]:Hide()
				UnitOptionFrame.tablist[CurTab]:Show()
				HDH_TabUnit_Adjust_TabButton() -- 이름 길이가 달라지면 탭의 열 위취가 변경될 수 있슴
				HDH_TabUnit_ChangeTab(UnitOptionFrame.tablist[CurTab])
				ShowAddFrame(true, true)
				--self:GetParent():Hide()
			end
		end
	else
		if mode == "modify" then ed:SetText(GetTabUnitInfo(CurTab)) end
		err:SetText("|cffffffff(이름을 입력해주세요)")
		return
	end
	HDH_RefreshFrameLevel_All()
end

function HDH_OnClickModifyUnit(self)
	ShowAddFrame(true, true)
end

function HDH_OnClickDelUnit()
	local name = GetTabUnitInfo(CurTab)
	HDH_TRACKER.RemoveList(name)
	HDH_TabUnit_Del_TabButton(CurTab)
	HDH_TabUnit_ChangeTab(UnitOptionFrame.tablist[1])
	HDH_RefreshFrameLevel_All()
end

function HDH_OnClickCloseAddUnitFrmame(self)
	HDH_TabUnit_ChangeTab(UnitOptionFrame.tablist[CurTab])
end

function HDH_OnClick_AddTabButton(self)
	HDH_TabUnit_ChangeTab(self)
end

function HDH_CopyAuraList(srcSpec, srcName, dstName)
	if not srcName or not dstName then return end
	if (srcSpec == CurSpec) and (srcName == dstName) then return end
	
	DB_AURA.Talent[CurSpec][dstName] = deepcopy(DB_AURA.Talent[srcSpec][srcName])
	local t = HDH_TRACKER.Get(dstName)
	if t then t:InitIcons() end
end

function HDH_OnClickCopyAura(self)
	local name = UIDropDownMenu_GetSelectedValue(AddUnitTabFrameDDMTabList)
	local spec = UIDropDownMenu_GetSelectedID(AddUnitTabFrameDDMSpecList)
	if not name or not GetTabUnitInfo(CurTab) or not spec or spec == 0 then 
		print("|cffff0000AuraTracking:Error - |cffffff00특성과 추적 창 목록을 선택해주세요.|r")
		return 
	end
	if AlertDlg:IsShown() then return end
	AlertDlg.func = HDH_CopyAuraList
	AlertDlg.arg = {spec, name, GetTabUnitInfo(CurTab)}
	AlertDlg.text = "현재 추적 창의 오라 목록을 '"..name.."'의 목록으로\n|cffffffff교체 하시겠습니까?\n|cffff0000(기존 목록은 삭제 됩니다)"
	AlertDlg:Show()
end

function HDH_OnClick_TabUnit_MoveLeft(self)
	if HDH_TabUnit_Exchange_TabButton(CurTab, CurTab-1) then
		CurTab = CurTab - 1
	end
end

function HDH_OnClick_TabUnit_MoveRight(self)
	if HDH_TabUnit_Exchange_TabButton(CurTab, CurTab+1) then
		CurTab = CurTab + 1
	end
end

function OnSelectedItem_UnitList(self)
	UIDropDownMenu_SetSelectedID(AddUnitTabFrameDDMUnitList, self:GetID())
	UIDropDownMenu_SetSelectedValue(AddUnitTabFrameDDMUnitList, self.value)
	AddUnitTabFrameDDMUnitList.value = self.value
	AddUnitTabFrameDDMUnitList.id = self:GetID()
	
	if HDH_IS_UNIT[self.value] then
		AddUnitTabFrameCheckButtonBuff:Show()
		AddUnitTabFrameCheckButtonDebuff:Show()
		AddUnitTabFrameCheckButtonMine:Show()
		AddUnitTabFrameCheckButtonAllAura:Show()
	else
		AddUnitTabFrameCheckButtonBuff:Hide()
		AddUnitTabFrameCheckButtonDebuff:Hide()
		AddUnitTabFrameCheckButtonMine:Hide()
		AddUnitTabFrameCheckButtonAllAura:Hide()
	end
end

function OnSelectedItem_SpecList(self)
	UIDropDownMenu_SetSelectedID(AddUnitTabFrameDDMSpecList, self:GetID())
	if self:GetID() > 0 then
		UIDropDownMenu_EnableDropDown(AddUnitTabFrameDDMTabList)
	else
		UIDropDownMenu_DisableDropDown(AddUnitTabFrameDDMTabList)
	end
end

function OnSelectedItem_TabList(self)
	UIDropDownMenu_SetSelectedID(AddUnitTabFrameDDMTabList, self:GetID())
	UIDropDownMenu_SetSelectedValue(AddUnitTabFrameDDMTabList, self.value)
end

------------------------------------------
-- control DropDownMenu
------------------------------------------

function OnSeletedItem_DDMCooldown(self)
	UIDropDownMenu_SetSelectedID(UnitOptionFrameDDMCooldown, self:GetID())
	DB_OPTION[GetTabUnitInfo(CurTab)].cooldown = self:GetID()
	if UI_LOCK then
		HDH_TRACKER.SetMoveAll(UI_LOCK)
	else
		local t = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
		if t then t:UpdateSetting() end
	end
end

local function HDH_LoadDropDownCooldown(value)
	LoadDropDownButton(UnitOptionFrameDDMCooldown, value, DDM_COOLDOWN_LIST, OnSeletedItem_DDMCooldown)
end


------------------------------------------
-- ColorPicker 
------------------------------------------

function HDH_ShowColorPicker(picker_type)
	local key = SET_KEY_FONT[FONT_SETTING_INDEX]
	if ColorPickerFrame:IsShown() then return end
	local option
	if CURMODE == MODE_SET_EACH then
		if not GetTabUnitInfo(CurTab)then return end
		option = DB_OPTION[GetTabUnitInfo(CurTab)]
	else
		option = DB_OPTION
	end
	
	ColorPickerFrame.arg = picker_type
	if picker_type == "buff" then
		ColorPickerFrame.func = function() end
		ColorPickerFrame.opacityFunc = HDH_OnSelectedColor
		ColorPickerFrame.cancelFunc = function() end
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetColorRGB(unpack(option.icon.buff_color))
	elseif picker_type == "debuff" then
		ColorPickerFrame.func = function() end
		ColorPickerFrame.opacityFunc = HDH_OnSelectedColor
		ColorPickerFrame.cancelFunc = function() end
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetColorRGB(unpack(option.icon.debuff_color))
	elseif picker_type == "text" then
		ColorPickerFrame.func = function() end
		ColorPickerFrame.opacityFunc = HDH_OnSelectedColor
		ColorPickerFrame.cancelFunc = function() end
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetColorRGB(unpack(option.font[key.color]))
	elseif picker_type == "text5" then
		ColorPickerFrame.func = function() end
		ColorPickerFrame.opacityFunc = HDH_OnSelectedColor
		ColorPickerFrame.cancelFunc = function() end
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetColorRGB(unpack(option.font.textcolor_5s))
	else
		ColorPickerFrame.opacity = option.icon.cooldown_bg_color[4]
		OpacitySliderFrame:SetValue(option.icon.cooldown_bg_color[4])
		ColorPickerFrame.previousValues = {option.icon.cooldown_bg_color[1],
											option.icon.cooldown_bg_color[2],
											option.icon.cooldown_bg_color[3],
											option.icon.cooldown_bg_color[4]};
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.func = HDH_OnSelectedColorAlpha 
		ColorPickerFrame.opacityFunc = HDH_OnSelectedColorAlpha
		ColorPickerFrame.cancelFunc = HDH_OnSelectColorCancel
		
		ColorPickerFrame:SetColorRGB(option.icon.cooldown_bg_color[1], option.icon.cooldown_bg_color[2], option.icon.cooldown_bg_color[3])
		--OpacitySliderFrame:SetValue(option.cooldown_bg_color[4])
		
	end
	ColorPickerFrame:Show();
end

------------------------------------------
-- control UI 
------------------------------------------

function HDH_RefrashSettingUI(mode)
	local icon, font
	if mode == MODE_SET_ALL then
		icon = DB_OPTION.icon
		font = DB_OPTION.font
	else
		local name = GetTabUnitInfo(CurTab)
		if not name then return end
		icon = DB_OPTION[name].icon
		font = DB_OPTION[name].font
	end
	if not icon or not font then return end
	
	_G["OptionFrameCheckButtonMove"]:SetChecked(UI_LOCK)
	_G[SettingFrame:GetName().."CheckButtonIDShow"]:SetChecked(DB_OPTION.tooltip_id_show)
	_G[SettingFrame:GetName().."CheckButtonAlwaysShow"]:SetChecked(DB_OPTION.always_show)
	
	--_G[SetFrameContents:GetName().."SliderFont"]:SetValue(font.fontsize)
	HDH_Adjust_Slider(_G[SetFrameContents:GetName().."SliderIcon"], icon.size ,20, 400)
	HDH_Adjust_Slider(_G[SetFrameContents:GetName().."SliderMarginH"], icon.margin_h ,0, 100)
	HDH_Adjust_Slider(_G[SetFrameContents:GetName().."SliderMarginV"], icon.margin_v ,0, 100)
	_G[SetFrameContents:GetName().."SliderOnAlpha"]:SetValue(icon.on_alpha*100)
	_G[SetFrameContents:GetName().."SliderOffAlpha"]:SetValue(icon.off_alpha*100)
	_G[SetFrameContents:GetName().."CheckButtonShowCooldown"]:SetChecked(icon.show_cooldown)
	_G[SetFrameContents:GetName().."ButtonColorBuffColor"]:SetTexture(unpack(icon.buff_color))
	_G[SetFrameContents:GetName().."ButtonColorDebuffColor"]:SetTexture(unpack(icon.debuff_color))
	_G[SetFrameContents:GetName().."ButtonColorCooldownBgColor"]:SetTexture(unpack(icon.cooldown_bg_color))
	
	--_G["UnitOptionFrameCheckButtonPet"]:SetChecked(DB_OPTION["player"].check_pet)
	--_G["UnitOptionFrameDDMCooldown"]:
	HDH_LoadUnitUI(CurTab)
end

function HDH_LoadUnitUI(tabIdx)
	local name = GetTabUnitInfo(tabIdx)
	if not name then return end
	if not DB_OPTION[name] then return end
	_G["UnitOptionFrameCheckButtonReversH"]:SetChecked(DB_OPTION[name].revers_h)
	_G["UnitOptionFrameCheckButtonReversV"]:SetChecked(DB_OPTION[name].revers_v)
	_G["UnitOptionFrameCheckButtonFix"]:SetChecked(DB_OPTION[name].fix)
	_G["UnitOptionFrameSliderLine"]:SetValue(DB_OPTION[name].line)
	_G["UnitOptionFrameCheckButtonEachSet"]:SetChecked(DB_OPTION[name].use_each)
	if DB_OPTION[name].use_each then
		_G["UnitOptionFrameButtonEachSet"]:Enable()
	else
		_G["UnitOptionFrameButtonEachSet"]:Disable()
	end
	HDH_LoadDropDownCooldown(DB_OPTION[name].cooldown)
	--UIDropDownMenu_Initialize(UnitOptionFrameDDMCooldown, InitializeDropDownCooldown)
end

function HDH_SetModeUI(mode)
	CURMODE = mode or MODE_LIST;
	if mode == MODE_EDIT then
		UnitOptionFrameCheckButtonReversH:Hide()
		UnitOptionFrameCheckButtonReversV:Hide()
		UnitOptionFrameCheckButtonFix:Hide()
		UnitOptionFrameSliderLine:Hide()
		UnitOptionFrameDDMCooldown:Hide()
		UnitOptionFrameCheckButtonEachSet:Hide()
		UnitOptionFrameButtonEachSet:Hide()
		UnitOptionFrameSF:Hide()
		AddUnitTabFrame:Show()
		SettingFrame:Hide()
		SettingFrame:Hide() 
		ProfileFrame:Hide()
		UnitOptionFrame:Show()
		TalentListFrame:Show()
		
	elseif mode == MODE_SET_EACH then
		UnitOptionFrameCheckButtonReversH:Hide()
		UnitOptionFrameCheckButtonReversV:Hide()
		UnitOptionFrameCheckButtonFix:Hide()
		UnitOptionFrameSliderLine:Hide()
		UnitOptionFrameDDMCooldown:Hide()
		UnitOptionFrameCheckButtonEachSet:Hide()
		UnitOptionFrameButtonEachSet:Hide()
		UnitOptionFrameSF:Hide()
		AddUnitTabFrame:Hide()
		HDH_SetModeSettingFrame(mode)
		SettingFrame:Show() 
		ProfileFrame:Hide()
		UnitOptionFrame:Show()
		TalentListFrame:Show()
		
	elseif mode == MODE_SET_ALL then
		SettingFrame:Show()
		ProfileFrame:Show()
		UnitOptionFrame:Hide()
		TalentListFrame:Hide()
		HDH_SetModeSettingFrame(mode)
		
	else -- mode == MODE_LIST
		SettingFrame:Hide()
		UnitOptionFrameCheckButtonReversH:Show()
		UnitOptionFrameCheckButtonReversV:Show()
		UnitOptionFrameCheckButtonFix:Show()
		UnitOptionFrameSliderLine:Show()
		UnitOptionFrameDDMCooldown:Show()
		UnitOptionFrameCheckButtonEachSet:Show()
		UnitOptionFrameButtonEachSet:Show()
		UnitOptionFrameSF:Show()
		AddUnitTabFrame:Hide()
		SettingFrame:Hide() 
		ProfileFrame:Hide()
		UnitOptionFrame:Show()
		TalentListFrame:Show()
	end
end

function HDH_SetModeSettingFrame(mode)
	local title = _G[SettingFrame:GetName().."TitleText"]
	local close = _G[SettingFrame:GetName().."ButtonClose"]
	local reset_ui = _G[SettingFrame:GetName().."ButtonResetUI"]
	local reset_aura = _G[SettingFrame:GetName().."ButtonResetAura"]
	local id_show = _G[SettingFrame:GetName().."CheckButtonIDShow"]
	local always_show = _G[SettingFrame:GetName().."CheckButtonAlwaysShow"]
	
	if mode == MODE_SET_EACH then
		title:Hide()
		SettingFrame:ClearAllPoints();
		SettingFrame:SetPoint("TOPLEFT",UnitOptionFrame,"TOPLEFT",0,0);
		SettingFrame:SetPoint("BOTTOMRIGHT",UnitOptionFrame,"BOTTOMRIGHT",0,0);
		close:Show()
		reset_ui:Hide()
		reset_aura:Hide()
		id_show:Hide()
		always_show:Hide()
		HDH_RefrashSettingUI(MODE_SET_EACH)
	else -- mode == MODE_SET_ALL
		title:Show()
		SettingFrame:ClearAllPoints();
		--f:SetHeight(180);
		SettingFrame:SetPoint("TOPLEFT", SettingFrame:GetParent(), "TOPLEFT", 20 , -50)
		SettingFrame:SetPoint("BOTTOMRIGHT",SettingFrame:GetParent(),"BOTTOMRIGHT",-20, 160);
		close:Hide()
		reset_ui:Show()
		reset_aura:Show()
		id_show:Show()
		always_show:Show()
		HDH_RefrashSettingUI(MODE_SET_ALL)
	end
	HDH_DDM_LoadFontList()
end



------------------------------------------
-- setting font functions
------------------------------------------

local function HDH_OnSelectItem_DDM_Font_Location(self)
	local key = SET_KEY_FONT[FONT_SETTING_INDEX]
	local ddm = _G[SetFrameContents:GetName().."DDMFontLocation"]
	UIDropDownMenu_SetSelectedID(ddm,self:GetID())
	local id = UIDropDownMenu_GetSelectedID(ddm)
	local option
	if CURMODE == MODE_SET_EACH then
		local name = GetTabUnitInfo(CurTab)
		option = DB_OPTION[name]
		option.font[key.location] = id
		local t = HDH_TRACKER.Get(name)
		if t then 
			t:UpdateSetting() 
			if UI_LOCK then t:SetMove(UI_LOCK)
				       else t:Update() end
		end
	else
		option = DB_OPTION
		option.font[key.location] = id
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

local function OnSelectedItem_Font(self)
	local ddm = _G[SetFrameContents:GetName().."DDMFont"]
	UIDropDownMenu_SetSelectedID(ddm,self:GetID())
	local id = UIDropDownMenu_GetSelectedID(ddm)
	HDH_LoadFontSetting(CURMODE, id)
end

function HDH_DDM_LoadFontList()
	local ui_ddm_font_list = _G[SetFrameContents:GetName().."DDMFont"]
	LoadDropDownButton(ui_ddm_font_list, 1, DDM_FONT_LIST, OnSelectedItem_Font)
	HDH_LoadFontSetting(CURMODE, 1)
end


function HDH_LoadFontSetting(mode, value)
	FONT_SETTING_INDEX = value
	local key = SET_KEY_FONT[value]
	local icon, font
	if mode == MODE_SET_ALL then
		icon = DB_OPTION.icon
		font = DB_OPTION.font
	else
		local name = GetTabUnitInfo(CurTab)
		if not name then return end
		icon = DB_OPTION[name].icon
		font = DB_OPTION[name].font
	end
	if not icon or not font then return end

	local ui_color_5s= _G[SetFrameContents:GetName().."ButtonColorCooldownText5Color"]
	local ui_color = _G[SetFrameContents:GetName().."ButtonColorTextColor"]
	local ui_slider_size = _G[SetFrameContents:GetName().."SliderFont"]
	local ui_check_show_cd = _G[SetFrameContents:GetName().."CheckButtonShowCooldown"]
	local ui_ddm_location = _G[SetFrameContents:GetName().."DDMFontLocation"]
	
	if value == 1 then
		ui_color_5s:SetTexture(unpack(font.textcolor_5s))
		ui_color_5s:GetParent():Show()
		ui_check_show_cd:Show()
		ui_check_show_cd:SetChecked(icon.show_cooldown)
	else
		ui_color_5s:GetParent():Hide()
		ui_check_show_cd:Hide()
	end
	
	HDH_Adjust_Slider(ui_slider_size, font[key.size], 12, 32)
	ui_color:SetTexture(unpack(font[key.color]))
	LoadDropDownButton(ui_ddm_location, font[key.location], DDM_FONT_LOCATION_LIST, HDH_OnSelectItem_DDM_Font_Location)
	
	--HDH_Adjust_Slider(_G[SetFrameContents:GetName().."SliderFont2"], font.countsize ,12, 32)
	
	
	--_G[SetFrameContents:GetName().."ButtonColorCountTextColor"]:SetTexture(unpack(font.countcolor))
	
	
	--LoadDropDownButton(_G[SetFrameContents:GetName().."DDMFontLocation2"],font.count_location, DDM_FONT_LOCATION_LIST, HDH_OnSelectItem_DDM_Count_Location)
end

------------------------------------------
-- Call back function
------------------------------------------

function HDH_OnRevers(t, unit, check)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	if t == 'h' then
		DB_OPTION[name].revers_h = check
	else
		DB_OPTION[name].revers_v = check
	end
	if UI_LOCK then
		HDH_TRACKER.SetMoveAll(UI_LOCK)
	else
		local t = HDH_TRACKER.Get(name)
		if t then t:Update() end
	end
end

function HDH_OnFix(check)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	
	DB_OPTION[name].fix = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnShowValue(self, no, check)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].ShowValue = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnShow_ValueFrame(self, check, id)
	if not check then HDH_OptionFrame_HideAni(ValueOptionFrame)end
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(id)] then return end
	db = db[tonumber(id)]
	if check == true then
		ValueOptionFrame:ClearAllPoints()
		ValueOptionFrame:SetPoint("TOPLEFT",self,"BOTTOMRIGHT",10,5)
		ValueOptionFrame.id = id
		--GlowOptionFrameEB:SetText(db[tonumber(id)].GlowCount or 0)
		
		_G[ValueOptionFrame:GetName().."CheckButtonValue1"]:SetChecked(db.v1)
		_G[ValueOptionFrame:GetName().."CheckButtonValue2"]:SetChecked(db.v2)
		_G[ValueOptionFrame:GetName().."CheckButtonValuePerHp1"]:SetChecked(db.v1_hp or false)
		_G[ValueOptionFrame:GetName().."CheckButtonValuePerHp2"]:SetChecked(db.v2_hp or false)
		_G[ValueOptionFrame:GetName().."EB1"]:SetText(db.v1_type or "")
		_G[ValueOptionFrame:GetName().."EB2"]:SetText(db.v2_type or "")
		HDH_OptionFrame_ShowAni(ValueOptionFrame)
	end
end

function HDH_OnClick_SaveShowValue(self)
	local v1 = _G[self:GetParent():GetName().."CheckButtonValue1"]:GetChecked()
	local v2 = _G[self:GetParent():GetName().."CheckButtonValue2"]:GetChecked()
	local h1 = _G[self:GetParent():GetName().."CheckButtonValuePerHp1"]:GetChecked()
	local h2 = _G[self:GetParent():GetName().."CheckButtonValuePerHp2"]:GetChecked()
	local text1 = _G[self:GetParent():GetName().."EB1"]:GetText()
	local text2 = _G[self:GetParent():GetName().."EB2"]:GetText()
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not ValueOptionFrame.id then return end
	if not db[tonumber(ValueOptionFrame.id)] then return end
	db = db[tonumber(ValueOptionFrame.id)]
	db.v1 = v1
	db.v1_type = HDH_trim(text1) or "" 
	db.v1_hp = h1
	db.v2 = v2 
	db.v2_type = HDH_trim(text2) or ""
	db.v2_hp = h2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnGlow(self, no, check)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Glow = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnShow_GlowFrame(self, check , id)
	if not check then HDH_OptionFrame_HideAni(GlowOptionFrame) end
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(id)] then return end
	
	if check == true then
		GlowOptionFrame:ClearAllPoints()
		GlowOptionFrame:SetPoint("TOPLEFT",self,"BOTTOMRIGHT",10,5)
		GlowOptionFrame.id = id
		GlowOptionFrameEB:SetText(db[tonumber(id)].GlowCount or "")
		GlowOptionFrameEB2:SetText(db[tonumber(id)].GlowV1 or "")
		GlowOptionFrameEB3:SetText(db[tonumber(id)].GlowV2 or "")
		HDH_OptionFrame_ShowAni(GlowOptionFrame)
	end
end

function HDH_OnClick_SaveGlowCount(self)
	local count = _G[self:GetParent():GetName().."EB"]:GetText()
	local v1 = _G[self:GetParent():GetName().."EB2"]:GetText()
	local v2 = _G[self:GetParent():GetName().."EB3"]:GetText()
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not GlowOptionFrame.id then return end
	if not db[tonumber(GlowOptionFrame.id)] then return end
	
	count = tonumber(HDH_trim(count))
	v1 = tonumber(HDH_trim(v1))
	v2 = tonumber(HDH_trim(v2))
	db[tonumber(GlowOptionFrame.id)].GlowCount = count
	db[tonumber(GlowOptionFrame.id)].GlowV1 = v1
	db[tonumber(GlowOptionFrame.id)].GlowV2 = v2
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnAlways(unit, no, check)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local db = DB_AURA.Talent[CurSpec][name]
	if not db[tonumber(no)] then return end
	
	db[tonumber(no)].Always = check
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnValueChanged(self, value, userInput)
	local name = GetTabUnitInfo(CurTab)
	if not name then return end
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[name]
	else
		option = DB_OPTION
	end
	value = math.floor(value)
	if self == _G[self:GetParent():GetName().."SliderFont"] then
		local key = SET_KEY_FONT[FONT_SETTING_INDEX]
		option.font[key.size] = math.floor(value)
		if CURMODE == MODE_SET_EACH then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == _G[self:GetParent():GetName().."SliderIcon"] then
		option.icon.size = math.floor(value)
		if CURMODE == MODE_SET_EACH then
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
	elseif self == _G[self:GetParent():GetName().."SliderOnAlpha"] then
		option.icon.on_alpha = value/100
		if CURMODE == MODE_SET_EACH then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == _G[self:GetParent():GetName().."SliderOffAlpha"] then
		option.icon.off_alpha = value/100
		if CURMODE == MODE_SET_EACH then
			local t = HDH_TRACKER.Get(name)
			if t then t:UpdateSetting() end
		else
			HDH_TRACKER.UpdateSettingAll()
		end
	elseif self == _G["UnitOptionFrameSliderLine"] then
		DB_OPTION[name].line = value
		local t = HDH_TRACKER.Get(name)
		if t then 
			if UI_LOCK then t:SetMove(UI_LOCK)
					   else t:Update() end
		end		
	elseif self == _G[SetFrameContents:GetName().."SliderMarginH"] then
		option.icon.margin_h = math.floor(value)
		if CURMODE == MODE_SET_EACH then
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
	elseif self == _G[SetFrameContents:GetName().."SliderMarginV"] then
		option.icon.margin_v = math.floor(value)
		if CURMODE == MODE_SET_EACH then
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
		HDH_RefrashSettingUI(MODE_SET_ALL)
	else
		DB_AURA = nil
		DB_FRAME_LIST = nil
		ReloadUI()
	end
end

function HDH_OnCheckTooltipShow(checked)
	DB_OPTION.tooltip_id_show = checked
end

function HDH_OnAlwaysShow(bool)
	DB_OPTION.always_show = bool
	for k,tracker in pairs(HDH_TRACKER.GetList()) do
		tracker:Update()
	end
	--HDH_AlwaysShow(bool)
end

function HDH_OnMoveAble(bool)
	HDH_TRACKER.SetMoveAll(bool)
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
	local name = GetTabUnitInfo(CurTab)
	local str = HDH_trim(self:GetText()) or ""
	self:SetText(str)
	if tonumber(self:GetText()) and string.len(self:GetText()) > 7 then 
		print("|cffff0000AuraTracking:Error - |cffffff00'"..self:GetText().."' 은(는) 알 수 없는 주문입니다.")
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
		print("|cffff0000AuraTracking:Error - |cffffff00주문 ID/이름을 입력해주세요.")
	end
end

function HDH_OnCheckedAllAura(checked)
	local name = GetTabUnitInfo(CurTab)
	local tracker = HDH_TRACKER.Get(name)
	if tracker then
		DB_OPTION[name].tracking_all = checked
		if UI_LOCK then tracker:SetMove(UI_LOCK)
				   else tracker:InitIcons() end
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
	local name = GetTabUnitInfo(CurTab)
	local aura = DB_AURA.Talent[CurSpec][name]
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
		f2.ani.args = {CurTab, row-1, row}
		StartAni(f1, ANI_MOVE_UP)
		StartAni(f2 , ANI_MOVE_DOWN)
	end
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnClickBtnDown(self, row)
	row = tonumber(row)
	local name = GetTabUnitInfo(CurTab)
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
		f2.ani.func = HDH_LoadListFrame
		f2.ani.args = {CurTab, row, row+1}
		StartAni(f1, ANI_MOVE_DOWN)
		StartAni(f2 , ANI_MOVE_UP)
		--HDH_LoadListFrame(CurUnit, row, row+1)
	end
	local t = HDH_TRACKER.Get(name)
	if t then t:InitIcons() end
end

function HDH_OnSelectedColor()
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[GetTabUnitInfo(CurTab)]
	else
		option = DB_OPTION
	end
	local t = ColorPickerFrame.arg
	ColorPickerFrame.arg = nil
	if t == 'buff' then
		option.icon.buff_color = {ColorPickerFrame:GetColorRGB()}
		_G[SetFrameContents:GetName().."ButtonColorBuffColor"]:SetTexture(unpack(option.icon.buff_color))
	elseif t== 'debuff' then
		option.icon.debuff_color = {ColorPickerFrame:GetColorRGB()}
		_G[SetFrameContents:GetName().."ButtonColorDebuffColor"]:SetTexture(unpack(option.icon.debuff_color))
	elseif t == 'text' then
		local key = SET_KEY_FONT[FONT_SETTING_INDEX]
		option.font[key.color] = {ColorPickerFrame:GetColorRGB()}
		_G[SetFrameContents:GetName().."ButtonColorTextColor"]:SetTexture(unpack(option.font[key.color]))
	elseif t == 'text5' then
		option.font.textcolor_5s = {ColorPickerFrame:GetColorRGB()}
		_G[SetFrameContents:GetName().."ButtonColorCooldownText5Color"]:SetTexture(unpack(option.font.textcolor_5s))
	end
	
	if CURMODE == MODE_SET_EACH then
		local tracker = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
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

function HDH_OnSelectedColorAlpha()
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[GetTabUnitInfo(CurTab)]
	else
		option = DB_OPTION
	end
	local r,g,b = ColorPickerFrame:GetColorRGB()
	option.icon.cooldown_bg_color = {r, g, b, OpacitySliderFrame:GetValue()}
	_G[SetFrameContents:GetName().."ButtonColorCooldownBgColor"]:SetTexture(unpack(option.icon.cooldown_bg_color))
	
	if CURMODE == MODE_SET_EACH then
		local tracker = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
		if not tracker then return end
		tracker:UpdateSetting()
	else
		HDH_TRACKER.UpdateSettingAll()
	end
	
end

function HDH_OnSelectColorCancel()
	local option
	if CURMODE == MODE_SET_EACH then
		option = DB_OPTION[GetTabUnitInfo(CurTab)]
	else
		option = DB_OPTION
	end
	option.icon.cooldown_bg_color[1] = ColorPickerFrame.previousValues[1]
	option.icon.cooldown_bg_color[2] = ColorPickerFrame.previousValues[2]
	option.icon.cooldown_bg_color[3] = ColorPickerFrame.previousValues[3]
	option.icon.cooldown_bg_color[4] = ColorPickerFrame.previousValues[4]
	_G[SetFrameContents:GetName().."ButtonColorCooldownBgColor"]:SetTexture(unpack(option.icon.cooldown_bg_color))
	
	if CURMODE == MODE_SET_EACH then
		local tracker = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
		if not tracker then return end
		tracker:UpdateSetting()
	else
		HDH_TRACKER.UpdateSettingAll()
	end
end

function HDH_OnCheckShowCooldown(checked)
	local option
	if CURMODE == MODE_SET_EACH then
		local t = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
		if t then
			t.option.icon.show_cooldown = checked
			t:UpdateSetting()
		end
	else
		DB_OPTION.icon.show_cooldown = checked
		HDH_TRACKER.UpdateSettingAll()
	end
end

function HDH_OnCheckedBuff(checked)
	if not GetTabUnitInfo(CurTab) then return end
	DB_OPTION[GetTabUnitInfo(CurTab)].check_buff = checked
	local t = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
	if t then t:Update() end
end

function HDH_OnCheckedDebuff(checked)
	if not GetTabUnitInfo(CurTab) then return end
	DB_OPTION[GetTabUnitInfo(CurTab)].check_debuff = checked
	local t = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
	if t then t:Update() end
end	

function HDH_OnCheckedMine(checked)
	if not GetTabUnitInfo(CurTab) then return end
	DB_OPTION[GetTabUnitInfo(CurTab)].check_only_mine = checked
	local t = HDH_TRACKER.Get(GetTabUnitInfo(CurTab))
	if t then t:Update() end
end

function HDH_OnCheckedPet(checked)
	--DB_OPTION["player"].check_pet = checked
	--HDH_UNIT_AURA("player")
end

function HDH_OnChecked_EachSet(checked)
	local name = GetTabUnitInfo(CurTab)
	local tracker = HDH_TRACKER.Get(name)
	DB_OPTION[name].use_each = checked
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
	tracker:UpdateSetting()
	if UI_LOCK then
		tracker:SetMove(UI_LOCK)
	else
		tracker:InitIcons()
	end
end

function HDH_OnClick_EachSet(self)
	if CURMODE == MODE_SET_EACH then
		HDH_SetModeUI(MODE_LIST)
	else
		HDH_SetModeUI(MODE_SET_EACH)
	end
end

function HDH_OnEnterPressedChangeIcon(self)
	local t2 = _G[self:GetParent():GetName().."Texture2"]
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
		t2:SetTexture(texture)
		self:GetParent().texture = texture
	else
		self:GetParent().texture = nil
		t2:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		print("|cffff0000AuraTracking:Error - |cffffff00알 수 없는 이름(ID) 입니다")
	end
end

function HDH_OnClickChangeIcon(self)
	local t2 = _G[self:GetParent():GetName().."Texture2"]
	local ed = _G[self:GetParent():GetName().."EditBox"]
	local no = tonumber(self:GetParent().no)
	local parent= self:GetParent()
	if not no then 
		print("|cffff0000AuraTracking:Error - |cffffff00아이콘 이미지 변경을 실패하였습니다")
		return parent:Hide() 
	end
	if ListFrame.row and (#ListFrame.row) <= no then 
		print("|cffff0000AuraTracking:Error - |cffffff00아이콘 이미지 변경을 실패하였습니다")
		return parent:Hide() 
	end
	local tabName = GetTabUnitInfo(parent.tab)
	if not tabName then 
		print("|cffff0000AuraTracking:Error - |cffffff00아이콘 이미지 변경을 실패하였습니다")
		return parent:Hide() 
	end
	local data = DB_AURA.Talent[parent.spec][tabName][no]
	if not data then parent:Hide() return end
	if parent.texture then 
		data.Texture = parent.texture
		OptionFrame:Hide()
		OptionFrame:Show()
		parent:Hide()
		local tracker = HDH_TRACKER.Get(tabName)
		if tracker then
			tracker:InitIcons()
		end
	else
		parent.texture = nil
		t2:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		print("|cffff0000AuraTracking:Error - |cffffff00알 수 없는 이름(ID) 입니다")
	end
end

function HDH_OnShowChangeIconFrame(self)
	local t1 = _G[self:GetName().."Texture1"]
	local t2 = _G[self:GetName().."Texture2"]
	local ed = _G[self:GetName().."EditBox"]
	local name = _G[self:GetName().."TextName"]
	_G[self:GetName().."CheckButtonIsItem"]:SetChecked(false)
	local no = tonumber(self.no)
	if not no then return self:Hide() end
	if ListFrame.row and (#ListFrame.row) <= no then return self:Hide() end
	local data = DB_AURA.Talent[self.spec][GetTabUnitInfo(self.tab)][no]
	name:SetText(data.Name)
	t1:SetTexture(data.Texture)
	t2:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	ed:SetText("")
end

function HDH_Option_OnShow(self)
	if not GetSpecialization() then
		print("|cffff0000AuraTracking:Error - |cffffff00직업 전문화를 활성화 해야합니다")
		self:Hide()
		return
	end
	
	self:SetClampedToScreen(true)
	local x = self:GetLeft()
	local y = self:GetBottom()
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", x, y)
	self:SetClampedToScreen(false)
	if self:GetWidth() < FRAME_W then
		self:SetWidth(FRAME_W)
	end
	
	if self:GetHeight() < 410 then
		self:SetHeight(410)
	end
	
	if not DB_AURA or #DB_AURA.Talent == 0 then
		HDH_TRACKER.InitVaribles()
	end
	
	if #DB_FRAME_LIST > 0 then
		HDH_LoadDropDownCooldown()
	end
	HDH_LoadTabSpec()
	HDH_TabUnit_Load()
	HDH_RefrashSettingUI(MODE_SET_ALL)
end

function HDH_Option_OnLoad(self)
	ListFrame = _G[UnitOptionFrame:GetName().."SFContents"]
	self:SetMinResize(self:GetWidth(), 410) 
	self:SetMaxResize(self:GetWidth(), 900)
	SetFrameContents = SettingFrameSFContents
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




