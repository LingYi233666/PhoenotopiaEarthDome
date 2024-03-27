local RAY_TEXTURE = "fx/spark.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_RAY_YELLOW = "gale_explode_ray_vfx_colourenvelope_yellow"
local SCALE_ENVELOPE_NAME_RAY = "gale_explode_ray_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", RAY_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}


local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_RAY_YELLOW,
        {
            { 0,    IntColour(200, 85, 60, 25) },
            { .2,   IntColour(230, 140, 90, 200) },
            { .3,   IntColour(255, 90, 70, 255) },
            { .6,   IntColour(255, 90, 70, 255) },
            { .9,   IntColour(255, 90, 70, 230) },
            { 1,    IntColour(255, 70, 70, 0) },
        }
    )

    local ray_max_scale = 2.75
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_RAY,
        {
            { 0,    { ray_max_scale, ray_max_scale} },
            { 1,    { ray_max_scale * 0.125, ray_max_scale * 0.125 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local RAY_MAX_LIFETIME = 1.75

local function emit_ray_fn(effect, sphere_emitter)
    local lifetime = RAY_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()

    py = math.abs(py)

    local speed = GetRandomMinMax(0.5,0.6)
    local vx, vy, vz = (Vector3(px,py,pz):GetNormalized() * speed):Get()

    local uv_offset = math.random(0, 3) * .25
    
    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx,vy,vz,          -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst:DoTaskInTime(1,inst.Remove)

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
    effect:SetRenderResources(0, RAY_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 25)
    effect:SetMaxLifetime(0, RAY_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_RAY_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_RAY)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetDragCoefficient(0, 0.14)
    effect:SetRotateOnVelocity(0, true)

    local sphere_emitter = CreateSphereEmitter(.1)
    local ray_to_emit = math.random(20,25)

    EmitterManager:AddEmitter(inst, nil, function()
        while ray_to_emit > 0 do 
            emit_ray_fn(effect, sphere_emitter)
            ray_to_emit = ray_to_emit - 1
        end
    end)

    return inst
end

return Prefab("gale_explode_ray_yellow_vfx", fn, assets)
