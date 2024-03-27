local POINT_TEXTURE = "fx/smoke.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local POINT_COLOUR_ENVELOPE_NAME = "gale_phantom_eyes_vfx_point_colourenvelope"
local POINT_SCALE_ENVELOPE_NAME = "gale_phantom_eyes_vfx_point_scaleenvelope"

local SMOKE_COLOUR_ENVELOPE_NAME = "gale_phantom_eyes_vfx_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "gale_phantom_eyes_vfx_smoke_scaleenvelope"


local assets =
{
    Asset("IMAGE", POINT_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- Point

    EnvelopeManager:AddColourEnvelope(
        POINT_COLOUR_ENVELOPE_NAME,
        {
            -- { 0, IntColour(255, 247, 255, 0) },
            { 0, IntColour(117, 230, 243, 150) },
            { 1, IntColour(117, 230, 243, 0) }
        }
    )

    local point_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        POINT_SCALE_ENVELOPE_NAME,
        {
            { 0,    { point_max_scale, point_max_scale } },
            { 0.33, { point_max_scale, point_max_scale } },
            { 0.66, { point_max_scale, point_max_scale } },
            { 1,    { point_max_scale * 0.8, point_max_scale * 0.8 } },
        }
    )

    -- Eye main
    EnvelopeManager:AddColourEnvelope(
        SMOKE_COLOUR_ENVELOPE_NAME,
        {
            { 0,   IntColour(117, 230, 243, 0) },
            { 0.1, IntColour(117, 230, 243, 90) },
            { .3,  IntColour(117, 230, 243, 150) },
            { .52, IntColour(117, 230, 243, 90) },
            { 1,   IntColour(117, 230, 243, 0) },
        }
    )

    local smoke_max_scale = 0.09
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0, { smoke_max_scale * .75, smoke_max_scale * .75 } },
            { 1, { smoke_max_scale * .5, smoke_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local POINT_MAX_LIFETIME = 0.5
local SMOKE_MAX_LIFETIME = 0.75

local function emit_point_fn(effect, spherefn)
    local vx, vy, vz = 0, 0, 0
    local lifetime = POINT_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = spherefn()
    local uv_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        UnitRand() * 1,      -- angle velocity
        uv_offset, 0
    )
end

local function emit_smoke_fn(effect, eye_main_sphere)
    local vx, vy, vz = .005 * UnitRand(), 0, .005 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = eye_main_sphere()

    effect:AddRotatingParticle(
        1,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, -- angle
        0                    -- angle velocity
    )
end
-- local fx = SpawnPrefab("gale_phantom_eyes_vfx") fx.entity:SetParent(ThePlayer.entity) fx.Follower:FollowSymbol(ThePlayer.GUID,"headbase", 0, 0, 0)

-- local fx = c_findnext("gale_phantom_eyes_vfx") fx.Follower:FollowSymbol(ThePlayer.GUID,"headbase", 0, 0, 0)
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")

    inst.persists = false
    inst.should_emit = false
    inst.no_point = false

    if InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SPARKLE
    effect:SetRenderResources(0, POINT_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 1024)
    effect:SetMaxLifetime(0, POINT_MAX_LIFETIME)
    effect:SetColourEnvelope(0, POINT_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, POINT_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetDragCoefficient(0, .001)


    -- Eye main
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(1, 64)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(1, true)
    effect:SetAngularDragCoefficient(1, 0.1)
    effect:SetFollowEmitter(1, true)
    -- effect:SetSortOrder(1, 0)
    effect:SetKillOnEntityDeath(1, true)

    local point_sphere = CreateSphereEmitter(0)
    local eye_main_sphere = CreateSphereEmitter(0.01)

    EmitterManager:AddEmitter(inst, nil, function()
        if inst.should_emit then
            if not inst.no_point then
                emit_point_fn(effect, point_sphere)
            end
            emit_smoke_fn(effect, eye_main_sphere)
        else
            effect:ClearAllParticles(1)
        end



        -- local parent = inst.entity:GetParent()

        -- if parent then
        --     local face = parent.Transform:GetFacing()
        --     local poses = nil

        --     if face == 3 then
        --         poses = {
        --             Vector3(-30,-40,0),
        --             Vector3(30,-40,0),
        --         }
        --     elseif face == 0 then
        --         poses = {15,-46,0}
        --     elseif face == 1 then
        --         poses = {}
        --     elseif face == 2 then
        --         poses = {15,-46,0}
        --     else
        --         poses = {}
        --     end

        --     for _,v in pairs(poses) do
        --         for i = 1,10 do
        --             local px,py,pz = eye_main_sphere()
        --             px = px + v.x
        --             py = py + v.y
        --             pz = pz + v.z

        --         end
        --     end
        -- else
        --     inst:Remove()
        -- end
    end)


    return inst
end

-- c_findnext("skeleton"):SpawnChild("gale_phantom_eyes_vfx")
-- ThePlayer:SpawnChild("gale_phantom_eyes_vfx")

--
return Prefab("gale_phantom_eyes_vfx", fn, assets)
