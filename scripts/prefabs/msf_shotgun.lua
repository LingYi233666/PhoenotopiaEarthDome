local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")



return GaleEntity.CreateNormalWeapon({
    prefabname = "msf_shotgun",
    assets = {
        Asset("ANIM", "anim/deer_fire_charge.zip"),
        Asset("ANIM", "anim/fireball_2_fx.zip"),
    
        -- Asset("ANIM", "anim/msf_silencer_pistol.zip"),
        -- Asset("ANIM", "anim/swap_msf_silencer_pistol.zip"),
    
        -- Asset("IMAGE","images/inventoryimages/msf_silencer_pistol.tex"),
        -- Asset("ATLAS","images/inventoryimages/msf_silencer_pistol.xml"),
    },

    tags = {"gale_blaster","icebox_valid"},


    bank = "msf_silencer_pistol",
    build = "msf_silencer_pistol",
    anim = "idle",


    inventoryitem_data = {
        use_gale_item_desc = true,
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
                function (inst,owner)
                    inst.components.container:Open(owner)
                end,
                1,
            }
            
        },

        onunequip_priority = {
            {
                function (inst,owner)
                    inst.components.container:Close()
                end,
                1
            },
            
        }, 
    },

    weapon_data = {
        damage = 0,
        ranges = 18,
        swapanims = {"swap_msf_silencer_pistol","swap_msf_silencer_pistol"},
    },

    clientfn = function(inst)
        inst.shoot_sound = "gale_sfx/battle/silencer_pistol/shoot"
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
        -- inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP
        -- inst.components.temperature.mintemp = TUNING.MIN_ENTITY_TEMP
        -- inst.components.temperature.overheattemp = TUNING.OVERHEAT_TEMP

        inst:AddComponent("gale_blaster_jammed")

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("msf_silencer_pistol")
        inst.components.container.canbeopened = false
        

        inst:ListenForEvent("gale_blaster_jammed",WeaponOnJammed)
        inst:ListenForEvent("gale_blaster_not_jammed",WeaponOnNotJammed)

        inst:ListenForEvent("itemget", OnInstallClip)
        inst:ListenForEvent("itemlose", OnUninstallClip)

        inst:DoTaskInTime(0,inst.CheckCanRangeAttack)
    end,
})