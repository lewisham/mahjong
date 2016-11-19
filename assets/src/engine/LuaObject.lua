----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：lua 对象类
----------------------------------------------------------------------

LuaObject = class("LuaObject")

local instance_id = 0

-- 构造函数
function LuaObject:ctor()
    self.mAutoAddToScene = true
    self.mProperty = {}
    self.mSchedulers = {}
    self.mTimers = {}       -- 定时器
    self.mRoot = nil
    self.mRefCnt   = 1
    self.mGameOject = nil
	self.mInstanceId = instance_id + 1
    instance_id = instance_id + 1
    self.mZorder = 0
end

function LuaObject:init()
end

-- 获得实例id
function LuaObject:getInstanceId()
	return self.mInstanceId
end

-- 获取缓存数据
function LuaObject:get(name)
    local ret = self.mProperty[name]
    return ret
end

-- 设置缓存数据
function LuaObject:set(name, value)
    self.mProperty[name] = value
end

-- 修改数据
function LuaObject:modify(name, value)
    self.mProperty[name] = self.mProperty[name] + value
    return self.mProperty[name]
end

function LuaObject:releaseLuaObject()
    self.mRefCnt = self.mRefCnt - 1
end

-- 弱引用
function LuaObject:getSelf()
    if self.mRefCnt < 1 then return nil end
    return self
end
