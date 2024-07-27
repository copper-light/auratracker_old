-- spell tooltip
local function addLine(tooltip, id)
    local found = false
	local idText = "주문ID: |cffffffff" .. id
	
    -- Check if we already added to this tooltip. Happens on the talent frame
    for i = 1,15 do
        local frame = _G[tooltip:GetName() .. "TextRight" .. i]
        local text
		
        if frame then text = frame:GetText() end
        if text and text == idText then found = true break end
    end

    if not found then
        tooltip:AddDoubleLine(" ", idText)
        tooltip:Show()
    end
end

hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
	if not DB_OPTION.tooltip_id_show then return end
    local id = select(11, UnitBuff(...))
    if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	if not DB_OPTION.tooltip_id_show then return end
    local id = select(11, UnitDebuff(...))
    if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	if not DB_OPTION.tooltip_id_show then return end
    local id = select(11, UnitAura(...))
    if id then addLine(self, id) end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	if not DB_OPTION.tooltip_id_show then return end
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id) end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	if not DB_OPTION.tooltip_id_show then return end
    local id = select(3, self:GetSpell())
    if id then addLine(self, id) end
end)