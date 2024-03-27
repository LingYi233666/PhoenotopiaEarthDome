local FLUTE_TEXTURE = resolvefilepath("fx/gale_flute_vfxs.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local FLUTE_COLOUR_ENVELOPE_NAME = "gale_flute_vfx_colourenvelope"
local FLUTE_SCALE_ENVELOPE_NAME = "gale_flute_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", FLUTE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        FLUTE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 0, 0, 30) },
            { .1,   IntColour(255, 255, 255, 255) },
            { .8,   IntColour(255, 255, 255, 255) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local max_scale = 1.5
    EnvelopeManager:AddVector2Envelope(
        FLUTE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale * 0.25, max_scale * 0.25 } },
            { 0.1,    { max_scale,max_scale} },
            { 1,    { max_scale,max_scale} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local FLUTE_MAX_LIFETIME = 1.5

local function emit_flute_fn(effect,uv_offset)     
           
    local lifetime = FLUTE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    
    local right_vec = TheCamera:GetRightVec()
    -- local down_vec = TheCamera:GetDownVec()

    local vx,vy,vz = (Vector3(0,0.5,0) + right_vec * GetRandomMinMax(-0.2,0.2)):Get()

    -- print("emit_flute_fn at",vx,vy,vz)
    effect:AddParticleUV(
        0,
        lifetime,                 -- lifetime
        0, 1, 0,                  -- position
        vx,vy,vz,                 -- velocity
        uv_offset * 0.2, 0        -- uv offset
    )
end

local function OnEmitTrigger(inst)
    print(inst,"OnEmitTrigger")

    local val = inst._emit_what:value()
    local effect = inst.VFXEffect

    if val == "shang" then 
        emit_flute_fn(effect,0)
    elseif val == "you" then 
        emit_flute_fn(effect,1)
    elseif val == "mid" then 
        emit_flute_fn(effect,2)
    elseif val == "zuo" then 
        emit_flute_fn(effect,3)
    elseif val == "xia" then 
        emit_flute_fn(effect,4)
    end 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._emit_what = net_string(inst.GUID,"inst._emit_what","emit_what_dirty")

    inst.DoEmit = function(inst,emit_what)
        print(inst,"DoEmit",emit_what)
        inst._emit_what:set_local("")
        inst._emit_what:set(emit_what)
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        inst:ListenForEvent("emit_what_dirty",OnEmitTrigger)
        if InitEnvelope ~= nil then
            InitEnvelope()
        end 
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, FLUTE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, FLUTE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, FLUTE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, FLUTE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.2, 1)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .25)
    -- effect:SetRotateOnVelocity(0, true)
    -- effect:SetAcceleration(0, 0, -0.15, 0)


    return inst
end

return Prefab("gale_flute_vfx", fn, assets)