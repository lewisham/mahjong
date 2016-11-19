----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：组件类
----------------------------------------------------------------------

Component = class("Component", LuaObject)

function Component:getGameObject()
    return self.mGameOject
end

function Component:getAppBase()
    return self:getGameObject():getScene():getAppBase()
end

function Component:coroutine(target, name, ...)
	self:getGameObject():coroutine(target, name, ...)
end

-- 重命名
function Component:rename(name)
    self:getGameObject().mComponents[name] = self
end

-- 查找组件
function Component:getComponent(name)
    return self.mGameOject:getComponent(name)
end

-- 查找游戏对象
function Component:findGameObject(name)
    return self.mGameOject:findGameObject(name)
end

function Component:removeFromObject()
end

function Component:getScene()
    return self:getGameObject():getScene()
end
