local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local namespace = "gale_skill_hyperburn_vfx"


local COLOUR_ENVELOPE_NAME_SMOKE_RED = namespace .. "_colourenvelope_smoke_red"
local COLOUR_ENVELOPE_NAME_SMOKE_YELLOW = namespace .. "_colourenvelope_smoke_yellow"
local SCALE_ENVELOPE_NAME_SMOKE_THIN = namespace .. "_scaleenvelope_smoke_thin"
local SCALE_ENVELOPE_NAME_SMOKE = namespace .. "_scaleenvelope_smoke"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(255, 255, 150, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 255, 150, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 255, 150, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_YELLOW, {
        { 0,   IntColour(255, 255, 0, 0) },
        { 0.1, IntColour(255, 255, 0, 1) },
        { 0.9, IntColour(255, 255, 0, 1) },
        { 1,   IntColour(255, 255, 0, 0) },
    })

    local scale_factor = 4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_THIN,
        {
            { 0,   { scale_factor * 0.2, scale_factor } },
            { 0.2, { scale_factor * 0.2, scale_factor } },
            { 1,   { scale_factor * .02, scale_factor * 0.9 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.75

local function emit_line_thin(effect, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = (MAX_LIFETIME * (.9 + UnitRand() * .1))

    effect:AddParticle(
        0,
        lifetime,  -- lifetime
        0, 0, 0,   -- position
        vx, vy, vz -- velocity
    )
end

local function linevfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false


    inst._velocity_x = net_float(inst.GUID, "inst._velocity_x")
    inst._velocity_y = net_float(inst.GUID, "inst._velocity_y")
    inst._velocity_z = net_float(inst.GUID, "inst._velocity_z")
    inst._event = net_event(inst.GUID, "inst._event")

    inst.DoEmit = function(inst, x_or_pos, y, z)
        local x = x_or_pos
        if x_or_pos ~= nil and y == nil and z == nil then
            x, y, z = x_or_pos:Get()
        end

        inst._velocity_x:set(x)
        inst._velocity_y:set(y)
        inst._velocity_z:set(z)

        inst._event:push()
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    inst:ListenForEvent("inst._event", function()
        emit_line_thin(effect, Vector3(inst._velocity_x:value(), inst._velocity_y:value(), inst._velocity_z:value()))
    end)

    return inst
end

local function segmentfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("gale_skill_hyperburn_line_vfx")

    inst:DoTaskInTime(10 * FRAMES, inst.Remove)

    return inst
end

return Prefab("gale_skill_hyperburn_line_vfx", linevfxfn, assets),
    Prefab("gale_skill_hyperburn_line_segment", segmentfn)
