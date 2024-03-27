local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local SPIKE_TEXTURE = "fx/confetti.tex"
local POINT_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SPIKE = "typhon_phantom_spike_vfx_colourenvelope_spike"
local SCALE_ENVELOPE_NAME_SPIKE = "typhon_phantom_spike_vfx_scaleenvelope_spike"
local SCALE_ENVELOPE_NAME_SPIKE_LARGE = "typhon_phantom_spike_vfx_scaleenvelope_spike_large"


local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", SPIKE_TEXTURE),
    Asset("IMAGE", POINT_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local spike_colours = {}
    for i = 0, 4 do
        if i % 2 == 0 then
            table.insert(spike_colours, { i * 0.2, IntColour(0, 0, 0, 255) })
        else
            table.insert(spike_colours, { i * 0.2, IntColour(60, 0, 10, 255) })
        end
    end
    table.insert(spike_colours, { 1, IntColour(0, 0, 0, 0) })
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SPIKE,
        spike_colours
    )



    -- local spike_max_scale = 12.0
    local spike_max_scale = 4

    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPIKE,
        {
            { 0,   { spike_max_scale * 0.15 * 0.1, spike_max_scale } },
            { 0.5, { spike_max_scale * 0.15 * 0.9, spike_max_scale * 0.9 } },
            { 1,   { spike_max_scale * 0.15 * 0.1, spike_max_scale } },
        }
    )

    spike_max_scale = 8
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPIKE_LARGE,
        {
            { 0,   { spike_max_scale * 0.15 * 0.1, spike_max_scale * 0.6 } },
            { 0.5, { spike_max_scale * 0.15 * 0.9, spike_max_scale * 0.7 } },
            { 1,   { spike_max_scale * 0.15 * 0.1, spike_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SPIKE_MAX_LIFETIME = 1.5
local SPIKE_LARGE_MAX_LIFETIME = 2.5

local function emit_spike_offset_0_fn(effect, sphere_emitter)
    local lifetime = SPIKE_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 1e-3):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_spike_offset_1_fn(effect, sphere_emitter)
    local lifetime = SPIKE_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 1e-3):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_spike_large_fn(effect, sphere_emitter)
    local lifetime = SPIKE_LARGE_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 1e-3):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        2,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
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
    effect:InitEmitters(4)

    --SPIKE_OFFSET_0
    effect:SetRenderResources(0, SPIKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, SPIKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SPIKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SPIKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetDragCoefficient(0, .14)
    effect:SetRotateOnVelocity(0, true)
    effect:SetFollowEmitter(0, true)
    effect:EnableDepthTest(0, true)
    effect:SetSortOffset(0, 0)
    -- effect:SetKillOnEntityDeath(0, true)


    --SPIKE_OFFSET_1
    effect:SetRenderResources(1, SPIKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 128)
    effect:SetMaxLifetime(1, SPIKE_LARGE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SPIKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SPIKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetDragCoefficient(1, .14)
    effect:SetRotateOnVelocity(1, true)
    effect:SetFollowEmitter(1, true)
    effect:EnableDepthTest(1, true)
    effect:SetSortOffset(1, 1)
    -- effect:SetKillOnEntityDeath(1, true)

    --SPIKE_LARGE
    effect:SetRenderResources(2, SPIKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 16)
    effect:SetMaxLifetime(2, SPIKE_LARGE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_SPIKE)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_SPIKE_LARGE)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(2, true)
    effect:SetUVFrameSize(2, 0.25, 1)
    effect:SetDragCoefficient(2, .14)
    effect:SetRotateOnVelocity(2, true)
    effect:SetFollowEmitter(2, true)
    effect:EnableDepthTest(2, true)
    effect:SetSortOffset(2, 0)
    -- effect:SetKillOnEntityDeath(2, true)

    -----------------------------------------------------
    -- local sphere_emiter = CreateSphereEmitter()

    local function common_emitter(bx, radius)
        local base_x = bx:GetNormalized()
        local base_y = Vector3(0, 1, 0)
        local base_z = base_y:Cross(base_x)

        local x = GetRandomMinMax(0, radius)
        local remain = math.sqrt(radius * radius - x * x)
        local t = math.random() * PI2
        local y = math.cos(t) * remain
        local z = math.sin(t) * remain

        return (base_x * x + base_y * y + base_z * z):Get()
    end

    local spike_sphere_emitters = {
        [FACING_RIGHT] = function()
            return common_emitter(-TheCamera:GetRightVec(), 0.7)
        end,
        [FACING_UP] = function()
            return common_emitter(TheCamera:GetDownVec(), 0.7)
        end,
        [FACING_LEFT] = function()
            return common_emitter(TheCamera:GetRightVec(), 0.7)
        end,
        [FACING_DOWN] = function()
            return common_emitter(-TheCamera:GetDownVec(), 0.7)
        end,
    }

    local num_to_emit_spike = 3
    local num_to_emit_spike_large = 1
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if not (parent and parent.entity:IsVisible()) then
            return
        end
        local upperbpdy = parent._upper_body and parent._upper_body:value()

        local facing = (upperbpdy or parent).Transform:GetFacing()
        local emitterfn = spike_sphere_emitters[facing]

        if emitterfn == nil then
            num_to_emit_spike = 0
        else
            while num_to_emit_spike > 0 do
                emit_spike_offset_0_fn(effect, emitterfn)
                emit_spike_offset_1_fn(effect, emitterfn)
                num_to_emit_spike = num_to_emit_spike - 1
            end

            while num_to_emit_spike_large > 0 do
                emit_spike_large_fn(effect, emitterfn)
                num_to_emit_spike_large = num_to_emit_spike_large - 1
            end
        end

        -- if facing == FACING_DOWN then
        --     effect:SetSortOffset(0, 0)
        --     effect:SetSortOffset(1, 0)
        -- else
        --     effect:SetSortOffset(0, 1)
        --     effect:SetSortOffset(1, 1)
        -- end


        num_to_emit_spike = num_to_emit_spike + 0.2
        num_to_emit_spike_large = num_to_emit_spike_large + 0.02
    end)

    return inst
end

return Prefab("typhon_phantom_spike_vfx", fn, assets)
