----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：自动更新
----------------------------------------------------------------------

local SAutoUpdate = class("SAutoUpdate", GameScene)

-- 执行自动更新逻辑
function SAutoUpdate:play(co, url)
	self:createGameObject("UIAutoUpdate")
	-- 不进进行自动更新
    if NOT_AUTO_UPDATE then
        self:findGameObject("UIAutoUpdate"):refreshTips("不进行自动更新")
        WaitForSeconds(co, 0.5)
	else
		self:createGameObject("SCUpdateOneByOne", url):play(co)
	end
    self:destroy()
end

return SAutoUpdate