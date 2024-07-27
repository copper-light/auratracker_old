ATC_VERSION = 0.1
ATC = {}

ATC_UI_LOCK = false


------------------------------------
-- load variables
-------------------------------------
function InitVariables()
	local center_x = UIParent:GetWidth()/3
	local center_y = UIParent:GetHeight()/3
	if not DB_OPTION.cooldown or DB_OPTION.cooldown.ATC_VERSION ~= ATC_VERSION then
		DB_OPTION.cooldown = { x    	= center_x, 
							   y    	= center_y+200,  revers_h = false, 
							   revers_v = false,
							   cooldown = 1, -- 1위로, 2아래로 3왼쪽으로 4오른쪽으로 5 원형
							   show_cooldown = true,
							   use_able = true,
							   line     = 10,
							   max_time = 0,
							   icon     = { size 		= 30, 
											margin		= 4, 
											on_alpha	= 1, 
											off_alpha 	= 0.5 },   -- 아이콘 크기
							   font     = { fontsize     = 12,  -- 폰트 사이즈
											countcolor   = {1,1,1},
											textcolor    = {1,1,0},  -- 6초 이상 남았을때, 폰트 색상
											textcolor_5s = {1,0,0}, -- 5초 이하 남았을때, 폰트 색상
											style        = [[fonts\FRIZQT__.ttf]]
										}
							} -- 폰트 종류	
		DB_OPTION.cooldown.ATC_VERSION	= ATC_VERSION
	end
	
	if not DB_AURA.Talent[1].cooldown then
		for i =1, 4 do
			if not DB_AURA.Talent[i] then break end
			DB_AURA.Talent[i].cooldown = {}
		end
	end
end


------------------------------
-- init
------------------------------

function ATC:Create(name)
	self.Frame = CreateFrame("Frame", name, ATC_Frame)
	self.Frame:SetScript("OnUpdate", ATC_OnUpdate_ChackTime)
	self.ICONS = {}
	self:CreateIconSet()
end

function ATC:CreateIconSet()
	setmetatable(self.ICONS, { __index = function(t,k) 
											local f = CreateFrame("CheckButton", "ICON_"..k, self.Frame)
											t[k] = f
											self:FrameBaseSettings(f)
											self:UserCustomFrameSettings(f)
											return f
										end })
end

function ATC:SetData(data)
	self.DATA = data
end

function ATC:SetOption(option)
	self.OPTION = option
end

local cashIcon ={}
function ATC:GetIconByID(id)
	if cashIcon[id] then
		if cashIcon[id].spell and cashIcon[id].spell.id == id then
			return cashIcon[id]
		else
			cashIcon[id] = nil
		end
	end
	if not self.ICONS then return end
	for i=1, #self.ICONS do
		if self.ICONS[i].spell then
			if self.ICONS[i].spell.id == id then
				cashIcon[id] = self.ICONS[i]
				return self.ICONS[i]
			end
		end
	end
	return nil
end

function ATC:InitIcons()
	if not self.DATA then return end
	self.Frame:SetSize(self.OPTION.icon.size,self.OPTION.icon.size)
	self.Frame:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT", self.OPTION.x, self.OPTION.y)
	local spell
	local icon
	local name, spellID, icon, isItem
	for i = 1 , #self.DATA do
		db_spell = self.DATA[i]
		iconFrame = self.ICONS[i]
		name, spellID, icon, isItem = HDH_GetInfo(db_spell.Key or db_spell.ID) -- AT function
		iconFrame.spell = {}
		iconFrame.spell.name = name
		iconFrame.spell.id = tonumber(db_spell.ID)
		iconFrame.spell.fix = db_spell.Fix
		iconFrame.spell.duration = 0
		iconFrame.spell.count = 0
		iconFrame.spell.remaining = 0
		iconFrame.spell.startTime = 0
		iconFrame.spell.endTime = 0
		iconFrame.spell.isItem = (isItem or false)
		iconFrame.icon:SetTexture(icon)
		--[[iconFrame:EnableMouse(true)
		if isItem then
			iconFrame:SetAttribute("type", "item");
			iconFrame:SetAttribute("item", spellID);
		else
			iconFrame:SetAttribute("type", "spell");
			iconFrame:SetAttribute("spell", spellID);
		end]]
		--iconFrame:SetAttribute("type", "spell");
		--iconFrame:SetAttribute("type", "action");
		--iconFrame:SetAttribute("checkselfcast", true);
		--iconFrame:SetAttribute("checkfocuscast", true);
		--iconFrame:SetAttribute("useparent-unit", true);		
		--iconFrame:SetAttribute("useparent-actionpage", true);	
		--iconFrame:SetAttribute("spell", iconFrame.spell.name);
		ATC_RemoveActvationOverlay(iconFrame)
		self:ChangeCooldownType(iconFrame, self.OPTION.cooldown)
		iconFrame:Hide()
	end
		
	for i = #self.DATA+1 , #self.ICONS do
		self.ICONS[i].spell = nil
		self.ICONS[i]:Hide()
	end
end


-----------------------------------
-- update icon
-----------------------------------

function ATC:SetChangeAble(f, value)
	if value then
		if f.icon:IsDesaturated() then f.icon:SetDesaturated(nil) end
		f.icon:SetAlpha(self.OPTION.icon.on_alpha)
		f.border:SetAlpha(self.OPTION.icon.on_alpha)
	else
		if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
		f.icon:SetAlpha(self.OPTION.icon.off_alpha)
		f.border:SetAlpha(self.OPTION.icon.off_alpha)
	end
end

local tmpdelay = 0
function ATC_OnUpdate_ChackTime()
	local cur = GetTime()
	if (cur - tmpdelay) > 3 then
		for i = 1, #ATC.ICONS do
			if ATC.ICONS[i] and ATC.ICONS[i].spell then
				ATC.ICONS[i].spell.remaining = ATC.ICONS[i].spell.endTime - cur
				if ATC.OPTION.max_time ~= 0 and ATC.OPTION.max_time > ATC.ICONS[i].spell.remaining and ATC.ICONS[i].spell.remaining > 0 then
					if ATC:Update_Icon(ATC.ICONS[i]) then
						ATC:Update_Layout()
					end
				end
			end
		end
		tmpdelay = cur
	end
end

--------------------------------------------
-- set icon 
--------------------------------------------

function ATC:FrameBaseSettings(f)
	f:RegisterEvent("ACTIONBAR_UPDATE_STATE");
	f:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
	f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
	f:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	f:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
	f:SetScript("OnEvent",ATC_OnEventIcon)
	
	f:SetFrameStrata('MEDIUM')
	f:SetClampedToScreen(true)
	
	f.icon = f:CreateTexture(nil, 'BACKGROUND')
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	f.icon:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.icon:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	--f.icon:SetVertexColor(1,0,0,1)
	f.border = f:CreateTexture(nil, 'BORDER')
	f.border:SetTexture([[Interface/AddOns/HDH_AuraTracking/border.tga]])
	--f.border:SetVertexColor(1,1,1,1)
	f.border:Hide()
	
	local color = {0.2,0.2,0.2,0.7}
	t = f:CreateTexture(nil,'BORDER')
	t:SetTexture(unpack(color))
	t:SetSize(0,1)
	t:SetPoint("TOPLEFT",f,"TOPLEFT", -1,1)
	t:SetPoint("TOPRIGHT",f,"TOPRIGHT", 1,1)
	
	b = f:CreateTexture(nil,'BORDER')
	b:SetTexture(unpack(color))
	b:SetSize(0,1)
	b:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT", -1,-1)
	b:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 1,-1)
	
	l = f:CreateTexture(nil,'BORDER')
	l:SetTexture(unpack(color))
	l:SetSize(1,0)
	l:SetPoint("TOPLEFT",f,"TOPLEFT",-1,0)
	l:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",-1,0)
	
	r = f:CreateTexture(nil,'BORDER')
	r:SetTexture(unpack(color))
	r:SetSize(1,0)
	r:SetPoint("TOPRIGHT",f,"TOPRIGHT",1,0)
	r:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",1,0)
	
	f.cooldown1 = CreateFrame("StatusBar", nil, f)
	f.cooldown1:SetPoint('LEFT', f, 'LEFT', 0, 0)
	f.cooldown1:SetScript('OnUpdate', ATC_OnUpdateCooldown)
	f.cooldown1:SetStatusBarTexture(0,0,0,0.6)
	f.cooldown1.timetext = f.cooldown1:CreateFontString(nil, 'OVERLAY')
	f.cooldown1:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.cooldown1:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.cooldown1.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', 1, 0)
	f.cooldown1.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 2)
	f.cooldown1.timetext:SetJustifyH('LEFT')
	f.cooldown1.timetext:SetJustifyV('BOTTOM')
	f.cooldown1.timetext:SetNonSpaceWrap(false)
	f.cd = f.cooldown1 -- cooldown 이라는 이름으로 블리자드에서 사용하는데, 필요한거 설정 안하면 이거 때문에 오류 남 그래서 속편하게 cd 변경..
	
	f.cooldown2 = CreateFrame("Cooldown", nil,f)
	f.cooldown2:SetPoint('LEFT', f, 'LEFT', 0,0)
	f.cooldown2:SetScript('OnUpdate', ATC_OnUpdateCooldown)
	f.cooldown2:SetHideCountdownNumbers(true) 
	f.cooldown2:SetSwipeColor(0,0,0,0.6)
	f.cooldown2:SetSwipeTexture(0,0,0)
	f.cooldown2:SetReverse(false)
	f.cooldown2:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f.cooldown2:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.cooldown2.timetext = f.cooldown2:CreateFontString(nil, 'OVERLAY')
	f.cooldown2.timetext:SetPoint('TOPLEFT', f, 'TOPLEFT', -10, -1)
	f.cooldown2.timetext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 10, 0)
	f.cooldown2.timetext:SetNonSpaceWrap(false)
	f.cooldown2.timetext:SetJustifyH('CENTER')
	f.cooldown2.timetext:SetJustifyV('CENTER')
	
	f.counttext = CreateFrame("Frame", nil, f):CreateFontString(nil, 'OVERLAY')
	f.counttext:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 0)
	f.counttext:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f.counttext:SetNonSpaceWrap(false)
	f.counttext:SetJustifyH('RIGHT')
	f.counttext:SetJustifyV('TOP')
end

-- bar 세부 속성 세팅하는 함수 (나중에 option 을 통해 바 값을 변경할수 있기에 따로 함수로 지정해둠)
function ATC:UserCustomFrameSettings(f)
	f:SetSize(self.OPTION.icon.size,self.OPTION.icon.size)
	f:EnableMouse(false)
	f:SetMovable(false)
	
	local icon = f.icon
	f.border:SetWidth(self.OPTION.icon.size*1.3)
	f.border:SetHeight(self.OPTION.icon.size*1.3)
	f.border:SetPoint('CENTER', f, 'CENTER', 0, 0)
	
	local counttext = f.counttext
	counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	counttext:SetTextColor(unpack(self.OPTION.font.countcolor))
	
	local timetext = f.cooldown1.timetext
	timetext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	timetext:SetTextColor(unpack(self.OPTION.font.textcolor))
	timetext = f.cooldown2.timetext
	timetext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	timetext:SetTextColor(unpack(self.OPTION.font.textcolor))
	
	if self.OPTION.show_cooldown then
		f.cooldown2.timetext:Show()
		f.cooldown1.timetext:Show()
	else
		f.cooldown2.timetext:Hide()
		f.cooldown1.timetext:Hide()
	end
end

function ATC:UpdateSetting()
	local f
	if not self.ICONS then return end
	for i=1 , #self.ICONS do
		f = self.ICONS[i]
		self:UserCustomFrameSettings(f)
	end
end

function ATC:ChangeCooldownType(f, cooldown_type)
	if cooldown_type == COOLDOWN_UP then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(true)
		if f.cooldown2:IsShown() then
			f.cooldown2:Hide()
		end
		f.counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_DOWN  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Vertical")
		f.cd:SetReverseFill(false)
		if f.cooldown2:IsShown() then
			f.cooldown2:Hide()
		end
		f.counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_LEFT  then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(false)
		if f.cooldown2:IsShown() then
			f.cooldown2:Hide()
		end
		f.counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	elseif cooldown_type == COOLDOWN_RIGHT then 
		f.cd = f.cooldown1
		f.cd:SetOrientation("Horizontal"); 
		f.cd:SetReverseFill(true)
		if f.cooldown2:IsShown() then
			f.cooldown2:Hide()
		end
		f.counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize, "OUTLINE")
	else 
		f.cd = f.cooldown2
		if f.cooldown1:IsShown() then
			f.cooldown1:Hide()
		end
		f.counttext:SetFont(self.OPTION.font.style, self.OPTION.font.fontsize-2, "OUTLINE") -- 쿨다운이 중앙으로 가면서 폰트가 겹쳐서 살짝 작게 만들어줌 귀차니즘임..
	end
end

--------------------------------------------------
-- move
-------------------------------------------------

-- 바 프레임 이동시키는 플래그 및 이동바 생성+출력
function ATC:MoveFrame(lock)
	local dummy_data_count = 10
	if lock then
		ATC_UI_LOCK = true
		self:SetMoveFrame(true)
		self:CreateDummyIcon(dummy_data_count)
		ATC:Update_Layout()
		--self:UpdateIcons()
	else
		ATC_UI_LOCK = false
		self:RealeseDummyIcon(dummy_data_count)
		self:SetMoveFrame(false)
		self:InitIcons()
		self:UpdateIcons()
	end
end

-- 프레임 이동 시킬때 드래그 시작 콜백 함수
function ATC_OnDragStart(self)
	self:StartMoving()
end

-- 프레임 이동 시킬때 드래그 끝남 콜백 함수
function ATC_OnDragStop(self)
	DB_OPTION["cooldown"].x = self:GetLeft()
	DB_OPTION["cooldown"].y = self:GetBottom()
	self:StopMovingOrSizing()
end

function ATC:SetMoveFrame(move)
	local frame = self.Frame
	if move then
		if not frame.text then
			local tf = CreateFrame("Frame",nil, frame)
			tf:SetFrameStrata("HIGH")
			--tf.SetAllPoints(frame)
			local text = tf:CreateFontString(nil, 'OVERLAY')
			frame.text = text
			text:ClearAllPoints()
			text:SetFont(self.OPTION.font.style, 12, "THICKOUTLINE")
			text:SetTextColor(1,0,0)
			text:SetWidth(150)
			text:SetHeight(70)
			text:SetPoint("BOTTOM", frame, "CENTER", 0,0)
			text.text = ("|cffffff00[%s]\n |cffff0000Move this icon\n|\nV"):format(frame:GetName():upper())
			text:SetMaxLines(6) 
		end
		frame.text:Show()
		frame:SetScript('OnDragStart', ATC_OnDragStart)
		frame:SetScript('OnDragStop', ATC_OnDragStop)
		frame:SetScript('OnUpdate', OnDragUpdate)
		frame:RegisterForDrag('LeftButton')
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:Show()
	else
		frame:EnableMouse(false)
		frame:SetMovable(false)
		frame:SetScript('OnUpdate', ATC_OnUpdate_ChackTime)
		if frame.text then frame.text:Hide() end
	end
end

function ATC:CreateDummyIcon(count)
	local line = self.OPTION.line or 10-- 한줄에 몇개의 아이콘 표시
	local size = self.OPTION.icon.size + self.OPTION.icon.margin -- 아이콘 간격 띄우는 기본값
	local revers_v = self.OPTION.revers_v -- 상하반전
	local revers_h = self.OPTION.revers_h -- 좌우반전
	local cooldown_type = self.OPTION.cooldown
	local use_able = self.OPTION.use_able
	for i=1, count do
		--AllFrameVisible(true)
		f = self.ICONS[i]
		f.icon:SetTexture("Interface\\ICONS\\TEMP")
		if not f.spell or not f.spell.isDummy then 
		--f:ClearAllPoints()
			local spell = {}
			spell.isDummy = true
			spell.name = name
			spell.icon = icon
			spell.fix = true
			spell.id = 0
			spell.count = i
			spell.duration = i * i
			spell.startTime = GetTime()
			spell.endTime = spell.startTime+ spell.duration
			spell.remaining = spell.endTime -spell.startTime
			f.spell = spell
		end
		
		self:ChangeCooldownType(f, cooldown_type)
		if f.spell.count < 1 then f.counttext:SetText(nil)
					 else f.counttext:SetText(f.spell.count) end
		if f.spell.duration == 0 then f.cd:Hide()
								 else f.cd:Show() end
		if cooldown_type == COOLDOWN_CIRCLE then
			f.cd:SetCooldown(f.spell.startTime, f.spell.duration or 0)
		else
			f.cd:SetMinMaxValues(f.spell.startTime, f.spell.endTime)
		end
		if not f:IsShown() then f:Show() end
		
		if i == 1 then
			self:SetChangeAble(f, use_able)
		else
			self:SetChangeAble(f, use_able == false)
		end
	end
end

function ATC:RealeseDummyIcon(count)
	for i=1, count do
		f = self.ICONS[i]
		if f.spell then f.spell = nil end
	end
end


-----------------------------------------------------------------------------
-- icon 정보 업데이트 그리기
-----------------------------------------------------------------------------

-- 매 프레임마다 bar frame 그려줌, 콜백 함수
function ATC_OnUpdateCooldown(self)
	local spell = self:GetParent().spell
	if not spell then self:Hide() end
	spell.remaining = spell.endTime - GetTime()

	if spell.remaining > 0.0 and spell.duration > 0 then
		if spell.remaining > 6 then
			--self.bar:SetTexture(0,0,0,0.75)
			self.timetext:SetTextColor(unpack(ATC.OPTION.font.textcolor))
		else 
			--self.bar:SetTexture(1,0.1,0.1,0.4)
			self.timetext:SetTextColor(unpack(ATC.OPTION.font.textcolor_5s))
		end
		if spell.remaining > 60 then
			self.timetext:SetText(('%d:%02d'):format((spell.remaining)/60,spell.remaining%60))
		else
			self.timetext:SetText(('%d'):format(spell.remaining+1))
		end
		if  ATC.OPTION.cooldown ~= COOLDOWN_CIRCLE then
			self:SetValue(spell.startTime+spell.remaining)
		end
	else
		self:Hide()
		ATC:SetChangeAble(self:GetParent(), ATC.OPTION.use_able)
		ATC:Update_Layout()
	end
	--self.icon:SetTexCoord(.08, .92, .08, .92)
end

function ATC:UpdateIcons()
	for i = 1 , #self.ICONS do
		self:Update_Icon(self.ICONS[i])
	end
	self:Update_Layout()
end

function ATC:Update_Layout()
	if not self.OPTION or not self.ICONS then return end
	local f, spell
	local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
	local line = self.OPTION.line or 10-- 한줄에 몇개의 아이콘 표시
	local size = self.OPTION.icon.size + self.OPTION.icon.margin -- 아이콘 간격 띄우는 기본값
	local revers_v = self.OPTION.revers_v -- 상하반전
	local revers_h = self.OPTION.revers_h -- 좌우반전
	local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	
	for i = 1 , #self.ICONS do
		f = self.ICONS[i]
		if f and f.spell then
			if f:IsShown() then
				f:ClearAllPoints()
				f:SetPoint('RIGHT', self.Frame, 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				show_index = show_index+ 1
				if show_index % line == 0 then row = row + size; col = 0
										  else col = col + size end
			end
			if f.spell.remaining > 0 then ret = ret + 1 end -- 비전투라도 쿨이 돌고 잇는 스킬이 있으면 화면에 출력하기 위해서 체크함
		end
	end
	if ATC_UI_LOCK then return false end
	if ret == 0 and not self.OPTION.always_show and not UnitAffectingCombat("player") then 
		if self.Frame:IsShown() then self.Frame:Hide() end
	else
		if not self.Frame:IsShown() then self.Frame:Show() end
	end
end

function ATC:Update_CountAndCooldown(f)
	local option = self.OPTION
	local spell
	if not f or not f.spell or not option then return end
	spell = f.spell
	spell.isCharging = false
	local count, maxCharges, startTime, duration = GetSpellCharges(spell.id) -- 스킬의 중첩count과 충전charge은 다른 개념이다. 
	if count then -- 충전류 스킬 (ex구르기
		spell.count = count
		if count ~= maxCharges and duration > 2 then
			spell.duration = duration
			spell.startTime = startTime
			spell.endTime = spell.startTime + spell.duration
			spell.remaining = spell.endTime - GetTime()
			if count > 0 then spell.isCharging = true end
		else
			spell.duration = 0
			spell.startTime = 0
			spell.remaining  = -1
		end
	else	
		if spell.isItem then
			startTime, duration = GetItemCooldown(spell.id)
			spell.count = GetItemCount(spell.id) or 0
		else
			startTime, duration = GetSpellCooldown(spell.id)
			spell.count = GetSpellCount(spell.id) or 0
		end
		spell.duration = duration
		spell.startTime = startTime
		spell.endTime = spell.startTime + spell.duration
		spell.remaining = spell.endTime - GetTime()
	end
end

function ATC:Update_Usable(f)
	local option = self.OPTION
	local spell
	if not f or not f.spell or not option then return end
	spell = f.spell
	
	if spell.isItem then
		spell.isAble = IsUsableItem(spell.id)
	else
		local isAble, isNotEnoughMana = IsUsableSpell(spell.id)
		spell.isAble = isAble or isNotEnoughMana -- 사용 불가능인데, 마나 때문이라면 -> 사용 가능한 걸로 본다.
	end
end

function ATC:Update_Icon(f)
	--if ATC_UI_LOCK then return false end
	local option = self.OPTION
	local spell
	if not f or not f.spell or not option then return end
	
	self:Update_Usable(f)
	self:Update_CountAndCooldown(f)
	
	spell = f.spell
	if ((spell.duration > 2) or not spell.isAble) and not spell.isCharging then -- 글로버 쿨다운 2초  무시
		if not self.Frame:IsShown() then self.Frame:Show() end
		if (option.max_time == 0 and spell.fix) or 
			(option.max_time > spell.remaining or spell.fix) then
			if f.spell.count < 2 then f.counttext:SetText(nil)
								 else f.counttext:SetText(f.spell.count ) end
			if f.spell.duration <= 2 then 	f.cd:Hide()
								     else 	f.cd:Show()
											if (option.cooldown == COOLDOWN_CIRCLE) 
												then f.cd:SetCooldown(spell.startTime, spell.duration or 0) f.cd:SetDrawSwipe(true) 
												else f.cd:SetMinMaxValues(spell.startTime, spell.endTime) end
			end
			self:SetChangeAble(f, option.use_able == false)
			if not f:IsShown() then f:Show() return true end
		else
			if f:IsShown() then f:Hide() return true end
		end
	else -- 쿨 안도는 중
		if spell.isCharging then
			if not f.cd:IsShown() then f.cd:Show() end
			spell.endTime = spell.startTime + spell.duration
			spell.remaining = spell.endTime - GetTime()
			if (option.cooldown == COOLDOWN_CIRCLE)
				then f.cd:SetCooldown(f.spell.startTime, f.spell.duration or 0) f.cd:SetDrawSwipe(false)
				else f.cd:SetMinMaxValues(0, 0) end	
		else
			if f.cd:IsShown() then f.cd:Hide() end
		end
		self:SetChangeAble(f, option.use_able)
		if f.spell.count < 2 then f.counttext:SetText(nil)
							 else f.counttext:SetText(f.spell.count ) end
		if not f:IsShown() then f:Show() return true end
	end
	return false
end

function ATC_RemoveActvationOverlay(f)
	if f.overlay then
		if ( f.overlay.animIn:IsPlaying() ) then
			f.overlay.animIn:Stop();
		end
		f.overlay.animOut:Play();
		f.overlay = nil
	end	
end

function ATC_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(f, id)
	if f and f.spell and f.spell.id == id then
		if not f.overlay then
			f.overlay = CreateFrame("Frame", "overlay"..id, f, "ActionBarButtonSpellActivationAlert");
			--f.overlay:SetParent(f.cooldown2); 
			f.overlay:SetPoint("TOPLEFT", f, "TOPLEFT", -f:GetWidth() * 0.2, f:GetHeight() * 0.2);
			f.overlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", f:GetWidth() * 0.2, -f:GetHeight() * 0.2);
		end
		if ( f.overlay.animOut:IsPlaying() ) then
			f.overlay.animOut:Stop();
		end
		f.overlay.animIn:Play();
	end
end

function ATC_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(f, id)
	if f and f.spell and f.spell.id == id then
		if not f.overlay then return end
		
		if ( f.overlay.animIn:IsPlaying() ) then
			f.overlay.animIn:Stop();
		end
		if ( f:IsShown() ) then
			f.overlay.animOut:Play();
		end
	end
end

function ATC_PLAYER_ENTERING_WORLD()
	InitVariables()
	
	ATC:Create("cooldown")
	ATC:SetData(DB_AURA.Talent[GetSpecialization() or 1].cooldown)
	ATC:SetOption(DB_OPTION.cooldown)
	ATC:InitIcons()
	ATC:UpdateIcons()
	
	--self:
	ATC_Frame:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	--ATC_Frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW");
	--ATC_Frame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE");
end
--[[
function ATC:UpdateIcons()
	if not self.OPTION or not self.ICONS then return end
	local f, spell
	local startTime, duration
	local ret = 0 -- 쿨이 도는 스킬의 갯수를 체크하는것
	local line = self.OPTION.line or 10-- 한줄에 몇개의 아이콘 표시
	local size = self.OPTION.icon.size + self.OPTION.icon.margin -- 아이콘 간격 띄우는 기본값
	local revers_v = self.OPTION.revers_v -- 상하반전
	local revers_h = self.OPTION.revers_h -- 좌우반전
	local cooldown_type = self.OPTION.cooldown
	local use_able = self.OPTION.use_able
	local maxTime = self.OPTION.max_time
	local show_index = 0 -- 몇번째로 아이콘을 출력했는가?
	local col = 0  -- 열에 대한 위치 좌표값 = x
	local row = 0  -- 행에 대한 위치 좌표값 = y
	local isAble
	local isNotEnoughMana
	local maxCharges, count
	local isCharging
	
	for i = 1 , #self.ICONS do
		f = self.ICONS[i]
		if f and f.spell then
			spell = f.spell
			isCharging = false
			if not ATC_UI_LOCK then
				count, maxCharges, startTime, duration = GetSpellCharges(spell.id) -- 스킬의 중첩count과 충전charge은 다른 개념이다. 
				if count then -- 충전류 스킬 (ex구르기
					spell.count = count
					if count ~= maxCharges then
						spell.duration = duration
						spell.startTime = startTime
						spell.endTime = spell.startTime + spell.duration
						spell.remaining = spell.endTime - GetTime()
						if count > 0 then isCharging = true end
					else
						spell.duration = 0
						spell.startTime = 0
						spell.remaining  = 0
					end
				else -- 중첩류 스킬 (ex 호안주) + 일반 스킬 
					if spell.isItem then
						startTime, duration = GetItemCooldown(spell.id)
						spell.count = GetItemCount(spell.id) or 0
					else
						startTime, duration = GetSpellCooldown(spell.id)
						spell.count = GetSpellCount(spell.id) or 0
					end
					spell.duration = duration
					spell.startTime = startTime
					spell.endTime = spell.startTime + spell.duration
					spell.remaining = spell.endTime - GetTime()
				end
			end
			if spell.isItem then
				isAble = IsUsableItem(spell.id)
			else
				isAble, isNotEnoughMana = IsUsableSpell(spell.id)
				isAble = isAble or isNotEnoughMana -- 사용 불가능인데, 마나 때문이라면 -> 사용 가능한 걸로 본다.
			end
			
		else
			break
		end
	end
	if ret == 0 and not self.OPTION.always_show and not UnitAffectingCombat("player") then 
		self.Frame:Hide()
	else
		self.Frame:Show()
	end
	--return ret
end
]]


function ATC_OnEventIcon(this,event,...)
	if event == "ACTIONBAR_UPDATE_STATE" then -- 층전, 중첩  변경
		if not ATC_UI_LOCK and ATC:Update_Icon(this) then
			ATC:Update_Layout(this)
		end
	elseif event == "ACTIONBAR_UPDATE_USABLE" then
		if  not ATC_UI_LOCK and ATC:Update_Icon(this) then
			ATC:Update_Layout(this)
		end
	elseif event == "ACTIONBAR_UPDATE_COOLDOWN" then
		if  not ATC_UI_LOCK and ATC:Update_Icon(this) then
			ATC:Update_Layout(this)
		end
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" then
		ATC_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(this,...)
	elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" then
		ATC_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(this,...)
	end
end

function ATC_OnEvent(this,event,...)
	if event == "PLAYER_REGEN_DISABLED" then 
		if ATC.Frame and not ATC.Frame:IsShown() then
			ATC.Frame:Show()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then 
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		ATC:SetData(DB_AURA.Talent[GetSpecialization() or 1].cooldown)
		ATC:SetOption(DB_OPTION.cooldown)
		ATC:InitIcons()
		--ATC:UpdateIcons()
	elseif event == "PLAYER_ENTERING_WORLD" then
		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
		C_Timer.After(2, ATC_PLAYER_ENTERING_WORLD) -- GET_ITEM_INFO_RECEIVED 이게 이상하게 일은 안해서.. 2초 딜레이후에 아이템 데이터들 가져옴
	end
end	


ATC_Frame = CreateFrame("Frame")
ATC_Frame:RegisterEvent('PLAYER_ENTERING_WORLD')
ATC_Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
ATC_Frame:RegisterEvent('PLAYER_REGEN_ENABLED')
ATC_Frame:SetScript("OnEvent", ATC_OnEvent)
--hooksecurefunc("HDH_UpdateSetting", test)

function ATC_Frame:GET_ITEM_INFO_RECEIVED()
	--print("GET_ITEM_INFO_RECEIVED")
end

