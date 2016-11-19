----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：主城界面
----------------------------------------------------------------------

local UICityPanel = class("UICityPanel", UIBase)

function UICityPanel:onCreate()
    self:loadCsb("ui/main/city/CityPanel.csb", false)
end

return UICityPanel