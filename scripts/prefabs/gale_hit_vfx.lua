local HIT_TEXTURE = resolvefilepath("fx/gale_hit_vfx.tex")

local USE_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "gale_hit_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "gale_hit_vfx_scaleenvelope"
local SCALE_SMALLER_ENVELOPE_NAME = "gale_hit_vfx_smaller_scaleenvelope"

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
        { 0,    IntColour(255,255,255,0) },
        { 0.4,    IntColour(255,255,255,200) },
        { 1,    IntColour(255,255,255,0) },
    })

    local sparkle_max_scale = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale * 0.5, sparkle_max_scale * 0.5} },
            { 0.4,    { sparkle_max_scale * 1.3, sparkle_max_scale * 0.75} },
            { 1,    { sparkle_max_scale * 0.6, sparkle_max_scale * 0.6 } },
        }
    )

    local sparkle_max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_SMALLER_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale * 0.5, sparkle_max_scale * 0.5} },
            { 0.4,    { sparkle_max_scale * 1.3, sparkle_max_scale * 0.75} },
            { 1,    { sparkle_max_scale * 0.6, sparkle_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.35

local function emit_hit_fx_fn(effect, sphere_emitter, adjust_vec, direction,angle)            
    local vx, vy, vz = 0,0,0
    if direction then 
        vx = vx + direction.x
        vy = vy + direction.y
        vz = vz + direction.z
    end 
    
    local lifetime = MAX_LIFETIME * (0.7 + math.random() * .3)
    -- local px, py, pz = 0,0,0
    local px, py, pz = sphere_emitter()

    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    angle = angle or math.random() * 360
    local ang_vel = (UnitRand() - 1) * 0.2
    
    effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py + 0.7, pz,    -- position
        vx, vy, vz,          -- velocity
        angle, ang_vel     -- angle, angular_velocity
    )
end

local function emit_hit_fx_smaller_fn(effect, sphere_emitter, adjust_vec, direction,angle)            
    local vx, vy, vz = 0,0,0
    if direction then 
        vx = vx + direction.x
        vy = vy + direction.y
        vz = vz + direction.z
    end 
    
    local lifetime = MAX_LIFETIME * (0.7 + math.random() * .3)
    -- local px, py, pz = 0,0,0
    local px, py, pz = sphere_emitter()

    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    angle = angle or math.random() * 360
    local ang_vel = (UnitRand() - 1) * 0.2
    
    effect:AddRotatingParticle(
        1,
        lifetime,           -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,          -- velocity
        angle, ang_vel     -- angle, angular_velocity
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._fx_size = net_string(inst.GUID,"inst._fx_size")

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    -- Big
    effect:SetRenderResources(0, HIT_TEXTURE, USE_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 4)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 1)
    -- effect:SetSortOffset(0, 2)

    effect:SetRenderResources(1, HIT_TEXTURE, USE_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetMaxNumParticles(1, 4)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, SCALE_SMALLER_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    -- effect:SetSortOrder(1, 0)
    -- effect:SetSortOffset(1, 2)

    -----------------------------------------------------

    local sphere_emitter = CreateSphereEmitter(0.03)
    local burst_state = 0
    local time_threshold = 0.08
    local num_to_emit = 2

    local fx_fns = {
        small = emit_hit_fx_smaller_fn,
        large = emit_hit_fx_fn,
    }
    
    EmitterManager:AddEmitter(inst, nil, function()
        while 1 do 
            local val = inst._fx_size:value()
            if val ~= nil and fx_fns[val] ~= nil then 
                break
            end
        end

        local start_angle = math.random() * 360
        local per_angle = 0
        while num_to_emit > 0 do 
            local val = inst._fx_size:value()
            fx_fns[val](effect, sphere_emitter,nil,nil,start_angle + per_angle)
            per_angle = per_angle + GetRandomMinMax(20,30) * (math.random() <= 0.5 and 1 or -1)
            num_to_emit = num_to_emit - 1
        end
        inst:Remove()
    end)

    return inst
end


local function HostPrefabFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then 
        return inst
    end 

    inst.persists = false

    inst.InitFX = function(inst,size_str)
        inst:SpawnChild("gale_hit_vfx")._fx_size:set(size_str)
    end

    inst:DoTaskInTime(FRAMES,inst.Remove)

    return inst
end
-- ThePlayer:SpawnChild("gale_hit_vfx")
return Prefab("gale_hit_vfx", fn, assets),Prefab("gale_hit_vfx_host",HostPrefabFn)