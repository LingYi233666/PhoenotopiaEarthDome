local GaleCommon = require("util/gale_common")

local RECT_TEXTURE = resolvefilepath("fx/rect_vfx.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "athetos_operator_medical_scan_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "athetos_operator_medical_scan_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", RECT_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,   IntColour(255, 0, 0, 0) },
        { 0.3, IntColour(255, 0, 0, 255) },
        { 0.8, IntColour(255, 0, 0, 255) },
        { 1,   IntColour(200, 0, 0, 0) },
    })

    local rect_max_scale = 3.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { rect_max_scale * 0.01, rect_max_scale * 0.01 } },
            { 1, { rect_max_scale, rect_max_scale * 2 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.33

local function emit_rect_fn(effect, direction_vec)
    local vx, vy, vz = direction_vec:Get()
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = 0, 0, 0

    -- local angle = math.random() * 360
    -- local ang_vel = (UnitRand() - 1) * 5
    local angle = 0
    local ang_vel = 0

    effect:AddRotatingParticle(
        0,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
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
    effect:InitEmitters(1)

    --RECT
    effect:SetRenderResources(0, RECT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetFollowEmitter(0, true)
    -- effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetSpawnVectors(0,
                           1, 0, 0,
                           0, 1, 0
    )

    -----------------------------------------------------

    local num_to_emit = 1

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent == nil then
            return
        end
        if TheCamera == nil then
            return
        end


        local direction_vec = GaleCommon.GetFaceVector(parent)
        direction_vec.y = direction_vec.y - 0.5

        local c_r = TheCamera:GetRightVec()
        effect:SetSpawnVectors(0,
                               c_r.x, c_r.y, c_r.z,
                               0, 1, 0
        )


        while num_to_emit > 1 do
            emit_rect_fn(effect, direction_vec * 0.2)
            num_to_emit = num_to_emit - 1
        end

        num_to_emit = num_to_emit + 1.0 / 3
    end)

    return inst

    -- c_findnext("athetos_operator_medical_scan_vfx").VFXEffect:SetSpawnVectors(0, 1, 0, 0,  0, 1, 0)
end

return Prefab("athetos_operator_medical_scan_vfx", fn, assets)
