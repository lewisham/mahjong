--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local Node = cc.Node

-- 遍历所有子控件
function Node:visitAll(fn)
	local function fnVisitAll(nd, fn)
		for k, child in pairs(nd:getChildren()) do
			local bStop = fn(child)
			if bStop then
				return bStop
			end
            if not tolua.iskindof(child, 'cc.TMXTiledMap') then
                bStop = fnVisitAll(child, fn)
			    if bStop then
				    return bStop
			    end
            end
		end
	end

	return fnVisitAll(self, fn)
end

-- 功能：开始节点定时器
-- 参数fnTimer: 要做的事情
-- 参数bSkipFirst: 不立即执行
-- 例子：g_rootNode:startTimer(function() print(os.time()) end, 2)
function Node:startTimer(fnTimer, seconds, bSkipFirst)
	self:stopAllActions()

	local function fnWrap() -- 出错时关闭定时器
		return TryCatch(fnTimer, function() self:stopAllActions() end)
	end

	local acList = {}
	if bSkipFirst then -- 跳过第一次
		acList:insert(cc.DelayTime:create(seconds))
		acList:insert(cc.CallFunc:create(fnWrap))
	else
		acList:insert(cc.CallFunc:create(fnWrap))
		acList:insert(cc.DelayTime:create(seconds))
	end

	self:runAction(cc.RepeatForever:create(cc.Sequence:create(acList)))
	return self
end

-- 功能: 停止定时器
function Node:stopTimer()
	self:stopAllActions()
	return self
end

----------------------------------------------------------------------
-- 功  能：条件定时重复触发
----------------------------------------------------------------------
function Node:timerWhile(fnCond, seconds, fnOnError)
	local nd = cc.Node:create()
	self:addChild(nd)

	local function fnCatch()
		SafeRemoveNode(nd) -- 出错先删自己, 防止资源泄露
		fnOnError()
	end

	local function fnCondWrap()
		return TryCatch(fnCond, fnCatch)
	end

	local hasFinish = false -- 加这个变量防止cocos2dx bug，最后条件可能被执行多次
	local function fnTimer()
		if hasFinish then
			return
		end
		if not fnCondWrap() then
			hasFinish = true
			SafeRemoveNode(nd)
		end
	end

	nd:startTimer(fnTimer, seconds, true)
end

function Node:getMidPos()
	local sz = self:getContentSize()
	return cc.p(sz.width/2, sz.height/2)
end

function Node:setMidPosition(node, difX, difY)
    difX = difX or 0
    difY = difY or 0
    local pos = self:getMidPos()
    node:setPosition(cc.p(pos.x+difX, pos.y+difY))
end

-- 添加到控件中点
function Node:addChildToMid(node, difX, difY)
    self:addChild(node)
    self:setMidPosition(node, difX, difY)
end

-- 功能: 绑定到屏幕的某个点, 必须确保父节点已加入场景树
-- 例子: nd:bindScreen(0.5, 0.5) -- 绑到屏幕中心
-- 例子: nd:bindScreen(0, 0) -- 绑到屏幕左下角
-- 例子: nd:bindScreen(1, 1) -- 绑到屏幕右上角
function Node:bindScreen(xAnchor, yAnchor)
	assert(xAnchor and yAnchor, "请传入x, y绑定点, 取值范围0.0至1.0!")
	-- 父节点
	local ndParent = self:getParent()
	assert(ndParent, "没父节点屏幕坐标算不出来!")
	local director = cc.Director:getInstance()
	local view = director:getOpenGLView()
	--Log(view:getVisibleRect())
	local rc = view:getVisibleRect()
	-- 世界坐标
	local worldPos = cc.p(rc.x + rc.width * xAnchor, rc.y + rc.height * yAnchor)
	-- 转成自己的坐标
	local selfPos = ndParent:convertToNodeSpace(worldPos)
	self:setPosition(selfPos)
	return self
end

-- 显示控件
function Node:where()
	local sz = self:getContentSize()
	if sz.width < 50 then
		sz.width = 50
	end

	if sz.height < 50 then
		sz.height = 50
	end

	local ly = cc.LayerColor:create(cc.c4b(0,255,0, 128), sz.width, sz.height)
	self:addChild(ly)

	ly:runAction(cc.Sequence:create(
							cc.DelayTime:create(3),
							cc.CallFunc:create(function() SafeRemoveNode(ly) end)
							))
end

function Node:add(child, zorder, tag)
    if tag then
        self:addChild(child, zorder, tag)
    elseif zorder then
        self:addChild(child, zorder)
    else
        self:addChild(child)
    end
    return self
end

function Node:addTo(parent, zorder, tag)
    if tag then
        parent:addChild(self, zorder, tag)
    elseif zorder then
        parent:addChild(self, zorder)
    else
        parent:addChild(self)
    end
    return self
end

function Node:removeSelf()
    self:removeFromParent()
    return self
end

function Node:align(anchorPoint, x, y)
    self:setAnchorPoint(anchorPoint)
    return self:move(x, y)
end

function Node:show()
    self:setVisible(true)
    return self
end

function Node:hide()
    self:setVisible(false)
    return self
end

function Node:move(x, y)
    if y then
        self:setPosition(x, y)
    else
        self:setPosition(x)
    end
    return self
end

function Node:moveTo(args)
    transition.moveTo(self, args)
    return self
end

function Node:moveBy(args)
    transition.moveBy(self, args)
    return self
end

function Node:fadeIn(args)
    transition.fadeIn(self, args)
    return self
end

function Node:fadeOut(args)
    transition.fadeOut(self, args)
    return self
end

function Node:fadeTo(args)
    transition.fadeTo(self, args)
    return self
end

function Node:rotate(rotation)
    self:setRotation(rotation)
    return self
end

function Node:rotateTo(args)
    transition.rotateTo(self, args)
    return self
end

function Node:rotateBy(args)
    transition.rotateBy(self, args)
    return self
end

function Node:scaleTo(args)
    transition.scaleTo(self, args)
    return self
end

----------------------------------------------------------------------
-- 功  能：过一会做某件事情
----------------------------------------------------------------------
function Node:callAfter(seconds, fn)
	local arr = {cc.DelayTime:create(seconds),
					cc.CallFunc:create(fn)}
	self:runAction(cc.Sequence:create(arr))
	return self
end

----------------------------------------------------------------------
-- 功  能：过一会做某件事情(用子节点做定时器, 防止runAction冲突)
----------------------------------------------------------------------
function Node:callAfterEx(seconds, fn)
	local nd = cc.Node:create()
	self:addChild(nd)
	local arr = {cc.DelayTime:create(seconds),
					cc.CallFunc:create(function() SafeRemoveNode(nd) end),
					cc.CallFunc:create(fn)}
	nd:runAction(cc.Sequence:create(arr))
	return self
end

-- 跳过一帧，防止出现视觉bug
function Node:runAtNextFrame(fn)
	local oldVal = cc.Director:getInstance():getTotalFrames()
	local function fnCond()
		if cc.Director:getInstance():getTotalFrames() > oldVal + 1 then -- 跳过2帧
			fn()
			return false
		else
			return true
		end
	end

	self:timerWhile(fnCond, 0.01, function() end)
end

----------------------------------------------------------------------
-- 功  能：改变父节点
----------------------------------------------------------------------
function Node:changeParentNode(newParent)
	local nd = self
	nd:retain() -- 防止被释放
	local parent = nd:getParent()
	if parent then
		parent:removeChild(nd, false)
	end
	newParent:addChild(nd)
	nd:release()
end
----------------------------------------------------------------------
-- 功  能：去掉setParent函数，防止误用
----------------------------------------------------------------------
Node.setParent = nil


--[[
function Node:onUpdate(callback)
    self:scheduleUpdateWithPriorityLua(callback, 0)
    return self
end

-- scheduleUpdate内部不能删除任何节点，否则可能会闪退
Node.scheduleUpdate = Node.onUpdate
]]--

function Node:onNodeEvent(eventName, callback)
    if "enter" == eventName then
        self.onEnterCallback_ = callback
    elseif "exit" == eventName then
        self.onExitCallback_ = callback
    elseif "enterTransitionFinish" == eventName then
        self.onEnterTransitionFinishCallback_ = callback
    elseif "exitTransitionStart" == eventName then
        self.onExitTransitionStartCallback_ = callback
    elseif "cleanup" == eventName then
        self.onCleanupCallback_ = callback
    end
    self:enableNodeEvents()
end

function Node:enableNodeEvents()
    if self.isNodeEventEnabled_ then
        return self
    end

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter_()
        elseif state == "exit" then
            self:onExit_()
        elseif state == "enterTransitionFinish" then
            self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
            self:onExitTransitionStart_()
        elseif state == "cleanup" then
            self:onCleanup_()
        end
    end)
    self.isNodeEventEnabled_ = true

    return self
end

function Node:disableNodeEvents()
    self:unregisterScriptHandler()
    self.isNodeEventEnabled_ = false
    return self
end


function Node:onEnter()
end

function Node:onExit()
end

function Node:onEnterTransitionFinish()
end

function Node:onExitTransitionStart()
end

function Node:onCleanup()
end

function Node:onEnter_()
    self:onEnter()
    if not self.onEnterCallback_ then
        return
    end
    self:onEnterCallback_()
end

function Node:onExit_()
    self:onExit()
    if not self.onExitCallback_ then
        return
    end
    self:onExitCallback_()
end

function Node:onEnterTransitionFinish_()
    self:onEnterTransitionFinish()
    if not self.onEnterTransitionFinishCallback_ then
        return
    end
    self:onEnterTransitionFinishCallback_()
end

function Node:onExitTransitionStart_()
    self:onExitTransitionStart()
    if not self.onExitTransitionStartCallback_ then
        return
    end
    self:onExitTransitionStartCallback_()
end

function Node:onCleanup_()
    self:onCleanup()
    if not self.onCleanupCallback_ then
        return
    end
    self:onCleanupCallback_()
end

-- 绑定粒子(跟随节点移动)
function Node:setParticleGrouped()
	self:visitAll(function(v)
				local disNode = v:getDisplayRenderNode()
				if disNode then
					if tolua.iskindof(disNode, 'cc.ParticleSystem') then
						disNode:setPositionType(cc.POSITION_TYPE_GROUPED)
					end
				end
			end)
end
