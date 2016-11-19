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
    local app = self:getAppBase()
	app:posScene()
    app:pushScene("SBattle")
end

function UIBattlePanel:click_btn_speed()
    DebugGameObject(self)
    SafeRemoveNode(self.test_model)
    local id = 20004
    local name = tostring(id)
    local factory = db.DBCCFactory:getInstance()
    LoadMonsterDragonBones(id)
    local action = "skill1"
    local model = factory:buildArmatureNode(name .. "_" .. action, name)
    model:setTag(101)
    model:getAnimation():play()
    g_MonsterRoot:addChild(model)
    model:setPosition(cc.p(0, 200))
    self.test_model = model

    local filename = "New/" .. name .."/" .."skeleton.xml"
    local xml = cc.FileUtils:getInstance():getStringFromFile(filename)
    for k, v in string.gfind(xml, "name=(%w+)") do 
        print(k, v)
    end

end

return UIBattlePanel