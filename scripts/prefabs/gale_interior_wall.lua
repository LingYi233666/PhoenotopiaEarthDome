local DEFAULT_TEXTURE = resolvefilepath("levels/interiors/gale_wall_sinkhole.tex")

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "gale_interior_wall_colourenvelope"
-- local SCALE_ENVELOPE_NAME_HIGH = "gale_interior_wall_high_scaleenvelope"
-- local SCALE_ENVELOPE_NAME_NORMAL = "gale_interior_wall_normal_scaleenvelope"
-- local SCALE_ENVELOPE_NAME_LOW = "gale_interior_wall_low_scaleenvelope"

local SCALE_ENVELOPE_NAMEs = {}
for i = 1,8 do
    table.insert(SCALE_ENVELOPE_NAMEs,"gale_interior_wall_height_"..i.."_scaleenvelope")
end

local assets =
{
    Asset("SHADER", SHADER),
}

-- local height = 2.345 * 8 / 8
-- local width = 2.345 * 8 / 8 
-- The width is cutted 1/8,so it's 1,see SetUVFrameSize also 
-- However,the height is still 8
-- VFX is emit is middle,so it should raise by 4

local height = 2.345 * 1 / 8
local width = 2.345 * 1 / 8 

local function InitEnvelopes()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    { 1, 1, 1, 1 } },
            { 1,    { 1, 1, 1, 1 } },
        }
    )

    for k,v in pairs(SCALE_ENVELOPE_NAMEs) do
        EnvelopeManager:AddVector2Envelope(
            v,
            {
                { 0,    { k * width, k * height } },
                { 1,    { k * width, k * height } },
            }
        )
    end

	-- EnvelopeManager:AddVector2Envelope(
	-- 	SCALE_ENVELOPE_NAME_HIGH,
	-- 	{
	-- 		{ 0,    { width, height } },
	-- 		{ 1,    { width, height } },
	-- 	}
	-- )

    -- EnvelopeManager:AddVector2Envelope(
	-- 	SCALE_ENVELOPE_NAME_HIGH,
	-- 	{
	-- 		{ 0,    { width, height } },
	-- 		{ 1,    { width, height } },
	-- 	}
	-- )

    InitEnvelopes = nil
end

-- c_spawn("gale_test_wall")
local MAX_LIFETIME = 0.33

local function GetTexture(inst)
    return inst.texture
end

local function SetTexture(inst, texture)
    inst.texture = texture
    inst.VFXEffect:SetRenderResources(0, resolvefilepath(texture), SHADER)
end

local function SetLayer(inst,layer)
    inst.VFXEffect:SetLayer(0, layer)
end

local function SetWallRotation(inst, angle)
    inst.angle = angle 
end

local function SetEmitDataList(inst,data)
    inst.emit_data_list = data or {}
    inst.VFXEffect:SetMaxNumParticles(0, math.max(1,#inst.emit_data_list))
end

local function GenEmitData(inst,start_pos,end_pos,offset)
    local down_y = -0.1
    local wall_dist = 1
    offset = offset or 0

    local delta = end_pos - start_pos
    delta.y = 0
    local delta_nor = delta:GetNormalized()

    local angle = math.atan2(delta.z, delta.x)
    if angle < 0 then
        angle = 2 * PI + angle
    end
    inst:SetWallRotation(angle)

    local emit_data_list = {}
    for i = 0,delta:Length() - wall_dist,wall_dist do
        local pos = start_pos + delta_nor * i + delta_nor * (wall_dist / 2)
        pos.y = pos.y + down_y

        table.insert(emit_data_list,{
            pos = pos,
            uv_x = offset / inst.height,
        })        
        

        offset = offset + 1
        if offset >= inst.height then
            offset = 0
        end
    end

    inst.emit_data_list = emit_data_list



    inst.VFXEffect:SetMaxNumParticles(0, math.max(1,#inst.emit_data_list))

    return offset
end

local function FnWrapper(height)
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
    
        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        if TheNet:GetIsClient() then
            inst.entity:AddClientSleepable()
        end

        
        inst.persists = false
    
        inst:AddTag("FX")
    
        -----------------------------------------------------
    
        if InitEnvelopes ~= nil then
            InitEnvelopes()
        end
    
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(1)
    
        effect:SetRenderResources(0, DEFAULT_TEXTURE, SHADER)
        effect:SetMaxNumParticles(0, 1)
        effect:SetSortOrder(0, -1)
        effect:SetLayer(0, LAYER_BACKGROUND)
        effect:SetMaxLifetime(0, MAX_LIFETIME)
        effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
        effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAMEs[height])
        effect:SetUVFrameSize(0, 1/height, 1)
        effect:SetKillOnEntityDeath(0, true)
        effect:EnableDepthTest(0, true)
        effect:SetSpawnVectors(0,
            1,0,0,
            0,1,0
        )
        -----------------------------------------------------
        inst.height = height
        inst.emit_data_list = {}
    
        inst.SetTexture = SetTexture
        inst.GetTexture = GetTexture
        inst.SetLayer = SetLayer
        inst.SetWallRotation = SetWallRotation
        inst.GenEmitData = GenEmitData
    
        inst:SetWallRotation(0)
    
        EmitterManager:AddEmitter( inst, nil, function()
            local c_down = TheCamera:GetPitchDownVec():Normalize()
            local c_right = TheCamera:GetRightVec():Normalize()
    
            local c_up = c_down:Cross(c_right):Normalize()
            
            local h_suit = height / 2
    
            inst.VFXEffect:SetSpawnVectors(0,
                math.cos(inst.angle),0,math.sin(inst.angle),
                c_up.x, c_up.y, c_up.z
            )
    
            for k,data in pairs(inst.emit_data_list) do
                effect:AddParticleUV(
                    0,
                    MAX_LIFETIME,   -- lifetime
                    c_up.x * h_suit + data.pos.x, c_up.y * h_suit + data.pos.y, c_up.z * h_suit + data.pos.z,     -- position
                    0, 0, 0,			-- velocity
                    data.uv_x, 0        -- uv offset
                )
            end
            
        end )
    
        return inst
    end

    return fn 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    if TheNet:GetIsClient() then
        inst.entity:AddClientSleepable()
    end
    inst.persists = false

    inst:AddTag("FX")

    -----------------------------------------------------

    if InitEnvelopes ~= nil then
        InitEnvelopes()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

	effect:SetRenderResources(0, DEFAULT_TEXTURE, SHADER)
	effect:SetMaxNumParticles(0, 1)
    effect:SetSortOrder(0, -1)
    effect:SetLayer(0, LAYER_BACKGROUND)
	effect:SetMaxLifetime(0, MAX_LIFETIME)
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
	effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_HIGH)
    effect:SetUVFrameSize(0, 1/8, 1)
	effect:SetKillOnEntityDeath(0, true)
	effect:EnableDepthTest(0, true)
    effect:SetSpawnVectors(0,
        1,0,0,
        0,1,0
    )
    -----------------------------------------------------
    inst.emit_data_list = {}

    inst.SetTexture = SetTexture
    inst.GetTexture = GetTexture
    inst.SetLayer = SetLayer
    inst.SetWallRotation = SetWallRotation
    inst.SetEmitDataList = SetEmitDataList

    inst:SetWallRotation(0)

    EmitterManager:AddEmitter( inst, nil, function()
        local c_down = TheCamera:GetPitchDownVec():Normalize()
        local c_right = TheCamera:GetRightVec():Normalize()

        local c_up = c_down:Cross(c_right):Normalize()


        inst.VFXEffect:SetSpawnVectors(0,
            math.cos(inst.angle),0,math.sin(inst.angle),
            c_up.x, c_up.y, c_up.z
        )

        for k,data in pairs(inst.emit_data_list) do
            effect:AddParticleUV(
                0,
                MAX_LIFETIME,   -- lifetime
                c_up.x * 4 + data.pos.x, c_up.y * 4 + data.pos.y, c_up.z * 4 + data.pos.z,     -- position
                0, 0, 0,			-- velocity
                data.uv_x, 0        -- uv offset
            )
        end
        
    end )

    return inst
end

-- return Prefab("gale_interior_wall", fn, assets)

local return_prefabs = {}
for k,v in pairs(SCALE_ENVELOPE_NAMEs) do
    table.insert(return_prefabs,Prefab("gale_interior_wall_height_"..k, FnWrapper(k), assets))
end

return unpack(return_prefabs)