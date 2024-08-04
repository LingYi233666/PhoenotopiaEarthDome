local GaleCommon = require("util/gale_common")
local GaleEntity = require("util/gale_entity")

local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"
local FLAME_TEXTURE = resolvefilepath("fx/DYC/dyc_flame.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local namespace = "gale_divine_smite_fxs"


local COLOUR_ENVELOPE_NAME_ARROW = namespace .. "_colourenvelope_arrow"
local COLOUR_ENVELOPE_NAME_FIRE = namespace .. "_colourenvelope_fire"

local SCALE_ENVELOPE_NAME_ARROW = namespace .. "_scaleenvelope_arrow"
local SCALE_ENVELOPE_NAME_FIRE = namespace .. "_scaleenvelope_fire"


local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", FLAME_TEXTURE),


    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,  IntColour(255, 240, 240, 0) },
        { .2, IntColour(255, 253, 255, 200) },
        { .3, IntColour(200, 255, 240, 110) },
        { .6, IntColour(230, 245, 240, 180) },
        { .9, IntColour(255, 240, 240, 100) },
        { 1,  IntColour(255, 240, 240, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_FIRE, {
        { 0,  IntColour(255, 240, 240, 0) },
        { .2, IntColour(255, 253, 255, 60) },
        { .3, IntColour(200, 255, 240, 20) },
        { .6, IntColour(230, 245, 240, 40) },
        { .9, IntColour(255, 240, 240, 20) },
        { 1,  IntColour(255, 240, 240, 0) },
    })



    local scale_factor = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },

            -- { 0,   { scale_factor * 0.07, scale_factor } },
            -- { 0.2, { scale_factor * 0.07, scale_factor } },
            -- { 1,   { scale_factor * 0.07, scale_factor } },
        }
    )

    scale_factor = 2.7
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_FIRE, {
        { 0,   { scale_factor * 0.8, scale_factor * 0.9 } },
        { 0.2, { scale_factor, scale_factor * 1.2 } },
        { 1,   { scale_factor * 0.9, scale_factor } }
    })



    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_ARROW = 0.6
local FLAME_MAX_LIFETIME = 0.6

local function emit_line_thin(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME_ARROW * (.6 + UnitRand() * .4))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_flame_fn_by_pos(effect, pos)
    local lifetime = FLAME_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = pos:Get()

    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()

    local u_offset = math.random(0, 3) * .25
    local v_offset = math.random(0, 3) * .25

    effect:AddParticleUV(0,
                         lifetime,          -- lifetime
                         px, py, pz,        -- position
                         vx, vy, vz,        -- velocity
                         u_offset, v_offset -- uv offset
    )
end

local function emit_flame_fn(effect, sphere_emitter)
    emit_flame_fn_by_pos(effect, Vector3(sphere_emitter()))
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
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 12)
    effect:SetMaxLifetime(0, MAX_LIFETIME_ARROW)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.4)

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    local remain_time = FRAMES * 3
    EmitterManager:AddEmitter(inst, nil, function()
        if remain_time > 0 then
            for i = 1, 12 do
                -- local velocity = Vector3(norm_sphere_emitter()) * 0.3
                local velocity = Vector3(norm_sphere_emitter()) * 1
                velocity.y = math.abs(velocity.y)
                local pos = velocity:GetNormalized() * 0.66
                emit_line_thin(effect, pos, velocity)
            end
            remain_time = remain_time - FRAMES
        end
    end)

    return inst
end


local function firevfxfn()
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
    effect:InitEmitters(1)

    -- SPARKLE
    effect:SetRenderResources(0, FLAME_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FIRE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FIRE)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 0.25)
    effect:SetSortOffset(0, 1)

    local sphere_emitter = CreateSphereEmitter(.1)

    local flame_to_emit = 0
    EmitterManager:AddEmitter(inst, nil, function()
        flame_to_emit = flame_to_emit + GetRandomMinMax(0.5, 1)
        while flame_to_emit > 0 do
            local x, y, z = sphere_emitter()
            emit_flame_fn_by_pos(effect, Vector3(x, y + 0.5, z))
            flame_to_emit = flame_to_emit - 1
        end
    end)

    return inst
end

return Prefab("gale_divine_smite_explode_vfx", explovfxfn, assets),
    Prefab("gale_divine_smite_fire_vfx", firevfxfn, assets),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_divine_smite_explode_fx",
        assets = assets,

        bank = "bomb_lunarplant",
        build = "bomb_lunarplant",
        anim = "used",
        clientfn = function(inst)
            inst.AnimState:SetLightOverride(1)
            inst.AnimState:HideSymbol("bombbreak")
            inst.AnimState:HideSymbol("splash_fx")

            local s = 1.3
            inst.AnimState:SetScale(s, s, s)
        end,

        serverfn = function(inst)
            inst:SpawnChild("gale_divine_smite_explode_vfx")
        end
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_divine_smite_circle_fx",
        assets = assets,

        bank = "winona_catapult_projectile",
        build = "winona_catapult_projectile",
        anim = "aoe_lunar",

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_GROUND)
            inst.AnimState:SetSortOrder(3)
            inst.AnimState:SetFinalOffset(1)

            inst.AnimState:SetAddColour(1, 1, 0, 1)
            inst.AnimState:SetLightOverride(1)
        end,
    }),
    GaleEntity.CreateNormalFx({
        prefabname = "gale_divine_smite_burntground_fx",
        assets = assets,

        bank = "burntground",
        build = "burntground",
        anim = "idle",

        animover_remove = false,

        clientfn = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_GROUND)
            inst.AnimState:SetSortOrder(3)

            inst.AnimState:SetLightOverride(1)

            inst.Transform:SetRotation(math.random() * 360)

            local s = 0.7
            inst.AnimState:SetScale(s, s, s)
        end,

        serverfn = function(inst)
            inst.fires = {}
            local num_fires = 1
            for i = 1, num_fires do
                local fire = inst:SpawnChild("gale_divine_smite_fire_vfx")
                -- fire._colour:set(4)
                -- fire._scale:set(1)

                -- local x, y, z = Vector3FromTheta(math.random() * PI2, math.random()):Get()
                -- fire.Transform:SetPosition(x, y, z)

                table.insert(inst.fires, fire)
            end


            inst:DoTaskInTime(GetRandomMinMax(3, 4), function()
                for k, v in pairs(inst.fires) do
                    v:Remove()
                end

                GaleCommon.FadeTo(inst, 1, nil, {
                                      Vector4(1, 1, 1, 1),
                                      Vector4(0, 0, 0, 0)
                                  }, nil, inst.Remove)
            end)
        end
    })
