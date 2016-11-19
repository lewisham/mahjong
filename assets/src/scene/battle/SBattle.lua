----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：战斗场景
----------------------------------------------------------------------

local SBattle = class("SBattle", GameScene)

function SBattle:ctor()
    SBattle.super.ctor(self)
    g_BattleScene = self
end

function SBattle:run()
    require("BattleConst")
    self:createGameObject("DAMahjong")
    self:createGameObject("DAPlayers")
    self:coroutine(self, "play")
end

function SBattle:play(co)
    self:createGameObject("UIBattleScene")
    self:balckOut(co, 0.1)
    PlayMusic("sound/bgm_battle1.mp3")
    self:createGameObject("UIDecision")
    self:createGameObject("UIBattlePanel")
    self:findGameObject("DAMahjong"):shuffle()
    self:createGameObject("UIWallTile")
    self:findGameObject("DAPlayers"):createPlayers()
    self:deal(co)
    self:loop(co)
    self:gameEnd(co)
end

-- 发牌
function SBattle:deal(co)
    self:createGameObject("UIDice"):play(co, 1)
    self:findGameObject("UIWallTile"):deal(co)
    self:removeGameObject("UIDice")
    self:findGameObject("DAPlayers"):sortTiles()
    WaitForSeconds(co, 0.2)
    self:createGameObject("UIDice"):play(co, 2)  
    self:findGameObject("UIWallTile"):displayRascal()
    WaitForSeconds(co, 1.5)
    self:removeGameObject("UIDice")
    self:findGameObject("DAPlayers"):sortTiles()
    WaitForSeconds(co, 0.3)
end

function SBattle:loop(co)
    local idx = self:findGameObject("DAPlayers"):get("dealer")
    local card = nil
    while true do
        if self:findGameObject("DAMahjong"):isOver() then
            break
        end
        local player = self:findGameObject("DAPlayers"):getPlayer(idx)
        self:findGameObject("UIBattleScene"):onTurn(player)
        card = player:play(co)
        while card do
            local jumper = self:findGameObject("DAPlayers"):afterDiscard(idx, card)
            if jumper == nil then break end
            cnt = jumper:decision(co, card)
            if cnt == 2 then
                self:findGameObject("UIBattleScene"):onTurn(jumper)
                player:getComponent("DropCard"):removeCurrent()
                card = jumper:doPong(co, card)
                idx = jumper:get("seat")
            elseif cnt >= 3 then
                self:findGameObject("UIBattleScene"):onTurn(jumper)
                player:getComponent("DropCard"):removeCurrent()
                card = jumper:doMingKong(co, card)
                idx = jumper:get("seat")
            else
                break
            end
        end
        idx = idx + 1
        if idx > 4 then
            idx = 1
        end
        WaitForSeconds(co, 0.8)
    end
end

function SBattle:gameEnd(co)
    local app = self:getAppBase()
	app:posScene()
    app:pushScene("SBattle")
end

return SBattle