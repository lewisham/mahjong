----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：app
----------------------------------------------------------------------

AppBase = class("AppBase", LuaObject)

-- 场景zorder顺序
SCENE_ZORDER =
{
    normal = 0, -- 普通
    net = 2,    -- 网络层
    syterm = 5, -- 系统(对话框,提示信息)
    tools = 4,
}

local mInstance = nil
function AppBase:getInstance()
    return mInstance
end

function AppBase:createInstacne()
	mInstance = AppBase.new()
    mInstance:init()
end

function AppBase:init()
    self.mSceneList = {}
    self.mSceneStack = {}
    self.mRunningScene = nil
    math.randomseed(os.clock())
    StartCoroutine(self, "play")
end

function AppBase:play(co)
    self:loadConfig()
    --self:createScene("STools")
    --self:createScene("SSystem")
	--self:createScene("SNetWork")
    --self:createScene("SAutoUpdate"):play(co, GetChannelInfo().url)
    --self:runScene("SMainHome")
    --PulishToCurrent()
    self:runScene("SBattle")
end

-- 创建场景
function AppBase:createScene(name, ...)
    ReloadLuaModule(name)
    local scene = require(name).new()
    scene:set("AppBase", self)
    scene:createRoot()
    scene:init(...)
    self.mSceneList[scene.__cname] = scene
    return scene
end

-- 运行场景
function AppBase:runScene(name, ...)
    local scene = self:createScene(name, ...)
    table.insert(self.mSceneStack, 1, scene)
    scene:run()
end

function AppBase:getRunningScene()
	return self.mSceneStack[1]
end

-- 替换场景
function AppBase:replaceScene(name, ...)
    for _, scene in ipairs(self.mSceneStack) do
        if scene:getSelf() then
            scene:destroy()
        end
    end
    self.mSceneStack = {}
    self:runScene(name, ...)
end

-- 添加场景
function AppBase:pushScene(name, ...)
    for _, scene in ipairs(self.mSceneStack) do
        if scene:getSelf() then
            scene:getRoot():setVisible(false)
        end
    end
    local scene = self:createScene(name, ...)
    table.insert(self.mSceneStack, 1, scene)
    scene:run()
end

function AppBase:posScene()
	local pop = self.mSceneStack[1]
	if pop and pop:getSelf() then
        pop:destroy()
		table.remove(self.mSceneStack, 1)
    end
	for _, scene in ipairs(self.mSceneStack) do
        if scene:getSelf() then
            scene:getRoot():setVisible(true)
        end
    end
end

-- 查找场景
function AppBase:findScene(name)
    return self.mSceneList[name]
end

-- 移除场景
function AppBase:removeScene(name)
    self.mSceneList[name] = nil
end

-- 加载策划配置数据
function AppBase:loadConfig()
    local t1 = os.clock()
	local c1 = collectgarbage("count")
    print("开始加载数据资源", c1)
    -- windows平台下加载文件
    CreateDatasFile() 
    for _, name in pairs(require("data.DataFiles")) do
        LoadDataFile(name)
    end
	local c2 = collectgarbage("count")
    print("结束加载数据资源, 总耗时", os.clock() - t1, c2, c2 - c1)
end

return AppBase

