local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
local GaleWeaponSkill = require("util/gale_weaponskill")

local assets = {
    Asset("ANIM", "anim/galeboss_katash_blade.zip"),
    Asset("ANIM", "anim/swap_galeboss_katash_blade.zip"),

    Asset("IMAGE", "images/inventoryimages/galeboss_katash_blade.tex"),
    Asset("ATLAS", "images/inventoryimages/galeboss_katash_blade.xml"),

    Asset("IMAGE", "images/inventoryimages/galeboss_katash_blade_normal.tex"),
    Asset("ATLAS", "images/inventoryimages/galeboss_katash_blade_normal.xml"),
}

local function WeaponOnAttack(inst, attacker, target)
    local in_weapon_skill = attacker.sg and attacker.sg.currentstate.name == "gale_lightning_roll"

    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)

        local time = 3
        local sleep_addition = in_weapon_skill and 0.1 or 0.9
        if target:HasTag("largecreature") or target:HasTag("epic") then
            sleep_addition = sleep_addition * 0.25
            time = time * 0.25
        end

        if not (target.components.freezable ~= nil and target.components.freezable:IsFrozen()) and
            not (target.components.pinnable ~= nil and target.components.pinnable:IsStuck()) and
            not (target.components.fossilizable ~= nil and target.components.fossilizable:IsFossilized()) then
            local mount = target.components.rider ~= nil and target.components.rider:GetMount() or nil
            if mount ~= nil then
                mount:PushEvent("ridersleep", { sleepiness = sleep_addition, sleeptime = time + math.random() })
            end
            if target.components.sleeper ~= nil then
                target.components.sleeper:AddSleepiness(sleep_addition, time + math.random())
            elseif target.components.grogginess ~= nil then
                target.components.grogginess:AddGrogginess(sleep_addition, time + math.random())
            end
        end
    end
    if not in_weapon_skill then
        inst.components.finiteuses:Use(1)
    end
end

local function SetFxOwner(inst, fx, owner)
    local old_owner = fx.entity:GetParent()
    if old_owner ~= nil and old_owner.components.colouradder ~= nil and old_owner ~= fx then
        old_owner.components.colouradder:DetachChild(fx)
    end

    if owner ~= nil then
        fx:Show()
        fx.entity:SetParent(owner.entity)
        fx.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, 0, 8)
        fx.components.highlightchild:SetOwner(owner)
        if owner.components.colouradder ~= nil then
            owner.components.colouradder:AttachChild(fx)
        end
    else
        fx.entity:SetParent(inst.entity)
        fx.components.highlightchild:SetOwner(inst)
        fx:Hide()
    end
end

local function BladeClientFn(inst)
    GaleWeaponSkill.AddAoetargetingClient(inst, "line", nil, 12)

    -- inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    -- inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting.reticule.validcolour = { 253 / 255, 168 / 255, 255 / 255, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
end

local function BladeServerFn(inst)
    inst.AnimState:HideSymbol("light")
    -- inst.AnimState:SetSymbolBrightness("light", 1.5)
    -- inst.AnimState:SetSymbolAddColour("light", 1, 1, 1, 1)
    inst.components.weapon:SetElectric(1.0)
    inst.components.weapon:SetOnAttack(WeaponOnAttack)
    inst.components.weapon.attackwear = 0

    inst.swapanim_ent = SpawnPrefab("galeboss_katash_blade_swapanims")
    inst.swapanim_ent.entity:AddFollower()
    SetFxOwner(inst, inst.swapanim_ent, nil)


    GaleWeaponSkill.AddAoetargetingServer(inst, function()
        inst.components.rechargeable:Discharge(3)
    end)
end


return GaleEntity.CreateNormalWeapon({
        prefabname = "galeboss_katash_blade",
        assets = assets,

        bank = "galeboss_katash_blade",
        build = "galeboss_katash_blade",
        anim = "idle",

        tags = {},

        inventoryitem_data = {
            imagename = "galeboss_katash_blade_normal",
            atlasname = "galeboss_katash_blade_normal",
            use_gale_item_desc = true,
        },

        finiteuses_data = {
            maxuse = 500,
        },

        equippable_data = {
            onequip_priority = {
                {
                    function(inst, owner)
                        inst.components.inventoryitem.atlasname = "images/inventoryimages/galeboss_katash_blade.xml"
                        inst.components.inventoryitem:ChangeImageName("galeboss_katash_blade")
                        SetFxOwner(inst, inst.swapanim_ent, owner)
                    end,
                    1,
                }

            },

            onunequip_priority = {
                {
                    function(inst, owner)
                        inst.components.inventoryitem.atlasname =
                        "images/inventoryimages/galeboss_katash_blade_normal.xml"
                        inst.components.inventoryitem:ChangeImageName("galeboss_katash_blade_normal")
                        SetFxOwner(inst, inst.swapanim_ent, nil)
                    end,
                    1
                },

            },
        },

        weapon_data = {
            damage = 43,
            ranges = 0,
        },

        clientfn = BladeClientFn,
        serverfn = BladeServerFn,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "galeboss_katash_blade_swapanims",
        assets = assets,
        bank = "swap_galeboss_katash_blade",
        build = "swap_galeboss_katash_blade",
        anim = "anim",
        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:SetSymbolLightOverride("swap_upper", 1)
            inst:AddComponent("highlightchild")
        end,

        serverfn = function(inst)
            inst:AddComponent("colouradder")
        end
    })
