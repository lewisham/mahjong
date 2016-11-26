----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-2-15
-- 描述：玩家
----------------------------------------------------------------------

local SCPlayer = class("SCPlayer", GameObject)

function SCPlayer:init(seat, dir)
    self:set("robot", false)
    self:set("sex", math.random(1, 2))
    self:set("tiles", {})
    self:set("turn", false)
    self:set("seat", seat)
    self:set("peng_cnt", 0)
    self:set("gang_cnt", 0)
    self:set("display_dir", dir)
    self:set("ting", {})
    self:createComponent("PlayerCard")
    self:createComponent("DropCard")
    self:createComponent("PongCard")
    self:createComponent("AI")
    self:createComponent("Ting")

    do return end
    local tb = {}
    for i = 1, 16 do
        table.insert(tb, AllocTile(1, 1))
    end
    self:getComponent("PongCard"):onPeng(tb)
end

function SCPlayer:onDeal(tb)
    for _, val in ipairs(tb) do
        table.insert(self:get("tiles"), val)
    end
    self:getComponent("PlayerCard"):onDeal()
end

-- 摸最前的面的牌
function SCPlayer:doDrawFront(co)
    local card = self:findGameObject("DAMahjong"):getNext()
    table.insert(self:get("tiles"), card)
    self:findGameObject("UIWallTile"):removeOne()
    self:getComponent("PlayerCard"):onDraw(card)
    self:set("draw_card", card)
    WaitForSeconds(co, 0.3)
end

-- 摸最后面的牌
function SCPlayer:doDrawLast(co)
    local card = self:findGameObject("DAMahjong"):getLast()
    table.insert(self:get("tiles"), card)
    self:findGameObject("UIWallTile"):removeLast()
    self:getComponent("PlayerCard"):onDraw(card)
    self:set("draw_card", card)
    WaitForSeconds(co, 0.3)
end

function SCPlayer:afterDraw(co)
    --self:getComponent("AI"):isHu(self:get("tiles"))
    local card = self:get("draw_card")
    local ting = self:get("ting")
    if #ting > 0 then
        local hu = false
        if card.rascal == 1 then
            hu = true
        else
            for _, pai in ipairs(self:get("ting")) do
                if card.pai == pai then
                    hu = true
                    break
                end
            end
        end
        if hu then
            self:playSound("hu" .. math.random(1, 3))
            self:findGameObject("DAMahjong"):set("hu", true)
            return
        end
    end
    local cnt = self:calcCardCount(card)
    if cnt > 3 and self:decision(co, card) then
        return self:doAnKong(co, card)
    else
        return self:discard(co)
    end
end

function SCPlayer:play(co)
    local cnt = #self:get("tiles")
    -- 抓牌
    if cnt < 14 then
        self:doDrawFront(co)
    end
    return self:afterDraw(co)
end

function SCPlayer:aiDiscard()
    return self:getComponent("AI"):discard(self:get("tiles"))
end

function SCPlayer:discard(co)
    WaitForFrames(co, 1)
    self:set("card", nil)
    self:set("turn", true)
    local card = nil
    if self:get("robot") then
        card = self:aiDiscard()
        WaitForSeconds(co, 0.5)
    else
        card = self:getComponent("PlayerCard"):play(co) 
    end
    self:set("turn", false)
    self:doDiscard(card)
    self:getComponent("PlayerCard"):removeCard(card)
    self:getComponent("DropCard"):onDrop(co, card)
    self:playDiscardSound(card)
    WaitForSeconds(co, 0.3)
    self:getComponent("PlayerCard"):adjust()
    card.drop_from = self:get("seat")

    -- 
    local ting = self:getComponent("Ting"):calcTing(self:get("tiles"))
    Log(ting)
    self:set("ting", ting)
    return card
end

function SCPlayer:doDiscard(card)
    local tb = {}
    for _, val in ipairs(self:get("tiles")) do
        if card.id ~= val.id then
            table.insert(tb, val)
        end
    end
    self:set("tiles", tb)
end

function SCPlayer:playDiscardSound(card)
    local filename = string.format("mjt%s_%s", card.suit, card.rank)
    self:playSound(filename)
end

function SCPlayer:playSound(filename)
    local sex = self:get("sex") == 1 and "man" or "woman"
    filename = string.format("sound/%s/%s.mp3", sex, filename)
    PlaySound(filename)
end

function SCPlayer:calcCardCount(card)
    if card == nil then return 0 end
    local cnt = 0
    for _, val in ipairs(self:get("tiles")) do
        if IsTileEqual(card, val) then
            cnt = cnt + 1
        end
    end
    return cnt
end

function SCPlayer:removeCard(card, cnt)
    local tb = {}
    local list = {}
    cnt = cnt or 1
    for _, val in ipairs(self:get("tiles")) do
        if IsTileEqual(card, val) and cnt > 0 then
            cnt = cnt - 1
            table.insert(tb, val)
        else
            table.insert(list, val)
        end
    end
    self:set("tiles", list)
    return tb
end

-- 碰
function SCPlayer:doPong(co, card)
    local tb = self:removeCard(card, 2)
    for _, val in ipairs(tb) do
        self:getComponent("PlayerCard"):removeCard(val)
    end
    local idx = self:modify("peng_cnt", 1)
    if idx > 5 then idx = 5 end
    self:playSound("peng" .. idx)
    table.insert(tb, card)
    self:getComponent("PongCard"):onPeng(tb)
    WaitForSeconds(co, 1.0)
    return self:discard(co)
end

-- 明杠
function SCPlayer:doMingKong(co, card)
    local tb = self:removeCard(card, 3)
    for _, val in ipairs(tb) do
        self:getComponent("PlayerCard"):removeCard(val)
    end
    local idx = self:modify("gang_cnt", 1)
    if idx > 3 then idx = 3 end
    self:playSound("gang" .. idx)
    table.insert(tb, card)
    self:getComponent("PongCard"):onKong(tb)
    WaitForSeconds(co, 1.0)
    self:doDrawLast(co)
    return self:afterDraw(co)
end

-- 明杠
function SCPlayer:doAnKong(co, card)
    local tb = self:removeCard(card, 4)
    for _, val in ipairs(tb) do
        self:getComponent("PlayerCard"):removeCard(val)
    end
    local idx = self:modify("gang_cnt", 1)
    if idx > 3 then idx = 3 end
    self:playSound("gang" .. idx)
    self:getComponent("PongCard"):onKong(tb)
    self:getComponent("PlayerCard"):adjust()
    WaitForSeconds(co, 1.0)
    self:doDrawLast(co)
    return self:afterDraw(co)
end

-- 判断是否要碰或杠
function SCPlayer:decision(co, card)
    local cnt = 0
    if self:get("robot") then
        cnt = self:getComponent("AI"):pong(co, self:get("tiles"), card)
        return cnt
    end 
    cnt = self:calcCardCount(card)
    local tb = {}
    if cnt == 2 then
        tb = {DECISION_TYPE.pong}
    elseif cnt > 2 then
        tb = {DECISION_TYPE.kong, DECISION_TYPE.pong}
    end
    local decision = self:findGameObject("UIDecision"):play(co, tb)
    if decision == DECISION_TYPE.pong then
        return 2
    elseif decision == DECISION_TYPE.kong then
        return 3
    end
    return 0
end

return SCPlayer