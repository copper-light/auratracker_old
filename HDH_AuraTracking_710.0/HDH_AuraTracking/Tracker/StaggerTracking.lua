HDH_STAGGER_TRACKER = {}
local MyClassKor, MyClass = UnitClass("player");
local TrackerTypeName = "양조:시간차";
local HDH_POWER = {}
local HDH_STAGGER_KEY = "STAGGER";
do
	local info = PowerBarColor[HDH_STAGGER_KEY];
	HDH_STAGGER = {green_texture = "Interface\\Icons\\Priest_icon_Chakra_green", green_color  = {info[STAGGER_GREEN_INDEX].r, info[STAGGER_GREEN_INDEX].g, info[STAGGER_GREEN_INDEX].b},
				   yellow_texture = "Interface\\Icons\\Priest_icon_Chakra", 	 yellow_color = {info[STAGGER_YELLOW_INDEX].r, info[STAGGER_YELLOW_INDEX].g, info[STAGGER_YELLOW_INDEX].b},
				   red_texture = "Interface\\Icons\\Priest_icon_Chakra_red",     red_color    = {info[STAGGER_RED_INDEX].r, info[STAGGER_RED_INDEX].g, info[STAGGER_RED_INDEX].b},
	}
	HDH_STAGGER_TRACKER.STAGGER = HDH_STAGGER;
 end

if MyClass == "MONK" then 
	HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = TrackerTypeName -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
	HDH_GET_CLASS[TrackerTypeName] = HDH_STAGGER_TRACKER -- 
	HDH_GET_CLASS_NAME[TrackerTypeName] = "HDH_STAGGER_TRACKER";
end

------------------------------------
do -- HDH_STAGGER_TRACKER class
------------------------------------
	setmetatable(HDH_STAGGER_TRACKER, HDH_POWER_TRACKER) -- 상속
	HDH_STAGGER_TRACKER.__index = HDH_STAGGER_TRACKER;
	local super = HDH_POWER_TRACKER;

	local function STAGGER_TRACKER_OnUpdate(self)
		self.spell.curTime = GetTime()
		
		if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
		self.spell.delay = self.spell.curTime
		local curValue = UnitStagger('player') or 0;
		local health_max = UnitHealthMax("player");
		local per = curValue/health_max;
		-- print(self.spell.v1 ,curValue)
		-- if (tonumber(self.v1:GetText()) or 0) == curValue then return; end
		self.spell.v1 = curValue;
		self.spell.count = (per * 100)
		self.counttext:SetText(format("%d%%", math.ceil(self.spell.count))); 
		
		if per > STAGGER_RED_TRANSITION then
			self.icon:SetTexture(HDH_STAGGER_TRACKER.STAGGER.red_texture);
		elseif per > STAGGER_YELLOW_TRANSITION then
			self.icon:SetTexture(HDH_STAGGER_TRACKER.STAGGER.yellow_texture);
		else
			self.icon:SetTexture(HDH_STAGGER_TRACKER.STAGGER.green_texture);
		end
		
		if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1,true)); else self.v1:SetText(nil) end
		
		-- if self.bar then self.bar:SetValue(self.spell.v1); end
		
		if self.spell.v1 > 0 then
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
		
		if self.bar and self.bar.max ~= health_max then
			self:GetParent().parent:UpdateBar(self, health_max);
		end
		self:GetParent().parent:UpdateBarValue(self);
	end
	
	-- STAGGER_YELLOW_TRANSITION = .30
	-- STAGGER_RED_TRANSITION = .60
	-- function HDH_STAGGER_TRACKER:UpdateBarValue(f)
		-- if f.bar and #f.bar.bar > 0 then
			-- local bar;
			-- for i = 1, #f.bar.bar do 
				-- bar = f.bar.bar[i];
				-- if bar then 
					-- bar:SetValue(self:GetAnimatedValue(bar,f.spell.v1,i)); 
					-- if f:GetParent().parent.option.bar.use_full_color then
						-- if f.spell.v1 >= (bar.mpMax) then
							-- bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.full_color));
						-- else
							-- bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.color));
						-- end
					-- end
					-- if self.option.bar.show_spark then
						-- if bar:GetValue() >= bar.mpMax then value = 1; if bar.spark:IsShown() then bar.spark:Hide(); end
						-- elseif bar:GetValue()<= bar.mpMin then value = 0; if bar.spark:IsShown() then bar.spark:Hide(); end
						-- else
							-- value = (bar:GetValue()-bar.mpMin)/(bar.mpMax - bar.mpMin);
							-- if not bar.spark:IsShown() then bar.spark:Show(); end
						-- end
						-- if bar:GetOrientation() == "HORIZONTAL" then
							-- if self.option.bar.reverse_progress then
								-- bar.spark:SetPoint("CENTER", bar,"RIGHT", -bar:GetWidth() * value, 0);
							-- else
								-- bar.spark:SetPoint("CENTER", bar,"LEFT", bar:GetWidth() * value, 0);
							-- end
						-- else
							-- if self.option.bar.reverse_progress then
								-- bar.spark:SetPoint("CENTER", bar,"TOP", 0, -bar:GetHeight() * value);
							-- else
								-- bar.spark:SetPoint("CENTER", bar,"BOTTOM", 0, bar:GetHeight() * value);
							-- end
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
	
	function HDH_STAGGER_TRACKER:UpdateBar(f, barMax)
		local value = math.floor((barMax or UnitHealthMax("player"))*0.3);
		if not self:IsHaveData(self:GetSpec()) or not f.bar or not DB_AURA.Talent[self:GetSpec()][self.name][1] then return end
		DB_AURA.Talent[self:GetSpec()][self.name][1].split_bar = {value, value*2};
		super.UpdateBar(self, f, UnitHealthMax("player"));
	end
	
	function HDH_STAGGER_TRACKER:CreateData(spec)
		if spec and DB_AURA.Talent[spec] then
			local new = {}		
			new.Key = HDH_STAGGER_KEY;
			new.Name = TrackerTypeName;
			new.Texture = self.STAGGER.green_texture;
			new.defaultImg = new.Texture;
			new.ShowValue = true;
			new.No = 1
			new.ID = 0
			new.Always = true;
			new.Glow = false;
			new.IsItem = false;
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
			DB_OPTION[self.name].bar.color = {unpack(self.STAGGER.green_color)};
			DB_OPTION[self.name].bar.full_color = {unpack(self.STAGGER.red_color)};
			DB_OPTION[self.name].bar.use_full_color = true;
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
	
	function HDH_STAGGER_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local data = DB_AURA.Talent[spec][self.name][1];
			if data and string.find(data.Key, HDH_STAGGER_KEY) then
				return 1;
			end
		end
		return false;
	end

	function HDH_STAGGER_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local f, spell
		local health_max = UnitHealthMax("player");
		f = icons[1];
		f:SetMouseClickEnabled(false);
		if not f:GetParent() then f:SetParent(self.frame) end
		if f.icon:GetTexture() == nil then
			f.icon:SetTexture(HDH_POWER[self.unit].texture);
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
			f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(spell.v1,true));
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

	-- function HDH_STAGGER_TRACKER:UpdateIcons()  -- HDH_TRACKER override
		-- local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		-- local f = self.frame.icon[1]
		-- if f == nil or f.spell == nil then return end;
		-- if f.spell.v1 > 0 then 
			-- f.icon:SetDesaturated(nil)
			-- f.icon:SetAlpha(self.option.icon.on_alpha)
			-- f.border:SetAlpha(self.option.icon.on_alpha)
			-- f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
			-- ret = 1;
			-- self:SetGlow(f, true)
			-- f:Show();
			-- if self.option.bar.enable and f.bar then
				-- self:UpdateBarValue(f);
				-- f.bar:Show();
			-- end
		-- else
			-- if f.spell.always then
				-- f.icon:SetDesaturated(1)
				-- f.icon:SetAlpha(self.option.icon.off_alpha)
				-- f.border:SetAlpha(self.option.icon.off_alpha)
				-- f.border:SetVertexColor(0,0,0)
				-- self:SetGlow(f, false)
				-- f:Show();
			-- else
				-- f:Hide();
			-- end
		-- end
		-- f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', 0, 0);
		-- return ret
	-- end

	function HDH_STAGGER_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or UI_LOCK then return end
		local f = self.frame.icon[1]
		local show
		if f and f.spell then
			-- f.spell.type = UnitPowerType('player');
			f.spell.v1 = UnitStagger('player') or 0;
			f.spell.max = UnitHealthMax('player');
			f.spell.count = (f.spell.v1/f.spell.max * 100);
			self:UpdateIcons()
			if f.spell.v1 > 0 then show = true end
		end
		if UI_LOCK or self.option.icon.always_show or UnitAffectingCombat("player") or show then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	function HDH_STAGGER_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		if not talent[self.name] then talent[self.name] = {} end
		local auraList = talent[self.name]
		local spell 
		local f
		local ret = 0
		self.frame:Hide()
		if self:IsHaveData(self:GetSpec()) and not self:IsIgnoreSpellByTalentSpell(auraList[1]) then
			ret = 1
			f = self.frame.icon[1]
			if f:GetParent() == nil then f:SetParent(self.frame) end
			spell = {}
			--self.frame.pointer[auraList[1].Key] = self.frame.icon[i]
			spell.key = auraList[1].Key
			spell.id = auraList[1].ID
			spell.no = auraList[1].No
			spell.name = auraList[1].Name
			spell.icon = auraList[1].Texture
			spell.glow = auraList[1].Glow
			spell.glowCount = auraList[1].GlowCount
			spell.glowV1= auraList[1].GlowV1
			spell.always = auraList[1].Always
			spell.showValue = auraList[1].ShowValue;
			spell.startSound = auraList[1].StartSound
			spell.endSound = auraList[1].EndSound
			spell.conditionSound = auraList[1].ConditionSound
			-- spell.type = HDH_POWER[self.unit].power_type;
			-- spell.power_index = HDH_POWER[self.unit].power_index;
			spell.max = UnitHealthMax("player");
			if f.bar then
				f.bar.max = UnitHealthMax("player");
				self:UpdateBar(f, f.bar.max);
			end
			spell.v1 = 0
			spell.duration = 0
			spell.count = 0
			spell.remaining = 0
			spell.startTime = 0
			spell.endTime = 0
			spell.happenTime = 0;
			spell.isItem = false;
			spell.showPer = true;
			
			f.cooldown1:Hide();
			f.cooldown2:Hide();
			f.icon:SetTexture(auraList[1].Texture);
			
			if spell.startSound then
				f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
				f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
			end
			if spell.endSound then
				f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
				f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
			end
			
			f.spell = spell;
			f:SetScript("OnUpdate",STAGGER_TRACKER_OnUpdate);
			f:Hide();
			self:ActionButton_HideOverlayGlow(f)
			
			-- self.frame:SetScript("OnEvent", self.OnEvent)
			-- self.frame:RegisterUnitEvent('UNIT_POWER',"player")
			-- self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")
			self:Update()
		else
			self.frame:UnregisterAllEvents()
		end
		
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		return ret
	end
	
	function HDH_STAGGER_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
	
	function HDH_STAGGER_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	-- function HDH_STAGGER_TRACKER:OnEvent(event, unit, powerType)
		-- if self == nil or self.parent == nil then return end
		-- if ((event == 'UNIT_MAXPOWER')) and (HDH_POWER[self.parent.unit].power_type == powerType) then  -- (event == "UNIT_POWER")
			-- if not UI_LOCK then
				-- self.parent:Update(powerType)
				-- self.parent:UpdateBar(self.parent.frame.icon[1]);
			-- end
		-- end
	-- end
------------------------------------
end -- HDH_STAGGER_TRACKER class
------------------------------------