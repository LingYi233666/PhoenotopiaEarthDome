local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

SetSharedLootTable("typhon_phantom", {
    { "typhon_phantom_organ", 1.00 },
    { "boneshard",            1.00 },
    { "boneshard",            1.00 },
})

local sound_index_map = {
    I_HEAR_YOU = "gale_sfx/battle/typhon_phantom/talk_text/i_hear_you",
    I_WILL_CHECKOUT = "gale_sfx/battle/typhon_phantom/talk_text/i_will_checkout",
    WHERE_ARE_YOU = "gale_sfx/battle/typhon_phantom/talk_text/where_are_you",
    WHERE_YOU_ARE = "gale_sfx/battle/typhon_phantom/talk_text/where_you_are",
    COME_OUT = "gale_sfx/battle/typhon_phantom/talk_text2/comeout",
    SHHH_SOMEONE_IS_COMMING = "gale_sfx/battle/typhon_phantom/talk_text2/shhhhangonsomeonesco",
    SHHH_THERE_ARE_SOMETHING = "gale_sfx/battle/typhon_phantom/talk_text2/shhhtheressomething",
    BETTER_NOT_BE_ANYTHING = "gale_sfx/battle/typhon_phantom/talk_text2/therebetternotbeanyt",
    SOMETHING_OVER_THERE = "gale_sfx/battle/typhon_phantom/talk_text2/theressomethingovert",
    WHATS_GOING_ON = "gale_sfx/battle/typhon_phantom/talk_text2/whatisgoingon",
    WHAT_WAS_THAT = "gale_sfx/battle/typhon_phantom/talk_text2/whatwasthat",

    I_SEE = "gale_sfx/battle/typhon_phantom/talk_text/i_see",
    I_SEE_YOU = "gale_sfx/battle/typhon_phantom/talk_text/i_see_you",
    THERE_YOU_ARE = "gale_sfx/battle/typhon_phantom/talk_text/there_you_are",
    WHO_ARE_YOU = "gale_sfx/battle/typhon_phantom/talk_text/who_are_you",
    ARE_YOU_ALONE = "gale_sfx/battle/typhon_phantom/talk_text2/areyoualone",
    ANSWER_ME = "gale_sfx/battle/typhon_phantom/talk_text/answer_me",
    GET_AWAY_FROME_ME = "gale_sfx/battle/typhon_phantom/talk_text/get_away_from_me",
    ARE_YOU_ANGRY = "gale_sfx/battle/typhon_phantom/talk_text2/areyouangry",
    YOU_SEEMS_FRUSTRATED = "gale_sfx/battle/typhon_phantom/talk_text2/youseemfrustrated",

    ITS_GONE = "gale_sfx/battle/typhon_phantom/talk_text/its_gone",
    IT_WAS_JUST_HERE = "gale_sfx/battle/typhon_phantom/talk_text2/itwasjusthere",
    ITS_VANISHED = "gale_sfx/battle/typhon_phantom/talk_text2/vanished",
    I_DIDNT_FIND_ANYTHING = "gale_sfx/battle/typhon_phantom/talk_text2/ididntfindanything",

    I_MUST_HAVE_LOSING_MY_MIND = "gale_sfx/battle/typhon_phantom/talk_text2/imustbelosingmymind",
    SOME_KIND_OF_BAD_DREAM = "gale_sfx/battle/typhon_phantom/talk_text2/thisissomekindofbadd",
    WAS_THAT_REALLY_YOU = "gale_sfx/battle/typhon_phantom/talk_text2/wasthatreallyyou",
    WHERE_DO_YOU_SUPPOSE = "gale_sfx/battle/typhon_phantom/talk_text2/wheredoyousupposethe",
    YOU_HALF_WAKE = "gale_sfx/battle/typhon_phantom/talk_text2/youeverbeenhalfawake",
    DID_WE_MAKE_THAT = "gale_sfx/battle/typhon_phantom/talk_text2/didwemakethatinoneof",
    BREATHING = "gale_sfx/battle/typhon_phantom/talk_text2/breathing",

    ASK_ATHETOS = "gale_sfx/battle/typhon_phantom/talk_random",
    I_CAN_XXX_UNDERSTAND_US = "gale_sfx/battle/typhon_phantom/talk_text/i_can_xxx_they_to_understand_us",
    EVEN_IF_WE_DEAD = "gale_sfx/battle/typhon_phantom/talk_text2/evenifweredeaditwont",
    I_USED_TO_WISH = "gale_sfx/battle/typhon_phantom/talk_text2/iusedtowishwewerenta",
    I_HAVE_BEING_WATCHING_THEM = "gale_sfx/battle/typhon_phantom/talk_text2/ivebeenwatchingthemf",
    THEY_CAN_BE_ANYTHING = "gale_sfx/battle/typhon_phantom/talk_text2/theycouldbeanythinga",
    THEY_WANT_TO_LIVE_INSIDE = "gale_sfx/battle/typhon_phantom/talk_text2/theywanttoliveinside",
    THE_SHAPE_IN_THE_GLASS = "gale_sfx/battle/typhon_phantom/talk_text2/whatdoesitlookliketh",
    WAHT_DO_YOU_SEE_IN_THE_GLASS = "gale_sfx/battle/typhon_phantom/talk_text2/whatdoyouseeinthegla",
}


local function SayAndPlaySound(inst, text, sound_index)
    if sound_index == false then

    elseif sound_index == nil or sound_index_map[sound_index] == nil then
        inst.SoundEmitter:PlaySound(inst.sounds.talk_random)
    else
        inst.SoundEmitter:PlaySound(sound_index_map[sound_index])
    end

    if text then
        inst.components.talker:Say(text)
    end
end

local function GetUpperBody(inst)
    return inst._upper_body:value()
end

local function CommonClientFn(inst)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1.5, .75)

    MakeCharacterPhysics(inst, 50, .5)

    local s = 1.3
    inst.Transform:SetScale(s, s, s)
    inst.Transform:SetFourFaced()

    inst.AnimState:AddOverrideBuild("player_pistol")
    inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")
    inst.AnimState:AddOverrideBuild("gale_phantom_add")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")

    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    inst._upper_body = net_entity(inst.GUID, "inst._upper_body")

    inst.GetUpperBody = GetUpperBody

    inst:AddComponent("talker")
    -- inst.components.talker.fontsize = 33
    -- inst.components.talker.font = TALKINGFONT
    -- inst.components.talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
end

local function CanTarget(inst, target)
    local leader = inst.components.follower:GetLeader()

    -- Should not attack shadow creatures,unless they attack me
    return inst.components.combat:CanTarget(target)
        and target ~= leader
        and (not GaleCommon.IsShadowCreature(target) or inst.components.combat:TargetIs(target)
            or (target.components.combat and target.components.combat:TargetIs(inst)))
end

local function OnBeenInspected(inst, viewer)
    if inst.sg:HasStateTag("spawn") then
        return
    end

    if not inst.components.combat:HasTarget()
        and inst.alert_target == nil
        and inst.components.combat:CanTarget(viewer)
        and inst:IsNear(viewer, 33) then
        inst.alert_target = viewer
        inst.alert_target_pos = viewer:GetPosition()

        local textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.ALERT)
        inst:SayAndPlaySound(textstr, textkey)
        -- inst.components.talker:Say(textstr)
        -- inst.SoundEmitter:PlaySound(inst.sounds.talk_random)

        -- inst.SoundEmitter:PlaySound(inst.sounds.alert)

        local x, y, z = inst:GetPosition():Get()
        for _, v in pairs(FindPlayersInRange(x, y, z, 33, true)) do
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["play_clientside_sound"], v.userid, inst.sounds.alert)
        end
    end
end

local function AlertNearbyPlayer(inst)
    if inst.sg:HasStateTag("spawn") then
        return
    end

    if inst.components.combat:HasTarget()
        or GetTime() - (inst.last_droptarget_time or 0) < 10 then
        inst.alert_target = nil
        inst.alert_target_pos = nil
        return
    end


    if inst.alert_target then
        if inst.components.combat:CanTarget(inst.alert_target)
            and inst:IsNear(inst.alert_target, 33) then
            inst.alert_target_pos = inst.alert_target:GetPosition()
        else
            inst.alert_target = nil
            inst.alert_target_pos = nil
        end
    else
        for k, v in pairs(AllPlayers) do
            if inst.components.combat:CanTarget(v)
                and inst:IsNear(v, 25)
                and Vector3(v.Physics:GetVelocity()):Length() > 4.1 then
                inst.alert_target = v
                inst.alert_target_pos = inst.alert_target:GetPosition()

                local textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.ALERT)
                inst:SayAndPlaySound(textstr, textkey)
                -- inst.components.talker:Say(textstr)
                -- inst.SoundEmitter:PlaySound(inst.sounds.talk_random)

                -- inst.SoundEmitter:PlaySound(inst.sounds.alert)
                local x, y, z = inst:GetPosition():Get()
                for _, v in pairs(FindPlayersInRange(x, y, z, 33, true)) do
                    SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["play_clientside_sound"], v.userid, inst.sounds.alert)
                end

                break
            end
        end
    end
end

local function SelectTargetFnPhantom(inst)
    if inst.sg:HasStateTag("spawn") then
        return
    end

    local leader = inst.components.follower:GetLeader()
    local leader_target = leader and leader.components.combat and leader.components.combat.target

    if leader_target then
        return leader_target
    end


    return FindEntity(inst, 12,
                      function(guy)
                          return inst:CanTarget(guy)
                      end,
                      { "_combat", "_health" },
                      { "INLIMBO" },
                      { "character", "lunar_aligned", "largecreature" }
    )
end

local function KeepTargetFnPhantom(inst, target)
    local leader = inst.components.follower:GetLeader()

    return inst.components.combat:CanTarget(target)
        and (leader == nil or leader:IsNear(inst, 15))
        and inst:IsNear(target, 47)
end

local function OnAttackedPhantom(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    local leader = inst.components.follower:GetLeader()

    if attacker ~= nil and attacker ~= leader then
        inst.components.combat:SetTarget(attacker)
    end
end

local function OnNewTarget(inst, data)
    if inst.last_talk_new_target_time and GetTime() - inst.last_talk_new_target_time < 12 then
        return
    end

    if data.target and data.target == inst.alert_target then
        -- inst.SoundEmitter:PlaySound(inst.sounds.findtarget)
        local x, y, z = inst:GetPosition():Get()
        for _, v in pairs(FindPlayersInRange(x, y, z, 33, true)) do
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["play_clientside_sound"], v.userid, inst.sounds.findtarget)
        end
    end


    local textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.NEW_TARGET)
    inst:SayAndPlaySound(textstr, textkey)
    -- inst.components.talker:Say(textstr)
    -- inst.SoundEmitter:PlaySound(inst.sounds.talk_high_random)

    inst.last_talk_new_target_time = GetTime()
end

local function OnDropTarget(inst, data)
    inst.last_droptarget_time = GetTime()

    inst:EnableUpperBody(false)

    local textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.LOSE_TARGET)
    inst:SayAndPlaySound(textstr, textkey)
    -- inst.components.talker:Say(textstr)
    -- inst.SoundEmitter:PlaySound(inst.sounds.talk_random)
end

local upperbody_symbols = {
    "arm_lower",
    "arm_upper",
    "cheeks",
    "face",
    "hand",
    "headbase",
    "torso",
}
local function EnableUpperBody(inst, enable)
    local ent = inst._upper_body:value()
    if enable and ent == nil then
        ent = inst:SpawnChild("typhon_phantom_upperbody")
        inst._upper_body:set(ent)
        ent.entity:AddFollower()
        ent.Follower:FollowSymbol(inst.GUID, "torso", 0, 53, 0, nil, true)
        inst.spike_vfx.Follower:FollowSymbol(ent.GUID, "swap_body", 0, -40, 0)
        for _, v in pairs(upperbody_symbols) do
            inst.AnimState:SetSymbolMultColour(v, 0, 0, 0, 0)
        end
    elseif not enable and ent ~= nil then
        inst._upper_body:set(nil)
        ent:Remove()
        for _, v in pairs(upperbody_symbols) do
            inst.AnimState:SetSymbolMultColour(v, 1, 1, 1, 1)
        end
        inst.spike_vfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, -40, 0)
    end

    return ent
end


-- local function SuitZombieBank(inst)
--     if inst.sg:HasStateTag("moving")
--         or inst.sg.currentstate.name == "walk_pst"
--         or inst.sg.currentstate.name == "run_pst" then
--         inst.AnimState:SetBank("typhon_phantom_actions")
--     else
--         inst.AnimState:SetBank("wilson")
--     end
-- end

local function CommonServerFn(inst)
    inst.CanTarget = CanTarget
    inst.SayAndPlaySound = SayAndPlaySound

    inst:AddComponent("planarentity")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 6
    inst.components.locomotor:SetAllowPlatformHopping(true) -- boat hopping setup

    inst:AddComponent("embarker")

    inst:AddComponent("health")

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = 0.5

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("typhon_phantom")

    inst:AddComponent("named")

    inst:AddComponent("sanityaura")
    -- inst.components.sanityaura.aurafn = CalcSanityAura
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("areaaware")

    -- 需要消耗灵能
    inst:AddComponent("gale_magic")


    inst.spike_vfx = inst:SpawnChild("typhon_phantom_spike_vfx")
    inst.spike_vfx.entity:AddFollower()
    inst.spike_vfx.Follower:FollowSymbol(inst.GUID, "swap_body", 0, -40, 0)

    inst.sounds = {
        whip = "gale_sfx/battle/typhon_phantom/whip",
        step = "gale_sfx/battle/typhon_phantom/step",
        launch_pre = "gale_sfx/battle/typhon_phantom/launch_pre",
        -- launch_pre = "gale_sfx/skill/launch_pre",
        launch = "gale_sfx/skill/launch2",
        evade = "gale_sfx/skill/hero_shade_dash_1",
        talk_random = "gale_sfx/battle/typhon_phantom/talk_random",
        talk_long_random = "gale_sfx/battle/typhon_phantom/talk_long_random",
        talk_high_random = "gale_sfx/battle/typhon_phantom/talk_high_random",
        death = "gale_sfx/battle/typhon_phantom/talk_high_random",

        alert = "gale_sfx/battle/typhon_phantom/alert",
        findtarget = "gale_sfx/battle/typhon_phantom/findtarget",
    }
end

local function UpperBodyFacePoint(inst, pos)
    local parent = inst.entity:GetParent()
    -- parent.AnimState:MakeFacingDirty()
    local dir1 = parent:GetAngleToPoint(pos)

    inst.Transform:SetRotation(dir1 - parent.Transform:GetRotation())
end

local function CheckEmergencyEvade(inst)
    if inst.sg:HasStateTag("busy") or IsEntityDead(inst, true) then
        return
    end

    if not inst.components.gale_magic:CanUseMagic(1) then
        return false
    end

    -- if inst.sg:HasStateTag("evade")
    --     or inst.sg:HasStateTag("spawn")
    --     or inst.sg:HasStateTag("kinetic_blast")
    --     or IsEntityDead(inst, true) then
    --     return
    -- end

    if (inst.last_evade_time and GetTime() - inst.last_evade_time < 6)
        and (inst.components.combat.lastwasattackedtime and GetTime() - inst.components.combat.lastwasattackedtime > 0.33) then
        return
    end

    local hositile = FindEntity(
        inst,
        4,
        function(guy)
            return (
                    guy.components.combat
                    and (guy.components.combat:TargetIs(inst) or inst.components.combat:TargetIs(guy))
                    and guy.sg
                    and (
                        guy.sg:HasStateTag("attack")
                        or
                        (
                            guy.sg:HasStateTag("charging_attack")
                            and guy.sg:GetTimeInState() <= 1
                        )
                    )
                    and inst:IsNear(guy, guy.components.combat.hitrange + 1)
                )
                or (
                    guy.components.projectile
                    and guy.components.projectile.target == inst
                ) or (
                    guy.components.complexprojectile
                    and guy.components.complexprojectile.attacker == inst.components.combat.target
                ) or (
                    guy:HasTag("scarytophantom") or guy:HasTag("scarytotyphon")
                )
        end,
        nil,
        { "INLIMBO" }
    )


    if hositile then
        if hositile.components.combat then
            inst.components.combat:SuggestTarget(hositile)
        end

        local hositile_pos = hositile:GetPosition()
        local possible_evade_pos = {}

        -- If see projectile,evade verticle
        if hositile:HasTag("projectile") then
            local vec = hositile_pos - inst:GetPosition()

            for i = 1, 360 do
                local cur_offset = Vector3(math.cos(i * DEGREES), 0, math.sin(i * DEGREES))
                local jia_angle = math.acos(cur_offset:Dot(vec) / (cur_offset:Length() * vec:Length()))
                if jia_angle > 180 * DEGREES then
                    jia_angle = jia_angle - 360 * DEGREES
                end
                if jia_angle < -180 * DEGREES then
                    jia_angle = jia_angle + 360 * DEGREES
                end -- control to [-180 * DEGREES,180 * DEGREES]

                if math.abs(jia_angle) >= 60 * DEGREES and math.abs(jia_angle) <= 120 * DEGREES then
                    table.insert(possible_evade_pos, inst:GetPosition() + cur_offset * 5)
                end
            end
        elseif hositile.components.combat then
            -- If attacker is ranged attacker
            if hositile.components.combat.hitrange >= 4 and inst:IsNear(hositile, inst.components.combat.hitrange + 1) then
                --  If ready to melee attack,might dash to nearby
                if not inst.components.combat:InCooldown() then
                    local offset = FindWalkableOffset(hositile_pos, math.random() * PI * 2, hositile:GetPhysicsRadius(),
                                                      10,
                                                      nil, false, nil, false, true)
                    table.insert(possible_evade_pos, hositile_pos + (offset or Vector3(0, 0, 0)))
                end
            end

            -- Evade away
            local offset = FindWalkableOffset(inst:GetPosition(), math.random() * PI * 2, GetRandomMinMax(5, 10), 33,
                                              nil, false, nil, false, true)
            table.insert(possible_evade_pos, inst:GetPosition() + (offset or Vector3(0, 0, 0)))
        end

        if #possible_evade_pos > 0 then
            local evade_pos = GetRandomItem(possible_evade_pos)

            local speed = 25
            local timeout = math.clamp((evade_pos - inst:GetPosition()):Length() / speed, 0, 0.66)
            inst.sg:GoToState("evade", {
                target_pos = evade_pos,
                attack_target = hositile.components.combat and hositile,
                timeout = timeout,
            })
            inst.last_evade_time = GetTime()
        end
    end
end

local function DoRandomIdleChat(inst)
    local function InterfaceFn(inst)
        if not IsEntityDead(inst, true)
            and not inst.sg:HasStateTag("busy") then
            local textkey, textstr
            if inst.components.combat:HasTarget() then
                textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.NEW_TARGET)
            else
                textkey, textstr = GetRandomItemWithIndex(STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM.IDLE)
            end
            inst:SayAndPlaySound(textstr, textkey)
            -- inst.components.talker:Say(textstr)
            -- inst.SoundEmitter:PlaySound(inst.sounds.talk_random)
        end
        DoRandomIdleChat(inst)
    end

    if inst.random_chat_task then
        inst.random_chat_task:Cancel()
        inst.random_chat_task = nil
    end

    inst.random_chat_task = inst:DoTaskInTime(GetRandomMinMax(8, 16), InterfaceFn)
end

local function OnTalk(inst, data)
    for k, v in pairs(AllPlayers) do
        if inst:IsNear(v, 45) then
            SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce_advance"], v.userid, ChatTypes.Message,
                               inst:GetDisplayName(), data.message, 1, 1, 1, 1, "profileflair")
        end
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "typhon_phantom",

        assets = {
            Asset("ANIM", "anim/typhon_phantom_actions_move.zip"),
            Asset("ANIM", "anim/wilton.zip"),
        },

        bank = "wilson",
        build = "wilton",
        anim = "idle",

        tags = { "typhon", "shadow_aligned", "monster", "hositile", "scarytoprey", "character" },

        clientfn = function(inst)
            CommonClientFn(inst)

            inst.AnimState:SetMultColour(0, 0, 0, 1)

            -- Add eyes
            if not TheNet:IsDedicated() then
                inst._flame1 = inst:SpawnChild("gale_phantom_eyes_vfx")
                inst._flame2 = inst:SpawnChild("gale_phantom_eyes_vfx")

                inst._flame1.entity:AddFollower()
                inst._flame2.entity:AddFollower()

                inst._flame1.Follower:FollowSymbol(inst.GUID, "headbase", 0, 0, 0)
                inst._flame2.Follower:FollowSymbol(inst.GUID, "headbase", 0, 0, 0)

                inst:DoPeriodicTask(0, function()
                    local emit_ent = inst:GetUpperBody() or inst
                    local face = emit_ent.Transform:GetFacing()

                    if IsEntityDead(inst, true) then
                        -- inst._flame1.Follower:FollowSymbol(inst.GUID,"headbase",-35,-45,0.1)
                        -- inst._flame2.Follower:FollowSymbol(inst.GUID,"headbase",35,-45,0.1)

                        inst._flame1.should_emit = false
                        inst._flame2.should_emit = false
                    elseif inst:HasTag("attacked") then
                        inst._flame1.Follower:FollowSymbol(inst.GUID, "headbase", 30, -90, 0.1)
                        inst._flame2.Follower:FollowSymbol(inst.GUID, "headbase", -30, -90, 0.1)

                        inst._flame1.should_emit = true
                        inst._flame2.should_emit = true
                    elseif inst.AnimState:IsCurrentAnimation("amulet_rebirth") then
                        inst._flame1.should_emit = false
                        inst._flame2.should_emit = false
                    else
                        if face == 3 then
                            inst._flame1.Follower:FollowSymbol(emit_ent.GUID, "headbase", 30, -90, 0.1, true)
                            inst._flame2.Follower:FollowSymbol(emit_ent.GUID, "headbase", -30, -90, 0.1, true)

                            inst._flame1.should_emit = true
                            inst._flame2.should_emit = true
                        elseif face == 0 or face == 2 then
                            inst._flame1.Follower:FollowSymbol(emit_ent.GUID, "headbase", 0, -90, 0.1, true)
                            inst._flame1.should_emit = true
                            inst._flame2.should_emit = false
                        elseif face == 1 then
                            inst._flame1.should_emit = false
                            inst._flame2.should_emit = false
                        else
                            inst._flame1.should_emit = false
                            inst._flame2.should_emit = false
                        end
                    end
                end)
            end
        end,

        serverfn = function(inst)
            CommonServerFn(inst)
            inst.EnableUpperBody = EnableUpperBody
            -- inst.EnableKineticBlastTask = EnableKineticBlastTask

            inst.components.inspectable.descriptionfn = OnBeenInspected

            inst.components.talker.ontalkfn = OnTalk



            inst.components.health:SetMaxHealth(250)

            inst.components.combat:SetRange(1.5)
            inst.components.combat:SetDefaultDamage(68)
            inst.components.combat:SetAttackPeriod(10)
            inst.components.combat:SetRetargetFunction(1, SelectTargetFnPhantom)
            inst.components.combat:SetKeepTargetFunction(KeepTargetFnPhantom)

            inst:SetStateGraph("SGtyphon_phantom")

            local brain = require("brains/typhon_phantom_brain")
            inst:SetBrain(brain)

            inst:ListenForEvent("attacked", OnAttackedPhantom)
            inst:ListenForEvent("newcombattarget", OnNewTarget)
            inst:ListenForEvent("droppedtarget", OnDropTarget)
            -- inst:ListenForEvent("newstate", SuitZombieBank)

            inst:DoPeriodicTask(0, CheckEmergencyEvade)
            inst:DoPeriodicTask(3, AlertNearbyPlayer)
            DoRandomIdleChat(inst)
        end
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "typhon_phantom_upperbody",

        assets = {
            Asset("ANIM", "anim/typhon_phantom_actions_move.zip"),
            Asset("ANIM", "anim/wilton.zip"),
        },

        bank = "wilson",
        build = "wilton",
        anim = "idle",

        tags = {},

        persists = false,

        clientfn = function(inst)
            inst.AnimState:SetMultColour(0, 0, 0, 1)

            inst.AnimState:HideSymbol("foot")
            inst.AnimState:HideSymbol("leg")
            inst.Transform:SetFourFaced()

            -- inst.AnimState:AddOverrideBuild("player_pistol")
            inst.AnimState:AddOverrideBuild("player_actions_roll")
            inst.AnimState:AddOverrideBuild("player_lunge")
            inst.AnimState:AddOverrideBuild("player_attack_leap")
            inst.AnimState:AddOverrideBuild("player_superjump")
            inst.AnimState:AddOverrideBuild("player_multithrust")
            inst.AnimState:AddOverrideBuild("player_parryblock")
            inst.AnimState:AddOverrideBuild("gale_phantom_add")

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            inst.AnimState:Show("HEAD")
            inst.AnimState:Hide("HEAD_HAT")
        end,

        serverfn = function(inst)
            inst:SetStateGraph("SGtyphon_phantom")
            inst.UpperBodyFacePoint = UpperBodyFacePoint
        end,
    })
