----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：发布更新包
----------------------------------------------------------------------

local SCPublish = class("SCPublish", GameObject)

function SCPublish:init(idx)
    self:coroutine(self, "play", idx)
end

function SCPublish:play(co, idx)
    self:old()
    Toast("发布更新包完毕")
    do return end
    assert(ASSETS_SEVER_PATH, "没有设置资源服路径")
    cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH)
    local list = self:calcFileList()
    self:calcNeedUpdateFiles()
    Log(list)
end

function SCPublish:calcFileList()
    local sDir = ""
    local list = {}
    local workDir = RunDosCmd("cd")[1]
    for key, _ in io.popen('dir ' .. sDir .. ' /a-D/b/s'):lines() do
        local filename = string.match(key, ".+\\([^\\]*%.%w+)$")
        local win32Path = string.sub(key, #workDir + 2)
        local path = string.gsub(win32Path, "\\", "/")
        local pos = #win32Path - #filename
        local dir = string.sub(win32Path, 1, pos)
        local unit = {}
        unit.win32Path = win32Path
        unit.filename = filename
        unit.path = path
        unit.dir = dir
        table.insert(list, unit)
	end
    return list
end

-- 解析文件列表
function SCPublish:calcNeedUpdateFiles()
    local path = "FileList.txt"
    local str = cc.FileUtils:getInstance():getStringFromFile(path)    
    local dic = {}
	local lines = str:split('\r\n')
	for k, v in pairs(lines) do
		local ab = v:split(',') -- {path, md5}
		local path = ab[1]
		if path then
			dic[path] = ab
		end
	end
    self:set("file_list", dic)
end

function SCPublish:isNeedUpdate(path, md5)
    local dic = self:get("file_list")
    local ab = dic[path]
    if ab == nil then
        ab = {path, md5}
        dic[path] = ab
        return true
    elseif ab[2] ~= md5 then
        ab[2] = md5
        return true
    end
    return false
end

function SCPublish:solution01(co, list)
    for _, val in ipairs(list) do
        local content = FileRead(val.win32Path)
        content = EncryptFile(val.filename, content)
        local md5 = content:md5() or "0bytes"
        if self:isNeedUpdate(val.path, md5) then
            self:updateFile(val.path, val.dir, content)
        end
    end
end

-- 保存文件
function SCPublish:updateFile(path, dir, content)
    if dir ~= "" then
        cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH .. dir)
		cc.FileUtils:getInstance():createDirectory(PRODUCT_PATH .. dir)
    end
    FileWrite(ASSETS_SEVER_PATH..path, content)
	FileWrite(PRODUCT_PATH..path, content)
end

-- 单文件更新方式
function SCPublish:old()
    assert(ASSETS_SEVER_PATH, "没有设置资源服路径")
    cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH)
    local sDir = ""
    local list = {}
    local workDir = RunDosCmd("cd")[1]
    for key, _ in io.popen('dir ' .. sDir .. ' /a-D/b/s'):lines() do
        local filename = string.match(key, ".+\\([^\\]*%.%w+)$")
        if filename ~= "CustomScript.lua" then
			--print(filename)
            local path = string.sub(key, #workDir + 2)
            local pos = #path - #filename
            local dir = string.sub(path, 1, pos)
            local content = FileRead(path)
            content = EncryptFile(filename, content)
            local md5 = content:md5() or "0bytes"
            local size = #content
            local path1 = string.gsub(path, "\\", "/")
            local abcd = {1, md5, path1, size}     
            table.insert(list, abcd)
            if dir ~= "" then
                cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH .. dir)
				cc.FileUtils:getInstance():createDirectory(PRODUCT_PATH .. dir)
            end
			print(path)
            FileWrite(ASSETS_SEVER_PATH..path, content)
			FileWrite(PRODUCT_PATH..path, content)
        else
            print("skip file", filename)
        end
    end

    -- 保存文件信息
    SaveFileList(ASSETS_SEVER_PATH .. "CheckFileList.txt", list)
	SaveFileList(PRODUCT_PATH .. "CheckFileList.txt", list)
    -- 保存版本号
    local versionId = tostring(os.time())
    FileWrite(ASSETS_SEVER_PATH .. "CheckVersion.txt", versionId)
	FileWrite(PRODUCT_PATH .. "CheckVersion.txt", versionId)
    print("发布资源成功")
end


-- 单文件更新方式
function SCPublish:old()
    assert(ASSETS_SEVER_PATH, "没有设置资源服路径")
    cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH)
    local sDir = ""
    local list = {}
    local workDir = RunDosCmd("cd")[1]
    for key, _ in io.popen('dir ' .. sDir .. ' /a-D/b/s'):lines() do
        local filename = string.match(key, ".+\\([^\\]*%.%w+)$")
        if filename ~= "CustomScript.lua" then
			--print(filename)
            local path = string.sub(key, #workDir + 2)
            local pos = #path - #filename
            local dir = string.sub(path, 1, pos)
            local content = FileRead(path)
            content = EncryptFile(filename, content)
            local md5 = content:md5() or "0bytes"
            local size = #content
            local path1 = string.gsub(path, "\\", "/")
            local abcd = {1, md5, path1, size}     
            table.insert(list, abcd)
            if dir ~= "" then
                cc.FileUtils:getInstance():createDirectory(ASSETS_SEVER_PATH .. dir)
				cc.FileUtils:getInstance():createDirectory(PRODUCT_PATH .. dir)
            end
			print(path)
            FileWrite(ASSETS_SEVER_PATH..path, content)
			FileWrite(PRODUCT_PATH..path, content)
        else
            print("skip file", filename)
        end
    end

    -- 保存文件信息
    SaveFileList(ASSETS_SEVER_PATH .. "CheckFileList.txt", list)
	SaveFileList(PRODUCT_PATH .. "CheckFileList.txt", list)
    -- 保存版本号
    local versionId = tostring(os.time())
    FileWrite(ASSETS_SEVER_PATH .. "CheckVersion.txt", versionId)
	FileWrite(PRODUCT_PATH .. "CheckVersion.txt", versionId)
    print("发布资源成功")
end

return SCPublish