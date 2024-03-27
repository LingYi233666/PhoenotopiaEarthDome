local GaleEntity = require("util/gale_entity")
local GaleCondition = require("util/gale_conditions")

local assets = {
    Asset("ANIM", "anim/athetos_medkit.zip"),

    Asset("IMAGE", "images/inventoryimages/athetos_medkit_small.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_medkit_small.xml"),
    Asset("IMAGE", "images/inventoryimages/athetos_medkit_mid.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_medkit_mid.xml"),
    Asset("IMAGE", "images/inventoryimages/athetos_medkit_big.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_medkit_big.xml"),
    Asset("IMAGE", "images/inventoryimages/athetos_medkit_big_operator.tex"),
    Asset("ATLAS", "images/inventoryimages/athetos_medkit_big_operator.xml"),
}

local heal_amount = {
    small = { 15, 10 },
    mid = { 30, 20 },
    big = { 50, 25 },
    big_operator = { 50, 25 },
}

local function OnHealFnWrapper(amout, sound)
    local function OnHealFn(inst, target)
        if not target:HasTag("mech") then
            GaleCondition.AddCondition(target, "condition_mending", amout)
        end

        if sound ~= nil then
            inst.SoundEmitter:PlaySound(sound)
        end
    end

    return OnHealFn
end

local function CreateMedkit(size)
    return GaleEntity.CreateNormalInventoryItem({
        prefabname = "athetos_medkit_" .. size,
        assets = assets,

        bank = "athetos_medkit",
        build = "athetos_medkit",
        anim = "idle_" .. size,

        inventoryitem_data = {
            use_gale_item_desc = true,
        },


        clientfn = function(inst)
            local s = 0.5
            inst.Transform:SetScale(s, s, s)
        end,

        serverfn = function(inst)
            inst:AddComponent("healer")
            inst.components.healer:SetHealthAmount(heal_amount[size][1])

            local soundpath = "gale_sfx/other/heal_" .. (size == "big_operator" and "big" or size)
            inst.components.healer.onhealfn = OnHealFnWrapper(heal_amount[size][2], soundpath)
        end,
    })
end

local rets = {}
for size, _ in pairs(heal_amount) do
    table.insert(rets, CreateMedkit(size))
end

return unpack(rets)
