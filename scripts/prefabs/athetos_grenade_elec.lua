local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/athetos_grenade_elec.zip"),
    Asset("ANIM", "anim/swap_athetos_grenade_elec.zip"),

    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),

    Asset("IMAGE", "images/inventoryimages/athetos_grenade_elec.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_grenade_elec.xml"),
}

local function DoExplode(inst)
    inst.SoundEmitter:KillSound("didi")
    inst.SoundEmitter:PlaySound("gale_sfx/battle/athetos_grenade_elec/explode")
    -- local fx = SpawnAt("hammer_mjolnir_crackle",inst,{0.8,0.8,0.8})
    -- fx.AnimState:HideSymbol("droplet")
    -- fx.AnimState:HideSymbol("flash_up")
    -- fx.AnimState:SetAddColour(0/255, 138/255, 255/255, 1)
    -- fx.AnimState:SetDeltaTimeMultiplier(1.66)
    -- fx.AnimState:SetLightOverride(1)

    local animfx = SpawnAt("hammer_mjolnir_crackle", inst, { 0.9, 0.7, 0.7 })
    animfx.AnimState:SetAddColour(50 / 255, 169 / 255, 255 / 255, 1)
    -- animfx.AnimState:SetAddColour(0/255, 138/255, 255/255, 1)

    -- animfx.AnimState:HideSymbol("flash_up")
    animfx.AnimState:HideSymbol("lightning_land")
    -- animfx.AnimState:HideSymbol("lightning1")
    animfx.AnimState:HideSymbol("droplet")
    -- animfx.AnimState:SetDeltaTimeMultiplier(1.66)
    animfx.AnimState:SetLightOverride(1)
    animfx.persists = false
    animfx:ListenForEvent("animover", animfx.Remove)

    if inst:GetPosition().y <= 0.05 then
        local ring = SpawnAt("gale_laser_ring_fx", inst)
        local s = 1.1
        ring.Transform:SetScale(s, s, s)
        ring.AnimState:SetFinalOffset(3)
        ring.AnimState:SetLayer(LAYER_GROUND)
        ring.AnimState:HideSymbol("circle")
        ring.AnimState:HideSymbol("glow_2")
        ring.AnimState:HideSymbol("lightning01")
    end

    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)

    inst:Hide()
    inst:StartThread(function()
        -- local spark_cnt = 0
        local rad = 1
        local max_rad = 5
        local already_hitted = {}

        while rad <= max_rad do
            local attacker = inst.components.complexprojectile.attacker
            if not (attacker and attacker:IsValid()) then
                attacker = inst
            end
            local hitted_ents = GaleCommon.AoeGetAttacked(attacker, inst:GetPosition(), rad,
                function(attacker, target)
                    local dmg = 0
                    if GaleCondition.GetCondition(target, "condition_metallic") then
                        dmg = GetRandomMinMax(200, 300)
                    else
                        dmg = GetRandomMinMax(20, 34)
                    end

                    if target:HasTag("player") then
                        dmg = dmg / 2
                    end

                    return dmg, nil, "electric"
                end,
                function(attacker, target)
                    return already_hitted[target] == nil
                end)

            for _, v in pairs(hitted_ents) do
                -- SpawnAt("electrichitsparks",v)
                already_hitted[v] = true
                v:RemoveDebuff("mindcontroller")
            end

            ---------------------------------------

            local old_rad = rad

            rad = rad + Remap(rad, 1, max_rad, 66 * FRAMES, 5 * FRAMES)

            local new_rad = rad

            if new_rad - old_rad >= 1.5 then
                for emit_rad = old_rad, new_rad, 30 * FRAMES do
                    local dd = 360 / math.random(4, 5)
                    local start_deg = math.random() * 360
                    for deg = start_deg, start_deg + 360 - dd, dd do
                        SpawnAt("electrichitsparks", inst, nil,
                            Vector3(math.cos(deg * DEGREES), 0, math.sin(deg * DEGREES)) * emit_rad)

                        -- spark_cnt = spark_cnt + 1
                    end
                end
            end



            for emit_rad = old_rad, new_rad, 8 * FRAMES do
                local scale = Remap(emit_rad, 1, max_rad, 1.1, 0.8)
                local points = {}
                local dd = 360 / math.random(6, 9)
                local start_deg = math.random() * 360
                for deg = start_deg, start_deg + 360 - dd, dd do
                    table.insert(points,
                        inst:GetPosition() + Vector3(math.cos(deg * DEGREES), 0, math.sin(deg * DEGREES)) * emit_rad)
                end

                for k, p1 in pairs(points) do
                    local p2 = k == #points and points[1] or points[k + 1]
                    SpawnPrefab("gale_lightningfx"):Emit(p1, p2, scale)
                end

                if emit_rad >= 4 and emit_rad == old_rad then
                    local dd = 360 / math.random(5, 7)
                    local start_deg = math.random() * 360
                    for deg = start_deg, start_deg + 360 - dd, dd do
                        local offset = Vector3(math.cos(deg * DEGREES), 0, math.sin(deg * DEGREES))
                        SpawnPrefab("gale_lightningfx"):Emit(inst:GetPosition() + offset * math.min(1, emit_rad),
                            inst:GetPosition() + offset * emit_rad, scale)
                    end
                end
            end

            -- local points = {}
            -- local dd = 360 / math.random(6,9)
            -- for deg = 0,360-dd,dd do
            --     table.insert(points,inst:GetPosition() + Vector3(math.cos(deg * DEGREES),0,math.sin(deg * DEGREES)) * old_rad)
            -- end

            -- for k,p1 in pairs(points) do
            --     local p2 = k == #points and points[1] or points[k+1]
            --     SpawnPrefab("gale_lightningfx"):Emit(p1,p2)
            -- end

            Sleep(0)
        end
        -- print("spark_cnt = ",spark_cnt)

        Sleep(0.1)
        local fx = SpawnAt("hammer_mjolnir_cracklebase", inst)
        local s = 0.9
        fx.Transform:SetScale(s, s, s)
        fx.AnimState:SetDeltaTimeMultiplier(0.66)
        fx.AnimState:SetLightOverride(1)
        -- fx.AnimState:SetMultColour(0/255, 60/255, 125/255, 1)
        fx.AnimState:SetAddColour(0 / 255, 138 / 255, 255 / 255, 1)
        fx:ListenForEvent("animover", fx.Remove)


        inst:Remove()
    end)
end

local function ExplodeCountdown(inst, duration)
    -- Play start sfx
    inst.SoundEmitter:PlaySound("gale_sfx/battle/athetos_grenade_elec/didi", "didi")

    inst.persists = false
    inst:DoTaskInTime(duration, DoExplode)

    inst:DoPeriodicTask(2 * FRAMES, function()
        if inst.should_red then
            inst.AnimState:SetAddColour(1, 0, 0, 1)
        else
            inst.AnimState:SetAddColour(0, 0, 0, 0)
        end

        inst.should_red = not inst.should_red
    end)

    inst.components.inventoryitem.canbepickedup = false
end

local function OnThrown(inst)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:PlayAnimation("throw", true)

    inst:ExplodeCountdown(1.5)
end

local function OnHit(inst, other)
    inst.AnimState:PlayAnimation("idle")
    -- inst.components.inventoryitem.canbepickedup = true
end

return GaleEntity.CreateNormalWeapon({
    prefabname = "athetos_grenade_elec",
    assets = assets,


    bank = "athetos_grenade_elec",
    build = "athetos_grenade_elec",
    anim = "idle",

    tags = { "allow_action_on_impassable" },

    weapon_data = {
        swapanims = { "swap_athetos_grenade_elec", "swap_athstos_grenade_elec" },
        damage = 0,
        ranges = { 12, 36 },
    },

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    clientfn = function(inst)
        inst.Transform:SetTwoFaced()
    end,

    serverfn = function(inst)
        inst.ExplodeCountdown = ExplodeCountdown

        inst.components.inventoryitem:SetSinks(true)

        inst.components.equippable.equipstack = true

        inst.components.weapon:SetElectric()

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM


        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(15)
        inst.components.complexprojectile:SetGravity(-35)
        inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
        inst.components.complexprojectile:SetOnLaunch(OnThrown)
        inst.components.complexprojectile:SetOnHit(OnHit)
    end,
})
