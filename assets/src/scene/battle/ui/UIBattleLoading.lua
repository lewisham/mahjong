----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗加载资源
----------------------------------------------------------------------

local UIBattleLoading = class("UIBattleLoading", UIBase)

function UIBattleLoading:onCreate()
    self:loadCsb("ui/battle/BattleLoading.csb", true)
    self.loading_bar:setPercent(0)
    self.loading_bar:setVisible(true)
end

function UIBattleLoading:play(co)
    local list = self:findGameObject("DAMonsters"):calcLoadMonsters()
    list = {1, 2, 3, 4}
    local total = #list
    local interval = 0.2
    for key, id in ipairs(list) do
        local percent = math.floor(key / total * 100)
        self.loading_bar:aniPercentTo(percent, interval)
        WaitForSeconds(co, interval)
    end
    WaitForSeconds(co, 0.5)
    self:removeFromScene()
end

return UIBattleLoading