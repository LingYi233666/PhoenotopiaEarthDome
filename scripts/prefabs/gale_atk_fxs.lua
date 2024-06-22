local assets = {
    Asset("ANIM", "anim/halloween_embers_cold.zip"),
    Asset("ANIM", "anim/deer_ice_charge.zip"),

}

local function cold_firepufffn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("halloween_embers_cold")
    inst.AnimState:SetBuild("halloween_embers_cold")
    inst.AnimState:PlayAnimation("puff_" .. math.random(2, 3))
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function hot_firepufffn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("halloween_embers")
    inst.AnimState:SetBuild("halloween_embers")
    inst.AnimState:PlayAnimation("puff_" .. math.random(1, 3))
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function chargefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.KillFX = function(inst)
        inst.AnimState:PlayAnimation("blast")
        inst:ListenForEvent("animover", inst.Remove)
    end

    return inst
end

local function OnRemoveHit(inst)
    if inst.target ~= nil and inst.target:IsValid() then
        if inst.target.components.colouradder == nil then
            if inst.target.components.freezable ~= nil then
                inst.target.components.freezable:UpdateTint()
            else
                inst.target.AnimState:SetAddColour(0, 0, 0, 0)
            end
        end
        if inst.target.components.bloomer == nil then
            inst.target.AnimState:ClearBloomEffectHandle()
        end
    end
end

local function UpdateHit(inst, target)
    if target:IsValid() then
        local oldflash = inst.flash
        inst.flash = math.max(0, inst.flash - .075)
        if inst.flash > 0 then
            local c = math.min(1, inst.flash)
            local r, g, b = (inst.add_colour * c):Get()

            if target.components.colouradder ~= nil then
                target.components.colouradder:PushColour(inst, r, g, b, 0)
            else
                target.AnimState:SetAddColour(r, g, b, 0)
            end
            if inst.flash < .3 and oldflash >= .3 then
                if target.components.bloomer ~= nil then
                    target.components.bloomer:PopBloom(inst)
                else
                    target.AnimState:ClearBloomEffectHandle()
                end
            end
            return
        end
    end
    inst:Remove()
end

local function SetTarget(inst, target)
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil

        inst.target = target
        inst.OnRemoveEntity = OnRemoveHit

        if target.components.bloomer ~= nil then
            target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
        else
            target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
        inst.flash = .8 + math.random() * .4
        inst:DoPeriodicTask(0, UpdateHit, nil, target)
        UpdateHit(inst, target)
    end
end

local function CreateHitFn(prefabname, add_colour)
    local function hitfn()
        local inst = CreateEntity()

        inst:AddTag("CLASSIFIED")
        --[[Non-networked entity]]
        inst.persists = false

        inst.add_colour = add_colour

        inst.SetTarget = SetTarget
        inst.inittask = inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    return Prefab(prefabname, hitfn)
end

return Prefab("gale_atk_firepuff_cold", cold_firepufffn, assets),
    Prefab("gale_atk_firepuff_hot", hot_firepufffn, assets),
    Prefab("gale_charge_fx", chargefn, assets),
    CreateHitFn("gale_hit_color_adder", Vector3(0, 1, 1)),
    CreateHitFn("gale_hit_color_adder_green", Vector3(0, 1, 0)),
    CreateHitFn("gale_hit_color_adder_yellow", Vector3(1, 1, 0))
