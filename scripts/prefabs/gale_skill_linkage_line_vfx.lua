local SPARKLE_TEXTURE = "fx/smoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_skill_linkage_line_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_skill_linkage_line_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    -- local t = 0
    -- local step = .15
    -- while t + step + .01 < 1 do
    --     table.insert(envs, { t, IntColour(0, 229, 232, 255) })
    --     t = t + step
    --     table.insert(envs, { t, IntColour(0, 229, 232, 0) })
    --     t = t + .01
    -- end
    table.insert(envs, { 0, IntColour(255, 210, 0, 255) })
    table.insert(envs, { 1, IntColour(255, 210, 0, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 0.33
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
local MAX_LIFETIME = 0.1

local function emit_sparkle_fn(effect, pos)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst.TargetEntity = net_entity(inst.GUID,"inst.TargetEntity")

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
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 2048)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 2)
    effect:SetLayer(0,LAYER_BACKGROUND)

    -----------------------------------------------------



    local num_to_emit = 2

    -- local sphere_emitter = CreateSphereEmitter(.25)
    -- ThePlayer:SpawnChild("gale_skill_linkage_line_vfx")
    -- c_findnext("gale_skill_linkage_line_vfx").OffsetPosX:set(0)
    -- ThePlayer:SpawnChild("gale_skill_linkage_line_vfx").TargetEntity:set(c_findnext("dummytarget"))
    EmitterManager:AddEmitter(inst, nil, function()
        -- local parent = inst.entity:GetParent()
        -- local target = inst.TargetEntity:value()
        -- local delta_length = 0.075
        -- if parent then 
        --     while num_to_emit > 1 do
        --         local parentpos = parent:GetPosition()
        --         local startpos = parentpos -- + Vector3(inst.OffsetPosX:value(),inst.OffsetPosY:value(),inst.OffsetPosZ:value())
        --         local targetpos = Vector3(inst.TargetPosX:value(),inst.TargetPosY:value(),inst.TargetPosZ:value())
        --         -- local targetpos = TheInput:GetWorldPosition()
        --         local target = inst.TargetEntity:value()
        --         if target and target:IsValid() then 
        --             targetpos = target:GetPosition()
        --         end 
        --         local deltapos = targetpos - startpos
        --         local i_to_emit = deltapos:Length() / delta_length + 1
        --         for i = 0,i_to_emit do 
        --             local sppos = deltapos:GetNormalized() * delta_length * i
        --             if inst.OffsetPosX:value() <= sppos:Length() then 
        --                 emit_sparkle_fn(effect,sppos + Vector3(0,inst.OffsetPosY:value() * (i_to_emit - i) / i_to_emit,0))
        --             end 
        --         end 
        --         num_to_emit = num_to_emit - 1
        --     end
        -- end 
        -- num_to_emit = 2

        local parent = inst.entity:GetParent()
        local target = inst.TargetEntity:value()
        if parent and target and target:IsValid() then
            local seg_length = 0.075
            local delta = target:GetPosition() - parent:GetPosition()
            local delta_norm = delta:GetNormalized()

            for i = 0,delta:Length(),seg_length do
                emit_sparkle_fn(effect,delta_norm * i)
            end
        end


    end)

    return inst
end

return Prefab("gale_skill_linkage_line_vfx", fn, assets)
