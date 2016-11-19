----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：工具主界面
----------------------------------------------------------------------

local UIToolsMain = class("UIToolsMain", UIBase)

function UIToolsMain:onCreate()
    self:loadCsb("CoreUI/Tools/ToolsMain.csb", true)
    self.Panel_1:onClicked(function() self:click_btn_exit() end)
end

function UIToolsMain:click_btn_publish_res()
    self:getScene():createGameObject("SCPublish")
end

function UIToolsMain:click_btn_debug()
    ReloadLuaModule("CustomDebug")
end

function UIToolsMain:click_btn_exit()
    self:removeFromScene()
end

return UIToolsMain