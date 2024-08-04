local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local function DuckOwnerValidFn(inst, owner)
    return owner.sg ~= nil
end

local function DuckEscapeElectrocute(inst, owner)
    if owner:IsValid() and owner.sg and owner.sg.currentstate.name == "electrocute" then
        print(inst, "help", owner)

        owner.sg:GoToState("idle", true)

        -- TODO: Announce here
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["announce"], owner.userid,
                           STRINGS.GALE_UI.ANNOUNCE_DUCK_AVOID_ELECTROCUTE, "default", 202 / 255,
                           174 / 255, 118 / 255, 255 / 255)

        inst.components.stackable:Get():Remove()
    end
end


local function DuckOnActiviteFn(inst, owner)
    inst.trace_fn = function(_, data)
        if data.statename == "electrocute" then
            if inst.escape_task then
                inst.escape_task:Cancel()
            end
            inst.escape_task = inst:DoTaskInTime(0, function()
                DuckEscapeElectrocute(inst, owner)
                inst.escape_task = nil
            end)
        end
    end

    inst:ListenForEvent("newstate", inst.trace_fn, owner)
end

local function DuckOnDeactiviteFn(inst, owner)
    inst:RemoveEventCallback("newstate", inst.trace_fn, owner)
    inst.trace_fn = nil
end


----------------------------------------------------------------------

local function RabbitOwnerValidFn(inst, owner)
    return owner:HasTag("gallop")
end

local RABBIT_UNIT_RECOVER = TUNING.DAPPERNESS_LARGE / 40

local function RabbitOnActiviteFn(inst, owner)
    local stacksize = inst.components.stackable:StackSize()
    owner.components.sanity.externalmodifiers:SetModifier(inst, RABBIT_UNIT_RECOVER * stacksize, inst.prefab)
end

local function RabbitOnStackChange(inst)
    local owner = inst.components.gale_inventory_effect_item:GetOwner()
    if owner ~= nil then
        local stacksize = inst.components.stackable:StackSize()
        owner.components.sanity.externalmodifiers:SetModifier(inst, RABBIT_UNIT_RECOVER * stacksize, inst.prefab)
    end
end

local function RabbitOnDeactiviteFn(inst, owner)
    owner.components.sanity.externalmodifiers:RemoveModifier(inst, inst.prefab)
end


----------------------------------------------------------------------
-- size, offset, scale, swap_bank, float_index, swap_data
local default_floatable_param = { "small", 0.2, { 1.1, 0.5, 1.1 }, nil, nil, { bank = "gale_trinkets", anim = "idle_water" } }
local default_floatable_param_idle_anim = deepcopy(default_floatable_param)
default_floatable_param_idle_anim[6].anim = "idle"

local trinkets_config =
{
    gale_trinket_duck = {
        goldvalue = 3,
        serverfn = function(inst)
            -- inst.components.inventoryitem:SetOnPutInInventoryFn(DuckOnPutInInventory)
            -- inst.components.inventoryitem:SetOnDroppedFn(DuckOnDropped)

            inst:AddComponent("gale_inventory_effect_item")
            inst.components.gale_inventory_effect_item:SetTargetValidFn(DuckOwnerValidFn)
            inst.components.gale_inventory_effect_item:SetOnActivateFn(DuckOnActiviteFn)
            inst.components.gale_inventory_effect_item:SetOnDeactivateFn(DuckOnDeactiviteFn)
        end,
    },

    gale_trinket_rabbit = {
        goldvalue = 3,
        serverfn = function(inst)
            -- inst.components.inventoryitem:SetOnPutInInventoryFn(RabbitOnPutInInventory)
            -- inst.components.inventoryitem:SetOnDroppedFn(RabbitOnDropped)

            inst:AddComponent("gale_inventory_effect_item")
            inst.components.gale_inventory_effect_item:SetTargetValidFn(RabbitOwnerValidFn)
            inst.components.gale_inventory_effect_item:SetOnActivateFn(RabbitOnActiviteFn)
            inst.components.gale_inventory_effect_item:SetOnDeactivateFn(RabbitOnDeactiviteFn)

            inst:ListenForEvent("stacksizechange", RabbitOnStackChange)
        end,
        floatable_param = default_floatable_param_idle_anim,
    },
}


local function MakeTrinket(config)
    local floating_param = (config.floatable_param == nil and default_floatable_param or config.floatable_param)

    local function PlayIdleAnim(inst)
        if floating_param == nil then
            return
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        if TheWorld.Map:IsOceanAtPoint(x, y, z, false) then
            inst.AnimState:PlayAnimation(floating_param[6] and floating_param[6].anim or "idle_water")
            -- inst.AnimState:SetFloatParams(0.1, 1.0, inst.components.floater.bob_percent)
        else
            inst.AnimState:PlayAnimation("idle")
        end
    end


    return GaleEntity.CreateNormalInventoryItem({
        prefabname = config.prefabname,
        assets = {
            Asset("ANIM", "anim/gale_trinkets.zip"),

            Asset("IMAGE", "images/inventoryimages/" .. config.prefabname .. ".tex"),
            Asset("ATLAS", "images/inventoryimages/" .. config.prefabname .. ".xml"),
        },

        bank = "gale_trinkets",
        build = "gale_trinkets",
        anim = "idle",

        tags = config.tags or { "molebait", "cattoy" },

        inventoryitem_data = {
            use_gale_item_desc = true,
            floatable_param = floating_param,
            -- floatable_param = false,
        },

        clientfn = function(inst)
            inst.AnimState:OverrideSymbol("gale_trinket_duck", "gale_trinkets", config.prefabname)

            if inst.components.floater then
                local old_OnLandedClient = inst.components.floater.OnLandedClient
                inst.components.floater.OnLandedClient = function(...)
                    local rets = old_OnLandedClient(...)
                    inst.AnimState:SetFloatParams(0.1, 1.0, inst.components.floater.bob_percent)
                    return rets
                end
            end

            if config.clientfn then
                config.clientfn(inst)
            end
        end,

        serverfn = function(inst)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

            inst:AddComponent("tradable")
            inst.components.tradable.goldvalue = config.goldvalue or 1
            inst.components.tradable.tradefor = config.tradefor -- {"chesspiece_bishop_sketch"},

            if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                inst.components.tradable.halloweencandyvalue = config.halloweencandyvalue or 1
            end

            inst.components.tradable.rocktribute = math.ceil(inst.components.tradable.goldvalue / 3)

            inst:AddComponent("bait")

            inst:ListenForEvent("on_landed", PlayIdleAnim)

            if config.serverfn then
                config.serverfn(inst)
            end
        end,
    })
end

local rets = {}
for prefabname, config in pairs(trinkets_config) do
    config.prefabname = prefabname
    table.insert(rets, MakeTrinket(config))
end

local old_PickRandomTrinket = PickRandomTrinket
function PickRandomTrinket(...)
    if math.random() < 0.5 then
        return old_PickRandomTrinket(...)
    end

    return GetRandomKey(trinkets_config)
end

return unpack(rets)
