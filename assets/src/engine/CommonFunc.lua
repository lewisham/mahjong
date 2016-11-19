----------------------------------------------------------------------
-- 日期：2016-3-31
-- 描述：通用函数
----------------------------------------------------------------------

-- 把node里的子控件挂载在ui对象上
function BindToUI(widget, obj)
    -- 按钮事件
    local function buttonEventHandler(child)
        local name = child:getName()
        local func = obj["click_"..name]
        if func then 
            func(obj, child)
        else
            print("no function", obj.__cname, "click_"..name)
        end
    end

    local function visitChild(child)
        local name = child:getName()
		if (not name) or name == '' then
			return
		end
        --print(name)
		obj[name] = child -- 
		if tolua.iskindof(child, 'ccui.Button') or tolua.iskindof(child, 'ccui.CheckBox') then
			child:onClicked(function() buttonEventHandler(child) end)
		end
    end
    widget:visitAll(visitChild)
end

-- 加载csb
function LoadCsb(filename, obj, bShield)
    local widget = ccui.Widget:create()
    local node = cc.CSLoader:createNode(filename)
 	widget:setContentSize(node:getContentSize())
 	widget:setTouchEnabled(bShield) --
    widget:setPosition(0, 0)
    widget:setAnchorPoint(0, 0)
	for k, v in pairs(node:getChildren()) do
		v:changeParentNode(widget)
	end
	if obj then
		BindToUI(widget, obj)
	end
    return widget
end

-- 移除某个结点
function SafeRemoveNode(node)
    if node == nil or tolua.isnull(node) then return end
    node:removeFromParent(true)
end

-- 弹出消息框
function MsgBox(content)
    content = content or ""
    CCMessageBox(content, "")
end

-- 调用
function Invoke(target, name, ...)
    if target == nil then return end
    local func = target[name]
    if func == nil then return end
    return func(target, ...)
end

-- 重新加载lua文件
function ReloadLuaModule(name)
    if not device:isWindows() then return require(name) end
	local path = SrcLuaPath[name] or name
    package.loaded[path] = nil
    return require(name)
end

function ReloadLua(name)
	local path = SrcLuaPath[name] or name
    package.loaded[path] = nil
    return require(name)
end

-- 生成数据文件
function CreateDatasFile()
    if not device:isWindows() then return end
    local sDir = "data"
    local tb = {}
    for path, _ in io.popen('dir ' .. sDir .. ' /a-D/b/s'):lines() do
        local filename = string.match(path, ".+\\([^\\]*%.%w+)$")
        local idx = filename:match(".+()%.%w+$")
        filename = filename:sub(1, idx - 1)
        if filename ~= "DataFiles" then
            table.insert(tb, filename)
        end
    end
    local str = TableToString(tb, 1, true, 1)
    str = "return "..str
    local path = "data\\DataFiles.lua"
	local file = io.open(path, "w")
	file:write(str, "\n")
	file:flush()
	file:close()
end

-- 加载数据文件
function LoadDataFile(name)
    local data = require("data." .. name)
    local tb = {}
    function tb:get(id)
        local ret = data[id]
        assert(ret, "cann't find data ".. name .." ".. id)
        return clone(ret)
    end

    function tb:getAll()
        local list = {}
        for _, val in pairs(data) do
            table.insert(list, clone(val))
        end
        return list
    end
    setmetatable(data, {__index=tb})
    _G[name] = data
end

-- 继承类
function ExtendClass(obj, cls)
    local parent = cls.new()
    if parent.super then
        ExtendClass(obj, parent.super)
    end

    -- 继承变量
    for name, val in pairs(parent) do
        if obj[name] == nil and name ~= "class" then
            --print("value", name, obj[name], val)
            obj[name] = val
        end
    end

    -- 继承方法
    for name, val in pairs(cls) do
        if obj[name] == nil then
            --print("function", name, obj[name], val)
            obj[name] = val
        end

        if name == "getComponent" then
            obj[name] = val
        end
    end
end

-- 是否属于某个类
function IsKindOf(cls, name)
    if cls.__cname == name then return true end
    if cls.super then
        return IsKindOf(cls.super, name)
    end
    return false
end



-- 对象是否还存活
function IsObjectAlive(obj)
	if obj == nil then return false end
	local t = type(obj)
	if t == "userdate" then
		return not tolua.isnull(obj)
	elseif obj.getSelf then
		return obj:getSelf()
	end
	return false
end

-- 调试对象
function DebugGameObject(obj)
    local name = obj.__cname
    local cls = ReloadLuaModule(name)
    --print("DebugGameObject", name)
    for key, val in pairs(cls) do
        if type(val) == "function" then
            obj[key] = val
        end
    end
end

-- 创建界面
function CreateWindow(name, ...)
	local scene = AppBase:getInstance():getRunningScene()
	if scene == nil or scene:getSelf() == nil then return end
	return scene:createGameObject(name, ...)
end

-- 功  能：生成多重排序规则
function MakeSortRule(...)
	local fnList = {...}
	local fnMore = function(x, y)
		for i = 1, #fnList do
			local fn = fnList[i]
			if fn(x, y) then
				return true
			elseif fn(y, x) then
				return false
			end

		end
		return false
	end
	return fnMore
end

function PlaySound(filename)
    if DISABLE_SOUND then return end
    cc.SimpleAudioEngine:getInstance():playEffect(filename)
end

function PlayMusic(filename)
    if DISABLE_MUSIC then return end
    cc.SimpleAudioEngine:getInstance():playMusic(filename)
end