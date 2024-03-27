local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_BLACK = "typhon_phantom_spawn_smoke_vfx_black_colourenvelope"
local SCALE_ENVELOPE_NAME = "typhon_phantom_spawn_smoke_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_BLACK,
        {
            -- { 0,    IntColour(0, 229, 230, 0) },
            -- { .1,  IntColour(50, 229, 230, 80) },
            -- { .35,  IntColour(100, 229, 232, 160) },
            -- { .51,  IntColour(150, 235, 240, 80) },
            -- { .75,  IntColour(200, 240, 245, 40) },
            -- { 1,    IntColour(255, 255, 255, 0) },

            { 0,   IntColour(0, 0, 0, 0) },
            { 0.4, IntColour(112, 40, 211, 200) },
            { 0.6, IntColour(0, 0, 0, 150) },
            { 1,   IntColour(0, 0, 0, 0) },
        }
    )

    local glow_max_scale = 0.45
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,   { glow_max_scale * 0.33, glow_max_scale * 0.33 } },
            { .55, { glow_max_scale * 1, glow_max_scale * 1 } },
            { 1,   { glow_max_scale * 0.6, glow_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local GLOW_MAX_LIFETIME = 1.7

local function emit_grow_fn(effect, emitter_fn, angle_velocity)
    local vx, vy, vz = .005 * UnitRand(), GetRandomMinMax(0.1, 0.13), .005 * UnitRand()
    local lifetime = GLOW_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = emitter_fn()

    angle_velocity = angle_velocity or GetRandomMinMax(3, 5) * (math.random() <= 0.5 and 1 or -1)

    effect:AddRotatingParticle(
        0,
        lifetime,            -- lifetime
        px, py + 0.1, pz,    -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        angle_velocity       -- angle velocity
    )
end

local function CreateEmitter(max_rad)
    local sqrt = math.sqrt
    local rand = math.random
    local sin = math.sin
    local cos = math.cos

    return function()
        local radius = GetRandomMinMax(0, max_rad)
        local z = 2.0 * rand() - 1.0
        local t = 2.0 * PI * rand()
        local w = sqrt(1.0 - z * z)
        local x = w * cos(t)
        local y = w * sin(t)

        return radius * x, radius * y, radius * z
    end
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
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, GLOW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_BLACK)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetRadius(0, 3) --only needed on a single emitter
    -- effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)

    -----------------------------------------------------


    local tick_time = TheSim:GetTickTime()
    local sparkle_desired_pps_low = 1
    local sparkle_desired_pps_high = 3
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 1

    -- local emitter = CreateBoxEmitter(-1, -0.5, -0.1, 1, 0.5, 0.1)
    local emitter = CreateEmitter(1)
    local angle_ver_1 = (math.random() <= 0.5 and 1 or -1)

    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        num_to_emit = num_to_emit + 0.66
        while num_to_emit > 1 do
            emit_grow_fn(effect, emitter, GetRandomMinMax(2, 3.5) * angle_ver_1)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end
-- ThePlayer:SpawnChild("typhon_phantom_spawn_smoke_vfx")
return Prefab("typhon_phantom_spawn_smoke_vfx", fn, assets)
