local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/gale_bombbox.zip"),
    Asset("ANIM", "anim/swap_gale_bombbox.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),
    

    Asset("IMAGE","images/inventoryimages/gale_bombbox.tex"),
    Asset("ATLAS","images/inventoryimages/gale_bombbox.xml"),
    Asset("IMAGE","images/inventoryimages/gale_bombbox_duplicate.tex"),
    Asset("ATLAS","images/inventoryimages/gale_bombbox_duplicate.xml"),
    
    Asset("IMAGE","images/inventoryimages/gale_bomb_projectile.tex"),
    Asset("ATLAS","images/inventoryimages/gale_bomb_projectile.xml"),
}

local torchfire_prefab = "torchfire_rag"

local function CheckBombCnt(inst)
    local exists_bombs_cnt = 0
    for k,v in pairs(inst.exists_bombs) do
        if v == true then
            exists_bombs_cnt = exists_bombs_cnt + 1
        end
    end

    if exists_bombs_cnt >= 2 then
        inst:AddTag("out_of_bomb")
    else 
        inst:RemoveTag("out_of_bomb")
    end


    return exists_bombs_cnt
end

local function CommonBombBoxClientFn(inst)
    
end

local function CommonBombBoxServerFn(inst)
    inst.exists_bombs = {}
    inst.CheckBombCnt = CheckBombCnt

    inst.components.equippable.restrictedtag = "gale_weaponcharge"

    inst:AddComponent("gale_chargeable_weapon")
    -- inst.components.gale_chargeable_weapon.never_charge = true
    inst.components.gale_chargeable_weapon.do_attack_fn = function(inst,player,target,target_pos,percent)
        percent = GaleCondition.GetCondition(player,"condition_carry_charge") ~= nil and 1 or percent
        

        if inst:CheckBombCnt() < 2 then
            local real_target_pos = target and target:GetPosition() or target_pos
            local delta = real_target_pos - player:GetPosition()
            local proj = SpawnAt("gale_bomb_projectile",inst)
            proj.components.complexprojectile.usehigharc = delta:Length() >= 10
            proj.components.complexprojectile:SetHorizontalSpeed(15 + 10 * percent)
            proj.components.complexprojectile:SetGravity(-29 + 8 * percent)
            proj.components.complexprojectile:Launch(real_target_pos,player)
    
            inst.exists_bombs[proj] = true
            inst:ListenForEvent("onremove",function()
                inst.exists_bombs[proj] = nil
                inst:CheckBombCnt()
            end,proj)
            inst:CheckBombCnt()
        else 
            -- Can't thorw bomb 
        end

        if GaleCondition.GetCondition(player,"condition_carry_charge") ~= nil then
            GaleCondition.RemoveCondition(player,"condition_carry_charge")
        end
    end
end

local function CommonBombProjClientFn(inst)
    RemovePhysicsColliders(inst)
    inst.Physics:SetDontRemoveOnSleep(true) -- so the object can land and put out the fire, also an optimization due to how this moves through the world

    inst.Transform:SetFourFaced()

    
end

local function BombResetFireFx(inst, owner,prefab_name)
    if inst.firefx then
        inst.firefx:Remove()
        inst.firefx = nil 
    end

    if prefab_name then
        inst.firefx = SpawnPrefab(prefab_name)
        inst.firefx.SoundEmitter:KillAllSounds()
        inst.firefx.entity:AddFollower()
        if owner then
            inst.firefx.entity:SetParent(owner.entity)
            inst.firefx.Follower:FollowSymbol( owner.GUID, "swap_object", 32, -130, 1 )
        else
            inst.firefx.entity:SetParent(inst.entity)
            inst.firefx.Follower:FollowSymbol( inst.GUID, "fireline", -10, 4, 0.1 )
        end
        inst.firefx:AttachLightTo(owner or inst)
    end
end

local function EnableFlashing(inst,enabled)
    if inst.FlashingTask then
        KillThread(inst.FlashingTask)
        inst.FlashingTask = nil 
    end

    if enabled then
        inst.FlashingTask = inst:StartThread(function()
            local red = true
            while true do
                if red then
                    inst.AnimState:SetAddColour(1,0,0,1)
                else
                    inst.AnimState:SetAddColour(0,0,0,1)
                end
                red = not red
                Sleep(0.1)
            end
        end)
    end
end

local function DoExplode(source,attacker,eater)
    local explo = SpawnAt("gale_bomb_projectile_explode",source)
    explo.Transform:SetScale(1.5,1.5,1.5)
    explo.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
    explo:SpawnChild("gale_normal_explode_vfx")

    if source:GetPosition().y <= 0.05 then
        local ring = SpawnAt("gale_laser_ring_fx",source)
        ring.Transform:SetScale(0.9,0.9,0.9)
        ring.AnimState:SetFinalOffset(3)
        ring.AnimState:SetLayer(LAYER_GROUND)
        ring.AnimState:HideSymbol("circle")
        ring.AnimState:HideSymbol("glow_2")
        ring.AnimState:HideSymbol("lightning01")
    end

    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, source, 40)

    GaleCommon.AoeForEach(
        attacker,
        source:GetPosition(),
        2.8,
        nil,
        {"INLIMBO"},
        nil,
        function(attacker,v)
            if v.components.combat then
                local multi = 1
                local basedamage = GetRandomMinMax(60,120)
                if eater and v == eater then
                    multi = 2.5
                    basedamage = math.max(100,basedamage)
                elseif source.components.inventoryitem:GetGrandOwner() == v then
                    multi = 2
                    basedamage = math.max(100,basedamage)
                end
                v.components.combat:GetAttacked(attacker,basedamage * multi)
                v:PushEvent("knockback", { knocker = explo, radius = GetRandomMinMax(1.2,1.4) + v:GetPhysicsRadius(.5)})
            elseif v.components.inventoryitem then
                if v.Physics then
                    GaleCommon.LaunchItem(v,source,5)
                end
                
            elseif v.components.workable ~= nil
                and v.components.workable:CanBeWorked()
                and v.components.workable.action ~= ACTIONS.NET then

                -- SpawnPrefab("collapse_small",v)

                v.components.workable:WorkedBy(attacker,5)
            end
        end,
        function(inst,v)
            local is_combat = v.components.combat and v.components.health and not v.components.health:IsDead()
                and not (v.sg and v.sg:HasStateTag("dead"))
                and not v:HasTag("playerghost")
            local is_inventory = v.components.inventoryitem
            return v and v:IsValid() 
                and (is_combat or is_inventory or v.components.workable)
        end
    )

    source:Remove()
end

local function BombProjOnThrown(inst)
    inst.AnimState:PlayAnimation("throw",true)

    inst:BombResetFireFx(nil,torchfire_prefab)

    if inst.status == nil then
        inst.SoundEmitter:PlaySound("gale_sfx/battle/bomb/p1_bomb_fuse","fuse")
        inst:DoTaskInTime(inst.burning_time,function()
            inst.SoundEmitter:KillSound("fuse")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/bomb/p1_bomb_fuse_warn","fuse_warn")
            inst.status = "fuse_warn"

            inst:EnableFlashing(true)
            inst:DoTaskInTime(inst.explode_delay,function()
                inst:DoExplode(inst.components.complexprojectile.attacker or inst)
            end)
        end)
        inst.status = "fuse"

        inst:ListenForEvent("onremove",function()
            inst:Remove()
        end,inst.components.complexprojectile.attacker)
    end
end

local function BombProjOnHit(inst,other)
    inst.AnimState:PlayAnimation("single")
end

local function CommonBombProjServerFn(inst)
    inst.status = nil 
    inst.has_triggered = false
    inst.burning_time = 3.2
    inst.explode_delay = 0.8

    inst.BombResetFireFx = BombResetFireFx
    inst.EnableFlashing = EnableFlashing
    inst.DoExplode = DoExplode

    inst:AddComponent("bait")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.secondaryfoodtype = FOODTYPE.VEGGIE
    inst.components.edible.sanityvalue = 0
    inst.components.edible.temperaturedelta = 0
    inst.components.edible.temperatureduration = 0
    inst.components.edible:SetOnEatenFn(function(inst,eater)
        local attacker = inst.components.complexprojectile.attacker
        eater:DoTaskInTime(1.2,function()
            local fakeball = SpawnAt(inst.prefab,eater)
            fakeball:DoExplode(attacker and attacker:IsValid() and attacker or fakeball,eater)
        end)
    end)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile.usehigharc = true
    -- inst.components.complexprojectile.onupdatefn = CommonBombProjOnUpdate
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-29)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(BombProjOnThrown)
    inst.components.complexprojectile:SetOnHit(BombProjOnHit)

    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        inst:BombResetFireFx(nil,torchfire_prefab)
    end)
    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst)
        inst:BombResetFireFx()
        if inst.status == "fuse" then
            inst.SoundEmitter:PlaySound("gale_sfx/battle/bomb/p1_bomb_fuse","fuse")
        elseif inst.status == "fuse_warn" then
            inst.SoundEmitter:KillSound("fuse")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/bomb/p1_bomb_fuse_warn","fuse_warn")
        end
    end)

    inst:ListenForEvent("equipped",function(inst,data)
        inst:BombResetFireFx(data.owner,torchfire_prefab)
    end)

    inst:ListenForEvent("unequipped",function(inst,data)
        inst:BombResetFireFx()
    end)

    inst:ListenForEvent("onremove",function(inst,data)
        inst:BombResetFireFx()
    end)
end

local function HighLightClientFn(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
end

return GaleEntity.CreateNormalWeapon({
    prefabname = "gale_bombbox",
    assets = assets,

    bank = "gale_bombbox",
    build = "gale_bombbox",
    anim = "idle",

    clientfn = CommonBombBoxClientFn,
    serverfn = CommonBombBoxServerFn,

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        swapanims = {"swap_gale_bombbox","swap_gale_bombbox"},
        damage = 0,
        ranges = {12,36}
    },
}),
GaleEntity.CreateNormalWeapon({
    prefabname = "gale_bombbox_duplicate",
    assets = assets,

    bank = "gale_bombbox",
    build = "gale_bombbox",
    anim = "idle",

    clientfn = CommonBombBoxClientFn,
    serverfn = CommonBombBoxServerFn,

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        swapanims = {"swap_gale_bombbox","swap_gale_bombbox"},
        damage = 0,
        ranges = {12,36}
    },
}),
GaleEntity.CreateNormalWeapon({
    prefabname = "gale_bomb_projectile",
    assets = assets,

    bank = "gale_bombbox",
    build = "gale_bombbox",
    anim = "single",

    tags = {"molebait","explosive"},

    persists = false,

    clientfn = CommonBombProjClientFn,
    serverfn = CommonBombProjServerFn,

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        swapanims = {"swap_gale_bombbox","swap_gale_bombbox"},
        damage = 0,
        ranges = {12,36}
    },
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_bomb_projectile_explode",
    assets = assets,

    bank = "lavaarena_firebomb",
    build = "lavaarena_firebomb",
    anim = "used",

    clientfn = HighLightClientFn,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_bomb_projectile_hit",
    assets = assets,

    bank = "lavaarena_firebomb",
    build = "lavaarena_firebomb",
    anim = "hitfx",

    clientfn = HighLightClientFn,
})