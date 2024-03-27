local GaleCommon = require("util/gale_common")

local ANIM_SMOKE_TEXTURE = resolvefilepath("fx/smoke.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "gale_circleing_tail_vfx_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "gale_circleing_tail_vfx_scaleenvelope_smoke"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),

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
            -- { 0,    IntColour(0, 200, 200, 80) },
            -- { 0.1,    IntColour(0, 255, 255, 175) },
            -- { 0.6,  IntColour(0, 255, 255, 175) },
            -- { 1,    IntColour(0, 200, 200, 0) },

            { 0,    IntColour(200, 200,180, 175) },
            { 0.1,    IntColour(255, 255,200, 175) },
            { 0.6,  IntColour(255, 255,200, 80) },
            { 1,    IntColour(200, 200,180, 0) },
        }
    )

    local smoke_max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            -- { 0,    { smoke_max_scale * 0.3, smoke_max_scale * 0.3 } },
            -- { 1,    { smoke_max_scale, smoke_max_scale } },
            { 0,    { smoke_max_scale, smoke_max_scale } },
            { 0.5,    { smoke_max_scale * 0.01, smoke_max_scale * 0.01 } },
            { 1,    { smoke_max_scale * 0.01, smoke_max_scale * 0.01 } },
            -- { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    
    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = 5


local function emit_smoke_fn(effect,pos,v)
    pos = pos or Vector3(0,0,0)
    v = v or Vector3(0,0,0)
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        pos.x,pos.y,pos.z,    -- position
        v.x,v.y,v.z,          -- velocity
        uv_offset, 0        -- uv offset
    )
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._static = net_bool(inst.GUID,"inst._static","staticdirty")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("staticdirty",function()
            if inst._static:value() == true then
                inst.VFXEffect:SetDragCoefficient(0,99999)
            end
            
        end)
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end



    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 1024)
    effect:SetUVFrameSize(0,0.25,1)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.Additive) --AlphaBlended Premultiplied
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)
    effect:SetDragCoefficient(0,0.02)

    inst.angle = math.random() * 2 * PI
    -- ThePlayer:SpawnChild("gale_circleing_tail_vfx")

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        local height = 0
        if parent then
            local rad = 0.5
            -- local parent_speed = parent.Physics and parent.Physics:GetMotorSpeed() or 0

            local face_vec = GaleCommon.GetFaceVector(parent)
            local mid_pos = -face_vec * 0.2
            local crossed = face_vec:Cross(Vector3(0,1,0)):GetNormalized()

            local x = math.cos(inst.angle) * rad
            local y = math.sin(inst.angle) * rad

            local spawn_pos = crossed * x + Vector3(0,1,0) * y
            spawn_pos = spawn_pos + mid_pos + Vector3(0,height,0)

            local x2 = -math.cos(inst.angle) * rad
            local y2 = -math.sin(inst.angle) * rad

            local spawn_pos2 = crossed * x2 + Vector3(0,1,0) * y2
            spawn_pos2 = spawn_pos2 + mid_pos + Vector3(0,height,0)

            local back_speed = 0.5
            emit_smoke_fn(effect,spawn_pos,face_vec * (-back_speed))
            emit_smoke_fn(effect,spawn_pos2,face_vec * (-back_speed))
            -- emit_smoke_fn(effect,spawn_pos)
            -- emit_smoke_fn(effect,spawn_pos2)

            inst.angle = inst.angle + 1 * FRAMES * PI / 180
        else 

        end
        -- emit_smoke_fn(effect,Vector3(0,0,0),Vector3(0,0,0))
        
    end)


    return inst
end

return Prefab("gale_circleing_tail_vfx", fn, assets)
