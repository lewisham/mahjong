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

local Widget = ccui.Widget

function Widget:onTouch(callback)
    self:addTouchEventListener(function(sender, state)
        local event = {x = 0, y = 0}
        if state == 0 then
            event.name = "began"
        elseif state == 1 then
            event.name = "moved"
        elseif state == 2 then
            event.name = "ended"
        else
            event.name = "cancelled"
        end
        event.target = sender
        callback(event)
    end)
    return self
end

function Widget:onClicked(callback)
	assert(type(callback) == 'function')
    local function touchEvent(_sender, eventType)
		if eventType == ccui.TouchEventType.ended then
            if PlayBtnSound then PlayBtnSound(self.sound_type) end
			callback(self)
		end
	end
    -- 设置回调引用,新手引导用
    self._onClickedHandler = callback
	self:addTouchEventListener(touchEvent)
    return self
end


local LoadingBar = ccui.LoadingBar
-- 功能: 进度条动画
-- 参数second: 多少秒
-- 参数to: 目标进度0~100
function LoadingBar:aniPercentTo(to, second, callback)
	assert(second, '请填写需要多少时间')
	if to < 0 then
		to = 0
	end

	if to > 100 then
		to = 100
	end

	local frameTime = cc.Director:getInstance():getAnimationInterval()
	local diff = to - self:getPercent()
	local per = diff/second * frameTime -- 每帧更新百分几

	self:unscheduleUpdate()

	if per == 0 then
		return
	end

	local function fnUpdate()
		local old = self:getPercent()
		local new = old + per
		if per > 0 then
			if new >= to then
				new = to
				self:setPercent(new)
				self:unscheduleUpdate() -- 进度条更新完毕
                if callback then callback() end
			else
				self:setPercent(new)
			end
		else
			if new <= to then
				new = to
				self:setPercent(new)
                if callback then callback() end
				self:unscheduleUpdate() -- 进度条更新完毕
			else
				self:setPercent(new)
			end
		end
	end

	self:scheduleUpdateWithPriorityLua(fnUpdate, 0)
end



