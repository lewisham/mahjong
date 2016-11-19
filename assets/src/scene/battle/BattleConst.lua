----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗定义
----------------------------------------------------------------------

MAHJONG_COUNT = 136
--MAHJONG_COUNT = 108

DECISION_TYPE =
{
    pass = 0,
    pong = 1,
    kong = 2,
}

MAHJONG_TYPE =
{
    character = 1,
    dot = 2,
    bamboo = 3,
    zi = 4,
}


MAHJONG_DIR =
{
    down = 1,
    right = 2,
    up = 3,
    left = 4
}

local logic_id = 0

function AllocTile(suit, rank)
    --suit = 2
    --rank = 5
    logic_id = logic_id + 1
    local unit = {}
    unit.id = logic_id
    unit.idx = 100
    unit.suit = suit
    unit.rank = rank
    unit.logic_suit = suit
    unit.logic_rank = rank
    unit.rascal = 0
    unit.weight = 0
    return unit
end

function IsTileEqual(t1, t2)
    return t1.suit == t2.suit and t1.rank == t2.rank
end

function IsSuit(card)
    return card.logic_suit == 1 or card.logic_suit == 2 or card.logic_suit == 3
end

function SortLogicMahjong(tb)
    local func = MakeSortRule(function(a, b) return a.rascal > b.rascal end,
                              function(a, b) return a.logic_suit < b.logic_suit end,
                              function(a, b) return a.logic_rank < b.logic_rank end)
    table.sort(tb, func)
end

function SortDisplayMahjong(tb)
    local func = MakeSortRule(function(a, b) return a.rascal > b.rascal end,
                              function(a, b) return a.logic_suit < b.logic_suit end,
                              function(a, b) return a.logic_rank < b.logic_rank end,
                              function(a, b) return a.idx < b.idx end)
    table.sort(tb, func)
    for key, val in ipairs(tb) do
        val.idx = key
    end
end