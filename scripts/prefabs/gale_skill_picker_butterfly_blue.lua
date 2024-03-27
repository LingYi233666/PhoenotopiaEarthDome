local SPARKLE_TEXTURE = resolvefilepath("fx/blue_butterfly.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_skill_picker_butterfly_blue_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_skill_picker_butterfly_blue_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------
-- 
local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0, IntColour(255, 255, 255, 255) },
        { 1, IntColour(255, 255, 255, 255) },
    })

    local sparkle_max_scale = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale, sparkle_max_scale} },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = FRAMES * 4

local function emit_sparkle_fn(effect, sphere_emitter,u,v)
    local lifetime = MAX_LIFETIME

    local u_offset = u * 0.25
    local v_offset = v * 0.25

    -- effect:AddRotatingParticleUV(
    --     0,
    --     lifetime,           -- lifetime
    --     px, py, pz,         -- position
    --     vx, vy, vz,         -- velocity
    --     angle, ang_vel,     -- angle, angular_velocity
    --     uv_offset, 0        -- uv offset
    -- )

    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        0, 0, 0,         -- position
        0, 0, 0,         -- velocity
        u_offset, v_offset        -- uv offset
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

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    -- effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 0.25, 0.25)
    effect:SetMaxNumParticles(0, 2)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0,true)

    inst.cur_id = 0

    inst.cur_u = 0
    inst.cur_v = 1

    -----------------------------------------------------
    local sphere_emitter = CreateSphereEmitter(.25)

    -- EmitterManager:AddEmitter(inst, nil, function()
        
    -- end)
    -- local u = math.floor(i / 4) local v = (i - u * 4) % 4
    -- ThePlayer:SpawnChild("gale_skill_picker_butterfly_blue")
    inst:DoPeriodicTask(MAX_LIFETIME - FRAMES,function()
        effect:ClearAllParticles(0)


        emit_sparkle_fn(effect, sphere_emitter,inst.cur_u,inst.cur_v)
        inst.cur_u = inst.cur_u + 1
        if inst.cur_u > 3 then
            inst.cur_u = 0
            inst.cur_v = inst.cur_v + 1

            if inst.cur_v > 2 then
                inst.cur_u = 0
                inst.cur_v = 1
            end
        end

        -- local u = math.floor(inst.cur_id / 4)
        -- local v = (inst.cur_id - u * 4) % 4

        -- inst.cur_id = inst.cur_id + 1
        -- if inst.cur_id >= 12 then
        --     inst.cur_id = 0
        -- end        
    end)

    -- inst:StartThread(function()
    --     local u = math.floor(inst.cur_id / 4)
    --     local v = inst.cur_id % 3
    --     emit_sparkle_fn(effect, sphere_emitter,u,v)

    --     inst.cur_id = inst.cur_id + 1
    --     if inst.cur_id >= 12 then
    --         inst.cur_id = 0
    --     end

    --     Sleep(0.5)
    -- end)

    return inst
end

return Prefab("gale_skill_picker_butterfly_blue", fn, assets)
