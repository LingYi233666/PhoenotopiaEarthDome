AddClientModRPCHandler("gale_rpc", "announce", function(msg, icon_name, r, g, b, a)
    msg = msg or "gale_rpc announce empty msg"
    icon_name = icon_name or "default"
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1

    -- icon_name: See constants.lua also
    -- ANNOUNCEMENT_ICONS =
    -- {
    --     ["default"] = { atlas = "images/button_icons.xml", texture = "announcement.tex" },
    --     ["afk_start"] = { atlas = "images/button_icons.xml", texture = "AFKstart.tex" },
    --     ["afk_stop"] = { atlas = "images/button_icons.xml", texture = "AFKstop.tex" },
    --     ["death"] = { atlas = "images/button_icons.xml", texture = "death.tex" },
    --     ["resurrect"] = { atlas = "images/button_icons.xml", texture = "resurrect.tex" },
    --     ["join_game"] = { atlas = "images/button_icons.xml", texture = "join.tex" },
    --     ["leave_game"] = { atlas = "images/button_icons.xml", texture = "leave.tex" },
    --     ["kicked_from_game"] = { atlas = "images/button_icons.xml", texture = "kicked.tex" },
    --     ["banned_from_game"] = { atlas = "images/button_icons.xml", texture = "banned.tex" },
    --     ["item_drop"] = { atlas = "images/button_icons.xml", texture = "item_drop.tex" },
    --     ["vote"] = { atlas = "images/button_icons.xml", texture = "vote.tex" },
    --     ["dice_roll"] = { atlas = "images/button_icons.xml", texture = "diceroll.tex" },
    --     ["mod"] = { atlas = "images/button_icons.xml", texture = "mod_announcement.tex" },
    -- }


    -- ChatHistoryManager:AddToHistory(type, sender_userid, sender_netid, sender_name, message, colour, icondata, whisper,
    --     localonly, text_filter_context)
    ChatHistory:AddToHistory(ChatTypes.Announcement, nil, nil, nil, msg, { r, g, b, a }, icon_name, true, true)
end)



AddClientModRPCHandler("gale_rpc", "announce_advance",
    function(type, sender_name, message, r, g, b, a, icondata, whisper)
        message = message or "gale_rpc announce empty msg"
        icondata = icondata or "default"
        r = r or 1
        g = g or 1
        b = b or 1
        a = a or 1

        ChatHistory:AddToHistory(type, nil, nil, sender_name, message, { r, g, b, a }, icondata,
            whisper, true)
    end
)

AddClientModRPCHandler("gale_rpc", "chatter_message",
    function(talker, name_colour_R, name_colour_G, name_colour_B, message, colour_R, colour_G, colour_B,
             user_vanity, user_vanity_bg, priority)
        local name_colour = { 1, 1, 1 }
        local colour = { 1, 1, 1 }
        if name_colour_R and name_colour_G and name_colour_B then
            name_colour = { name_colour_R, name_colour_G, name_colour_B }
        end
        if colour_R and colour_G and colour_B then
            colour = { colour_R, colour_G, colour_B }
        end
        ChatHistory:OnChatterMessage(talker, name_colour, message, colour, user_vanity, user_vanity_bg, priority)
    end
)
