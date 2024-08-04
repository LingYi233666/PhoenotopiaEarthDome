require "prefabutil"

local cooking = require("cooking")

local assets =
{
    Asset("ANIM", "anim/cook_pot.zip"),
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"),
}

local assets_item =
{
    Asset("ANIM", "anim/portable_cook_pot.zip"),
}

local prefabs =
{
    "collapse_small",
}


local assets_archive =
{
    Asset("ANIM", "anim/cook_pot.zip"),
    Asset("ANIM", "anim/cookpot_archive.zip"),
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"),
    Asset("MINIMAP_IMAGE", "cookpot_archive"),
}

for k, v in pairs(cooking.recipes.cookpot) do
    table.insert(prefabs, v.name)

    if v.overridebuild then
        table.insert(assets, Asset("ANIM", "anim/" .. v.overridebuild .. ".zip"))
        table.insert(assets_archive, Asset("ANIM", "anim/" .. v.overridebuild .. ".zip"))
    end
end

local containers = require("containers")
local containers_params = containers.params
local widgetsetup_old = containers.widgetsetup

local gale_cookpot =
{
    widget =
    {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = STRINGS.ACTIONS.COOK,
            position = Vector3(0, -165, 0),
        }
    },
    acceptsstacks = false,
    type = "cooker",
}

function gale_cookpot.itemtestfn(container, item, slot)
    return cooking.IsCookingIngredient(item.prefab) and not container.inst:HasTag("burnt")
end

function gale_cookpot.widget.buttoninfo.fn(inst)
    if inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendModRPCToServer(MOD_RPC["gale_rpc"]["cook_qte_button_clicked"], inst)
    end
end

function gale_cookpot.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

containers_params["gale_cookpot"] = gale_cookpot
containers_params["gale_cookpot_duplicate"] = gale_cookpot

local function ChangeToItem(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end


    local item = SpawnPrefab(inst.item_prefab, inst.linked_skinname, inst.skin_id)
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    item.AnimState:PlayAnimation("collapse")
    item.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/collapse")
end

local function onhammered(inst) --, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst:HasTag("burnt") then
        inst.components.lootdropper:SpawnLootPrefab("ash")
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    else
        ChangeToItem(inst)
    end

    inst:Remove()
end

local function onhit(inst) --, worker)
    if not inst:HasTag("burnt") then
        if inst.components.gale_qte_cooker:IsCooking() then
            inst.AnimState:PlayAnimation("hit_cooking")
            inst.AnimState:PushAnimation("cooking_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
        else
            if inst.components.container ~= nil and inst.components.container:IsOpen() then
                inst.components.container:Close()
                --onclose will trigger sfx already
            else
                inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
            end
            inst.AnimState:PlayAnimation("hit_empty")
            inst.AnimState:PushAnimation("idle_empty", false)
        end
    end
end

--anim and sound callbacks

local function startcookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_loop", true)
        inst.SoundEmitter:KillSound("snd")
        -- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
        inst.SoundEmitter:PlaySound("gale_sfx/cooking/cooking_sizzle", "snd")
        inst.Light:Enable(true)
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_pre_loop")
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if not inst.components.gale_qte_cooker:IsCooking() then
            inst.AnimState:PlayAnimation("idle_empty")
            inst.SoundEmitter:KillSound("snd")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    end
end

local function SetProductSymbol(inst, product, overridebuild)
    local recipe = cooking.GetRecipe("cookpot", product)
    local potlevel = recipe ~= nil and recipe.potlevel or nil
    local build = (recipe ~= nil and recipe.overridebuild) or overridebuild or "cook_pot_food"
    local overridesymbol = (recipe ~= nil and recipe.overridesymbolname) or product

    if potlevel == "high" then
        inst.AnimState:Show("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Hide("swap_low")
    elseif potlevel == "low" then
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Hide("swap_mid")
        inst.AnimState:Show("swap_low")
    else
        inst.AnimState:Hide("swap_high")
        inst.AnimState:Show("swap_mid")
        inst.AnimState:Hide("swap_low")
    end

    inst.AnimState:OverrideSymbol("swap_cooked", build, overridesymbol)
end


local function ShowProduct(inst)
    if not inst:HasTag("burnt") then
        local product = inst.components.gale_qte_cooker.product
        SetProductSymbol(inst, product, IsModCookingProduct("cookpot", product) and product or nil)
    end
end

local function donecookfn(inst, end_state)
    if end_state == "INTERRUPTE" then
        inst.AnimState:PlayAnimation("idle_empty")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    else
        if not inst:HasTag("burnt") then
            inst.AnimState:PlayAnimation("cooking_pst")
            inst.AnimState:PushAnimation("idle_full", false)
            ShowProduct(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
            inst.SoundEmitter:PlaySound("gale_sfx/cooking/cooking_finished")
        end
    end

    inst.SoundEmitter:KillSound("snd")
    inst.Light:Enable(false)
end

local function harvestfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle_empty")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (not inst.components.gale_qte_cooker:IsCooking() and "EMPTY")
        or "COOKING_SHORT"
end

local function OnDismantle(inst) --, doer)
    ChangeToItem(inst)
    inst:Remove()
end

local function commonfn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("portablecookpot.png")

    inst.Light:Enable(false)
    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235 / 255, 62 / 255, 12 / 255)

    inst.DynamicShadow:SetSize(2, 1)

    inst:AddTag("structure")

    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("portable_cook_pot")
    inst.AnimState:PlayAnimation("idle_empty")

    inst:SetPrefabNameOverride("gale_cookpot_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.item_prefab = "gale_cookpot_item"

    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("gale_qte_cooker")
    inst.components.gale_qte_cooker.onstartcooking = startcookfn
    inst.components.gale_qte_cooker.ondonecooking = donecookfn
    inst.components.gale_qte_cooker.onharvest = harvestfn

    inst:AddComponent("container")
    inst.components.container:WidgetSetup(data.widgetname)
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

local function fn()
    local inst = commonfn({
        widgetname = "gale_cookpot",
    })

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function duplicatefn()
    local inst = commonfn({
        widgetname = "gale_cookpot_duplicate",
    })

    inst:SetPrefabNameOverride("gale_cookpot_item_duplicate")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.item_prefab = "gale_cookpot_item_duplicate"


    return inst
end

---------------------------------------------------------------
---------------- Inventory Portable Cookpot -------------------
---------------------------------------------------------------

local function ondeploy(inst, pt, deployer)
    local pot = SpawnPrefab(inst.cookpot_prefab, inst.linked_skinname, inst.skin_id)
    if pot ~= nil then
        pot.Physics:SetCollides(false)
        pot.Physics:Teleport(pt.x, 0, pt.z)
        pot.Physics:SetCollides(true)
        pot.AnimState:PlayAnimation("place")
        pot.AnimState:PushAnimation("idle_empty", false)
        pot.SoundEmitter:PlaySound("dontstarve/common/together/portable/cookpot/place")
        inst:Remove()
        PreventCharacterCollisionsWithPlacedObjects(pot)
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("portable_cook_pot")
    inst.AnimState:SetBuild("portable_cook_pot")
    inst.AnimState:PlayAnimation("idle_ground")

    inst:AddTag("portableitem")

    MakeInventoryFloatable(inst, "med", 0.1, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.cookpot_prefab = "gale_cookpot"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "portablecookpot_item"

    inst:AddComponent("gale_item_desc")

    inst:AddComponent("deployable")
    inst.components.deployable.restrictedtag = "gale"
    inst.components.deployable.ondeploy = ondeploy
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

local function duplicateitemfn()
    local inst = itemfn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.cookpot_prefab = "gale_cookpot_duplicate"

    return inst
end

return Prefab("gale_cookpot", fn, assets, prefabs),
    Prefab("gale_cookpot_duplicate", duplicatefn, assets, prefabs),
    Prefab("gale_cookpot_item", itemfn, assets_item),
    Prefab("gale_cookpot_item_duplicate", duplicateitemfn, assets_item),
    MakePlacer("gale_cookpot_item_placer", "portable_cook_pot", "portable_cook_pot", "idle_empty"),
    MakePlacer("gale_cookpot_item_duplicate_placer", "portable_cook_pot", "portable_cook_pot", "idle_empty")
