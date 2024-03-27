local GaleCommon = require("util/gale_common")

AddStategraphPostInit("wilson", function(sg)
    local old_HEAL = sg.actionhandlers[ACTIONS.HEAL].deststate
    sg.actionhandlers[ACTIONS.HEAL].deststate = function(inst, action,...)
        
		local inv = action.invobject
        -- print("inv =",inv,"action.doer =",action.doer,"action.target =",action.target)
        if inv and inv.prefab == "athetos_health_upgrade_node" then
            if action.target == nil then
                return "gale_use_health_upgrade_node"
            else 
                return "dolongaction"
            end
            
        end

        return FunctionOrValue(old_HEAL,inst, action,...)
    end
end)
AddStategraphPostInit("wilson_client", function(sg)
    local old_HEAL = sg.actionhandlers[ACTIONS.HEAL].deststate
    sg.actionhandlers[ACTIONS.HEAL].deststate = function(inst, action,...)
		local inv = action.invobject
        if inv and inv.prefab == "athetos_health_upgrade_node" then
            if action.target == nil then
                inst:PerformPreviewBufferedAction()
                return 
            else 
                return "dolongaction"
            end
        end

        return FunctionOrValue(old_HEAL,inst, action,...)
    end
end)

-- ThePlayer.sg:GoToState("gale_use_health_upgrade_node")
local addition_time = 40 * FRAMES
AddStategraphState("wilson",State{
    name = "gale_use_health_upgrade_node",
    tags = { "doing", "busy","nopredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        -- inst.AnimState:PlayAnimation("pickup")
        -- inst.AnimState:PushAnimation("give_pst", false)

        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)

        inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")

        inst.components.health:SetInvincible(true)
    end,

    timeline =
    {
        TimeEvent(0 * FRAMES + addition_time, function(inst)
            inst.AnimState:SetPercent("build_loop",inst.AnimState:GetCurrentAnimationTime() / inst.AnimState:GetCurrentAnimationLength())

            inst.SoundEmitter:KillSound("make")

            inst.AnimState:HideSymbol("fx_wipe")

            inst.AnimState:SetLightOverride(1)
            inst.SoundEmitter:PlaySound("gale_sfx/other/healthnode_pick")

            inst:SpawnChild("athetos_health_upgrade_node_absorb_fx").Transform:SetPosition(0,0.7,0)

            inst.sg.statemem.thread = GaleCommon.FadeTo(inst,15 * FRAMES,nil,{
                Vector4(1,1,1,1),
                Vector4(0.8,0,0,1)
            })
        end),

        TimeEvent(15 * FRAMES + addition_time, function(inst)
            inst:SpawnChild("athetos_health_upgrade_node_absorb_fx2").Transform:SetPosition(0,0.7,0)

            if inst.sg.statemem.thread then
                KillThread(inst.sg.statemem.thread)
            end

            inst.sg.statemem.thread = GaleCommon.FadeTo(inst,15 * FRAMES,nil,nil,{
                Vector4(0,0,0,0),
                Vector4(0.5,0,0,1)
            })
        end),

        TimeEvent(52 * FRAMES + addition_time, function(inst)
            local fx = inst:SpawnChild("gale_laser_explosion")
            fx.Transform:SetScale(0.6,0.6,0.6)
            fx.AnimState:SetFinalOffset(1)

            inst.components.health:SetInvincible(false)
            inst:PerformBufferedAction()
            inst.components.health:SetInvincible(true)

            inst.sg.statemem.thread = GaleCommon.FadeTo(inst,30 * FRAMES,nil,{
                Vector4(0.8,0,0,1),
                Vector4(1,1,1,1),
            },{
                Vector4(0.5,0,0,1),
                Vector4(0,0,0,0),
            })
        end),

        TimeEvent(85 * FRAMES + addition_time, function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle",true)
        end),
    },

    onexit = function(inst)
        if inst.sg.statemem.thread then
            KillThread(inst.sg.statemem.thread)
        end
        inst.SoundEmitter:KillSound("make")

        inst.AnimState:ShowSymbol("fx_wipe")

        inst.AnimState:SetLightOverride(0)
        inst.AnimState:SetMultColour(1,1,1,1)
        inst.AnimState:SetAddColour(0,0,0,0)

        inst.components.health:SetInvincible(false)
    end,
})


----------------------------------------------------------------------
AddAction("GALE_LEARN","GALE_LEARN",function(act) 
    if act.invobject ~= nil then
        local target = act.target or act.doer
        if act.invobject.components.athetos_production_process ~= nil then
            return act.invobject.components.athetos_production_process:Teach(target)
        end
    end
end)

AddComponentAction("USEITEM", "athetos_production_process", function(inst, doer, target, actions, right) 
    if doer == target and target.replica.builder ~= nil then
        table.insert(actions, ACTIONS.GALE_LEARN)
    end
end)

AddComponentAction("INVENTORY", "athetos_production_process", function(inst, doer, actions, right) 
    if doer.replica.builder ~= nil then
        table.insert(actions, ACTIONS.GALE_LEARN)
    end
end)



AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GALE_LEARN,"dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GALE_LEARN,"dolongaction"))

