-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1280,
    height = 720,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
            return {autoscale = "SHOW_ALL"}
    end
}

cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("res/")

CC_USE_FRAMEWORK = true
require "cocos.init"
print = release_print -- 打印函数
old_require = require

-- 开始内存回收
function StartCollectGarbage()
	collectgarbage("restart")
	collectgarbage("collect")
	collectgarbage("setpause", 150)
    collectgarbage("setstepmul", 5000)
end

-- 停止垃圾回收
function StopCollectGarbage()
	collectgarbage("stop")
end

-- 主函数
local function main()
    cc.Director:getInstance():setAnimationInterval(1.0 / 42)
	local tp = cc.Application:getInstance():getTargetPlatform()
    -- 平台自定义
    if tp == 0 then 
        require("src.platform.win32")
	end
	-- 下载目录
	DOWD_LOAD_DIR = cc.FileUtils:getInstance():getWritablePath() .. "download/"
	cc.FileUtils:getInstance():createDirectory(DOWD_LOAD_DIR)
	print("写入地址", cc.FileUtils:getInstance():getWritablePath())
	print("下载地址", DOWD_LOAD_DIR)
    cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)

	-- 开始lua内存回收
    StartCollectGarbage()
	-- 创建场景
    local scene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
	    cc.Director:getInstance():replaceScene(scene)
    else
	    cc.Director:getInstance():runWithScene(scene)
    end
    g_RootNode = scene

	-- 添加搜索(自动更新的在前)
    local arr = cc.FileUtils:getInstance():getSearchPaths()
	table.insert(arr, 1, cc.FileUtils:getInstance():getWritablePath())
    -- 非开发环境下，
    if not DEVELOPER_ENV then
        table.insert(arr, 1, DOWD_LOAD_DIR)
		table.insert(arr, 1, DOWD_LOAD_DIR .. "res/")
    end
    cc.FileUtils:getInstance():setSearchPaths(arr)

	require("SrcLuaPath")
	require = function(filename, ...)
		local path = SrcLuaPath[filename] or filename
		return old_require(path, ...)
	end

    require("InitEngine")
	require("Channel")
	Log("搜索目径:", arr)
	Log("渠道信息", GetChannelInfo())
	-- 开始自动更新
	require("AppBase"):createInstacne()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    --MsgBox(msg)
    --print(msg)
end
