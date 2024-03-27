local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")


local containers = require("containers")
local containers_params = containers.params

local container_param = {
    widget =
    {
        slotpos =
        {
            Vector3(0, -32 - 4, 0),
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 60, 0),
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
    acceptsstacks = false,
    excludefromcrafting = true,
    itemtestfn = function(container, item, slot)
        return item:HasTag("msf_clip_pistol")
    end,
}
-- require("containers").params.msf_silencer_pistol.widget.pos.y = 60
containers_params.msf_silencer_pistol = container_param

local function HasAmmo(inst)
    local clip = inst.components.container:GetItemInSlot(1)
    if clip then
        local bullet = clip.components.container:FindItem(function(item)
            return item and item:IsValid()
        end)

        return bullet ~= nil
    end
end

local function GetAmmo(inst)
    local clip = inst.components.container:GetItemInSlot(1)
    if clip then
        local bullet = clip.components.container:FindItem(function(item)
            return item and item:IsValid()
        end)

        if bullet then
            if bullet.components.stackable then
                return bullet.components.stackable:Get()
            else
                return bullet
            end
        end
    end
end

local function GetNumAmmo(inst)
    local result = 0
    local clip = inst.components.container:GetItemInSlot(1)
    if clip then
        for k, v in pairs(clip.components.container.slots) do
            if v ~= nil then
                result = result + 1
            end
        end
    end

    return result
end


local function WeaponOnLaunchedProjectile(inst, attacker, target)
    if inst.components.gale_blaster_jammed:JudgeJammed() then
        local owner = inst.components.inventoryitem:GetGrandOwner()

        local jammedfx = SpawnPrefab("gale_quick_spark_vfx")
        jammedfx.entity:SetParent(owner.entity)
        jammedfx.entity:AddFollower()
        jammedfx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -25, 0)

        owner:PushEvent("attacked", { attacker = inst, damage = 0 })

        inst.SoundEmitter:PlaySound("gale_sfx/battle/silencer_pistol/jammed")

        inst.components.finiteuses:Use(10)
        return
    end

    local ammo = GetAmmo(inst)
    if ammo == nil then
        -- Not ammo,do nothing
        return
    end


    local face_vec = GaleCommon.GetFaceVector(attacker)

    local proj = SpawnAt(ammo.prefab .. "_projectile", attacker)
    proj.components.complexprojectile:Launch(attacker:GetPosition() + face_vec, attacker, inst)
    proj:Hide()

    ammo:Remove()

    SpawnAt("gale_hand_shoot_fx", attacker).Transform:SetRotation(attacker.Transform:GetRotation())

    inst.components.temperature:SetTemperature(inst.components.temperature:GetCurrent() + 1)

    inst:CheckCanRangeAttack()

    inst._num_ammo:set(GetNumAmmo(inst))

    inst.components.finiteuses:Use(1)
end

local function CheckCanRangeAttack(inst)
    local has_ammo = HasAmmo(inst)
    if has_ammo and not (inst.components.gale_blaster_jammed and inst.components.gale_blaster_jammed.jammed) then
        inst.components.weapon.attackwear = 0
        inst.components.weapon:SetDamage(0)
        inst.components.weapon:SetRange(18)
        inst.components.weapon:SetProjectile("gale_fake_projectile")
        inst.components.weapon:SetOnProjectileLaunched(WeaponOnLaunchedProjectile)
    else
        inst.components.weapon.attackwear = 5
        inst.components.weapon:SetDamage(10)
        inst.components.weapon:SetRange(0)
        inst.components.weapon:SetProjectile(nil)
        inst.components.weapon:SetOnProjectileLaunched(nil)
    end

    if not has_ammo then
        inst:AddTag("gale_blaster_out_of_ammo")
    else
        inst:RemoveTag("gale_blaster_out_of_ammo")
    end
end

local function WeaponOnJammed(inst, data)
    inst:CheckCanRangeAttack()
end

local function WeaponOnNotJammed(inst, data)
    inst:CheckCanRangeAttack()

    inst.SoundEmitter:PlaySound("gale_sfx/battle/silencer_pistol/reload")
end

local function OnEquipToModel(inst, owner)
    inst.components.container:Close()
end

local function OnInstallClip(inst)
    inst:CheckCanRangeAttack()
    inst._num_ammo:set(GetNumAmmo(inst))
end

local function OnUninstallClip(inst)
    inst:CheckCanRangeAttack()
    inst._num_ammo:set(GetNumAmmo(inst))
end

local function CreatePistol(suffix)
    return GaleEntity.CreateNormalWeapon({
        prefabname = suffix and ("msf_silencer_pistol_" .. suffix) or "msf_silencer_pistol",
        assets = {
            Asset("ANIM", "anim/deer_fire_charge.zip"),
            Asset("ANIM", "anim/fireball_2_fx.zip"),

            Asset("ANIM", "anim/msf_silencer_pistol.zip"),
            Asset("ANIM", "anim/swap_msf_silencer_pistol.zip"),
            Asset("IMAGE", "images/inventoryimages/msf_silencer_pistol.tex"),
            Asset("ATLAS", "images/inventoryimages/msf_silencer_pistol.xml"),
        },

        tags = { "gale_blaster", "icebox_valid" },


        bank = "msf_silencer_pistol",
        build = "msf_silencer_pistol",
        anim = "idle",


        inventoryitem_data = {
            use_gale_item_desc = true,
            imagename = "msf_silencer_pistol",
            atlasname = "msf_silencer_pistol",
        },

        finiteuses_data = {
            maxuse = 500,
            onfinished = function(inst)
                inst.components.container:DropEverything()
                inst:Remove()
            end,
        },

        equippable_data = {
            onequip_priority = {
                {
                    function(inst, owner)
                        if owner.components.combat then
                            owner.components.combat:SetAttackPeriod(FRAMES)
                        end


                        inst.components.container:Open(owner)
                    end,
                    1,
                }

            },

            onunequip_priority = {
                {
                    function(inst, owner)
                        if owner.components.combat then
                            owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
                        end


                        inst.components.container:Close()
                    end,
                    1
                },

            },
        },

        weapon_data = {
            damage = 0,
            ranges = 18,
            swapanims = { "swap_msf_silencer_pistol", "swap_msf_silencer_pistol" },
        },

        clientfn = function(inst)
            if suffix then
                inst:SetPrefabName("msf_silencer_pistol")
            end
            inst.shoot_sound = "gale_sfx/battle/silencer_pistol/shoot"

            inst._num_ammo = net_ushortint(inst.GUID, "inst._num_ammo", "inst._num_ammo")
            inst._num_ammo:set(0)
        end,

        serverfn = function(inst)
            inst.CheckCanRangeAttack = CheckCanRangeAttack

            inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

            inst.components.weapon.attackwear = 0
            inst.components.weapon:SetProjectile("gale_fake_projectile")
            inst.components.weapon:SetOnProjectileLaunched(WeaponOnLaunchedProjectile)

            inst:AddComponent("areaaware")

            inst:AddComponent("temperature")
            inst.components.temperature.current = TheWorld.state.temperature

            inst:AddComponent("gale_blaster_jammed")

            inst:AddComponent("container")
            inst.components.container:WidgetSetup("msf_silencer_pistol")
            inst.components.container.canbeopened = false


            inst:ListenForEvent("gale_blaster_jammed", WeaponOnJammed)
            inst:ListenForEvent("gale_blaster_not_jammed", WeaponOnNotJammed)

            inst:ListenForEvent("itemget", OnInstallClip)
            inst:ListenForEvent("itemlose", OnUninstallClip)

            inst:DoTaskInTime(0, inst.CheckCanRangeAttack)

            if suffix == "full" then
                inst.components.container:GiveItem(SpawnAt("msf_clip_pistol_full", inst))
            elseif suffix == "random" then
                inst.components.container:GiveItem(SpawnAt("msf_clip_pistol_random", inst))
            end
        end,
    })
end


return CreatePistol(), CreatePistol("full"), CreatePistol("random")
