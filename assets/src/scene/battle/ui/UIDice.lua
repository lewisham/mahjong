----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：骰子
----------------------------------------------------------------------

local UIDice = class("UIDice", UIBase)

function UIDice:onCreate()
    self:loadCsb("ui/battle/Dice.csb", false)
    self.dice1:setVisible(false)
    self.dice2:setVisible(false)
end

function UIDice:play(co, idx)
    local go = self:findGameObject("DAMahjong")
    local s1, s2 = Invoke(go, "roll" .. idx)
    self:action(self.dice1, s1)
    WaitForSeconds(co, 0.3)
    self:action(self.dice2, s2)
    WaitForSeconds(co, 1.2)
end


function UIDice:action(sprite, to)
    sprite:setVisible(true)
    local animation = cc.Animation:create()
	local number, name
    for j = 1, 2 do
        for i = 0, 3 do
            name = "ui/battle/dice/dice_Action_" .. i .. ".png"
            animation:addSpriteFrameWithFile(name)
        end
    end
    animation:addSpriteFrameWithFile("ui/battle/dice/dice_" .. to .. ".png")
    animation:setDelayPerUnit(1 / 20.0)
    animation:setRestoreOriginalFrame(false)
    local act1 = cc.Animate:create(animation)
    local tb = 
    {
        cc.MoveBy:create(0.1, cc.p(0, -50)),
        cc.Animate:create(animation),
        cc.Animate:create(animation),
    }
    sprite:runAction(cc.Sequence:create(tb))
end

return UIDice