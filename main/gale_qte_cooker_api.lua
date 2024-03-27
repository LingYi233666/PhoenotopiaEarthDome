local add_assets = {
    Asset("ANIM", "anim/gale_ui_cook_remaster.zip"),

    Asset("IMAGE", "images/ui/qte_cook/hud_cook_interface.tex"),
    Asset("ATLAS", "images/ui/qte_cook/hud_cook_interface.xml"),

    Asset("IMAGE", "images/ui/qte_cook/arrow.tex"),
    Asset("ATLAS", "images/ui/qte_cook/arrow.xml"),

    Asset("IMAGE", "images/ui/qte_cook/animsmoke.tex"),
    Asset("ATLAS", "images/ui/qte_cook/animsmoke.xml"),

    Asset("IMAGE", "images/ui/qte_cook/white_block.tex"),
    Asset("ATLAS", "images/ui/qte_cook/white_block.xml"),


}

-- for i=0,9 do
--     local name = "cook_dots_0"..tostring(i)
--     table.insert(add_assets,Asset( "IMAGE", "images/ui/qte_cook/"..name..".tex" ))
--     table.insert(add_assets,Asset( "ATLAS", "images/ui/qte_cook/"..name..".xml" ))
-- end

for k, v in pairs(add_assets) do
    table.insert(Assets, v)
end

TUNING.GALECOOK = {
    COOK_PST_TIME = 1.2,
    MAX_DOTS_NUM = 10,
}

AddStategraphState("wilson", State {
    name = "gale_qte_cooking",
    tags = { "nomorph", "busy", "nopredict", "gale_qte_cooking" },

    onenter = function(inst)
        inst:ClearBufferedAction()
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)

        inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
    end,

    onexit = function(inst)
        inst.SoundEmitter:KillSound("make")
    end,
}
)

AddStategraphState("wilson", State {
    name = "gale_qte_cooking_pst",
    tags = { "nomorph", "busy", "nopredict", "gale_qte_cooking" },

    onenter = function(inst, data)
        inst.sg.statemem.product = data.product
        inst.sg.statemem.end_state = data.end_state
        inst.sg.statemem.container = data.container
        inst.sg.statemem.product_stacksize = data.product_stacksize or 1
        inst.sg.statemem.ingredient_prefabs = data.ingredient_prefabs



        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)


        inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")

        inst.sg:SetTimeout(TUNING.GALECOOK.COOK_PST_TIME)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("build_pst")
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        local end_state = inst.sg.statemem.end_state
        local get_product = inst.sg.statemem.product
        local container = inst.sg.statemem.container
        local product_stacksize = inst.sg.statemem.product_stacksize
        local ingredient_prefabs = inst.sg.statemem.ingredient_prefabs
        if end_state == "SUCCESS" then
            inst.SoundEmitter:PlaySound("gale_sfx/cooking/good_job")
        elseif end_state == "FAILED" then

        elseif end_state == "INTERRUPTE" then

        end

        if get_product and container and container:IsValid() then
            container.components.gale_qte_cooker:Harvest(inst, get_product, product_stacksize,
                                                         ingredient_prefabs)
        end
        inst.SoundEmitter:KillSound("make")
    end,
}
)


-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_start"],"a1","a2","a3","a4","a5","a6","a7")
-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_start"],target_player.userid)
-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_start"],nil,"pumpkincookie")
-- SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["cook_qte_start"],nil,"pumpkincookie",nil,5,2.2,9999)
local GaleQteCookScreen = require "screens/gale_qte_cook_screen"
AddClientModRPCHandler("gale_rpc", "cook_qte_start", function(product, container, dot_num, per_time, time_remain)
    TheFrontEnd:PushScreen(GaleQteCookScreen(ThePlayer, product, container, dot_num, per_time, time_remain))
end)

AddModRPCHandler("gale_rpc", "cook_qte_button_clicked", function(inst, container)
    if container and container:IsValid() then
        container.components.gale_qte_cooker:Start(inst)
    end
end)

AddClientModRPCHandler("gale_rpc", "cook_qte_end_client", function(end_state)
    if ThePlayer.HUD.GaleQteCookScreen then
        ThePlayer.HUD.GaleQteCookScreen:End(end_state)
    end
end)

AddModRPCHandler("gale_rpc", "cook_qte_end", function(inst, end_state, get_product, container)
    -- inst.sg:GoToState("gale_qte_cooking_pst",{end_state=end_state,product=get_product})
    if container and container:IsValid() then
        container.components.gale_qte_cooker:Stop(end_state)
    end
end)
