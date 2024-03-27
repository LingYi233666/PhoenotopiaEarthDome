local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    -- CommonHandlers.OnDeath(),

    EventHandler("death", function(inst)
        inst.sg:GoToState("death_pre")
    end),


}

local function FindTargetNearBy(inst,targetpos,rad,min_len)
    min_len = min_len or math.clamp(rad * 1.5,6,12)
    local function customcheckfn(suitpos)
        return (inst:GetPosition() - suitpos):Length() >= min_len
    end
    local offset = FindWalkableOffset(targetpos,0,rad,12,nil,nil,customcheckfn,false,true) or Vector3(0,0,0)

    return offset
end

local states = {
    State{
        name = "ball_charge",
        tags = {"busy", "doing","attack"},
    
        onenter = function(inst,data)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("charge_pre")
            inst.AnimState:PushAnimation("charge_grow",true)

            inst.sg.statemem.target = data.target

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/enm_giant_super_charge_loop", "chargedup")
            -- ThePlayer.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/charge2", "chargedup") ThePlayer.SoundEmitter:KillSound("chargedup")
            -- 
            inst.sg:SetTimeout(data.time or 0.5)
        end,

        onupdate = function(inst)
            inst.sg.statemem.target = (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) and inst.sg.statemem.target or inst.components.combat.target
        
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then 
                inst:ForceFacePoint(inst.sg.statemem.target:GetPosition():Get())
            end
        end,
    
        ontimeout = function(inst)
            inst.sg:GoToState("ball_release")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("chargedup")
        end,
        
    },

    State{
        name = "ball_release",
        tags = {"busy", "doing","attack"},
    
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("charge_pst")
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) 
                local targetpos = inst:GetPosition() + GaleCommon.GetFaceVector(inst) * 15
                local proj = SpawnAt("galeboss_errorbot_redball",inst)
                proj.components.complexprojectile:SetLaunchOffset(Vector3(0,0.7,0))
                proj.components.complexprojectile:Launch(targetpos,inst)
                -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/smallshot")
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/enm_tp")
            end),   
            TimeEvent(5*FRAMES, function(inst) inst.sg:RemoveStateTag("busy")  end),   
            
        }, 
        
        events=
        {
            EventHandler("animover", function(inst) 
                if inst.BallCount and inst.BallCount > 0 then 
                    inst.BallCount = inst.BallCount - 1
                end 

                if inst.BallCount > 0 then 
                    inst.sg:GoToState("ball_charge") 
                else
                    inst.sg:GoToState("idle") 
                end
                
            end ),
        },             
    },

    State{
        name = "attack_leap",
        tags = {"busy", "doing","attack","nointerrupt"},
    
        onenter = function(inst,data)
            data.target = data.target or inst.components.combat.target 

            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("atk_leap")

            local targetpos = data.target:GetPosition()
            local dist = targetpos:Dist(inst:GetPosition())

            inst:ForceFacePoint(targetpos:Get())

            inst.sg.statemem.targetpos = targetpos
            inst.sg.statemem.speed = dist / (data.time or 0.4)
            inst.sg.statemem.use_shadow = true 
            
            inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
            GaleCommon.ToggleOffPhysics(inst)

            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")

        end,

        onupdate = function(inst)
            if inst.sg.statemem.use_shadow then 
                local anim_data = GaleCommon.GetAnim(inst)
                local shadow = SpawnAt("galeboss_errorbot_shadow",inst)
                shadow.Transform:SetRotation(inst.Transform:GetRotation())
                shadow.AnimState:SetPercent(anim_data.anim,anim_data.percent)
                GaleCommon.FadeTo(shadow,FRAMES * 7,nil,{Vector4(0.7,0,0,0.6),Vector4(0,0,0,0)},{Vector4(0.3,0,0,1),Vector4(0,0,0,0)},shadow.Remove)
            end 
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
            end),

            TimeEvent(6*FRAMES, function(inst) 
                inst.AnimState:Resume()                
                inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
                inst.sg.statemem.use_shadow = true
            end),

            TimeEvent(12 * FRAMES, function(inst)
                GaleCommon.ToggleOnPhysics(inst)
                inst.sg.statemem.use_shadow = false
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
            end),

            TimeEvent(13 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.sg:RemoveStateTag("nointerrupt")
                --Do aoe here
                local aoepos = inst:GetPosition() + GaleCommon.GetFaceVector(inst)
                SpawnAt("gale_laser_ring_fx",aoepos)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/explode")
                
                GaleCommon.AoeGetAttacked(inst,
                    aoepos,
                    2.5,
                    40,
                    function(inst,other)
                        return inst.components.combat and inst.components.combat:CanTarget(other) and not inst.components.combat:IsAlly(other)
                    end
                )
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle",true)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                GaleCommon.ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                local x, y, z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsPassableAtPoint(x, 0, z) and not TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
                    inst.Physics:Teleport(x, 0, z)
                else
                    inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
                end
            end
            inst.Transform:SetFourFaced()
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            inst.components.bloomer:PopBloom("leap")
            inst.components.colouradder:PopColour("leap")

        end,
        
    },

    State{
        name = "teleport",
        tags = {"busy","teleport"},
        
        onenter = function(inst,data)
            local attackerpos = data.attacker:GetPosition()
            -- local offset = FindWalkableOffset(attackerpos,data.start_angle or 0,data.telerad,6) or Vector3(0,0,0)
            local offset = FindTargetNearBy(inst,attackerpos,data.telerad)
            inst.sg.statemem.origin_pos = inst:GetPosition()
            inst.sg.statemem.target_pos = attackerpos + offset
            inst.sg.statemem.current_time = 0
            inst.sg.statemem.max_time = data.time or 0.2

			
            inst.components.locomotor:Stop()
            -- SpawnAt("gale_laser_explosion",inst).Transform:SetScale(0.6,0.6,0.6)	
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/teleport")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/teleport_bg2")
            

            -- inst.Transform:SetPosition((offset + attackerpos):Get())
            -- SpawnAt("gale_laser_explosion",inst).Transform:SetScale(0.6,0.6,0.6)	

            -- 

            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.AnimState:PushAnimation("atk_leap_lag",false)

            inst:ForceFacePoint(inst.sg.statemem.target_pos:Get())

        end,

        onupdate = function(inst)
            inst.sg.statemem.current_time = math.min(inst.sg.statemem.current_time + FRAMES,inst.sg.statemem.max_time)

            local delta_pos = (inst.sg.statemem.target_pos - inst.sg.statemem.origin_pos) / inst.sg.statemem.max_time
            local current_pos = inst.sg.statemem.origin_pos + delta_pos * inst.sg.statemem.current_time 

            local anim_data = GaleCommon.GetAnim(inst)
            local shadow = SpawnAt("galeboss_errorbot_shadow",inst)
            shadow.Transform:SetRotation(inst.Transform:GetRotation())
            shadow.AnimState:PlayAnimation(anim_data.anim)
            shadow.AnimState:SetTime(anim_data.frame)
            shadow.Physics:SetMotorVel(12 * (1 - inst.sg.statemem.current_time / inst.sg.statemem.max_time),0,0)
            GaleCommon.FadeTo(shadow,FRAMES * 7,nil,{Vector4(0.3,0,0,0.6),Vector4(0,0,0,0)},{Vector4(0.7,0,0,1),Vector4(0,0,0,0)},shadow.Remove)

            inst.Transform:SetPosition(current_pos:Get())

            if inst.sg.statemem.current_time >= inst.sg.statemem.max_time then 
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle",true)   
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.attacker and inst.sg.statemem.attacker:IsValid() and inst:IsNear(inst.sg.statemem.attacker,3) then 
                inst.components.combat:ResetCooldown()
            end
        end,

        events=
        {
           
        },             
    },   

    State{
        name = "attack_flying",
        tags = {"busy", "doing","attack"},
    
        onenter = function(inst,data)
            inst.Physics:Stop()  
            inst.components.locomotor:Stop()          
            inst.AnimState:PlayAnimation("charge_pre")
            inst.AnimState:PushAnimation("charge_grow",false)
            inst.AnimState:PushAnimation("charge_super_pre",false)
            inst.AnimState:PushAnimation("charge_super_loop",true)

            data.time = data.time or 3 
            data.height = data.height or 8
            inst.sg.statemem.target = data.target
            inst.sg.statemem.last_launch_time = 0
            inst.sg.statemem.height = data.height
            inst.sg.statemem.num_to_launch = 4

            local fx = SpawnPrefab("gale_rocket_flame")
            fx.entity:SetParent(inst.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "torso",0,0,0)

            inst.sg.statemem.fx = fx 

            -- inst.SoundEmitter:PlaySound("gale_sfx/battle/gale_rocket")
            -- inst.SoundEmitter:PlaySound("gale_sfx/battle/gale_hover_loop", "flying")

            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/borg_jump")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/borg_hover", "flying")
            

            inst.sg:SetTimeout(data.time)

            inst.components.gale_flyer:Enable(true)
            inst.components.gale_flyer:SetHeight(data.height)
        end,

        onupdate = function(inst)
            inst.sg.statemem.target = (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) and inst.sg.statemem.target or inst.components.combat.target
        
            if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then 
                inst:ForceFacePoint(inst.sg.statemem.target:GetPosition():Get())
            end

            local y = inst:GetPosition().y 
            if inst.sg.statemem.num_to_launch > 0 and GetTime() - inst.sg.statemem.last_launch_time >= 0.75 and y >= inst.sg.statemem.height * 0.8 then 
                if not (inst.sg.statemem.target and inst.sg.statemem.target:IsValid()) then 
                    return 
                end
                local proj = SpawnAt("galeboss_errorbot_redball",inst)
                proj.hit_ground = true
                proj.components.complexprojectile:SetLaunchOffset(Vector3(0,0.7,0))
                proj.components.complexprojectile:Launch(inst.sg.statemem.target:GetPosition(),inst)
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/enm_tp")

                inst.sg.statemem.last_launch_time = GetTime()
                inst.sg.statemem.num_to_launch = inst.sg.statemem.num_to_launch - 1
            end 
        end,
    
        ontimeout = function(inst)
            local tarpos = inst.components.combat.target and inst.components.combat.target:GetPosition() or inst:GetPosition()
            tarpos.y = 0
            inst.sg:GoToState("attack_flying_pst",{targetpos = tarpos})
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("flying")
            inst.components.gale_flyer:Enable(false)
            inst.components.gale_flyer:SetHeight(0)
            if inst.sg.statemem.fx then 
                inst.sg.statemem.fx:Remove()
            end 
        end,
    },

    State{
        name = "attack_flying_pst",
        tags = {"busy", "doing","attack"},
    
        onenter = function(inst,data)
            inst.Physics:Stop()        
            inst.sg.statemem.origin_pos = inst:GetPosition()
            inst.sg.statemem.target_pos = data.targetpos
            inst.sg.statemem.current_time = 0
            inst.sg.statemem.max_time = data.time or 0.3
            inst.sg.statemem.doing = false
            inst:ForceFacePoint(data.targetpos:Get())
        end,

        onupdate = function(inst)
            if inst.sg.statemem.doing then 
                if not inst.sg.statemem.entered then 
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/teleport")
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/teleport_bg2")
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/stomp_air","stomp_air")
                    inst.AnimState:PlayAnimation("atk_leap_pre")
                    
                    local fx = SpawnPrefab("gale_superdash_vfx")
                    fx.entity:SetParent(inst.entity)
                    fx.Follower:FollowSymbol(inst.GUID, "torso",0,-110,0)
                    fx:SetTargetPos(inst.sg.statemem.target_pos:Get())
                    inst.sg.statemem.entered = true 
                end
                inst.sg.statemem.current_time = math.min(inst.sg.statemem.current_time + FRAMES,inst.sg.statemem.max_time)

                local delta_pos = (inst.sg.statemem.target_pos - inst.sg.statemem.origin_pos) / inst.sg.statemem.max_time
                local current_pos = inst.sg.statemem.origin_pos + delta_pos * inst.sg.statemem.current_time 

                local anim_data = GaleCommon.GetAnim(inst)
                local shadow = SpawnAt("galeboss_errorbot_shadow",inst)
                shadow.Transform:SetRotation(inst.Transform:GetRotation())
                shadow.AnimState:PlayAnimation(anim_data.anim)
                shadow.AnimState:SetTime(anim_data.frame)
                shadow.Physics:SetMotorVel(12 * (1 - inst.sg.statemem.current_time / inst.sg.statemem.max_time),0,0)
                GaleCommon.FadeTo(shadow,FRAMES * 7,nil,{Vector4(0.3,0,0,0.6),Vector4(0,0,0,0)},{Vector4(0.7,0,0,1),Vector4(0,0,0,0)},shadow.Remove)

                inst.Transform:SetPosition(current_pos:Get())

                if inst.sg.statemem.current_time >= inst.sg.statemem.max_time then 
                    local fx = SpawnAt("gale_groundhit_fx",inst)
                    fx:DoPlayAnim(3)
                    fx.Transform:SetScale(1.5,1.8,1.5)

                    ShakeAllCameras(CAMERASHAKE.FULL, 1.2, .03, .7, inst, 30)
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/stomp_char"..tostring(math.random(2,3)))
                    inst:StartThread(function()
                        for i = 1,6 do 
                            local pos = inst:GetPosition()
                            local offset = FindWalkableOffset(pos,math.random() * 360,1 + 2 * math.random(),6) or Vector3(0,0,0)
                            local fx = SpawnAt("gale_groundhit_fx",pos+offset)
                            fx:DoPlayAnim(2)
                            fx.Transform:SetScale(1.5,1.8,1.5)
                            if i % 2 == 0 then
                                fx.SoundEmitter:PlaySound("gale_sfx/battle/stomp_char"..tostring(math.random(2,3)))
                            end
                            Sleep(0)
                        end
                    end)
                    GaleCommon.AoeGetAttacked(inst,
                        inst:GetPosition(),
                        3,
                        40,
                        function(inst,other)
                            return inst.components.combat and inst.components.combat:CanTarget(other) and not inst.components.combat:IsAlly(other)
                        end
                    )
                    
                    
                    inst.sg:GoToState("attack_flying_pst_pst",{}) 
                end
            end 
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) 
                -- SpawnAt("gale_laser_explode_sm",inst).Transform:SetScale(2,2,2)
                -- inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_weapon_charge")
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                inst.SoundEmitter:PlaySound("gale_sfx/battle/hit_crit")
                inst.AnimState:PlayAnimation("charge_super_pst")
                
            end),

            TimeEvent(12*FRAMES, function(inst) 
                inst.sg.statemem.doing = true
                inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/active_denialwave")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("stomp_air")
        end,
    },

    State{
        name = "attack_flying_pst_pst",
        tags = {"busy", "doing"},
    
        onenter = function(inst,data)
            inst.Physics:Stop()        
            inst.AnimState:PlayAnimation("pickup")

            inst.sg.statemem.speed = data.speed or 5
            inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
        end,

        onupdate = function(inst)
            inst.sg.statemem.speed = inst.sg.statemem.speed - FRAMES * 7
            if inst.sg.statemem.speed >= 0 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed,0,0)
            else
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle",true)
            end
        end,

        onexit = function(inst)
            inst.Physics:Stop()    
        end,
    },
    

    State{
        name = "death_pre",
        tags = {"busy"},
    
        onenter = function(inst,data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("suit_destruct")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/static_shocked","shocked")
            inst.sg:SetTimeout(5)
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) 
                inst.sg.statemem.shock_anim_task = inst:DoPeriodicTask(8 * FRAMES,function()
                    inst.AnimState:SetTime(25 * FRAMES)
                end)

                inst.sg.statemem.explo_fx_task = inst:DoPeriodicTask(8 * FRAMES,function()
                    local rad = 0.8
                    local x = GetRandomMinMax(-rad,rad)
                    local z = GetRandomMinMax(-rad,rad)
                    inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
                    SpawnAt("gale_laser_explode_sm",inst:GetPosition() + Vector3(x,1,z))
                end)

                
                
            end),

            TimeEvent(4.5 * 30 * FRAMES, function(inst) 
                if inst.sg.statemem.shock_anim_task then
                    inst.sg.statemem.shock_anim_task:Cancel()
                    inst.sg.statemem.shock_anim_task = nil 
                end

                -- if inst.sg.statemem.explo_fx_task then
                --     inst.sg.statemem.explo_fx_task:Cancel()
                --     inst.sg.statemem.explo_fx_task = nil 
                -- end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("death")
        end,

        onexit = function(inst)
            if inst.sg.statemem.shock_anim_task then
                inst.sg.statemem.shock_anim_task:Cancel()
            end

            if inst.sg.statemem.explo_fx_task then
                inst.sg.statemem.explo_fx_task:Cancel()
            end
        end,
    },
}

CommonStates.AddIdle(states)
CommonStates.AddCombatStates(states,{
    hittimeline =
    {
        TimeEvent(0*FRAMES, function(inst) 
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/hit") 
            inst.SoundEmitter:PlaySound("gale_sfx/battle/galeboss_errorbot/borg_hurt")
        end),
    },
    
    attacktimeline = 
    {
    
        TimeEvent(0*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("gale_sfx/battle/zombot/p1_zombot_scream")
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/punch_pre") 
        end),
        
        TimeEvent(6*FRAMES, function(inst) 
            -- inst:PerformBufferedAction() 
            inst.components.combat:DoAttack(inst.components.combat.target)
        end),
        
		TimeEvent(8*FRAMES, function(inst) 
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/punch") 
            inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/hide_pre")
            -- inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/wendigo/wendigo_slash_wall")
            
        end),

        TimeEvent(12*FRAMES, function(inst) 
            inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") 
        end),
    },

    deathtimeline = {
        TimeEvent(0*FRAMES, function(inst) 
            SpawnAt("gale_laser_explosion",inst).Transform:SetScale(1.6,1.6,1.6)
            -- SpawnAt("gale_laser_explode_sm",inst:GetPosition() + Vector3(0,1,0)).Transform:SetScale(2,2,2)
            inst.SoundEmitter:PlaySound("gale_sfx/battle/explode")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/explo_stereo")
            -- inst.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
            inst.SoundEmitter:PlaySound("gale_sfx/battle/zombot/p1_zombot_shutoff")

            inst.SoundEmitter:KillSound("shocked")

            SpawnAt("deerclops_laserscorch",inst).Transform:SetScale(1.6,1.6,1.6)

            inst:Hide()
        end),
        -- TimeEvent(4*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .2}) 
        -- end),
        -- TimeEvent(8*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .4}) 
        -- end),
        -- TimeEvent(12*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .6}) 
        -- end),
        -- TimeEvent(19*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= 1}) 
        -- end),
        -- TimeEvent(26*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) 
        -- end),
        -- TimeEvent(35*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) 
        -- end),
        
        -- TimeEvent(52*FRAMES, function(inst) 
        --     SpawnAt("gale_laser_explosion",inst).Transform:SetScale(0.6,0.6,0.6)
        -- end),

        -- TimeEvent(54*FRAMES, function(inst) 
        --     inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/explosion") 
        -- end),  
    },
},
{
    attack="power_punch",
    -- death="suit_destruct",
    death="",

}
)

CommonStates.AddRunStates(states)
CommonStates.AddWalkStates(states)

return StateGraph("SGgaleboss_errorbot", states, events, "idle")

