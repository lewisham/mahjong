----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：对话框
----------------------------------------------------------------------

local UIDialog = class("UIDialog", UIBase)

function UIDialog:onCreate()
    self:loadCsb("CoreUI/System/Dialog.csb", true)
	self:setVisible(false)
end

function UIDialog:show(title, content, yesFunc, noFunc)
    self:setVisible(true)
    self.content:setString(content)
    self.yesFunc = yesFunc
    self.noFunc = noFunc
end

function UIDialog:click_btn_yes()
    local callback = self.yesFunc
    self:removeFromScene()
    if callback then 
        callback()
    end
end

function UIDialog:click_btn_no()
    local callback = self.noFunc
    self:removeFromScene()
    if callback then 
        callback()
    end
end

return UIDialog