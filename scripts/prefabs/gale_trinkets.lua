local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local function DuckEscapeElectrocute(inst, owner)
    if owner:IsValid() and owner.sg and owner.sg.currentstate == "electrocute" then
        owner.sg:GoToState("idle", true)

        -- TODO: Announce here

        inst.components.stackable:Get():Remove()
    end
end

local function DuckStopTracing(inst)
    if inst.trace_owner ~= nil then
        print(inst, "stop tracing old owner:", inst.trace_owner)

        inst:RemoveEventCallback("newstate", inst.trace_fn, inst.trace_owner)
    end
    inst.trace_owner = nil
    inst.trace_fn    = nil
end

local function DuckOnPutInInventory(inst, owner)
    if owner and owner.sg then
        DuckStopTracing(inst)

        inst.trace_owner = owner
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

        print(inst, "trace new owner:", owner)

        inst:ListenForEvent("newstate", inst.trace_fn, owner)
    end
end

local function DuckOnDropped(inst)
    DuckStopTracing(inst)
end

----------------------------------------------------------------------
local function RabbitStartTracing(inst, owner)
    inst.trace_owner = owner

    local stacksize = inst.components.stackable:StackSize()
    local unit_recv = TUNING.DAPPERNESS_LARGE / 40
    owner.components.sanity.externalmodifiers:SetModifier(inst, unit_recv * stacksize, inst.prefab)
end

local function RabbitStopTracing(inst)
    if inst.trace_owner then
        inst.trace_owner.components.sanity.externalmodifiers:RemoveModifier(inst, inst.prefab)
    end

    inst.trace_owner = nil
end

local function RabbitCheckTracing(inst, new_owner)
    if new_owner and new_owner.components.sanity and new_owner:HasTag("gralupo") then
        if inst.trace_owner ~= new_owner then
            RabbitStopTracing(inst)
            RabbitStartTracing(inst, new_owner)
        end
    else
        RabbitStopTracing(inst)
    end
end

local function RabbitOnPutInInventory(inst, owner)
    RabbitCheckTracing(inst, owner)
    -- inst.check_task = inst:DoPeriodicTask(0)
end

local function RabbitOnDropped(inst)
    RabbitCheckTracing(inst)
end

----------------------------------------------------------------------

local trinkets_config =
{
    gale_trinket_duck = {
        goldvalue = 3,
        serverfn = function(inst)
            inst.components.inventoryitem:SetOnPutInInventoryFn(DuckOnPutInInventory)
            inst.components.inventoryitem:SetOnDroppedFn(DuckOnDropped)
        end,
    },

    gale_trinket_rabbit = {
        goldvalue = 3,
        serverfn = function(inst)
            inst.components.inventoryitem:SetOnPutInInventoryFn(RabbitOnPutInInventory)
            inst.components.inventoryitem:SetOnDroppedFn(RabbitOnDropped)
        end,
    },
}

local function MakeTrinket(config)
    local default_floatable_param = { "med",
        0.2,
        { 1.1, 0.5, 1.1 },
        nil,
        nil,
        {
            bank = "gale_trinkets",
            anim = "idle_water",
        } }

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
            floatable_param = config.floatable_param or default_floatable_param
        },

        clientfn = function(inst)
            inst.AnimState:OverrideSymbol("gale_trinket_duck", "gale_trinkets", config.prefabname)

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

            if config.serverfn then
                config.serverfn(inst)
            end
        end,
    })
end

local rets = {}
for prefabanme, config in pairs(trinkets_config) do
    config.prefabanme = prefabanme
    table.insert(rets, MakeTrinket(config))
end

return unpack(rets)
