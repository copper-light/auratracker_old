HDH_COMBO_POINT_TRACKER = {}
local MyClassKor, MyClass = UnitClass("player");

local L_POWRE_ARCANE_CHARGES = "자원:비전_충전몰";
local L_POWRE_HOLY_POWER = "자원:신성한_힘"
local L_POWRE_COMBO_POINTS = "자원:연계_점수"
local L_POWRE_SOUL_SHARDS = "자원:영혼의_조각"
local L_POWRE_CHI = "자원:기"

local HDH_POWER = {}
HDH_POWER[L_POWRE_COMBO_POINTS] 	= {power_type="COMBO_POINTS", 	power_index = 4,	color={1.00, 0.50, 0.25}, texture = "Interface\\Icons\\INV_Misc_Gem_Pearl_05"};
HDH_POWER[L_POWRE_SOUL_SHARDS]		= {power_type="SOUL_SHARDS",	power_index = 7, 	color={1, 0.96, 0.41}, 	  texture = "Interface\\Icons\\Spell_Shadow_SoulGem"};
HDH_POWER[L_POWRE_HOLY_POWER]		= {power_type="HOLY_POWER", 	power_index = 9,	color={0.77, 0.12, 0.23}, texture = "Interface\\Icons\\Spell_Holy_BlessedResillience"};
HDH_POWER[L_POWRE_CHI]				= {power_type="CHI", 			power_index = 12,	color={0.77, 0.12, 0.23}, texture = "Interface\\Icons\\INV_Misc_Gem_Pearl_06"};
HDH_POWER[L_POWRE_ARCANE_CHARGES]	= {power_type="ARCANE_CHARGES",	power_index = 16,	color={0.25, 0.78, 0.92}, texture = "Interface\\Icons\\Spell_Nature_WispSplode"};
HDH_COMBO_POINT_TRACKER.POWER = HDH_POWER;
-- 지원하는 특성
-- local IS_USE_POWER = {}

-- IS_USE_POWER[62] = true; -- 비법
-- IS_USE_POWER[70] = true; -- 징기
-- IS_USE_POWER[269] = true; -- 풍운
-- IS_USE_POWER[265] = true; -- 고흑
-- IS_USE_POWER[266] = true; -- 악흑
-- IS_USE_POWER[267] = true; -- 파흑
-- IS_USE_POWER[103] = true; -- 야드
-- IS_USE_POWER[259] = true; -- 암살도적
-- IS_USE_POWER[260] = true; -- 전투도적
-- IS_USE_POWER[261] = true; -- 무법도적

local TrackerTypeName;
if MyClass == "MAGE" then TrackerTypeName = L_POWRE_ARCANE_CHARGES;
elseif MyClass == "PALADIN" then TrackerTypeName = L_POWRE_HOLY_POWER;
elseif MyClass == "WARRIOR" then
elseif MyClass == "DRUID" then TrackerTypeName = L_POWRE_COMBO_POINTS;
elseif MyClass == "DEATHKNIGHT" then
elseif MyClass == "HUNTER" then
elseif MyClass == "PRIEST" then
elseif MyClass == "ROGUE" then TrackerTypeName = L_POWRE_COMBO_POINTS;
elseif MyClass == "SHAMAN" then
elseif MyClass == "WARLOCK" then TrackerTypeName = L_POWRE_SOUL_SHARDS;
elseif MyClass == "MONK" then TrackerTypeName = L_POWRE_CHI;
elseif MyClass == "DEMONHUNTER" then
else TrackerTypeName = "2차 자원(콤보)"; end

if TrackerTypeName then
	HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = TrackerTypeName -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
	HDH_GET_CLASS[TrackerTypeName] = HDH_COMBO_POINT_TRACKER -- 
	HDH_GET_CLASS_NAME[TrackerTypeName] = "HDH_COMBO_POINT_TRACKER";
end
HDH_OLD_TRACKER["Combo_points"] = TrackerTypeName;

------------------------------------
do -- HDH_COMBO_POINT_TRACKER class
------------------------------------
	setmetatable(HDH_COMBO_POINT_TRACKER, HDH_TRACKER) -- 상속
	HDH_COMBO_POINT_TRACKER.__index = HDH_COMBO_POINT_TRACKER
	local super = HDH_TRACKER
	
	-- function HDH_COMBO_POINT_TRACKER:InitVariblesOption() -- HDH_TRACKER override
		-- super.InitVariblesOption(self)
	-- end
	
	function HDH_COMBO_POINT_TRACKER:CreateData(spec)
		if spec then
			DB_AURA.Talent[spec][self.name] = {}
			local new = {}		
			new.Key = HDH_POWER[self.type].power_type..1;
			new.Name = HDH_POWER[self.type].power_type..1;
			new.Texture = HDH_POWER[self.type].texture;
			new.defaultImg = new.Texture;
			new.ShowValue = true;
			new.No = 1
			new.ID = 0
			new.Always = true
			new.Glow = true
			new.IsItem = false
			DB_AURA.Talent[spec][self.name][1] = new;
		end
	end
	
	function HDH_COMBO_POINT_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local data = DB_AURA.Talent[spec][self.name][1];
			if data and string.find(data.Key, HDH_POWER[self.type].power_type) then
				return 1;
			end
		end
		return false;
	end
	
	function HDH_COMBO_POINT_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			self.frame:UnregisterAllEvents()
			self.frame.namePointer = nil
		end
		super.Release(self)
	end
	
	function HDH_COMBO_POINT_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
		local icon = self.frame.icon[idx]
		--icon:SetScript("OnEvent", nil)
		icon:Hide()
		icon:SetParent(nil)
		icon.spell = nil
		self.frame.icon[idx] = nil
	end
	
	function HDH_COMBO_POINT_TRACKER:CreateDummySpell(count)
		local power_max = UnitPowerMax('player', HDH_POWER[self.type].power_index);
		local auraList = DB_AURA.Talent[self:GetSpec()][self.name]
		if not auraList or #auraList == 0 then return end
		local max = 1;
		if not self.option.base.merge_power_icon then
			max = power_max;
		end
		for i = 1, max do
			iconf = self.frame.icon[i]
			if iconf then 
				if not iconf.spell then
					iconf.spell = {}
				end
				iconf:SetParent(self.frame) 
				iconf.spell.duration = 0
				iconf.spell.count = 0
				iconf.spell.remaining = 0
				iconf.spell.startTime = 0
				iconf.spell.endTime = 0
				iconf.spell.key = i
				iconf.spell.id = 0
				iconf.spell.happenTime = 0;
				iconf.spell.no = 1
				iconf.spell.name = 1
				iconf.spell.icon = auraList[1].Texture
				iconf.spell.glow = false
				iconf.spell.glowCount = 0
				iconf.spell.glowV1= 0
				iconf.spell.always = true
				iconf.spell.showValue = true;
				iconf.icon:SetTexture(auraList[1].Texture);
				
				iconf.spell.v1 = power_max;
				if (power_max) == i then
					iconf.icon:SetAlpha(self.option.icon.off_alpha);
					iconf.spell.isUpdate = false;
				else
					iconf.spell.isUpdate = true;
					iconf.icon:SetAlpha(self.option.icon.on_alpha);
				end
			end
		end
		return power_max;
	end

	function HDH_COMBO_POINT_TRACKER:UpdateSetting() -- HDH_TRACKER override
		super.UpdateSetting(self)
	end
	
	function HDH_COMBO_POINT_TRACKER:UpdateArtBar(f) -- HDH_TRACKER override
		super.UpdateArtBar(self,f)
		if f.bar then
			f.bar:SetScript("OnUpdate",nil);
		end
	end

	function HDH_COMBO_POINT_TRACKER:UpdateIcons()  -- HDH_TRACKER override
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local size = self.option.icon.size -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
		local icons = self.frame.icon
		
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		
		for k,f in ipairs(icons) do
			if not f.spell then break end
			f.cd:Hide();
			f.counttext:SetText(nil)
			if f.spell.isUpdate then
				f.spell.isUpdate = false
				f.icon:SetDesaturated(nil)
				f.icon:SetAlpha(self.option.icon.on_alpha)
				f.border:SetAlpha(self.option.icon.on_alpha)
				f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				
				i = i + 1
				if i % line == 0 then row = row + size + margin_v; col = 0
									 else col = col + size + margin_h end
				ret = ret + 1
				self:SetGlow(f, true)
				f:Show()
				if self.option.bar.enable and f.bar then
					f.bar:SetMinMaxValues(0,1);
					f.bar:SetValue(1);
				end
				
				if self.option.base.merge_power_icon then
					f.v1:SetText(f.spell.v1);
				else
					f.v1:SetText("");
				end
			else
				if k <= UnitPowerMax('player', HDH_POWER[self.type].power_index) then 
					if f.spell.always then 
						if not f.icon:IsDesaturated() then f.icon:SetDesaturated(1) end
						f.icon:SetAlpha(self.option.icon.off_alpha)
						f.border:SetAlpha(self.option.icon.off_alpha)
						f.border:SetVertexColor(0,0,0)
						f.v1:SetText("");
						self:SetGlow(f, false)
						f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
						
						i = i + 1
						if i % line == 0 then row = row + size + margin_v; col = 0
										 else col = col + size + margin_h end
						f:Show()
						if self.option.bar.enable and f.bar then
							f.bar:SetMinMaxValues(0,1);
							f.bar:SetValue(0);
						end
					else
						f:Hide();
					end
				else
					self:ReleaseIcon(k);
				end
			end
		end
		return ret
	end

	function HDH_COMBO_POINT_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or UI_LOCK then return end
		local auraList = DB_AURA.Talent[self:GetSpec()][self.name]
		if not auraList or #auraList == 0 then return end
		local iconf;
		local spell;
		local ret = 0;
		
		local power = UnitPower('player', HDH_POWER[self.type].power_index, true);
		local power_max = UnitPowerMax('player', HDH_POWER[self.type].power_index);
		
		if self.option.base.merge_power_icon then -- 아이콘 하나로
			iconf = self.frame.icon[1]
			if iconf then 
				if not iconf.spell then
					iconf.spell = {}
				end
				iconf:SetParent(self.frame) 
				iconf.spell.duration = 0
				iconf.spell.count = 0
				iconf.spell.remaining = 0
				iconf.spell.startTime = 0
				iconf.spell.endTime = 0
				iconf.spell.key = i
				iconf.spell.id = 0
				iconf.spell.happenTime = 0;
				iconf.spell.no = auraList[1].No
				iconf.spell.name = auraList[1].Name
				iconf.spell.icon = auraList[1].Texture
				iconf.spell.glow = auraList[1].Glow
				iconf.spell.glowCount = auraList[1].GlowCount
				iconf.spell.glowV1= auraList[1].GlowV1
				iconf.spell.always = auraList[1].Always
				iconf.spell.showValue = auraList[1].ShowValue;
				iconf.icon:SetTexture(auraList[1].Texture);
				iconf.spell.v1 = power;
				if power > 0 then
					iconf.spell.isUpdate = true
				else
					iconf.spell.isUpdate = false
				end
				ret = ret + 1;
			end
		else -- 아이콘 여러개
			
			for i = 1, power_max do
				iconf = self.frame.icon[i]
				if iconf then 
					if not iconf.spell then
						iconf.spell = {}
					end
					 iconf:SetParent(self.frame) 
					iconf.spell.duration = 0
					iconf.spell.count = 0
					iconf.spell.remaining = 0
					iconf.spell.startTime = 0
					iconf.spell.endTime = 0
					iconf.spell.key = i
					iconf.spell.id = 0
					iconf.spell.happenTime = 0;
					iconf.spell.no = auraList[1].No
					iconf.spell.name = auraList[1].Name
					iconf.spell.icon = auraList[1].Texture
					iconf.spell.glow = auraList[1].Glow
					iconf.spell.glowCount = auraList[1].GlowCount
					iconf.spell.glowV1= auraList[1].GlowV1
					iconf.spell.always = auraList[1].Always
					iconf.spell.showValue = auraList[1].ShowValue;
					iconf.icon:SetTexture(auraList[1].Texture);
					if power >= i then
						iconf.spell.isUpdate = true
						iconf.spell.v1 = power;
					else
						iconf.spell.isUpdate = false
						iconf.spell.v1 = 0;
					end
					ret = ret + 1;
				end
			end
		end
		self:UpdateIcons();
		if self.option.icon.always_show or UnitAffectingCombat("player") or power >= 1 then
			self:ShowTracker();
		else
			self:HideTracker();
		end
		return ret;
	end

	function HDH_COMBO_POINT_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		if not talent[self.name] then
			talent[self.name] = {}
		end
		local auraList = talent[self.name]
		local name, icon, spellID, isItem
		local spell 
		local f
		local ret = 0
		local power_type = HDH_POWER[self.type].power_type;
		local power_max = UnitPowerMax('player', HDH_POWER[self.type].power_index);
		-- print(self.option.base.merge_power_icon)
		-- if IS_USE_POWER[GetSpecializationInfo(GetSpecialization())] then 
		-- for i = 1, #auraList do
			-- if string.find(auraList[i].Key, power_type)  then
				-- ret = ret +1
			-- end
		-- end
		-- end
		if self:IsHaveData(self:GetSpec()) and not self:IsIgnoreSpellByTalentSpell(auraList[1]) then
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterUnitEvent('UNIT_POWER',"player")
			self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")
			ret = self:Update()
		else
			self.frame:UnregisterAllEvents()
			self.frame:SetScript("OnEvent", nil);
			self.frame:Hide();
		end
		for i = ret+1, #self.frame.icon do
			self:ReleaseIcon(i)
		end
		
		return ret
	end
	
	function HDH_COMBO_POINT_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
	end
	
	function HDH_COMBO_POINT_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_COMBO_POINT_TRACKER:OnEvent(event, unit, powerType)
		if self == nil or self.parent == nil then return end
		if (event == "UNIT_POWER" or event == 'UNIT_MAXPOWER') and (HDH_POWER[self.parent.type].power_type == powerType) then 
			if not UI_LOCK then
				self.parent:Update()
			end
		end
	end
------------------------------------
end -- HDH_COMBO_POINT_TRACKER class
------------------------------------

