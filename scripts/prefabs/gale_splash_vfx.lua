local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_ANIMSMOKE = "gale_splash_vfx_colourenvelope_animsmoke"
local SCALE_ENVELOPE_NAME_ANIMSMOKE = "gale_splash_vfx_scaleenvelope_animsmoke"

local COLOUR_ENVELOPE_NAME_ANIMSMOKE_BLACK = "gale_splash_vfx_colourenvelope_animsmoke_black"
local SCALE_ENVELOPE_NAME_ANIMSMOKE_BLACK = "gale_splash_vfx_scaleenvelope_animsmoke_black"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

-- ThePlayer:SpawnChild("gale_splash_vfx")
--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ANIMSMOKE,
        {
            { 0,    IntColour(177, 17, 22, 100) },
            { 0.05,    IntColour(182, 17, 22, 255) },
            { 1,    IntColour(175, 17, 22, 0) },
        }
    )

    local animsmoke_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ANIMSMOKE,
        {
            { 0,    { animsmoke_max_scale, animsmoke_max_scale} },
            { 1,    { animsmoke_max_scale * 0.6, animsmoke_max_scale * 0.6 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ANIMSMOKE_BLACK,
        {
            { 0,    IntColour(90, 0, 0, 100) },
            { 0.05,    IntColour(90, 0, 0, 255) },
            { 1,    IntColour(90, 0, 0, 0) },
        }
    )

    local animsmoke_black_max_scale = 0.4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ANIMSMOKE_BLACK,
        {
            { 0,    { animsmoke_black_max_scale, animsmoke_black_max_scale} },
            { 1,    { animsmoke_black_max_scale * 0.6, animsmoke_black_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local ANIMSMOKE_MAX_LIFETIME = 2
local ANIMSMOKE_BLACK_MAX_LIFETIME = 1.75

local function emit_animsmoke_fn(effect, sphere_emitter)
    local lifetime = ANIMSMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()

    local v_angle1,v_angle2 = math.random() * PI * 2,math.random() * PI * 2
    local speed = 1.4
    local vx, vy, vz = speed * math.sin(v_angle1) * math.cos(v_angle2),speed * math.sin(v_angle1) * math.sin(v_angle2),speed * math.cos(v_angle1)

    effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function emit_animsmoke_black_fn(effect, sphere_emitter)
    local lifetime = ANIMSMOKE_BLACK_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()

    local v_angle1,v_angle2 = math.random() * PI * 2,math.random() * PI * 2
    local speed = 1.2
    local vx, vy, vz = speed * math.sin(v_angle1) * math.cos(v_angle2),speed * math.sin(v_angle1) * math.sin(v_angle2),speed * math.cos(v_angle1)

    effect:AddRotatingParticle(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._should_emit = net_bool(inst.GUID,"inst._should_emit")
    inst._should_emit:set(true)
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 512)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, ANIMSMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ANIMSMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ANIMSMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 2)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetAcceleration(0, 0, -0.2, 0)
    effect:SetDragCoefficient(0, .1)

    --SMOKE_BLACK
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 512)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, ANIMSMOKE_BLACK_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_ANIMSMOKE_BLACK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_ANIMSMOKE_BLACK)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 2)
    effect:SetRadius(1, 3) --only needed on a single emitter
    effect:SetAcceleration(1, 0, -0.3, 0)
    effect:SetDragCoefficient(1, .1)
   

    local sphere_emitter = CreateSphereEmitter(0.15)

    EmitterManager:AddEmitter(inst, nil, function()        
        if inst._should_emit:value() then 
            local num_to_emit = 2 * math.random()
            local num_to_emit_black = 4 * math.random()
            for i=1,num_to_emit do 
                emit_animsmoke_fn(effect, sphere_emitter)
            end 

            for i=1,num_to_emit_black do 
                emit_animsmoke_black_fn(effect, sphere_emitter)
            end 
        end
    end)

    return inst
end

return Prefab("gale_splash_vfx", fn, assets)