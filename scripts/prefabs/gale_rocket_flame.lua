local GaleCommon = require("util/gale_common")

local FLAME_TEXTURE = resolvefilepath("fx/torchfire.tex")
local EMBER_TEXTURE = resolvefilepath("fx/snow.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local FLAME_COLOUR_ENVELOPE_NAME = "gale_rocket_flame_colourenvelope"
local FLAME_SCALE_ENVELOPE_NAME = "gale_rocket_flame_scaleenvelope"

local MOVE_FLAME_COLOUR_ENVELOPE_NAME = "gale_rocket_flame_move_colourenvelope"
local MOVE_FLAME_SCALE_ENVELOPE_NAME = "gale_rocket_flame_move_scaleenvelope"

local EMBER_COLOUR_ENVELOPE_NAME = "gale_rocket_flame_ember_colourenvelope"
local EMBER_SCALE_ENVELOPE_NAME = "gale_rocket_flame_ember_scaleenvelope"

local assets =
{
    Asset("IMAGE", FLAME_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        FLAME_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(200, 85, 60, 25) },
            { .19,  IntColour(200, 125, 80, 100) },
            { .35,  IntColour(255, 20, 10, 200) },
            { .51,  IntColour(255, 20, 10, 128) },
            { .75,  IntColour(255, 20, 10, 64) },
            { 1,    IntColour(255, 7, 5, 0) },
        }
    )

    local max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        FLAME_SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale * .5, max_scale } },
            { 1,    { max_scale * .5 * .5, max_scale * 1.5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        MOVE_FLAME_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(187, 111, 60, 128) },
            { .49,  IntColour(187, 111, 60, 128) },
            { .5,   IntColour(255, 255, 0, 128) },
            { .51,  IntColour(255, 30, 56, 128) },
            { .75,  IntColour(255, 30, 56, 128) },
            { 1,    IntColour(255, 7, 28, 0) },
        }
    )

    local max_scale_move = 2.5
    EnvelopeManager:AddVector2Envelope(
        MOVE_FLAME_SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale_move * .5, max_scale_move } },
            { 1,    { max_scale_move * .5 * .5, max_scale_move * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        EMBER_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(200, 85, 60, 25) },
            { .2,   IntColour(230, 140, 90, 200) },
            { .3,   IntColour(255, 90, 70, 255) },
            { .6,   IntColour(255, 90, 70, 255) },
            { .9,   IntColour(255, 90, 70, 75) },
            { 1,    IntColour(255, 70, 70, 0) },
        }
    )

    local ember_max_scale = .35
    EnvelopeManager:AddVector2Envelope(
        EMBER_SCALE_ENVELOPE_NAME,
        {
            { 0,    { ember_max_scale, ember_max_scale } },
            { 1,    { ember_max_scale, ember_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local FLAME_MAX_LIFETIME = 0.6
local MOVE_FLAME_MAX_LIFETIME = 0.33
local EMBER_MAX_LIFETIME = 0.4

local function emit_flame_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = FLAME_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = GetRandomMinMax(-182,-178)
    
    local uv_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, 0,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_move_flame_fn(effect, sphere_emitter)
    local lifetime = MOVE_FLAME_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = GetRandomMinMax(180 - 45,180 + 45)
    local angle_velocity = -(angle - 180) / 10

    local down_vec = TheCamera:GetDownVec()
    local right_vec = TheCamera:GetRightVec()

    local vx, vy, vz = ((down_vec * math.cos((180 - angle) * DEGREES) - right_vec * math.sin((180 - angle) * DEGREES)) * 0.05):Get()
    local uv_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, angle_velocity,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_ember_fn(effect, sphere_emitter)
    local vx, vy, vz = .05 * UnitRand(), -0.05 - 0.05 * UnitRand(), .05 * UnitRand()
    local lifetime = EMBER_MAX_LIFETIME * (0.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    effect:AddParticleUV(
        2,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        0, 0                -- uv offset
    )
end

local function fn()
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
    effect:InitEmitters(3)

    effect:SetRenderResources(0, FLAME_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(0, FLAME_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, FLAME_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)

    effect:SetRenderResources(1, FLAME_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, MOVE_FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(1, MOVE_FLAME_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, MOVE_FLAME_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)

    --EMBER
    effect:SetRenderResources(2, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 128)
    effect:SetMaxLifetime(2, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(2, EMBER_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, EMBER_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.Additive)
    effect:EnableBloomPass(2, true)
    effect:SetUVFrameSize(2, 1, 1)
    effect:SetSortOrder(2, 0)
    effect:SetSortOffset(2, 3)
    effect:SetDragCoefficient(2, .07)

    local sphere_emitter = CreateSphereEmitter(.1)
    local sphere_emitter_ember = CreateSphereEmitter(.25)

    EmitterManager:AddEmitter(inst, nil, function()
        local num_to_emit = 10
        local num_to_emit_move = 7
        local num_to_emit_ember = 8

        while num_to_emit > 1 do
            emit_flame_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end

        while num_to_emit_move > 1 do
            emit_move_flame_fn(effect, sphere_emitter)
            num_to_emit_move = num_to_emit_move - 1
        end

        while num_to_emit_ember > 1 do
            emit_ember_fn(effect, sphere_emitter_ember)
            num_to_emit_ember = num_to_emit_ember - 1
        end
    end)

    return inst
end
-- ThePlayer:SpawnChild("gale_rocket_flame")
return Prefab("gale_rocket_flame", fn, assets)