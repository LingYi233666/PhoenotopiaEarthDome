local ANIM_SMOKE_TEXTURE = resolvefilepath("fx/deadcell_explode1.tex")
local ANIM_SMOKE2_TEXTURE = resolvefilepath("fx/deadcell_explode2.tex")
local ANIM_SMOKE_MIST_TEXTURE = resolvefilepath("fx/deadcell_mist_orb.tex")
local SMOKE_TEXTURE = "fx/animsmoke.tex"
local TAIL_TEXTURE = resolvefilepath("fx/snow.tex")
local SPIKE_TEXTURE = "fx/snow.tex"


local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "gale_skill_kinetic_blast_projectile_vfx_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_smoke"

local COLOUR_ENVELOPE_NAME_SMOKE_PURPLE = "gale_skill_kinetic_blast_projectile_vfx_colourenvelope_smoke_purple"
local SCALE_ENVELOPE_NAME_SMOKE_PURPLE = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_smoke_purple"

local COLOUR_ENVELOPE_NAME_SMOKE_DARK = "gale_skill_kinetic_blast_projectile_vfx_colourenvelope_smoke_dark"
local SCALE_ENVELOPE_NAME_SMOKE_DARK = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_smoke_dark"

local COLOUR_ENVELOPE_NAME_TAIL = "gale_skill_kinetic_blast_projectile_vfx_colourenvelope_tail"
local SCALE_ENVELOPE_NAME_TAIL = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_tail"

local SCALE_ENVELOPE_NAME_SMOKE_CARRY = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_smoke_carry"

local SCALE_ENVELOPE_NAME_SMOKE_DARK_CARRY = "gale_skill_kinetic_blast_projectile_vfx_scaleenvelope_smoke_dark_carry"


local COLOUR_ENVELOPE_NAME_WEAVER_SPIKE = "typhon_weaver_create_phantom_vfx_colourenvelope_spike"
local SCALE_ENVELOPE_NAME_WEAVER_SPIKE = "typhon_weaver_create_phantom_vfx_scaleenvelope_spike"


local GaleCommon = require("util/gale_common")


local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE2_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_MIST_TEXTURE),
    Asset("IMAGE", SMOKE_TEXTURE),
    Asset("IMAGE", SPIKE_TEXTURE),


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
            { 0,   IntColour(250, 200, 0, 64) },
            { 0.1, IntColour(250, 200, 0, 100) },
            { 0.8, IntColour(250, 200, 0, 10) },
            { 1,   IntColour(0, 0, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE_DARK,
        {
            { 0,   IntColour(0, 0, 0, 64) },
            { .2,  IntColour(0, 0, 0, 150) },
            { .75, IntColour(0, 0, 0, 150) },
            { 1,   IntColour(0, 0, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_TAIL,
        {
            { 0,   IntColour(255, 200, 0, 100) },
            { 0.1, IntColour(255, 200, 0, 60) },
            { 0.6, IntColour(255, 200, 0, 30) },
            { 1,   IntColour(255, 200, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE_PURPLE,
        {
            { 0,   IntColour(171, 109, 255, 100) },
            { 0.1, IntColour(171, 109, 255, 60) },
            { 0.6, IntColour(171, 109, 255, 30) },
            { 1,   IntColour(171, 109, 255, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_WEAVER_SPIKE,
        {
            { 0,   IntColour(199, 159, 255, 60) },
            { 0.1, IntColour(199, 159, 255, 200) },
            { 0.6, IntColour(199, 159, 255, 100) },
            { 1,   IntColour(199, 159, 255, 0) },
        }
    )


    local smoke_max_scale = 0.55
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,  { smoke_max_scale * 0.66, smoke_max_scale * 0.66 } },
            { .5, { smoke_max_scale, smoke_max_scale } },
            { 1,  { smoke_max_scale * 0.4, smoke_max_scale * 0.4 } },
        }
    )

    local smoke_max_scale = 0.8
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_PURPLE,
        {
            { 0,  { smoke_max_scale * 0.66, smoke_max_scale * 0.66 } },
            { .5, { smoke_max_scale, smoke_max_scale } },
            { 1,  { smoke_max_scale * 0.4, smoke_max_scale * 0.4 } },
        }
    )

    smoke_max_scale = 0.66
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_DARK,
        {
            { 0,  { smoke_max_scale, smoke_max_scale } },
            { .5, { smoke_max_scale * 1.1, smoke_max_scale * 1.1 } },
            { 1,  { smoke_max_scale, smoke_max_scale } },
        }
    )

    smoke_max_scale = 1.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_TAIL,
        {
            { 0, { smoke_max_scale, smoke_max_scale } },
            { 1, { smoke_max_scale, smoke_max_scale } },
        }
    )



    smoke_max_scale = 0.55
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_CARRY,
        {
            { 0,  { smoke_max_scale * 0.1, smoke_max_scale * 0.1 } },
            { .5, { smoke_max_scale, smoke_max_scale } },
            { 1,  { smoke_max_scale * 0.4, smoke_max_scale * 0.4 } },
        }
    )

    smoke_max_scale = 0.66
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_DARK_CARRY,
        {
            { 0,  { smoke_max_scale * 0.1, smoke_max_scale * 0.1 } },
            { .5, { smoke_max_scale * 1.1, smoke_max_scale * 1.1 } },
            { 1,  { smoke_max_scale, smoke_max_scale } },
        }
    )


    local spike_max_scale = 16.0
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_WEAVER_SPIKE,
        {
            { 0, { spike_max_scale * 0.1, spike_max_scale } },
            { 1, { spike_max_scale * 0.001, spike_max_scale * 0.1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = 0.5
local SMOKE_DARK_MAX_LIFETIME = 1.25
local TAIL_MAX_LIFETIME = 0.9

local SMOKE_CARRY_MAX_LIFETIME = 0.75
local SMOKE_DARK_CARRY_MAX_LIFETIME = 1.5
local SPIKE_MAX_LIFETIME = 1

local function emit_smoke_fn(effect)
    local vx, vy, vz = 0, 0, 0
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0, 0, 0

    effect:AddRotatingParticle(
        0,
        lifetime,                   -- lifetime
        px, py, pz,                 -- position
        vx, vy, vz,                 -- velocity
        GetRandomMinMax(-180, 180), --* 2 * PI, -- angle
        0                           -- angle velocity
    )
end

local function emit_smoke_dark_fn(effect)
    local vx, vy, vz = .01 * UnitRand(), .01 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_DARK_MAX_LIFETIME * (.9 + UnitRand() * .1)

    effect:AddRotatingParticle(
        1,
        lifetime,            -- lifetime
        0, 0, 0,             -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end

local function emit_tail_fn(effect, pos, v)
    pos = pos or Vector3(0, 0, 0)
    v = v or Vector3(0, 0, 0)
    local lifetime = TAIL_MAX_LIFETIME * (.9 + math.random() * .1)

    -- effect:AddParticleUV(
    --     2,
    --     lifetime,           -- lifetime
    --     pos.x,pos.y,pos.z,    -- position
    --     v.x,v.y,v.z,          -- velocity
    --     0, 0        -- uv offset
    -- )
    effect:AddParticle(
        2,
        lifetime,            -- lifetime
        pos.x, pos.y, pos.z, -- position
        v.x, v.y, v.z        -- velocity
    )
end

local function emit_smoke_carry_fn(effect)
    local vx, vy, vz = 0, 0, 0
    local lifetime = SMOKE_CARRY_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0, 0, 0

    effect:AddRotatingParticle(
        0,
        lifetime,                   -- lifetime
        px, py, pz,                 -- position
        vx, vy, vz,                 -- velocity
        GetRandomMinMax(-180, 180), --* 2 * PI, -- angle
        0                           -- angle velocity
    )
end

local function emit_smoke_dark_carry_fn(effect)
    local vx, vy, vz = .01 * UnitRand(), .01 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_DARK_CARRY_MAX_LIFETIME * (.9 + UnitRand() * .1)

    effect:AddRotatingParticle(
        1,
        lifetime,            -- lifetime
        0, 0, 0,             -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end

local function emit_spike_fn(effect, sphere_emitter)
    local lifetime = SPIKE_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(-0.3, -0.2)):Get()
    -- vy = math.abs(vy)

    effect:AddParticle(
        2,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._static = net_bool(inst.GUID, "inst._static", "staticdirty")
    inst._use_tail = net_bool(inst.GUID, "inst._use_tail")

    inst._use_tail:set(false)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("staticdirty", function()
            if inst._static:value() == true then
                inst.VFXEffect:SetDragCoefficient(2, 99999)
            end
        end)
    end


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    effect:SetRenderResources(0, ANIM_SMOKE_MIST_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 512)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)

    effect:SetRenderResources(1, SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, SMOKE_DARK_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_DARK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_DARK)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetSortOffset(1, 1)
    effect:SetFollowEmitter(1, true)
    effect:SetRotationStatus(1, true)

    effect:SetRenderResources(2, TAIL_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 102400)
    -- effect:SetUVFrameSize(2,0.25,1)
    effect:SetMaxLifetime(2, TAIL_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_TAIL)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_TAIL)
    effect:SetBlendMode(2, BLENDMODE.Additive) --AlphaBlended Premultiplied
    effect:SetSortOffset(2, 3)
    effect:SetFollowEmitter(2, true)
    -- effect:SetDragCoefficient(2,0.02)

    inst.smoke_sum = 1
    inst.smoke_dark_sum = 1
    inst.angle = math.random() * 2 * PI


    EmitterManager:AddEmitter(inst, nil, function()
        inst.smoke_sum = inst.smoke_sum + FRAMES * 7
        while inst.smoke_sum > 0 do
            inst.smoke_sum = inst.smoke_sum - 1
            emit_smoke_fn(effect)
        end


        inst.smoke_dark_sum = inst.smoke_dark_sum + FRAMES * 7
        while inst.smoke_dark_sum > 0 do
            inst.smoke_dark_sum = inst.smoke_dark_sum - 1
            emit_smoke_dark_fn(effect)
        end

        if inst._use_tail:value() == false then
            return
        end

        local parent = inst.entity:GetParent()
        local height = 0
        if parent then
            local rad = 0.66
            local back_speed = 0.4
            local face_vec = GaleCommon.GetFaceVector(parent)
            local crossed = face_vec:Cross(Vector3(0, 1, 0)):GetNormalized()
            local mid_pos = -face_vec * 0.2

            local old_angle = inst.angle
            local angle_delta = 6 * PI / 180
            inst.angle = inst.angle + angle_delta

            for ag = old_angle, inst.angle, angle_delta / 3 do
                for ag_tri = ag, ag + 4 * PI / 3, 2 * PI / 3 do
                    local x = math.cos(ag_tri) * rad
                    local y = math.sin(ag_tri) * rad

                    local percent = (ag - old_angle) / angle_delta
                    local duration = (1 - percent)
                    local spawn_pos = crossed * x + Vector3(0, 1, 0) * y + mid_pos - face_vec * duration * back_speed

                    emit_tail_fn(effect, spawn_pos, face_vec * (-back_speed))
                end
            end
        end
    end)

    -- inst:DoTaskInTime(FRAMES,inst.Remove)

    return inst
end


local function carry_fn()
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

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    effect:SetRenderResources(0, ANIM_SMOKE_MIST_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 512)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_CARRY_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_CARRY)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)

    effect:SetRenderResources(1, SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, SMOKE_DARK_CARRY_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_DARK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_DARK_CARRY)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetSortOffset(0, 1)
    effect:SetFollowEmitter(1, true)
    effect:SetRotationStatus(1, true)


    inst.smoke_sum = 1
    inst.smoke_dark_sum = 1


    EmitterManager:AddEmitter(inst, nil, function()
        inst.smoke_sum = inst.smoke_sum + FRAMES * 7
        while inst.smoke_sum > 0 do
            inst.smoke_sum = inst.smoke_sum - 1
            emit_smoke_carry_fn(effect)
        end


        inst.smoke_dark_sum = inst.smoke_dark_sum + FRAMES * 7
        while inst.smoke_dark_sum > 0 do
            inst.smoke_dark_sum = inst.smoke_dark_sum - 1
            emit_smoke_dark_carry_fn(effect)
        end
    end)

    return inst
end

local function create_phantom_fn()
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

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    effect:SetRenderResources(0, ANIM_SMOKE_MIST_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 512)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_CARRY_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_PURPLE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_PURPLE)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied
    effect:SetSortOrder(0, 3)
    effect:SetSortOffset(0, 1)
    effect:SetFollowEmitter(0, true)

    effect:SetRenderResources(1, SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, SMOKE_DARK_CARRY_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_DARK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_DARK)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetFollowEmitter(1, true)
    effect:SetRotationStatus(1, true)

    --SPIKE
    effect:SetRenderResources(2, SPIKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 128)
    effect:SetMaxLifetime(2, SPIKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_WEAVER_SPIKE)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_WEAVER_SPIKE)
    effect:SetBlendMode(2, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(2, true)
    effect:SetSortOrder(2, 2)
    effect:SetSortOffset(2, 1)
    effect:SetDragCoefficient(2, .14)
    effect:SetRotateOnVelocity(2, true)
    effect:SetFollowEmitter(2, true)



    inst.smoke_sum = 1
    inst.smoke_dark_sum = 1
    inst.spike_sum = 1

    local sphere_emitter = CreateSphereEmitter(2)

    EmitterManager:AddEmitter(inst, nil, function()
        inst.smoke_sum = inst.smoke_sum + FRAMES * 7
        while inst.smoke_sum > 0 do
            inst.smoke_sum = inst.smoke_sum - 1
            emit_smoke_carry_fn(effect)
        end


        inst.smoke_dark_sum = inst.smoke_dark_sum + FRAMES * 7
        while inst.smoke_dark_sum > 0 do
            inst.smoke_dark_sum = inst.smoke_dark_sum - 1
            emit_smoke_dark_carry_fn(effect)
        end

        inst.spike_sum = inst.spike_sum + FRAMES * 16
        while inst.spike_sum > 0 do
            inst.spike_sum = inst.spike_sum - 1
            emit_spike_fn(effect, sphere_emitter)
        end
    end)

    return inst
end

-- ThePlayer:SpawnChild("typhon_weaver_create_phantom_vfx")
return Prefab("gale_skill_kinetic_blast_projectile_vfx", fn, assets),
    Prefab("gale_skill_kinetic_blast_carry_vfx", carry_fn, assets),
    Prefab("typhon_weaver_create_phantom_vfx", create_phantom_fn, assets)
