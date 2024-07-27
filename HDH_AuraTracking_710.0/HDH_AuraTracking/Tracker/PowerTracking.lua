CT_VERSION = 0.1
HDH_POWER_TRACKER = {}

local POWRE_BAR_SPLIT_MARGIN = 5;

local MyClassKor, MyClass = UnitClass("player");

-- local POWRE_NAME = {}
local L_POWER_MANA = "자원:마나";
local L_POWER_RAGE = "자원:분노"
local L_POWER_FOCUS = "자원:집중"
local L_POWER_ENERGY = "자원:기력"
local L_POWER_RUNIC_POWER = "자원:룬마력"
local L_POWER_LUNAR_POWER = "자원:천공의힘"
local L_POWER_MAELSTROM = "자원:소용돌이"
local L_POWER_INSANITY = "자원:광기"
local L_POWER_FURY = "자원:격노"
local L_POWER_PAIN = "자원:고통"

local HDH_POWER = {}
HDH_POWER[L_POWER_MANA]		 	= {power_type="MANA",		 	power_index =0,		color={0.25, 0.78, 0.92}, 		texture = "Interface\\Icons\\INV_Misc_Rune_03"};
HDH_POWER[L_POWER_RAGE]			= {power_type="RAGE", 			power_index =1,		color={0.77, 0.12, 0.23}, 		texture = "Interface\\Icons\\Ability_Warrior_Rampage"};
HDH_POWER[L_POWER_FOCUS] 		= {power_type="FOCUS", 			power_index =2,		color={1.00, 0.50, 0.25}, 		texture = "Interface\\Icons\\Ability_Fixated_State_Orange"};
HDH_POWER[L_POWER_ENERGY]		= {power_type="ENERGY",			power_index =3, 	color={1, 0.96, 0.41}, 	  		texture = "Interface\\Icons\\Spell_Holy_PowerInfusion"};
HDH_POWER[L_POWER_RUNIC_POWER]	= {power_type="RUNIC_POWER", 	power_index =6,		color={0, 0.82, 1}, 			texture = "Interface\\Icons\\Spell_DeathKnight_FrozenRuneWeapon"};
HDH_POWER[L_POWER_LUNAR_POWER] 	= {power_type="LUNAR_POWER",	power_index =8, 	color={0.30, 0.52, 0.90},		texture = "Interface\\Icons\\Ability_Druid_Eclipse"};
HDH_POWER[L_POWER_MAELSTROM]	= {power_type="MAELSTROM", 		power_index =11,	color={0.25, 0.5, 1},			texture = "Interface\\Icons\\Spell_Shaman_StaticShock"};
HDH_POWER[L_POWER_INSANITY] 	= {power_type="INSANITY", 		power_index =13,	color={0.70, 0.4, 0.90},	  	texture = "Interface\\Icons\\SPELL_SHADOW_TWISTEDFAITH"};
HDH_POWER[L_POWER_FURY] 		= {power_type="FURY",			power_index =17, 	color={0.788, 0.259, 0.992},	texture = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker"};-- 17
HDH_POWER[L_POWER_PAIN] 		= {power_type="PAIN",			power_index =18,	color={1, 156/255, 0}, 			texture = "Interface\\Icons\\Ability_Warlock_FireandBrimstone"}; -- 18
HDH_POWER_TRACKER.POWER = HDH_POWER;

local IS_REGEN_POWER = {} -- 자동으로 리젠되는 자원인가? 비전투중일때 자원바를 보이게 할것인가 판단하는 기준이됨
IS_REGEN_POWER[0] = true; -- 마나
IS_REGEN_POWER[2] = true; -- 집중
IS_REGEN_POWER[3] = true; -- 기력

-- HDH_POWER["MANA"]		 = {tracker_name="자원:마나", 	color={0.25, 0.78, 0.92}, 	texture = "Interface\\Icons\\INV_Misc_Rune_03"};
-- HDH_POWER["RAGE"]		 = {tracker_name="자원:분노", 	color={0.77, 0.12, 0.23}, 	texture = "Interface\\Icons\\Ability_Warrior_Rampage"};
-- HDH_POWER["FOCUS"] 		 = {tracker_name="자원:집중", 	color={1.00, 0.50, 0.25}, 	texture = "Interface\\Icons\\Ability_Fixated_State_Orange"};
-- HDH_POWER["ENERGY"]		 = {tracker_name="자원:기력", 	color={1, 0.96, 0.41}, 	  	texture = "Interface\\Icons\\Ability_Priest_SpiritOfTheRedeemer"};
-- HDH_POWER["RUNIC_POWER"] = {tracker_name="자원:룬마력", 	color={0.77, 0.12, 0.23}, 	texture = "Interface\\Icons\\Spell_DeathKnight_FrozenRuneWeapon"};
-- HDH_POWER["LUNAR_POWER"] = {tracker_name="자원:천공의힘", 	color={0.30, 0.52, 0.90},	texture = "Interface\\Icons\\Spell_Nature_AbolishMagic"};
-- HDH_POWER["MAELSTROM"]	 = {tracker_name="자원:소용돌이", 	color={0.25, 0.78, 0.92},	texture = "Interface\\Icons\\Spell_Lightning_LightningBolt01"};
-- HDH_POWER["INSANITY"] 	 = {tracker_name="자원:광기", 	color={0.40, 0, 0.80},	  	texture = "Interface\\Icons\\Ability_Rogue_EnvelopingShadows"};
-- HDH_POWER["FURY"] 		 = {tracker_name="자원:격노", 	color={0.788, 0.259, 0.992},texture = "Interface\\Icons\\Ability_BossFelOrcs_Necromancer_Purple"};-- 17
-- HDH_POWER["PAIN"] 		 = {tracker_name="자원:고통",		color={1, 156/255, 0}, 		texture = "Interface\\Icons\\Ability_BossFelOrcs_Necromancer_Purple"}; -- 18

local TrackerTypeName ={};
if MyClass == "MAGE" or MyClass == "PALADIN" or MyClass == "WARLOCK" then 
	TrackerTypeName[1] = L_POWER_MANA;
elseif MyClass == "PRIEST"  then
	TrackerTypeName[1] = L_POWER_MANA;
	TrackerTypeName[2] = L_POWER_INSANITY;
elseif MyClass == "WARRIOR" then 
	TrackerTypeName[1] = L_POWER_RAGE
elseif MyClass == "DRUID" then 
	TrackerTypeName[1] = L_POWER_MANA
	TrackerTypeName[2] = L_POWER_LUNAR_POWER
	TrackerTypeName[3] = L_POWER_ENERGY
	TrackerTypeName[4] = L_POWER_RAGE
elseif MyClass == "DEATHKNIGHT" then TrackerTypeName[1] = L_POWER_RUNIC_POWER;
elseif MyClass == "HUNTER" then TrackerTypeName[1] = L_POWER_FOCUS; 
elseif MyClass == "ROGUE" then TrackerTypeName[1] = L_POWER_ENERGY 
elseif MyClass == "SHAMAN" then 
	TrackerTypeName[1] = L_POWER_MANA
	TrackerTypeName[2] = L_POWER_MAELSTROM
elseif MyClass == "MONK" then TrackerTypeName[1] = L_POWER_ENERGY
elseif MyClass == "DEMONHUNTER" then 
	TrackerTypeName[1] = L_POWER_FURY; 
	TrackerTypeName[2] = L_POWER_PAIN;
end
-- else TrackerTypeName[1] = "2차 자원(콤보)"; end

for i = 1, #TrackerTypeName do
	HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = TrackerTypeName[i] -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
	HDH_GET_CLASS[TrackerTypeName[i]] = HDH_POWER_TRACKER -- 
	HDH_GET_CLASS_NAME[TrackerTypeName[i]] = "HDH_POWER_TRACKER";
end

-- HDH_POWER_TRACKER.SPEC_INFO = {}
-- HDH_POWER_TRACKER.SPEC_INFO[62] = {TYPE = "MANA", INDEX=0, TEXTURE="INV_Misc_Rune_03" }-- Mage: Arcane
-- HDH_POWER_TRACKER.SPEC_INFO[63] = {TYPE = "MANA", INDEX=0, TEXTURE="INV_Misc_Rune_03" } -- Mage: Fire
-- HDH_POWER_TRACKER.SPEC_INFO[64] = {TYPE = "MANA", INDEX=0, TEXTURE="INV_Misc_Rune_03" }-- Mage: Frost

-- HDH_POWER_TRACKER.SPEC_INFO[65] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Paladin: Holy
-- HDH_POWER_TRACKER.SPEC_INFO[66] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Paladin: Protection
-- HDH_POWER_TRACKER.SPEC_INFO[70] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Paladin: Retribution

-- HDH_POWER_TRACKER.SPEC_INFO[71] = {TYPE = "RAGE", INDEX=1, TEXTURE="" }-- Warrior: Arms
-- HDH_POWER_TRACKER.SPEC_INFO[72] = {TYPE = "RAGE", INDEX=1, TEXTURE="" }-- Warrior: Fury
-- HDH_POWER_TRACKER.SPEC_INFO[73] = {TYPE = "RAGE", INDEX=1, TEXTURE="" }-- Warrior: Protection

-- HDH_POWER_TRACKER.SPEC_INFO[102] = {TYPE = "LUNAR_POWER", INDEX = 8, TEXTURE="" }-- Druid: Balance
-- HDH_POWER_TRACKER.SPEC_INFO[103] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Druid: Feral
-- HDH_POWER_TRACKER.SPEC_INFO[104] = {TYPE = "RAGE", INDEX=1, TEXTURE="" }-- Druid: Guardian
-- HDH_POWER_TRACKER.SPEC_INFO[105] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Druid: Restoration

-- HDH_POWER_TRACKER.SPEC_INFO[250] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Blood
-- HDH_POWER_TRACKER.SPEC_INFO[251] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Frost
-- HDH_POWER_TRACKER.SPEC_INFO[252] = {TYPE = "RUNIC_POWER", INDEX=6, TEXTURE="" }-- Death Knight: Unholy

-- HDH_POWER_TRACKER.SPEC_INFO[253] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Beast Mastery
-- HDH_POWER_TRACKER.SPEC_INFO[254] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Marksmanship
-- HDH_POWER_TRACKER.SPEC_INFO[255] = {TYPE = "FOCUS", INDEX=2, TEXTURE="" }-- Hunter: Survival

-- HDH_POWER_TRACKER.SPEC_INFO[256] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Priest: Discipline
-- HDH_POWER_TRACKER.SPEC_INFO[257] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Priest: Holy
-- HDH_POWER_TRACKER.SPEC_INFO[258] = {TYPE = "INSANITY", INDEX=13, TEXTURE="" }-- Priest: Shadow

-- HDH_POWER_TRACKER.SPEC_INFO[259] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Assassination
-- HDH_POWER_TRACKER.SPEC_INFO[260] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Combat
-- HDH_POWER_TRACKER.SPEC_INFO[261] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Rogue: Subtlety

-- HDH_POWER_TRACKER.SPEC_INFO[262] = {TYPE = "MAELSTROM", INDEX=11, TEXTURE="" }-- Shaman: Elemental
-- HDH_POWER_TRACKER.SPEC_INFO[263] = {TYPE = "MAELSTROM", INDEX=11, TEXTURE="" }-- Shaman: Enhancement
-- HDH_POWER_TRACKER.SPEC_INFO[264] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Shaman: Restoration

-- HDH_POWER_TRACKER.SPEC_INFO[265] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Affliction
-- HDH_POWER_TRACKER.SPEC_INFO[266] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Demonology
-- HDH_POWER_TRACKER.SPEC_INFO[267] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Warlock: Destruction

-- HDH_POWER_TRACKER.SPEC_INFO[268] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Monk: Brewmaster
-- HDH_POWER_TRACKER.SPEC_INFO[269] = {TYPE = "ENERGY", INDEX=3, TEXTURE="" }-- Monk: Windwalker
-- HDH_POWER_TRACKER.SPEC_INFO[270] = {TYPE = "MANA", INDEX=0, TEXTURE="" }-- Monk: Mistweaver

-- HDH_POWER_TRACKER.SPEC_INFO[577] = {TYPE = "FURY", INDEX=17, TEXTURE="" }-- Demon Hunter: Havoc
-- HDH_POWER_TRACKER.SPEC_INFO[581] = {TYPE = "PAIN", INDEX=18, TEXTURE="" }-- Demon Hunter: Vengeance

-- HDH_POWER_TRACKER.HDH_POWER_INDEX, HDH_POWER_TRACKER.HDH_POWER_NAME

------------------------------------
do -- HDH_POWER_TRACKER class
------------------------------------
	setmetatable(HDH_POWER_TRACKER, HDH_TRACKER) -- 상속
	HDH_POWER_TRACKER.__index = HDH_POWER_TRACKER
	local super = HDH_TRACKER

	local function HDH_POWER_OnUpdate(self)
		self.spell.curTime = GetTime()
		
		if self.spell.curTime - (self.spell.delay or 0) < 0.02  then return end 
		self.spell.delay = self.spell.curTime
		local curValue = UnitPower('player', self.spell.power_index);
		local maxValue = UnitPowerMax('player', self.spell.power_index);
		self.spell.v1 = curValue;
		if self.spell.showPer then
			self.spell.count = (self.spell.v1/maxValue * 100);
			self.counttext:SetText(format("%d%%", self.spell.count)); 
		else self.counttext:SetText(nil) end
		if self.spell.showValue then self.v1:SetText(HDH_AT_UTIL.AbbreviateValue(self.spell.v1)); else self.v1:SetText(nil) end
		
		if IS_REGEN_POWER[self.spell.power_index] then
			if self.spell.v1 < maxValue then
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
		else
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
		end
		
		self:GetParent().parent:SetGlow(self, true);
		self:GetParent().parent:UpdateBarValue(self);
	end
	
	function HDH_POWER_TRACKER:UpdateBarValue(f)
		if f.bar and f.bar.bar and #f.bar.bar > 0 then
			local bar;
			for i = 1, #f.bar.bar do 
				bar = f.bar.bar[i];
				-- bar:SetMinMaxValues(bar.mpMin, bar.mpMax);
				if bar then 
					bar:SetValue(self:GetAnimatedValue(bar,f.spell.v1,i)); 
					-- bar:SetValue(f.spell.v1); 
					if f:GetParent().parent.option.bar.use_full_color then
						if f.spell.v1 >= (bar.mpMax) then
							bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.full_color));
						else
							bar:SetStatusBarColor(unpack(f:GetParent().parent.option.bar.color));
						end
					end
					if self.option.bar.show_spark then
						if bar:GetValue() >= bar.mpMax then value = 1; if bar.spark:IsShown() then bar.spark:Hide(); end
						elseif bar:GetValue()<= bar.mpMin then value = 0; if bar.spark:IsShown() then bar.spark:Hide(); end
						else
							value = (bar:GetValue()-bar.mpMin)/(bar.mpMax - bar.mpMin);
							if not bar.spark:IsShown() then bar.spark:Show(); end
						end
						if bar:GetOrientation() == "HORIZONTAL" then
							if self.option.bar.reverse_progress then
								bar.spark:SetPoint("CENTER", bar,"RIGHT", -bar:GetWidth() * value, 0);
							else
								bar.spark:SetPoint("CENTER", bar,"LEFT", bar:GetWidth() * value, 0);
							end
						else
							if self.option.bar.reverse_progress then
								bar.spark:SetPoint("CENTER", bar,"TOP", 0, -bar:GetHeight() * value);
							else
								bar.spark:SetPoint("CENTER", bar,"BOTTOM", 0, bar:GetHeight() * value);
							end
						end
					end
				end
			end
		end
	end
		
	local ANI_TERM = 0.2 -- second
	function HDH_POWER_TRACKER:GetAnimatedValue(bar, v) -- v:target value
		if bar.targetValue ~= v then
			bar.animatedStartTime = bar.preTime or GetTime();
			bar.targetValue = v;
		end
		local gap = bar.targetValue - bar:GetValue();
		local gapTime;
		if gap ~= 0 then
			gapTime = (GetTime() - bar.animatedStartTime);
			if gapTime < ANI_TERM then
				v = gap * (gapTime/ANI_TERM);
			else
				v = gap;
			end
		else
			v = 0;
		end
		bar.preTime = GetTime();
		return bar:GetValue()+ v;
	end
	
	
	function HDH_POWER_TRACKER:CreateData(spec)
		if spec and DB_AURA.Talent[spec] then
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
			DB_OPTION[self.name].bar.color = {unpack(HDH_POWER[self.type].color)};
			DB_OPTION[self.name].bar.full_color = {unpack(HDH_POWER[self.type].color)};
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
	
	function HDH_POWER_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local data = DB_AURA.Talent[spec][self.name][1];
			if data and string.find(data.Key, HDH_POWER[self.type].power_type) then
				return 1;
			end
		end
		return false;
	end
	
	function HDH_POWER_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
	end
	
	function HDH_POWER_TRACKER:CreateDummySpell(count)
		local icons =  self.frame.icon
		local option = self.option
		local curTime = GetTime()
		local f, spell
		local power_max = UnitPowerMax("player",HDH_POWER[self.type].power_index);
		f = icons[1];
		f:SetMouseClickEnabled(false);
		if not f:GetParent() then f:SetParent(self.frame) end
		if f.icon:GetTexture() == nil then
			f.icon:SetTexture(HDH_POWER[self.type].texture);
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
		spell.v1 = power_max
		spell.max = power_max;
		f.cd:Hide();
		if self.option.bar.enable and f.bar then
			f:SetScript("OnUpdate",nil);
			-- f.bar:SetMinMaxValues(0, power_max);
			-- f.bar:SetValue(spell.v1);
			f.v1:SetText(HDH_AT_UTIL.CommaValue(spell.v1));
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

	function HDH_POWER_TRACKER:Release() -- HDH_TRACKER override
		if self and self.frame then
			self.frame:UnregisterAllEvents()
			self.frame.namePointer = nil
		end
		super.Release(self)
	end
	
	function HDH_POWER_TRACKER:ReleaseIcon(idx) -- HDH_TRACKER override
		local icon = self.frame.icon[idx]
		--icon:SetScript("OnEvent", nil)
		icon:Hide()
		icon:SetParent(nil)
		icon.spell = nil
		icon:SetScript("OnUpdate",nil);
		self.frame.icon[idx] = nil
	end

	function HDH_POWER_TRACKER:UpdateSetting() -- HDH_TRACKER override
		super.UpdateSetting(self)
	end
	
	function HDH_POWER_TRACKER:UpdateArtBar(f) -- HDH_TRACKER override
		local op = self.option.bar;
		local hide_icon = self.option.icon.hide_icon;
		if op.enable then
			if (f.bar and f.bar:GetObjectType() ~= "Frame") then
				f.bar:Hide();
				f.bar:SetParent(nil);
				f.bar = nil;
			end
			if not f.bar then
				f.bar = CreateFrame("Frame", nil, f);
				f.bar.margin = POWRE_BAR_SPLIT_MARGIN;--------------------------------------------- margin
			end
			if hide_icon then f.iconframe:Hide();
			else f.iconframe:Show(); end
			self:UpdateBar(f);
		else
			if f.bar then f.bar:Hide(); end
			if hide_icon then
				f.iconframe:Show();
			end
		end
	end
	
	-- barMax: 다른 클래스에서 호환성을 위해서 추가 파워트래킹에서는 사용안함
	function HDH_POWER_TRACKER:UpdateBar(f, barMax) 
		local bar_op = self.option.bar;
		local hide_icon = self.option.icon.hide_icon;
		if not self:IsHaveData(self:GetSpec()) or not f.bar then return end
		local aura_data = DB_AURA.Talent[self:GetSpec()][self.name][1];
		if not aura_data then return; end
		aura_data = aura_data.split_bar;
		
		local bf = f.bar;
		local split = {unpack(aura_data or {})}
		local nextIsNill = false;
		bf.max = barMax or UnitPowerMax("player",HDH_POWER[self.type].power_index);
		self.max = bf.max;
		-- print(self.max)
		-- 무결성 체크
		for i = 1, #split do
			if nextIsNill then 
				split[i] = nil 
			else
				if not split[i] or  split[i] > bf.max then
					split[i] = nil;
					nextIsNill = true;
				end
				if split[i] and (split[i] > (split[i+1] or bf.max)) then
					split[i+1] = nil;
					nextIsNill = true;
				end
			end
		end
		
		if bf.bar == nil then bf.bar ={} end
		bf:ClearAllPoints();
		if bar_op.location == HDH_TRACKER.BAR_LOCATION_T then  
			bf:SetSize(bar_op.height,bar_op.width);
			bf:SetPoint("BOTTOM",f, hide_icon and "BOTTOM" or "TOP",0,1); 
		elseif bar_op.location == HDH_TRACKER.BAR_LOCATION_B then 
			bf:SetSize(bar_op.height,bar_op.width);
			bf:SetPoint("TOP",f, hide_icon and "TOP" or "BOTTOM",0,-1); 
		elseif bar_op.location == HDH_TRACKER.BAR_LOCATION_L then 
			bf:SetSize(bar_op.width,bar_op.height);
			bf:SetPoint("RIGHT",f, hide_icon and "RIGHT" or "LEFT",-1,0); 
		else
			bf:SetSize(bar_op.width,bar_op.height);
			bf:SetPoint("LEFT",f, hide_icon and "LEFT" or "RIGHT",1,0); 
		end
		
		local cnt = (#split == 0) and 1 or (#split +1);
		for i = 1, cnt do
			if bf.bar[i] == nil then
				local newBar = CreateFrame("StatusBar",nil,bf);
				newBar.background = newBar:CreateTexture(nil,"BACKGROUND");
				newBar.background:SetPoint('TOPLEFT', newBar, 'TOPLEFT', -1, 1)
				newBar.background:SetPoint('BOTTOMRIGHT', newBar, 'BOTTOMRIGHT', 1, -1)
				newBar.background:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\cooldown_bg");
				newBar.spark = newBar:CreateTexture(nil, "OVERLAY");
				newBar.spark:SetBlendMode("ADD");
				bf.bar[i] = newBar;
				if i== 1 and not f.name then f.name = newBar:CreateFontString(nil,"OVERLAY"); end
			end 
			
			local powerMax = bf.max
			bf.bar[i].mpMax = split[i] or powerMax;
			bf.bar[i].mpMin = split[i-1] or 0;
			
			local gap = bf.bar[i].mpMax - bf.bar[i].mpMin;
			bf.bar[i]:SetMinMaxValues(bf.bar[i].mpMin, bf.bar[i].mpMax);
			
			local r = bar_op.reverse_progress;
			bf.bar[i]:SetStatusBarTexture(r and HDH_TRACKER.BAR_TEXTURE[bar_op.texture].texture_r or HDH_TRACKER.BAR_TEXTURE[bar_op.texture].texture); 
			bf.bar[i]:SetStatusBarColor(unpack(bar_op.color));
			bf.bar[i]:ClearAllPoints();
			if bar_op.location == HDH_TRACKER.BAR_LOCATION_T or bar_op.location == HDH_TRACKER.BAR_LOCATION_B then  
				local h = ( bf:GetHeight() - (bf.margin * #split) ) * (gap/powerMax);
				bf.bar[i]:SetSize(bf:GetWidth(), h);
				bf.bar[i]:SetOrientation("Vertical"); bf.bar[i]:SetRotatesTexture(true);
				if i == 1 then bf.bar[i]:SetPoint(r and "TOP" or "BOTTOM",0,0);
						  else bf.bar[i]:SetPoint(r and "TOP" or "BOTTOM", bf.bar[i-1], r and "BOTTOM" or "TOP", 0, r and -bf.margin or bf.margin); end
				bf.bar[i].spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark_v");
				bf.bar[i].spark:SetSize(bar_op.height*1.3, 19);
			else
				local w = ( bf:GetWidth() - (bf.margin * #split) ) * (gap/powerMax);
				bf.bar[i]:SetSize(w, bf:GetHeight());
				bf.bar[i]:SetOrientation("Horizontal"); bf.bar[i]:SetRotatesTexture(false);
				if i == 1 then bf.bar[i]:SetPoint(r and "RIGHT" or "LEFT",0,0);
						  else bf.bar[i]:SetPoint(r and "RIGHT" or "LEFT", bf.bar[i-1], r and "LEFT" or "RIGHT", r and -bf.margin or bf.margin, 0); end
				bf.bar[i].spark:SetTexture("Interface\\AddOns\\HDH_AuraTracking\\Texture\\UI-CastingBar-Spark");
				bf.bar[i].spark:SetSize(19, bar_op.height*1.3);		  
			end
			if self.option.bar.show_spark then
				bf.bar[i].spark:Show();
			else
				bf.bar[i].spark:Hide();
			end
			bf.bar[i].background:SetVertexColor(unpack(bar_op.bg_color));
			bf.bar[i]:SetReverseFill(r);	
			
			bf.bar[i]:Show();
		end
		
		for i = cnt+1, #bf.bar do
			bf.bar[i]:Hide();
			bf.bar[i]:SetParent(nil);
			bf.bar[i] = nil;
		end
		bf.cnt = cnt;
		bf:Show();
	end

	function HDH_POWER_TRACKER:UpdateIcons()  -- HDH_TRACKER override
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

	function HDH_POWER_TRACKER:Update() -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or UI_LOCK then return end
		local f = self.frame.icon[1]
		local show
		if f and f.spell then
			-- f.spell.type = UnitPowerType('player');
			f.spell.v1 = UnitPower('player', f.spell.power_index);
			f.spell.max = UnitPowerMax('player', f.spell.power_index);
			f.spell.count = (f.spell.v1/f.spell.max * 100);
			self:UpdateIcons()
			if IS_REGEN_POWER[f.spell.power_index] then
				if f.spell.max ~= f.spell.v1 then show = true end
			elseif f.spell.v1 > 0 then show = true end
		end
		if UI_LOCK or self.option.icon.always_show or UnitAffectingCombat("player") or show then
			-- self.frame:Show()
			self:ShowTracker();
		else
			-- self.frame:Hide()
			self:HideTracker();
		end
	end
	
	function HDH_POWER_TRACKER:InitIcons() -- HDH_TRACKER override
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
		if self:IsHaveData(self:GetSpec()) then
			if string.find(auraList[1].Key or "", HDH_POWER[self.type].power_type) and not self:IsIgnoreSpellByTalentSpell(auraList[1])  then
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
				spell.type = HDH_POWER[self.type].power_type;
				spell.power_index = HDH_POWER[self.type].power_index;
				spell.max = UnitPowerMax('player', spell.power_index);
				if f.bar then
					f.bar.max = UnitPowerMax('player', spell.power_index);
					self:UpdateBar(f);
				end
				spell.v1 = 0
				spell.duration = 0
				spell.count = 0
				spell.remaining = 0
				spell.startTime = 0
				spell.endTime = 0
				spell.happenTime = 0;
				spell.isItem = false;
				if HDH_POWER[self.type].power_type == "MANA" then
					spell.showPer = true;
				end
				
				f.cooldown1:Hide();
				f.cooldown2:Hide();
				f.icon:SetTexture(auraList[1].Texture);
				
				-- if f.bar then f.bar:SetMinMaxValues(0, spell.max); end
				if spell.startSound then
					f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
					f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
				end
				if spell.endSound then
					f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
					f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
				end
				
				f.spell = spell;
				f:SetScript("OnUpdate",HDH_POWER_OnUpdate);
				f:Hide();
				self:ActionButton_HideOverlayGlow(f)
				
				
				-- self:ChangeCooldownType(f, self.option.base.cooldown)
			end
			
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterUnitEvent('UNIT_POWER',"player")
			self.frame:RegisterUnitEvent('UNIT_MAXPOWER',"player")
			-- GetPowerRegen
			self:Update()
		else
			self.frame:UnregisterAllEvents()
		end
		
		for i = #self.frame.icon, ret+1 , -1 do
			self:ReleaseIcon(i)
		end
		return ret
	end
	
	function HDH_POWER_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
		-- self:UpdateBar(self.frame.icon[1]);
	end
	
	function HDH_POWER_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_POWER_TRACKER:OnEvent(event, unit, powerType)
		if self == nil or self.parent == nil then return end
		if ((event == 'UNIT_MAXPOWER')) and (HDH_POWER[self.parent.type].power_type == powerType) then  -- (event == "UNIT_POWER")
			if not UI_LOCK then
				-- self.parent:Update(powerType)
				-- print("e")
				self.parent:UpdateBar(self.parent.frame.icon[1]);
			end
		end
	end
------------------------------------
end -- HDH_POWER_TRACKER class
------------------------------------