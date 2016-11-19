----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：系统场景
----------------------------------------------------------------------

-- 显示提示信息
function Toast(str)
    local scene = AppBase:getInstance():findScene("SSystem")
    scene:findGameObject("UIToast"):show(str)
end

-- 显示对话框
function Dialog(title, content, yesFunc, noFunc)
    local scene = AppBase:getInstance():findScene("SSystem")
    scene:createGameObject("UIDialog"):show(title, content, yesFunc, noFunc)
end

-- 等待对话框
function WaitForDialog(co, title, content)
    local bRet = false
    local function yesFunc() 
        bRet = true 
        co:resume("WaitForDialog")
    end
    local function noFunc() 
        bRet = false
        co:resume("WaitForDialog") 
    end
    Dialog(title, content, yesFunc, noFunc)
    co:pause("WaitForDialog")
    WaitForFrames(co, 1)
    return bRet
end

local SSystem = class("SSystem", GameScene)

-- 构造函数
function SSystem:ctor()
    SSystem.super.ctor(self)
    self.mRootZorder = SCENE_ZORDER.syterm
end

function SSystem:init()
    self:getRoot():setTouchEnabled(false)
    self:createGameObject("UIToast")
    self:createGameObject("UISystemPanel")
end

return SSystem