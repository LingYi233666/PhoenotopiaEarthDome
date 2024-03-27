local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleWeaponSkill = require("util/gale_weaponskill")


local function OnEquip(inst,owner)
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    owner.AnimState:ClearOverrideSymbol("swap_object")
    
    inst.swapanim = owner:SpawnChild("athetos_psychostatic_cutter_swapanim")
    inst.swapanim.Follower:FollowSymbol(owner.GUID,"swap_object",nil,nil,nil,true)
    inst.swapanim.components.highlightchild:SetOwner(owner)
    local frame = math.random(inst.swapanim.AnimState:GetCurrentAnimationNumFrames()) - 1
	inst.swapanim.AnimState:SetFrame(frame)

    owner.AnimState:SetSymbolLightOverride("swap_object",1)

    inst:EnableFireFx(true)

    inst.SoundEmitter:PlaySound("gale_sfx/battle/athetos_psychostatic_cutter/equip")
end

local function OnUnequip(inst,owner)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    if inst.swapanim then
        inst.swapanim:Remove()
        inst.swapanim = nil 
    end
    owner.AnimState:SetSymbolLightOverride("swap_object",0)

    inst:EnableFireFx(false)
    inst.SoundEmitter:PlaySound("gale_sfx/battle/athetos_psychostatic_cutter/unequip")
end

local function EnableFireFx(inst,enable)
    local owner = inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner
    if enable and inst.firefxs == nil and owner then 
        inst.firefxs = {}
        local vfx_pos = {
            Vector3(8,-82,0.1),
            Vector3(17,-136,0.1),
            Vector3(8,-197,0.1),
        }
        for _,pos in pairs(vfx_pos) do
            local fx = inst:SpawnChild("gale_flame_vfx")
            fx.entity:AddFollower()
            -- set purple colour 
            fx._colour:set(2)
    
            -- small size 
            fx._scale:set(3)
            fx.Follower:FollowSymbol(owner.GUID,"swap_object",pos:Get())
    
            table.insert(inst.firefxs,fx)
        end
    elseif not enable and inst.firefxs ~= nil then 
        for _,v in pairs(inst.firefxs) do
            v:Remove()
        end
        inst.firefxs = nil 
    end
end

local function ProjectileOnUpdate(inst)
    inst.max_range = inst.max_range or 20
    inst.start_pos = inst.start_pos or inst:GetPosition()
    
    local dist_moved = (inst:GetPosition() - inst.start_pos):Length()
    if dist_moved >= inst.max_range then
        inst.components.complexprojectile:Hit()
        return true
    else
        if dist_moved >= 0.66 then
            inst:Show()
        else 
            inst:Hide()
        end
    end

    if inst.entity:IsVisible() and not inst.vfx then
        inst.vfx = inst:SpawnChild("gale_flame_swordspirit_vfx")
    end

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed,0,0)

    
    local attacker = inst.components.complexprojectile.attacker
    if not (attacker and attacker:IsValid() and not IsEntityDead(attacker)) then
        inst.components.complexprojectile:Hit()
    else 
        local x,y,z = inst.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x,y,z,1.5,{"_combat","_health"},{"INLIMBO"})
        for k,v in pairs(ents) do 
            if attacker.components.combat and attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then 

                -- local tx,ty,tz = inst.entity:WorldToLocalSpace(v:GetPosition():Get())

                -- if tx >= -0.4 and tz >= -0.66 and tz <= 0.66 then 
                --     inst.components.complexprojectile:Hit(v)
                --     break
                -- end
                if not inst.hitted_targets[v] and attacker and attacker:IsValid() and attacker.components.combat then
                    local fx = SpawnAt("blossom_hit_fx",v)
                    -- local frame = math.random(inst.swapanim.AnimState:GetCurrentAnimationNumFrames()) - 1
                    -- inst.swapanim.AnimState:SetFrame(frame)
                    fx.AnimState:HideSymbol("fff")
                    fx.AnimState:HideSymbol("fff2")
                    fx.AnimState:HideSymbol("fff3")
                    fx.persists = false
                    fx.AnimState:SetAddColour(1,0.2,1,1)
                    fx:ListenForEvent("animover",fx.Remove)

                    attacker.components.combat:DoAttack(v, inst, inst,nil,nil,99999)
                    
                    inst.hitted_targets[v] = true
                end
            end 
        end
    end

    
    return true
end

local function ProjectileOnHit(inst,attacker,target)
    inst:Remove()
end

local function ProjectileGetDamageFn(inst,attacker,target)
    return GetRandomMinMax(50,70)
end

return GaleEntity.CreateNormalWeapon({
    prefabname = "athetos_psychostatic_cutter",
    assets = {
        Asset("ANIM", "anim/athetos_psychostatic_cutter.zip"),
      
        Asset("IMAGE","images/inventoryimages/athetos_psychostatic_cutter.tex"),
        Asset("ATLAS","images/inventoryimages/athetos_psychostatic_cutter.xml"),
    },

    bank = "athetos_psychostatic_cutter",
    build = "athetos_psychostatic_cutter",
    anim = "idle",

    tags = {"allow_action_on_impassable"},

    weapon_data = {
        damage = 68,
        onequip_anim_override = OnEquip,
        onunequip_anim_override = OnUnequip,
    },

    inventoryitem_data = {
        floatable_param = {"small", 0.1, 0.88},
        use_gale_item_desc = true,
    },

    finiteuses_data = {
        maxuse = 200,
    },

    clientfn = function(inst)
        GaleWeaponSkill.AddAoetargetingClient(inst,"line",nil,12)
        
        inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
		inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
        inst.components.aoetargeting.reticule.validcolour = { 253/255, 123/255, 255/255, 1 }
        inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    end,

    serverfn = function(inst)
        inst.charge_sound = "gale_sfx/battle/athetos_psychostatic_cutter/charge"

        inst.EnableFireFx = EnableFireFx
        GaleWeaponSkill.AddAoetargetingServer(inst,function(inst,doer,pos)
            inst.components.rechargeable:Discharge(3)
            doer.SoundEmitter:PlaySound("gale_sfx/battle/athetos_psychostatic_cutter/launch")
            SpawnAt("athetos_psychostatic_cutter_swordspirit",doer).components.complexprojectile:Launch(pos,doer)
            inst.components.finiteuses:Use(5)
        end)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "athetos_psychostatic_cutter_swapanim",
    assets = {
        Asset("ANIM", "anim/athetos_psychostatic_cutter.zip"),
    },

    bank = "athetos_psychostatic_cutter",
    build = "athetos_psychostatic_cutter",
    anim = "onhand",

    loop_anim = true,
    animover_remove = false,

    clientfn = function(inst)
        inst:AddComponent("highlightchild")
    end,

    serverfn = function(inst)
        inst.entity:AddFollower()

        inst:AddComponent("colouradder")
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "athetos_psychostatic_cutter_swordspirit",
    assets = {},

    clientfn = function(inst)
        MakeProjectilePhysics(inst)
        inst:AddComponent("highlightchild")
    end,

    serverfn = function(inst)
        -- inst:SpawnChild("gale_flame_swordspirit_vfx")

        inst.hitted_targets = {}

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(ProjectileGetDamageFn)

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(38)
        inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
        inst.components.complexprojectile.onupdatefn = ProjectileOnUpdate
    end,
})