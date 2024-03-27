local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"


local COLOUR_ENVELOPE_NAME_EMBER = "gale_superdash_vfx_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "gale_superdash_vfx_scaleenvelope_ember"
local COLOUR_ENVELOPE_NAME_ARROW = "gale_superdash_vfx_colourenvelope_arrow"
local SCALE_ENVELOPE_NAME_ARROW = "gale_superdash_vfx_scaleenvelope_arrow"

local GaleCommon = require("util/gale_common")
local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local ember_colour_envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(ember_colour_envs, { t, IntColour(200, 10, 10, 255) })
        t = t + step
        table.insert(ember_colour_envs, { t, IntColour(200, 10, 10, 200) })
        t = t + .01
    end
    table.insert(ember_colour_envs, { 1, IntColour(200, 5, 5, 0) })
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        ember_colour_envs
    )

    local ember_max_scale = 0.9
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,    { ember_max_scale, ember_max_scale } },
            { 1,    { ember_max_scale * 0.2, ember_max_scale * 0.2 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            { 0,    IntColour(200, 5, 5, 180) },
            { .2,   IntColour(210, 10, 10, 255) },
            { .6,   IntColour(200, 10, 10, 175) },
            { 1,    IntColour(200, 5, 5, 0) },
        }
    )
    local arrow_max_scale = 2.25
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0,    { arrow_max_scale, arrow_max_scale } },
            { 1,    { arrow_max_scale * 0.125, arrow_max_scale * 0.8} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local EMBER_MAX_LIFETIME = 8
local ARROW_MAX_LIFETIME = 1

local function emit_ember_fn(effect, sphere_emitter,vec)            
    local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx,vy,vz = vec:Get()

    effect:AddParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz         -- velocity
    )
end



local function emit_arrow_fn(effect, sphere_emitter, vec)            
    local lifetime = ARROW_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vx,vy,vz = vec:Get()
    
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,          -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._target_pos_x = net_float(inst.GUID,"inst._target_pos_x")
    inst._target_pos_y = net_float(inst.GUID,"inst._target_pos_y")
    inst._target_pos_z = net_float(inst.GUID,"inst._target_pos_z")
    inst._can_emit = net_bool(inst.GUID,"inst._can_emit")

    inst.SetTargetPos = function(inst,x,y,z)
        inst._target_pos_x:set(x)
        inst._target_pos_y:set(y)
        inst._target_pos_z:set(z)
        inst._can_emit:set(true)
    end

    inst:DoTaskInTime(5,inst.Remove)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --EMBER
    effect:SetRenderResources(0, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, -1)
    effect:SetDragCoefficient(0, .2)
    effect:SetAcceleration(0, 0, -0.1, 0)
    effect:SetGroundPhysics(0, true)

    --ARROW
    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 25)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, .14)
    effect:SetRotateOnVelocity(1, true)
    -- effect:SetAcceleration(4, 0, -0.3, 0)

    -----------------------------------------------------
    

    local common_sphere_emitter = CreateSphereEmitter(.1)
    local behind_arrow_sphere_emitter = CreateSphereEmitter(0.35)
    local behind_ember_sphere_emitter = CreateSphereEmitter(1.5)
    local num_to_emit_ember = 40
    local num_to_emit_arrow = 15
    EmitterManager:AddEmitter(inst, nil, function()
        if not inst._can_emit:value() then
            return
        end


        local parent = inst.entity:GetParent()
        local inst_to_tar = Vector3(inst._target_pos_x:value(),inst._target_pos_y:value(),inst._target_pos_z:value()) - parent:GetPosition()
        for i = 1,num_to_emit_ember do
            emit_ember_fn(effect,common_sphere_emitter,Vector3(behind_ember_sphere_emitter()))
        end

        for i = 1,num_to_emit_arrow do
            emit_arrow_fn(effect,common_sphere_emitter,-inst_to_tar:GetNormalized() + Vector3(behind_arrow_sphere_emitter()))
        end

        inst:Remove()
    end)

    return inst
end

return Prefab("gale_superdash_vfx", fn, assets)