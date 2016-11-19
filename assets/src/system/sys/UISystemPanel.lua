----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：系统按钮
----------------------------------------------------------------------

local UISystemPanel = class("UISystemPanel", UIBase)

function UISystemPanel:onCreate()
    self:loadCsb("CoreUI/System/SystemPanel.csb", false)
end

function UISystemPanel:click_btn_exit()
    os.exit()
end

return UISystemPanel