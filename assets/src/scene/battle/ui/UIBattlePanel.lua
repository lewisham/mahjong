----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：战斗层ui
----------------------------------------------------------------------

local UIBattlePanel = class("UIBattlePanel", UIBase)

function UIBattlePanel:onCreate()
    self:loadCsb("ui/battle/BattlePanel.csb", false)
end

function UIBattlePanel:click_btn_restart()
    self:getScene():createGameObject("UIBattleSetting") 
end

return UIBattlePanel