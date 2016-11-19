----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：自动更新界面
----------------------------------------------------------------------

local UIAutoUpdate = class("UIAutoUpdate", UIBase)

function UIAutoUpdate:onCreate()
    self:loadCsb("CoreUI/AutoUpdate/AutoUpdate.csb", true)
    self.loading_bar:setPercent(0)
end

function UIAutoUpdate:refreshTips(str)
    self.text:setString(str)
end

function UIAutoUpdate:refreshPercent(percent)
    self.loading_bar:aniPercentTo(percent, 0.3)
end

return UIAutoUpdate