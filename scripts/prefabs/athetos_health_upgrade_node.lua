local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/athetos_health_upgrade_node.zip"), 

    Asset("IMAGE","images/inventoryimages/athetos_health_upgrade_node.tex"),
    Asset("ATLAS","images/inventoryimages/athetos_health_upgrade_node.xml"),
}

local function OnHealFn(inst,target)
    local bonus = math.clamp(250 - target.components.health.maxhealth ,0,5)
    if bonus > 0 and target.components.gale_status_bonus then
        target.components.gale_status_bonus:AddBonus("health",bonus)
    end
end

return GaleEntity.CreateNormalInventoryItem({
    prefabname = "athetos_health_upgrade_node",
    assets = assets,

    bank = "athetos_health_upgrade_node",
    build = "athetos_health_upgrade_node",
    anim = "idle",
    loop_anim = true,

    lightoverride = 1,

    tags = {},

    

    inventoryitem_data = {
        floatable_param = {"small", 0.1, 0.88},
        use_gale_item_desc = true,
    },

    clientfn = function(inst)
        
    end,

    serverfn = function(inst)
        inst.AnimState:SetDeltaTimeMultiplier(0.55)

        inst:AddComponent("healer")
        inst.components.healer:SetHealthAmount(250)
        inst.components.healer.onhealfn = OnHealFn
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "athetos_health_upgrade_node_absorb_fx",
    assets = {},

    bank = "bearger_ring_fx",
    build = "bearger_ring_fx",
    -- anim = "idle",

    lightoverride = 1,
    final_offset = 1,

    

    clientfn = function(inst)
        local s = 0.22
        inst.AnimState:SetScale(s,s,s)

        inst.AnimState:SetAddColour(255/255, 0/255, 0/255,1)
    end,

    serverfn = function(inst)
       local fx = inst:SpawnChild("athetos_health_upgrade_node_absorb_vfx") 

    --    fx:DoTaskInTime(0,fx.Remove)

       inst:StartThread(function()
            local percent = 1

            while percent >= 0 do
                inst.AnimState:SetPercent("idle",percent) 
                local length = inst.AnimState:GetCurrentAnimationLength()

                percent = math.max(0,percent - 1 * FRAMES / length)
                
                Sleep(0)

                if percent <= 0 then
                    break
                end
            end
            
            inst:Remove()
       end)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "athetos_health_upgrade_node_absorb_fx2",
    assets = {},

    bank = "laser_ring_fx",
    build = "laser_ring_fx",
    -- anim = "idle",

    lightoverride = 1,
    final_offset = 1,

    clientfn = function(inst)
        local s = 0.5
        inst.AnimState:SetScale(s,s,s)

        -- inst.AnimState:SetAddColour(255/255, 0/255, 0/255,1)

        inst.AnimState:HideSymbol("scorched_ground1")
    end,

    serverfn = function(inst)

       inst:StartThread(function()
            local percent = 1

            while percent >= 0 do
                inst.AnimState:SetPercent("idle",percent) 
                local length = inst.AnimState:GetCurrentAnimationLength()

                percent = math.max(0,percent - 1 * FRAMES / length)
                
                Sleep(0)

                if percent <= 0 then
                    break
                end
            end
            
            inst:Remove()
       end)
    end,
})