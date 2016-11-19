----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：文件管理
----------------------------------------------------------------------

-- 读文件
function FileRead(filename)
	local f, moreInfo = io.open(filename, "rb")
	local ret
	if f then
		ret = f:read("*all")
		io.close(f)
	end
	return ret, moreInfo
end

-- 写文件
function FileWrite(filename, str)
	local f = assert(io.open(filename, "wb"))
	if f then
		f:write(str)
		io.close(f)
	end
end

function SaveFileList(filename, list)
    local tb = {}
	for k, abcd in pairs(list) do
		table.insert(tb, string:join(abcd, ','))
	end
	local str = string:join(tb, '\r\n')
    FileWrite(filename, str)
end

-- 加密文件
function EncryptFile(filename, data)
	return data
end

-- 解密文件
function DecryptFile(filename, data)
    return data
end