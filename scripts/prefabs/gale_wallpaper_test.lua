local HIT_TEXTURE = resolvefilepath("fx/gale_wallpaper_test.tex")

local USE_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_wallpaper_test_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_wallpaper_test_scaleenvelope"

local assets =
{
    Asset("IMAGE", HIT_TEXTURE),
    Asset("SHADER", USE_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,    IntColour(255,255,255,255) },
        { 1,    IntColour(255,255,255,255) },
    })

    local sparkle_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale} },
            { 1,    { sparkle_max_scale, sparkle_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1

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

    -- Big
    effect:SetRenderResources(0, HIT_TEXTURE, USE_SHADER)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, false)
    -- effect:SetRotationStatus(0, true)
    effect:SetRotateOnVelocity(0, true)
    effect:SetDragCoefficient(0, 999)
    -- effect:SetSortOrder(0, 1)
    -- effect:SetSortOffset(0, 2)

    inst.vec = Vector3(0.1,0.1,0)
    inst.ang = Vector3(0,0,0)
    -----------------------------------------------------
    
    EmitterManager:AddEmitter(inst, nil, function()
        effect:ClearAllParticles(0)
        effect:AddParticle(
            0,
            MAX_LIFETIME,           -- lifetime
            0, 0, 0,                -- position
            inst.vec.x, inst.vec.y, inst.vec.z                 -- velocity
        )
    end)

    return inst
end


-- local wp = c_findnext("gale_test_room"):SpawnChild("gale_wallpaper_test") wp.Transform:SetPosition(-15,0,0)
-- local ang = PI/4 c_findnext("gale_wallpaper_test").vec = Vector3(math.cos(ang) * 0.1,1,math.sin(ang) * 0.1)
-- c_findnext("gale_wallpaper_test").ang.x = 90
-- local arg1,arg2 = 0,0 c_findnext("gale_wallpaper_test").vec = Vector3(math.sin(arg1)*math.cos(arg2),math.cos(arg1),math.sin(arg1)*math.sin(arg2))
-- c_findnext("gale_wallpaper_test").vec = Vector3(0,1,0)
return Prefab("gale_wallpaper_test", fn, assets)