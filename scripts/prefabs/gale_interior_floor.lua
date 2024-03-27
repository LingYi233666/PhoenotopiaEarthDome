local DEFAULT_TEXTURE = resolvefilepath("levels/interiors/floor_gardenstone.tex")

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "gale_interior_floor_colourenvelope"
local SCALE_ENVELOPE_NAME_512 = "gale_interior_floor_512_scaleenvelope"
local SCALE_ENVELOPE_NAME_1024 = "gale_interior_floor_1024_scaleenvelope"

local assets =
{
    Asset("SHADER", SHADER),
}

local height = 2.345 * 8 / 8
local width = 2.345 * 8 / 8 

local function InitEnvelopes()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    { 1, 1, 1, 1 } },
            { 1,    { 1, 1, 1, 1 } },
        }
    )

	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME_512,
		{
			{ 0,    { width, height } },
			{ 1,    { width, height } },
		}
	)

    EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME_1024,
		{
			{ 0,    { width/2, height/2 } },
			{ 1,    { width/2, height/2 } },
		}
	)

    InitEnvelopes = nil
end

local MAX_LIFETIME = 5

-- local function SetCutUV(inst,uv_x,uv_y)
--     inst.uv_x = uv_x
--     inst.uv_y = uv_y
-- end

local function GetTexture(inst)
    return inst.texture
end

local function SetTexture(inst, texture)
    inst.texture = texture
    inst.VFXEffect:SetRenderResources(0, resolvefilepath(texture), SHADER)
    inst.VFXEffect:ClearAllParticles(0)
end

local function SetLayer(inst,layer)
    inst.VFXEffect:SetLayer(0, layer)
    inst.VFXEffect:ClearAllParticles(0)
end

local function SetFloorRotation(inst, angle)
    inst.angle = angle 
    inst.VFXEffect:SetSpawnVectors(0,
        math.cos(inst.angle),0,math.sin(inst.angle),
        0,0,1
    )
    inst.VFXEffect:ClearAllParticles(0)
end

local function SetEmitDataList(inst,data)
    inst.emit_data_list = data or {}
    inst.VFXEffect:SetMaxNumParticles(0, math.max(1,#inst.emit_data_list))
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
    -- effect:SetSortOrder(0, -1)
    effect:SetLayer(0, LAYER_GROUND)
	-- effect:SetSortOffset(0, -1)
	effect:SetMaxLifetime(0, MAX_LIFETIME)
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
	effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_512)
	effect:SetKillOnEntityDeath(0, true)
	-- effect:EnableDepthTest(0, true)
    effect:SetUVFrameSize(0,1/8,1/8)
    -----------------------------------------------------
    inst.emit_data_list = {}

    -- inst.SetCutUV = SetCutUV
    inst.SetTexture = SetTexture
    inst.GetTexture = GetTexture
    inst.SetLayer = SetLayer
    inst.SetFloorRotation = SetFloorRotation
    inst.SetEmitDataList = SetEmitDataList

    inst:SetFloorRotation(0)

    EmitterManager:AddEmitter( inst, nil, function()

        for k,data in pairs(inst.emit_data_list) do
            effect:AddParticleUV(
                0,
                MAX_LIFETIME,   -- lifetime
                data.pos.x, data.pos.y, data.pos.z,     -- position
                0, 0, 0,			-- velocity
                data.uv_x or 0,data.uv_y or 0
            )
        end
        
    end)

    return inst
end

return Prefab("gale_interior_floor", fn, assets)