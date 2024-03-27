local GaleCommon = require("util/gale_common")

local ARROW_TEXTURE = resolvefilepath("fx/spark.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local ARROW_COLOUR_ENVELOPE_NAME = "gale_blaster_katash_projectile_tail_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "gale_blaster_katash_projectile_tail_vfx_arrow_scaleenvelope"

local assets =
{
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
            { 0,    IntColour(255, 150, 2, 25) },
            { .075,   IntColour(255, 193, 5, 200) },
            { .3,   IntColour(255, 193, 5, 255) },
            { .6,   IntColour(255, 193, 50, 255) },
            { .9,   IntColour(255, 193, 161, 230) },
            { 1,    IntColour(255, 193, 175, 0) },
        }
    )

    local arrow_max_scale = 2
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0,    { arrow_max_scale * 0.1 , arrow_max_scale * 0.05} },
            { 0.2,    { arrow_max_scale * 0.4 , arrow_max_scale * 1} },
            { 1,    { arrow_max_scale * 0.002, arrow_max_scale * 0.2} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local ARROW_MAX_LIFETIME = 1

local function emit_arrow_fn(effect, sphere_emitter,pos,angle)            
    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx,vy,vz = pos:Get()

    local uv_offset = math.random(0, 3) * .25

    -- effect:AddRotatingParticleUV(
    --     0,
    --     lifetime,           -- lifetime
    --     px, py, pz,         -- position
    --     vx, vy, vz,         -- velocity
    --     angle, 0,     -- angle, angular_velocity
    --     uv_offset, 0        -- uv offset
    -- )
    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        uv_offset, 0        -- uv offset
    )
end
-- ThePlayer:SpawnChild("gale_blaster_katash_projectile_tail_vfx")
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false
    
    inst._sphere_emitter_rad = net_float(inst.GUID,"inst._sphere_emitter_rad","sphere_emitter_rad_dirty")
    inst._sphere_emitter_rad:set(0.1)

    inst:DoTaskInTime(5,inst.Remove)
    
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end 

        inst:ListenForEvent("sphere_emitter_rad_dirty",function()
            inst.sphere_emitter = CreateSphereEmitter(inst._sphere_emitter_rad:value())
        end)
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
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, 0.1)
    effect:SetRotateOnVelocity(0, true)
    -- effect:SetRotationStatus(0,true)
    -- effect:SetIsTrailEmitter(0,true)
    -- effect:SetFollowEmitter(0, true)
    -- effect:SetE
    -- effect:SetGroundPhysics(0, true)


    local tick_time = TheSim:GetTickTime()

    local desired_pps_low = 1
    local desired_pps_high = 8
    local low_per_tick = desired_pps_low * tick_time
    local high_per_tick = desired_pps_high * tick_time
    local num_to_emit = 0

    inst.last_pos = inst:GetPosition()
    inst.sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if parent then
            local dist_moved = inst:GetPosition() - inst.last_pos
            local move = dist_moved:Length()
            move = math.clamp(move*6, 0, 1)

            local per_tick = Lerp(low_per_tick, high_per_tick, move)

            inst.last_pos = inst:GetPosition()

            num_to_emit = num_to_emit + per_tick * math.random() * 3
            while num_to_emit > 1 do
                local face_vec = GaleCommon.GetFaceVector(parent)
                emit_arrow_fn(effect, inst.sphere_emitter,face_vec * GetRandomMinMax(0.25,0.33))
                num_to_emit = num_to_emit - 1
            end
            
        else 
            inst:Remove()
        end
        
    end)

    return inst
end

return Prefab("gale_blaster_katash_projectile_tail_vfx", fn, assets)
