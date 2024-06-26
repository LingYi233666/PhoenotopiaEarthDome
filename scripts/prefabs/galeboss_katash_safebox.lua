local GaleEntity = require("util/gale_entity")
local GaleCommon = require("util/gale_common")

local containers = require("containers")
local containers_params = containers.params

local galeboss_katash_safebox =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(galeboss_katash_safebox.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

containers_params["galeboss_katash_safebox"] = galeboss_katash_safebox

local function SetLocked(inst, locked)
    inst.locked = locked
    if locked and inst.components.container:IsOpen() then
        inst.components.container:Close()
    end
    inst.components.container.canbeopened = not locked
end

local function OnOpen(inst, data)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")

    if TheWorld.components.galeboss_katash_spawner then
        local phase_normal          = TheWorld.components.galeboss_katash_spawner.Phase.BOX_NORMAL
        local phase_box_with_drones = TheWorld.components.galeboss_katash_spawner.Phase.BOX_WITH_DRONES
        local phase_box_with_katash = TheWorld.components.galeboss_katash_spawner.Phase.BOX_WITH_KATASH
        local phase                 = TheWorld.components.galeboss_katash_spawner.phase

        if phase_normal <= phase and phase <= phase_box_with_drones then
            print(inst, "is opened by", data.doer, "set galeboss_katash_spawner.statemem.box_opened to true")
            TheWorld.components.galeboss_katash_spawner.statemem.box_opened = true
        elseif phase == phase_box_with_katash
            and data.doer
            and not inst.trigger_katash
            and TheWorld.components.galeboss_katash_spawner.entities.katash == nil
            and not TheWorld.components.galeboss_katash_spawner.statemem.katash_defeated
        then
            inst.trigger_katash = true
            local grenade = SpawnAt("athetos_grenade_elec", inst)
            grenade.components.complexprojectile:Launch(inst:GetPosition(), inst)

            print(inst, "is opened by", data.doer, "summon grenade and katash")

            inst:DoTaskInTime(2, function()
                local pos = inst:GetPosition()
                local offset = FindWalkableOffset(pos, math.random() * TWOPI, 5, 33, nil, false, nil, false, false)
                if offset then
                    pos = pos + offset
                end
                TheWorld.components.galeboss_katash_spawner:Spawnkatash(pos, data.doer)
            end)
        end
    end
end

local function OnClose(inst)
    if inst.locked then
        inst.AnimState:PlayAnimation("closed")
    else
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("idle_unlock", false)
    end

    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function OnHammered(inst, worker)
    if inst.locked then
        print(inst, "is hammered to be unlocked by", worker)
        inst:SetLocked(false)
    end
    inst.components.workable:SetWorkLeft(5)
end

local function OnHit(inst, worker)
    inst.components.container:Close()
    if inst.locked then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
    else
        inst.AnimState:PlayAnimation("hit_unlocked")
        inst.AnimState:PushAnimation("idle_unlock", false)
        inst.components.workable:SetWorkLeft(5)
    end
end

local function GetStatus(inst)
    return inst.locked and "LOCKED" or "GENERIC"
end

local function OnSave(inst, data)
    data.locked = inst.locked
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.locked ~= nil then
            inst:SetLocked(data.locked)
        end
    end
end

return GaleEntity.CreateNormalEntity({
    prefabname = "galeboss_katash_safebox",
    assets = {
        Asset("ANIM", "anim/quagmire_safe.zip"),
    },

    tags = { "structure", "chest" },

    bank = "quagmire_safe",
    build = "quagmire_safe",
    anim = "closed",


    clientfn = function(inst)
        MakeSnowCoveredPristine(inst)
    end,

    serverfn = function(inst)
        inst.locked = false
        inst.SetLocked = SetLocked

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

        inst:AddComponent("container")
        inst.components.container:WidgetSetup("galeboss_katash_safebox")
        inst.components.container.onopenfn = OnOpen
        inst.components.container.onclosefn = OnClose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(5)
        inst.components.workable:SetOnFinishCallback(OnHammered)
        inst.components.workable:SetOnWorkCallback(OnHit)

        MakeSnowCovered(inst)
    end,
})
