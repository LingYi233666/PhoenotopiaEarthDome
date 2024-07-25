require("util/vector4")

local function GetFaceVector(inst)
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)

    return Vector3(sinangle, 0, cosangle)
end

local function GetFaceAngle(inst, target)
    local myangle = inst:GetRotation()
    local faceguyangle = inst:GetAngleToPoint(target:GetPosition():Get())
    local deltaangle = math.abs(myangle - faceguyangle)
    if deltaangle > 180 then
        deltaangle = 360 - deltaangle
    end

    return deltaangle
end

local function LaunchItem(inst, launcher_or_lpos, basespeed)
    local x0, y0, z0 = 0, 0, 0

    if launcher_or_lpos.entity then
        x0, y0, z0 = launcher_or_lpos.Transform:GetWorldPosition()
    else
        x0, y0, z0 = launcher_or_lpos:Get()
    end

    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = 2 * PI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.components.inventoryitem:SetLanded(false, true)

    if not inst.components.inventoryitem.nobounce and inst.Physics ~= nil and inst.Physics:IsActive() then
        inst.components.inventoryitem:SetLanded(false, true)
    end
    inst.Physics:SetVel(cosa * speed, speed * 3 + math.random() * 2, sina * speed)
end

local function DoToss(inst, range)
    range = range or 0.7
    local x, y, z = inst.Transform:GetWorldPosition()
    local totoss = TheSim:FindEntities(x, 0, z, range, { "_inventoryitem" }, { "locomotor", "INLIMBO" })
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end

        LaunchItem(v, inst, 5)
    end
end

local function AoeForEach(inst, pos, radius, must_tag, no_tag, one_of_tag, applyfn, validfn)
    local ret_ents = {}
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, radius, must_tag, no_tag, one_of_tag)
    for k, v in pairs(ents) do
        if validfn(inst, v) then
            applyfn(inst, v)

            table.insert(ret_ents, v)
        end
    end

    return ret_ents
end

local function AoeGetAttacked(inst, pos, radius, get_dmg, validfn)
    pos = pos or inst:GetPosition()
    validfn = validfn or function(inst, other)
        return inst.components.combat and inst.components.combat:CanTarget(other) and
            not inst.components.combat:IsAlly(other)
    end

    local applyfn = function(inst, other)
        other.components.combat:GetAttacked(inst, FunctionOrValue(get_dmg, inst, other))
    end
    return AoeForEach(inst, pos, radius, nil, { "INLIMBO" }, { "_combat", "_health" }, applyfn, validfn)
end

local function AoeDoAttack(inst, pos, radius, aoe_data, validfn)
    pos = pos or inst:GetPosition()
    validfn = validfn or function(inst, other)
        return inst.components.combat and inst.components.combat:CanTarget(other) and
            not inst.components.combat:IsAlly(other)
    end

    aoe_data = aoe_data or {}

    local applyfn = function(inst, other)
        local weapon, projectile, stimuli, instancemult, ignorehitrange
        if type(aoe_data) == "function" then
            weapon, projectile, stimuli, instancemult, ignorehitrange = aoe_data(inst, other)
        else
            weapon, projectile, stimuli, instancemult, ignorehitrange = aoe_data.weapon, aoe_data.projectile,
                aoe_data.stimuli, aoe_data.instancemult, aoe_data.ignorehitrange
        end


        local old_ignorehitrange = inst.components.combat.ignorehitrange
        inst.components.combat.ignorehitrange = ignorehitrange
        inst.components.combat:DoAttack(other, weapon, projectile, stimuli, instancemult)
        inst.components.combat.ignorehitrange = old_ignorehitrange
    end
    return AoeForEach(inst, pos, radius, nil, { "INLIMBO" }, { "_combat", "_health" }, applyfn, validfn)
end

local function AoeDestroyWorkableStuff(inst, pos, radius, work_count, validfn)
    pos = pos or inst:GetPosition()
    validfn = validfn or function(inst, other)
        return other.components.workable ~= nil
            and other.components.workable:CanBeWorked()
            and other.components.workable.action ~= ACTIONS.NET
    end
    local applyfn = function(inst, other)
        local count = FunctionOrValue(work_count, inst, other)
        other.components.workable:WorkedBy(inst, count)
    end

    return AoeForEach(inst, pos, radius, nil, { "INLIMBO" }, nil, applyfn, validfn)
end

local function AoeLaunchItems(pos, radius, basespeed, validfn)
    validfn = validfn or function(_, other)
        return other.components.inventoryitem ~= nil
    end

    local applyfn = function(_, other)
        LaunchItem(other, pos, FunctionOrValue(basespeed, other))
    end

    return AoeForEach(nil, pos, radius, { "_inventoryitem" }, { "locomotor", "INLIMBO" }, nil, applyfn, validfn)
end

local function FadeTo(inst, duration, scales, multcolours, addcolours, onfinished)
    local time = 0
    if scales then
        inst.Transform:SetScale(scales[1]:Get())
    end
    if multcolours then
        inst.AnimState:SetMultColour(multcolours[1]:Get())
    end
    if addcolours then
        inst.AnimState:SetAddColour(addcolours[1]:Get())
    end

    return inst:StartThread(function()
        local delta_scale = scales and (scales[2] - scales[1])
        local delta_multcolours = multcolours and (multcolours[2] - multcolours[1])
        local delta_addcolours = addcolours and (addcolours[2] - addcolours[1])
        while true do
            local percent = time / duration

            if scales then
                inst.Transform:SetScale((scales[1] + delta_scale * percent):Get())
            end

            if multcolours then
                inst.AnimState:SetMultColour((multcolours[1] + delta_multcolours * percent):Get())
            end

            if addcolours then
                inst.AnimState:SetAddColour((addcolours[1] + delta_addcolours * percent):Get())
            end

            time = time + FRAMES
            Sleep(0)

            if time >= duration then
                break
            end
        end

        if scales then
            inst.Transform:SetScale(scales[2]:Get())
        end

        if multcolours then
            inst.AnimState:SetMultColour(multcolours[2]:Get())
        end

        if addcolours then
            inst.AnimState:SetAddColour(addcolours[2]:Get())
        end

        if onfinished then
            onfinished(inst)
        end
    end)
end

local function GetAnim(inst)
    local debug_str = inst.entity:GetDebugString()
    local bank, build, anim, frame, frame_all = string.match(debug_str,
        "bank:%s+(.-)%s+build:%s+(.-)%s+anim:%s+(.-)%s+.-Frame:%s+(.-)/(.-)%s+")

    local percent = nil
    if frame and frame_all then
        local iter = nil
        iter, percent = math.modf(frame / frame_all)
        percent = math.min(1 - 1e-6, percent)
    end

    return {
        bank = bank,
        build = build,
        anim = anim,
        frame = frame,
        frame_all = frame_all,
        percent = percent,
    }
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.WORLD)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function AddEpicBGM(inst, bgmname)
    local function PushMusic(inst, level)
        if ThePlayer == nil then
            inst._playingmusic = false
        elseif ThePlayer:IsNear(inst, inst._playingmusic and 30 or 20) then
            inst._playingmusic = true
            ThePlayer:PushEvent("triggeredevent", { name = bgmname, level = level })
        elseif inst._playingmusic and not ThePlayer:IsNear(inst, 40) then
            inst._playingmusic = false
        end
    end

    local function OnMusicDirty(inst)
        --Dedicated server does not need to trigger music
        if not TheNet:IsDedicated() then
            if inst._musictask ~= nil then
                inst._musictask:Cancel()
            end
            PushMusic(inst, inst._music:value())
            inst._musictask = inst:DoPeriodicTask(1, PushMusic, nil, inst._music:value())
            PushMusic(inst, inst._music:value())
        end
    end

    local function SetMusicLevel(inst, level)
        if inst._music:value() ~= level then
            inst._music:set(level)
            OnMusicDirty(inst)
        end
    end

    inst:AddTag("noepicmusic")
    inst._music = net_tinybyte(inst.GUID, bgmname .. "._music", "musicdirty")
    inst._playingmusic = false
    inst._musictask = nil
    SetMusicLevel(inst, 1)

    inst.SetMusicLevel = SetMusicLevel

    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)
        return inst
    end
end

local function KeepNDecimalPlaces(decimal, n) -----------------------四舍五入保留n位小数的代码
    n = n or 0
    local h = math.pow(10, n)
    decimal = math.floor((decimal * h) + 0.5) / h
    return decimal
end


local FunctionPriorityList = Class(function(self, init_list)
    self.list = init_list or {}

    self.Insert = function(self, func, priority)
        table.insert(self.list, { func, priority })
    end

    self.Sort = function(self)
        table.sort(self.list, function(a, b)
            return a[2] < b[2]
        end)
    end

    self.Execute = function(self, ...)
        self:Sort()
        for k, v in pairs(self.list) do
            -- print("FunctionPriorityList:Execute",k,v)
            v[1](...)
        end
    end
end)

local keys = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
    "V", "W", "X", "Y", "Z", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "LAlt", "RAlt",
    "LCtrl", "RCtrl", "LShift", "RShift", "Tab", "Capslock", "Space", "Minus", "Equals", "Backspace", "Insert", "Home",
    "Delete", "End", "Pageup", "Pagedown", "Print", "Scrollock", "Pause", "Period", "Slash", "Semicolon", "Leftbracket",
    "Rightbracket", "Backslash", "Up", "Down", "Left", "Right" }

local function GetKeyFromString(str)
    return rawget(_G, "KEY_" .. str)
end

local function GetStringFromKey(key)
    for k, v in pairs(keys) do
        local result = rawget(_G, "KEY_" .. v)
        if result ~= nil and result == key then
            return v
        end
    end
end

local function IsTruelyDead(inst)
    return inst:HasTag("playerghost") or
        (inst.sg and inst.sg:HasStateTag("dead")) or
        (inst.components.health and inst.components.health:IsDead())
end

local function ClearBackAnimation(inst, kill_thread)
    if inst._gale_back_anim_thread and (kill_thread == nil or kill_thread == true) then
        KillThread(inst._gale_back_anim_thread)
    end
    inst._gale_back_anim_thread = nil
    inst._gale_back_anim_queue = nil
end

local function BackAnimationThread(inst)
    while #inst._gale_back_anim_queue > 0 do
        local pop_data = inst._gale_back_anim_queue[1]
        local anim, loop, start_percent, speed = unpack(pop_data)

        -- print("Pop:",anim,loop)

        if not loop then
            table.remove(inst._gale_back_anim_queue, 1)
        end

        local percent = start_percent or 1.0
        local length = nil

        while percent >= 0 do
            -- print("Set percent:",anim,percent)

            inst.AnimState:SetPercent(anim, percent)
            if length == nil then
                length = inst.AnimState:GetCurrentAnimationLength()
            end

            percent = percent - (speed or 1) * FRAMES / length
            Sleep(0)
        end

        -- print("animover:",anim)

        inst:PushEvent("back_animover")
    end

    -- print("animqueueover")
    inst:PushEvent("back_animqueueover")

    ClearBackAnimation(inst, false)

    -- print("exit thread...")
end

local function PlayBackAnimation(inst, animname, loop, start_percent, speed)
    ClearBackAnimation(inst)

    inst._gale_back_anim_queue = {
        { animname, loop, start_percent, speed }
    }


    inst._gale_back_anim_thread = inst:StartThread(function()
        BackAnimationThread(inst)
    end)
end

local function PushBackAnimation(inst, animname, loop, start_percent, speed)
    if inst._gale_back_anim_queue == nil then
        inst._gale_back_anim_queue = {
            { animname, loop, start_percent, speed }
        }
    else
        table.insert(inst._gale_back_anim_queue, { animname, loop, start_percent, speed })
    end

    if inst._gale_back_anim_thread == nil then
        inst._gale_back_anim_thread = inst:StartThread(function()
            BackAnimationThread(inst)
        end)
    end
end

-- galetestmen.cm = require("util/gale_common")
-- galetestmen.cm.PlayBackAnimation(ThePlayer,"atk")
-- galetestmen.cm.ClearBackAnimation(ThePlayer)
-- galetestmen.cm.PlayBackAnimation(ThePlayer,"atk") galetestmen.cm.PushBackAnimation(ThePlayer,"atk_pre") galetestmen.cm.PushBackAnimation(ThePlayer,"atk") galetestmen.cm.PushBackAnimation(ThePlayer,"atk_pre")


local function RemoveConstrainedPhysicsObj(physics_obj)
    if physics_obj:IsValid() then
        physics_obj.Physics:ConstrainTo(nil)
        physics_obj:Remove()
    end
end

local function AddConstrainedPhysicsObj(target, physics_obj)
    physics_obj:ListenForEvent("onremove", function() RemoveConstrainedPhysicsObj(physics_obj) end, target)

    physics_obj:DoTaskInTime(0, function()
        if target:IsValid() then
            physics_obj.Transform:SetPosition(target.Transform:GetWorldPosition())
            physics_obj.Physics:ConstrainTo(target.entity)
        end
    end)
end

local shadow_tags = {
    "typhon",
    "shadow_aligned",
    "nightmarecreature",
    "shadowcreature",
    "shadow",
    "shadowminion",
    "stalker",
    "stalkerminion",
    "nightmare",
    "shadow_fire",
}
local function IsShadowCreature(v)
    for _, tag in pairs(shadow_tags) do
        if v:HasTag(tag) then
            return true
        end
    end

    return false
end

local function IsTyphonTarget(v)
    return IsShadowCreature(v)
        or (v:HasTag("player") and v.components.gale_skiller and v.components.gale_skiller:GetTyphonSkillNum() >= 3)
end

-- Can work in both client and server side
local function GetDestructRecipesByName(name, percent, float_to_int_fn)
    percent = math.max(0, percent or 1)
    float_to_int_fn = float_to_int_fn or math.floor

    local recipe = AllRecipes[name]
    if recipe == nil then
        return {}
    end

    local tmp = {}
    local results = {}
    for i, v in ipairs(recipe.ingredients) do
        if tmp[v.type] == nil then
            tmp[v.type] = 0
        end
        tmp[v.type] = tmp[v.type] + v.amount
    end

    for name, cnt in pairs(tmp) do
        local cnt_fix = float_to_int_fn(cnt * percent / recipe.numtogive)
        if cnt_fix > 0 then
            results[name] = cnt_fix
        end
    end

    return results
end

-- Only work in server side
local function GetDestructRecipesByEntity(target, percent, float_to_int_fn)
    local recipe = AllRecipes[target.prefab]
    if recipe == nil or FunctionOrValue(recipe.no_deconstruction, target) then
        return {}
    end

    percent = percent or 1
    float_to_int_fn = float_to_int_fn or math.floor

    local ingredient_percent = (target.components.finiteuses ~= nil and target.components.finiteuses:GetPercent()) or
        (target.components.fueled ~= nil and target.components.inventoryitem ~= nil and target.components.fueled:GetPercent()) or
        (target.components.armor ~= nil and target.components.inventoryitem ~= nil and target.components.armor:GetPercent()) or
        1

    return GetDestructRecipesByName(name, percent * ingredient_percent, float_to_int_fn)
end


return {
    GetFaceVector = GetFaceVector,
    GetFaceAngle = GetFaceAngle,
    LaunchItem = LaunchItem,
    -- DoToss = DoToss,

    AoeForEach = AoeForEach,
    AoeGetAttacked = AoeGetAttacked,
    AoeDoAttack = AoeDoAttack,
    AoeDestroyWorkableStuff = AoeDestroyWorkableStuff,
    AoeLaunchItems = AoeLaunchItems,


    -- FadeOut = FadeOut,
    -- FadeIn = FadeIn,
    FadeTo = FadeTo,

    GetAnim = GetAnim,

    ToggleOffPhysics = ToggleOffPhysics,
    ToggleOnPhysics = ToggleOnPhysics,

    AddEpicBGM = AddEpicBGM,

    KeepNDecimalPlaces = KeepNDecimalPlaces,

    -- CreateTail = CreateTail,
    -- OnUpdateProjectileTail = OnUpdateProjectileTail,

    GetKeyFromString = GetKeyFromString,
    GetStringFromKey = GetStringFromKey,

    --classes
    FunctionPriorityList = FunctionPriorityList,

    IsTruelyDead = IsTruelyDead,

    -- Back anim
    PlayBackAnimation = PlayBackAnimation,
    PushBackAnimation = PushBackAnimation,
    ClearBackAnimation = ClearBackAnimation,

    AddConstrainedPhysicsObj = AddConstrainedPhysicsObj,

    IsTyphonTarget = IsTyphonTarget,
    IsShadowCreature = IsShadowCreature,

    GetDestructRecipesByName = GetDestructRecipesByName,
    GetDestructRecipesByEntity = GetDestructRecipesByEntity,
}
