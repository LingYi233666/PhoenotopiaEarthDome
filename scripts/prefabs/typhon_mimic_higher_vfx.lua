local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local EMBER_TEXTURE = "fx/confetti.tex"
local POINT_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "typhon_mimic_higher_vfx_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "typhon_mimic_higher_vfx_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME_EMBER = "typhon_mimic_higher_vfx_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "typhon_mimic_higher_vfx_scaleenvelope_ember"
local COLOUR_ENVELOPE_NAME_POINT = "typhon_mimic_higher_vfx_colourenvelope_point"
local SCALE_ENVELOPE_NAME_POINT = "typhon_mimic_higher_vfx_scaleenvelope_point"


local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", POINT_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,   IntColour(10, 10, 10, 0) },
            { .3,  IntColour(10, 10, 10, 175) },
            { .52, IntColour(10, 10, 10, 90) },
            { 1,   IntColour(10, 10, 10, 0) },
        }
    )
    local smoke_max_scale = 0.3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0, { smoke_max_scale * .5, smoke_max_scale * .5 } },
            { 1, { smoke_max_scale, smoke_max_scale } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_POINT,
        {
            { 0,   IntColour(255, 255, 255, 255) },
            { 0.4, IntColour(0, 0, 0, 255) },
            { .6,  IntColour(255, 226, 110, 255) },
            { 1,   IntColour(0, 0, 0, 0) },
        }
    )
    local point_max_scale = 0.9
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_POINT,
        {
            { 0,   { point_max_scale, point_max_scale } },
            { 0.7, { point_max_scale * 0.7, point_max_scale * 0.7 } },
            { 1,   { point_max_scale * 0.1, point_max_scale * 0.1 } },
        }
    )


    local ember_colours = {}
    for i = 0, 4 do
        if i % 2 == 0 then
            table.insert(ember_colours, { i * 0.2, IntColour(0, 0, 0, 255) })
        else
            table.insert(ember_colours, { i * 0.2, IntColour(39, 0, 41, 255) })
        end
    end
    table.insert(ember_colours, { 1, IntColour(0, 0, 0, 0) })
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        -- {
        --     -- { 0,  IntColour(255, 255, 255, 255) },
        --     -- { .2, IntColour(0, 0, 0, 255) },
        --     -- { .6, IntColour(255, 226, 110, 255) },
        --     -- { 1,  IntColour(0, 0, 0, 0) },
        --     -- { 0,  IntColour(255, 255, 255, 255) },
        --     -- { .3, IntColour(255, 226, 110, 255) },
        --     -- { 1,  IntColour(0, 0, 0, 0) },
        -- }
        ember_colours
    )



    -- local ember_max_scale = 12.0
    local ember_max_scale = 4.0

    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,   { ember_max_scale * 0.15 * 0.1, ember_max_scale } },
            { 0.5, { ember_max_scale * 0.15 * 0.9, ember_max_scale * 0.9 } },
            { 1,   { ember_max_scale * 0.15 * 0.1, ember_max_scale } },

            -- { 0,   { ember_max_scale * 0.1, ember_max_scale } },
            -- { 0.5, { ember_max_scale * 0.9, ember_max_scale * 0.9 } },
            -- { 1,   { ember_max_scale * 0.1, ember_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.1
local POINT_MAX_LIFETIME = .6
local EMBER_MAX_LIFETIME = 1.5

local function emit_smoke_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .06 * UnitRand(), -.015 + .01 * UnitRand(), .06 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end

local function emit_point_fn(effect, sphere_emitter)
    local lifetime = POINT_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.05, 0.2)):Get()



    local ang_vel = 0
    local angle = math.random() * 360

    effect:AddRotatingParticle(
        1,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
    )
end

local function emit_ember_fn(effect, sphere_emitter)
    local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    py = math.abs(py)
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 1e-3):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        2,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
    -- effect:AddParticle(
    --     2,
    --     lifetime,   -- lifetime
    --     px, py, pz, -- position
    --     vx, vy, vz  -- velocity
    -- )
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
    effect:InitEmitters(3)

    --SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, .1)

    --Point
    effect:SetRenderResources(1, POINT_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 16)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, POINT_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_POINT)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_POINT)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, .11)

    --EMBER
    effect:SetRenderResources(2, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 128)
    effect:SetMaxLifetime(2, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(2, true)
    effect:SetUVFrameSize(2, 0.25, 1)
    effect:SetDragCoefficient(2, .14)
    effect:SetRotateOnVelocity(2, true)
    effect:SetFollowEmitter(2, true)
    -- effect:SetKillOnEntityDeath(2, true)
    -- effect:SetSortOrder(2, 1)
    effect:SetSortOffset(2, 1)
    effect:EnableDepthTest(2, true)
    -- effect:SetAcceleration(2, 0, -0.05, 0)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local burst_state = 0

    local smoke_sphere_emitter = CreateSphereEmitter(0.15)
    local point_sphere_emitter = CreateSphereEmitter(0.5)
    -- local ember_sphere_emitter = CreateSphereEmitter(0.7)
    local ember_sphere_emitter = function()
        local z = GetRandomMinMax(0.3, 0.8)
        local t = 2.0 * PI * rand()
        local w = math.sqrt(1.0 - z * z) * 0.5
        local x = w * math.cos(t)
        local y = w * math.sin(t)

        return x, z, y
    end

    local num_to_emit_smoke = 1
    local num_to_emit_spark = 1
    local num_to_emit_ember = 12

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not (parent and parent.entity:IsVisible()) then
            return
        end
        while num_to_emit_smoke > 0 do
            emit_smoke_fn(effect, smoke_sphere_emitter)
            num_to_emit_smoke = num_to_emit_smoke - 1
        end
        -- while num_to_emit_spark > 0 do
        --     emit_point_fn(effect, point_sphere_emitter)
        --     num_to_emit_spark = num_to_emit_spark - 1
        -- end
        while num_to_emit_ember > 0 do
            emit_ember_fn(effect, ember_sphere_emitter)
            num_to_emit_ember = num_to_emit_ember - 1
        end

        num_to_emit_smoke = num_to_emit_smoke + 0.3
        -- num_to_emit_spark = num_to_emit_spark + 1
        num_to_emit_ember = num_to_emit_ember + 0.4
    end)

    return inst
end

return Prefab("typhon_mimic_higher_vfx", fn, assets)
