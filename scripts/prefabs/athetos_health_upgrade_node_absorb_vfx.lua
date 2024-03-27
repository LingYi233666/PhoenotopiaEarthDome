local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local ARROW_COLOUR_ENVELOPE_NAME = "athetos_health_upgrade_node_absorb_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "athetos_health_upgrade_node_absorb_vfx_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(75, 16, 19, 255) },
            { .2,   IntColour(162, 20, 19, 255) },
            { .8,   IntColour(177, 20, 19, 255) },
            { 1,    IntColour(75, 16, 19, 255) },
        }
    )

    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0,    { arrow_max_scale * 0.2, arrow_max_scale } },
            { 1,    { arrow_max_scale * .001, arrow_max_scale * .001 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.5

local function emit_arrow_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (-Vector3(px, py, pz):GetNormalized() * 0.38):Get()

    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,          -- velocity
        uv_offset, 0        -- uv offset
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
    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0,true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetDragCoefficient(0, 0.12)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetFollowEmitter(0,true)

    -----------------------------------------------------


    local sphere_emitter = CreateSphereEmitter(2.25)
    local num_to_emit = 20
    EmitterManager:AddEmitter(inst, nil, function()
        -- print("emit_arrow_fn")
        while num_to_emit > 0 do
            emit_arrow_fn(effect,sphere_emitter)
            num_to_emit = num_to_emit - 1
        end

        
    end)

    return inst
end

-- local fx=ThePlayer:SpawnChild("athetos_health_upgrade_node_absorb_vfx") fx.Transform:SetPosition(0,0.5,0) fx:DoTaskInTime(0,fx.Remove)
return Prefab("athetos_health_upgrade_node_absorb_vfx", fn, assets)
