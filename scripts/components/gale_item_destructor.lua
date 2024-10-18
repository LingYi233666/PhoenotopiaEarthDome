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
        ing = { "redgem", "bluegem", "greengem", "purplegem", "yellowgem", "orangegem" },
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
    for prefab in pairs(v.ing) do
        DESTSOUNDS_MAP[prefab] = v.soundpath
    end
end
DESTSOUNDS = nil

local GaleItemDestructor = Class(function(self, inst)
    self.inst = inst

    self.base_percent = 1
    self.select_item_fn = nil
    self.consume_reward_fn = nil
end)

function GaleItemDestructor:SetSelectItemFn(fn)
    self.select_item_fn = fn
end

function GaleItemDestructor:SetConsumeAndRewardFn(fn)
    self.consume_reward_fn = fn
end

function GaleItemDestructor:GetConsumeAndReward(target, subitems)
    subitems = subitems or {}

    local consumes = { target }
    local rewards = GaleCommon.GetDestructRecipesByEntity(target, self.base_percent)

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
        return
    end

    subitems = subitems or {}

    local consumes, rewards = self:GetConsumeAndReward(target, subitems)
    if #consumes == 0 or #rewards == 0 then
        return
    end

    for _, v in pairs(consumes) do
        v:Remove()
    end

    for name, cnt in pairs(rewards) do
        for i = 1, cnt do
            local item = SpawnAt(name, doer or self.inst)

            if doer and doer.components.inventory then
                doer.components.inventory:GiveItem(item, nil, self.inst:GetPosition())
            end
        end

        if DESTSOUNDS_MAP[name] then
            self.inst.SoundEmitter:PlaySound(DESTSOUNDS_MAP[name])
        end
    end

    return true
end

return GaleItemDestructor
