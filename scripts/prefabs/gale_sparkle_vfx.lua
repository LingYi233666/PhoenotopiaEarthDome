local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_sparkle_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_sparkle_vfx_scaleenvelope"

local ARROW_COLOUR_ENVELOPE_NAME = "gale_sparkle_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "gale_sparkle_vfx_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
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
        table.insert(envs, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(0, 229, 232, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 0.88
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 229, 230, 180) },
            { .2,   IntColour(0, 229, 232, 255) },
            { .8,   IntColour(0, 229, 230, 175) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local arrow_max_scale = 2.8
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0,    { arrow_max_scale, arrow_max_scale } },
            { 1,    { arrow_max_scale * 0.01, arrow_max_scale * 0.01} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.75
local ARROW_MAX_LIFETIME = 1

local function emit_sparkle_fn(effect, sphere_emitter,target_pos)
    local target_pos_nor = target_pos:GetNormalized() * 0.25
    local vx, vy, vz = target_pos_nor:Get()
    local svx,svy,svz = CreateSphereEmitter(target_pos_nor:Length())()
    svy = svy < 0 and -svy or svy
    svy = Remap(svy,0,target_pos_nor:Length(),0,target_pos_nor:Length() + 0.2)

    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py + 1, pz,         -- position
        vx+svx, vy+svy, vz+svz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end


local function emit_arrow_fn(effect, sphere_emitter,target_pos)            
    local target_pos_nor = target_pos:GetNormalized() * 0.4
    local vx, vy, vz = target_pos_nor:Get()
    local svx,svy,svz = CreateSphereEmitter(target_pos_nor:Length())()
    svy = svy < 0 and -svy or svy
    svx = Remap(svx,0,target_pos_nor:Length(),0.1,target_pos_nor:Length())
    svz = Remap(svz,0,target_pos_nor:Length(),0.1,target_pos_nor:Length())

    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local uv_offset = math.random(0, 3) * .25
    
    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py + 1, pz,    -- position
        vx+svx, vy+svy, vz+svz,          -- velocity
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

    inst._target_pos_x = net_float(inst.GUID,"inst._target_pos_x")
    inst._target_pos_y = net_float(inst.GUID,"inst._target_pos_y")
    inst._target_pos_z = net_float(inst.GUID,"inst._target_pos_z")
    inst._can_emit = net_bool(inst.GUID,"inst._can_emit")
    inst._can_emit:set(false)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .1)

    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 25)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, .14)
    effect:SetRotateOnVelocity(1, true)
    effect:SetAcceleration(1, 0, -0.15, 0)

    local num_to_emit = GetRandomMinMax(15,20)
    local arrow_to_emit = Remap(num_to_emit,15,20,5,9)
    local sphere_emitter = CreateSphereEmitter(.25)

    EmitterManager:AddEmitter(inst, nil, function()
        while not inst._can_emit:value() do 

        end
        while num_to_emit > 0 do 
            emit_sparkle_fn(effect, sphere_emitter,Vector3(inst._target_pos_x:value(),inst._target_pos_y:value(),inst._target_pos_z:value()))
            num_to_emit = num_to_emit - 1
        end
        while arrow_to_emit > 0 do 
            emit_arrow_fn(effect, sphere_emitter,Vector3(inst._target_pos_x:value(),inst._target_pos_y:value(),inst._target_pos_z:value()))
            arrow_to_emit = arrow_to_emit - 1
        end
        -- inst:Remove()
    end)

    inst:DoTaskInTime(0.33,inst.Remove)

    return inst
end

return Prefab("gale_sparkle_vfx", fn, assets)
