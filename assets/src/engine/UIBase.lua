----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-10-18
-- 描述：ui基类()
----------------------------------------------------------------------

UIBase = class("UIBase", NodeBase)

function UIBase:init(...)
	self.mRoot:addChild(self)
	self:onCreate(...)
end

