----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：玩家的牌
----------------------------------------------------------------------

local PlayerCard = class("PlayerCard", NodeBase)

function PlayerCard:onCreate()
    self:set("tiles", {})
    self:findGameObject("UITable"):addChild(self, 1)
end

function PlayerCard:play(co)
    self:set("drop_card", nil)
    local time = 0
    while true do
        if self:get("drop_card") then break end
        WaitForFrames(co, 1)
        time = time + 0.02
        if time > 6.0 or self:getGameObject():get("robot") then
            local card = self:getGameObject():aiDiscard()
            self:set("drop_card", card)
            break
        end
    end
    return self:get("drop_card")
end

function PlayerCard:getDisplayDir()
    return self:getGameObject():get("display_dir")
end

function PlayerCard:calcPos(dir, cnt)
    cnt = cnt < 14 and cnt + 1 or cnt
    local dir = self:getDisplayDir()
    local tb = {}
    if dir == MAHJONG_DIR.down then
        local offx = 83
        local x = 640 - (cnt - 1) * offx / 2
        local y = 70
        for i = 1, cnt do
            table.insert(tb, cc.p(x, y))
            x = x + offx
        end
    elseif dir == MAHJONG_DIR.up then
        local offx = 38
        local x = 640 - (cnt - 1) * offx / 2
        local y = 650
        for i = 1, cnt do
            table.insert(tb, cc.p(x, y))
            x = x + offx
        end
    elseif dir == MAHJONG_DIR.right then
        local x = 640 + 510
        local offy = -32
        y = 400 + (cnt - 1) * math.abs(offy) / 2
        for i = 1, cnt do
            table.insert(tb, cc.p(x, y))
            y = y + offy
        end
    elseif dir == MAHJONG_DIR.left then
        local x = 640 - 510
        local offy = -32
        y = 400 + (cnt - 1) * math.abs(offy) / 2
        for i = 1, cnt do
            table.insert(tb, cc.p(x, y))
            y = y + offy
        end
    end
    return tb
end

function PlayerCard:getFilename()
    local dir = self:getDisplayDir()
    local filename = ""
    if dir == MAHJONG_DIR.left then
        filename = "ui/battle/mahjong/tbgs_3.png"
    elseif dir == MAHJONG_DIR.right then
        filename = "ui/battle/mahjong/tbgs_1.png"
    elseif dir == MAHJONG_DIR.up then
        filename = "ui/battle/mahjong/tbgs_2.png"
    end
    return filename
end

function PlayerCard:getTiles()
    local tb = {}
    for key, image in pairs(self:get("tiles")) do
        if not tolua.isnull(image) then
            table.insert(tb, image)
        else
            self:get("tiles")[key] = nil
        end
    end
    return tb
end

-- 发牌
function PlayerCard:onDeal()
    local dir = self:getDisplayDir()
    local cnt = 14
    local list = self:calcPos(dir, cnt)
    if dir == MAHJONG_DIR.down then
        local tb = self:getGameObject():get("tiles")
        for key, unit in ipairs(tb) do
            local image = self:get("tiles")[unit.id]
            if image == nil then
                local name = string.format("ui/battle/mahjong/p4b%d_%d.png", unit.suit, unit.rank)
                local image = ccui.ImageView:create(name)
                self:addChild(image)
                image.data = unit
                image:setTouchEnabled(true)
                image:onClicked(function(...) self:onSelectTile(...) end)
                image:setPosition(list[key])
                self:get("tiles")[unit.id] = image
            end
        end
    else
        local tb = self:getGameObject():get("tiles")
        for key, unit in ipairs(tb) do
            local image = self:get("tiles")[unit.id]
            if image == nil then
                local pos = list[key]
                local image = cc.Sprite:create(self:getFilename())
                self:addChild(image, 900 - pos.y)
                image.data = unit
                image:setPosition(pos)      
                self:get("tiles")[unit.id] = image    
            end
        end
    end
end

-- 摸牌
function PlayerCard:onDraw(unit)
    local dir = self:getDisplayDir()
    local data = self:getGameObject():get("tiles")
    local total = #data
    local list = self:calcPos(dir, total)
    local pos = list[#list]
    if dir == MAHJONG_DIR.down then
        pos.x = pos.x + 20
        local name = string.format("ui/battle/mahjong/p4b%d_%d.png", unit.suit, unit.rank)
        local image = ccui.ImageView:create(name)
        self:addChild(image)
        image.data = unit
        image:setTouchEnabled(true)
        image:onClicked(function(...) self:onSelectTile(...) end)
        image:setPosition(pos)
        self:get("tiles")[unit.id] = image
        image.new_tile = true
    else
        local image = cc.Sprite:create(self:getFilename())
        self:addChild(image, 900 - pos.y)
        image.data = unit
        image:setPosition(pos)      
        self:get("tiles")[unit.id] = image
    end
end

-- 打牌
function PlayerCard:removeCard(card)
    local tb = self:getTiles()
    for key, image in ipairs(tb) do
        if card.id == image.data.id then
            SafeRemoveNode(image)
            break
        end
    end
end

function PlayerCard:onSelectTile(sender)
    if self:getGameObject():get("turn") then
        if sender:getPositionY() > 70 then
            self:set("drop_card", sender.data)
            return
        end
    end
    local y = sender:getPositionY() > 70 and 70 or 100
    sender:setPositionY(y)
end

-- 排序牌
function PlayerCard:sort()
    local dir = self:getDisplayDir()
    if dir ~= MAHJONG_DIR.down then return end
    local data = self:getGameObject():get("tiles")
    SortDisplayMahjong(data)
    local list = self:calcPos(dir, #data)
    local tb = self:getTiles()
    table.sort(tb, function(a, b) return a.data.idx < b.data.idx end)
    for key, image in ipairs(tb) do
        local act = cc.MoveTo:create(0.2, list[key])
        image:runAction(act)
    end
end

-- 调整牌
function PlayerCard:adjust()
    local dir = self:getDisplayDir()
    local data = self:getGameObject():get("tiles")
    local list = self:calcPos(dir, #data)
    local tb = self:getTiles()
    local total = #tb
    if dir == MAHJONG_DIR.down then
        SortDisplayMahjong(data)
        table.sort(tb, function(a, b) return a.data.idx < b.data.idx end)
        for key, image in ipairs(tb) do
            local pos = list[key]
            if not image.new_tile or key == total then
                local act = cc.MoveTo:create(0.2, pos)
                image:runAction(act)

            else
                local orgin = cc.p(image:getPosition())
                local tb = 
                {
                    cc.MoveBy:create(0.2, cc.p(0, 100)),
                    cc.MoveBy:create(0.3, cc.p(pos.x - orgin.x, 0)),
                    cc.MoveBy:create(0.2, cc.p(0, -100)),
                }
                image:runAction(cc.Sequence:create(tb))
            end
            image.new_tile = nil
        end
    else
        for key, image in ipairs(tb) do
            local pos = list[key]
            image:setPosition(pos)
            image:setLocalZOrder(900 - pos.y)
        end
        self:sortAllChildren()
    end
end

function PlayerCard:showCards()
    local dir = self:getGameObject():get("display_dir")
    local dirs = {2, 1, 2, 3}
    if dir == MAHJONG_DIR.down then return end
    self:removeAllChildren()
    local dir = self:getDisplayDir()
    local data = self:getGameObject():get("tiles")
    local list = self:getShowCardPos(#data)
    SortDisplayMahjong(data)
    for key, card in ipairs(data) do
        local pos = list[key]
        local filename = string.format("ui/battle/mahjong/p%ss%s_%s.png", dirs[dir], card.suit, card.rank)
        local sprite = cc.Sprite:create(filename)
        self:addChild(sprite, 900 - pos.y)
        sprite:setPosition(pos)
    end
end

function PlayerCard:getShowCardPos(cnt)
    local orginX, orginY, offx, offy = 512, 200, 36, -42
    local dir = self:getDisplayDir()
    local horizon = true
    if dir == MAHJONG_DIR.down then
        orginX, orginY, offx, offy = 640 - 240, 220, 36, 42
    elseif dir == MAHJONG_DIR.up then
        orginX, orginY, offx, offy = 640 + 245, 650, -36, -42
        orginX = 640 + (cnt - 1) * math.abs(offx) / 2
    elseif dir == MAHJONG_DIR.right then
        horizon = false
        orginX, orginY, offx, offy = 640 + 510, 380 + 140, -49, -26
        orginY = 400 + (cnt - 1) * math.abs(offy) / 2
    elseif dir == MAHJONG_DIR.left then
        horizon = false
        orginX, orginY, offx, offy = 640 - 510, 380 - 140, 49, 26
        orginY = 400 - (cnt - 1) * math.abs(offy) / 2
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
    return tb
end

return PlayerCard