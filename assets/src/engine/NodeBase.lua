----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-10-18
-- 描述：node基类
----------------------------------------------------------------------

NodeBase = class("NodeBase", function() return ccui.Widget:create() end)

function NodeBase:init(...)
	self:onCreate(...)
end

-- 创建中
function NodeBase:onCreate()
end

-- 加载csb
function NodeBase:loadCsb(filename, bShield, aniType)
    local node = cc.CSLoader:createNode(filename)
 	self:setContentSize(node:getContentSize())
 	self:setTouchEnabled(bShield)
    self:setPosition(0, 0)
    self:setAnchorPoint(0, 0)

	-- csb 绑定到的节点
	local bindWidget = self

	-- 开场特效
	if aniType == "scaleTo" then
		bindWidget = self:scaleToEnter()
	end

	for k, v in ipairs(node:getChildren()) do
		v:changeParentNode(bindWidget)
	end
	BindToUI(bindWidget, self)
end

function NodeBase:scaleToEnter()
	local size = cc.Director:getInstance():getWinSize()
	local mask = ccui.Layout:create()
	self:addChild(mask)
	mask:setContentSize(size)
	mask:setBackGroundColor(cc.c3b(0, 0, 0))
	mask:setBackGroundColorOpacity(128)
	mask:setBackGroundColorType(1)

	-- 动作结点
	local action = ccui.Widget:create()
	self:addChild(action)
	action:setContentSize(size)
	action:setAnchorPoint(0.5, 0.5)
	action:setPosition(size.width / 2, size.height / 2)

	local root = ccui.Layout:create()
	action:addChild(root)
	root:setContentSize(size)

	-- action
	action:setScale(0.0)
	action:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.25, 1.0)))

	return root
end

------------------------------------
-- 继承GameObject接口
------------------------------------

function NodeBase:coroutine(target, name, ...)
    local co = NewCoroutine(target, name, ...)
	co.mNode = self
	co:resume("start run")
end

-- 从场景中移除
function NodeBase:removeFromScene()
	SafeRemoveNode(self)
end

-- 获得添加到的场景
function NodeBase:getScene()
    return self.mGameScene
end

------------------------------------
-- 列表
------------------------------------

function NodeBase:createListView(name, list, root, cls, cellSize, cpr, dir)
    if type(cls) == "string" then
        cls = require(cls)
    end
    dir = dir or ccui.ScrollViewDir.vertical
    local ret = ListViewHelper.new()
    self.mComponents[name] = ret
    ret.mGameOject = self
    ret.item_cls = cls
    ret.cell_size = cellSize
    ret.mDataList = list
    ret.contetent_size = root:getContentSize()
    ret.cpr = cpr or 1  -- 每行多少列
    ret:setDirection(dir)
    ret:setBounceEnabled(true)
    ret:setContentSize(root:getContentSize())
    ret:init(list)
    ret.items_margin = 6   -- 默认间隔
    ret:setItemsMargin(ret.items_margin)
    root:addChild(ret)
    return ret
end

