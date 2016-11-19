----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：打出去的牌
----------------------------------------------------------------------

local DropCard = class("DropCard", NodeBase)

function DropCard:onCreate(seat)
    self:findGameObject("UIBattleScene"):addChild(self)
    self:set("drop_card", {})
    self:initPos()
end

function DropCard:initPos()
    local orginX, orginY, offx, offy = 512, 200, 36, -42
    local dir = self:getDisplayDir()
    local horizon = true
    if dir == MAHJONG_DIR.down then
        orginX, orginY, offx, offy = 640 - 240, 220, 36, 42
    elseif dir == MAHJONG_DIR.up then
        orginX, orginY, offx, offy = 640 + 245, 540, -36, -42
    elseif dir == MAHJONG_DIR.right then
        horizon = false
        orginX, orginY, offx, offy = 1280 - 182, 380 + 140, -49, -26
    elseif dir == MAHJONG_DIR.left then
        horizon = false
        orginX, orginY, offx, offy = 182, 380 - 140, 49, 26
    end
    local x = orginX
    local y = orginY
    local tb = {}
    if horizon then
        for j = 1, 3 do
            x = orginX
            for i = 1, 16 do
                table.insert(tb, cc.p(x, y))
                x = x + offx
            end
            y = y + offy
        end
    else
        for j = 1, 3 do
            y = orginY
            for i = 1, 16 do
                table.insert(tb, cc.p(x, y))
                y = y + offy
            end
            x = x + offx
        end
    end
    
    self:set("pos_list", tb)
end

function DropCard:getDisplayDir()
    return self:getGameObject():get("display_dir")
end

function DropCard:onDrop(co, card)
    local pos = self:get("pos_list")[#self:get("drop_card") + 1]
    local dir = self:getGameObject():get("display_dir")
    local dirs = {2, 1, 2, 3}
    local filename = string.format("ui/battle/mahjong/p%ss%s_%s.png", dirs[dir], card.suit, card.rank)
    local sprite = cc.Sprite:create(filename)
    self:addChild(sprite, 900 - pos.y)
    table.insert(self:get("drop_card"), 1, sprite)
    sprite:setPosition(pos)
    PlaySound("sound/common/audio_card_out.mp3")
    WaitForSeconds(co, 0.2)
end

function DropCard:removeCurrent()
    local tb = self:get("drop_card")
    local node = tb[1]
    table.remove(tb, 1)
    local tb = 
    {
        cc.FadeOut:create(0.3),
        cc.RemoveSelf:create(),
    }
    node:runAction(cc.Sequence:create(tb))
end

return DropCard