local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")
local GaleCondition = require("util/gale_conditions")

local function PickNewName(inst)
    inst.name2 = inst.name2 or GetRandomItem(STRINGS.NAMES.GALE_NAMEPOOL.MECH_SPECIAL)
    local name = string.format("%s%s", STRINGS.NAMES.ATHETOS_OPERATOR_MEDICAL, inst.name2)
    if inst.corrupt then
        name = name .. STRINGS.NAMES.ATHETOS_OPERATOR_CORRUPT
    end

    inst.components.named:SetName(name)
end

local function OnSave(inst, data)
    data.name2 = inst.name2
    data.corrupt = inst.corrupt
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.name2 ~= nil then
            inst.name2 = data.name2
        end
        if data.corrupt ~= nil then
            inst.corrupt = data.corrupt
        end
    end
end

SetSharedLootTable("athetos_operator_medical",
                   {
                       { 'athetos_medkit_big_operator', 1.00 },
                       { 'trinket_6',                   1.00 },
                       { 'trinket_6',                   0.55 },
                       { 'gears',                       0.25 },
                   })

SetSharedLootTable("athetos_operator_medical_broken",
                   {
                       { 'athetos_medkit_big_operator', 1.00 },
                       { 'trinket_6',                   0.66 },
                       { 'trinket_6',                   0.20 },
                       { 'gears',                       0.05 },
                   })

local sound_index_map = {
    HELLO = "gale_sfx/battle/athetos_operator_medical/talk_text/hello",
    ARE_YOU_FEELING = "gale_sfx/battle/athetos_operator_medical/talk_text/areyoufeelingwell",
    NICE_TO_SEE = "gale_sfx/battle/athetos_operator_medical/talk_text/nicetoseeyou",
    WELCOME = "gale_sfx/battle/athetos_operator_medical/talk_text/welcomemaybeicanhelp",
    APPOINTMENT = "gale_sfx/battle/athetos_operator_medical/talk_text/areyouhereforanappoi",
    SEE_YOU_AGAIN = "gale_sfx/battle/athetos_operator_medical/talk_text/goodtoseeyouagaindry",
    PYRAMID = "gale_sfx/battle/athetos_operator_medical/talk_text/imaquotpyramidquot49",

    MEDICAL_JOKES = "gale_sfx/battle/athetos_operator_medical/talk_text/ihaveafewmedicaljoke",
    IMPROVISE = "gale_sfx/battle/athetos_operator_medical/talk_text/withauthorizationica",
    PREVENTION = "gale_sfx/battle/athetos_operator_medical/talk_text/youknowthesayinganou",
    NUTRITION = "gale_sfx/battle/athetos_operator_medical/talk_text/ihopeyourepracticing",
    POMEGRANATE = "gale_sfx/battle/athetos_operator_medical/talk_text/haveyoutriedaskyking",
    BRAIN_USELESS = "gale_sfx/battle/athetos_operator_medical/talk_text/didyouknowancientegy",
    PREVENTION2 = "gale_sfx/battle/athetos_operator_medical/talk_text/mostphysicaltraumais",
    HEART_THINK = "gale_sfx/battle/athetos_operator_medical/talk_text/aristotlebelievedthe",
    HUMAN_CRY = "gale_sfx/battle/athetos_operator_medical/talk_text/humansseemtobetheonl",
    BRAIN_BULB = "gale_sfx/battle/athetos_operator_medical/talk_text/yourbraingeneratesab",
    MUMIES = "gale_sfx/battle/athetos_operator_medical/talk_text/didyouknowthathumanm",
    MOUTH_BRAIN = "gale_sfx/battle/athetos_operator_medical/talk_text/symptomsoffootinmout",
    BLOOD_SUPPLY = "gale_sfx/battle/athetos_operator_medical/talk_text/didyouknowthehumanbo",
    TRIAL_AND_ERROR = "gale_sfx/battle/athetos_operator_medical/talk_text/improgrammedtooptimi",
    ANATOMY = "gale_sfx/battle/athetos_operator_medical/talk_text/allofmyanatomyandpro",
    ABOUT_EQUIP = "gale_sfx/battle/athetos_operator_medical/talk_text/imequippedtohandleov",

    WHOOPS = "gale_sfx/battle/athetos_operator_medical/talk_text/whoops",
    PARDON_ME = "gale_sfx/battle/athetos_operator_medical/talk_text/pardonme",
    MY_MISTAKE = "gale_sfx/battle/athetos_operator_medical/talk_text/mymistake",
    DIDNT_SEE_YOU = "gale_sfx/battle/athetos_operator_medical/talk_text/ididntseeyouthere",

    DIAGNOSING = "gale_sfx/battle/athetos_operator_medical/talk_text/diagnosing",

    FRACTURE = "gale_sfx/battle/athetos_operator_medical/talk_text/itappearsyourfemurha",
    FRACTURE2 = "gale_sfx/battle/athetos_operator_medical/talk_text/scanshowsadistalradi",
    FRACTURE3 = "gale_sfx/battle/athetos_operator_medical/talk_text/ouchyourribsarecrack",
    FRACTURE4 = "gale_sfx/battle/athetos_operator_medical/talk_text/hmmtorusfractureleft",

    RADIATION = "gale_sfx/battle/athetos_operator_medical/talk_text/youresufferingfromra",
    RADIATION2 = "gale_sfx/battle/athetos_operator_medical/talk_text/radiationtoxicitycon",
    RADIATION3 = "gale_sfx/battle/athetos_operator_medical/talk_text/ohmyacuteradiationsy",

    BLEED = "gale_sfx/battle/athetos_operator_medical/talk_text/imseeingirregularlac",
    BLEED2 = "gale_sfx/battle/athetos_operator_medical/talk_text/splitandstretchlacer",
    BLEED3 = "gale_sfx/battle/athetos_operator_medical/talk_text/hmmmultipletearsandp",

    BURN = "gale_sfx/battle/athetos_operator_medical/talk_text/hmmfullthicknessburn",
    BURN2 = "gale_sfx/battle/athetos_operator_medical/talk_text/imseeingepidermaland",
    BURN3 = "gale_sfx/battle/athetos_operator_medical/talk_text/thirddegreeburnsperf",

    CONCUSSION = "gale_sfx/battle/athetos_operator_medical/talk_text/disturbedvisionbruis",
    CONCUSSION2 = "gale_sfx/battle/athetos_operator_medical/talk_text/iseewhatsgoingonyouv",
    CONCUSSION3 = "gale_sfx/battle/athetos_operator_medical/talk_text/scanshowscranialhemo",

    DIAG_RESULT_MANY_TRAUMA = "gale_sfx/battle/athetos_operator_medical/talk_text/youhavemorethanonese",

    ROUGH_DAY = "gale_sfx/battle/athetos_operator_medical/talk_text/lookslikeyouvehadaro",
    COMMON_ISSUE = "gale_sfx/battle/athetos_operator_medical/talk_text/bruisingabrasionsfat",
    SUPERFICIAL = "gale_sfx/battle/athetos_operator_medical/talk_text/superficialinjuriesn",

    HOLD_STILL = "gale_sfx/battle/athetos_operator_medical/talk_text/pleaseholdstillthisw",
    TRY_TO_RELAX = "gale_sfx/battle/athetos_operator_medical/talk_text/trytorelax",
    BETTER_SOON = "gale_sfx/battle/athetos_operator_medical/talk_text/illhaveyoufeelingbet",
    WONT_TAKE_LONG = "gale_sfx/battle/athetos_operator_medical/talk_text/thiswonttakelong",
    ALL_BETTER = "gale_sfx/battle/athetos_operator_medical/talk_text/thereallbetter",
    GOOD_AS_NEW = "gale_sfx/battle/athetos_operator_medical/talk_text/goodasnew",
    ALL_DONE = "gale_sfx/battle/athetos_operator_medical/talk_text/alldone",

    FULLFILL_QUESTIONNAIRE = "gale_sfx/battle/athetos_operator_medical/talk_text/pleasefilloutapatien",
    FULLFILL_QUESTIONNAIRE2 = "gale_sfx/battle/athetos_operator_medical/talk_text/dontforgettocomplete",
    FULLFILL_QUESTIONNAIRE3 = "gale_sfx/battle/athetos_operator_medical/talk_text/youcanfilloutaservic",

    BIG_BANG_CANDY = "gale_sfx/battle/athetos_operator_medical/talk_text/caniofferyouabigbang",

    MY_FAULT = "gale_sfx/battle/athetos_operator_medical/talk_text/imsurethatwasmyfault",
    INTEND_TO_DAMAGE = "gale_sfx/battle/athetos_operator_medical/talk_text/didyouintendtodamage",
    PLEASE_DONT_HARM = "gale_sfx/battle/athetos_operator_medical/talk_text/pleasedontharmme",
    REPAIR_SOON = "gale_sfx/battle/athetos_operator_medical/talk_text/illneedrepairssoon",
    IS_THAT_FUNNY = "gale_sfx/battle/athetos_operator_medical/talk_text/wasthatfunny",

    NO_TRAUMA = "gale_sfx/battle/athetos_operator_medical/talk_text/notraumaorillnessesd",
    -- MEDICAL_TRAVIA = "gale_sfx/battle/athetos_operator_medical/talk_text/",

    CANT_DIAG_CD = "gale_sfx/battle/athetos_operator_medical/talk_text/sorryicannotdiagnose",
    CANT_DIAG_ENV = "gale_sfx/battle/athetos_operator_medical/talk_text/conditionisnotsuitab",
    CANT_DIAG_PSY = "gale_sfx/battle/athetos_operator_medical/talk_text/imafraidicanttreatps",

    SYSTEM_ALERT = "gale_sfx/battle/athetos_operator_medical/talk_text/systemalertrepairsne",
    ALL_SYSTEM_OPERATIONAL = "gale_sfx/battle/athetos_operator_medical/talk_text/allsystemsoperationa",
}

local function DoTalk(inst, dtype, talk_target)
    local tab = STRINGS.GALE_CHATTYNODES.ATHETOS_OPERATOR_MEDICAL[dtype]
    local line_time = 3

    if type(tab) == "string" then
        line_time = Remap(math.clamp(#tab, 30, 150), 30, 150, 3, 8)
        inst.components.talker:Say(tab, line_time)

        if inst.SoundEmitter:PlayingSound("talking") then
            inst.SoundEmitter:KillSound("talking")
        end
        inst.SoundEmitter:PlaySound(sound_index_map[dtype], "talking")
        inst.last_talk_time = GetTime()

        return dtype
    elseif type(tab) == "table" then
        local index, text = GetRandomItemWithIndex(tab)
        line_time = Remap(math.clamp(#text, 30, 150), 30, 150, 3, 8)

        if index == "SEE_YOU_AGAIN" then
            inst.components.talker:Say(text:format(
                                           talk_target and talk_target:GetDisplayName() or ""
                                       ), line_time)
        else
            inst.components.talker:Say(text, line_time)
        end

        if inst.SoundEmitter:PlayingSound("talking") then
            inst.SoundEmitter:KillSound("talking")
        end
        inst.SoundEmitter:PlaySound(sound_index_map[index], "talking")
        inst.last_talk_time = GetTime()

        return index
    end
end

local function DoRandomIdleSound(inst)
    local function InterfaceFn(inst)
        if not IsEntityDead(inst, true) then
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
        end
        DoRandomIdleSound(inst)
    end

    if inst.random_noise_task then
        inst.random_noise_task:Cancel()
        inst.random_noise_task = nil
    end

    inst.random_noise_task = inst:DoTaskInTime(GetRandomMinMax(4, 8), InterfaceFn)
end

local function CommonClientFn(inst)
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()

    inst.DynamicShadow:SetSize(1, 0.6)

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(252 / 255, 251 / 255, 237 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(0.33)
    inst.Light:Enable(true)



    local s = 1.5
    inst.Transform:SetScale(s, s, s)
    inst.Transform:SetEightFaced()

    MakeCharacterPhysics(inst, 25, 0.7)
    -- MakeGhostPhysics(inst, 25, 0.7)
    -- MakeFlyingCharacterPhysics(inst, 25, 0.7)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)


    inst:AddComponent("talker")
    inst.components.talker.offset = Vector3(0, -300, 0)
    inst.components.talker:MakeChatter()
end

local function CommonServerFn(inst)
    inst.name2 = nil
    inst.corrupt = false
    inst.last_talk_time = 0
    inst.DoTalk = DoTalk

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("athetos_operator_medical")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 4

    inst:AddComponent("combat")

    inst:AddComponent("named")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(175)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad


    inst.sounds = {
        idle = "gale_sfx/battle/athetos_operator_medical/beepingwhirring",
        hit = "gale_sfx/battle/hit_metal",
        healing_success = "gale_sfx/battle/athetos_operator_medical/heal_success",
        scan = "gale_sfx/battle/athetos_operator_medical/scan",
        death = "gale_sfx/battle/athetos_operator_medical/before_death",
    }

    inst:DoTaskInTime(0, function()
        if inst.name2 == nil then
            PickNewName(inst)
        end
    end)

    GaleCondition.AddCondition(inst, "condition_metallic")
    DoRandomIdleSound(inst)
end


local function OnInteractMedical(inst, doer)
    if inst.corrupt then
        inst.components.combat:SuggestTarget(doer)
    else
        if not IsEntityDead(inst) and
            (not inst.sg:HasStateTag("busy") or inst.sg.currentstate.name == "greeting") then
            local index, can_handle = inst:GetDiagResultIndex(doer)

            if index ~= "NO_TRAUMA" and inst.components.timer:TimerExists("heal_cd") then
                inst:DoTalk("CANT_DIAG_CD")
                inst:ForceFacePoint(doer:GetPosition())
            elseif index == "NO_TRAUMA" and inst.healed_players[doer] == true then
                inst.sg:GoToState("chat", { target = doer })
            else
                inst.sg:GoToState("scanandheal", doer)
            end
        end
    end
end

local bad_condition_map = {
    condition_bleed = "DIAG_RESULT_BLEED",
    condition_impair = "DIAG_RESULT_FRACTURE",
}

local function GetDiagResultIndex(inst, doer)
    local index = nil
    local can_handle = true

    if doer.components.health:IsHurt() and not doer.components.oldager then
        index = "DIAG_RESULT_COMMON"
    end

    local bad_condition_count = 0

    for k, v in pairs(bad_condition_map) do
        if GaleCondition.GetCondition(doer, k) then
            index = v
            bad_condition_count = bad_condition_count + 1
        end
    end

    -- if doer.components.takingfiredamage then
    if (doer.components.health and doer.components.health.takingfiredamage)
        or (doer.components.burnable and doer.components.burnable:IsBurning())
        or (doer.components.temperature and doer.components.temperature:GetCurrent() > TUNING.OVERHEAT_TEMP - 10) then
        index = "DIAG_RESULT_BURN"
        bad_condition_count = bad_condition_count + 1
    end

    if bad_condition_count > 1 then
        index = "DIAG_RESULT_MANY_TRAUMA"
    end


    if index == nil then
        if doer.components.sanity and (doer.components.sanity:IsInsane() or doer.components.sanity:IsEnlightened()) then
            index = "CANT_DIAG_PSY"
            can_handle = false
        else
            index = "NO_TRAUMA"
            can_handle = false
        end
    end

    return index, can_handle
end

local function DoHeal(inst, doer)
    if not IsEntityDeadOrGhost(doer, true) then
        doer.components.health:DoDelta(doer.components.health.maxhealth,
                                       nil,
                                       inst.prefab,
                                       nil,
                                       inst)

        for k, _ in pairs(bad_condition_map) do
            if GaleCondition.GetCondition(doer, k) then
                GaleCondition.RemoveConditionAll(doer, k)
            end
        end

        if doer.components.burnable and doer.components.burnable:IsBurning() then
            doer.components.burnable:Extinguish()
        end

        if doer.components.temperature then
            doer.components.temperature:SetTemperature(TUNING.STARTING_TEMP)
        end

        if doer.components.moisture then
            doer.components.moisture:SetMoistureLevel(0)
        end
    end
end

local function OnPlayerNear(inst, player)
    if not inst.corrupt then
        if inst.greeting_players[player] ~= true then
            inst.greeting_players[player] = true

            if not inst.sg:HasStateTag("busy") and GetTime() - inst.last_talk_time > 6 then
                inst.sg:GoToState("greeting", {
                    target = player,
                })
            end
        end
    end
end

local function OnPlayerFar(inst, player)
    inst.greeting_players[player] = nil
    inst.healed_players[player] = nil
end

local function OnAttacked(inst, data)
    if not inst.corrupt then
        if data.attacker and data.attacker:HasTag("player") then
            if GetTime() - inst.last_talk_time > 5 then
                inst:ForceFacePoint(data.attacker:GetPosition())
                inst:DoTalk("ATTACKED_BY_PLAYER")
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------

local function OnBrokenHammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnAt("collapse_small", inst)
    fx:SetMaterial("metal")
    inst:Remove()
end

local function OnBrokenHit(inst, worker, workLeft)
    inst.AnimState:PlayAnimation("mine")
    inst.AnimState:PushAnimation("need_repair")
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
end

local function OnBrokenRepaired(inst)
    if inst.components.workable.workleft < inst.components.workable.maxwork then
        inst.SoundEmitter:PlaySound("dontstarve/common/chesspile_repair")
        inst.AnimState:PlayAnimation("mine")
        inst.AnimState:PushAnimation("need_repair")
    else
        inst.repaired = true

        inst.AnimState:PlayAnimation("mine")
        inst.AnimState:PushAnimation("need_repair")
        inst.SoundEmitter:PlaySound("dontstarve/common/chesspile_ressurect")
        if inst.SoundEmitter:PlayingSound("talking") then
            inst.SoundEmitter:KillSound("talking")
        end

        inst:DoTaskInTime(0.7, function()
            inst.Physics:SetCollides(false)
            SpawnAt("athetos_operator_medical", inst).sg:GoToState("repair_done")
            inst:Remove()
        end)
    end
end

return GaleEntity.CreateNormalEntity({
        prefabname = "athetos_operator_medical",
        assets = {
            Asset("ANIM", "anim/athetos_operator_medical.zip"),
        },

        bank = "athetos_operator_medical",
        build = "athetos_operator_medical",
        anim = "idle",
        loop_anim = true,

        tags = { "operator", "mech", "cattoyairborne" },


        clientfn = function(inst)
            CommonClientFn(inst)

            inst.AnimState:SetLightOverride(0.6)
        end,

        serverfn = function(inst)
            CommonServerFn(inst)

            inst.greeting_players = {}
            inst.healed_players = {}
            inst.GetDiagResultIndex = GetDiagResultIndex
            inst.DoHeal = DoHeal

            inst:AddComponent("timer")

            inst:AddComponent("cattoy")

            inst:AddComponent("gale_talkable")
            inst.components.gale_talkable.interactfn = OnInteractMedical

            inst:AddComponent("playerprox")
            inst.components.playerprox:SetDist(6, 20)
            inst.components.playerprox:SetPlayerAliveMode(
                inst.components.playerprox.AliveModes.AliveOnly)
            inst.components.playerprox:SetTargetMode(
                inst.components.playerprox.TargetModes.AllPlayers)
            inst.components.playerprox.onnear = OnPlayerNear
            inst.components.playerprox.onfar = OnPlayerFar

            inst:SetStateGraph("SGathetos_operator_medical")

            local brain = require("brains/athetos_operator_medical_brain")
            inst:SetBrain(brain)

            inst:ListenForEvent("attacked", OnAttacked)
        end,
    }),
    GaleEntity.CreateNormalEntity({
        prefabname = "athetos_operator_medical_broken",
        assets = {
            Asset("ANIM", "anim/athetos_operator_medical.zip"),
        },

        bank = "athetos_operator_medical",
        build = "athetos_operator_medical",
        anim = "need_repair",

        tags = { "operator", "mech" },


        clientfn = function(inst)
            local s = 1.5
            inst.Transform:SetScale(s, s, s)

            MakeObstaclePhysics(inst, 0.4)

            inst.entity:AddDynamicShadow()

            inst.DynamicShadow:SetSize(3.5, 1)

            inst:SetPrefabNameOverride("athetos_operator_medical")

            inst:AddComponent("talker")
            inst.components.talker.offset = Vector3(0, -125, 0)
            inst.components.talker:MakeChatter()
        end,

        serverfn = function(inst)
            local MAXHITS = 6

            inst.DoTalk = DoTalk


            inst:AddComponent("inspectable")

            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetChanceLootTable("athetos_operator_medical_broken")

            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(MAXHITS / 2)
            inst.components.workable:SetMaxWork(MAXHITS)
            inst.components.workable:SetOnFinishCallback(OnBrokenHammered)
            inst.components.workable:SetOnWorkCallback(OnBrokenHit)

            inst:AddComponent("repairable")
            inst.components.repairable.repairmaterial = MATERIALS.GEARS
            inst.components.repairable.onrepaired = OnBrokenRepaired

            inst:DoPeriodicTask(15, function()
                local work_left = inst.components.workable.workleft
                if not inst.repaired and work_left > MAXHITS / 2 and inst.AnimState:IsCurrentAnimation("need_repair") then
                    inst.AnimState:PlayAnimation("need_repair_talk", true)
                    -- TODO:Say sth
                    inst:DoTalk("SYSTEM_ALERT")
                    inst:DoTaskInTime(4, function()
                        inst.AnimState:PlayAnimation("need_repair")
                    end)
                end
            end)
        end,
    })
