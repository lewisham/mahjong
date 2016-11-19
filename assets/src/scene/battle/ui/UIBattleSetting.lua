----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗设置
----------------------------------------------------------------------

local UIBattelSetting = class("UIBattelSetting", UIBase)

function UIBattelSetting:onCreate()
    self:loadCsb("ui/battle/BattleSetting.csb", true)
    self.Panel_1:onClicked(function() SafeRemoveNode(self) end)
    local auto = self:findGameObject("DAPlayers"):getPlayer():get("robot")
    self.btn_auto:setSelected(auto)
end

function UIBattelSetting:getZorder()
    return 100
end

function UIBattelSetting:click_btn_auto()
    local cur = self:findGameObject("DAPlayers"):getPlayer():get("robot")
    cur = not cur
    self:findGameObject("DAPlayers"):getPlayer():set("robot", cur)
end

function UIBattelSetting:click_btn_sound()
    local app = self:getAppBase()
	app:posScene()
    app:pushScene("SBattle")
end

return UIBattelSetting