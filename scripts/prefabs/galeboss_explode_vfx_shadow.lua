local POINT_TEXTURE = "fx/smoke.tex"
local RAIN_INVERSE_TEXTURE = resolvefilepath("fx/rain_inverse.tex")
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ANIM_HAND_TEXTURE = "fx/animhand.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_COLOUR_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_point_colourenvelope"
local POINT_SCALE_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_point_scaleenvelope"

local POINT_BG_COLOUR_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_point_bg_colourenvelope"
local POINT_BG_SCALE_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_point_bg_scaleenvelope"

local SMOKE_COLOUR_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_smoke_scaleenvelope"

local SMOKE_BG_COLOUR_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_smoke_bg_colourenvelope"
local SMOKE_BG_SCALE_ENVELOPE_NAME = "galeboss_explode_vfx_shadow_smoke_bg_scaleenvelope"

local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", RAIN_INVERSE_TEXTURE),
    Asset("IMAGE", ANIM_HAND_TEXTURE),
    
    
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- Point
    EnvelopeManager:AddColourEnvelope(
        POINT_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 64) },
            { .05,   IntColour(0, 0, 0, 256) },
            { .75,  IntColour(0, 0, 0, 256) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local point_max_scale = 0.55
    EnvelopeManager:AddVector2Envelope(
        POINT_SCALE_ENVELOPE_NAME,
        {
            { 0,    { point_max_scale, point_max_scale} },
            { 0.33,    { point_max_scale, point_max_scale} },
            { 0.66,    { point_max_scale, point_max_scale} },
            { 1,    { point_max_scale * 0.8, point_max_scale * 0.8 } },
        }
    )

    -- Point BG
    EnvelopeManager:AddColourEnvelope(
        POINT_BG_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 0)},
            { .075,   IntColour(0, 0, 0, 255)},
            { .3,   IntColour(0, 0, 5, 250) },
            { .6,   IntColour(0, 0, 5, 200) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local point_bg_max_scale = 17
    EnvelopeManager:AddVector2Envelope(
        POINT_BG_SCALE_ENVELOPE_NAME,
        {
            { 0,    { point_bg_max_scale, point_bg_max_scale } },
            { 1,    { point_bg_max_scale * 1.1, point_bg_max_scale * 1.1 } },
        }
    )

    -- smoke
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 100) },
            { .1,   IntColour(0, 0, 0, 150) },
            { .9,  IntColour(0, 0, 0, 150) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local smoke_max_scale = 0.75
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale * .3, smoke_max_scale * .3} },
            { .2,   { smoke_max_scale, smoke_max_scale} },
            { 1,    { smoke_max_scale * .7, smoke_max_scale * .7 } },
        }
    )

    -- Smoke BG
    EnvelopeManager:AddColourEnvelope(
        SMOKE_BG_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 0) },
            { 0.02,    IntColour(0, 0, 0, 90) },
            { .05,   IntColour(0, 0, 0, 180) },
            { .3,   IntColour(0, 0, 0, 175) },
            { .52,  IntColour(0, 0, 0, 90) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local smoke_max_scale = 2
    EnvelopeManager:AddVector2Envelope(
        SMOKE_BG_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale * .5, smoke_max_scale * .5 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local POINT_MAX_LIFETIME = 1.5
local POINT_BG_MAX_LIFETIME = 0.8
local SMOKE_MAX_LIFETIME = 1.2
local SMOKE_BG_MAX_LIFETIME = 1.2

local function emit_point_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px,py,pz):GetNormalized() * GetRandomMinMax(0.3,0.4)):Get()
    vy = math.random(0.5,0.8)
    local lifetime = POINT_MAX_LIFETIME * (0.9 + math.random() * 0.1)
    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = UnitRand()

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_point_bg_fn(effect)
    local lifetime = POINT_BG_MAX_LIFETIME * (0.9 + math.random() * 0.1)
    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = UnitRand()

    effect:AddRotatingParticleUV(
        1,
        lifetime,           -- lifetime
        0, 0, 0,         -- position
        0, 0, 0,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end


local function emit_smoke_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px,py,pz):GetNormalized() * GetRandomMinMax(1.2,1.5)):Get()
    local lifetime = SMOKE_MAX_LIFETIME * (0.6 + math.random() * 0.4)

    effect:AddRotatingParticle(
        2,
        lifetime,  -- lifetime
        px, py, pz,   -- position
        vx, vy, vz,         -- velocity
        0,                  --* 2 * PI, -- angle
        UnitRand() * 2         -- angle velocity
    )
end

local function emit_smoke_bg_fn(effect)
    local lifetime = SMOKE_BG_MAX_LIFETIME * (0.9 + math.random() * 0.1)
    local angle = math.random() * 360
    local ang_vel = UnitRand()

    effect:AddRotatingParticle(
        3,
        lifetime,           -- lifetime
        0, 0, 0,         -- position
        0, 0, 0,         -- velocity
        angle, ang_vel     -- angle, angular_velocity
    )
end

local function CommonFn()
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
    effect:InitEmitters(4)

    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 512)
    effect:SetMaxLifetime(0, POINT_MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:SetDragCoefficient(0, .02)
    effect:SetAcceleration(0,0,-0.8,0)
    effect:SetGroundPhysics(0, true)

    effect:SetRenderResources(1, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetUVFrameSize(1, .25, 1)
    effect:SetMaxNumParticles(1, 1)
    effect:SetMaxLifetime(1, POINT_BG_MAX_LIFETIME)
    effect:SetColourEnvelope(1, POINT_BG_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, POINT_BG_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetSortOrder(1, 2)
    effect:SetSortOffset(1, 2)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(2, 256)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(2, true)
    effect:SetAcceleration(2,0,-0.4,0)
    effect:SetDragCoefficient(2, .12)

    effect:SetRenderResources(3, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(3, 1)
    effect:SetRotationStatus(3, true)
    effect:SetMaxLifetime(3, SMOKE_BG_MAX_LIFETIME)
    effect:SetColourEnvelope(3, SMOKE_BG_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(3, SMOKE_BG_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(3, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(3, true)


    return inst 
end

local function loop_fn()
    local inst = CommonFn()

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    local point_sphere = CreateSphereEmitter(0.01)
    local smoke_sphere = CreateSphereEmitter(0.05)

    EmitterManager:AddEmitter(inst, nil, function()
        for i=1,math.random(1,2) do
            emit_point_fn(inst.VFXEffect,point_sphere)
        end 

        for i=1,math.random(2,3) do
            emit_smoke_fn(inst.VFXEffect,smoke_sphere)
        end
        
    end)


    return inst
end

local function onshoot_fn()
    local inst = CommonFn()

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetDragCoefficient(0, .02)
    inst.VFXEffect:SetDragCoefficient(2, .2)

    local point_sphere = CreateSphereEmitter(0.01)
    local smoke_sphere = CreateSphereEmitter(0.05)

    EmitterManager:AddEmitter(inst, nil, function()
        for i=1,math.random(25,28) do
            emit_point_fn(inst.VFXEffect,point_sphere)
        end 

        for i=1,math.random(30,33) do
            emit_smoke_fn(inst.VFXEffect,smoke_sphere)
        end
        
        emit_point_bg_fn(inst.VFXEffect)
        emit_smoke_bg_fn(inst.VFXEffect)
    end)

    inst:DoTaskInTime(0,inst.Remove)


    return inst
end

-- c_findnext("skeleton"):SpawnChild("galeboss_explode_vfx_shadow")
-- ThePlayer:SpawnChild("galeboss_explode_vfx_shadow")
return Prefab("galeboss_explode_vfx_shadow_loop", loop_fn, assets),
Prefab("galeboss_explode_vfx_shadow_oneshoot", onshoot_fn, assets)