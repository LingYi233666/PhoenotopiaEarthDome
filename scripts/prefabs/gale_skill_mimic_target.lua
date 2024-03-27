local GaleEntity = require("util/gale_entity")

local assets = {

}


-- ThePlayer:Hide() local mimic = c_spawn("gale_skill_mimic_target") mimic:DoPeriodicTask(0,function() mimic.Transform:SetPosition(ThePlayer:GetPosition():Get()) end)
-- local mimic = c_spawn("gale_skill_mimic_target") ThePlayer.components.playercontroller.locomotor = mimic.components.locomotor
-- ThePlayer.components.playercontroller.locomotor = c_findnext("gale_skill_mimic_target").components.locomotor
-- ThePlayer.components.playercontroller.locomotor = ThePlayer.components.locomotor
-- ThePlayer.components.locomotor:SetExternalSpeedMultiplier(ThePlayer,"mimic",0)
local function MimicClientFn(inst)
    MakeInventoryPhysics(inst)

    local anim = "f"..math.random(1,3)
    inst.idle_anim = anim
    inst.walk_anim = anim
    inst.run_anim = anim



    -- if not TheNet:IsDedicated() then
    --     inst:SetStateGraph("SGgale_skill_mimic_target_client")    
    -- end

    inst._mimic_nameoverride = net_string(inst.GUID,"inst._mimic_nameoverride","mimic_nameoverride_dirty")
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("mimic_nameoverride_dirty",function()
            inst.nameoverride = inst._mimic_nameoverride:value()
        end)
    end
end

local function MimicServerFn(inst)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(150)

    inst:AddComponent("combat")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 3

    inst:SetStateGraph("SGgale_skill_mimic_target")    
end

return GaleEntity.CreateNormalEntity({
    assets = assets,
    prefabname = "gale_skill_mimic_target",
    tags = {"prey","shadow_aligned"},
    bank = "rocks",
    build = "rocks",

    persists = false,

    clientfn = MimicClientFn,
    serverfn = MimicServerFn,
}),GaleEntity.CreateClientFX({
    assets = assets,
    prefabname = "gale_skill_mimic_fx",
    bank = "shadow_rook",
    build = "shadow_rook",

    faced = 4,

    server_remove_time = 8,

    clientfn_fx = function(inst)
        inst.AnimState:HideSymbol("base")
        inst.AnimState:HideSymbol("top_head")
        inst.AnimState:HideSymbol("bottom_head")
        inst.AnimState:HideSymbol("big_horn")
        inst.AnimState:HideSymbol("mouth_space")
        inst.AnimState:HideSymbol("small_horn_lft")
        inst.AnimState:HideSymbol("small_horn_rgt")

        inst.AnimState:PlayAnimation("transform",true)
        
        inst.AnimState:SetTime(26 * FRAMES)

        inst:DoTaskInTime(48 * FRAMES,function()
            inst.AnimState:PlayAnimation("teleport")
            inst.AnimState:SetTime(6 * FRAMES)
            inst.AnimState:SetDeltaTimeMultiplier(0.6)

            if TheCamera then
                inst:ForceFacePoint((inst:GetPosition() + TheCamera:GetDownVec()):Get())
            end

            inst:DoPeriodicTask(0,function()
                if TheCamera then
                    inst:ForceFacePoint((inst:GetPosition() + TheCamera:GetDownVec()):Get())
                end
            end)
        end)
    end,
})