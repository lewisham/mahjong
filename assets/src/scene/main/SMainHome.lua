----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：主城场景
----------------------------------------------------------------------

local SMainHome = class("SMainHome", GameScene)

function SMainHome:run()
	self:createGameObject("DAPlayer")
	self:awaken()
    self:coroutine(self, "play")
end

function SMainHome:play(co)
    --CreateWindow("UIMainLoading"):play(co)
    self:balckOut(nil, 0.5)
    cc.SimpleAudioEngine:getInstance():playMusic("sound/bgm_battle1.mp3", true)
    CreateWindow("UIMainCity", "ui/main/city/yumengling.csb")
    CreateWindow("UICityPanel")
end

return SMainHome