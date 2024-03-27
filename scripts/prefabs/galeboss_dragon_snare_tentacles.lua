local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local moving_tentacle_brain = require("brains/galeboss_dragon_snare_moving_tentacle_brain")
require("util/vector4")

local asset_fx_dynamic = {
    Asset("ANIM", "anim/gale_groundpound_fx_dynamic.zip"),
}

local function IsAlly(inst,other)
    local leader = inst.components.follower.leader
    return other == leader
         or other:HasTag("galeboss_dragon_snare")
         or other:HasTag("galeboss_dragon_snare_token")
end

local function MovingTentacleRetarget(inst)
    local leader = inst.components.follower.leader
    
    return FindEntity(
        leader or inst,
        33,
        function(guy)
            return guy ~= inst
                and not IsAlly(inst,guy)
                and not guy.components.health:IsDead()
        end,
        { "_combat", "_health","character" },
        { "INLIMBO",}
    )
    
end

local function MovingTentacleKeepTarget(inst, target)
    local leader = inst.components.follower.leader
    return target ~= nil
        and target:IsValid()
        and target.entity:IsVisible()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and (leader == nil or target:IsNear(leader, 33))
end

local function CheckSG(inst)
    local is_moving = inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("dash_prepare_moving") 
    
    if is_moving and not inst.SoundEmitter:PlayingSound("underground") then
        inst.SoundEmitter:PlaySound("gale_sfx/battle/tentacle/enm_beholder_tentacleloop","underground")
    elseif not is_moving and inst.SoundEmitter:PlayingSound("underground") then
        inst.SoundEmitter:KillSound("underground")
    end

    inst.Physics:SetActive(inst.sg:HasStateTag("should_physics") or inst.sg:HasStateTag("moving"))
end


local function CreateDirt(symbol)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetTwoFaced()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gale_groundpound_fx_dynamic")
    inst.AnimState:SetBuild("gale_groundpound_fx_dynamic")
    inst.AnimState:PlayAnimation("dynamic",true)
    inst.AnimState:SetDeltaTimeMultiplier(1.2)

    if symbol then
        inst.AnimState:OverrideSymbol("1","gale_groundpound_fx_dynamic",tostring(symbol))
    end


    local s = 1
    inst.Transform:SetScale(s,s,s)
    GaleCommon.FadeTo(inst,GetRandomMinMax(1.5,2),{
        Vector3(s,s,s),
        Vector3(0.6,0.6,0.6),
    },nil,nil,inst.Remove)

    inst.task = inst:DoPeriodicTask(0,function()
        local x,y,z = inst:GetPosition():Get()
        local gravity = 40
        local vx,vy,vz = inst.Physics:GetMotorVel()
        vy = vy - gravity * FRAMES
        inst.Physics:SetMotorVel(vx,vy,vz)

        if y <= 0.05 and vy <= 0 then
            inst.Transform:SetPosition(x,0,z)
            inst.Physics:Stop()
            inst.AnimState:Pause()
            inst.task:Cancel()
        end
    end)

    return inst
end


local function dynamic_fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    if not TheNet:IsDedicated() then
        inst:StartThread(function()
            while true do
                for i = 2,3 do
                    local spawn_sphere = CreateSphereEmitter(0.5)
                    local spawn_offset = Vector3(spawn_sphere())
                    local mypos = inst:GetPosition()
                    spawn_offset.y = GetRandomMinMax(0.5,0.8)

                    local symbols = {3,4,5}
                    local dirt = CreateDirt(GetRandomItem(symbols))
                    dirt.Transform:SetPosition((mypos+spawn_offset):Get())
                    -- dirt.AnimState:SetMultColour(74/255,69/255,57/255,1)
                    dirt:ForceFacePoint((mypos+spawn_offset*2):Get())

                    local vx_init = GetRandomMinMax(0,1)
                    local vy_init = GetRandomMinMax(15,23)
                    dirt.Physics:SetMotorVel(vx_init,vy_init,0)

                end
                Sleep(0)
            end
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst:DoTaskInTime(10,inst.Remove)

    return inst
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_dragon_snare_moving_tentacle",
    assets = {
        Asset("ANIM", "anim/tentacle.zip"),
        Asset("ANIM", "anim/galeboss_dragon_snare_moving_tentacle.zip"),
        Asset("SOUND", "sound/tentacle.fsb"),
    },

    tags = {"monster","galeboss_dragon_snare_token","tentacle"},

    bank = "tentacle",
    build = "tentacle",
    anim = "idle",

    clientfn = function(inst)
        -- inst.entity:AddPhysics()

        -- inst.Physics:SetCylinder(0.25, 2)
        MakeCharacterPhysics(inst,1000,0.33)

        inst.Transform:SetTwoFaced()

        inst.AnimState:OverrideSymbol("tentacle_pieces","galeboss_dragon_snare_moving_tentacle","tentacle_pieces")
    end,

    serverfn = function(inst)
        inst.CheckSG = CheckSG
        inst.CanDash = false

        inst:AddComponent("inspectable")
        
        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = 4
        inst.components.locomotor.runspeed = 7

        inst:AddComponent("follower")

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(250)
    
        inst:AddComponent("combat")
        inst.components.combat.playerdamagepercent = 0.5
        inst.components.combat:SetAttackPeriod(6)
        inst.components.combat:SetDefaultDamage(64)
        inst.components.combat:SetAreaDamage(1.5, 0.5)
        inst.components.combat:SetRange(1,1.5)
        inst.components.combat:SetRetargetFunction(1, MovingTentacleRetarget)
        inst.components.combat:SetKeepTargetFunction(MovingTentacleKeepTarget)

        inst:AddComponent("lootdropper")

        inst:SetStateGraph("SGgaleboss_dragon_snare_moving_tentacle")
        inst:SetBrain(moving_tentacle_brain)

        inst.dirt_fx = SpawnPrefab("gale_underground_dirt")
        inst.dirt_fx:SetOwner(inst)
        -- inst.dirt_fx.Transform:SetScale(1.33,1.33,1.33)

        inst.OnSave = function(inst,data)
            data.CanDash = inst.CanDash
            data.runspeed = inst.components.locomotor.runspeed
        end

        inst.OnLoad = function(inst,data)
            if data ~= nil then
                if data.CanDash ~= nil then
                    inst.CanDash = data.CanDash
                end
                if data.runspeed ~= nil then
                    inst.components.locomotor.runspeed = data.runspeed
                end
            end
        end

        inst:ListenForEvent("newstate",CheckSG)
    end,
}),
GaleEntity.CreateNormalEntity({
    prefabname = "gale_underground_dirt",
    assets = {
        Asset("ANIM", "anim/mole_build.zip"),
    },

    tags = {"NOCLICK"},

    bank = "mole",
    build = "mole_build",
    anim = "idle_under",

    persists = false,

    clientfn = function(inst)
        inst.Transform:SetFourFaced()
    end,

    serverfn = function(inst)
        inst.SetOwner = function(inst,owner)
            inst.owner = owner
            inst.owner_last_pos = owner:GetPosition()
            inst.entity:SetParent(owner.entity)
            inst.Transform:SetPosition(0,0,0)

            inst:DoPeriodicTask(0,function()
                local pos = inst.owner:GetPosition()
                local is_moving = (inst.owner_last_pos - pos):Length() >= 0.033

                if is_moving and not inst.DirtFxSpawnTask then
                    inst:OnOwnerStartMove()
                elseif not is_moving and inst.DirtFxSpawnTask then
                    inst:OnOwnerStopMove()
                end

                -- inst:ForceFacePoint(GaleCommon.)

                inst.owner_last_pos = pos
            end)
        end 

        inst.OnOwnerStartMove = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
            inst.AnimState:PushAnimation("walk_loop",true)
            if not inst.SoundEmitter:PlayingSound("move") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/move", "move")
            end
            if inst.DirtFxSpawnTask then 
                inst.DirtFxSpawnTask:Cancel()
            end
            -- SpawnAt("gale_underground_dirt_fx",inst).AnimState:SetTime(10 * FRAMES)
            inst.DirtFxSpawnTask = inst:DoPeriodicTask(2*FRAMES,function()
                -- SpawnAt("gale_underground_dirt_fx",inst).AnimState:SetTime(10 * FRAMES)
            end)
        end 
        
        inst.OnOwnerStopMove = function(inst)
            inst.AnimState:PlayAnimation("walk_pst")
            inst.AnimState:PushAnimation("idle_under",false)
            inst.SoundEmitter:KillSound("move")
            if inst.DirtFxSpawnTask then 
                inst.DirtFxSpawnTask:Cancel()
            end
            inst.DirtFxSpawnTask = nil 
        end 

        inst:DoTaskInTime(1,function ()
            if inst.owner == nil then
                inst:Remove()
            end
        end)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_underground_dirt_fx",
    assets = {
        Asset("ANIM", "anim/mole_move_fx.zip"),
    },
    bank = "mole_fx",
    build = "mole_move_fx",
    anim = "move",
}),
Prefab("gale_groundpound_fx_dynamic",dynamic_fxfn,asset_fx_dynamic)