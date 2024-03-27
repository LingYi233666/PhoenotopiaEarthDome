local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local EMBER_TEXTURE = "fx/wintersnow_cane.tex"
local CIRCLE_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "gale_ice_explode_vfx_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "gale_ice_explode_vfx_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME_EMBER = "gale_ice_explode_vfx_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "gale_ice_explode_vfx_scaleenvelope_ember"
local COLOUR_ENVELOPE_NAME_CIRCLE = "gale_ice_explode_vfx_colourenvelope_circle"
local SCALE_ENVELOPE_NAME_CIRCLE = "gale_ice_explode_vfx_scaleenvelope_circle"
local COLOUR_ENVELOPE_NAME_SMOKE2 = "gale_ice_explode_vfx_colourenvelope_smoke2"
local SCALE_ENVELOPE_NAME_SMOKE2 = "gale_ice_explode_vfx_scaleenvelope_smoke2"
local COLOUR_ENVELOPE_NAME_ARROW = "gale_ice_explode_vfx_colourenvelope_arrow"
local SCALE_ENVELOPE_NAME_ARROW = "gale_ice_explode_vfx_scaleenvelope_arrow"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", CIRCLE_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
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
            { 0,    IntColour(255, 247, 255, 0) },
            { 0.1,    IntColour(255, 239, 255, 90) },
            { .3,   IntColour(255, 239, 255, 150) },
            { .52,  IntColour(255, 239, 255, 90) },
            { 1,    IntColour(255, 239, 255, 0) },
        }
    )

    local smoke_max_scale = 0.7
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .5, smoke_max_scale * .5 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        {
            -- { 0,    IntColour(255, 255, 255, 25) },
            -- { .2,   IntColour(255, 255, 255, 255) },
            -- { .6,   IntColour(128, 128, 128, 255) },
            -- { 1,    IntColour(0, 0, 0, 0) },

            { 0,    IntColour(190, 247, 245, 25) },
            { .075,   IntColour(200, 250, 255, 200) },
            { .3,   IntColour(210, 255, 255, 255) },
            { .6,   IntColour(210, 255, 255, 255) },
            { .9,   IntColour(210, 255, 255, 230) },
            { 1,    IntColour(210, 247, 250, 0) },
        }
    )

    local ember_max_scale = 1.4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,    { ember_max_scale, ember_max_scale } },
            { 1,    { ember_max_scale * 0.5, ember_max_scale * 0.5 } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_CIRCLE,
        {
            { 0,    IntColour(145, 238, 248, 0)},
            { .075,   IntColour(145, 240, 250, 255)},
            { .3,   IntColour(145, 244, 255, 60) },
            { .6,   IntColour(145, 244, 255, 50) },
            { .9,   IntColour(145, 244, 255, 25) },
            { 1,    IntColour(145, 244, 255, 0) },
        }
    )

    local circle_max_scale = 17
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_CIRCLE,
        {
            { 0,    { circle_max_scale, circle_max_scale } },
            { 1,    { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE2,
        {
            { 0,    IntColour(255, 240, 255, 0)},
            { .2,   IntColour(255, 253, 255, 240)},
            { .3,   IntColour(200, 255, 255, 60) },
            { .6,   IntColour(230, 245, 245, 50) },
            { .9,   IntColour(255, 240, 245, 25) },
            { 1,    IntColour(255, 240, 244, 0) },
        }
    )

    local circle_max_scale = 1.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE2,
        {
            { 0,    { circle_max_scale, circle_max_scale } },
            { 1,    { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            { 0,    IntColour(255, 240, 240, 180) },
            { .2,   IntColour(255, 255, 255, 255) },
            { .6,   IntColour(255, 255, 255, 175) },
            { 1,    IntColour(255, 255, 255, 0) },
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
local EMBER_MAX_LIFETIME = 3
local SMOKE_MAX_LIFETIME = 2
local CIRCLE_MAX_LIFETIME = 0.6
local SMOKE2_MAX_LIFETIME = 0.5
local ARROW_MAX_LIFETIME = 1

local function emit_ember_fn(effect, sphere_emitter, adjust_vec)            
    
    local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.8,1.2)
    -- local vx, vy, vz = .17 * UnitRand(), .17 * math.random(), .17 * UnitRand()
    local vx,vy,vz = (vec + Vector3(0,GetRandomMinMax(0.04,0.17),0)):Get()
    local uv_offset = math.random(0, 7) * .125

    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py + .4, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,UnitRand() * 2, -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_smoke_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .3 * UnitRand(), .1 + .2 * UnitRand(), .3 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        1,
        lifetime,           -- lifetime
        px, py + .5, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function emit_circle_fn(effect, adjust_vec)
    local vx, vy, vz = 0,0,0
    local lifetime = CIRCLE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0,0,0
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        2,
        lifetime,           -- lifetime
        px, py + .4, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 0.1      -- angle velocity
    )
end

local function emit_smoke2_fn(effect, adjust_vec)
    local vx, vy, vz = 0,0,0
    local lifetime = SMOKE2_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0,0,0
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        3,
        lifetime,           -- lifetime
        px, py + .7, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2.5      -- angle velocity
    )
end

local function emit_arrow_fn(effect, sphere_emitter, adjust_vec)            
    local lifetime = ARROW_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()

    -- local vx, vy, vz = sz * UnitRand(), 3*sz * UnitRand(), sz * UnitRand()
    local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.5,0.6)
    -- local vx, vy, vz = .17 * UnitRand(), .17 * math.random(), .17 * UnitRand()
    local vx,vy,vz = vec:Get()
    
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end
    
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        4,
        lifetime,           -- lifetime
        px, py + .4, pz,    -- position
        vx, vy, vz,          -- velocity
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

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(5)

    --EMBER
    effect:SetRenderResources(0, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, .2)
    effect:SetUVFrameSize(0, .125, 1)
    effect:SetRotationStatus(0, true)
    effect:SetGroundPhysics(0, true)
    inst:DoTaskInTime(GetRandomMinMax(1,2.25),function()
        effect:SetDragCoefficient(0,0)
        effect:SetAcceleration(0,0,-0.3,0)
    end)


    --SMOKE
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(1, true)
    --effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetRadius(1, 3) --only needed on a single emitter
    effect:SetDragCoefficient(1, .1)

    --CIRCLE
    effect:SetRenderResources(2, CIRCLE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 1)
    effect:SetRotationStatus(2, true)
    effect:SetUVFrameSize(2, 0.25, 1)
    effect:SetMaxLifetime(2, CIRCLE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_CIRCLE)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_CIRCLE)
    effect:SetBlendMode(2, BLENDMODE.Additive) --AlphaBlended Premultiplied
    effect:SetSortOrder(2, 2)
    effect:SetSortOffset(2, 2)
    -- effect:SetRadius(2, 3) --only needed on a single emitter
    effect:SetDragCoefficient(2, .1)

    --SMOKE2
    effect:SetRenderResources(3, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(3, 1)
    effect:SetRotationStatus(3, true)
    effect:SetMaxLifetime(3, SMOKE2_MAX_LIFETIME)
    effect:SetColourEnvelope(3, COLOUR_ENVELOPE_NAME_SMOKE2)
    effect:SetScaleEnvelope(3, SCALE_ENVELOPE_NAME_SMOKE2)
    effect:SetBlendMode(3, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(1, true)
    --effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(3, 0)
    effect:SetSortOffset(3, 0)
    effect:SetRadius(3, 3) --only needed on a single emitter
    effect:SetDragCoefficient(3, .1)

    --ARROW
    effect:SetRenderResources(4, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(4, 25)
    effect:SetMaxLifetime(4, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(4, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(4, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(4, BLENDMODE.Additive)
    effect:EnableBloomPass(4, true)
    effect:SetUVFrameSize(4, 0.25, 1)
    effect:SetSortOrder(4, 0)
    effect:SetSortOffset(4, 0)
    effect:SetDragCoefficient(4, .14)
    effect:SetRotateOnVelocity(4, true)
    -- effect:SetAcceleration(4, 0, -0.3, 0)

    -----------------------------------------------------
    

    -- local ember_sphere_emitter = function()
    --     local rad = 0.25
    --     local theate = PI * 2 * math.random()
    --     local fai = PI * 0.5 * math.random()
    --     local x = rad * math.sin(theate) * math.cos(fai)
    --     local y = rad * math.sin(theate) * math.sin(fai)
    --     local z = rad * math.cos(theate)
    --     return x,y,z
    -- end
    local ember_sphere_emitter = CreateSphereEmitter(0.15)
    local smoke_sphere_emitter = CreateSphereEmitter(.2)
    local arrow_sphere_emitter = CreateSphereEmitter(.1)
    -- print("ember_sphere_emitter")

    local num_to_emit_ember = 80
    local num_to_emit_smoke = 75
    local num_to_emit_circle = 2
    local num_to_emit_arrow = 25

    EmitterManager:AddEmitter(inst, nil, function()
        -- print("start AddEmitter")
        
        while num_to_emit_circle > 1 do
            emit_circle_fn(effect)
            emit_smoke2_fn(effect)
            num_to_emit_circle = num_to_emit_circle - 1
        end 

        while num_to_emit_arrow > 1 do
            emit_arrow_fn(effect,arrow_sphere_emitter)
            num_to_emit_arrow = num_to_emit_arrow - 1
        end 

        while num_to_emit_ember > 1 do
            emit_ember_fn(effect, ember_sphere_emitter)
            num_to_emit_ember = num_to_emit_ember - 1
        end

        while num_to_emit_smoke > 1 do
            emit_smoke_fn(effect, smoke_sphere_emitter)
            num_to_emit_smoke = num_to_emit_smoke - 1
        end
    end)

    return inst
end
--local fx = ThePlayer:SpawnChild("gale_ice_explode_vfx") fx:DoTaskInTime(3,fx.Remove)
return Prefab("gale_ice_explode_vfx", fn, assets)
