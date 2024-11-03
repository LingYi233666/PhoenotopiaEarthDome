local GaleCommon = require("util/gale_common")

local DESTSOUNDS =
{
    { --magic
        soundpath = "dontstarve/common/destroy_magic",
        ing = { "nightmarefuel", "livinglog" },
    },
    { --cloth
        soundpath = "dontstarve/common/destroy_clothing",
        ing = { "silk", "beefalowool" },
    },
    { --tool
        soundpath = "dontstarve/common/destroy_tool",
        ing = { "twigs" },
    },
    { --gem
        soundpath = "dontstarve/common/gem_shatter",
        ing = { "redgem", "bluegem", "greengem", "purplegem", "yellowgem", "orangegem", "opalpreciousgem" },
    },
    { --wood
        soundpath = "dontstarve/common/destroy_wood",
        ing = { "log", "boards" },
    },
    { --stone
        soundpath = "dontstarve/common/destroy_stone",
        ing = { "rocks", "cutstone" },
    },
    { --straw
        soundpath = "dontstarve/common/destroy_straw",
        ing = { "cutgrass", "cutreeds" },
    },
}

local DESTSOUNDS_MAP = {}

for _, v in pairs(DESTSOUNDS) do
    for i, prefab in pairs(v.ing) do
        DESTSOUNDS_MAP[prefab] = v.soundpath
    end
end
DESTSOUNDS = nil

print("DESTSOUNDS_MAP is:")
dumptable(DESTSOUNDS_MAP)

local GaleItemDestructor = Class(function(self, inst)
    self.inst = inst

    self.base_percent = 1
    self.spawn_gem = false
    self.spawn_preciousgem = true

    self.select_item_fn = nil
    self.consume_reward_fn = nil
    self.on_destruct_fn = nil
end)

function GaleItemDestructor:SetSelectItemFn(fn)
    self.select_item_fn = fn
end

function GaleItemDestructor:SetConsumeAndRewardFn(fn)
    self.consume_reward_fn = fn
end

function GaleItemDestructor:SetOnDestructFn(fn)
    self.on_destruct_fn = fn
end

function GaleItemDestructor:GetConsumeAndReward(target, subitems)
    subitems = subitems or {}

    local consumes = { target }
    local rewards = GaleCommon.GetDestructRecipesByEntity(target, self.base_percent, math.ceil)

    local banned_item_names = {}
    for name, cnt in pairs(rewards) do
        if not self.spawn_gem and string.sub(name, -3) == "gem" then
            table.insert(banned_item_names, name)
        end
        if not self.spawn_preciousgem and string.sub(name, -11, -4) == "precious" then
            table.insert(banned_item_names, name)
        end
    end

    for _, name in pairs(banned_item_names) do
        rewards[name] = nil
    end

    if self.consume_reward_fn then
        self.consume_reward_fn(self.inst, target, subitems, consumes, rewards)
    end

    return consumes, rewards
end

function GaleItemDestructor:Destruct(doer, target, subitems)
    if self.select_item_fn then
        target, subitems = self.select_item_fn(self.inst, doer)
    end

    if not target then
        return false, "ANNOUNCE_CANT_DESTRUCT_NO_TARGET"
    end

    subitems = subitems or {}

    local consumes, rewards = self:GetConsumeAndReward(target, subitems)
    if #consumes == 0 then
        return false, "ANNOUNCE_CANT_DESTRUCT_NO_CONSUMES"
    end

    if GetTableSize(rewards) == 0 then
        return false, "ANNOUNCE_CANT_DESTRUCT_NO_REWARDS"
    end

    local raw_rewards = GaleCommon.GetDestructRecipesByName(target.prefab, 1.0, math.ceil)
    for name, cnt in pairs(raw_rewards) do
        if DESTSOUNDS_MAP[name] then
            self.inst.SoundEmitter:PlaySound(DESTSOUNDS_MAP[name])
        end
    end


    for _, v in pairs(consumes) do
        local owner = v.components.inventoryitem.owner
        if owner then
            if owner.components.container then
                local slot = owner.components.container:GetItemSlot()
                if slot and slot > 0 then
                    owner.components.container:DropItemBySlot(slot)
                end
            end
        end

        ------------------------------------------
        -- Before remove do sth

        if v.components.inventory ~= nil then
            v.components.inventory:DropEverything()
        end

        if v.components.container ~= nil then
            v.components.container:DropEverything(nil, true)
        end

        if v.components.spawner ~= nil and v.components.spawner:IsOccupied() then
            v.components.spawner:ReleaseChild()
        end

        if v.components.occupiable ~= nil and v.components.occupiable:IsOccupied() then
            local item = v.components.occupiable:Harvest()
            if item ~= nil then
                item.Transform:SetPosition(v.Transform:GetWorldPosition())
                item.components.inventoryitem:OnDropped()
            end
        end

        if v.components.trap ~= nil then
            v.components.trap:Harvest()
        end

        if v.components.dryer ~= nil then
            v.components.dryer:DropItem()
        end

        if v.components.harvestable ~= nil then
            v.components.harvestable:Harvest()
        end

        if v.components.stewer ~= nil then
            v.components.stewer:Harvest()
        end

        if v.components.constructionsite ~= nil then
            v.components.constructionsite:DropAllMaterials()
        end

        if v.components.inventoryitemholder ~= nil then
            v.components.inventoryitemholder:TakeItem()
        end
        ------------------------------------------

        v:Remove()
    end

    for name, cnt in pairs(rewards) do
        for i = 1, cnt do
            local item = SpawnAt(name, doer or self.inst)

            if doer and doer.components.inventory then
                doer.components.inventory:GiveItem(item, nil, self.inst:GetPosition())
            end
        end
    end

    if self.on_destruct_fn then
        self.on_destruct_fn(self.inst, rewards, raw_rewards)
    end

    return true
end

return GaleItemDestructor
