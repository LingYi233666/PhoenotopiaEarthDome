local GaleCommon = require("util/gale_common")
local GaleConditionUtil = require("util/gale_conditions")

local GaleFluteBuffed = Class(function(self, inst)
    self.inst = inst

    self.cooldowns_define = {
        melody_panselo = 180,
        melody_battle = 180,
        melody_phoenix = 180,
    }

    self.cooldowns = {
        melody_panselo = 0,
        melody_battle = 0,
        melody_phoenix = 0,
    }

    self.inst:StartUpdatingComponent(self)
end)

function GaleFluteBuffed:OnSave()
    return self.cooldowns
end

function GaleFluteBuffed:OnLoad(data)
    if data then
        self.cooldowns.melody_panselo = data.melody_panselo ~= nil and data.melody_panselo or 0
        self.cooldowns.melody_battle = data.melody_battle ~= nil and data.melody_battle or 0
        self.cooldowns.melody_phoenix = data.melody_phoenix ~= nil and data.melody_phoenix or 0
    end
end

function GaleFluteBuffed:GetCD(name)
    return self.cooldowns[name]
end

function GaleFluteBuffed:TryTrigger(name)
    local is_success = nil
    if self.cooldowns[name] == nil then
        is_success = nil
    elseif self.cooldowns[name] <= 0 then
        if name == "melody_panselo" then
            if self.inst.components.health and not self.inst.components.health:IsDead()
                and not self.inst.sg:HasStateTag("dead") and not self.inst.sg:HasStateTag("playerghost") then
                self.inst.components.health:DoDelta(99)
                is_success = true
            end
        elseif name == "melody_battle" then
            GaleCommon.AoeForEach(self.inst, self.inst:GetPosition(), 12, { "_combat" }, nil, nil, function(inst, v)
                                      GaleConditionUtil.AddCondition(v, "condition_power", inst == v and 6 or 3)
                                  end, function(inst, v)
                                      return not IsEntityDeadOrGhost(v, true)
                                          and (
                                              inst == v
                                              or (inst.components.combat and inst.components.combat:IsAlly(v))
                                              or (not TheNet:GetPVPEnabled() and v:HasTag("player"))
                                          )
                                  end)
            is_success = true
        elseif name == "melody_phoenix" then
            -- GaleConditionUtil.AddCondition(self.inst,"condition_lullaby")
            GaleConditionUtil.AddCondition(self.inst, "condition_stamina_recover", 60)
            is_success = true
        end
    else
        is_success = false
    end

    if is_success == true then
        self.cooldowns[name] = self.cooldowns_define[name]
    end

    return is_success
end

function GaleFluteBuffed:DelightPlants(radius)
    radius = radius or 20

    local delighted_plants = GaleCommon.AoeForEach(self.inst,
                                                   self.inst:GetPosition(),
                                                   radius,
                                                   { "farm_plant" },
                                                   { "INLIMBO" },
                                                   nil,
                                                   function(owner, plant)
                                                       if plant.components.farmplanttendable ~= nil then
                                                           plant.components.farmplanttendable:TendTo(owner)
                                                       end
                                                   end)

    return delighted_plants
end

function GaleFluteBuffed:OnUpdate(dt)
    for k, v in pairs(self.cooldowns) do
        self.cooldowns[k] = math.max(0, self.cooldowns[k] - dt)
    end
end

return GaleFluteBuffed
