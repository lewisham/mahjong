----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：数据存放中心
----------------------------------------------------------------------

DataBase = class("DataBase", LuaObject)

local mInstance = nil

function DataBase:getInstance()
    if mInstance then return mInstance end
    mInstance = DataBase.new()
    mInstance:init()
    return mInstance
end

function DataBase:init()
    mInstance = self
    self:set("root", {})
end

function DataBase:load()
end

function DataBase:save()
    local str = TableToString()
end

function DataBase:getRoot()
end

function DataBase:getUserData()
end


