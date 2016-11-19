----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗特效
----------------------------------------------------------------------

local UIBattleEffect = class("UIBattleEffect", NodeBase)

function UIBattleEffect:onCreate(name, action)
    local dn = cc.Node:create()
    self:addChild(dn)
    self:set("direction_node", dn)

    local model = db.DBCCFactory:getInstance():buildArmatureNode(name .. "_" .. action, name)
    self:set("model", model)
    dn:addChild(model)
    g_MonsterRoot:addChild(self)
end

-- 计算朝向
function UIBattleEffect:calcDir(monster)
    if self:get("lock_scalex") then return end
    local scale = monster:get("group") == CampType.player and 1 or -1
    self:get("model"):setScaleX(scale)
end

function UIBattleEffect:resetZorder()
    local z = 800 - math.floor(self:getPositionY()) + 10
    self:setLocalZOrder(z)
end

-- 设置特效的偏移位置
function UIBattleEffect:setOffsetPos(pos)
    self:get("model"):setPosition(pos)
end

-- 播放动画
function UIBattleEffect:play(loops)
    self:get("model"):getAnimation():play()
    if loops == 1 then
        local function animation()
            SafeRemoveNode(self)
        end
        self:get("model"):registerAnimationEventHandler(animation)
    end
end

-- 发射弹道
function UIBattleEffect:launch(duration, startPos, targetPos, handler)
    self:play()
    self:setPosition(startPos)
    local function callback()
        SafeRemoveNode(self)
        if handler then handler.func(handler.param) end
    end
    local tb = 
    {
        cc.MoveTo:create(duration, targetPos),
        cc.CallFunc:create(callback, {}),
    }
    self:runAction(cc.Sequence:create(tb))

    -- 计算朝向
    local angle = math.atan2(targetPos.x - startPos.x, targetPos.y - startPos.y) * 180 / 3.14
    self:get("direction_node"):setRotation(angle - 90)
    self:get("model"):setScaleX(1)
    self:set("lock_scalex", true)
end

return UIBattleEffect