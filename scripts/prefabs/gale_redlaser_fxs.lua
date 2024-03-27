local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")
require("util/vector4")

local assets = {
    Asset("ANIM", "anim/laser_explosion.zip"),
    Asset("ANIM", "anim/laser_ring_fx.zip"),
    Asset("ANIM", "anim/laser_explode_sm.zip"),
    Asset("ANIM", "anim/metal_hulk_projectile.zip"),

 --    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
	-- Asset("SOUND", "sound/DLC003_sfx.fsb"),
}

-- local function ProjectileClientFn(inst)
--     MakeInventoryPhysics(inst)
--     RemovePhysicsColliders(inst)
-- end

-- local function OnProjectileLaunch(inst)
--     inst.AnimState:PlayAnimation("spin_loop",true)
--     inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed,0,0)

--     inst:DoTaskInTime(5,function()
--         inst.components.complexprojectile:Hit()
--     end)

--     inst:ListenForEvent("death",function()
--         inst:Remove()
--     end,inst.components.complexprojectile.attacker)

--     inst:ListenForEvent("onremove",function()
--         inst:Remove()
--     end,inst.components.complexprojectile.attacker)
-- end

-- local function OnProjectileUpdate(inst)
--     inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed,0,0)
    
--     local x,y,z = inst.Transform:GetWorldPosition()
--     local ents = TheSim:FindEntities(x,y,z,1.25,{"_combat","_health"},{"INLIMBO"})
--     for k,v in pairs(ents) do 
--         if inst:CanProjectileHit(v) then 
--             inst.components.complexprojectile:Hit(v)
--             break
--         end 
--     end
--     return true
-- end

-- local function OnProjectileHit(inst,other)
--     SpawnAt("gale_laser_explosion",inst)

--     inst:OnProjectileHitFn(other)

--     inst.Physics:Stop()
--     inst.AnimState:PlayAnimation("impact")
--     inst:ListenForEvent("animover",inst.Remove)
-- end
-- -- SpawnAt("gale_red_ball_projectile",ThePlayer).components.complexprojectile:Launch(TheInput:GetWorldPosition(),ThePlayer)
-- local function ProjectileServerFn(inst)
--     inst.CanProjectileHit = function(inst,other)
--         local attacker = inst.components.complexprojectile.attacker
--         return attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other)
--     end
--     inst.ValidFn = function(attacker,other)
--         return (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other))
--         or other.components.inventoryitem
--     end
--     inst.OnProjectileHitFn = function(inst,other)
--         local attacker = inst.components.complexprojectile.attacker
--         GaleCommon.AoeForEach(attacker,inst:GetPosition(),3,nil,{"INLIMBO"},{"_combat","_inventoryitem"},function(attacker,other)
--             if (attacker.components.combat and attacker.components.combat:CanTarget(other) and not attacker.components.combat:IsAlly(other)) then 
--                 other.components.combat:GetAttacked(attacker,40)
--             elseif other.components.inventoryitem then 
--                 GaleCommon.LaunchItem(other,inst,5)
--             end 

--             local adder = SpawnPrefab("gale_hit_color_adder")
--             adder.add_colour = Vector3(1,0,0)
--             adder:SetTarget(other)
--         end,inst.ValidFn)
--     end


--     inst:AddComponent("complexprojectile")
--     inst.components.complexprojectile.horizontalSpeed = 12
--     inst.components.complexprojectile.onupdatefn = OnProjectileUpdate
--     inst.components.complexprojectile:SetOnHit(OnProjectileHit)
--     inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
-- end

return GaleEntity.CreateNormalFx({
    prefabname = "gale_laser_explosion",

    assets = assets,
    bank = "laser_explosion",
    build = "laser_explosion",
    anim = "idle",
    lightoverride = 1,
}),GaleEntity.CreateNormalFx({
    prefabname = "gale_laser_ring_fx",

    assets = assets,
    bank = "laser_ring_fx",
    build = "laser_ring_fx",
    anim = "idle",
    lightoverride = 1,
    animover_remove = false,
    clientfn = function(inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
    end,
    serverfn = function(inst)
        inst:ListenForEvent("animover",function()
            local r,g,b,a = inst.AnimState:GetMultColour()
            GaleCommon.FadeTo(inst,3,nil,{Vector4(r,g,b,a),Vector4(0,0,0,0)},nil,inst.Remove)
        end)
    end,
}),GaleEntity.CreateNormalFx({
    prefabname = "gale_laser_explode_sm",

    assets = assets,
    bank = "laser_explode_sm",
    build = "laser_explode_sm",
    anim = "anim",
    lightoverride = 1,
})
-- ,GaleEntity.CreateNormalEntity({
--     -- 
--     prefabname = "gale_red_ball_projectile",

--     assets = assets,
--     persists = false,
--     tags = {"NOCLICK","NOBLOCK"},
--     bank = "metal_hulk_projectile",
--     build = "metal_hulk_projectile",
--     lightoverride = 1,

--     clientfn = ProjectileClientFn,
--     serverfn = ProjectileServerFn,
-- })
