local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_WHITE = "athetos_iron_slug_steam_vfx_colourenvelope_white"
local COLOUR_ENVELOPE_NAME_YELLOW = "athetos_iron_slug_steam_vfx_colourenvelope_yellow"
local COLOUR_ENVELOPE_NAME_GREEN = "athetos_iron_slug_steam_vfx_colourenvelope_green"
local COLOUR_ENVELOPE_NAME_BROWN = "athetos_iron_slug_steam_vfx_colourenvelope_brown"

local SCALE_ENVELOPE_NAME = "athetos_iron_slug_steam_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

local color_index_set = {
    COLOUR_ENVELOPE_NAME_WHITE, --蒸汽
    COLOUR_ENVELOPE_NAME_GREEN,
    COLOUR_ENVELOPE_NAME_YELLOW,
    COLOUR_ENVELOPE_NAME_BROWN
}
--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_WHITE,
        {
            { 0,    IntColour(105, 105, 105, 0) },
            { 0.33, IntColour(105, 105, 105, 100) },
            { 1,    IntColour(105, 105, 105, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_GREEN,
        {
            { 0,    IntColour(20, 210, 108, 0) },
            { 0.33, IntColour(20, 210, 108, 100) },
            { 1,    IntColour(20, 210, 108, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_YELLOW,
        {
            { 0,    IntColour(236, 177, 35, 0) },
            { 0.33, IntColour(236, 177, 35, 100) },
            { 1,    IntColour(236, 177, 35, 0) },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_BROWN,
        {
            { 0,    IntColour(114, 81, 72, 0) },
            { 0.33, IntColour(114, 81, 72, 175) },
            { 1,    IntColour(114, 81, 72, 0) },
        }
    )

    local glow_max_scale = 0.17
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,  { glow_max_scale, glow_max_scale } },
            { .4, { glow_max_scale, glow_max_scale } },
            { 1,  { glow_max_scale * 0.33, glow_max_scale * 0.33 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local GLOW_MAX_LIFETIME = 1.7

local function emit_grow_fn(effect, emitter_fn, velocity)
    -- local vx, vy, vz = .005 * UnitRand(), 0, .005 * UnitRand()
    local vx, vy, vz = velocity:Get()
    local lifetime = GLOW_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = emitter_fn()

    local angle_velocity = GetRandomMinMax(3, 5) * (math.random() <= 0.5 and 1 or -1)

    effect:AddRotatingParticle(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        angle_velocity       -- angle velocity
    )
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._left_direction = net_bool(inst.GUID, "inst._left_direction")
    inst._left_direction:set(false)

    inst._color_index = net_tinybyte(inst.GUID, "inst._color_index", "color_index_dirty")
    inst._color_index:set(1)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("color_index_dirty", function()
            inst.VFXEffect:SetColourEnvelope(0, color_index_set[inst._color_index:value()])
        end)
    end


    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 8)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, GLOW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_WHITE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetAcceleration(0, 0, 0.08, 0)
    effect:SetDragCoefficient(0, 0.005)

    local sphere_emitter = CreateSphereEmitter(.001)

    local num_to_emit = 0
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        num_to_emit = num_to_emit + FRAMES * 3
        while num_to_emit > 0 do
            local velocity = Vector3(0, 1, 0) * GetRandomMinMax(0.01, 0.02)
            -- local velocity = Vector3(0, 0, 0)
            local right_vec = TheCamera:GetRightVec()
            local right_addition = right_vec * GetRandomMinMax(0.03, 0.05)

            local left_direction = inst._left_direction:value()
            local facing = parent.AnimState:GetCurrentFacing()

            -- if inst._left_direction:value() then
            --     velocity = velocity - right_addition
            -- else
            --     velocity = velocity + right_addition
            -- end
            if facing == FACING_RIGHT and not left_direction then
                velocity = velocity + right_addition
            elseif facing == FACING_RIGHT and left_direction then
                velocity = velocity - right_addition
            elseif facing == FACING_LEFT and not left_direction then
                velocity = velocity - right_addition
            elseif facing == FACING_LEFT and left_direction then
                velocity = velocity + right_addition
            else
                num_to_emit = 0
                return
            end


            emit_grow_fn(effect, sphere_emitter, velocity)

            num_to_emit = num_to_emit - 1
        end
    end)


    return inst
end
-- ThePlayer:SpawnChild("athetos_iron_slug_steam")
return Prefab("athetos_iron_slug_steam", fn, assets)
