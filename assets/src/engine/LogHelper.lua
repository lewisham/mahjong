----------------------------------------------------------------------
-- 作者：lewis
-- 日期：2013-3-31
-- 描述：打印lua table
----------------------------------------------------------------------

function LogKeys(obj, sFind)
	if not sFind then
		Log(obj)
		return 
	end

	sFind = sFind:upper()
	local t = {}
	for k,v in pairs(obj) do
		if type(k) == "string" and k:upper():find(sFind) then
			t[k] = v
		end
	end
	Log(t)
end

-- Log 支持多参数
function Log(...)
	local args = {...}
	if #args == 0 then
		print("nil")
		return 
	end

	for _, v in ipairs(args) do
		local sType = type(v)
		if sType == "table" then
			LogTable(v)
		else
			print(tostring(v))
		end
	end
end
-- Log 支持加打印的层数
function LogSimple(tab,n)
	if not n then
		n = 2
	end
	if not tab then
		print("nil")
		return
	end
	LogTable(tab,nil,nil,n)
end



function LogTable(obj,parentDic,indent,deep)
	if not deep then
		deep = 10
	end
	deep = deep - 1 
	if deep < 0 then
		return
	end
	parentDic = parentDic or {}
	parentDic[obj] = true
	indent = indent or ""
	local oldIndent = indent
	print(indent.."{")
	indent = indent.."    "

	for k, v in pairs(obj) do
		local kType = type(k)
		local kStr = indent
		if kType == "number" then
			kStr = kStr.."["..k.."]"
		else
			kStr = kStr..tostring(k)
		end
		local sType = type(v)
		if sType == "table" then
			if parentDic[v] then
				print(kStr,"=","table is nest in parent")
			else
				print(kStr,"=")
				LogTable(v,parentDic,indent,deep)
			end
		elseif sType == "string" then
			print(kStr,"=", "'"..tostring(v).."'")
		else
			print(kStr,"=", tostring(v))
		end
	end

	print(oldIndent.."}")
	parentDic[obj] = nil
end


-- 显示图片占用内存
function LogPicMem()
	cc.TextureCache:getInstance():dumpCachedTextureInfo()
end


