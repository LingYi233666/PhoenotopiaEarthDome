local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleWeaponSkill = require("util/gale_weaponskill")
local GaleCondition = require("util/gale_conditions")

local function PhysicsFn()
    
end


local TAILS_ANIM =
{
    ["tail_5_2"] = .15,
    ["tail_5_3"] = .15,
    ["tail_5_4"] = .2,
    ["tail_5_5"] = .8,
    ["tail_5_6"] = 1,
    ["tail_5_7"] = 1,
}

local THINTAILS_ANIM =
{
    ["tail_5_8"] = 1,
    ["tail_5_9"] = .5,
}

return GaleEntity.CreateNormalWeapon({
    prefabname = "gale_sky_striker_blade_fire",
    assets = {
        Asset("ANIM", "anim/gale_sky_striker_blade_fire.zip"),
        Asset("ANIM", "anim/swap_gale_sky_striker_blade_fire.zip"),

        Asset("IMAGE","images/inventoryimages/gale_sky_striker_blade_fire.tex"),
        Asset("ATLAS","images/inventoryimages/gale_sky_striker_blade_fire.xml"),
    },

    bank = "gale_sky_striker_blade_fire",
    build = "gale_sky_striker_blade_fire",
    anim = "idle",

    inventoryitem_data = {
        use_gale_item_desc = true,
    },

    weapon_data = {
        damage = 45,
        ranges = 0.2,
    },

    finiteuses_data = {
        maxuse = 175,
    },

    clientfn = function(inst)
        GaleWeaponSkill.AddAoetargetingClient(inst,"line",nil,12)
    end,

    serverfn = function(inst)
        GaleWeaponSkill.AddAoetargetingServer(inst,function(inst,doer,pos)
            inst.components.rechargeable:Discharge(8)

            local power = GaleCondition.GetCondition(doer,"condition_power")

            
            doer.sg.statemem.addition_attack = power ~= nil and power.condition_data.stacks and power.condition_data.stacks >= 3
        end)

        inst.components.finiteuses:SetOnFinished(function()
            SpawnAt("galeboss_ruinforce_core",inst).components.inventoryitem:OnDropped(false)
            inst:Remove()
        end)
    end,
}),GaleEntity.CreateNormalFx({
    prefabname = "gale_sky_striker_blade_fire_tail",
    assets = {
        Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
    },

    bank = "lavaarena_blowdart_attacks",
    build = "lavaarena_blowdart_attacks",
    anim = "attack_4",

    animover_remove = false,
    loop_anim = true,

    clientfn = function(inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetAddColour(1, 1, 0, 0)
        inst.AnimState:SetLayer( LAYER_GROUND )
        -- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetScale(1,1,1)

        if not TheNet:IsDedicated() then
            
            inst:DoPeriodicTask(0,function()
                local parent = inst.entity:GetParent()

                if parent then
                    local emitter = CreateRingEmitter(0.2)
                    for i = 1,3 do
                        local tail = GaleEntity.CreateClientAnim({
                            bank = "lavaarena_blowdart_attacks",
                            build = "lavaarena_blowdart_attacks",
                            anim = weighted_random_choice(TAILS_ANIM),
                            lightoverride = 1
                        })
                        
                        local x,z = emitter()
                        
                        tail.Transform:SetPosition(parent.entity:LocalToWorldSpace(x,GetRandomMinMax(0.33,1.5),z))
                        tail.Transform:SetRotation(parent.Transform:GetRotation())

                        tail.AnimState:SetAddColour(1,1,0,1)
                        tail.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                    end
                    
                end
                
            end)
            
        end
    end,
}),GaleEntity.CreateNormalFx({
    prefabname = "gale_sky_striker_blade_fire_hitground_fx",
    assets = {
        -- Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
    },

    -- bank = "lavaarena_blowdart_attacks",
    -- build = "lavaarena_blowdart_attacks",
    -- anim = "attack_4",

    -- animover_remove = false,
    -- loop_anim = true,

    clientfn = function(inst)
        -- inst._emit_event = net_event(inst.GUID,"inst._emit_event")
        -- inst.face_pos = {
        --     [FACING_RIGHT] = Vector3(0,0,0),
        --     [FACING_UPRIGHT] = Vector3(0,0,0),
        --     [FACING_UP] = Vector3(0,0,0),
        --     [FACING_UPLEFT] = Vector3(0,0,0),
        --     [FACING_LEFT] = -inst.face_pos[FACING_RIGHT],
        --     [FACING_DOWNLEFT] = Vector3(0,0,0),
        --     [FACING_DOWN] = Vector3(0,0,0),
        --     [FACING_DOWNRIGHT] = Vector3(0,0,0),
        -- }

        -- if not TheNet:IsDedicated() then
        --     inst:ListenForEvent("inst._emit_event",function()
        --         local player = inst.entity:GetParent()
        --         if player then
        --             -- local face = player.AnimState:GetCurr
        --             player:SpawnChild("gale_explode_ray_yellow_vfx")
        --         end
        --     end)
        -- end
    end,

    serverfn = function(inst)
        -- inst:StartThread(function()
        --     local radius = 0.1
        --     local dist = 0.5
            

        --     while radius < 5 do
        --         local theta = math.acos((2 * radius * radius - dist*dist) / (2 * radius * radius))
        --         local start_angle = math.random() * PI
        --         for angle = start_angle,start_angle + 2 * PI,theta do
        --             local fx = inst:SpawnChild("gale_flame_vfx")
        --             fx.Transform:SetPosition((Vector3(math.cos(angle),0,math.sin(angle)) * radius):Get())
        --             fx:DoTaskInTime(GetRandomMinMax(0.1,0.11),fx.Remove)
        --         end
        --         radius = radius + 0.5
        --         Sleep(0)
        --     end
        -- end)

        inst:SpawnChild("gale_flame_circle_vfx")

        inst:DoTaskInTime(5,inst.Remove)
    end,
})
