----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：游戏场景
----------------------------------------------------------------------

GameScene = class("GameScene", LuaObject)

-- 构造函数
function GameScene:ctor()
    GameScene.super.ctor(self)
    self.mRootZorder = 0
    self.mGameObjects = {}
    self.mUniqueObjects = {}
    self.mLayers = {}
    self:set("tmp_name_id", 0)
    self:set("application", nil)
    self:set("listen_net_message", false)
end

function GameScene:run()
end

function GameScene:destroy()
    SafeRemoveNode(self.mRoot)
	for _, obj in pairs(self.mGameObjects) do
		Invoke(obj, "releaseLuaObject")
	end
    self:releaseLuaObject()
    self:get("AppBase"):removeScene(self.__cname)
end

function GameScene:getAppBase()
    return self:get("AppBase")
end

--
function GameScene:awaken()
	local tb = self:getGameObjects()
    for _, obj in pairs(tb) do
		Invoke(obj, "awake")
	end
end

function GameScene:coroutine(target, name, ...)
	local co = NewCoroutine(target, name, ...)
	co.mScene = self
	co:resume("start run")
end

function GameScene:setVisible(bVisible)
    self:getRoot():setVisible(bVisible)
end

-- 创建根结点
function GameScene:createRoot()
    local widget = ccui.Widget:create()
    g_RootNode:addChild(widget, self.mRootZorder)
    local size = cc.Director:getInstance():getWinSize()
    widget:setContentSize(size)
    widget:setTouchEnabled(true) -- 防止穿透
    widget:setPosition(0, 0)
    widget:setAnchorPoint(0, 0)
    local function update(dt)
        if not device:isWindows() then
            self:onUpdate(dt)
        else
            xpcall(function() self:onUpdate(dt) end, __G__TRACKBACK__)
        end
    end
    widget:scheduleUpdateWithPriorityLua(update, 0)
    self.mRoot = widget
end

-- 创建图层
function GameScene:createLayer(name)
    local layer = cc.Layer:create()
    self:getRoot():addChild(layer)
    self.mLayers[name] = layer
end

function GameScene:setLayer(name, layer)
    self.mLayers[name] = layer
end

function GameScene:getLayer(name)
    return self.mLayers[name]
end

-- 处理网络消息
function GameScene:onNetMessage(name, resp)
    if not self:get("listen_net_message") then return end
    local list = self:getObjectList()
    for _, val in ipairs(list) do
        Invoke(val, name, resp)
    end
end

function GameScene:getObjectList()
    local list = {}
    for key, val in pairs(self.mGameObjects) do
        if val:getSelf() then
            table.insert(list, val)
        end
    end  
    return list
end

function GameScene:onUpdate(dt)
    -- 清除无用的对象
    local tb = self:getGameObjects()
    for _, obj in pairs(tb) do
        Invoke(obj, "onUpdate", dt)
    end 
end

function GameScene:getGameObjects()
	-- 清除无用的对象
    local tb = {}
    for key, val in pairs(self.mGameObjects) do
        if IsObjectAlive(val) then
            tb[key] = val
        end
    end  
    self.mGameObjects = tb
	return tb
end

function GameScene:getRoot()
    return self.mRoot
end

-- 创建游戏对象
function GameScene:createGameObject(path, ...)
    ReloadLuaModule(path)
    local cls = require(path)
	local ret = cls.new(...)
	if not IsKindOf(cls, "GameObject") then
        ExtendClass(ret, GameObject)
    end
    local name = ret.__cname
    ret.mRoot = self:getRoot()
    ret.mGameScene = self
    self.mGameObjects[name] = ret
	ret:init(...)
    return ret
end

-- 创建无名字的对象
function GameScene:createUnnamedObject(path, ...)
    ReloadLuaModule(path)
    local cls = require(path)
	local ret = cls.new(...)
	if not IsKindOf(cls, "GameObject") then
        ExtendClass(ret, GameObject)
    end
    ret.mRoot = self:getRoot()
    ret.mGameScene = self
	ret:init(...)
    return ret
end

-- 创建唯一的对象
function GameScene:createUniqueObject(path, ...)
    local ret = self:createGameObject(path, ...)
    self.mUniqueObjects[ret.__cname] = ret
    return ret
end

-- 查找游戏对象
function GameScene:findGameObject(name)
    return self.mGameObjects[name]
end

-- 移除游戏对象
function GameScene:removeGameObject(name, args)
    local obj = self:findGameObject(name)
    if obj == nil then return end
    self.mGameObjects[name] = nil
    obj:removeFromScene(args)
end

-- 打印当前的对象表
function GameScene:dumpGameObject()
    for key, val in pairs(self.mGameObjects) do
        print(key)
    end
end

-------------------------------------
-- 场景切换的特效
-------------------------------------
function GameScene:balckOut(co, duration)
    local mask = ccui.Layout:create()
    self:getRoot():addChild(mask, 1)
    local size = cc.Director:getInstance():getWinSize()
    mask:setContentSize(size)
    mask:setTouchEnabled(true) -- 防止穿透
    mask:setBackGroundColor(cc.c3b(0, 0, 0))
    mask:setBackGroundColorOpacity(255)
    mask:setBackGroundColorType(1)
    local tb = 
    {
        cc.FadeOut:create(duration),
        cc.RemoveSelf:create(),
    }
    mask:runAction(cc.Sequence:create(tb))
    if co then WaitForSeconds(co, duration) end
end

