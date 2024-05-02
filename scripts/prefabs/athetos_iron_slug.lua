local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")
local brain = require("brains/athetos_iron_slug_brain")

local assets = {
    Asset("ANIM", "anim/athetos_iron_slug.zip"),
    Asset("ANIM", "anim/swap_athetos_iron_slug.zip"),


    Asset("IMAGE", "images/inventoryimages/athetos_iron_slug.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_iron_slug.xml"),
}

local function OnCollide(inst, other)
    if other and inst.components.combat:CanTarget(other)
        and not inst.components.combat:IsAlly(other)
        and GetTime() - (inst.collide_targets[other] or 0) > 1
        and not inst.sg:HasStateTag("fall")
        and not other:HasTag("wall") then
        local myvel = Vector3(inst.Physics:GetVelocity())
        local othervel = other.Physics and Vector3(other.Physics:GetVelocity()) or Vector3(0, 0, 0)
        local deltavel = othervel - myvel
        local toward_vec = (inst:GetPosition() - other:GetPosition()):GetNormalized()

        local cos_theta = toward_vec:Dot(deltavel) / (toward_vec:Length() * deltavel:Length())

        local toward_sub = deltavel:Length() * cos_theta

        local min_speed = 0.25
        if toward_sub >= min_speed then
            local damage_mult = Remap(math.clamp(toward_sub, 6, 20), 6, 20, 1, 10)

            inst.components.combat.ignorehitrange = true
            inst.components.combat:DoAttack(other, nil, nil, nil, damage_mult)
            inst.components.combat.ignorehitrange = false

            inst.collide_targets[other] = GetTime()
        end
    end
end

local function RedirectHealth(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if amount >= 0 then
        return
    end

    if ignore_invincible or ignore_absorb then
        return
    end

    local damage = -amount

    if damage < 166 then
        return true
    end
end

local function TransformToItem(inst)
    inst.sg:GoToState("idle")

    inst.health_store = 20
    if inst.components.health then
        inst.health_store = inst.components.health.currenthealth
        inst:RemoveComponent("health")
    end

    if not inst.components.armor then
        inst:AddComponent("armor")
    end
    inst.components.armor:InitIndestructible(0.90)

    inst:StopBrain()
end

local function TransformToCreature(inst)
    if not inst.components.health then
        inst:AddComponent("health")
    end

    inst.components.health:SetMaxHealth(20)
    inst.components.health:SetVal(math.clamp(inst.health_store or 20, 1, 20))
    inst.components.health.redirect = RedirectHealth

    inst.health_store = nil

    if inst.components.armor then
        inst:RemoveComponent("armor")
    end


    inst:RestartBrain()
end

local function OnEquip(inst, owner)
    TransformToItem(inst)
    owner.AnimState:OverrideSymbol("swap_body", "swap_athetos_iron_slug", "swap_body")
end

local function OnUnequip(inst, owner)
    inst.Physics:Stop()
    TransformToCreature(inst)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst.sg:GoToState("fall")
end

local function DropTargets(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, { "_combat" }, { "INLIMBO", "player" })
    for i, v in ipairs(ents) do
        if v.components.combat:TargetIs(inst) then
            v.components.combat:SetTarget(nil)
        end
    end
end

-- local function AddTileNutrients(inst, pt, nutrients)
--     local tile_x, tile_z = TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
--     TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, nutrients[1] or 0, nutrients[2] or 0,
--                                                          nutrients[3] or 0)
-- end

local function FindFarmPoints(inst)
    local mypos = inst:GetPosition()
    local mtile_x, mtile_y, mtile_z = TheWorld.Map:GetTileCenterPoint(mypos.x, 0, mypos.z)

    local cand_list = {}
    for dx = -4, 4, 4 do
        for dz = -4, 4, 4 do
            local tarpos = Vector3(mtile_x, mtile_y, mtile_z) + Vector3(dx, 0, dz)
            if TheWorld.Map:IsFarmableSoilAtPoint(tarpos.x, tarpos.y, tarpos.z) then
                -- local tile_x, tile_y, tile_z = TheWorld.Map:GetTileCenterPoint(tarpos.x, 0, tarpos.z)
                -- table.insert(cand_list, Vector3(tile_x, 0, tile_z))
                table.insert(cand_list, tarpos)
            end
        end
    end

    table.sort(cand_list, function(pos1, pos2)
        return (pos1 - mypos):LengthSq() < (pos2 - mypos):LengthSq()
    end)

    return cand_list
end


local function SteamAndFertilize(inst, workpos)
    if inst:IsAsleep() then
        -- print(inst, "is steaming offscreen")
    else
        -- print(inst, "is steaming activite")
    end

    local fxs = {}


    local pos            = inst:GetPosition()
    workpos              = workpos or pos

    local tile_x, tile_z = TheWorld.Map:GetTileCoordsAtPoint(workpos:Get())
    local is_farm_soil   = TheWorld.Map:IsFarmableSoilAtPoint(workpos.x, workpos.y, workpos.z)

    local steam_count    = math.random(2, 4)
    local pos_preset     = {
        Vector3(30, -47),
        Vector3(92, -52),
        Vector3(-24, -47),
        Vector3(-83, -52),
    }

    local add_value      = 4


    local add_steam_fn      = function(inst, fx)
        if is_farm_soil then
            TheWorld.components.farming_manager:AddSoilMoistureAtPoint(workpos.x, workpos.y, workpos.z, 4)
        end

        if fx then
            fx._color_index:set(1)
        end
    end

    local add_nutrient_1_fn = function(inst, fx)
        TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, add_value, 0, 0)
        if fx then
            fx._color_index:set(2)
        end
    end

    local add_nutrient_2_fn = function(inst, fx)
        TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, 0, add_value, 0)
        if fx then
            fx._color_index:set(3)
        end
    end

    local add_nutrient_3_fn = function(inst, fx)
        TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, 0, 0, add_value)
        if fx then
            fx._color_index:set(4)
        end
    end

    local effects           = {
        add_steam_fn,
    }

    if is_farm_soil then
        -- n1, n2, n3: 催长剂，堆肥（腐烂物等），粪肥
        local n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(tile_x, tile_z)
        local thres1 = 33
        local thres2 = 15

        if n1 < thres1 then
            table.insert(effects, add_nutrient_1_fn)
        end
        if n1 < thres2 then
            table.insert(effects, add_nutrient_1_fn)
        end


        if n2 < thres1 then
            table.insert(effects, add_nutrient_2_fn)
        end
        if n2 < thres2 then
            table.insert(effects, add_nutrient_2_fn)
        end


        if n3 < thres1 then
            table.insert(effects, add_nutrient_3_fn)
        end
        if n3 < thres2 then
            table.insert(effects, add_nutrient_3_fn)
        end
    end


    while #effects < steam_count do
        table.insert(effects, add_steam_fn)
    end

    shuffleArray(pos_preset)
    shuffleArray(effects)

    for i = 1, steam_count do
        local fxpos = pos_preset[i]
        local effectfn = effects[i]

        local fx = nil

        if not inst:IsAsleep() then
            fx = inst:SpawnChild("athetos_iron_slug_steam")
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "slug", fxpos:Get())
            if fxpos.x < 0 then
                fx._left_direction:set(true)
            end
            table.insert(fxs, fx)
        end

        effectfn(inst, fx)
    end


    return fxs
end

local function SlugOnEntitySleep(inst)
    if inst.work_offscreen_task then
        inst.work_offscreen_task:Cancel()
    end
    inst.work_offscreen_task = inst:DoPeriodicTask(30, function()
        if math.random() < inst.steam_fram_possibility then
            local nearby_farm_pos_cands = inst:FindFarmPoints()
            local first_pos = nearby_farm_pos_cands[1]

            if first_pos then
                local distsq = inst:GetDistanceSqToPoint(first_pos)
                if distsq <= 8 then
                    print(inst, "teleport to", first_pos, " to do farm work")
                    inst.Transform:SetPosition(first_pos.x, 0, first_pos.z)
                end
            end

            inst:SteamAndFertilize()
        end
    end)
end

local function SlugOnEntityWake(inst)
    if inst.work_offscreen_task then
        inst.work_offscreen_task:Cancel()
    end
    inst.work_offscreen_task = nil
end

return GaleEntity.CreateNormalEntity({
    prefabname = "athetos_iron_slug",
    assets = assets,

    bank = "athetos_iron_slug",
    build = "athetos_iron_slug",
    anim = "walk",

    tags = { "heavy", "nonpotatable", "hide_percentage", "thorny" },

    loop_anim = true,

    clientfn = function(inst)
        inst.entity:AddDynamicShadow()
        inst.DynamicShadow:SetSize(1, 0.6)

        MakeCharacterPhysics(inst, 1000, 0.75)

        inst.Transform:SetTwoFaced()
    end,

    serverfn = function(inst)
        inst.Physics:SetCollisionCallback(OnCollide)

        inst.collide_targets = {}
        inst.steam_possibility = 0.2
        inst.steam_fram_possibility = 0.5

        inst.FindFarmPoints = FindFarmPoints
        inst.SteamAndFertilize = SteamAndFertilize
        inst.OnEntitySleep = SlugOnEntitySleep
        inst.OnEntityWake = SlugOnEntityWake

        inst:AddComponent("lootdropper")

        inst:AddComponent("inspectable")

        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = 0.5
        inst.components.locomotor.runspeed = 0.5

        inst:AddComponent("inventoryitem")
        -- inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem.cangoincontainer = false
        -- inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem:SetSinks(true)
        inst.components.inventoryitem.imagename = "athetos_iron_slug"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/athetos_iron_slug.xml"

        inst:AddComponent("gale_item_desc")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.BODY
        inst.components.equippable:SetOnUnequip(OnUnequip)
        inst.components.equippable:SetOnEquip(OnEquip)
        inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

        inst:AddComponent("combat")
        inst.components.combat:SetRange(2)
        inst.components.combat:SetDefaultDamage(5)
        inst.components.combat:SetAttackPeriod(0.1)
        inst.components.combat:SetHurtSound("gale_sfx/battle/hit_metal")

        inst:SetStateGraph("SGathetos_iron_slug")
        inst:SetBrain(brain)

        inst:DoPeriodicTask(10, function()
            inst.collide_targets = {}
        end)

        inst:DoPeriodicTask(10, DropTargets)


        -- inst:AddComponent("hauntable")
        -- inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        TransformToCreature(inst)

        GaleCondition.AddCondition(inst, "condition_metallic")
    end,
})
