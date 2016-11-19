----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：工具入口
----------------------------------------------------------------------

local UIToolsPanel = class("UIToolsPanel", UIBase)

function UIToolsPanel:onCreate()
    self:loadCsb("CoreUI/Tools/ToolsPanel.csb", false)
end

function UIToolsPanel:click_btn_tools()
    self:getScene():createGameObject("UIToolsMain")
end

return UIToolsPanel