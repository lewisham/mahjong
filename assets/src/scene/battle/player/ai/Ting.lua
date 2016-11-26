----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-2-15
-- 描述：听牌算法
----------------------------------------------------------------------

local disable_keys_tb = {8, 9, 17, 18, 26, 27}
local disable_keys = {}
for _, val in ipairs(disable_keys_tb) do
    disable_keys[val] = 1
end

local union_keys = {}
local function calcUnion(start)
    local offsets = {-2, -1, 1, 2}
    for i = 1, 9 do
        local tb = {}
        for _, offset in ipairs(offsets) do
            local idx = offset + i
            if idx > 0 and idx < 10 then
                table.insert(tb, idx + start)
            end
        end
        union_keys[i + start] = tb
    end
end

calcUnion(0)
calcUnion(9)
calcUnion(18)

local Ting = class("Ting", Component)

function Ting:calcTing(cards)
    --local t1 = os.clock()
    local pai = {}
    for i = 1, 34 do
        pai[i] = 0
    end
    local laizi = 0
    for _, card in ipairs(cards) do
        if card.rascal == 1 then
            laizi = laizi + 1
        else
            pai[card.pai] = pai[card.pai] + 1
        end
    end
    local tings = {}
    for i = 1, 34 do
        local tb = clone(pai)
        tb[i] = tb[i] + 1
        if self:calc(tb, laizi) then
            table.insert(tings, i)
        end
    end
    --print("+++++++++++++++++cost time", os.clock() - t1)
    --Log(tings)
    return tings
end

function Ting:calc(pai, laizi)
    local cnt = 0
    for _, val in ipairs(pai) do
        cnt = cnt + val
    end
    self:set("jiang", 0)
    self:set("pai", pai)
    self:set("count", cnt)
    self:set("laizi", laizi)
    return self:comb()
end

function Ting:comb()
    if self:get("count") == 0 then return true end
    local tb = self:get("pai")
    for key, val in ipairs(tb) do
        -- 刻子判断
        if val >= 3 then
            tb[key] = tb[key] - 3
            self:modify("count", -3)
            if self:comb() then return true end
            self:modify("count", 3)
            tb[key] = tb[key] + 3
        end
        -- 对子判断
        if val >= 2 then
            if self:get("jiang") == 0 then
                self:set("jiang", 1)
                tb[key] = tb[key] - 2
                self:modify("count", -2)
                if self:comb() then return true end
                tb[key] = tb[key] + 2
                self:modify("count", 2)
                self:set("jiang", 0)
            elseif self:get("laizi") > 0 then
                tb[key] = tb[key] - 2
                self:modify("count", -2)
                self:modify("laizi", -1)
                if self:comb() then return true end
                self:modify("laizi", 1)
                self:modify("count", 2)
                tb[key] = tb[key] + 2
            end
        end
        -- 组合成顺子
        if key < 28 and val > 0 and not disable_keys[key] and tb[key + 1] > 0 and tb[key + 2] > 0 then
            tb[key] = tb[key] - 1
            tb[key + 1] = tb[key + 1] - 1
            tb[key + 2] = tb[key + 2] - 1
            self:modify("count", -3)
            if self:comb() then return true end
            self:modify("count", 3)
            tb[key] = tb[key] + 1
            tb[key + 1] = tb[key + 1] + 1
            tb[key + 2] = tb[key + 2] + 1
        end

        -- 孤单的牌
        if val == 1 then 
            -- 可用癞子替换
            if self:get("laizi") > 0 then
                -- 用一个癞子组成将
                if self:get("jiang") == 0 then
                    self:set("jiang", 1)
                    tb[key] = tb[key] - 1
                    self:modify("count", -1)
                    self:modify("laizi", -1)
                    if self:comb() then return true end
                    tb[key] = tb[key] + 1
                    self:modify("laizi", 1)
                    self:modify("count", 1)
                    self:set("jiang", 0)
                end

                -- 用癞子与隔壁的牌组合成顺子
                if key < 28 then
                    local uk = union_keys[key]
                    for _, union in ipairs(uk) do
                        if tb[union] > 0 then
                            tb[key] = tb[key] - 1
                            tb[union] = tb[union] - 1
                            self:modify("count", -2)
                            self:modify("laizi", -1)
                            if self:comb() then return true end
                            self:modify("laizi", 1)
                            self:modify("count", 2)
                            tb[key] = tb[key] + 1
                            tb[union] = tb[union] + 1
                        end
                    end
                end

                -- 用两个癞子与单排组成刻子
                if self:get("jiang") == 1 and self:get("laizi") >= 2 then
                    tb[key] = tb[key] - 1
                    self:modify("count", -1)
                    self:modify("laizi", -2)
                    if self:comb() then return true end
                    tb[key] = tb[key] + 1
                    self:modify("laizi", 2)
                    self:modify("count", 1)
                end
            end
            return false 
        end
    end
    return false
end


function Ting:test()
    local tb = {0, 1, 1, 1, 1, 1, 1, 1, 0,
                0, 0, 0, 0, 0, 1, 1, 0, 0,
                0, 0, 0, 0, 0, 1, 0, 0, 0,
                0, 0, 0, 0, 0, 0, 0
                }
    local t1 = os.clock()
    local obj = Ting.new()
    local tings = {}
    for i = 1, 34 do
        local pai = clone(tb)
        pai[i] = pai[i] + 1
        --print(i)
        if obj:calc(pai, 3) then
            table.insert(tings, i)
        end
    end
    print("+++++++++++++++++cost time", os.clock() - t1)
    Log(tings)
end

return Ting