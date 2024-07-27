HDH_USED_SKILL_TRACKER = {}

local MyClassKor, MyClass = UnitClass("player");

-- local POWRE_NAME = {}
local L_TRACKER_NAME = "사용된 스킬 목록";
HDH_USED_SKILL_TRACKER.TIMER_DELAY = 10;
HDH_USED_SKILL_TRACKER.OVER_TIME = 30;
-- local HDH_POWER = {}
-- HDH_USED_SKILL_TRACKER.DATA = {type_name="HEALTH", bar_color={0, 1, 0}, texture = "Interface\\Icons\\Ability_Malkorok_BlightofYshaarj_Green"};

-- HDH_TRACKER_LIST[#HDH_TRACKER_LIST+1] = L_TRACKER_NAME -- 유닛은 명확하게는 추적 타입으로 보는게 맞지만 at 에서 이미 그렇게 사용하기 때문에 그냥 유닛 리스트로 넣어서 사용함
-- HDH_GET_CLASS[L_TRACKER_NAME] = HDH_USED_SKILL_TRACKER -- 
-- HDH_GET_CLASS_NAME[L_TRACKER_NAME] = "HDH_USED_SKILL_TRACKER";


	
local List = {}
function List.new (size)
  return {first = 0, last = -1, length = size}
end

function List.push(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
  local gap = list.last - list.first
  if gap >= list.length then
	list[list.first] = nil;
	list.first = list.first + 1;
  end
end

function List.pop(list)
	local first = list.first;
	local last = list.last;
	local value
	if first > last then return end
	value = list[first];
	first = first + 1;
	list[first] = nil;
	return value;
end

function List.get(list, idx)
	idx = list.first + idx-1;
	if idx > list.last or not list[idx] then return end
	local value = list[idx];
	if type(value) == "table" then
		return unpack(value);
	else
		return value;
	end
end

function List.get_length(list)
	return list.length;
end

function List.print(list)
	if list.first > list.last then error("list is empty") end
	local idx = list.first;
	local str = "";
	while idx <= list.last do
		if not list[idx] then break end
		str = str .. "@@"..list[idx]
		idx = idx + 1;
	end
	return str;
end


------------------------------------
do -- HDH_USED_SKILL_TRACKER class
------------------------------------
	setmetatable(HDH_USED_SKILL_TRACKER, HDH_TRACKER) -- 상속
	HDH_USED_SKILL_TRACKER.__index = HDH_USED_SKILL_TRACKER
	local super = HDH_TRACKER;
			
	function HDH_USED_SKILL_TRACKER:ChangeCooldownType(f, cooldown_type) -- 호출되지 말라고 빈함수
	end
	
	function HDH_USED_SKILL_TRACKER:IsHaveData(spec)
		if spec and DB_AURA.Talent[spec] then
			local cnt;
			if self.option.base.tracking_all then
				cnt = List.get_length(self.list) or 0; -- 이 부분 때문에 오버라이드 함
			else
				cnt = DB_AURA.Talent[spec][self.name] and #(DB_AURA.Talent[spec][self.name]) or 0;
			end
			return (cnt > 0) and cnt or false;
		end
		return false;
	end
	
	function HDH_USED_SKILL_TRACKER:GetEffect(f, ani_type) -- row 이동 애니
		local ret;
		if ani_type == "scale" then
			if not f.aniScale then
				local ag = f:CreateAnimationGroup()
				f.aniScale = ag
				ag.a1 = ag:CreateAnimation("SCALE")
				ag.a1:SetOrder(1)
				ag.a1:SetDuration(0.5)
				ag.a1:SetSmoothing("OUT")   
				ag.a1:SetFromScale(1.5,1.5);
				ag.a1:SetToScale(1,1);
			end
			ret = f.aniScale;
		elseif ani_type == "path" then
			-- if not f.aniMove then
				-- local ag = f:CreateAnimationGroup()
				-- f.aniMove = ag
				-- ag.a1 = ag:CreateAnimation("Translation")
				-- ag.a1:SetOrder(1)
				-- ag.a1:SetDuration(0.3)
				-- ag.a1:SetOffset(-20, 0)
			-- end
			-- ret = f.aniMove;
		end
		
		return ret;
	end
	
	function HDH_USED_SKILL_TRACKER:UpdateIcons()
		local ret = 0 -- 결과 리턴 몇개의 아이콘이 활성화 되었는가?
		local line = self.option.base.line or 10-- 한줄에 몇개의 아이콘 표시
		local margin_h = self.option.icon.margin_h
		local margin_v = self.option.icon.margin_v
		local size = self.option.icon.size -- 아이콘 간격 띄우는 기본값
		local revers_v = self.option.base.revers_v -- 상하반전
		local revers_h = self.option.base.revers_h -- 좌우반전
		local icons = self.frame.icon
		
		local i = 0 -- 몇번째로 아이콘을 출력했는가?
		local col = 0  -- 열에 대한 위치 좌표값 = x
		local row = 0  -- 행에 대한 위치 좌표값 = y
		-- if self.OrderFunc then self:OrderFunc(self) end 
		local list_lenght = List.get_length(self.list);
		local curTime = GetTime();
		for k,f in ipairs(icons) do
			if not f.spell then break end
			if f.spell.isUpdate and (curTime - f.spell.useTime) < HDH_USED_SKILL_TRACKER.OVER_TIME  then
				if f.spell.curUsed then
					local ani = self:GetEffect(f,"scale");
					if ani and not ani:IsPlaying() then
						ani:Play();
					end
					f.spell.curUsed = false;
				elseif ret > 0 then
					local ani = self:GetEffect(f,"path");
					if ani then
						if ani:IsPlaying() then
							ani:Stop();
						end
						ani:Play();
					end
					
				end
				f.spell.isUpdate = false

				if not f.spell.showValue then f.v1:SetText(nil) 
										 else f.v1:SetText(HDH_AT_UTIL.AbbreviateValue(f.spell.v1, true)) end
				f.counttext:SetText(nil)
				f.timetext:SetText("");
				f.icon:SetDesaturated(nil)
				
				local alpha = self.option.icon.on_alpha;
				alpha = alpha * (1.0 * (list_lenght-ret) / list_lenght);
			    f.icon:SetAlpha(alpha)
				f.border:SetVertexColor(unpack(self.option.icon.buff_color)) 
				f.border:SetAlpha(alpha)
				
				if self.option.bar.enable and f.bar then
					if not f.bar:IsShown() then f.bar:Show(); end
					f.name:SetText(f.spell.name);
					self:UpdateBarValue(f);
				end
				f:SetPoint('RIGHT', f:GetParent(), 'RIGHT', revers_h and -col or col, revers_v and row or -row)
				i = i + 1
				if i % line == 0 then row = row + size + margin_v; col = 0
								 else col = col + size + margin_h end
				f:Show()
				self:SetGlow(f, true)
				ret = ret + 1
			else
				f:Hide()
				self:SetGlow(f, false)
				f.spell.endTime = nil;
				f.spell.duration = 0;
				f.spell.duration = 0;
				f.spell.remaining = 0;
				f.spell.useTime = nil;
			end
		end
		return ret
	end
	
	function HDH_USED_SKILL_TRACKER:Update(use_time, name, id) -- HDH_TRACKER override
		if not self.frame or not self.frame.icon or not self.list or UI_LOCK then return end
		local show = false;
		local ret = 0;
		local q = self.list;
		local f, db_spell;
		
		local spell_name,spell_id,texture,isItem = HDH_AT_UTIL.GetInfo(id);
		
		if self.option.base.tracking_all then
			if spell_name and spell_name == name and not isItem and GetSpellLink(spell_id) then
				List.push(q, {name, id, texture, use_time});
			end	
			for i = List.get_length(q), 1, -1 do
				local q_name, q_id, q_texture, q_use_time = List.get(q,i);
				if q_name then
					ret = ret + 1;
					f = self.frame.icon[ret];
					if not f.spell then f.spell = {} end
					spell = f.spell
					spell.no = i;
					spell.isUpdate = true
					spell.id = q_id;
					spell.name = q_name;
					spell.icon = q_texture;
					spell.v1 = ret;
					f.icon:SetTexture(spell.icon)
					
					spell.count = 0
					spell.overlay = 0
					spell.endTime = 0
					-- spell.dispelType = dispelType
					spell.remaining = 0
					spell.duration = 0
					spell.startTime = 0
					
					spell.index = i; -- 툴팁을 위해, 순서
					spell.useTime = q_use_time;
					spell.curUsed = (q_use_time == use_time) or false;
				end
			end
		else
			if spell_name and spell_name == name and not isItem and GetSpellLink(spell_id) then
				db_spell = self.frame.pointer[tostring(spell_id)] or self.frame.pointer[spell_name]
				if db_spell then List.push(q, {name, id, texture, use_time}); end
			end	
			for i = List.get_length(q), 1, -1 do
				local q_name, q_id, q_texture, q_use_time = List.get(q,i);
				if q_name then
					ret = ret + 1;
					f = self.frame.icon[ret];
					if not f.spell then f.spell = {} end
					spell = f.spell
					spell.no = i;
					spell.isUpdate = true
					spell.id = q_id;
					spell.name = q_name;
					spell.icon = q_texture;
					spell.v1 = ret;
					f.icon:SetTexture(spell.icon)
					
					spell.count = 0
					spell.overlay = 0
					spell.endTime = 0
					-- spell.dispelType = dispelType
					spell.remaining = 0
					spell.duration = 0
					spell.startTime = 0
					
					spell.index = i; -- 툴팁을 위해, 순서
					spell.useTime = q_use_time;
					spell.curUsed = (q_use_time == use_time) or false;
				end
			end
		end
		self:UpdateIcons();
		
		
		if UnitAffectingCombat("player") then 
			show = true;
		else
			if self.option.icon.always_show and self.IsRecentUsedSkill then
				show = true;
				self:RunTimer(self.name, HDH_USED_SKILL_TRACKER.TIMER_DELAY, function() self.IsRecentUsedSkill = false; self:Update() end)
			else
				show = false;
			end
		end
		
		if UI_LOCK or show then
			self:ShowTracker();
		else
			self:HideTracker();
		end
	end
	
	function HDH_USED_SKILL_TRACKER:InitIcons() -- HDH_TRACKER override
		if UI_LOCK then return end 							-- ui lock 이면 패스
		if not DB_AURA.Talent then return end 				-- 특성 정보 없으면 패스
		local talent = DB_AURA.Talent[self:GetSpec()] 
		if not talent then return end 						-- 현재 특성 불러 올수 없으면 패스
		if not self.option then return end 	-- 설정 정보 없으면 패스
		local auraList = talent[self.name] or {}
		local name, icon, spellID
		local spell 
		local f
		local ret = 0;
		self.frame.pointer = {}
		
		if self.option.base.tracking_all then
			if #(self.frame.icon) > 0 then self:ReleaseIcons() end
		else
			for i = 1, #auraList do
				if not self:IsIgnoreSpellByTalentSpell(auraList[i]) then
					ret = ret + 1
					spell = {}
					self.frame.pointer[auraList[i].Key or tostring(auraList[i].ID)] = spell -- GetSpellInfo 에서 spellID 가 nil 일때가 있다.
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
					spell.is_buff = true;
					spell.isUpdate = false
					spell.isItem =  auraList[i].IsItem
					-- f.icon:SetDesaturated(1)
					-- f.icon:SetAlpha(self.option.icon.off_alpha)
					-- f.border:SetAlpha(self.option.icon.off_alpha)
					-- self:ChangeCooldownType(f, self.option.base.cooldown)
					-- self:SetGlow(f, false)
					
					-- spell.startSound = auraList[i].StartSound
					-- spell.endSound = auraList[i].EndSound
					-- spell.conditionSound = auraList[i].ConditionSound
					-- if spell.startSound then
						-- f.cooldown2:SetScript("OnShow", HDH_OnShowCooldown)
						-- f.cooldown1:SetScript("OnShow", HDH_OnShowCooldown)
					-- end
					-- if spell.endSound then
						-- f.cooldown1:SetScript("OnHide", HDH_OnHideCooldown)
						-- f.cooldown2:SetScript("OnHide", HDH_OnHideCooldown)
					-- end
				end
			end
		end
		
		self.frame:UnregisterAllEvents()
		if ret > 0 or self.option.base.tracking_all then
			self.frame:SetScript("OnEvent", self.OnEvent)
			self.frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
			self.frame:RegisterEvent('UNIT_SPELLCAST_SENT')
			self.frame:RegisterEvent("UNIT_SPELLCAST_STOP")
			if not self.list then self.list = List.new(5); end
		end
		return ret
	end
	
	function HDH_USED_SKILL_TRACKER:ACTIVE_TALENT_GROUP_CHANGED()
		self:InitIcons()
		-- self:UpdateBar(self.frame.icon[1]);
	end
	
	function HDH_USED_SKILL_TRACKER:PLAYER_ENTERING_WORLD()
	end
	
	function HDH_USED_SKILL_TRACKER:OnEvent(event, ...)
		if self == nil or self.parent == nil then return end
		if not self.SpellList then self.SpellList = {} end
		local unit, name, line_id = ...;
		if unit ~= "player" then return end
		if (event == 'UNIT_SPELLCAST_SUCCEEDED') then 
			if not UI_LOCK and self.SpellList[line_id] and name then
				local tracker = self.parent;
				tracker.IsRecentUsedSkill = true;
				tracker:Update(GetTime(),name,select(5,...));
				self.SpellList[line_id] = nil;
			end
		elseif (event == 'UNIT_SPELLCAST_SENT')then
			self.SpellList[line_id] = GetTime();
		elseif (event == 'UNIT_SPELLCAST_STOP')then
			self.SpellList[line_id] = nil;
		end
	end
------------------------------------
end -- HDH_USED_SKILL_TRACKER class
------------------------------------