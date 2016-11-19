----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：
----------------------------------------------------------------------

local UIDecision = class("UIDecision", UIBase)

function UIDecision:onCreate()
    self:loadCsb("ui/battle/Decision.csb", true)
    self:setVisible(false)
end

function UIDecision:play(co, tb)
    table.insert(tb, DECISION_TYPE.pass)
    local cnt = #tb
    local offx = 140
    local x = 800 - (cnt / 2 - 1) * math.abs(offx) / 2
    local y = 240
    for i = 0, 3 do
        self["btn_" .. i]:setVisible(false)
    end
    local decision = 0
    for _, idx in ipairs(tb) do
        local btn = self["btn_" .. idx]
        btn:setVisible(true)
        btn:setPosition(x, y)
        btn:onClicked(function() decision = idx end)
        x = x + offx
    end
    self:setVisible(true)
    WaitForFuncResult(co, function() return decision ~= 0 end)
    self:setVisible(false)
    return decision
end

return UIDecision