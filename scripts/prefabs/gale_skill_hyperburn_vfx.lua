local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

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
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_YELLOW, {
        { 0,  IntColour(255, 240, 0, 0) },
        { .2, IntColour(255, 253, 0, 120) },
        { .3, IntColour(200, 255, 0, 30) },
        { .6, IntColour(230, 245, 0, 20) },
        { .9, IntColour(255, 240, 0, 10) },
        { 1,  IntColour(255, 240, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_RED, {
        { 0,  IntColour(255, 0, 0, 0) },
        { .2, IntColour(255, 0, 0, 120) },
        { .3, IntColour(200, 0, 0, 30) },
        { .6, IntColour(230, 0, 0, 20) },
        { .9, IntColour(255, 0, 0, 10) },
        { 1,  IntColour(255, 0, 0, 0) },
    })

    local scale_factor = 1.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_THIN,
        {
            { 0,   { scale_factor * 0.075, scale_factor } },
            { 0.2, { scale_factor * 0.075, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )

    scale_factor = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,   { scale_factor * 0.15, scale_factor } },
            { 0.2, { scale_factor * 0.15, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.66
local MAX_LIFETIME_ARROW = 1.0
local sphere_emitter = CreateSphereEmitter(0.1)

local function emit_line_thin(effect, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = sphere_emitter()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_line(effect, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = sphere_emitter()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_arrow(effect, emitter, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = emitter()
    local lifetime = (MAX_LIFETIME_ARROW * (.6 + UnitRand() * .4))

    effect:AddParticle(
        2,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function InitCommonVFX(inst, effect)
    -- Thin yellow line in the flame middle
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:EnableDepthTest(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOrder(0, 1)

    -- Fat red line of the flame
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 1)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_RED)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    -- effect:EnableDepthTest(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOrder(1, 0)
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
    inst._depth = net_bool(inst.GUID, "inst._depth", "depthdirty")

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

    inst.EnableDepth = function(inst, enable)
        inst._depth:set(enable)
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
    effect:InitEmitters(3)

    InitCommonVFX(inst, effect)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(2, true)
    effect:SetMaxNumParticles(2, 8)
    effect:SetMaxLifetime(2, MAX_LIFETIME_ARROW)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_SMOKE_RED)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(2, true)
    effect:SetSortOrder(2, 0)
    effect:SetDragCoefficient(2, 0.05)

    -----------------------------------------------------
    local arrow_sphere_emitter = CreateSphereEmitter(0.1)
    inst:ListenForEvent("inst._event", function()
        local pos = Vector3(inst._velocity_x:value(), inst._velocity_y:value(), inst._velocity_z:value())
        emit_line_thin(effect, pos)
        emit_line(effect, pos)

        for i = 1, math.random(6, 8) do
            emit_arrow(effect, arrow_sphere_emitter, pos)
        end
    end)

    inst:ListenForEvent("depthdirty", function()
        effect:EnableDepthTest(0, inst._depth:value())
        effect:EnableDepthTest(1, inst._depth:value())
        effect:EnableDepthTest(2, inst._depth:value())
    end)

    return inst
end

local function explovfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    InitCommonVFX(inst, effect)
    effect:SetMaxNumParticles(0, 8)
    effect:SetMaxNumParticles(1, 8)

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    EmitterManager:AddEmitter(inst, FRAMES * 3, function()
        for i = 1, 8 do
            local pos = Vector3(norm_sphere_emitter()) * 0.4
            pos.y = math.abs(pos.y)
            emit_line_thin(effect, pos)
            emit_line(effect, pos)
        end
    end)

    return inst
end


local function linefxfn()
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

local function explofxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.vfx = inst:SpawnChild("gale_skill_hyperburn_explo_vfx")

    inst:DoTaskInTime(10 * FRAMES, inst.Remove)

    return inst
end

return Prefab("gale_skill_hyperburn_line_vfx", linevfxfn, assets),
    Prefab("gale_skill_hyperburn_explo_vfx", explovfxfn, assets),
    Prefab("gale_skill_hyperburn_line_fx", linefxfn),
    Prefab("gale_skill_hyperburn_explo_fx", explofxfn)