local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local ARROW_COLOUR_ENVELOPE_NAME = "gale_atk_leap_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "gale_atk_leap_vfx_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(123, 245, 247, 180) },
            { .2,   IntColour(147, 245, 247, 255) },
            { .8,   IntColour(123, 245, 247, 175) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local arrow_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0,    { arrow_max_scale * 0.4 , arrow_max_scale * 2} },
            -- { 0.6,    { arrow_max_scale * 0.05 , arrow_max_scale * 1.5} },
            { 1,    { arrow_max_scale * 0.002, arrow_max_scale * 0.01} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local ARROW_MAX_LIFETIME = 1

local function emit_arrow_fn(effect, sphere_emitter)            
    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx,vy,vz = (Vector3(px, 0, pz):GetNormalized() * 0.5):Get()

    local uv_offset = math.random(0, 3) * .25
    
    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, 0, pz,    -- position
        vx,vy,vz,          -- velocity
        uv_offset, 0        -- uv offset
    )
end
-- ThePlayer:SpawnChild("gale_atk_leap_vfx")
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst:DoTaskInTime(5,inst.Remove)

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
    effect:SetMaxNumParticles(0, 25)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.1)
    effect:SetLayer(0, LAYER_GROUND)
    effect:SetRotateOnVelocity(0, true)
    -- effect:SetGroundPhysics(0, true)



    local sphere_emitter = CreateSphereEmitter(.25)
    local arrow_to_emit = 15

    EmitterManager:AddEmitter(inst, nil, function()
        while arrow_to_emit > 0 do 
            emit_arrow_fn(effect, sphere_emitter)
            arrow_to_emit = arrow_to_emit - 1
        end
        inst:Remove()
    end)

    return inst
end

return Prefab("gale_atk_leap_vfx", fn, assets)
