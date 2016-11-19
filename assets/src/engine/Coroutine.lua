----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：协程
----------------------------------------------------------------------

Coroutine = class("Coroutine")

function Coroutine:init(func, target)
	self.mUpdateFunc = nil		-- 更新函数接口
	self.mScene = nil			-- 所在的场景
    self.mNode = nil            -- 所运行的结点
    self.coroutine = nil
    self.mSchedulerId = nil
    self.mAlive = true
	local scheduler = cc.Director:getInstance():getScheduler()
    self.mSchedulerId = scheduler:scheduleScriptFunc(function(dt) self:onUpdate(dt) end, 0, false)
    local co = coroutine.create(func)
    self.coroutine = co
    return true
end

-- 清除协程
function Coroutine:cleanup()
    if not self.mAlive then return end
    self.mAlive = false
    if self.mSchedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mSchedulerId)
        self.mSchedulerId = nil
    end
end

-- 每帧更新
function Coroutine:onUpdate(dt)
	-- 场景判断是否存活
	if self.mScene and self.mScene:getSelf() == nil then
        self.mNeedCleanup = true
        self:resume()
		self:cleanup()
		return
	end
    -- 绑定的结点是否存活
    if self.mNode and tolua.isnull(self.mNode) then
        self.mNeedCleanup = true
        self:resume()
        self:cleanup()
		return
    end
    if self.mUpdateFunc then self.mUpdateFunc(dt) end
end

-- 暂停
function Coroutine:pause(name, timeout)
    self.timeout = timeout
    coroutine.yield()
    -- 强制杀死协程
    if self.mNeedCleanup then
        NEED_TRACK_COROUTINE_ERROR = false
        local errors = nil
        errors = errors + 1
    end
end

-- 设置更新函数
function Coroutine:setUpdateFunc(handler)
    self.mUpdateFunc = handler
end

-- 恢复
function Coroutine:resume(name)
    self.mUpdateFunc = nil
    local success, yieldType, yieldParam = coroutine.resume(self.coroutine, self)
    if not success then
        print("resume failed", success, yieldType, yieldParam)
        self:cleanup()
        return
    end
    local status = coroutine.status(self.coroutine)
    --print("resume", name, status)
    -- 判断协程是否结束
    if status == "dead" then
    	self:cleanup()
    end
end
