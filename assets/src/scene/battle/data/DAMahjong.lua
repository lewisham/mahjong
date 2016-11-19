----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-2-15
-- 描述：麻将数据
----------------------------------------------------------------------

local DAMahjong = class("DAMahjong", GameObject)

function DAMahjong:init()
    self:initMahjong()
    self:set("current_idx", 0)
    self:set("last_idx", 0)
    self:set("player_tiles", {{}, {}, {}, {}})
end

function DAMahjong:awake()
end

function DAMahjong:initMahjong()
    local tb = {}
    -- 万筒条
    for suit = MAHJONG_TYPE.character, MAHJONG_TYPE.bamboo do
        for rank = 1, 9 do
            for i = 1, 4 do
                table.insert(tb, AllocTile(suit, rank))
            end
        end
    end
    -- 字
    if MAHJONG_COUNT == 136 then
        for rank = 1, 7 do
            for i = 1, 4 do
                table.insert(tb, AllocTile(MAHJONG_TYPE.zi, rank))
            end
        end
    end
    self:set("mahjong_list", tb)
end

function DAMahjong:shuffle()
    local tb = self:get("mahjong_list")
    for _, val in ipairs(tb) do
        val.weight = math.random(0, 10000)
    end
    table.sort(tb, function(a, b) return a.weight < b.weight end)
end

function DAMahjong:getNext()
    local idx = self:modify("current_idx", 1)
    if idx > MAHJONG_COUNT then
        idx = 1
        self:set("current_idx", 1)
    end
    return self:get("mahjong_list")[idx]
end

function DAMahjong:getLast()
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
    return self:get("mahjong_list")[idx]
end

function DAMahjong:isOver()
    return self:get("current_idx") == self:get("end_idx")
end

-- 选出方位
function DAMahjong:roll1()
    local s1 = math.random(1, 6)
    local s2 = math.random(1, 6)
    local max = math.max(s1, s2)
    local min = math.min(s1, s2)
    local dirs = {1, 4, 3, 2, 1, 4, 3, 2, 1, 4, 3, 2}
    max = max + self:findGameObject("DAPlayers"):get("dealer") - 1
    local dir = dirs[max]
    local sub = min
    local pos = (dir - 1) * MAHJONG_COUNT / 4 + 2 * sub
    self:set("start_pos", pos)
    self:set("current_idx", pos)
    self:set("last_idx", pos)
    return s1, s2
end

-- 选出金的位置
function DAMahjong:roll2()
    local s1 = math.random(1, 6)
    local s2 = math.random(1, 6)
    local cnt = s1 + s2
    local idx = self:getStartPos() - (cnt - 1) * 2 - 1
    if idx < 0 then
        idx = MAHJONG_COUNT + idx
    end
    self:set("rascal", idx)
    -- 设置癞子标记
    local rascal = self:get("mahjong_list")[idx]
    self:set("end_idx", idx - 1)
    for _, val in ipairs(self:get("mahjong_list")) do
        if IsTileEqual(val, rascal) then
            val.rascal = 1
        end
    end
    -- 白板设置成癞子的逻辑值
    if rascal.suit < MAHJONG_TYPE.zi then
        for _, val in ipairs(self:get("mahjong_list")) do
            if val.suit == MAHJONG_TYPE.zi and val.rank == 7 then
                val.logic_suit = rascal.suit
                val.logic_rank = rascal.rank
            end
        end
    end
    return s1, s2
end


function DAMahjong:getStartPos()
    return self:get("start_pos")
end

function DAMahjong:getRascal()
    local idx = self:get("rascal")
    return idx, self:get("mahjong_list")[idx]
end

function DAMahjong:deal(seat, cnt)
    local go = self:findGameObject("DAPlayers"):findPlayer(seat)
    local tb = {}
    for i = 1, cnt do
        local tile = self:getNext()
        table.insert(tb, tile)
    end
    go:onDeal(tb)
end

return DAMahjong