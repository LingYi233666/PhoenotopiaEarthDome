local POINT_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_COLOUR_ENVELOPE_NAME = "gale_quick_spark_vfx_point_colourenvelope"
local POINT_SCALE_ENVELOPE_NAME = "gale_quick_spark_vfx_point_scaleenvelope"

local ARROW_COLOUR_ENVELOPE_NAME = "gale_quick_spark_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "gale_quick_spark_vfx_arrow_scaleenvelope"

local SMOKE_COLOUR_ENVELOPE_NAME = "gale_quick_spark_vfx_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "gale_quick_spark_vfx_smoke_scaleenvelope"

local POINT_COLOUR_BLUE_ENVELOPE_NAME = "gale_quick_spark_vfx_point_blue_colourenvelope"

local ARROW_COLOUR_BLUE_ENVELOPE_NAME = "gale_quick_spark_vfx_arrow_blue_colourenvelope"

local SMOKE_COLOUR_BLUE_ENVELOPE_NAME = "gale_quick_spark_vfx_smoke_blue_colourenvelope"


local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
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
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(232, 160, 0, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(232, 160, 0, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_ENVELOPE_NAME, envs)


    -- Blue
    envs = {}
    t = 0
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(232, 160, 0, 255) })
    EnvelopeManager:AddColourEnvelope(POINT_COLOUR_BLUE_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 0.33
    EnvelopeManager:AddVector2Envelope(
        POINT_SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 90, 70, 180) },
            { .2,   IntColour(255, 120, 90, 255) },
            { .8,   IntColour(255, 90, 70, 175) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    -- Blue
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_BLUE_ENVELOPE_NAME,
        {
            { 0,    IntColour(0, 240, 240, 180) },
            { .2,   IntColour(10, 240, 240, 255) },
            { .6,   IntColour(10, 240, 240, 175) },
            { 1,    IntColour(0, 240, 240, 0) },
        }
    )

    local arrow_max_scale_width = 7
    local arrow_max_scale_height = 6
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {   

            { 0,    { arrow_max_scale_width * 0.1, arrow_max_scale_height * 0.5} },
            { 0.2,    { arrow_max_scale_width * 0.2, arrow_max_scale_height } },
            { 1,    { arrow_max_scale_width * 0.002, arrow_max_scale_height * 0.000001} },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 90, 70, 180)},
            { 0.1,   IntColour(255, 120, 90, 255)},
            { 0.2,  IntColour(0, 0, 0, 200) },
            { 0.6,  IntColour(0, 0, 0, 100) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    -- Blue
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_BLUE_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 247, 255, 0) },
            { 0.1,    IntColour(255, 239, 255, 90) },
            { .3,   IntColour(255, 239, 255, 150) },
            { .52,  IntColour(255, 239, 255, 90) },
            { 1,    IntColour(255, 239, 255, 0) },
        }
    )

    local circle_max_scale = 0.22
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { circle_max_scale, circle_max_scale } },
            { 1,    { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

-- blue
-- local function InitEnvelope()
--     local envs = {}
--     local t = 0
--     local step = .15
--     while t + step + .01 < 0.8 do
--         table.insert(envs, { t, IntColour(0, 229, 232, 255) })
--         t = t + step
--         table.insert(envs, { t, IntColour(255, 229, 232, 200) })
--         t = t + .01
--     end
--     table.insert(envs, { 1, IntColour(0, 229, 232, 0) })

--     EnvelopeManager:AddColourEnvelope(POINT_COLOUR_ENVELOPE_NAME, envs)

--     local sparkle_max_scale = 0.33
--     EnvelopeManager:AddVector2Envelope(
--         POINT_SCALE_ENVELOPE_NAME,
--         {
--             { 0,    { sparkle_max_scale, sparkle_max_scale } },
--             { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
--         }
--     )

--     EnvelopeManager:AddColourEnvelope(
--         ARROW_COLOUR_ENVELOPE_NAME,
--         {
--             { 0,    IntColour(0, 229, 230, 180) },
--             { .2,   IntColour(0, 229, 232, 255) },
--             { .8,   IntColour(0, 229, 230, 175) },
--             { 1,    IntColour(0, 0, 0, 0) },
--         }
--     )

--     local arrow_max_scale_width = 7
--     local arrow_max_scale_height = 5
--     EnvelopeManager:AddVector2Envelope(
--         ARROW_SCALE_ENVELOPE_NAME,
--         {   

--             { 0,    { arrow_max_scale_width * 0.1, arrow_max_scale_height * 0.5} },
--             { 0.2,    { arrow_max_scale_width * 0.2, arrow_max_scale_height } },
--             { 1,    { arrow_max_scale_width * 0.002, arrow_max_scale_height * 0.000001} },
--         }
--     )

--     InitEnvelope = nil
--     IntColour = nil
-- end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.3
local ARROW_MAX_LIFETIME = 0.22
local SMOKE_MAX_LIFETIME = 0.9

local function emit_point_fn(effect, sphere_emitter)
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .2 * UnitRand(), 0, .2 * UnitRand()

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


local function emit_arrow_fn(effect, sphere_emitter,double_emit)            

    local lifetime = ARROW_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px,0,pz):GetNormalized() * 0.33):Get()

    local uv_offset = math.random(2, 3) * .25
    
    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,          -- velocity
        uv_offset, 0        -- uv offset
    )

    if double_emit then
        effect:AddParticleUV(
            1,
            lifetime,           -- lifetime
            -px, -py, -pz,    -- position
            -vx, -vy, -vz,          -- velocity
            uv_offset, 0        -- uv offset
        )
    end
end

local function emit_smoke_fn(effect, sphere_emitter)

    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = .2 * UnitRand(), 0, .2 * UnitRand()


    effect:AddRotatingParticle(
        2,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 0.1      -- angle velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._color_set = net_string(inst.GUID,"inst._color_set","color_set_dirty")
    inst._color_set:set("red")

    inst._trigger = net_event(inst.GUID,"inst._trigger")
    
    -- if not TheNet:IsDedicated() then
    --     inst:ListenForEvent("color_set_dirty",function()
    --         local color = inst._color_set:value()
    --         print(inst,"color_set_dirty",color)

    --         if color == "blue" then
    --             inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
    --             inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_BLUE_ENVELOPE_NAME)
    --             inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_BLUE_ENVELOPE_NAME)
    --         end
    --     end)
    -- end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    --SPARKLE
    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 2)
    -- effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, .08)

    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 25)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    -- effect:SetSortOrder(1, 1)
    -- effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, .001)
    effect:SetRotateOnVelocity(1, true)
    -- effect:SetAcceleration(1, 0, -0.15, 0)

    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(2, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(2, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    -- effect:SetSortOrder(2, 0)
    -- effect:SetSortOffset(2, 0)
    effect:SetDragCoefficient(2, .16)

    local sphere_emitter = CreateSphereEmitter(0.01)


    inst:DoTaskInTime(0,function ()
        local color = inst._color_set:value()

        if color == "blue" then
            inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
            inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_BLUE_ENVELOPE_NAME)
            inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_BLUE_ENVELOPE_NAME)
        end

        for i=1,math.random(8,12) do
            emit_point_fn(effect,sphere_emitter)
        end

        for i=1,math.random(2,3) do
            emit_arrow_fn(effect,sphere_emitter,true)
        end

        for i=1,math.random(3,4) do
            emit_smoke_fn(effect,sphere_emitter)
        end
    end)

    -- local emitted = false 
    -- EmitterManager:AddEmitter(inst, nil, function()

    --     if not emitted and inst.Follower ~= nil and inst.entity:GetParent() ~= nil then
    --         local color = inst._color_set:value()

    --         if color == "blue" then
    --             inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
    --             inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_BLUE_ENVELOPE_NAME)
    --             inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_BLUE_ENVELOPE_NAME)
    --         end

    --         for i=1,math.random(8,12) do
    --             emit_point_fn(effect,sphere_emitter)
    --         end

    --         for i=1,math.random(2,3) do
    --             emit_arrow_fn(effect,sphere_emitter,true)
    --         end

    --         for i=1,math.random(3,4) do
    --             emit_smoke_fn(effect,sphere_emitter)
    --         end

    --         emitted = true 
    --     end
        
    -- end)

    -- inst:ListenForEvent("inst._trigger",function()
    --     local color = inst._color_set:value()

    --     if color == "blue" then
    --         inst.VFXEffect:SetColourEnvelope(0, POINT_COLOUR_BLUE_ENVELOPE_NAME)
    --         inst.VFXEffect:SetColourEnvelope(1, ARROW_COLOUR_BLUE_ENVELOPE_NAME)
    --         inst.VFXEffect:SetColourEnvelope(2, SMOKE_COLOUR_BLUE_ENVELOPE_NAME)
    --     end

    --     for i=1,math.random(8,12) do
    --         emit_point_fn(effect,sphere_emitter)
    --     end

    --     for i=1,math.random(2,3) do
    --         emit_arrow_fn(effect,sphere_emitter,true)
    --     end

    --     for i=1,math.random(3,4) do
    --         emit_smoke_fn(effect,sphere_emitter)
    --     end
    -- end)


    return inst
end

-- ThePlayer:SpawnChild("gale_quick_spark_vfx").Transform:SetPosition(0,2,0)
return Prefab("gale_quick_spark_vfx", fn, assets)
