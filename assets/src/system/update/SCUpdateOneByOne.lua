----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2016-3-31
-- 描述：自动更新逻辑(一个文件一个文件的更新)
----------------------------------------------------------------------

local SCUpdateOneByOne = class("SCUpdateOneByOne", GameObject)

function SCUpdateOneByOne:init(url)
    self:set("url", url)
    self:set("wait_cnt", 0)
    self:set("total_update_cnt", 1)       -- 总共要更新的文件
    self:set("update_cnt", 0)   
    self:set("down_load_filename", "")
    self:set("client_file_list", {})
    self:set("error_code", "")
end

-- 执行逻辑
function SCUpdateOneByOne:play(co)
    -- 清除文件缓存
	cc.FileUtils:getInstance():purgeCachedEntries()
    self:set("down_load_dir", DOWD_LOAD_DIR)
    self:logic(co)
    if self:get("error_code") ~= "" then
        self:refreshTips(self:get("error_code"))
		return false
    end
	return true
end

function SCUpdateOneByOne:logic(co)
    -- 检查版本号
    if self:checkVersion(co) then return end
    -- 检查要更新文件
    local tb = self:checkUpdateFiles(co)
    if tb == nil then return end
    WaitForSeconds(co, 0.5)
    self:refreshTips("更新中")
    -- 下载文件
    local maxThread = 3
    self:set("wait_cnt", 0)
    self:set("total_update_cnt", #tb)       -- 总共要更新的文件
    self:set("update_cnt", 0)               -- 已更新的文件
    for _, val in pairs(tb) do
        if self:get("error_code") ~= "" then return end
        self:updateFile(val)
        WaitForFuncResult(co, function() return self:get("wait_cnt") < maxThread end)
    end
    WaitForFuncResult(co, function() return self:get("wait_cnt") == 0 end)
    self:saveClientFileList()
    WaitForFrames(co, 1)
    self:refreshTips("自动更新完成")
    print("自动更新完成")
    WaitForSeconds(co, 1.0)
end

-- 检查版本号
function SCUpdateOneByOne:checkVersion(co)
    do return false end
	print("检测是否要更新")
    self:refreshTips("检测是否要更新")
    local location = "0"
    local server = self:download(co, "CheckVersion.txt")
    if server == nil then
        return true
    end
    print("检查版本号", "客户端", location, "服务端", server)
    if location == server then
        self:refreshTips("已是最新版本，无需更新") 
        return true
    end
end

-- 检查更新文件
function SCUpdateOneByOne:checkUpdateFiles(co) 
    WaitForSeconds(co, 0.5)
    self:refreshTips("检查要更新文件")
    local str1 = self:download(co, "CheckFileList.txt")
    if str1 == nil then return end
    local tb1 = self:parseUpdateFiles(str1)  -- 服务端文件列表
	print(cc.FileUtils:getInstance():fullPathForFilename("CheckFileList.txt"))
    local str2 = cc.FileUtils:getInstance():getStringFromFile("CheckFileList.txt")
	local tb2 = self:parseUpdateFiles(str2)  -- 客户端文件列表
    self:set("client_file_list", tb2)
    local list = {}
    local cnt = 0
    local total = 0
    for key, val in pairs(tb1) do
        if tb2[key] == nil or tb2[key][2] ~= val[2] then
            cnt = cnt + 1
            table.insert(list, val)
        end
        if total > 0 and cnt >= total then
            break
        end
    end
    print("检查要更新的文件", #list)
    --Log(list)
    return list
end

-- 更新文件
function SCUpdateOneByOne:updateFile(abcd)
    StartCoroutine(self, "implUpdateFile", abcd)
end

function SCUpdateOneByOne:implUpdateFile(co, abcd)
    self:modify("wait_cnt", 1)
    local filename = abcd[3]
	self:refreshTips("更新文件" .. filename)
    local data = self:download(co, filename)
    self:modify("wait_cnt", -1)
    if data == nil then
        return
    end
    print("更新文件成功", filename)
    -- 保存文件
    self:saveFile(filename, data)
    self:get("client_file_list")[filename] = abcd
    self:modify("update_cnt", 1)
    -- 每3次保存下client file list
    if self:get("update_cnt") % 3 == 0 then
        self:saveClientFileList()
    end
    self:refreshPercent()
end

-- 解析文件列表
function SCUpdateOneByOne:parseUpdateFiles(str)
    local dic = {}
	local lines = str:split('\r\n')
	for k, v in pairs(lines) do
		local abcd = v:split(',') -- {dlLevel, md5, filePath, fileSize}
		local path = abcd[3]
		if path then
			dic[path] = abcd
		end
	end
	return dic
end

-- 下载文件
function SCUpdateOneByOne:download(co, filename)
    local url = self:get("url")..filename
    local ret = nil
    local function callback(bOK, resp)
        if bOK then
            ret = resp
            ret = DecryptFile(filename, ret)
        else
            self:set("error_code", "下载文件"..filename.."失败")
        end
        co:resume("download")
    end
    self:httpGet(url, callback)
    co:pause("download")
    return ret
end

-- 保存client file list
function SCUpdateOneByOne:saveClientFileList()
	SaveFileList(cc.FileUtils:getInstance():getWritablePath().."CheckFileList.txt", self:get("client_file_list"))
end

-- 保存下载的文件
function SCUpdateOneByOne:saveFile(filename, data)
    local path = self:get("down_load_dir")..filename
	if true or device:isWindows() then
		local dir = string.match(filename, "(.+)/[^/]*%.%w+$") 
		if dir then
			cc.FileUtils:getInstance():createDirectory(self:get("down_load_dir") .. dir)
		end
	end
	FileWrite(path, data)
end

-- url请求下载
function SCUpdateOneByOne:httpGet(url, fnCallback)
	url = string.gsub(url, ' ', '%%20') -- 用urlencode 可能有问题，这里只改空格
    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	local ndProtected = cc.Node:create()
	local function onReadyStateChange()
		if tolua.isnull(ndProtected) then
			return -- 节点已被删了, 可能是游戏被重新加载了
		end
		SafeRemoveNode(ndProtected)
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then -- 成功
			--print("成功 Code:"..xhr.statusText)
			fnCallback(true, xhr.response)
		else -- 失败
            print(url)
			print("失败 xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
			fnCallback(false, xhr.response)
		end
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
	self:findGameObject("UIAutoUpdate"):addChild(ndProtected)
	return xhr
end

-- 刷新提示
function SCUpdateOneByOne:refreshTips(str)
    self:findGameObject("UIAutoUpdate"):refreshTips(str)
end

-- 刷新百分比
function SCUpdateOneByOne:refreshPercent()
    local go = self:findGameObject("UIAutoUpdate")
    if not go then return end
    local percent = math.floor(self:get("update_cnt") / self:get("total_update_cnt") * 100)
    go:refreshPercent(percent)
end

return SCUpdateOneByOne