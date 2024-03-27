local GaleEntity = require("util/gale_entity")

local function onnear(inst)
	inst.AnimState:PlayAnimation("down")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")

    inst.DynamicShadow:SetSize( 1.5, .75 )
end

local function onfar(inst)
    inst.AnimState:PlayAnimation("up")
    inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")

    inst.DynamicShadow:SetSize( 0,0 )
end

return GaleEntity.CreateNormalEntity({
    prefabname = "gale_forest_hanging_vine_dynamic",

    assets = {
        Asset("ANIM", "anim/cave_exit_rope.zip"),
        Asset("ANIM", "anim/vine01_build.zip"),
        Asset("ANIM", "anim/vine02_build.zip"),	
    },

    tags = {"hangingvine","NOCLICK"},
    
    bank = "exitrope",
    build = "vine01_build",
    -- anim = "idle_loop",

    -- loop_anim = true,

    clientfn = function(inst)
        inst.entity:AddDynamicShadow()

        inst.DynamicShadow:SetSize( 0, 0)
    end,


    serverfn = function(inst)
        if math.random() < 0.5 then
            inst.AnimState:SetBuild("vine01_build")
        else
            inst.AnimState:SetBuild("vine02_build")
        end

        inst:AddComponent("playerprox")
        inst.components.playerprox:SetOnPlayerNear(onnear)
        inst.components.playerprox:SetOnPlayerFar(onfar)
        inst.components.playerprox:SetDist(10,16)

        inst:DoTaskInTime(0,function()
            -- if not FindClosestEntity(inst,10,false,{"gale_forest_pillar_tree"},{"INLIMBO"}) then
            --     inst:Remove()
            -- else 
            --     inst.components.playerprox:ForceUpdate()
            -- end
            inst.components.playerprox:ForceUpdate()
        end)
    end,

}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_forest_hanging_vine_static",

    assets = {
        Asset("ANIM", "anim/vines_rainforest_border.zip"),
    },

    tags = {"hangingvine","NOCLICK"},
    
    bank = "vine_rainforest_border",
    build = "vines_rainforest_border",


    clientfn = function(inst)
        if not TheNet:IsDedicated() then
            inst:AddComponent("distancefade")
            inst.components.distancefade:Setup(15,25)
        end
    end,


    serverfn = function(inst)
        local color = 0.7 + math.random() * 0.3
        inst.AnimState:SetMultColour(color, color, color, 1)    

        inst.animchoice = math.random(1,6)
        inst.AnimState:PlayAnimation("idle_"..inst.animchoice)

        inst.OnSave = function(inst,data)
            data.animchoice = inst.animchoice
        end

        inst.OnLoad = function(inst,data)
            if data ~= nil then
                if data.animchoice ~= nil then
                    inst.animchoice = data.animchoice
                    inst.AnimState:PlayAnimation("idle_"..inst.animchoice)
                end
            end
        end

        -- inst:DoTaskInTime(0,function()
        --     if not FindClosestEntity(inst,10,false,{"gale_forest_pillar_tree"},{"INLIMBO"}) then
        --         inst:Remove()
        --     end
        -- end)
    end,

})