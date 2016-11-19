----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：墙牌
----------------------------------------------------------------------

local UIWallTile = class("UIWallTile", NodeBase)

function UIWallTile:onCreate()
    self:findGameObject("UIBattleScene"):addChild(self)
    self:set("tiles", {})
    local tb = {1, 4, 3, 2}
    for _, dir in ipairs(tb) do
        self:createTile(dir)
    end
end

function UIWallTile:deal(co)
    local go = self:findGameObject("DAMahjong")
    self:set("last_idx", go:getStartPos())
    self:set("current_idx", go:getStartPos() + 1)
    local interval = 0.05
    local seats = self:findGameObject("DAPlayers"):get("seats")
    for i = 1, 3 do
        for _, seat in ipairs(seats) do
            self:removeFour(interval)
            go:deal(seat, 4)
            WaitForSeconds(co, interval)
        end
    end

    for _, seat in ipairs(seats) do
        self:removeOne()
        go:deal(seat, 1)
        WaitForSeconds(co, interval)
    end

    self:removeOne()
    go:deal(seats[1], 1)
    WaitForSeconds(co, interval)
end

function UIWallTile:removeOne()
    local tile = self:getCurrentTile()
    local tb = 
    {
        cc.FadeOut:create(0.1),
        cc.RemoveSelf:create(),
    }
    tile.sprite:runAction(cc.Sequence:create(tb))
end

function UIWallTile:removeLast()
    local tile = self:getLastTile()
    local tb = 
    {
        cc.FadeOut:create(0.1),
        cc.RemoveSelf:create(),
    }
    tile.sprite:runAction(cc.Sequence:create(tb))
end

function UIWallTile:removeFour(interval)
    for i = 1, 4 do
        local tile = self:getCurrentTile()
        local tb = 
        {
            cc.FadeOut:create(0.1),
            cc.RemoveSelf:create(),
        }
        tile.sprite:runAction(cc.Sequence:create(tb))
    end   
end

function UIWallTile:getCurrentTile()
    local idx = self:get("current_idx")
    local nIdx = self:modify("current_idx", 1)
    if nIdx > MAHJONG_COUNT then
        self:set("current_idx", 1)
    end
    local tb = self:get("tiles")
    local tile = tb[idx]
    return tile
end

-- 获得最后一张牌
function UIWallTile:getLastTile()
    local idx = self:get("last_idx")
    local down = self:get("last_idx_down")
    self:set("last_idx_down", not down)
    if down then
        local n = idx - 2
        if n <= 0 then n = MAHJONG_COUNT end
        self:set("last_idx", n)
    else
        idx = idx - 1
    end
    local tb = self:get("tiles")
    local tile = tb[idx]
    return tile
end

function UIWallTile:displayRascal()
    local idx, info = self:findGameObject("DAMahjong"):getRascal()
    local tile = self:get("tiles")[idx]
    local row = MAHJONG_COUNT / 4
    local dir = math.ceil(idx / row)
    local dirs = {2, 3, 2, 1}
    local filename = string.format("ui/battle/mahjong/p%ss%s_%s.png", dirs[dir], info.suit, info.rank)
    tile.sprite:setTexture(filename)
end

function UIWallTile:createTile(dir)
    local tb = self:calcTileInfo(dir)
    local node = cc.Node:create()
    self:addChild(node)
    local filename = tb.filename
    local list = tb.list
    for _, unit in ipairs(list) do
        local tile = {}
        local sprite = cc.Sprite:create(filename)
        node:addChild(sprite, unit.zorder)
        sprite:setPosition(unit.pos)
        tile.sprite = sprite
        tile.idx = 0
        table.insert(self:get("tiles"), tile)
    end
end

function UIWallTile:calcTileInfo(dir)
    local cnt = MAHJONG_COUNT / 4
    local x, y, offx, offy, upx, upy = 0, 0, 0, 0, 0, 0
    local info = {}
    local zvar = 0
    self:set("tile_info", info)
    if dir == MAHJONG_DIR.down then
        offx = -38
        offy = 0
        x = 640 + (cnt / 2 - 1) * math.abs(offx) / 2
        y = 270
        upx = 0
        upy = 14
        info.filename = "ui/battle/mahjong/tdbgs_2.png"
    elseif dir == MAHJONG_DIR.up then
        offx = 38
        offy = 0
        x = 640 - (cnt / 2 - 1) * math.abs(offx) / 2
        y = 470
        upx = 0
        upy = 14
        info.filename = "ui/battle/mahjong/tdbgs_2.png"
     elseif dir == MAHJONG_DIR.right then
        offx = 0
        offy = -25 
        x = 1280 - 280
        y = 380 + (cnt / 2 - 1) * math.abs(offy) / 2    
        upx = 0
        upy = 12
        info.filename = "ui/battle/mahjong/tdbgs_1.png"
    else
        offx = 0
        offy = 25 
        x = 280
        y = 380 - (cnt / 2 - 1) * math.abs(offy) / 2    
        upx = 0
        upy = 12
        info.filename = "ui/battle/mahjong/tdbgs_1.png"
        zvar = -1
    end
    info.list = {}
    local bDown = false 
    local z = MAHJONG_COUNT / 4
    for i = 1, cnt do
        local unit = {}
        if bDown then
            unit.pos = cc.p(x, y)
            unit.zorder = z
            x = x + offx
            y = y + offy
        else
            unit.pos = cc.p(x + upx, y + upy)
            unit.zorder = 100 + z
        end    
        z = z + zvar 
        table.insert(info.list, unit)
        bDown = not bDown
    end
    return info
end

return UIWallTile