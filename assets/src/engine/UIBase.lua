----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-10-18
-- 描述：ui基类()
----------------------------------------------------------------------

UIBase = class("UIBase", NodeBase)

function UIBase:init(...)
    self:addTo(self:getParent(), self:getZorder())
	self:onCreate(...)
end

function UIBase:getParent()
    return self.mRoot
end

function UIBase:getZorder()
    return 0
end

