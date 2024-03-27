-- This information tells other players more about the mod
name = "不死鸟传说-地球穹顶(测试版)" ---mod名字
description = "乡村女孩凯尔的迷之冒险。\n建议开启错误追踪游玩！" --mod描述
author = "左轮山猫" --作者
version = "0.0.37" -- mod版本 上传mod需要两次的版本不一样

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = "/files/file/950-extended-sample-character/"


-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10
priority = -999

-- Compatible with Don't Starve Together
dst_compatible = true --兼容联机

-- Not compatible with Don't Starve
dont_starve_compatible = false     --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

-- Character mods need this set to true
all_clients_require_mod = true --所有人mod

icon_atlas = "modicon.xml"     --mod图标
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = { --服务器标签
    "character",
}



configuration_options = {
    {
        name = "gale_doubletap_arrow_to_dodge",
        label = "双击方向键来滑铲(本地)",
        options =
        {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },

    {
        name = "gale_healthbar_enable",
        label = "怪物血条(本地)",
        options =
        {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },

    {
        name = "gale_complex_desc_enable",
        label = "装备描述(本地)",
        options =
        {
            { description = "开启", data = true },
            { description = "关闭", data = false },
        },
        default = true,
    },
} --mod设置

-- if locale ~= "zh" then
--     configuration_options[1].label = "Double tap direction key to dodge"
--     configuration_options[1].options[1].description = "Enable"
--     configuration_options[1].options[2].description = "Disable"
-- end

bugtracker_config = {
    email = "1426163582@qq.com",
}
