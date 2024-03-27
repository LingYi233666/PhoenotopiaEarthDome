-- ThePlayer.AnimState:SetBuild("gale") ThePlayer.sg:GoToState("gale_flute_play")
local GaleFluteScreen = require("screens/gale_flute_screen")
local GaleCommon = require("util/gale_common")

local flute_Assets = {
    Asset( "IMAGE", "images/ui/flute/shang.tex" ), 
    Asset( "ATLAS", "images/ui/flute/shang.xml" ),

    Asset( "IMAGE", "images/ui/flute/you.tex" ), 
    Asset( "ATLAS", "images/ui/flute/you.xml" ),

    Asset( "IMAGE", "images/ui/flute/mid.tex" ), 
    Asset( "ATLAS", "images/ui/flute/mid.xml" ),

    Asset( "IMAGE", "images/ui/flute/zuo.tex" ), 
    Asset( "ATLAS", "images/ui/flute/zuo.xml" ),

    Asset( "IMAGE", "images/ui/flute/xia.tex" ), 
    Asset( "ATLAS", "images/ui/flute/xia.xml" ),

    ------------------------------------------------------------------

    Asset( "IMAGE", "images/ui/melody/melody_ouroboros.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_ouroboros.xml" ),

    Asset( "IMAGE", "images/ui/melody/melody_geo.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_geo.xml" ),

    Asset( "IMAGE", "images/ui/melody/melody_royal.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_royal.xml" ),

    Asset( "IMAGE", "images/ui/melody/melody_panselo.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_panselo.xml" ),

    Asset( "IMAGE", "images/ui/melody/melody_battle.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_battle.xml" ),

    Asset( "IMAGE", "images/ui/melody/melody_phoenix.tex" ), 
    Asset( "ATLAS", "images/ui/melody/melody_phoenix.xml" ),
}

for k,v in pairs(flute_Assets) do
	table.insert(Assets, v)
end

local flute_sg_server = State{
    name = "gale_flute_play",
    tags = {"gale_flute_play","nopredict" },

    onenter = function(inst)
        inst.Transform:SetNoFaced()
        inst.Physics:Stop()
        if inst.components.locomotor ~= nil then
            inst.components.locomotor:StopMoving()
        end

        local hand = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if hand then 
            inst.components.inventory:GiveItem(hand)
        end

        local bufferaction = inst:GetBufferedAction()

        if bufferaction and bufferaction.action == ACTIONS.GALE_FLUTE_PLAY and bufferaction.invobject and bufferaction.invobject:HasTag("gale_flute_future")  then 
            inst.sg:AddStateTag("gale_flute_play_future")
        end
        -- inst.AnimState:Hide("ARM_normal")
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:OverrideSymbol("swap_object", "swap_gale_flute", "swap_gale_flute")
        inst.AnimState:PlayAnimation("gale_flute_play_pre")
        inst.AnimState:PushAnimation("gale_flute_play_mid",false)

        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["flute_start"],inst.userid)
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["add_areabgm_pause_source"],inst.userid,inst,"gale_flute_play")
    end,

    onexit = function(inst)
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        inst.Transform:SetFourFaced()
        inst:ClearBufferedAction()
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["flute_exit_s2c"],inst.userid)
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["remove_areabgm_pause_source"],inst.userid,inst,"gale_flute_play")
    end,

    events =
    {
        
    },
}

local flute_sg_client = State{
    name = "gale_flute_play",
    tags = {"gale_flute_play","nopredict" },

    onenter = function(inst)
        inst.Transform:SetNoFaced()
        inst.Physics:Stop()
        if inst.components.locomotor ~= nil then
            inst.components.locomotor:StopMoving()
        end
        
        inst:PerformPreviewBufferedAction()
    end,
}
AddStategraphState("wilson", flute_sg_server)
AddStategraphState("wilson_client", flute_sg_client)

local flute_map = {
    normal = {
        shang = "gale_sfx/flute/normal/flute_a1",
        you = "gale_sfx/flute/normal/flute_bb1",
        mid = "gale_sfx/flute/normal/flute_c1",
        zuo = "gale_sfx/flute/normal/flute_e1",
        xia = "gale_sfx/flute/normal/flute_f1",
    },

    future = {
        shang = "gale_sfx/flute/future/spheralis_a",
        you = "gale_sfx/flute/future/spheralis_b",
        mid = "gale_sfx/flute/future/spheralis_c",
        zuo = "gale_sfx/flute/future/spheralis_e",
        xia = "gale_sfx/flute/future/spheralis_f",
    },
}

GLOBAL.TUNING.GALE_MELODY_DEFINE = {
    melody_ouroboros = {"zuo","xia","shang","you","shang"},
    melody_geo = {"xia","mid","shang","mid","you"},
    melody_royal = {"xia","you","shang","xia","mid","you"},
    melody_panselo = {"xia","mid","you","shang","you","shang","you","mid","shang"},
    melody_battle = {"you","shang","you","mid","you","shang","you","shang"},
    melody_phoenix = {"mid","you","shang","xia","xia","zuo","zuo","xia"},
}


-- client to server
AddModRPCHandler("gale_rpc","flute_fangxiang",function(inst,flute_fangxiang)
    if inst.sg and inst.sg:HasStateTag("gale_flute_play") then 
        inst.AnimState:PlayAnimation("gale_flute_play_"..flute_fangxiang)
    end 
end)

AddModRPCHandler("gale_rpc","flute_play",function(inst,flute_fangxiang)
    if inst.sg and inst.sg:HasStateTag("gale_flute_play") then 
        local ftype = inst.sg:HasStateTag("gale_flute_play_future") and "future" or "normal"
        inst.SoundEmitter:PlaySound(flute_map[ftype][flute_fangxiang])
        if ftype == "future" then
        	inst.SoundEmitter:PlaySound("gale_sfx/flute/future/waker")
        end

        local s1,s2,s3 = inst.Transform:GetScale()
        local start_scale = Vector3(s1,s2,s3)
        local high_scale = Vector3(0.98,1.02,1)
        local low_scale = Vector3(1.02,0.99,1)
        local final_scale = Vector3(1,1,1)

        GaleCommon.FadeTo(inst,FRAMES * 3,{start_scale,high_scale},nil,nil,function()
            GaleCommon.FadeTo(inst,FRAMES * 3,{high_scale,low_scale},nil,nil,function()
                GaleCommon.FadeTo(inst,FRAMES * 2,{low_scale,final_scale})
            end)
        end)

        -- local vfx = inst:SpawnChild("gale_flute_vfx")
        -- vfx:DoEmit(flute_fangxiang)
        -- vfx:DoTaskInTime(FRAMES,vfx.Remove)

        for _,v in pairs(AllPlayers) do 
            if v and v:IsValid() and v:IsNear(inst,40) then
                SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["popup_flute_fx"],v.userid,inst,flute_fangxiang)
            end
        end
    end 
end)

AddModRPCHandler("gale_rpc","melody_play",function(inst,name)
    if inst.sg and inst.sg:HasStateTag("gale_flute_play") then 
        inst.SoundEmitter:PlaySound("gale_sfx/flute/melody/"..name)

        -- Flute effects:
        if inst.components.gale_flute_buffed then
            local result = inst.components.gale_flute_buffed:TryTrigger(name)
            local announce_msg = ""
            if result == nil then
                announce_msg = string.format(STRINGS.GALE_MELODIES.TRIGGER_NORMAL,STRINGS.GALE_MELODIES.NAME[name:upper()])
            elseif result == false then 
                announce_msg = string.format(STRINGS.GALE_MELODIES.TRIGGER_FAIL[name:upper()],inst.components.gale_flute_buffed:GetCD(name))
            else 
                announce_msg = STRINGS.GALE_MELODIES.TRIGGER_SUCCESS[name:upper()]
            end

            -- TheNet:Announce(announce_msg,nil,nil,nil)
            -- ThePlayer.HUD.controls.networkchatqueue:PushMessage("username", "message", nil, false, true)
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"],inst.userid,announce_msg,"item_drop",202/255, 174/255, 118/255, 255/255)
        end
    end 
end)

AddModRPCHandler("gale_rpc","flute_exit_c2s",function(inst)
    if inst.sg and inst.sg:HasStateTag("gale_flute_play") then 
        inst.AnimState:PlayAnimation("gale_flute_play_pst")
        inst.sg:GoToState("idle",true)
    end 
end)
-----------------------------------------------------------------------

-- server to client
AddClientModRPCHandler("gale_rpc","flute_start",function()
    TheFrontEnd:PushScreen(GaleFluteScreen(ThePlayer))
end)

AddClientModRPCHandler("gale_rpc","flute_exit_s2c",function()
    if ThePlayer.HUD.GaleFluteScreen then 
        TheFrontEnd:PopScreen(ThePlayer.HUD.GaleFluteScreen)
        ThePlayer.HUD.GaleFluteScreen = nil 
    end
end)


local GalePopupFlute = require("widgets/galepopupflute")
AddClientModRPCHandler("gale_rpc","popup_flute_fx",function(singer,image_name)
    if ThePlayer.HUD then 
        -- print("gale_rpc-popup_flute_fx",ThePlayer,"see",singer,"is playing",image_name)
        ThePlayer.HUD.popupstats_root:AddChild(GalePopupFlute(ThePlayer,singer:GetPosition() + Vector3(0,1,0),1.5,image_name))
    end
end)

----------------------------------------------------------------------

AddAction("GALE_FLUTE_PLAY","GALE_FLUTE_PLAY",function(act) 
    return true
end)

ACTIONS.GALE_FLUTE_PLAY.priority = 3


AddComponentAction("INVENTORY", "gale_flute", function(inst, doer, actions, right) 
    if not doer:HasTag("busy") and inst.replica.inventoryitem:IsGrandOwner(doer) then 
        table.insert(actions, ACTIONS.GALE_FLUTE_PLAY)
    end 
end)

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_FLUTE_PLAY, function(inst)
    return "gale_flute_play"
end))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_FLUTE_PLAY,function(inst)
    inst:PerformPreviewBufferedAction()
    -- return "gale_flute_play"
end))

