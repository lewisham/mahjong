----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：协程基本等待
----------------------------------------------------------------------

local mCoroutineId = 0
NEED_TRACK_COROUTINE_ERROR = true

_CE_TRACKBACK_ = function(msg)
    if not NEED_TRACK_COROUTINE_ERROR then
        NEED_TRACK_COROUTINE_ERROR = true
        return
    end
    print("协程出错")
    local msg = debug.traceback(msg, 3)
	print(msg)
end

-- 创建新的协程
function NewCoroutine(target, name, ...)
	local func = target[name]
    local args = {...}
    if func == nil then
        assert("start coroutine can't find function name by "..name)
        return false
    end

    local co = nil
    local function callback()
        if type(target) == "function" then
            func(co, unpack(args))
        else
            func(target, co, unpack(args))
        end
    end

	-- 协程主函数
    local function executeFunc()
        if not device:isWindows() then
            callback()
        else
            xpcall(function() callback() end, _CE_TRACKBACK_)
        end
    end
    co = Coroutine.new()
    co:init(executeFunc)
	return co
end

-- 开启协程
function StartCoroutine(target, name, ...)
    local co = NewCoroutine(target, name, ...)
    co:resume("start run")
	return co
end

-- 等待数秒
function WaitForSeconds(co, seconds)
    WaitForFrames(co, 1)
    local function onUpdate(dt)
        if seconds > 0 then
            seconds = seconds - dt
        end
        if seconds <= 0 then
            co:resume("WaitForSeconds")
        end
    end
    co:setUpdateFunc(onUpdate)
    co:pause("WaitForSeconds")
end

-- 等待数帧
function WaitForFrames(co, frames)
    local function onUpdate(dt)
        if frames > 0 then
            frames = frames - 1
        end
        if frames <= 0 then
            co:resume("WaitForFrames")
        end
    end
    co:setUpdateFunc(onUpdate)
    co:pause("WaitForFrames")
end

-- 等待函数返回值为true 或不为nil
function WaitForFuncResult(co, func)
    local function onUpdate()
        if func() then
            co:resume("WaitForFuncResult")
        end
    end
    co:setUpdateFunc(onUpdate)
    co:pause("WaitForFuncResult")
end