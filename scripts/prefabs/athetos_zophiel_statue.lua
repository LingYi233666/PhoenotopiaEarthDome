local GaleEntity = require("util/gale_entity")

local function AlwaysRecoil(inst, worker, tool, numworks)
	return true, numworks
end

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        inst.components.workable:SetWorkLeft(1)
        -- worker:PushEvent("tooltooweak", { workaction = ACTIONS.MINE })
    end
end

local function IsResting(player)
    return player.sg 
            -- and player.sg.currentstate.name == "emote" 
            and (
                player.AnimState:IsCurrentAnimation("emote_loop_sit1")
                or player.AnimState:IsCurrentAnimation("emote_loop_sit2")
                or player.AnimState:IsCurrentAnimation("emote_loop_sit3")
                or player.AnimState:IsCurrentAnimation("emote_loop_sit4")
                or player.AnimState:IsCurrentAnimation("sit1_loop")
                or player.AnimState:IsCurrentAnimation("sit2_loop")
                or player.AnimState:IsCurrentAnimation("emote_pre_sit1")
                or player.AnimState:IsCurrentAnimation("emote_pre_sit2")
                or player.AnimState:IsCurrentAnimation("emote_pre_sit3")
                or player.AnimState:IsCurrentAnimation("emote_pre_sit4")
                or player.AnimState:IsCurrentAnimation("sit_pre")
                or player.AnimState:IsCurrentAnimation("sit_loop_pre")
            )
end

local function CreateRegenerateTask(inst,player)
    if inst.regenerate_tasks[player] then
        inst.regenerate_tasks[player]:Cancel()
    end
    inst.regenerate_tasks[player] = inst:DoPeriodicTask(1,function()
        if player:IsValid() 
            and not player.sg:HasStateTag("busy")
            and not IsEntityDeadOrGhost(player,true) 
            and not player.sg:HasStateTag("dead") then
            
            if player.components.health and player.components.health:GetPercent() < 0.5 then
                local delta = player.components.health.maxhealth * 0.5 - player.components.health.currenthealth
                delta = math.min(delta,1)
                player.components.health:DoDelta(delta,true)
            end

            if player.components.sanity and player.components.sanity:GetPercent() < 0.5 then
                local delta = player.components.sanity.max * 0.5 - player.components.sanity.current
                delta = math.min(delta,1)
                player.components.sanity:DoDelta(delta,true)
            end

            if player.components.gale_stamina and player.components.gale_stamina:GetPercent() < 1.0 then
                -- local delta = player.components.gale_stamina.max - player.components.gale_stamina.current
                -- delta = math.min(delta,1)
                player.components.gale_stamina:DoDelta(10)
            end
            
        else 
            -- print("Exit Resting",player)
            -- inst.regenerate_tasks[player]:Cancel()
            -- inst.regenerate_tasks[player] = nil 
        end
    end)
end

local function OnNear(inst,player)
    -- print("OnNear",player)
    -- inst:ListenForEvent("newstate",inst._player_emotion_sit,player)
    -- if player.components.grue then
    --     player.components.grue:AddImmunity(inst)
    -- end
    CreateRegenerateTask(inst,player)
end

local function OnFar(inst,player)
    -- print("OnFar",player)
    -- inst:RemoveEventCallback("newstate",inst._player_emotion_sit,player)
    -- if player.components.grue then
    --     player.components.grue:RemoveImmunity(inst)
    -- end
    if inst.regenerate_tasks[player] then
        inst.regenerate_tasks[player]:Cancel()
    end
    inst.regenerate_tasks[player] = nil 
end

local function AnimoverRemove(fx)
    if fx.AnimState:AnimDone() then
        fx:Remove()
    end
end

local function OnPhaseChangeClient(inst)
    local phase = TheWorld.state.phase
    if inst._fireflies == nil and phase == "night" then
        inst._fireflies = GaleEntity.CreateClientAnim({
            bank = "fireflies",
            build = "fireflies",

            lightoverride = 1,
            final_offset = 3,
        })

        inst:AddChild(inst._fireflies)

        inst._fireflies.entity:AddFollower()
        inst._fireflies.Follower:FollowSymbol(inst.GUID,"statue",0,-200,0)

        inst._fireflies.AnimState:PlayAnimation("swarm_pre")
        inst._fireflies.AnimState:PushAnimation("swarm_loop",true)
    elseif inst._fireflies ~= nil and phase ~= "night" then
        inst._fireflies.AnimState:PlayAnimation("swarm_pst")
        inst._fireflies:ListenForEvent("animover",AnimoverRemove)
        inst._fireflies = nil 
    end
end

local function LightUpdateTask(inst)
    local delta = inst.light_intensity_target - inst.light_intensity
    local flag = delta > 0 and 1 or -1 
    delta = math.clamp(math.abs(delta),0,FRAMES)
    delta = delta * flag 

    inst.light_intensity = inst.light_intensity + delta

    -- inst.Light:SetIntensity(inst.light_intensity)
    -- inst.Light:Enable(inst.light_intensity > 0)

    if inst.light_intensity > 0 then
        if inst.light_fx == nil then
            inst.light_fx = inst:SpawnChild("athetos_zophiel_statue_light")
            inst.light_fx.entity:AddFollower()
            inst.light_fx.Follower:FollowSymbol(inst.GUID,"statue",0,-200,0)
        end
        inst.light_fx.Light:SetIntensity(inst.light_intensity)
        
    elseif inst.light_fx and inst.light_intensity <= 0 then 
        inst.light_fx:Remove()
        inst.light_fx = nil 
    end

    if inst.light_intensity == inst.light_intensity_target then
        inst.light_intensity_task:Cancel()
        inst.light_intensity_task = nil 
    end
end

local function OnPhaseChangeServer(inst)
    local phase = TheWorld.state.phase
    if phase == "night" then
        inst.light_intensity_target = 0.66
    elseif phase ~= "night" then
        inst.light_intensity_target = 0
    end

    if inst.light_intensity_task == nil then
        inst.light_intensity_task = inst:DoPeriodicTask(0,LightUpdateTask)
    end
end

return GaleEntity.CreateNormalEntity({
    prefabname = "athetos_zophiel_statue",

    bank = "athetos_zophiel_statue",
    build = "athetos_zophiel_statue",
    anim = "idle",

    tags = {"statue"},

    clientfn = function(inst)
        inst.entity:AddLight()
    
        -- inst.Light:SetFalloff(1)
        -- inst.Light:SetIntensity(0)
        -- inst.Light:SetRadius(1)
        -- inst.Light:SetColour(180/255, 195/255, 150/255)
        -- inst.Light:Enable(false)

        MakeObstaclePhysics(inst, .66)

    
        if not TheNet:IsDedicated() then
            inst:WatchWorldState("phase",OnPhaseChangeClient)
            OnPhaseChangeClient(inst)
        end
    end,

    serverfn = function(inst)
        inst.light_intensity = 0 
        inst.light_intensity_target = nil 
        inst.light_intensity_task = nil 
        inst.regenerate_tasks = {

        }

        -- inst._player_emotion_sit = function(player)
        --     local is_resting = IsResting(player)
        --     -- print(player,"new state,is resting:",is_resting)
        --     if is_resting then
        --         if inst.regenerate_tasks[player] == nil then
        --             print("Start Resting",player)
        --             CreateRegenerateTask(inst,player)
        --         end

        --     else 
        --         if inst.regenerate_tasks[player] ~= nil then
        --             print("Exit Resting",player)
        --             inst.regenerate_tasks[player]:Cancel()
        --             inst.regenerate_tasks[player] = nil 
        --         end
                
        --     end
        -- end


        inst:AddComponent("inspectable")

        inst:AddComponent("workable")
        --TODO: Custom variables for mining speed/cost
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(OnWork)
        inst.components.workable:SetShouldRecoilFn(AlwaysRecoil)

        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(6,6)
        inst.components.playerprox:SetPlayerAliveMode(
            inst.components.playerprox.AliveModes.AliveOnly)
        inst.components.playerprox:SetTargetMode(
            inst.components.playerprox.TargetModes.AllPlayers)
        inst.components.playerprox.onnear = OnNear
        inst.components.playerprox.onfar = OnFar


        inst:WatchWorldState("phase",OnPhaseChangeServer)
        OnPhaseChangeServer(inst)
    end,
}),
GaleEntity.CreateNormalFx({
    prefabname = "athetos_zophiel_statue_light",

    assets = {

    },

    clientfn = function(inst)
        inst.entity:AddLight()
    
        inst.Light:SetFalloff(1)
        inst.Light:SetIntensity(0)
        inst.Light:SetRadius(1.33)
        inst.Light:SetColour(180/255, 195/255, 150/255)
        inst.Light:Enable(true)
    end,

    serverfn = function(inst)

    end,
})