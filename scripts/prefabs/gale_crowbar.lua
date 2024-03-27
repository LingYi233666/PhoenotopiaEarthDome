local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleWeaponSkill = require("util/gale_weaponskill")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/gale_crowbar.zip"),
    Asset("ANIM", "anim/swap_gale_crowbar.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
    Asset("ANIM", "anim/gale_actions_melee_chargeatk.zip"),

    Asset("ANIM", "anim/gale_circleslash_fx.zip"),
    

    Asset("IMAGE","images/inventoryimages/gale_crowbar.tex"),
    Asset("ATLAS","images/inventoryimages/gale_crowbar.xml"),
}

local function ChargeCommonAttack(inst,attacker,target,target_pos,percent)
    local face_vec = GaleCommon.GetFaceVector(attacker)

    local complete_charge = percent >= 1.0 or GaleCondition.GetCondition(attacker,"condition_carry_charge") ~= nil

    if not complete_charge then
        
        local bufferedaction = attacker:GetBufferedAction()
        if bufferedaction.action == ACTIONS.ATTACK then
            attacker.components.combat:DoAttack(target)
        else 
            local hit_pt = face_vec * attacker.components.combat:GetHitRange() + attacker:GetPosition()

            inst.components.weapon.attackwear = 0
            local hit_ents = GaleCommon.AoeDoAttack(attacker,hit_pt,1.25,{
                ignorehitrange = true,
                instancemult = 0.66,
            })
            inst.components.finiteuses:Use(#hit_ents)
            inst.components.weapon.attackwear = 1
        end
        
    else
        local hit_pt = face_vec * attacker.components.combat:GetHitRange() + attacker:GetPosition()
        
        inst.components.weapon.attackwear = 0
        local attack_ents_num = 0
        GaleCommon.AoeForEach(attacker,hit_pt,2.2,nil, {"INLIMBO"},{"_combat","_inventoryitem"},function(doer,other)
            local can_attack = doer.components.combat:CanTarget(other) and not doer.components.combat:IsAlly(other)
            local is_inv = other.components.inventoryitem ~= nil 

            if can_attack then 
                doer.components.combat.ignorehitrange = true
                doer.components.combat:DoAttack(other,doer.components.combat:GetWeapon(),nil,nil,GetRandomMinMax(2.8,3.0))
                doer.components.combat.ignorehitrange = false

                other:PushEvent("knockback", { knocker = doer, radius = 8})

                attack_ents_num = attack_ents_num + 1
            elseif is_inv then 
                GaleCommon.LaunchItem(other,doer,6.5)
            end

            if other ~= doer then
                SpawnPrefab("gale_hit_color_adder"):SetTarget(other)
            end
            
        end,
        function(doer,other)
            return other and other:IsValid()
        end)


        inst.components.finiteuses:Use(attack_ents_num)
        inst.components.weapon.attackwear = 1

        local sparkle = attacker:SpawnChild("gale_sparkle_vfx")
        sparkle.Transform:SetPosition(1.2,0,0)
        sparkle._target_pos_x:set(hit_pt.x - attacker:GetPosition().x)
        sparkle._target_pos_y:set(0)
        sparkle._target_pos_z:set(hit_pt.z - attacker:GetPosition().z)
        sparkle._can_emit:set(true)


        local animfx = SpawnAt("hammer_mjolnir_crackle",hit_pt)
        animfx.AnimState:SetAddColour(50/255, 169/255, 255/255, 1)
        animfx.AnimState:HideSymbol("flash_up")
        animfx.AnimState:HideSymbol("lightning_land")
        animfx.AnimState:HideSymbol("lightning1")
        animfx.AnimState:HideSymbol("droplet")
        animfx.AnimState:SetDeltaTimeMultiplier(1.66)
        animfx.AnimState:SetLightOverride(2)
        animfx.persists = false
        animfx:ListenForEvent("animover",animfx.Remove)
        
        attacker.SoundEmitter:PlaySound("gale_sfx/battle/P1_punchF")
        attacker.SoundEmitter:PlaySound("gale_sfx/character/p1_gale_charge_atk_shout")
        
        ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, attacker, 40)

        if GaleCondition.GetCondition(attacker,"condition_carry_charge") ~= nil then
            GaleCondition.RemoveCondition(attacker,"condition_carry_charge")
        end
    end
    
end

local function ChargeTimeCb(inst,data)
    local old_percent = data.old_percent
    local percent = data.current_percent
    local owner = inst.components.inventoryitem:GetGrandOwner()
    local equipped = inst.components.equippable:IsEquipped()

    if percent <= 0 or not (owner and equipped) then 
        if inst.charge_fx then 
            inst.charge_fx:KillFX()
            inst.charge_fx = nil 
        end
    elseif percent >= 1 and (owner and equipped) then 
        if not inst.charge_fx then 
            inst.charge_fx = SpawnPrefab("gale_charge_fx")
            inst.charge_fx.entity:SetParent(owner.entity)
            inst.charge_fx.entity:AddFollower()
            inst.charge_fx.Follower:FollowSymbol(owner.GUID,"swap_object", 0, -190, 0)
            inst.charge_fx.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge")
        end
    end
end

-- ThePlayer:AddTag("galeatk_multithrust")
local function OnSpecialAtk(owner,data)
    local target = data.target
    if data.name == "galeatk_lunge" then
        if target then
            GaleCommon.AoeDoAttack(owner,target:GetPosition(),1.2,{
                instancemult = 1.5,
            })
        end
    elseif data.name == "galeatk_multithrust" then
        if data.other_data.areahit then
            if target then
                GaleCommon.AoeDoAttack(owner,target:GetPosition(),1.25,{
                    instancemult = 0.75,
                })
            end
        end
    elseif data.name == "galeatk_leap" then
        if target then
            local hit_pos = owner:GetPosition() + GaleCommon.GetFaceVector(owner) * owner.components.combat:GetHitRange() * 0.75
            GaleCommon.AoeForEach(owner,hit_pos,2.5,nil, {"INLIMBO"},{"_combat","_inventoryitem"},function(doer,other)
                local can_attack = doer.components.combat:CanTarget(other) and not doer.components.combat:IsAlly(other)
                local is_inv = other.components.inventoryitem ~= nil 
        
                if can_attack then 
                    doer.components.combat.ignorehitrange = true
                    doer.components.combat:DoAttack(other,doer.components.combat:GetWeapon(),nil,nil,GetRandomMinMax(0.75,1))
                    doer.components.combat.ignorehitrange = false
                elseif is_inv then 
                    GaleCommon.LaunchItem(other,doer,2)
                end
            end,
            function(doer,other)
                return other and other:IsValid()
            end)

            -- SpawnAt("gale_atk_firepuff_cold",target).Transform:SetScale(1,1,1)
            SpawnAt("gale_leap_puff_fx",hit_pos)
            

            local ring = SpawnAt("gale_ring_fx",hit_pos)
            ring.AnimState:SetDeltaTimeMultiplier(0.95)
            ring.AnimState:SetTime(8 * FRAMES)
            ring.AnimState:SetMultColour(123/255, 245/255, 247/255,1)
            ring.Transform:SetScale(0.61,0.61,0.61)
            ring:SpawnChild("gale_atk_leap_vfx")
            -- owner:SpawnChild("gale_atk_leap_vfx").Transform:SetPosition((target:GetPosition() - owner:GetPosition()):Get())
        end
        ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, owner, 20)
    end
end

local function OnHitOther(owner,data)
    if data.target and owner.sg and owner.sg.currentstate.name == "galeatk_multithrust" then
        GaleCondition.AddCondition(data.target,"condition_bleed")
    end
end

local function CrowbarClientFn(inst)

end

local function CrowbarServerFn(inst)
    inst.components.equippable.restrictedtag = "gale_weaponcharge"

    inst:AddComponent("gale_chargeable_weapon")
    inst.components.gale_chargeable_weapon.do_attack_fn = ChargeCommonAttack

    inst:ListenForEvent("gale_charge_time_change",ChargeTimeCb)

    -- ThePlayer:AddTag("galeatk_leap")
    inst:ListenForEvent("equipped",function(inst,data)
        if not inst.magicgas then
            -- print("[CrowbarServerFn]Spawn a gale_magicgas_vfx (banned) ?")
            inst.magicgas = SpawnPrefab("gale_magicgas_vfx")
            inst.magicgas.entity:SetParent(data.owner.entity)
            inst.magicgas.entity:AddFollower()
            inst.magicgas.Follower:FollowSymbol(data.owner.GUID, "swap_object", 15, -190, 0)
        end
    end)

    inst:ListenForEvent("onremove",function(inst,data)
        if inst.magicgas then
            inst.magicgas:Remove()
            inst.magicgas = nil 
        end
    end)

    inst:ListenForEvent("unequipped",function(inst,data)
        if inst.magicgas then
            inst.magicgas:Remove()
            inst.magicgas = nil 
        end
    end)
end

return GaleEntity.CreateNormalWeapon({
    assets = assets,
    prefabname = "gale_crowbar",
    tags = {"gale_crowbar","gale_only_rmb_charge","gale_parryweapon"},
    

    bank = "gale_crowbar",
    build = "gale_crowbar",
    anim = "idle",

    equippable_data = {
        owner_listeners = {
            {"gale_speicalatk",OnSpecialAtk},
            {"onhitother",OnHitOther},
        }
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        damage = 34,
        ranges = 0.2,
    },

    finiteuses_data = {
        maxuse = 175,
    },

    clientfn = CrowbarClientFn,
    serverfn = CrowbarServerFn,
}),
GaleEntity.CreateNormalFx({
    assets = assets,
    prefabname = "gale_circleslash_fx",    

    bank = "gale_circleslash_fx",
    build = "gale_circleslash_fx",
    anim = "idle",

    clientfn = function(inst)
        inst.Transform:SetTwoFaced()

        -- inst.Transform:SetScale()
        inst.AnimState:SetScale(1.8,1.8,1.8)   	
        inst.AnimState:SetLightOverride(1)   	
        inst.AnimState:SetFinalOffset(-1)   	
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)   
    end,
}),
GaleEntity.CreateNormalFx({
    assets = assets,
    prefabname = "gale_leap_puff_fx",

    bank = "round_puff_fx",
    build = "round_puff_fx",
    anim = "puff_lg",

    clientfn = function(inst)
        inst.AnimState:SetAddColour(50/255, 169/255, 255/255, 1)
    end,
})