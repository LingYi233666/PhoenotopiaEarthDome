local LIGHTNING_TEXTURE = resolvefilepath("fx/DYC/dyc_lightningsheet.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local namespace = "gale_skill_electric_punch_vfx"
local COLOUR_ENVELOPE_NAME = namespace .. "_colourenvelope"
local SCALE_ENVELOPE_NAME = namespace .. "_scaleenvelope"

local assets =
{
    Asset("IMAGE", LIGHTNING_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- local envs = {}
    -- local t = 0
    -- local step = .15
    -- while t + step + .01 < 1 do
    --     table.insert(envs, { t, IntColour(255, 255, 150, 255) })
    --     t = t + step
    --     table.insert(envs, { t, IntColour(255, 255, 150, 0) })
    --     t = t + .01
    -- end
    -- table.insert(envs, { 1, IntColour(255, 255, 150, 0) })

    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,  IntColour(180, 180, 12, 0) },
            { .2, IntColour(200, 200, 10, 240) },
            { .7, IntColour(250, 250, 9, 256) },
            { 1,  IntColour(200, 200, 6, 0) },
        }
    )

    local sparkle_max_scale = 1.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.75

local function emit_sparkle_fn(effect, sphere_emitter)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    -- local vx, vy, vz = 0, 0, 0
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    -- local px, py, pz = 0, 0, 0

    local angle = math.random() * 360
    local u, v = math.random(0, 3) * .25, math.random(0, 1) * .5
    local ang_vel = (UnitRand() - 1) * 1

    effect:AddRotatingParticleUV(
        0,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        u, v            -- uv offset
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
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, LIGHTNING_TEXTURE, REVEAL_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 0.5)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 1)
    -- effect:SetSortOffset(0, 2)
    -- effect:SetFollowEmitter(0, true)

    -----------------------------------------------------
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)

    EmitterManager:AddEmitter(inst, nil, function()
        num_to_emit = 2
        while num_to_emit > 1 do
            emit_sparkle_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("gale_skill_electric_punch_vfx", fn, assets)
