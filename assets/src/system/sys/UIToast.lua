----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：Toast信息
----------------------------------------------------------------------

local UIToast = class("UIToast", UIBase)

function UIToast:onCreate()
    self:loadCsb("system/system//Toast.csb", false)
    self.Node_1:setVisible(false)
    self.Node_1:setCascadeOpacityEnabled(true)
end

function UIToast:show(str)
    local node = self.Node_1
    node:setVisible(true)
    node:setOpacity(255)
    self.text:setString(str)
    local w = self.text:getContentSize().width
    local h = self.bg:getContentSize().height
    w = w + 50
    self.bg:setContentSize(cc.size(w, h))

    node:stopActionByTag(101)
    local tb = 
    {
        cc.DelayTime:create(1.5),
        cc.FadeOut:create(0.5),
        cc.Hide:create(),
    }
    local act = cc.Sequence:create(tb)
    act:setTag(101)
    node:runAction(act)
end

return UIToast