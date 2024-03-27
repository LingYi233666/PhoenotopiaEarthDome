-- local SPARKLE_TEXTURE = "fx/smoke.tex"
-- local ARROW_TEXTURE = "fx/spark.tex"
local BEAM_TEXTURE = resolvefilepath("fx/gale_laserbeam.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_RED_NAME = "athetos_portable_turret_lines_vfx_red_colourenvelope"
local SCALE_ENVELOPE_RED_NAME = "athetos_portable_turret_lines_vfx_red_scaleenvelope"

local COLOUR_ENVELOPE_YELLOW_NAME = "athetos_portable_turret_lines_vfx_yellow_scaleenvelope"

local COLOUR_ENVELOPE_GREEN_NAME = "athetos_portable_turret_lines_vfx_green_scaleenvelope"

local COLOUR_ENVELOPE_EMPTY_NAME = "athetos_portable_turret_lines_vfx_empty_scaleenvelope"

local assets =
{
    Asset("IMAGE", BEAM_TEXTURE),
    -- Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

local colour_index_map = {
    COLOUR_ENVELOPE_GREEN_NAME,
    COLOUR_ENVELOPE_YELLOW_NAME,
    COLOUR_ENVELOPE_RED_NAME,
    COLOUR_ENVELOPE_EMPTY_NAME,
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_RED_NAME, {
        { 0, IntColour(255, 0, 0, 255) },
        { 1, IntColour(255, 0, 0, 255) }
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_GREEN_NAME, {
        { 0, IntColour(0, 255, 0, 255) },
        { 1, IntColour(0, 255, 0, 255) }
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_YELLOW_NAME, {
        { 0, IntColour(255, 255, 0, 255) },
        { 1, IntColour(255, 255, 0, 255) }
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_EMPTY_NAME, {
        { 0, IntColour(0, 0, 0, 0) },
        { 1, IntColour(0, 0, 0, 0) }
    })

    local y_scale = 2.345 * 13
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_RED_NAME,
        {
            { 0,    { 0.66, y_scale } },
            { 1,    { 0.66, y_scale} },
        }
    )

    -- EnvelopeManager:AddVector2Envelope(
    --     SCALE_ENVELOPE_RED_NAME,
    --     {
    --         { 0,    { 5, 0.1 } },
    --         { 1,    { 5, 0.1} },
    --     }
    -- )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0

local function emit_beam_fn(effect, pos)
    local pos_norm = pos:GetNormalized()
    local vx, vy, vz = (pos_norm * 0.1):Get()
    local lifetime = MAX_LIFETIME
    local px, py, pz = 0,0,0
    

    effect:AddParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz         -- velocity
    )
end

local function SetColourIndex(inst,index)
    inst.VFXEffect:SetColourEnvelope(0, colour_index_map[index])
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._colour_index = net_tinybyte(inst.GUID,"inst._colour_index","colourdirty")
    inst._offset_x = net_float(inst.GUID,"inst._offset_x")
    inst._offset_z = net_float(inst.GUID,"inst._offset_z")
    inst._radius = net_float(inst.GUID,"inst._radius")

    inst._colour_index:set(1)
    inst._offset_x:set(0)
    inst._offset_z:set(0)
    inst._radius:set(1.5)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    -- effect:InitEmitters(3)

    effect:SetRenderResources(0, BEAM_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0,true)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_RED_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_RED_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetDragCoefficient(0, 1)
    effect:EnableBloomPass(0, true)
    effect:SetFollowEmitter(0,true)
    effect:SetKillOnEntityDeath(0,true)
    effect:SetSortOrder(0,3)
    effect:EnableDepthTest(0,true)

    -----------------------------------------------------

    inst.SetColourIndex = SetColourIndex
    inst.rot_offset = 0


    -- ThePlayer:SpawnChild("athetos_portable_turret_lines_vfx")
    -- c_findnext("athetos_portable_turret_lines_vfx")._offset_x:set(15)
    -- c_findnext("athetos_portable_turret_lines_vfx").debug_s = 2.345
    -- ThePlayer:SpawnChild("athetos_portable_turret_lines_vfx").TargetEntity:set(c_findnext("dummytarget"))
    EmitterManager:AddEmitter(inst, nil, function()
        effect:ClearAllParticles(0)
        
        local mid_pos = Vector3(inst._offset_x:value(),0,inst._offset_z:value())

        local m_axis_y = Vector3(0,1,0)
        local m_axis_x = m_axis_y:Cross(mid_pos):GetNormalized()
        local seg_num = 8
        local radius = inst._radius:value()
        for i=0,seg_num-1 do
            local rot = TWOPI * i / seg_num + inst.rot_offset
            local delta = mid_pos + m_axis_x * math.cos(rot) * radius + m_axis_y * math.sin(rot) * radius

            emit_beam_fn(effect,delta)
        end
        

        inst.rot_offset = inst.rot_offset + TWOPI * FRAMES / 10
        if inst.rot_offset >= TWOPI then
            inst.rot_offset = inst.rot_offset - TWOPI
        end
        
        -- local entity = TheInput:GetWorldEntityUnderMouse()
        -- if entity then
            
        --     local parent = inst.entity:GetParent()
        --     local mid_pos = entity:GetPosition() - parent:GetPosition()
        --     emit_beam_fn(inst,effect,mid_pos)
        -- end
        -- local parent = inst.entity:GetParent()
        -- local mid_pos = TheInput:GetWorldPosition() - parent:GetPosition()
        -- emit_beam_fn(inst,effect,mid_pos)
    end)

    return inst
end

return Prefab("athetos_portable_turret_lines_vfx", fn, assets)
