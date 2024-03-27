local GaleCommon = require("util/gale_common")

local FLAME_TEXTURE = resolvefilepath("fx/DYC/dyc_flame.tex")
local FLAME2_TEXTURE = "fx/smoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_FLAME_RED = "gale_flame_vfx_red_colourenvelope"
local COLOUR_ENVELOPE_NAME_FLAME_PURPLE = "gale_flame_vfx_purple_colourenvelope"
-- TODO: Add COLOUR_ENVELOPE_NAME_FLAME_BLUE and COLOUR_ENVELOPE_NAME_FLAME_GREEN
local COLOUR_ENVELOPE_NAME_FLAME_BLUE = "gale_flame_vfx_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_FLAME_GREEN = "gale_flame_vfx_green_colourenvelope"

local SCALE_ENVELOPE_NAME_FLAME_BIG = "gale_flame_vfx_scaleenvelope_big"
local SCALE_ENVELOPE_NAME_FLAME_MID = "gale_flame_vfx_scaleenvelope_mid"
local SCALE_ENVELOPE_NAME_FLAME_SMALL = "gale_flame_vfx_scaleenvelope_small"
local SCALE_ENVELOPE_NAME_FLAME_TINY = "gale_flame_vfx_scaleenvelope_tiny"

local colour_index = {
    COLOUR_ENVELOPE_NAME_FLAME_RED,
    COLOUR_ENVELOPE_NAME_FLAME_PURPLE,
    COLOUR_ENVELOPE_NAME_FLAME_BLUE
}

local scale_index = {
    SCALE_ENVELOPE_NAME_FLAME_BIG, 
    SCALE_ENVELOPE_NAME_FLAME_MID,
    SCALE_ENVELOPE_NAME_FLAME_SMALL
}

local assets = {
    Asset("IMAGE", FLAME_TEXTURE), 
    Asset("IMAGE",FLAME2_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER)
}

local function IntColour(r, g, b, a) return {r / 255, g / 255, b / 255, a / 255} end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_FLAME_RED, {
        {0, IntColour(200, 85, 60, 25)}, 
        {.19, IntColour(200, 125, 80, 100)},
        {.35, IntColour(255, 20, 10, 200)},
         {.51, IntColour(255, 20, 10, 128)},
        {.75, IntColour(255, 20, 10, 64)}, 
        {1, IntColour(255, 7, 5, 0)}
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_FLAME_PURPLE, {
        {0, IntColour(122, 30, 255, 200)},
        {.5, IntColour(122, 20, 255, 230)},
        {.6, IntColour(122, 10, 255, 128)}, 
        {1, IntColour(200, 5, 255, 0)}
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_FLAME_BLUE, {
        {0, IntColour(25, 40, 170, 255)}, 
        {0.75, IntColour(0, 40, 170, 125)},
        {1, IntColour(0, 40, 170, 0)}
    })

    local flame_max_scale = 2.55
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_FLAME_BIG, {
        {0, {flame_max_scale * .9, flame_max_scale}},
        {1, {flame_max_scale * .5, flame_max_scale * .4}}
    })

    flame_max_scale = 1.9
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_FLAME_MID, {
        {0, {flame_max_scale * .9, flame_max_scale}},
        {1, {flame_max_scale * .5, flame_max_scale * .4}}
    })

    flame_max_scale = 1.25
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_FLAME_SMALL, {
        {0, {flame_max_scale * .9, flame_max_scale}},
        {1, {flame_max_scale * .5, flame_max_scale * .4}}
    })

    flame_max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME_FLAME_TINY, {
        {0, {flame_max_scale , flame_max_scale}},
        {1, {flame_max_scale * .5, flame_max_scale * .5}}
    })

    InitEnvelope = nil
    IntColour = nil
end

local FLAME_MAX_LIFETIME = 0.5

local function emit_flame_fn_by_pos(effect, pos)
    local lifetime = FLAME_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = pos:Get()

    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()

    local u_offset = math.random(0, 3) * .25
    local v_offset = math.random(0, 3) * .25

    effect:AddParticleUV(0, 
        lifetime, -- lifetime
        px, py, pz, -- position
        vx, vy, vz, -- velocity
        u_offset, v_offset -- uv offset
    )
end

local function emit_flame_fn(effect, sphere_emitter)
    emit_flame_fn_by_pos(effect,Vector3(sphere_emitter()))
end

local function emit_flame2_fn_by_pos(index,effect, pos,lifetime)
    local px, py, pz = pos:Get()

    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()

    local u_offset = math.random(0, 3) * .25
    local v_offset = 0

    effect:AddParticleUV(
        index, 
        lifetime, -- lifetime
        px, py, pz, -- position
        vx, vy, vz, -- velocity
        u_offset, v_offset -- uv offset
    )
end

local function CreateSwordSpiritPoints(height,width_1,width_2,height_resolution,width_resolution)
    local result = {}
    local x_offset = -(width_1 + width_2) / 2

    local param_b_1 = 0.75
    local param_a_1 = -(param_b_1 * height + width_1) / (height * height)
    -- x = param_a_1 * y * y + param_b_1 * y + width_1

    local param_b_2 = 0.9
    local param_a_2 = -(param_b_2 * height + width_2) / (height * height)
    -- x = param_a_2 * y * y + param_b_2 * y + width_2

    for y=0,height,height_resolution do
        local x1 = param_a_1 * y * y + param_b_1 * y + width_1
        local x2 = param_a_2 * y * y + param_b_2 * y + width_2

        -- table.insert(result,)
        for x=x1,x2,width_resolution do
            -- for z = -0.1,0.1,0.1 do
            --     local pos = Vector3(x + x_offset,y,z)
            --     table.insert(result,pos)
            -- end
            table.insert(result,Vector3(x + x_offset,y,0))
        end
        table.insert(result,Vector3(x2 + x_offset,y,0))
    end

    return result 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._colour = net_tinybyte(inst.GUID, "inst._colour", "colourdirty")
    inst._scale = net_tinybyte(inst.GUID, "inst._scale", "scaledirty")

    -- Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        inst:ListenForEvent("colourdirty", function()
            local colour = inst._colour:value()
            if colour and colour_index[colour] then
                inst.VFXEffect:SetColourEnvelope(0, colour_index[colour])
            end
        end)

        inst:ListenForEvent("scaledirty", function()
            local scale = inst._scale:value()
            if scale and scale_index[scale] then
                inst.VFXEffect:SetScaleEnvelope(0, scale_index[scale])
            end
        end)

        if InitEnvelope ~= nil then InitEnvelope() end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    -- SPARKLE
    effect:SetRenderResources(0, FLAME_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FLAME_RED)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FLAME_BIG)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 0.25)

    local sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        local flame_to_emit = math.random(1, 2)
        while flame_to_emit > 0 do
            emit_flame_fn(effect, sphere_emitter)
            flame_to_emit = flame_to_emit - 1
        end
    end)

    return inst
end

local function circle_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst:DoTaskInTime(5, inst.Remove)

    inst.persists = false

    -- Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    -- SPARKLE
    effect:SetRenderResources(0, FLAME_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 4096)
    effect:SetMaxLifetime(0, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FLAME_RED)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FLAME_BIG)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 0.25)

    local radius = 0.1
    local dist = 0.5

    EmitterManager:AddEmitter(inst, nil, function()
        if radius <= 4.75 then
            local theta = math.acos((2 * radius * radius - dist * dist) /
                                        (2 * radius * radius))
            local start_angle = math.random() * PI
            for angle = start_angle, start_angle + 2 * PI, theta do

                local px, py, pz =
                    (Vector3(math.cos(angle), 0, math.sin(angle)) * radius):Get()
                local task = inst:DoPeriodicTask(0, function()
                    local lifetime = FLAME_MAX_LIFETIME *
                                         (.8 + math.random() * .2)

                    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()

                    local u_offset = math.random(0, 3) * .25
                    local v_offset = math.random(0, 3) * .25

                    effect:AddParticleUV(0, 
                        lifetime, -- lifetime
                        px, py, pz, -- position
                        vx, vy, vz, -- velocity
                        u_offset, v_offset -- uv offset
                    )
                end)

                inst:DoTaskInTime(GetRandomMinMax(0.11, 0.13),
                                  function() task:Cancel() end)

            end
            radius = radius + 0.25
        end
    end)

    return inst
end

local function swordspiritfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._colour = net_tinybyte(inst.GUID, "inst._colour", "colourdirty")
    inst._scale = net_tinybyte(inst.GUID, "inst._scale", "scaledirty")

    -- Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        inst:ListenForEvent("colourdirty", function()
            local colour = inst._colour:value()
            if colour and colour_index[colour] then
                inst.VFXEffect:SetColourEnvelope(0, colour_index[colour])
            end
        end)

        inst:ListenForEvent("scaledirty", function()
            local scale = inst._scale:value()
            if scale and scale_index[scale] then
                inst.VFXEffect:SetScaleEnvelope(0, scale_index[scale])
            end
        end)

        if InitEnvelope ~= nil then 
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    -- SPARKLE
    effect:SetRenderResources(0, FLAME2_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 5200)
    effect:SetMaxLifetime(0, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FLAME_PURPLE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FLAME_TINY)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetFollowEmitter(0,true)

    effect:SetRenderResources(1, FLAME2_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 256)
    effect:SetMaxLifetime(1, FLAME_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_FLAME_PURPLE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_FLAME_SMALL)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)

    local points_to_emit = CreateSwordSpiritPoints(
        3.0,-0.3,0.2,0.1,0.1
    )
    local tails_to_emit = CreateSwordSpiritPoints(
        0.25,-0.3,0.2,0.1,0.1
    )
    -- print("points_to_emit size =",#points_to_emit)
    -- print("tails_to_emit size =",#tails_to_emit)

    local x_cood,y_cood,z_cood

    EmitterManager:AddEmitter(inst, nil, function()
        if x_cood == nil then 
            x_cood = GaleCommon.GetFaceVector(inst.entity:GetParent())
            y_cood = Vector3(0,1,0)
            z_cood = x_cood:Cross(y_cood):GetNormalized()

            for k,pt in pairs(points_to_emit) do
                points_to_emit[k] = x_cood * pt.x + y_cood * pt.y + z_cood * pt.z 
            end
            -- print("num live0:",effect:GetNumLiveParticles(0))
    
            for k,pt in pairs(tails_to_emit) do
                tails_to_emit[k] = x_cood * pt.x + y_cood * pt.y + z_cood * pt.z 
            end
        end

        for k,pt in pairs(points_to_emit) do
            emit_flame2_fn_by_pos(0,effect,pt, FLAME_MAX_LIFETIME * (.2 + math.random() * .1))
                
        end
        -- print("num live0:",effect:GetNumLiveParticles(0))

        for k,pt in pairs(tails_to_emit) do
            -- if math.abs(pt.z) <= 0.01 then
                -- emit_flame2_fn_by_pos(1,effect,pt, FLAME_MAX_LIFETIME * (.3 + math.random() * .1))
            -- end
            emit_flame2_fn_by_pos(1,effect,pt, FLAME_MAX_LIFETIME * (.3 + math.random() * .1))

        end

        
        -- print("num live1:",effect:GetNumLiveParticles(1))

    end)

    return inst
end

return Prefab("gale_flame_vfx", fn, assets),
       Prefab("gale_flame_circle_vfx", circle_fn, assets),
       Prefab("gale_flame_swordspirit_vfx", swordspiritfn, assets)
