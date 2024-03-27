
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local SMOKE_TEXTURE = "fx/animsmoke.tex"
local SMOKE_COLOUR_ENVELOPE_NAME = "galeboss_ruinforce_beheaded_smoke_vfx_smoke_colourenvelope"
local SMOKE_STATIC_COLOUR_ENVELOPE_NAME = "galeboss_ruinforce_beheaded_smoke_vfx_smoke_static_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "galeboss_ruinforce_beheaded_smoke_vfx_smoke_scaleenvelope"
local SMOKE_STATIC_SCALE_ENVELOPE_NAME = "galeboss_ruinforce_beheaded_smoke_vfx_smoke_static_scaleenvelope"

local assets =
{
    Asset("IMAGE", SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 64) },
            { .2,   IntColour(0, 0, 0, 100) },
            { .75,  IntColour(0, 0, 0, 100) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        SMOKE_STATIC_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 64) },
            { .2,   IntColour(0, 0, 0, 150) },
            { .75,  IntColour(0, 0, 0, 150) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local smoke_max_scale = 0.4
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale * .3, smoke_max_scale * .3} },
            { .2,   { smoke_max_scale, smoke_max_scale} },
            { 1,    { smoke_max_scale * .7, smoke_max_scale * .7 } },
        }
    )

    smoke_max_scale = 0.7
    EnvelopeManager:AddVector2Envelope(
        SMOKE_STATIC_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale, smoke_max_scale} },
            { .5,   { smoke_max_scale * 1.1, smoke_max_scale * 1.1} },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = 0.5
local SMOKE_STATIC_MAX_LIFETIME = 0.66

local function emit_smoke_fn(effect, sphere_emitter)
	local vx, vy, vz = .05 * UnitRand(), GetRandomMinMax(0.15,0.18), .05 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

	effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 4      -- angle velocity
    )
end

local function emit_smoke_static_fn(effect, sphere_emitter)
	local vx, vy, vz = .01 * UnitRand(), .01 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_STATIC_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

	effect:AddRotatingParticle(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.no_emit = false 
    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)
	
	--smoke
	effect:SetRenderResources(0, SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetRotationStatus(0,true)

    effect:SetRenderResources(1, SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, SMOKE_STATIC_MAX_LIFETIME)
    effect:SetColourEnvelope(1, SMOKE_STATIC_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, SMOKE_STATIC_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetFollowEmitter(1,true)
    effect:SetRotationStatus(1,true)
	
	

    -----------------------------------------------------
	
    local sphere_emitter = CreateSphereEmitter(.6)
    local sphere_static_emitter = CreateSphereEmitter(.05)
    local num_to_emit = 0

    EmitterManager:AddEmitter(inst, nil, function()
        num_to_emit = num_to_emit + FRAMES * 5

        while num_to_emit > 1 do
            emit_smoke_static_fn(effect, sphere_static_emitter)
            num_to_emit = num_to_emit - 1
        end

        for i =1,3 do
            emit_smoke_fn(effect, sphere_emitter)
        end
        
    end)

    return inst
end

return Prefab("galeboss_ruinforce_beheaded_smoke_vfx", fn, assets)
