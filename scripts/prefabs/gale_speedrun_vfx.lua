local POINT_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_COLOUR_ENVELOPE_NAME = "gale_speedrun_vfx_point_colourenvelope"
local POINT_SCALE_ENVELOPE_NAME = "gale_speedrun_vfx_point_scaleenvelope"

local ARROW_COLOUR_ENVELOPE_NAME = "gale_speedrun_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "gale_speedrun_vfx_arrow_scaleenvelope"

local SMOKE_COLOUR_ENVELOPE_NAME = "gale_speedrun_vfx_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "gale_speedrun_vfx_smoke_scaleenvelope"

local GaleCommon = require("util/gale_common")

local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(232, 160, 0, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(232, 160, 0, 255) })

    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 0.33
    EnvelopeManager:AddVector2Envelope(
        POINT_SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 90, 70, 180) },
            { .2,   IntColour(255, 120, 90, 255) },
            { .8,   IntColour(255, 90, 70, 175) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local arrow_max_scale_width = 1
    local arrow_max_scale_height = 1.9
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {   

            { 0,    { arrow_max_scale_width * 0.05, arrow_max_scale_height * 0.05 } },
            { 0.3,    { arrow_max_scale_width, arrow_max_scale_height} },
            { 0.8,    { arrow_max_scale_width * 0.1, arrow_max_scale_height * 0.1} },
            { 1,    { arrow_max_scale_width * 0.05, arrow_max_scale_height * 0.05} },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(105, 105, 105, 40) },
            { 0.33,    IntColour(105, 105, 105, 125) },
            { 1,    IntColour(105, 105, 105, 0) },
        }
    )

    local circle_max_scale = 0.22
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { circle_max_scale, circle_max_scale } },
            { 1,    { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.3
local ARROW_MAX_LIFETIME = 0.45
local SMOKE_MAX_LIFETIME = 0.9

local function emit_point_fn(effect, sphere_emitter)
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .2 * UnitRand(), 0, .2 * UnitRand()

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


local function emit_arrow_fn(effect,init_pos,speed)            
    local lifetime = ARROW_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = init_pos:Get()
    local vx, vy, vz = speed:Get()

    local uv_offset = math.random(2, 3) * .25
    
    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,          -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_smoke_fn(effect, sphere_emitter,pos_offset)

    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()

    px = px + pos_offset.x
    py = py + pos_offset.y
    pz = pz + pos_offset.z

    effect:AddRotatingParticle(
        2,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 0.1      -- angle velocity
    )
end

local function WrapSpeedFn(offset_speed)
    local sz = 0.05
    local base_speed = Vector3(sz * UnitRand(), 0.75 * sz * math.random(), sz * UnitRand())

    return base_speed + offset_speed
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

    --SPARKLE
    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .08)

    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 128)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, .1)
    effect:SetRotateOnVelocity(1, true)
    effect:SetAcceleration(1, 0, -0.2, 0)
    -- effect:SetFollowEmitter(1,true)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:SetSortOrder(2, 0)
    effect:SetSortOffset(2, 1)
    effect:SetRadius(2, 3) --only needed on a single emitter
    effect:SetDragCoefficient(2, .16)

    local sphere_emitter = CreateSphereEmitter(0.1)

    inst.last_emit_arrow_pos = nil 
    inst.last_emit_smoke_pos = nil 

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not parent then
            inst:Remove()
            return 
        end

        local cur_pos = parent:GetPosition()
        local facing = parent.Transform:GetFacing()

        if not inst.last_emit_arrow_pos and not inst.last_emit_smoke_pos then
            inst.last_emit_arrow_pos = cur_pos
            inst.last_emit_smoke_pos = cur_pos
            return 
        end

        if (cur_pos - inst.last_emit_arrow_pos):Length() >= 0.01 then

            local speed_offset = Vector3(0,0,0)
            local init_pos = Vector3(0,0,0)
            local face_vec = GaleCommon.GetFaceVector(parent)

            if facing == 0 then
                speed_offset = -TheCamera:GetRightVec() * 0.12 - TheCamera:GetDownVec() * 0.15
                init_pos = TheCamera:GetRightVec() * 1
            elseif facing == 1 then
                speed_offset = - face_vec * 0.12 + Vector3(0,0.15,0)
                init_pos = face_vec * 1
            elseif facing == 2 then
                speed_offset = TheCamera:GetRightVec() * 0.12 - TheCamera:GetDownVec() * 0.15
                init_pos = -TheCamera:GetRightVec() * 1
            elseif facing == 3 then
                speed_offset = - face_vec * 0.12 + Vector3(0,0.15,0)
                init_pos = face_vec * 1
            end

            for i=1,math.random(4,6) do
                emit_arrow_fn(effect,init_pos + Vector3(sphere_emitter()),WrapSpeedFn(speed_offset))
            end

            inst.last_emit_arrow_pos = cur_pos
        end

        if (cur_pos - inst.last_emit_smoke_pos):Length() >= 1.2 then
            emit_smoke_fn(effect,sphere_emitter,Vector3(0,1,0))

            inst.last_emit_smoke_pos = cur_pos
        end
        


    end)


    return inst
end

-- ThePlayer:SpawnChild("gale_speedrun_vfx").Transform:SetPosition(0,2,0)
return Prefab("gale_speedrun_vfx", fn, assets)
