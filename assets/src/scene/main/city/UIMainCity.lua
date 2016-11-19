----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：主城界面
----------------------------------------------------------------------

local UIMainCity = class("UIMainCity", UIBase)

function UIMainCity:onCreate(filename)
    local sea = cc.LayerGradient:create(cc.c4b(0,55,120,255), cc.c4b(40,150,200,255), cc.p(0.9, 0.9))
    self:addChild(sea)
    self:loadCsb(filename, true)
    self.scrollview:setScrollBarEnabled(false)
    self:createBuildiings()
end

function UIMainCity:createBuildiings()
    local children = self.building_root:getChildren()
    for _, child in pairs(children) do
        local name = child:getName()
        print(name)
        local filename = string.format("ui/main/city/buildings/%s.csb", name)
        local tb = {}
        local node = LoadCsb(filename, tb, false)
        self.building_root:addChild(node)
        node:setPosition(cc.p(child:getPosition()))
        node:setScale(child:getScale())
        tb.btn:onClicked(function() self:clickBuild(child) end)
    end
end

function UIMainCity:clickBuild(child)
    print(child:getName())
    self:getAppBase():replaceScene("SBattle")
end

return UIMainCity