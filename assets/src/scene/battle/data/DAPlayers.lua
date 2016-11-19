----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-2-15
-- 描述：玩家数据
----------------------------------------------------------------------

local DAPlayers = class("DAPlayers", GameObject)

function DAPlayers:init()
    self:set("player_list", {})
    self:set("dealer", math.random(1, 4)) -- 庄家
    local tb = {}
    local seat = self:get("dealer")
    for i = 1, 4 do
        if seat > 4 then seat = 1 end
        table.insert(tb, seat)
        seat = seat + 1
    end
    self:set("seats", tb)
end

function DAPlayers:createPlayers()
    local dirs = {1, 2, 3, 4}
    for i = 1, 4 do
        local go = self:createUniqueObject("SCPlayer", i, dirs[i])
        self:get("player_list")[i] = go
        go:set("robot", i ~= 1)
        --go:set("robot", true)
    end
end

function DAPlayers:getPlayer(seat)
    return self:get("player_list")[seat]
end

function DAPlayers:sortTiles()
    for _, val in ipairs(self:get("player_list")) do
        val:getComponent("PlayerCard"):sort()
    end
end

function DAPlayers:afterDiscard(idx, card)
    for i = 1, 3 do
        idx = idx + 1
        if idx > 4 then
            idx = 1
        end
        local player = self:getPlayer(idx)
        if player:get("seat") ~= card.drop_from then
            local cnt = player:calcCardCount(card)
            if cnt >= 2 then
                return player
            end
        end
    end
    return nil
end

return DAPlayers