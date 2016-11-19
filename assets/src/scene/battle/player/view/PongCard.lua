----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：打出去的牌
----------------------------------------------------------------------

local PongCard = class("PongCard", NodeBase)

function PongCard:onCreate(seat)
    self:findGameObject("UITable"):addChild(self, 0)
    self:set("pong_card", {})
    self:initPos()
end

function PongCard:initPos()
    local orginX, orginY, offx, offy = 512, 200, 36, -42
    local dir = self:getDisplayDir()
    local horizon = true
    if dir == MAHJONG_DIR.down then
        orginX, orginY, offx, offy = 640 - 288, 160, 36, 42
    elseif dir == MAHJONG_DIR.up then
        orginX, orginY, offx, offy = 640 + 288, 597, -36, -42
    elseif dir == MAHJONG_DIR.right then
        horizon = false
        orginX, orginY, offx, offy = 1280 - 62, 380 + 208, -49, -26
    elseif dir == MAHJONG_DIR.left then
        horizon = false
        orginX, orginY, offx, offy = 62, 380 - 208, 49, 26
    end
    local x = orginX
    local y = orginY
    local tb = {}
    if horizon then
        x = orginX
        for i = 1, 16 do
            table.insert(tb, cc.p(x, y))
            x = x + offx
        end
        y = y + offy
    else
        y = orginY
        for i = 1, 16 do
            table.insert(tb, cc.p(x, y))
            y = y + offy
        end
        x = x + offx
    end 
    self:set("pos_list", tb)
end

function PongCard:getDisplayDir()
    return self:getGameObject():get("display_dir")
end

function PongCard:onPeng(tb)
    for _, card in ipairs(tb) do
        table.insert(self:get("pong_card"), card)
        local pos = self:get("pos_list")[#self:get("pong_card")]
        local dir = self:getGameObject():get("display_dir")
        local dirs = {2, 1, 2, 3}
        local filename = string.format("ui/battle/mahjong/p%ss%s_%s.png", dirs[dir], card.suit, card.rank)
        local sprite = cc.Sprite:create(filename)
        self:addChild(sprite, 900 - pos.y)
        sprite:setPosition(pos)
    end
end

function PongCard:onKong(tb)
    for _, card in ipairs(tb) do
        table.insert(self:get("pong_card"), card)
        local pos = self:get("pos_list")[#self:get("pong_card")]
        local dir = self:getGameObject():get("display_dir")
        local dirs = {2, 1, 2, 3}
        local filename = string.format("ui/battle/mahjong/p%ss%s_%s.png", dirs[dir], card.suit, card.rank)
        local sprite = cc.Sprite:create(filename)
        self:addChild(sprite, 900 - pos.y)
        sprite:setPosition(pos)
    end
end

return PongCard