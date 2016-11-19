local channel_list = {}

-- windows开发版本
channel_list["10001"] =
{
    id = "10001",
    url = "http://192.168.1.103/dragon/",       -- 自动更新地址
    write_path = "../Bin/write/",
    down_load_dir = "download/",
}

-- ios发布版本
channel_list["20001"] =
{
    id = "20001",
    url = "http://192.168.0.186/dragon/",       -- 自动更新地址
    write_path = "",
    down_load_dir = "download/",
}

-- android发布版本
channel_list["30001"] =
{
    id = "30001",
    url = "http://192.168.0.186/dragon/",       -- 自动更新地址
    write_path = "",
    down_load_dir = "download/",
}

local channel_id = "10001"

if GAME_CHANNEL_ID then
	channel_id = GAME_CHANNEL_ID
elseif device:isWindows() then
	channel_id = "10003"
elseif device:isAndroid() then
	channel_id = "30001"
elseif device:isIos() then
	channel_id = "20001"
end

-- 获得渠道信息
function GetChannelInfo()
    return channel_list[channel_id]
end
