CT_VERSION = 0.1
HDH_HEALTH_TRACKER = {}

local POWRE_BAR_SPLIT_MARGIN = 5;
local MyClassKor, MyClass = UnitClass("player");

-- local POWRE_NAME = {}
local L_HEALTH = "체력";

local HDH_POWER = {}
HDH_HEALTH_TRACKER.DATA = {type_name="HEALTH", bar_color={0, 1, 0}, texture = "Interface\\Icons\\Ability_Malkorok_BlightofYshaarj_Green"};

HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = L_HEALTH -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
HDH_GET_CLASS[L_HEALTH] = HDH_HEALTH_TRACKER -- 
HDH_GET_CLASS_NAME[L_HEALTH] = "HDH_HEALTH_TRACKER";

------------------------------------
do -- HDH_HEALTH_TRACKER class
------------------------------------
	setmetatable(HDH_HEALTH_TRACKER, HDH_POWER_TRACKER) -- 상속
	HDH_HEALTH_TRACKER.__index = HDH_HEALTH_TRACKER
	local super = HDH_POWER_TRACKER;

	local function HDH_HEALTH_TRACKER_OnUpdate(self)
		self.spell.curTime = GetTime()
		
		if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
		self.spell.delay = self.spell.curTime
		local curValue = UnitHealth('player') or 0;
		local health_max = UnitHealthMax("player");
		local per = curValue/health_max;
		-- print(self.spell.v1 ,curValue)
		-- if (tonumber(self.v1:GetText()) or 0) == curValue then return; end
		self.spell.v1 = curValue;
		self.spell.count = (per * 100)
		self.counttext:SetText(format("%d%%", math.ceil(self.spell.count))); 
		
		if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1)); else self.v1:SetText(nil) end
		
		-- if self.bar then self.bar:SetValue(self.spell.v1); end
		
		if not UnitIsDead("player") and self.spell.v1 < health_max then
			if self.spell.isOn ~= true then
				self:GetParent().parent:Update();
				self.spell.isOn = true;
			end
		else
			if self.spell.isOn ~= false then
				self:GetParent().parent:Update();
				self.spell.isOn = false;
			end
		end
		
		self:GetParent().parent:SetGlow(self, true);
		
		if self.bar then
			-- self.bar.absorb:Show();
			if self.bar.max ~= health_max then -- UpdateBar 함수안에 UpdateAbsorb 를 포함한다.
				self:GetParent().parent:UpdateBar(self, health_max); 
			else
				self:GetParent().parent:UpdateAbsorb(self, health_max);
			end
		end
		self:GetParent().parent:UpdateBarValue(self);
	end
			
	function HDH_HEALTH_TRACKER:CreateData(spec)
		if spec and DB_AURA.Talent[spec] then
			local new = {}		
			new.Key = HDH_HEALTH_TRACKER.DATA.type_name;
			new.Name = HDH_HEALTH_TRACKER.DATA.type_name;
			new.Texture = HDH_HEALTH_TRACKER.DATA.texture;
			new.defaultImg = new.Texture;
			new.ShowValue = true;
			new.No = 1
			new.ID = 0
			new.Always = true
			new.Glow = true
			new.IsItem = false
			DB_AURA.Talent[spec][self.name][1] = new;
			
			if not DB_OPTION[self.name].use_each then
				DB_OPTION[self.name].icon = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.icon, DB_OPTION[self.name].icon);
				DB_OPTION[self.name].font = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.font, DB_OPTION[self.name].font);
				DB_OPTION[self.name].bar = HDH_AT_UTIL.CheckToUpdateDB(DB_OPTION.bar, DB_OPTION[self.name].bar);
				self.option.icon = DB_OPTION[self.name].icon
				self.option.font = DB_OPTION[self.name].font
				self.option.bar = DB_OPTION[self.name].bar;
			end
			DB_OPTION[self.name].use_each = true;
			DB_OPTION[self.name].bar.enable = true;
			DB_OPTION[self.name].bar.color = {unpack(HDH_HEALTH_TRACKER.DATA.bar_color)};
			DB_OPTION[self.name].bar.full_color = {unpack(HDH_HEALTH_TRACKER.DATA.bar_color)};
			DB_OPTION[self.name].bar.location = HDH_TRACKER.BAR_LOCATION_R;
			DB_OPTION[self.name].bar.height = 30
			DB_OPTION[self.name].bar.width = 200
			DB_OPTION[self.name].bar.show_name = false;
			DB_OPTION[self.name].icon.hide_icon = false;
			DB_OPTION[self.name].icon.size = 30;
			DB_OPTION[self.name].font.count_location = HDH_TRACKER.FONT_LOCATION_BAR_L;
			DB_OPTION[self.name].font.v1_location = HDH_TRACKER.FONT_LOCATION_BAR_R;
		end
		self:UpdateSetting();
	end
	
	function HDH_HEALTH_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local data = DB_AURA.Talent[spec][self.name][1];
			if data and string.find(data.Key, HDH_HEALTH_TRACKER.DATA.type_name) then
				return 1;
			end
		end
		return false;
	end
	
	function HDH_HEALTH_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local f, spell
		local health_max = UnitHealthMax("player");
		f = icons[1];
		f:SetMouseClickEnabled(false);
		if not f:GetParent() then f:SetParent(self.frame) end
		if f.icon:GetTexture() == nil then
			f.icon:SetTexture(HDH_HEALTH_TRACKER.DATA.texture);
		end
		f:ClearAllPoints()
		spell = {}
		spell.always = true
		spell.id = 0
		spell.count = 100
		spell.duration = 0
		spell.happenTime = 0;
		spell.glow = false
		spell.endTime = 0
		spell.startTime = 0
		spell.remaining = 0
		spell.showValue = true
		spell.v1 = health_max
		spell.max = health_max;
		f.cd:Hide();
		if self.option.bar.enable and f.bar then
			f:SetScript("OnUpdate",nil);
			-- f.bar:SetMinMaxValues(0, power_max);
			-- f.bar:SetValue(spell.v1);
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1));
			-- f.bar:Show();
			local bar
			for i = 1, #f.bar.bar do
				bar = f.bar.bar[i];
				if bar then
					bar:SetMinMaxValues(0,1);
					bar:SetValue(1);
				end
			end
		end
		f.spell = spell
		f.counttext:SetText("100%")
		f.icon:SetAlpha(option.icon.on_alpha)
		f.border:SetAlpha(option.icon.on_alpha)
		self:SetGameTooltip(f, false)
		f:Show()
		return 1;
	end
	
	function HDH_HEALTH_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
	end
	
	local s2 = sqrt(2);
	local cos, sin, rad = math.cos, math.sin, math.rad;
	local function CalculateCorner(angle)
		local r = rad(angle);
		return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
	end
	
	local function RotateTexture(texture, angle)
        local LRx, LRy = CalculateCorner(angle + 45);
        local LLx, LLy = CalculateCorner(angle + 135);
        local ULx, ULy = CalculateCorner(angle + 225);
        local URx, URy = CalculateCorner(angle - 45);
        
        texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
	end
	
	function HDH_HEALTH_TRACKER:UpdateAbsorb(f, health_max)
		local healthBar = f.bar.bar[1];
		local totalAbsorb = UnitGetTotalAbsorbs('player') or 0;
		local absorb_f = f.bar.absorb;
		local overlay_f = f.bar.absorb.overlay;
		-- print((totalAbsorb/health_max) * self.bar:GetWidth())
		if absorb_f and overlay_f then
			if totalAbsorb == 0 then 
				if absorb_f:IsShown() then absorb_f:Hide(); overlay_f:Hide() end
			else
				if healthBar:GetOrientation() == "HORIZONTAL" then
					RotateTexture(absorb_f,0);
					absorb_f:SetSize((totalAbsorb/health_max) * healthBar:GetWidth(), healthBar:GetHeight());
				else
					RotateTexture(absorb_f,90);
					absorb_f:SetSize(healthBar:GetWidth(),(totalAbsorb/health_max) * healthBar:GetHeight());
				end
				-- absorb_f:SetScale(1+(1-math.pow(2,-0.5)));
				if not absorb_f:IsShown() then absorb_f:Show(); overlay_f:Show() end
				-- absorb_f:SetWidth();
				absorb_f:ClearAllPoints();
				curValue = healthBar:GetValue();
				if totalAbsorb + curValue < health_max then
					if self.option.bar.reverse_progress then
						if healthBar:GetOrientation() == "HORIZONTAL" then
							absorb_f:SetPoint("RIGHT", healthBar,"RIGHT", -(curValue/health_max) * healthBar:GetWidth(),0);
						else
							absorb_f:SetPoint("TOP", healthBar,"TOP", 0, (curValue/health_max) * healthBar:GetHeight());
						end
					else
						if healthBar:GetOrientation() == "HORIZONTAL" then
							absorb_f:SetPoint("LEFT", healthBar,"LEFT", (curValue/health_max) * healthBar:GetWidth(),0);
						else
							absorb_f:SetPoint("BOTTOM", healthBar,"BOTTOM", 0, (curValue/health_max) * healthBar:GetHeight());
						end
					end
				else
					if self.option.bar.reverse_progress then
						if healthBar:GetOrientation() == "HORIZONTAL" then
							absorb_f:SetPoint("LEFT", healthBar,"LEFT", 0,0);
						else
							absorb_f:SetPoint("BOTTOM", healthBar,"BOTTOM", 0,0);
						end
					else
						if healthBar:GetOrientation() == "HORIZONTAL" then
							absorb_f:SetPoint("RIGHT", healthBar,"RIGHT", 0, 0);
						else
							absorb_f:SetPoint("TOP", healthBar,"TOP", 0, 0);
						end
					end
				end
			end
		end
	end
	
	function HDH_HEALTH_TRACKER:UpdateBar(f, barMax)
		barMax = barMax or UnitHealthMax("player");
		super.UpdateBar(self, f, barMax);
		local healthBar;
		if f.bar and f.bar.bar then healthBar = f.bar.bar[1]; end
		if healthBar then
			if f.bar.absorb == nil then 
				local absorb = healthBar:CreateTexture(nil, "OVERLAY"); 
				-- absorb:SetTexture([[Interface\RaidFrame\Shield-Fill.blp]]);
				
				absorb:SetVertexColor(1,1,1);
				local overlay = healthBar:CreateTexture(nil, "OVERLAY",nil,1); 
				overlay:SetTexture("Interface\\RaidFrame\\Shield-Overlay",true,true);
				overlay:SetVertTile(true) 
				overlay:SetHorizTile(true)
				overlay:SetAllPoints(absorb);
				f.bar.absorb = absorb; 
				f.bar.absorb.overlay = overlay; 
				f.bar.absorb:SetTexture("Interface\\RaidFrame\\Shield-fill");
			end
			-- f.bar.absorb:SetTexture(HDH_TRACKER.BAR_TEXTURE[self.option.bar.texture].texture);
			self:UpdateAbsorb(f, barMax);
		end
	end
	
	function HDH_HEALTH_TRACKER:UpdateIcons()  -- HDH_TRACKER override
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local f = self.frame.icon[1]
		if f == nil or f.spell == nil then return end;
		if f.spell.v1 > 0 then 
			f.icon:SetDesaturated(nil)
			f.icon:SetAlpha(self.option.icon.on_alpha)
			f.border:SetAlpha(self.option.icon.on_alpha)
			f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
			ret = 1;
			self:SetGlow(f, true)
			f:Show();
			if self.option.bar.enable and f.bar then
				self:UpdateBarValue(f);
				f.bar:Show();
				-- f.name:SetText(f.spell.name);
			end
		else
			if f.spell.always then
				f.icon:SetDesaturated(1)
				f.icon:SetAlpha(self.option.icon.off_alpha)
				f.border:SetAlpha(self.option.icon.off_alpha)
				f.border:SetVertexColor(0,0,0)
				self:SetGlow(f, false)
				f:Show();
			else
				f:Hide();
			end
		end
		f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0);
		return ret
	end

	function HDH_HEALTH_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or UI_LOCK then return end
		local f = self.frame.icon[1]
		local show
		if f and f.spell then
			-- f.spell.type = UnitPowerType('player');
			f.spell.v1 = UnitHealth('player') or 0;
			f.spell.max = UnitHealthMax('player');
			f.spell.count = (f.spell.v1/f.spell.max * 100);
			self:UpdateIcons()
			if f.spell.v1 < f.spell.max and not UnitIsDead("player") then show = true end
		end
		if UI_LOCK or self.option.icon.always_show or UnitAffectingCombat("player") or show then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	function HDH_HEALTH_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID
		local spell 
		local f
		local iconIdx = 0;
		-- local isBuff = (self.type == L_BUFF);
		self.frame.pointer = {}
		
		
		for i = 1, #auraList do
			if not self:IsIgnoreSpellByTalentSpell(auraList[i]) then
				iconIdx = iconIdx + 1
				f = self.frame.icon[iconIdx]
				if f:GetParent() == nil then f:SetParent(self.frame) end
				self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = f -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
				spell = {}
				spell.glow = auraList[i].Glow
				spell.glowCount = auraList[i].GlowCount
				spell.glowV1= auraList[i].GlowV1
				spell.always = auraList[i].Always
				spell.showValue = auraList[i].ShowValue -- 수치표시
				spell.v1_hp =  auraList[i].v1_hp -- 수치 체력 단위표시
				spell.v1 = 0 -- 수치를 저장할 변수
				spell.aniEnable = true;
				spell.aniTime = 8;
				spell.aniOverSec = false;
				spell.no = auraList[i].No
				spell.name = auraList[i].Name
				spell.icon = auraList[i].Texture
				if not auraList[i].defaultImg then auraList[i].defaultImg = auraList[i].Texture; 
				elseif auraList[i].defaultImg ~= auraList[i].Texture then spell.fix_icon = true end
				spell.id = tonumber(auraList[i].ID)
				spell.count = 0
				spell.duration = 0
				spell.remaining = 0
				spell.overlay = 0
				spell.endTime = 0
				spell.is_buff = isBuff;
				spell.isUpdate = false
				spell.isItem =  auraList[i].IsItem
				f.spell = spell
				f.icon:SetTexture(auraList[i].Texture or "Interface\\ICONS\\INV_Misc_QuestionMark")
				self:ChangeCooldownType(f, self.option.base.cooldown)
				self:SetGlow(f, false)
				
				spell.startSound = auraList[i].StartSound
				spell.endSound = auraList[i].EndSound
				spell.conditionSound = auraList[i].ConditionSound
				if spell.startSound then
					f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
					f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
				end
				if spell.endSound then
					f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
					f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
				end
				f:SetScript("OnUpdate", HDH_HEALTH_TRACKER_OnUpdate)
			end
		end
		for i = #(self.frame.icon) ,iconIdx+1, -1  do
			self:ReleaseIcon(i)
		end
		
		self.frame:SetScript("OnEvent", OnEventTracker)
		self.frame:UnregisterAllEvents()
		
		if #(self.frame.icon) <= 0 then
		else
			return 
		end
		
		self:Update()
	end
	
	function HDH_HEALTH_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
		-- self:UpdateBar(self.frame.icon[1]);
	end
	
	function HDH_HEALTH_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_HEALTH_TRACKER:OnEvent(event, unit, powerType)
		if self == nil or self.parent == nil then return end
		if (event == 'UNIT_MAXHEALTH')then  -- (event == "UNIT_POWER")
		end
	end
------------------------------------
end -- HDH_HEALTH_TRACKER class
------------------------------------