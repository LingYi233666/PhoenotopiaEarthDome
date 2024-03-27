
local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local SMOKE_TEXTURE = "fx/smoke.tex"
local SMOKE_COLOUR_ENVELOPE_NAME = "galeboss_ruinforce_eyeflame_vfx_smoke_colourenvelope"
local SMOKE_SCALE_ENVELOPE_NAME = "galeboss_ruinforce_eyeflame_vfx_smoke_scaleenvelope"

local assets =
{
    Asset("IMAGE", SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(SMOKE_COLOUR_ENVELOPE_NAME, {
		{ 0,    IntColour(225, 15, 15, 0) },
        { .3,   IntColour(200, 12, 12, 100) },
        { .55,  IntColour(198, 10, 10, 28) },
        { 1,    IntColour(198, 10, 10, 0) },
	})

    local smoke_max_scale = 1.75
    EnvelopeManager:AddVector2Envelope(
        SMOKE_SCALE_ENVELOPE_NAME,
        {
            { 0,    { smoke_max_scale, smoke_max_scale} },
			{ .3,  { smoke_max_scale * .9, smoke_max_scale * .9} },
            { .55,  { smoke_max_scale * .6, smoke_max_scale * .6} },
			{ 1,    { smoke_max_scale * .4, smoke_max_scale * .4} },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = 0.25
local function emit_smoke_fn(effect, sphere_emitter)
	local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

	effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
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

    inst.no_emit = false 
    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)
	
	--smoke
	effect:SetRenderResources(0, SMOKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, SMOKE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SMOKE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 0)
	
	

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local smoke_desired_pps_low = 5
    local smoke_desired_pps_high = 50
    local low_per_tick = smoke_desired_pps_low * tick_time
    local high_per_tick = smoke_desired_pps_high * tick_time
    local num_to_emit = 0
	
    local sphere_emitter = CreateSphereEmitter(.05)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        if inst.no_emit then
            num_to_emit = 0
            return 
        end

        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move*6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()
                
        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("galeboss_ruinforce_eyeflame_vfx", fn, assets)
