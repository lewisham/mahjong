----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：桌面
----------------------------------------------------------------------

local UITable = class("UITable", UIBase)

function UITable:onCreate()
    self:loadCsb("ui/battle/BattleScene.csb", true)
    for i = 1, 4 do
        local image = self["seat" .. i]
        local tb = 
        {
            cc.FadeTo:create(1.4, 164),
            cc.FadeTo:create(0.3, 255),
        }
        image:runAction(cc.RepeatForever:create(cc.Sequence:create(tb)))
        image:setVisible(false)
    end
end

function UITable:onTurn(player)
    local idx = player:get("seat")
    for i = 1, 4 do
        self["seat" .. i]:setVisible(i == idx)
    end
end

return UITable
