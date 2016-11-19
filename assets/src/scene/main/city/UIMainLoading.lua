----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：主城loading
----------------------------------------------------------------------

local UIMainLoading = class("UIMainLoading", UIBase)

function UIMainLoading:onCreate()
    self:loadCsb("MainUI/Main/MainLoading.csb", true)
    self.loading_bar:setPercent(0)
end

function UIMainLoading:play(co)
    local interval = 1.0
    self.loading_bar:aniPercentTo(100, interval)
    WaitForSeconds(co, interval)
    SafeRemoveNode(self)
end

return UIMainLoading