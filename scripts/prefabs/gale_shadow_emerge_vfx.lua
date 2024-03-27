local POINT_TEXTURE = "fx/smoke.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ANIM_HAND_TEXTURE = "FX/animhand.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_COLOUR_ENVELOPE_NAME = "gale_shadow_emerge_vfx_point_colourenvelope"
local POINT_SCALE_ENVELOPE_NAME = "gale_shadow_emerge_vfx_point_scaleenvelope"

local SMOKE_COLOUR_ENVELOPE_NAME = "gale_shadow_emerge_vfx_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "gale_shadow_emerge_vfx_smoke_scaleenvelope"

local HAND_COLOUR_ENVELOPE_NAME = "gale_shadow_emerge_vfx_hand_colourenvelope"
local HAND_SCALE_ENVELOPE_NAME = "gale_shadow_emerge_vfx_hand_scaleenvelope"

local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- Hand
    EnvelopeManager:AddColourEnvelope(
        HAND_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(24, 24, 24, 64) },
            { .2,   IntColour(20, 20, 20, 256) },
            { .75,  IntColour(18, 18, 18, 256) },
            { 1,    IntColour(12, 12, 12, 0) },
        }
    )

    local hand_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        HAND_SCALE_ENVELOPE_NAME,
        {
            { 0,    { hand_max_scale * .3, hand_max_scale * .3} },
            { .2,   { hand_max_scale * .7, hand_max_scale * .7} },
            { 1,    { hand_max_scale, hand_max_scale } },
        }
    )

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

    -- smoke
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 64) },
            { .2,   IntColour(0, 0, 0, 256) },
            { .75,  IntColour(0, 0, 0, 256) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local smoke_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale * .3, smoke_max_scale * .3} },
            { .2,   { smoke_max_scale, smoke_max_scale} },
            { 1,    { smoke_max_scale * .7, smoke_max_scale * .7 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local POINT_MAX_LIFETIME = 8
local HAND_MAX_LIFETIME = 3
local SMOKE_MAX_LIFETIME = 4

local function emit_point_fn(effect, get_pos_and_speed_fn)
    local pos,speed,lifetime = get_pos_and_speed_fn()
    local px, py, pz = pos:Get()
    local vx, vy, vz = speed:Get()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end


local function emit_hand_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px,py,pz):GetNormalized() * 0.08):Get()
    vy = math.random() * 0.04
    --offset the flame particles upwards a bit so they can be used on a torch

    local uv_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        1,
        HAND_MAX_LIFETIME,  -- lifetime
        px, py, pz,   -- position
        vx, vy, vz,         -- velocity
        0,                  --* 2 * PI, -- angle
        UnitRand(),         -- angle velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_smoke_fn(effect, sphere_emitter)
    local px, py, pz = sphere_emitter()
    py = 0
    local vx, vy, vz = (Vector3(px,py,pz):GetNormalized() * 0.2):Get()

    effect:AddRotatingParticle(
        2,
        HAND_MAX_LIFETIME,  -- lifetime
        px, py, pz,   -- position
        vx, vy, vz,         -- velocity
        0,                  --* 2 * PI, -- angle
        UnitRand()         -- angle velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false    

    inst._emit_point = net_bool(inst.GUID,"inst._emit_point")
    inst._emit_final_smoke = net_bool(inst.GUID,"inst._emit_final_smoke")
    inst._emit_outer = net_bool(inst.GUID,"inst._emit_outer")

    inst._emit_point:set(true)
    inst._emit_final_smoke:set(false)
    inst._emit_outer:set(false)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    --SPARKLE
    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 1024)
    effect:SetMaxLifetime(0, POINT_MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .02)
    effect:SetGroundPhysics(0, true)

    effect:SetRenderResources(1, ANIM_HAND_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(1, 32)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, HAND_MAX_LIFETIME)
    effect:SetColourEnvelope(1, HAND_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, HAND_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, .001)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(2, true)
    effect:SetDragCoefficient(2, .03)

    local sphere_emitter = CreateSphereEmitter(1)
    local sphere_emitter_outer = CreateSphereEmitter(0.5)
    local sphere_emitter_hand = CreateSphereEmitter(0.2)

    local get_pos_and_speed_fn_inner = function()
        local lifetime = (POINT_MAX_LIFETIME - 4) * (.7 + UnitRand() * .3)
        local px,py,pz = sphere_emitter()

        py = py + 10

        local vx = (-0.02 * px / lifetime) + UnitRand() * 0.002
        local vy = (-0.1 * py / lifetime) + UnitRand() * 0.002
        local vz = (-0.02 * pz / lifetime) + UnitRand() * 0.002

        return Vector3(px,py,pz),Vector3(vx,vy,vz),lifetime
    end

    local get_pos_and_speed_fn_outer = function()
        local lifetime = (POINT_MAX_LIFETIME - 4) * (.7 + UnitRand() * .3)
        local px,py,pz = sphere_emitter_outer()

        local vx = (0.02 / lifetime) + UnitRand() * 0.002
        local vy = (1 / lifetime) + UnitRand() * 0.002
        local vz = (0.02 / lifetime) + UnitRand() * 0.002

        return Vector3(px,py,pz),Vector3(vx,vy,vz),lifetime
    end
    

    EmitterManager:AddEmitter(inst, nil, function()
        if inst._emit_point:value() then
            emit_point_fn(effect,get_pos_and_speed_fn_inner)
        end

        if inst._emit_outer:value() then
            for i = 1,3 do
                emit_point_fn(effect,get_pos_and_speed_fn_outer)
            end
            
        end
        
        if inst._emit_final_smoke:value() then
            for i = 1,math.random(7,9) do
                emit_hand_fn(effect,sphere_emitter_hand)
            end

            for i = 1,math.random(10,15) do
                emit_smoke_fn(effect,sphere_emitter_hand)
            end
            
            inst:Remove()
        end 
    end)


    return inst
end

-- c_findnext("skeleton"):SpawnChild("gale_shadow_emerge_vfx")
-- ThePlayer:SpawnChild("gale_shadow_emerge_vfx")
return Prefab("gale_shadow_emerge_vfx", fn, assets)