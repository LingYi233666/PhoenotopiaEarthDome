local SPARKLE_TEXTURE = "fx/smoke.tex" --resolvefilepath("fx/ly_lightningsheet.tex") 

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_magicgas_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_magicgas_vfx_scaleenvelope"

local RED_COLOUR_ENVELOPE_NAME = "gale_magicgas_vfx_red_colourenvelope"
local RED_SCALE_ENVELOPE_NAME = "gale_magicgas_vfx_red_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0, IntColour(25, 40, 170, 255) },
        { 0.75, IntColour(0, 40, 170, 125) },
        { 1, IntColour(0, 40, 170, 0) },
    })

    local sparkle_max_scale = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(RED_COLOUR_ENVELOPE_NAME, {
        { 0,    IntColour(225, 15, 15, 0) },
        { .3,   IntColour(200, 12, 12, 100) },
        { .55,  IntColour(198, 10, 10, 28) },
        { 1,    IntColour(198, 10, 10, 0) },
    })

    EnvelopeManager:AddVector2Envelope(
        RED_SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.66

local function emit_bluefx_fn(effect, sphere_emitter)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

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

local function emit_redfx_fn(effect, sphere_emitter)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360    
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5
    effect:AddRotatingParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
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

    -- print("gale_magicgas_vfx spawned !")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    effect:SetRenderResources(1, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetMaxNumParticles(1, 256)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, RED_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, RED_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)

    local sphere_emitter = CreateSphereEmitter(0.05)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent then
            if parent.AnimState:IsCurrentAnimation("atk_prop")
                or parent.AnimState:IsCurrentAnimation("atk_prop_pre") then
                local anim_time = parent.AnimState:GetCurrentAnimationTime()

                if anim_time <= 0.47 then
                    local num_to_emit = GetRandomMinMax(5,6)
                    while num_to_emit > 1 do
                        emit_bluefx_fn(effect,sphere_emitter)
                        num_to_emit = num_to_emit - 1
                    end
                end
                
            elseif parent.AnimState:IsCurrentAnimation("multithrust") then
                local num_to_emit = GetRandomMinMax(5,6)
                while num_to_emit > 1 do
                    emit_redfx_fn(effect,sphere_emitter)
                    num_to_emit = num_to_emit - 1
                end
            end
        end
        
    end)

    return inst
end

return Prefab("gale_magicgas_vfx", fn, assets)
