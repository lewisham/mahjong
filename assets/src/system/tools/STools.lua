----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：工具场景
----------------------------------------------------------------------

local STools = class("STools", GameScene)

function STools:ctor()
    STools.super.ctor(self)
    self.mRootZorder = SCENE_ZORDER.tools
end

function STools:init()
    self:getRoot():setTouchEnabled(false)
    self:createGameObject("UIToolsPanel")
end

return STools