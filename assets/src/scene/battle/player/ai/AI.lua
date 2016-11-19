----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-2-15
-- 描述：AI
----------------------------------------------------------------------

local AI = class("AI", Component)

local Tri = 90
local Seq = 85
local Pair = 70
local Shu = 60
local Que = 40
local Dan = 20

local s_values =
{
    {offset = 0, key = "aaabbbccc", values = {Tri, Tri, Tri, Tri, Tri, Tri, Tri, Tri, Tri}},
    {offset = 3, key = "aaabc", values = {Tri, Tri, Seq, Shu, Que}},
    {offset = 3, key = "aaabd", values = {Tri, Tri, Tri, Que, Que}},
    {offset = 3, key = "aaabbcc", values = {Tri - 10, Tri, Tri, Seq, Seq, Seq, Seq}},
    {offset = 0, key = "aaa", values = {Tri, Tri, Tri}},
    {offset = 2, key = "aabbcc", values = {Seq, Seq, Seq + 1, Seq + 1, Seq, Seq}},
    {offset = 0, key = "abbbbc", values = {Seq, Tri, Tri, Tri, Seq, Seq}},
    {offset = 1, key = "abbbc", values = {Que, Tri, Tri, Tri, Que}},
    {offset = 1, key = "abbc", values = {Seq, Seq, Dan, Seq}},
    {offset = 0, key = "abc", values = {Seq, Seq, Seq}},
    {offset = 0, key = "aabcd", values = {Pair, Pair, Seq, Seq, Seq}},
    {offset = 1, key = "aabc", values = {Pair - 10, Seq, Seq, Seq}},
    {offset = 2, key = "aab", values = {Pair, Pair, Shu}},
    {offset = 2, key = "aac", values = {Pair, Pair, Que}},
    {offset = 1, key = "aa", values = {Pair, Pair}},
    {offset = 1, key = "ab", values = {Shu, Shu}},
    {offset = 1, key = "ac", values = {Que, Que}},
    {offset = 0, key = "a", values = {Dan}},
}

local s2 = {"aaa", "aa", "a"}

function AI:init()
    self:set("idx", 1)
    local tb = {}
    for _, val in ipairs(s_values) do
        table.insert(tb, val.key)
    end
    self:set("s1", tb)
end

function AI:calc(co, cards)
    local suits = {{}, {}, {}, {}}
    for _, val in ipairs(cards) do
        val.value = 0
        val.weight = math.random(1, 100)
        table.insert(suits[val.logic_suit], val)
    end
    for _, tb in ipairs(suits) do
        self:set("idx", 1)
        SortLogicMahjong(tb)
        while true do
            local idx = self:get("idx")
            local card = tb[idx]
            if card == nil then break end
            if card.rascal == 1 then
                card.value = 100
                self:modify("idx", 1)
            else
                local sulotion = IsSuit(card) and self:get("s1") or s2
                for _, name in ipairs(sulotion) do
                    if self:filter(tb, name) then
                        break
                    end
                end
            end
            if idx == self:get("idx") then
                self:modify("idx", 1)
            end
        end
    end
    local func = MakeSortRule(function(a, b) return a.value < b.value end,
                              function(a, b) return a.weight < b.weight end)
    
    table.sort(cards, func)
end

-- 打牌ai
function AI:discard(co, cards)
    self:calc(co, cards)
    WaitForSeconds(co, 0.5)
    return cards[1]
end

function AI:pong(co, cards, card)
    self:calc(co, cards)
    local cnt = 0
    for _, val in ipairs(cards) do
        if IsTileEqual(val, card) then
            if val.value == Pair or val.value == Tri then
                cnt = cnt + 1
            end
        end
    end
    WaitForSeconds(co, 0.1)
    return cnt
end

function AI:changeToCnt(str)
    local start = string.byte(str, 1, 1)
    local tb = {}
    for i = 1, #str do
        local val = string.byte(str, i, i) - start
        table.insert(tb, val)
    end
    return tb
end

function AI:filter(tb, str)
    local types = self:changeToCnt(str)
    local cnt = #types
    local idx = self:get("idx")
    for i = 1, cnt do
        if tb[idx + i - 1] == nil then return end
    end
    local start = tb[idx].logic_rank
    local bFind = true
    for i = 1, cnt do
        local card = tb[idx + i - 1]
        if card.logic_rank ~= start + types[i] then
            bFind = false
            break
        end
    end
    if not bFind then return end
    local unit = {}
    for _, val in ipairs(s_values) do
        if str == val.key then
            unit = val
            break
        end
    end
    for i = 1, cnt do
        local card = tb[idx + i - 1]
        card.value = math.max(card.value, unit.values[i])
    end
    local offset = unit.offset == 0 and cnt or unit.offset
    self:modify("idx", offset)
    return true
end

function AI:test()
    local ai = AI.new()
    local ranks = {2, 3, 3, 3, 3, 5}
    local tb = {}
    for _, val in ipairs(ranks) do
        table.insert(tb, {logic_rank = val})
    end
    for key, _ in pairs(s_values) do
        print(key)
    end
    ai:set("idx", 1)
    if ai:filter(tb, "abbbbc") then
        print("success")
    else
        print("faild")
    end
end

return AI