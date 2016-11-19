----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：string 扩展
----------------------------------------------------------------------

-- 功  能：屏蔽字符串
-- 返回值：第1个返回值 - 屏蔽后的字符串; 第二个返回值 - 是否合法文字
function string:keywordShield()
	if not string.mBadWords then -- 只初始化一次
		-- 屏蔽掩码
		local MASK = "*"
		local fileText = cc.FileUtils:getInstance():getStringFromFile('bad_word.txt')
		string.mBadWords = fileText:split('\r\n')
										:convert(function(s) return {s, string.rep(MASK, s:unicodeChars():size())} end)
	end

	local sRet = self
	for _k, ab in pairs(string.mBadWords) do
		sRet = string.gsub(sRet, ab[1], ab[2])
	end

 	return sRet, sRet == self
end

-- md5
function string:md5()
	return md5_crypto(self, self:len()) or ""
end

-- rc4
function string:rc4()
	return RC4Encode(self, self:len()) or ""
end

-- base64
function string:base64()
	return mime.b64(self) or ""
end

function string:unbase64()
	return mime.unb64(self) or ""
end

-- 压缩
function string:zip()
	local compress=zlib.deflate()
	return compress(self, 'finish')
end

-- 解压缩
function string:unzip()
	local uncompress=zlib.inflate()
	return uncompress(self, 'finish')
end

-- 是否以某个字符串开头
-- 例子: local s = 'this is a test'
--       Log(s:beginWith('this')) -- 返回true
--       Log(s:beginWith('is')) -- 返回false
function string:beginWith(s)
	return self:sub(1, s:len()) == s
end

-- 是否以某个字符串结尾
-- 例子: local s = 'this is a test'
--       Log(s:endWith('this')) -- 返回false
--       Log(s:endWith('test')) -- 返回true
function string:endWith(tail)
	return self:sub(-tail:len()) == tail
end

-- 包装字符串
-- 例子: local s = "abc"
--       Log(s:quoted()) -- 返回"'abc'"
function string:quoted(left, right)
	left = left or "'"
	right = right or left
	return left .. self .. right
end

-- 第一个字节
-- 例子: local s = 'xyz'
--       Log(s:head()) -- 返回'x'
function string:head()
	return self:sub(1, 1)
end

-- 最后一个字节
-- 例子: local s = 'xyz'
--       Log(s:tail()) -- 返回'z'
function string:tail()
	return self:sub(self:len())
end

-- 返回去掉第一个字符后的字符串
-- 例子: local s = 'xyz'
--       Log(s:popHead()) -- 返回'yz'
function string:popHead()
	return self:sub(2)
end

-- 返回去掉最后一个字符后的字符串
-- 例子: local s = 'xyz'
--       Log(s:popTail()) -- 返回'xy'
function string:popTail()
	return self:sub(1, self:len() - 1)
end

-- 逐个char判断是否都满足fn
-- 例子: local s = '132930'
--       Log(s:allIs(function(v) return '0' <= v and v <= '9' end)) -- 返回true
-- 例子: local s = '1329Abc'
--       Log(s:allIs(function(v) return '0' <= v and v <= '9' end)) -- 返回false
function string:allIs(fn)
	local s = self
	if s:len() == 0 then
		return false
	end

	while s:len() > 0 do
		if not fn(s:head()) then
			return false
		end

		s = s:popHead()
	end
	return true
end

-- 转成文本, 主要用来显示服务端的64位int字符串
function string:toText()
	local s = self
	if s:len() ~= 8 then -- 判断是否64位int
		return s
	end

	local sTmp = s
	while sTmp:len() > 0 do
		local ch = sTmp:head()
		local iVal = string.byte(ch)
		if (32 <= iVal) and (iVal < 127) then
			sTmp = sTmp:popHead()
		else
			break
		end
	end

	-- 不用转成\123\2\9之类的形式
	if sTmp:len() == 0 then
		return s
	end

	local sOut = ""
	while s:len() > 0 do
		local ch = s:head()
		local iVal = string.byte(ch)
		sOut = sOut .. "\\" .. iVal
		s = s:popHead()
	end

	return sOut
end

-- 转成16进制文本
-- 例子: local s = 'ok\n'
--       Log(s:toHex()) -- 返回'6F6B0A'
function string:toHex()
	local s = self
	local function fnGetHex(iVal)
		if iVal < 10 then
			return string.char(iVal + string.byte('0'))
		else
			return string.char(iVal - 10 + string.byte('A'))
		end
	end

	local sOut = ""
	while s:len() > 0 do
		local ch = s:head()
		local iVal = string.byte(ch)
		sOut = sOut .. fnGetHex(math.floor(iVal/16))
		sOut = sOut .. fnGetHex(math.mod(iVal, 16))

		s = s:popHead()
	end
	return sOut
end

-- 合并
-- 返回列表
-- 例子: local arr = List({'ab', 'cde', 'gh'})
--       Log(string:join(arr, ',')) -- 返回'ab,cde,gh'
function string:join(...)
	return table.concat(...)
end

-- 切割
-- 返回列表
-- 例子: local s = "ab,cde,gh"
--       Log(s:split(',')) -- 返回{'ab', 'cde', 'gh'}
function string:split(sDiv)
    local retList = {}
    self:gsub('[^'..sDiv..']+', function(sRet) table.insert(retList, sRet) end)
    return retList
end

-- 切割成unicode
-- 返回列表
-- 例子: local s = "a到b中文ok"
--       Log(s:unicodeChars()) -- 返回{'a', '到', 'b', '中', '文', 'o', 'k'}
function string:unicodeChars()
	local retList = List()

	for uchar in self:gfind("([%z\1-\127\194-\244][\128-\191]*)") do
		retList:insert(uchar)
	end
	return retList
end

-- 策划案要求的字符个数
function string:visibleCharWidth()
	return self:unicodeChars():sum(
				function(v)
					if v:len() > 1 then -- 汉字算2个
						return 2
					else                -- 英文算1个
						return 1
					end
				end)
end

-- 切割成unicode
-- 返回列表
-- 例子: local s = "a到b中文ok"
--       Log(s:unicodeInts()) -- 返回{97, 21040, 98, 20013, 25991, 111, 107}
function string:unicodeInts()
    local utf8str = self
    local res, seq, val = List(), 0, nil
    for i = 1, #utf8str do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                  error("invalid UTF-8 character sequence")
            val = bit.band(c, 2^(8-seq) - 1)
        else
            val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    table.insert(res, val)
    return res
end

-- 按指定长度插入分隔符
-- 返回列表
-- 例子: local s = "abc123ABC"
--       Log(s:insertPerLen(3, ",")) -- "abc,123,ABC,"
function string:insertPerLen(len, insertStr)
	local s = self
	local arr = List()
	while s:len() >= len do
		arr:insert(s:sub(1, len))
		s = s:sub(len + 1)
	end
	arr:insert(s)
	return string:join(arr, insertStr)
end


-- 以下是从cocos2dx拷过来的，还没整理
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

--~ function string.split(input, delimiter)
--~     input = tostring(input)
--~     delimiter = tostring(delimiter)
--~     if (delimiter=='') then return false end
--~     local pos,arr = 0, {}
--~     -- for each divider found
--~     for st,sp in function() return string.find(input, delimiter, pos, true) end do
--~         table.insert(arr, string.sub(input, pos, st - 1))
--~         pos = sp + 1
--~     end
--~     table.insert(arr, string.sub(input, pos))
--~     return arr
--~ end

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string.gsub (input, "+", " ")
    input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
    input = string.gsub (input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len  = string.len(input)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end
