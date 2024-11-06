local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local assets = {
    Asset("ANIM", "anim/galeboss_katash.zip"),
}

local function SelectTargetFn(inst)
    if inst:HasTag("temporary_freedom") then
        return
    end

    return FindEntity(inst, 20,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and (not GaleCommon.IsShadowCreature(guy) or (guy.components.combat and guy.components.combat:TargetIs(inst)))
        end,
        { "_combat", "_health" },
        { "INLIMBO" },
        { "character", "lunar_aligned", "largecreature" }
    )
end

local function KeepTargetFn(inst, target)
    return not inst:HasTag("temporary_freedom")
        and inst.components.combat:CanTarget(target)
        and inst:IsNear(target, 40)
end


local function OnAttacked(inst, data)
    if inst:HasTag("temporary_freedom") then
        return
    end

    local attacker = data ~= nil and data.attacker or nil

    if attacker ~= nil then
        inst.components.combat:SetTarget(attacker)
    end
end

local function OnTimerDone(inst, data)
    if data.name == "mind_controled_again" then
        -- TODO: into re-mindcontrol SG
    end
end

local function EnableUpBody(inst, enabled)
    local hidden_symbols = {
        "arm_lower",
        "arm_upper",
        "arm_upper_skin",
        "cheeks",
        "face",
        "hand",
        "headbase",
        "torso",
        -- "torso_pelvis",
    }

    local ent = inst._up_body:value()
    if enabled and ent == nil then
        ent = inst:SpawnChild("galeboss_katash_2_upbody")
        inst._up_body:set(ent)
        ent.entity:AddFollower()
        -- ent.Follower:FollowSymbol(inst.GUID, "torso", 0, 53, 0, true)
        ent.Follower:FollowSymbol(inst.GUID, "torso", 0, 53, 0, true)
        -- ent.Follower:FollowSymbol(inst.GUID, "torso", nil, nil, nil, true)
        -- ent.Follower:FollowSymbol(inst.GUID, "torso_pelvis", 0, 0, 0)

        for _, v in pairs(hidden_symbols) do
            inst.AnimState:SetSymbolMultColour(v, 0, 0, 0, 0)
        end
    elseif not enabled and ent ~= nil then
        inst._up_body:set(nil)
        ent:Remove()
        for _, v in pairs(hidden_symbols) do
            inst.AnimState:SetSymbolMultColour(v, 1, 1, 1, 1)
        end
        ent = nil
    end

    return ent
end


local function EnableBladeAnim(inst, enable)
    inst.AnimState:ClearOverrideSymbol("swap_object")

    if enable then
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")

        if not (inst.swapanim_ent and inst.swapanim_ent:IsValid()) then
            inst.swapanim_ent = inst:SpawnChild("galeboss_katash_blade_swapanims")
            inst.swapanim_ent.entity:AddFollower()
            inst.swapanim_ent.Follower:FollowSymbol(inst.GUID, "swap_object", nil, nil, nil, true, nil, 0, 8)
            inst.swapanim_ent.components.highlightchild:SetOwner(inst)
            if inst.components.colouradder ~= nil then
                inst.components.colouradder:AttachChild(inst.swapanim_ent)
            end
        end
    else
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        if inst.swapanim_ent and inst.swapanim_ent:IsValid() then
            inst.swapanim_ent:Remove()
        end
        inst.swapanim_ent = nil
    end
end

local function EnableMindControledParam(inst, enabled)
    inst.mind_controled = enabled

    if enabled then
        inst.components.gale_spdamage_psychic:SetBaseDamage(34)
    else
        inst.components.gale_spdamage_psychic:SetBaseDamage(0)
    end
end

-- local function EscapeFromMindControlTemporary(inst, escape_time)

-- end

local function SelectLeapDestination(inst, arrived_dests)
    arrived_dests = arrived_dests or {}

    local function custom_check(pt)
        for _, v in pairs(arrived_dests) do
            if (v - pt):Length() < 4 then
                return false
            end
        end

        return true
    end

    for r = 15, 5, -1 do
        local offset = FindWalkableOffset(inst:GetPosition(), math.random() * TWOPI, r, 10, nil, false, custom_check,
            false, false)

        if offset then
            return inst:GetPosition() + offset
        end
    end
end

local function OnLoad(inst, data)

end

local function AnimClientFn(inst)
    inst.Transform:SetFourFaced()

    inst.AnimState:AddOverrideBuild("player_lunge")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")

    inst.AnimState:OverrideSymbol("headbase", "galeboss_katash", "headbase_with_hair")
    inst.AnimState:OverrideSymbol("headbase_hat", "galeboss_katash", "headbase_with_hair")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")

    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")
    inst.AnimState:HideSymbol("hair")
    inst.AnimState:HideSymbol("hair_hat")
end

local function KatashClientFn(inst)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.5, .75)

    MakeCharacterPhysics(inst, 50, .5)

    AnimClientFn(inst)

    -------------------------------------------------------------------------
    inst:AddComponent("talker")
    inst.components.talker.font = TALKINGFONT
    inst.components.talker:MakeChatter()

    inst:AddComponent("npc_talker")
    -------------------------------------------------------------------------

    -- GaleCommon.AddEpicBGM(inst, "galeboss_katash")

    inst._up_body = net_entity(inst.GUID, "inst._up_body")
end

local function KatashServerFn(inst)
    inst.EnableBladeAnim = EnableBladeAnim
    inst.EnableUpBody = EnableUpBody
    inst.EnableMindControledParam = EnableMindControledParam
    inst.SelectLeapDestination = SelectLeapDestination
    inst.OnLoad = OnLoad

    inst:AddComponent("timer")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor.runspeed = 6

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(2250)
    inst.components.health:SetMinHealth(1)

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = 0.5
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.DEFAULT_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(1, SelectTargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("gale_spdamage_psychic")

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetChanceLootTable("galeboss_katash")

    inst:SetStateGraph("SGgaleboss_katash_2")

    -- local brain = require("brains/galeboss_katashbrain")
    -- inst:SetBrain(brain)

    inst.sounds = {
        slip = "dontstarve/common/tool_slip",
        knockback_stage1 = "",
        knockback_stage2 = "",
    }

    inst:EnableMindControledParam(true)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("timerdone", OnTimerDone)
end

----------------------------------------------------------------------------------------
local function UpBodyClientFn(inst)
    AnimClientFn(inst)

    inst.AnimState:HideSymbol("foot")
    inst.AnimState:HideSymbol("leg")
    inst.AnimState:HideSymbol("tail")
    inst.AnimState:HideSymbol("torso_pelvis")
end

local function UpBodyServerFn(inst)
    inst:SetStateGraph("SGgaleboss_katash_2")
end

return GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_katash_2",
        assets = assets,

        bank = "wilson",
        build = "galeboss_katash",
        anim = "idle",

        tags = { "epic", "hostile", "character", "scarytoprey", "katash" },

        clientfn = KatashClientFn,
        serverfn = KatashServerFn,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "galeboss_katash_2_upbody",
        assets = assets,

        bank = "wilson",
        build = "galeboss_katash",
        anim = "idle",
        persists = false,

        tags = { "FX" },

        clientfn = UpBodyClientFn,
        serverfn = UpBodyServerFn,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "galeboss_katash_2_punch_fx",
        assets = assets,

        bank = "wilson",
        build = "galeboss_katash",

        tags = { "FX", "NOCLICK" },

        clientfn = function(inst)
            local symbols = {
                "arm_lower",
                "arm_upper",
                "arm_upper_skin",
                "cheeks",
                "face",
                "foot",
                "hair",
                "hairfront",
                "hairpigtails",
                "hair_hat",
                "hand",
                "headbase",
                "headbase_hat",
                "headbase_with_hair",
                "leg",
                "skirt",
                "SWAP_ICON",
                "tail",
                "torso",
                "torso_pelvis",
            }

            for _, v in pairs(symbols) do
                inst.AnimState:HideSymbol(v)
            end

            inst.Transform:SetFourFaced()

            inst.AnimState:AddOverrideBuild("gale_phantom_add")
            inst.AnimState:SetSymbolAddColour("handswipes_fx", 255 / 255, 0 / 255, 255 / 255, 1)
            inst.AnimState:SetSymbolLightOverride("handswipes_fx", 1)

            inst.AnimState:SetFinalOffset(2)
        end,
        serverfn = function(inst)
            inst.SetAnim = function(inst, index)
                local anims = {
                    "atk_werewilba",
                    "atk_2_werewilba",
                }

                inst.AnimState:PlayAnimation(anims[index])

                inst.AnimState:SetTime(6 * FRAMES)
            end
        end,
    })
