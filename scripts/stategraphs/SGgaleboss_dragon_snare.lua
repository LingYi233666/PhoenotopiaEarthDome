require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")

local events=
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local actionhandlers = {

}


local function NoOtherSpikeTest(pt)
    local ents = TheSim:FindEntities(pt.x,0,pt.z,4,{"groundspike"},{"INLIMBO"})
    for k,v in pairs(ents) do
        if not v.AnimState:IsCurrentAnimation(tostring(v.size).."_break") then
            return false
        end
    end

    return true 
end


local function GetItemToConsume(inst)
    local food = inst.components.inventory:FindItem(function (v)
        return inst.components.eater:CanEat(v)
    end)

    if food then
        return food,"FOOD"
    end

    local normal_item = inst.components.inventory:FindItem(function (v)
        return true
    end)

    if normal_item then
        return normal_item,"NORMAL"
    end
end

local STYLES = {
    TENTACLE = "TENTACLE",
    SPIKE = "SPIKE",
    BABYPLANT = "BABYPLANT",
}

local function PickStyle(inst)
    if not GaleCommon.IsTruelyDead(inst) then
        local target = inst.components.combat.target 
        local is_visible = not inst.sg:HasStateTag("invisible")

        if target then
            -- When relaxing,get a target
            if inst.style == nil then
                -- Start with spikes
                inst.style = STYLES.SPIKE
                if not is_visible then
                    -- attack directly underground
                    return "attack_underground_spikes"
                else 
                    -- Go underground and do spike attack 
                    return "into_underground",{next_sg="attack_underground_spikes"}
                end 
            elseif inst.style == STYLES.SPIKE then
                inst.style = STYLES.TENTACLE
                if not is_visible then
                    return "out_of_underground",{next_sg="summon_tentacles"}
                else 
                    return "summon_tentacles"
                end 
            elseif inst.style == STYLES.TENTACLE then
                inst.style = STYLES.BABYPLANT
                if not is_visible then
                    -- return "out_of_underground",{next_sg="summon_babyplants"}
                    return "summon_babyplants"
                else 
                    return "into_underground",{next_sg="summon_babyplants"}
                end 
            elseif inst.style == STYLES.BABYPLANT then
                inst.style = STYLES.SPIKE
                if not is_visible then
                    return "attack_underground_spikes"
                else 
                    return "into_underground",{next_sg="attack_underground_spikes"}
                end 
            end
        else 
            inst.style = nil 
            if is_visible then
                return "into_underground"
            end
        end    
    
    end
end

local function MakeMinionsDisappear(inst,time_range)
    time_range = time_range or {0,1}
    for ent,_ in pairs(inst.components.galeboss_skill_summon_minion.minions) do
        ent:DoTaskInTime(math.random(),function ()
            ent:PushEvent("disappear")
        end)
    end
end

local states= {
    -- idle 
    State{
        name = "idle",
        tags = { "idle"},

        onenter = function(inst,data)
            data = data or {
                emerge = true,
            }

            if data.emerge and not inst.AnimState:IsCurrentAnimation("hit_out") then
                inst.AnimState:PlayAnimation("emerge")
                inst.AnimState:PushAnimation("idle_out")
            else 
                inst.AnimState:PlayAnimation("idle_out")
            end
        end,

        events = {
            EventHandler("animover",function(inst)
                if inst.AnimState:AnimDone() then
                    -- print("idle_out done")
                    local next_sg,next_sg_data = PickStyle(inst)
                    if next_sg then
                        inst.sg:GoToState(next_sg,next_sg_data)
                    else 
                        inst.sg:GoToState("idle",{
                            emerge = false
                        })
                    end
                end
            end),
        },
    },

    -- idle_underground
    State{
        name = "idle_underground",
        tags = { "idle","underground","invisible"},

        onenter = function(inst)
            inst.AnimState:SetPercent("grow",0)

            inst.sg.statemem.task = inst:DoPeriodicTask(3,function()
                local next_sg,next_sg_data = PickStyle(inst)
                if next_sg then
                    inst.sg:GoToState(next_sg,next_sg_data)
                end
            end)
        end,

        onexit = function(inst)
            inst.AnimState:Resume()
            inst.sg.statemem.task:Cancel()
        end,
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_out")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_pain")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local next_sg,next_sg_data = PickStyle(inst)
                if next_sg then
                    inst.sg:GoToState(next_sg,next_sg_data)
                else 
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },


    -- c_findnext("galeboss_dragon_snare").sg:GoToState("into_underground")
    -- c_findnext("galeboss_dragon_snare").sg:GoToState("into_underground",{next_sg="attack_underground_spikes"})
    State{
        name = "into_underground",
        tags = {"busy"},

        onenter = function(inst,data)
            data = data or {}

            inst.sg.statemem.next_sg = data.next_sg
            inst.sg.statemem.next_sg_data = data.next_sg_data
            inst.sg.statemem.start_out = inst.AnimState:IsCurrentAnimation("idle_out")

            
            if inst.sg.statemem.start_out then
                -- 0.667s
                GaleCommon.PlayBackAnimation(inst,"emerge")
                -- 0.334s
                GaleCommon.PushBackAnimation(inst,"idle_trans")

                GaleCommon.PushBackAnimation(inst,"grow")
            else 
                -- 0.334s
                GaleCommon.PlayBackAnimation(inst,"idle_trans")

                GaleCommon.PushBackAnimation(inst,"grow")
            end
            
        end,

        timeline = {
            TimeEvent(15 * FRAMES,function(inst)
                if not inst.sg.statemem.start_out then
                    SpawnAt("galeboss_dragon_snare_sand_splash_fx",inst)
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/break_spike")
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_chew")
                    inst.sg:AddStateTag("underground")
                    inst:CheckUnderground()
                end 
            end),

            TimeEvent(16 * FRAMES,function(inst)
                if not inst.sg.statemem.start_out then
                    inst:EnableFlower(true)
                end 
            end),

            TimeEvent(35 * FRAMES,function(inst)
                if inst.sg.statemem.start_out then
                    SpawnAt("galeboss_dragon_snare_sand_splash_fx",inst)
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/break_spike")
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_chew")
                    inst.sg:AddStateTag("underground")
                    inst:CheckUnderground()
                end 
            end),

            TimeEvent(36 * FRAMES,function(inst)
                if inst.sg.statemem.start_out then
                    inst:EnableFlower(true)
                end 
            end),
        },

        onexit = function(inst)
            GaleCommon.ClearBackAnimation(inst)
        end,

        events = {
            EventHandler("back_animqueueover",function(inst)
                inst.sg:GoToState(inst.sg.statemem.next_sg or "idle_underground",inst.sg.statemem.next_sg_data)      
            end),
        },
    },

    -- c_findnext("galeboss_dragon_snare").sg:GoToState("out_of_underground")
    State{
        name = "out_of_underground",
        tags = {"busy","underground","invisible"},

        onenter = function(inst,data)
            data = data or {}


            inst.sg.statemem.next_sg = data.next_sg
            inst.sg.statemem.next_sg_data = data.next_sg_data
            inst.sg.statemem.dig_rabbit = data.dig_rabbit

            inst.AnimState:PlayAnimation("grow")
            inst.AnimState:PushAnimation("idle_trans")
            SpawnAt("galeboss_dragon_snare_sand_splash_fx",inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/break_spike")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_ambush")


              
        end,

        timeline = {

            TimeEvent(3 * FRAMES,function(inst)
                inst:EnableFlower(false)
            end),

            TimeEvent(5 * FRAMES,function(inst)
                inst.sg:RemoveStateTag("underground")
                inst:CheckUnderground()
                if inst.sg.statemem.dig_rabbit then
                    for i = 1,math.random(4,8) do
                        local offset = FindWalkableOffset(inst:GetPosition(),
                            GetRandomMinMax(0,2*PI),
                            GetRandomMinMax(0.5,3.5),
                            12,
                            nil,
                            false,
                            nil,
                            false,
                            false
                        ) or Vector3(0,0,0)

                        local rabbit = SpawnAt("rabbit",inst,nil,offset)
                    end
                    
                end
            end),

            
        },

        events = {
            EventHandler("animover",function (inst)
                inst.sg:GoToState(inst.sg.statemem.next_sg or "idle",inst.sg.statemem.next_sg_data or { emerge = true})
            end),
        },
    },

    -- c_findnext("galeboss_dragon_snare").sg:GoToState("attack_underground_spikes")
    State{
        name = "attack_underground_spikes",
        tags = { "busy","underground","attack","invisible"},

        onenter = function(inst,data)
            data = data or {}

            inst.sg.statemem.task = inst:DoPeriodicTask(0.4,function ()
                for i = 1,5 do
                    local offset = FindWalkableOffset(inst:GetPosition(),
                            GetRandomMinMax(0,2*PI),
                            GetRandomMinMax(0,16),
                            12,
                            nil,
                            false,
                            NoOtherSpikeTest,
                            false,
                            false
                        )

                    if offset ~= nil then
                        local spike = SpawnAt("galeboss_dragon_snare_sand_spike",inst,nil,offset)

                        spike:Hide()
                        spike:DoTaskInTime(math.random() * 2,function()
                            spike:Show()
                            spike:SetSize("tall")
                        end)
                    end
                    
                end

                if math.random() <= 0.4 and inst.components.combat.target then
                    local spike = SpawnAt("galeboss_dragon_snare_sand_spike",inst.components.combat.target)
                    spike:Hide()
                    spike:DoTaskInTime(math.random(),function()
                        spike:Show()
                        spike:SetSize("tall")
                    end)
                end
            end)

            inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.2,function()
                ShakeAllCameras(CAMERASHAKE.FULL, .33, .02, 0.4, inst, 25)
            end)
            inst.AnimState:SetPercent("grow",0)

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/giant_centipede_move_loop", "shake")

            inst.sg:SetTimeout(data.duration or 10)
        end,

        ontimeout = function(inst)
            local next_sg,next_sg_data = PickStyle(inst)
            if next_sg then
                inst.sg:GoToState(next_sg,next_sg_data)
            else 
                inst.sg:GoToState("out_of_underground")
            end
        end,

        timeline = {
            TimeEvent(8,function(inst)
                if inst.sg.statemem.task then
                    inst.sg.statemem.task:Cancel()
                    inst.sg.statemem.task = nil 
                end
            end)
        },

        onexit = function(inst)
            inst.AnimState:Resume()
            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil 
            end
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
                inst.sg.statemem.shake_task = nil 
            end
            inst.SoundEmitter:KillSound("shake")
        end,
    },

    -- roar
    State{
        name = "roar",
        tags = { "busy" },

        onenter = function(inst,data)
            data = data or {}

            inst.AnimState:PlayAnimation(data.anim or "hit_out",true)
            inst.AnimState:SetDeltaTimeMultiplier(2)
            
            inst.sg.statemem.next_sg = data.next_sg
            inst.sg.statemem.next_sg_data = data.next_sg_data
            inst.sg.statemem.check_style = data.check_style

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_death")
            inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.25,function()
                ShakeAllCameras(CAMERASHAKE.FULL, .33, .02, 0.3, inst, 25)
            end)
            inst.components.epicscare:Scare(5)

            inst.sg:SetTimeout(2)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.check_style then
                local next_sg,next_sg_data = PickStyle(inst)
                if next_sg then
                    inst.sg:GoToState(next_sg,next_sg_data)
                else 
                    inst.sg:GoToState("idle")
                end
            else 
                inst.sg:GoToState(inst.sg.statemem.next_sg or "idle",inst.sg.statemem.next_sg_data)    
            end
            
        end,

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
            end
        end,
    },

    -- summon_tentacles
    State{
        name = "summon_tentacles",
        tags = { "summoning", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("emerge")
            inst.AnimState:PushAnimation("idle_out",false)
            
            

            inst.sg:SetTimeout(2.2)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("attack_using_moving_tentacle")
        end,

        events = {
            EventHandler("animover",function (inst)
                if inst.AnimState:IsCurrentAnimation("emerge") then
                    inst.AnimState:SetDeltaTimeMultiplier(2.5)
                end

                if inst.AnimState:IsCurrentAnimation("idle_out") then
                    inst.AnimState:SetDeltaTimeMultiplier(2)
                    inst.AnimState:PlayAnimation("hit_out",true)
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_death")

                    ------------------------------------------------------------------------
                    -- Summon tentacles
                    inst.components.galeboss_skill_summon_minion:AbandonAllMinion("REFREASH",true)
                    local pos = inst:GetPosition()
                    for i = 1,5 do
                        local offset = FindWalkableOffset(pos,GetRandomMinMax(0,PI * 2),GetRandomMinMax(4,12),15) or Vector3(0,0,0)
                        local tentacle = inst.components.galeboss_skill_summon_minion:AddMinion("galeboss_dragon_snare_moving_tentacle",pos+offset)

                        tentacle.sg:GoToState("spawn")

                        -- tentacle.LastCastDashTime = GetTime() + GetRandomMinMax(1,10)
                    end
                    ------------------------------------------------------------------------

                    inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.25,function()
                        ShakeAllCameras(CAMERASHAKE.FULL, .33, .02, 0.3, inst, 25)
                    end)
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
            end
        end,
    },

    -- c_findnext("galeboss_dragon_snare").sg:GoToState("attack_using_moving_tentacle")
    State{
        name = "attack_using_moving_tentacle",
        tags = { "busy",},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_out")

            inst.components.health.externalabsorbmodifiers:SetModifier(inst,0.9,"attack_using_moving_tentacle")
        end,

        timeline = {

        },

        events = {
            EventHandler("animover",function (inst)
                if inst.AnimState:IsCurrentAnimation("idle_out") then
                    -- local target = inst.components.combat.target 

                    -- if target then
                    --     if math.random() <= 0.4 then
                    --         inst.AnimState:PlayAnimation("taunt")
                    --         inst.AnimState:PushAnimation("idle_out",false)
                    --     else 
                    --         inst.AnimState:PlayAnimation("idle_out")
                    --     end
                    --     return 
                    -- end

                    local target = inst.components.combat.target 

                    if not target or inst.components.galeboss_skill_summon_minion:MinionCount() <= 0 then
                        local next_sg,next_sg_data = PickStyle(inst)
                        if next_sg then
                            inst.sg:GoToState(next_sg,next_sg_data)
                        else 
                            inst.sg:GoToState("idle")
                        end
                    else 
                        
                        if math.random() <= 0.4 then
                            inst.AnimState:PlayAnimation("taunt")
                            inst.AnimState:PushAnimation("idle_out",false)
                        else 
                            inst.AnimState:PlayAnimation("idle_out")
                        end
                    end 
                end
            end),
            EventHandler("galeboss_abandon_minion",function (inst,data)
                -- if inst.components.galeboss_skill_summon_minion:MinionCount() <= 0 then
                --     inst.sg:GoToState(inst.sg.statemem.next_sg or "idle",inst.sg.statemem.next_sg_data)
                -- end

                
                -- print("galeboss_abandon_minion",data.reason)

                if data.reason == "ENTITY_DEATH" then
                    for ent,_ in pairs(inst.components.galeboss_skill_summon_minion.minions) do
                        if ent.prefab == "galeboss_dragon_snare_moving_tentacle" then
                            ent.components.combat:RestartCooldown()
    
                            if ent.sg.currentstate.name == "attack_dash" or ent.sg.currentstate.name == "attack" then
                                ent.sg:GoToState("into_underground",{
                                    speed = 5
                                })
                            else 
                                ent.sg:GoToState("idle")
                            end
                            
                            if inst.components.galeboss_skill_summon_minion:MinionCount() <= 3 then
                                ent.CanDash = true
                            end 
                            ent.components.locomotor.runspeed = ent.components.locomotor.runspeed + 0.4
                        end
                    end
                    -- inst.components.combat
                    -- amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb
                    inst.components.health:DoDelta(-100,nil,nil,false,nil,true)
                    inst.sg:GoToState("roar",{
                        next_sg = "attack_using_moving_tentacle"
                    })
                end

                
            end),
            EventHandler("attacked",function (inst,data)
                if not inst.AnimState:IsCurrentAnimation("hit_out") then
                    inst.AnimState:PlayAnimation("hit_out")
                    inst.AnimState:PushAnimation("idle_out",false)
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_pain")
                end
                -- SpawnPrefab("bramblefx_armor"):SetFXOwner(inst)
                -- inst.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
            end),
        },

        onexit = function(inst)
            -- disappear

            if inst.components.combat.target == nil then
                MakeMinionsDisappear(inst)
    
                inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_OUT",false)
            end
            inst.components.health.externalabsorbmodifiers:RemoveModifier(inst,"attack_using_moving_tentacle")
        end,
    },

    State{
        name = "summon_babyplants",
        tags = { "summoning", "busy","underground","invisible" },

        onenter = function(inst)
            inst.AnimState:SetPercent("grow",0)

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/giant_centipede_move_loop", "shake")

            inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.2,function()
                ShakeAllCameras(CAMERASHAKE.FULL, .33, .02, 0.4, inst, 25)
            end)

            inst.sg.statemem.spawn_thread = inst:StartThread(function ()
                local max_cnt = 40
                local cur_cnt = 0
                local x,y,z = inst:GetPosition():Get()
                local distancemodifier = 11
                for i = 1, 100 do
                    local s = i / 32--(num/2) -- 32.0
                    local a = math.sqrt(s * 512)
                    local b = math.sqrt(s) * distancemodifier
                    local pos = Vector3(x + math.sin(a) * b, 0, z + math.cos(a) * b)
                    if TheWorld.Map:IsAboveGroundAtPoint(pos.x, pos.y, pos.z,false) and
                        #TheSim:FindEntities(pos.x, pos.y, pos.z, 2.5, {"galeboss_dragon_snare_token"}) <= 0 and
                        not TheWorld.Map:IsPointNearHole(pos) then

                        cur_cnt = cur_cnt + 1
                        if cur_cnt > max_cnt then
                            break
                        end

                        local baby = inst.components.galeboss_skill_summon_minion:AddMinion("galeboss_dragon_snare_babyplant",pos)
                        baby.sg:GoToState("spawn")

                        Sleep(math.random(0,3) * FRAMES)
                    end
                end

                Sleep(2)

                inst.sg.statemem.finished = true
            end)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.finished then
                inst.sg:GoToState("out_of_underground",{next_sg="attack_using_babyplant",dig_rabbit = true})
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.shake_task then
                inst.sg.statemem.shake_task:Cancel()
            end
            if not inst.sg.statemem.finished and inst.sg.statemem.spawn_thread then
                KillThread(inst.sg.statemem.spawn_thread)
            end
            inst.SoundEmitter:KillSound("shake")
        end,
    },

    State{
        name = "attack_using_babyplant",
        tags = { "busy",},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
            inst.components.health.externalabsorbmodifiers:SetModifier(inst,0.9,"attack_using_babyplant")

            inst.sg:SetTimeout(GetRandomMinMax(15,25))
        end,

        timeline = {

        },

        ontimeout = function(inst)
            inst.sg.statemem.should_exit = true
        end,



        events = {
            EventHandler("animover",function (inst)
                if inst.AnimState:IsCurrentAnimation("idle") then

                    local target = inst.components.combat.target 

                    if not target 
                        or inst.components.galeboss_skill_summon_minion:MinionCount() <= 0 
                        or inst.sg.statemem.should_exit then

                        MakeMinionsDisappear(inst)

                        local next_sg,next_sg_data = PickStyle(inst)
                        if next_sg then
                            inst.sg:GoToState(next_sg,next_sg_data)
                        else 
                            inst.sg:GoToState("idle")
                        end
                    else 
                        local item = inst.components.inventory:FindItem(function ()
                            return true
                        end)

                        if item then
                            inst.sg:GoToState("eat")
                            return 
                        end


                        inst.AnimState:PlayAnimation("idle")
                    end 
                end
                if inst.sg.statemem.wanttoroar then
                    MakeMinionsDisappear(inst)
        
                    inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_OUT",false)

                    inst.sg:GoToState("roar",{
                        anim = "hit",
                        check_style = true,
                    })
                end
            end),
            EventHandler("galeboss_abandon_minion",function (inst,data)


                if data.reason == "ENTITY_DEATH" then
                    print(inst,"galeboss_abandon_minion ENTITY_DEATH")
                    if data.ent and data.ent:IsValid() then
                        print(inst,"galeboss_abandon_minion ENTITY_DEATH 2 ",data.ent,data.ent:IsValid())
                        local respawn_pos = data.ent:GetPosition()
                        inst:DoTaskInTime(GetRandomMinMax(5,6),function ()
                            print(inst,"try respawn baby plants...")
                            if inst.style == STYLES.BABYPLANT then
                                print(inst,"respawn baby plants OK!")
                                local baby = inst.components.galeboss_skill_summon_minion:AddMinion("galeboss_dragon_snare_babyplant",respawn_pos)
                                baby.sg:GoToState("spawn")
                            end
                            
                        end)
                        
                    end
                end

                
            end),
            EventHandler("attacked",function (inst,data)
                if not inst.AnimState:IsCurrentAnimation("hit") then
                    inst.AnimState:PlayAnimation("hit")
                    inst.AnimState:PushAnimation("idle",false)
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_pain")
                end
                if data.damage >= 200 then
                    inst.sg.statemem.wanttoroar = true
                end
            end),
        },

        onexit = function(inst)
            -- disappear
            if inst.components.combat.target == nil then
                MakeMinionsDisappear(inst)
    
                inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_OUT",false)
            end
            inst.components.health.externalabsorbmodifiers:RemoveModifier(inst,"attack_using_babyplant")
        end,
    },

    -- c_findnext("galeboss_dragon_snare").sg:GoToState("eat")
    State{
        name = "eat",
        tags = { "busy","eat"},

        onenter = function(inst)
            inst.sg.statemem.start_time = 0 * FRAMES
            inst.sg.statemem.end_time = 11 * FRAMES
            inst.sg.statemem.length = 20 * FRAMES
            inst.sg.statemem.cur_time = inst.sg.statemem.start_time
            inst.sg.statemem.speed = 1.66
            inst.sg.statemem.inverse = false
            inst.sg.statemem.should_exit = false

            inst.AnimState:SetPercent("emerge",inst.sg.statemem.start_time / inst.sg.statemem.length)
            inst.AnimState:HideSymbol("tenticle")
            inst.AnimState:HideSymbol("swap_dried")

            inst.sg:SetTimeout(GetRandomMinMax(1.5,2))
        end,

        ontimeout = function(inst)
            inst.sg.statemem.should_exit = true
        end,

        onupdate = function(inst)
            if inst.sg.statemem.inverse then
                inst.sg.statemem.cur_time = inst.sg.statemem.cur_time - FRAMES * inst.sg.statemem.speed
            else 
                inst.sg.statemem.cur_time = inst.sg.statemem.cur_time + FRAMES * inst.sg.statemem.speed
            end

            
            if inst.sg.statemem.should_exit and inst.sg.statemem.inverse and inst.sg.statemem.cur_time <= 0 then
                inst.AnimState:SetPercent("emerge",0)
                local item = inst.components.inventory:FindItem(function ()
                    return true
                end)

                if item then
                    inst.sg:GoToState("eat")
                else 
                    inst.sg:GoToState("attack_using_babyplant")
                end                
                
                return 
            end
            
            if inst.sg.statemem.cur_time > inst.sg.statemem.end_time then
                inst.sg.statemem.inverse = true
                inst.sg.statemem.cur_time = inst.sg.statemem.end_time
            elseif inst.sg.statemem.cur_time < inst.sg.statemem.start_time then
                inst.sg.statemem.inverse = false 
                inst.sg.statemem.cur_time = inst.sg.statemem.start_time
            end

            -- 8~10
            if inst.sg.statemem.inverse and 
                8 * FRAMES < inst.sg.statemem.cur_time and
                inst.sg.statemem.cur_time < 10 * FRAMES then
                    
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_dragon_snare/p1_maneater_chew")
            end

            inst.AnimState:SetPercent("emerge",inst.sg.statemem.cur_time / inst.sg.statemem.length)
        end,

        timeline = {
            TimeEvent(30 * FRAMES,function(inst)
                -- Eat sth
                local item,ftype = GetItemToConsume(inst)
                if ftype == "FOOD" then
                    inst.components.eater:Eat(item)
                elseif item then
                    -- if not item:HasTag("irreplaceable") then
                    --     item:Remove()
                    -- else 

                    -- end
                    item:Remove()
                        
                end
            end)
        },

        events = {
            EventHandler("attacked",function (inst,data)
                if data.damage >= 200 then
                    MakeMinionsDisappear(inst)
        
                    inst.components.galeboss_skill_summon_minion:AbandonAllMinion("LEADER_OUT",false)
                    
                    inst.sg:GoToState("roar",{
                        anim = "hit",
                        check_style = true,
                    })
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ShowSymbol("tenticle")
            inst.AnimState:ShowSymbol("swap_dried")
        end,
    },

    State{
        name = "death",
        tags = { "busy","dead" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_out",true)
            inst.AnimState:SetDeltaTimeMultiplier(2.5)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_final_hit")
            inst:SpawnChild("galeboss_explode_fx_start").Transform:SetPosition(0,2,0)
            inst:SetMusicLevel(1)
            ShakeAllCameras(CAMERASHAKE.FULL, 0.8, .03, .5, inst, 30)
        end,

        timeline = {
            TimeEvent(25 * FRAMES,function(inst)
                inst.AnimState:PlayAnimation("hit_out",true)
                inst.AnimState:SetDeltaTimeMultiplier(3)
                inst.sg.statemem.loopfx = inst:SpawnChild("galeboss_explode_fx")
                inst.sg.statemem.loopfx.Transform:SetPosition(0,2,0)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_gushing")

                inst.sg.statemem.shake_task = inst:DoPeriodicTask(0.2,function()
                    ShakeAllCameras(CAMERASHAKE.FULL, .33, .015, 0.3, inst, 25)
                end)
            end),

            TimeEvent(115 * FRAMES,function(inst)
                inst.sg.statemem.loopfx:Remove()
                if inst.sg.statemem.shake_task then
                    inst.sg.statemem.shake_task:Cancel()
                    inst.sg.statemem.shake_task = nil 
                end
                inst.AnimState:SetDeltaTimeMultiplier(1.1)
                inst.AnimState:PlayAnimation("hide")
            end),
            TimeEvent(133 * FRAMES,function(inst)
                inst.AnimState:SetDeltaTimeMultiplier(1)
                inst.AnimState:PlayAnimation("death")
            end),

            TimeEvent(140 * FRAMES,function(inst)
                

                inst:SpawnChild("galeboss_explode_fx_start").Transform:SetPosition(0,2,0)
                inst:SpawnChild("galeboss_explode_fx_final").Transform:SetPosition(0,2,0)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_defeat/boss_explode")

                
                ShakeAllCameras(CAMERASHAKE.FULL, 0.8, .03, .5, inst, 30)
                TheWorld:PushEvent("screenflash", .5)

                inst.components.lootdropper:DropLoot()
            end),

            TimeEvent(143 * FRAMES,function(inst)
                inst.AnimState:OverrideSymbol("bulb_leaf","galeboss_dragon_snare","bulb_leaf_death")
            end),

            TimeEvent(150 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(157 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(160 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(167 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(190 * FRAMES,function(inst)
                inst:SetMusicLevel(3)
            end),

            TimeEvent(190 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(195 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(203 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(208 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(210 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(215 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(217 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(222 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),

            TimeEvent(250 * FRAMES,function(inst)
                GaleCommon.PlayBackAnimation(inst,"death")
            end),

            TimeEvent(257 * FRAMES,function(inst)
                GaleCommon.ClearBackAnimation(inst)
                local time = inst.AnimState:GetCurrentAnimationTime()
                inst.AnimState:PlayAnimation("death")
                inst.AnimState:SetTime(time)
            end),
            

            
        },
    },
}

return StateGraph("SGgaleboss_dragon_snare", states, events, "idle_underground",actionhandlers)
