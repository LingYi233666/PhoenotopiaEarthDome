local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")
local GaleChargeableWeaponFns = require("util/gale_chargeable_weapon_fns")

local assets = {
    Asset("ANIM", "anim/gale_spear.zip"),
    Asset("ANIM", "anim/swap_gale_spear.zip"),
    Asset("ANIM", "anim/floating_items.zip"),

    Asset("IMAGE", "images/inventoryimages/gale_spear.tex"),
    Asset("ATLAS", "images/inventoryimages/gale_spear.xml"),
}

local SPEAR_TRIGGER_DIST_NORMAL = 0.33
local SPEAR_TRIGGER_DIST_CHARGE = 0.33
local SPEAR_EXPLODE_DIST_CHARGE = 3.5

local function GetHeadPoint(inst, pre_dist)
    pre_dist = pre_dist or 0.8
    return inst:GetPosition() + GaleCommon.GetFaceVector(inst) * pre_dist
end

local function LaunchSpearAtPos(inst, player, pos, charge_complete)
    local proj = SpawnAt("gale_spear_projectile", inst)
    proj.components.weapon:SetDamage(inst.components.weapon.damage)

    if charge_complete then
        proj.AnimState:SetAddColour(0, 1, 1, 1)
        proj.charge_complete = true
        proj.components.complexprojectile:SetHorizontalSpeed(25)
        proj._usetail:set(true)

        if GaleCondition.GetCondition(player, "condition_carry_charge") ~= nil then
            GaleCondition.RemoveCondition(player, "condition_carry_charge")
        end

        player.SoundEmitter:PlaySound("gale_sfx/character/charged_spear_throw")
    end

    -- local room = TheWorld.components.gale_interior_room_manager:GetRoom(inst:GetPosition())
    -- if room then
    --     proj.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
    -- end

    proj.components.complexprojectile:Launch(pos, player, inst)
    proj:DoInitSpeed()
end

local function SpearChargeTimeCb(inst, data)
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
            inst.charge_fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -155, 0)
            inst.charge_fx.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge")
        end
    end
end

local function SpearClientFn(inst)
    -- MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)
end

local function SpearServerFn(inst)
    inst.components.weapon.attackwear = 0

    inst.components.equippable.restrictedtag = "gale_weaponcharge"

    inst:AddComponent("gale_chargeable_weapon")
    inst.components.gale_chargeable_weapon.do_attack_fn = function(inst, player, target, target_pos, percent)
        local face_vec = GaleCommon.GetFaceVector(player)

        LaunchSpearAtPos(inst, player, player:GetPosition() + face_vec * 10,
            percent >= 1 or GaleCondition.GetCondition(player, "condition_carry_charge") ~= nil)

        inst.components.finiteuses:Use(1)
    end

    inst:ListenForEvent("gale_charge_time_change", GaleChargeableWeaponFns.ChargeTimeCbWrapper({ 0, -155, 0 }))
end

-----------------------------------------------------------------------------------------------------------------

local function OnProjectileHit(inst, attacker, target)
    inst._usetail:set(false)

    if inst.charge_complete then
        local fx = SpawnAt("gale_atk_firepuff_cold", inst)
        fx.Transform:SetScale(2, 2, 2)
        fx.SoundEmitter:PlaySound("gale_sfx/battle/explode")

        inst:SpawnChild("gale_blue_explode_vfx")

        ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)

        GaleCommon.AoeForEach(
            attacker,
            GetHeadPoint(inst),
            SPEAR_EXPLODE_DIST_CHARGE,
            nil,
            { "INLIMBO" },
            { "_combat", "_inventoryitem" },
            function(attacker, v)
                if attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
                    attacker.components.combat.ignorehitrange = true
                    attacker.components.combat:DoAttack(v, inst, inst, nil,
                        inst.charge_complete and GetRandomMinMax(2, 2.5) or 1)
                    attacker.components.combat.ignorehitrange = false

                    v:PushEvent("knockback",
                        { knocker = inst, radius = GetRandomMinMax(1.2, 1.4) + v:GetPhysicsRadius(.5) })
                    SpawnPrefab("gale_hit_color_adder"):SetTarget(v)
                elseif v.components.inventoryitem then
                    SpawnPrefab("gale_hit_color_adder"):SetTarget(v)
                    GaleCommon.LaunchItem(v, inst, 5)
                end
            end,
            function(inst, v)
                local is_combat = v.components.combat and v.components.health and not v.components.health:IsDead()
                    and not (v.sg and v.sg:HasStateTag("dead"))
                    and not v:HasTag("playerghost")
                local is_inventory = v.components.inventoryitem
                return v and v:IsValid()
                    and (is_combat or is_inventory or v.components.workable)
            end
        )

        if attacker.components.gale_skiller and attacker.components.gale_skiller:IsLearned("spear_fragment") then
            local face_vec = GaleCommon.GetFaceVector(inst)
            local side_vec = face_vec:Cross(Vector3(0, 1, 0))

            -- local fly_times = math.random() <= 0.5 and { 0.33, 0.44 } or { 0.44, 0.33 }
            -- for i = -1, 1, 2 do
            --     local frag = SpawnAt("gale_spear_projectile_fragment", inst)
            --     local tarpos = GetHeadPoint(inst) + side_vec * i

            --     if i == -1 then
            --         frag.max_fly_time = fly_times[1]
            --     else
            --         frag.max_fly_time = fly_times[2]
            --     end


            --     frag.components.complexprojectile:Launch(tarpos, attacker)
            --     frag.Transform:SetPosition(GetHeadPoint(inst):Get())
            --     frag:ForceFacePoint(tarpos:Get())
            -- end

            local start_degree = -20
            local stop_degree = 20
            local num_frag = 5
            local step = (stop_degree - start_degree) / num_frag

            for i = 1, num_frag do
                local cur_degree = start_degree + i * step + math.random(-5, 5)
                local direction = Vector3FromTheta(cur_degree * DEGREES)
                local spawn_pos = GetHeadPoint(inst, 3)
                local target_pos = spawn_pos + face_vec * direction.x + side_vec * direction.z

                local frag = SpawnAt("gale_spear_projectile_fragment", spawn_pos)
                frag.max_fly_time = GetRandomMinMax(0.2, 0.3)

                frag.components.complexprojectile:Launch(target_pos, attacker)
                frag.Transform:SetPosition(spawn_pos:Get())
                frag:ForceFacePoint(target_pos:Get())
            end
        end
    elseif target then
        SpawnAt("gale_weaponsparks", inst):SetPiercing(attacker, target)

        attacker.components.combat.ignorehitrange = true
        attacker.components.combat:DoAttack(target, nil, inst)
        attacker.components.combat.ignorehitrange = false

        -- Spear remain on emy test
        if attacker.components.gale_skiller and attacker.components.gale_skiller:IsLearned("spear_remain") then
            local x1, y1, z1 = inst.Transform:GetWorldPosition()
            local th1 = inst.Transform:GetRotation() * PI / 180.0

            local x2, y2, z2 = target.Transform:GetWorldPosition()
            local th2 = target.Transform:GetRotation() * PI / 180.0

            local vec_delta = Vector3(x2 - x1, y2 - y1, z2 - z1):GetNormalized()
            x1, y1, z1 = (Vector3(x1, y1, z1) + vec_delta * FRAMES * 3 * 6):Get()


            local x3 = x1 * math.cos(th2) - x2 * math.cos(th2) + z1 * math.sin(-th2) - z2 * math.sin(-th2)
            local y3 = y1 - y2
            local z3 = z1 * math.cos(th2) - z2 * math.cos(th2) - x1 * math.sin(-th2) + x2 * math.sin(-th2)
            local th3 = th1 - th2

            local remained = target:SpawnChild("gale_spear_projectile_remain")
            remained.owner = attacker
            remained.Transform:SetPosition(x3, y3, z3)
            remained.Transform:SetRotation((th3 * 180.0 / PI) + GetRandomMinMax(15, -15))
            remained:AttachTo(target)
        end

        -- test done
    end

    inst:Hide()
    inst:DoTaskInTime(5 * FRAMES, inst.Remove)
    -- inst:Remove()
end

local function CreateTail()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("tail_1")
    inst.AnimState:SetAddColour(0, 1, 1, 1)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    -- local scale = TUNING.KUNAI_TAIL_SCALE or Vector3(1.33,1,1)
    -- inst.Transform:SetScale(1.33,1,1)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


local function OnUpdateProjectileTail(inst)
    if not inst._usetail:value() then return end

    local FADE_TIME = 0.33
    local tail = CreateTail()
    tail.Transform:SetPosition(inst.Transform:GetWorldPosition())
    tail.Transform:SetRotation(inst.Transform:GetRotation())

    local FADE_FRAMES = 5 * FRAMES
    local c = (not inst.entity:IsVisible() and 0) or
        (inst._fade ~= nil and (FADE_FRAMES - inst._fade:value() + 1) / FADE_FRAMES) or 1
    if c > 0 then
        local tail = CreateTail()
        tail.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tail.Transform:SetRotation(inst.Transform:GetRotation())
        if c < 1 then
            tail.AnimState:SetTime(c * tail.AnimState:GetCurrentAnimationLength())
        end
    end
end

local function projectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("gale_spear")
    inst.AnimState:SetBuild("gale_spear")
    inst.AnimState:PlayAnimation("throwing", true)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLightOverride(1)

    inst.Transform:SetScale(1.1, 1.1, 1.1)

    inst._fade = net_tinybyte(inst.GUID, "kunai_lumin_projectile._fade")
    inst._usetail = net_bool(inst.GUID, "kunai_lumin_projectile._usetail")
    inst._usetail:set(false)

    if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(0, OnUpdateProjectileTail)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst.persists = false

    inst.DoInitSpeed = function(inst)
        inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)
    end

    inst.Physics:SetCollisionCallback(function(inst, other)
        if other and other.prefab == "gale_polygon_physics" and not inst.collide then
            inst.collide = true
            inst.components.complexprojectile:Hit(other)
        end
    end)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)
    inst.components.complexprojectile:SetHorizontalSpeed(20)
    inst.components.complexprojectile.onupdatefn = function(inst, dt)
        dt = dt or FRAMES

        local self = inst.components.complexprojectile
        local head_point = GetHeadPoint(inst)
        local x, y, z = head_point:Get()

        self.flying_time = (self.flying_time or 0) + dt
        inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

        for k, v in pairs(TheSim:FindEntities(x, y, z, 4, { "_combat" })) do
            local rad = inst.charge_complete and SPEAR_TRIGGER_DIST_CHARGE or SPEAR_TRIGGER_DIST_NORMAL

            if self.attacker.components.combat:CanTarget(v)
                and not self.attacker.components.combat:IsAlly(v) then
                local hit_dist = rad + v:GetPhysicsRadius(0)
                local curr_dist = (head_point - v:GetPosition()):Length()

                if curr_dist <= hit_dist then
                    self:Hit(v)
                    break
                end
            end
        end

        if self.flying_time >= 2 then
            self:Hit()
        end

        return true
    end


    return inst
end

local function OnFragmentHit(inst, attacker, target)
    if target then
        target.components.combat:GetAttacked(attacker, GetRandomMinMax(10, 15))
    end

    -- ThePlayer:SpawnChild("gale_quick_spark_vfx")._color_set:set("blue")
    inst:SpawnChild("gale_quick_spark_vfx")._color_set:set("blue")
    inst:Hide()
    inst.SoundEmitter:PlaySound("gale_sfx/battle/bit_bot_bullet")

    inst:DoTaskInTime(5 * FRAMES, inst.Remove)
end


return GaleEntity.CreateNormalWeapon({
        assets = assets,
        prefabname = "gale_spear",
        tags = { "sharp", "pointy", "gale_spear", "gale_only_rmb_charge" },
        bank = "gale_spear",
        build = "gale_spear",
        anim = "idle",

        inventoryitem_data = {
            use_gale_item_desc = true,
        },

        finiteuses_data = {
            maxuse = 150,
        },

        weapon_data = {
            damage = 45,
            ranges = { 12, 36 },
        },

        clientfn = SpearClientFn,
        serverfn = SpearServerFn,
    }),
    Prefab("gale_spear_projectile", projectile_fn, assets),
    GaleEntity.CreateNormalEntity({
        assets = assets,
        prefabname = "gale_spear_projectile_remain",
        tags = { "NOCLICK", "NOBLOCK", "FX" },
        bank = "gale_spear",
        build = "gale_spear",
        anim = "throwing",

        persists = false,

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLightOverride(1)

            inst.Transform:SetScale(1.1, 1.1, 1.1)
        end,
        serverfn = function(inst)
            inst.AttachTo = function(inst, target)
                local s1, s2, s3 = target.Transform:GetScale()
                inst.Transform:SetScale(1 / s1, 1 / s2, 1 / s3)
                inst.attack_task = inst:DoPeriodicTask(0.33, function()
                    local attacker = (inst.owner and inst.owner:IsValid()) and inst.owner or inst
                    if target.components.combat and target.components.health and not target.components.health:IsDead() then
                        target.components.combat:GetAttacked(attacker, GetRandomMinMax(1, 2))
                    end
                end)
                inst:DoTaskInTime(GetRandomMinMax(3.5, 4), function()
                    inst.attack_task:Cancel()
                    ErodeAway(inst)
                end)
            end
        end,
    }),
    GaleEntity.CreateNormalEntity({
        assets = assets,
        prefabname = "gale_spear_projectile_fragment",
        tags = { "NOCLICK", "NOBLOCK", "FX" },
        bank = "lavaarena_blowdart_attacks",
        build = "lavaarena_blowdart_attacks",
        anim = "attack_3",
        loop_anim = true,

        persists = false,

        clientfn = function(inst)
            MakeInventoryPhysics(inst)
            RemovePhysicsColliders(inst)

            inst.AnimState:SetAddColour(0, 1, 1, 1)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            -- inst.AnimState:SetDeltaTimeMultiplier(1.5)
        end,
        serverfn = function(inst)
            inst.max_fly_time = GetRandomMinMax(0.33, 0.5)

            inst:AddComponent("complexprojectile")
            inst.components.complexprojectile:SetOnHit(OnFragmentHit)
            inst.components.complexprojectile:SetHorizontalSpeed(35)
            inst.components.complexprojectile.onupdatefn = function(inst, dt)
                dt = dt or FRAMES

                local self = inst.components.complexprojectile
                local x, y, z = inst:GetPosition():Get()

                self.flying_time = (self.flying_time or 0) + dt
                inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

                for k, v in pairs(TheSim:FindEntities(x, y, z, 1, { "_combat" })) do
                    if self.attacker.components.combat:CanTarget(v)
                        and not self.attacker.components.combat:IsAlly(v)
                        and inst:IsNear(v, 0.66 + v:GetPhysicsRadius(0)) then
                        self:Hit(v)
                        break
                    end
                end

                if self.flying_time >= inst.max_fly_time then
                    self:Hit()
                end

                return true
            end
        end,
    })
