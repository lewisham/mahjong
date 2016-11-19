local function MultiString(s,n)
	local r=""
	for i=1,n do
		r=r..s
	end
	return r
end
--o ,obj;b use [];n \n;t num \t;
function TableToString(o,n,b,t)
	if type(o) == "function" then return  "" end
	if type(b) ~= "boolean" and b ~= nil then
		print("expected third argument %s is a boolean", tostring(b))
	end
	if(b==nil)then b=true end
	t=t or 1
	local s=""
	if type(o) == "number" or 
		type(o) == "function" or
		type(o) == "boolean" or
		type(o) == "nil" then
		s = s..tostring(o)
	elseif type(o) == "string" then
		s = s..string.format("%q",o)
	elseif type(o) == "table" then
		s = s.."{"
		if(n)then
			s = s.."\n"..MultiString("  ",t)
		end
		for k,v in pairs(o) do
			if b then
				s = s.."["
			end

			s = s .. TableToString(k,n, b,t+1)

			if b then
				s = s .."]"
			end

			s = s.. " = "
			s = s.. TableToString(v,n, b,t+1)
			s = s .. ","
			if(n)then
				s=s.."\n"..MultiString("  ",t)
			end
		end
		s = s.."}"

	end
	return s
end

function SaveTabletoFile(tb, file)
    local str = TableToString(tb, 1, true, 1)
    str = "return "..str
    local path = cc.FileUtils:getInstance():getWritablePath()
	local file = io.open(path..file, "w")
	file:write(str, "\n")
	file:flush()
	file:close()
end