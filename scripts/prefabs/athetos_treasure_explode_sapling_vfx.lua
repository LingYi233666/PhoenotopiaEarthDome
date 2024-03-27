local GLITCH_TEXTURE = resolvefilepath("fx/athetos_treasure_sapling.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "athetos_treasure_explode_sapling_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "athetos_treasure_explode_sapling_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", GLITCH_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0, IntColour(255, 255, 255, 255) },
        { 1, IntColour(255, 255, 255, 255) },
    })

    local glitch_max_scale = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { glitch_max_scale, glitch_max_scale } },
            { 0.2,    { glitch_max_scale, glitch_max_scale } },
            { 1,    { glitch_max_scale * 0.01, glitch_max_scale * 0.01 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.33

local function emit_glitch_fn(effect, emitter,u_offset,v_offset)
    local vx, vy, vz = .4 * UnitRand(), GetRandomMinMax(-0.02,0.2), .4 * UnitRand()
    -- local vx, vy, vz = 0,0,0
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = emitter()

    local angle = math.random() * 360
    local ang_vel = UnitRand() * 66

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px,py,pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        u_offset, v_offset        -- uv offset
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

    --GLITCH
    effect:SetRenderResources(0, GLITCH_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 1/8, 1/8)
    effect:SetMaxNumParticles(0, 1024)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetDragCoefficient(0,0.1)

    -----------------------------------------------------
    -- local sphere_emitter = CreateSphereEmitter(0.5)
    -- local box_emitter = CreateBoxEmitter(-0.33,0.5,-0.33,
    --                                     0.33,3,0.33)

    -- local sphere_emitter = CreateSphereEmitter(0.5)
    -- local box_emitter = function()
    --     local x,y,z = sphere_emitter()
    --     return x,y + 0.5,z
    -- end
    local box_emitter = function()
        return GetRandomMinMax(-0.33,0.33),GetRandomMinMax(0,5),GetRandomMinMax(-0.33,0.33)
    end

    local spawned = false 
    EmitterManager:AddEmitter(inst, nil, function()
        if not spawned then
            for x = 1,6 do
                for y=0,7 do
                    emit_glitch_fn(effect, box_emitter,x/8,y/8)
                end
            end
            spawned = true 
        end
        
    end)

    return inst
end

return Prefab("athetos_treasure_explode_sapling_vfx", fn, assets)
