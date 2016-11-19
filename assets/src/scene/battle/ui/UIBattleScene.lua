----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗背景场景
----------------------------------------------------------------------

local UIBattleScene = class("UIBattleScene", UIBase)

function UIBattleScene:onCreate()
    self:loadCsb("ui/battle/BattleScene.csb", true)
    for i = 1, 4 do
        self["seat" .. i]:setVisible(false)
    end
end

function UIBattleScene:onTurn(player)
    local idx = player:get("seat")
    for i = 1, 4 do
        self["seat" .. i]:setVisible(i == idx)
    end
end



return UIBattleScene
