local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local namespace = "gale_skill_hyperburn_vfx"


local COLOUR_ENVELOPE_NAME_SMOKE_RED = namespace .. "_colourenvelope_smoke_red"
local COLOUR_ENVELOPE_NAME_SMOKE_YELLOW = namespace .. "_colourenvelope_smoke_yellow"
local COLOUR_ENVELOPE_NAME_ARROW = namespace .. "_colourenvelope_arrow"
local SCALE_ENVELOPE_NAME_SMOKE_THIN = namespace .. "_scaleenvelope_smoke_thin"
local SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN = namespace .. "_scaleenvelope_smoke_very_thin"
local SCALE_ENVELOPE_NAME_SMOKE = namespace .. "_scaleenvelope_smoke"
local SCALE_ENVELOPE_NAME_ARROW = namespace .. "_scaleenvelope_arrow"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_YELLOW, {
        { 0,  IntColour(255, 240, 0, 0) },
        { .2, IntColour(255, 253, 0, 200) },
        { .3, IntColour(200, 255, 0, 110) },
        { .6, IntColour(230, 245, 0, 180) },
        { .9, IntColour(255, 240, 0, 100) },
        { 1,  IntColour(255, 240, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_RED, {
        { 0,  IntColour(255, 0, 0, 0) },
        { .2, IntColour(255, 0, 0, 240) },
        { .3, IntColour(200, 0, 0, 180) },
        { .6, IntColour(230, 0, 0, 150) },
        { .9, IntColour(255, 0, 0, 110) },
        { 1,  IntColour(255, 0, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,  IntColour(150, 0, 19, 255) },
        { .2, IntColour(255, 10, 19, 255) },
        { .8, IntColour(230, 10, 19, 255) },
        { 1,  IntColour(150, 0, 19, 255) },
    })

    local scale_factor = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_THIN,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )

    scale_factor = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )


    scale_factor = 1.0
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )



    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { arrow_max_scale * 0.2, arrow_max_scale } },
            { 1, { arrow_max_scale * .001, arrow_max_scale * .001 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.6
local MAX_LIFETIME_ARROW = 1.0

local function emit_line_thin(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_line(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_arrow(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME_ARROW * (.6 + UnitRand() * .4))

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        2,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end



local function linevfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false


    inst._velocity_x = net_float(inst.GUID, "inst._velocity_x")
    inst._velocity_y = net_float(inst.GUID, "inst._velocity_y")
    inst._velocity_z = net_float(inst.GUID, "inst._velocity_z")
    inst._event = net_event(inst.GUID, "inst._event")
    inst._depth = net_bool(inst.GUID, "inst._depth", "depthdirty")

    inst.DoEmit = function(inst, x_or_pos, y, z)
        local x = x_or_pos
        if x_or_pos ~= nil and y == nil and z == nil then
            x, y, z = x_or_pos:Get()
        end

        inst._velocity_x:set(x)
        inst._velocity_y:set(y)
        inst._velocity_z:set(z)

        inst._event:push()
    end

    inst.EnableDepth = function(inst, enable)
        inst._depth:set(enable)
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    -- Thin yellow line in the flame middle
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:EnableDepthTest(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 1)

    -- Fat red line of the flame
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 1)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_RED)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    -- effect:EnableDepthTest(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOffset(1, 0)

    effect:SetRenderResources(2, ARROW_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(2, true)
    effect:SetMaxNumParticles(2, 32)
    effect:SetUVFrameSize(2, .25, 1)
    effect:SetMaxLifetime(2, MAX_LIFETIME_ARROW)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(2, BLENDMODE.Additive)
    effect:EnableBloomPass(2, true)
    effect:SetSortOffset(2, 2)
    effect:SetDragCoefficient(2, 0.1)

    -----------------------------------------------------
    local line_sphere_emitter = CreateSphereEmitter(0.1)
    local arrow_sphere_emitter = CreateSphereEmitter(0.2)

    inst:ListenForEvent("inst._event", function()
        local velocity = Vector3(inst._velocity_x:value(), inst._velocity_y:value(), inst._velocity_z:value())
        emit_line_thin(effect, Vector3(line_sphere_emitter()), velocity)
        emit_line(effect, Vector3(line_sphere_emitter()), velocity)

        for i = 1, 8 do
            emit_arrow(effect, Vector3(arrow_sphere_emitter()) + velocity * GetRandomMinMax(-2, 2), velocity)
        end
    end)

    inst:ListenForEvent("depthdirty", function()
        effect:EnableDepthTest(0, inst._depth:value())
        effect:EnableDepthTest(1, inst._depth:value())
        effect:EnableDepthTest(2, inst._depth:value())
    end)

    return inst
end

local function explovfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    -- vERY thin yellow line in the flame middle
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 8)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_VERY_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 1)

    -- Thin red line of the flame
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 8)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_RED)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOffset(1, 0)

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    local remain_time = FRAMES * 3
    EmitterManager:AddEmitter(inst, nil, function()
        if remain_time > 0 then
            for i = 1, 8 do
                local velocity = Vector3(norm_sphere_emitter()) * 0.3
                velocity.y = math.abs(velocity.y)
                -- local pos = Vector3(line_sphere_emitter())
                local pos = velocity:GetNormalized() * 0.66
                emit_line_thin(effect, pos, velocity)
                emit_line(effect, pos, velocity)
            end
            remain_time = remain_time - FRAMES
        end
    end)

    return inst
end


local function linefxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("gale_skill_hyperburn_line_vfx")

    inst:DoTaskInTime(10 * FRAMES, inst.Remove)

    return inst
end

local function explofxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("gale_skill_hyperburn_explo_vfx")

    inst:DoTaskInTime(10 * FRAMES, inst.Remove)

    return inst
end

local function ping_CreateDisc(r, g, b, a)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false) --use parent sleep
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("deerclops")
    inst.AnimState:SetBuild("deerclops_mutated")
    inst.AnimState:PlayAnimation("target_fx_ring")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetAddColour(r, g, b, a)
    inst.AnimState:SetMultColour(r, g, b, a)
    inst.AnimState:SetLightOverride(1)

    return inst
end



return Prefab("gale_skill_hyperburn_line_vfx", linevfxfn, assets),
    Prefab("gale_skill_hyperburn_explo_vfx", explovfxfn, assets),
    Prefab("gale_skill_hyperburn_line_fx", linefxfn),
    Prefab("gale_skill_hyperburn_explo_fx", explofxfn),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_skill_hyperburn_burntground",
        assets = {
            Asset("ANIM", "anim/burntground.zip"),
        },

        bank = "burntground",
        build = "burntground",
        anim = "idle",
        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
        end,

        serverfn = function(inst)
            inst.Transform:SetRotation(math.random() * 360)

            inst:DoTaskInTime(GetRandomMinMax(3, 5), function()
                GaleCommon.FadeTo(inst, 1, nil, { Vector4(1, 1, 1, 1), Vector4(0, 0, 0, 0) }, nil, inst.Remove)
            end)
        end,
    }),

    GaleEntity.CreateNormalFx({
        prefabname = "gale_skill_hyperburn_ping_fx",
        assets = {
            Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
            Asset("ANIM", "anim/deerclops_mutated.zip"),
            Asset("ANIM", "anim/deer_ice_circle.zip"),
        },

        bank = "deerclops",
        build = "deerclops_mutated",
        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
            inst.AnimState:SetFinalOffset(1)

            inst.AnimState:PlayAnimation("target_fx_pre")
            inst.AnimState:PushAnimation("target_fx", true)

            local r, g, b, a = 1, 0, 0, 1
            inst.AnimState:SetAddColour(r, g, b, a)
            inst.AnimState:SetMultColour(r, g, b, a)
            inst.AnimState:SetLightOverride(1)

            local ICE_LANCE_RADIUS = 5.5
            local my_dist = 3
            local s = my_dist / ICE_LANCE_RADIUS

            inst.Transform:SetScale(s, s, s)

            inst._remove_dist_event = net_event(inst.GUID, "inst._remove_dist_event")

            --Dedicated server does not need to spawn the local fx
            if not TheNet:IsDedicated() then
                inst.disc = ping_CreateDisc(r, g, b, a)
                inst.disc.entity:SetParent(inst.entity)

                inst:ListenForEvent("inst._remove_dist_event", function()
                    inst.disc:Remove()
                end)
            end
        end,

        serverfn = function(inst)
            inst.KillFX = function(inst)
                inst._remove_dist_event:push()
                inst.AnimState:PlayAnimation("target_fx_pst")
                inst:ListenForEvent("animover", inst.Remove)
            end
        end,
    })
