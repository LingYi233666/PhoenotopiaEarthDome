local GaleCommon = require("util/gale_common")

local GaleSkillHyperBurn = Class(function(self, inst)
    self.inst = inst
    self.data_list = {}
    self.period = 8 * FRAMES
    self.task = nil
end)

function GaleSkillHyperBurn:ClearList()
    for _, data in pairs(self.data_list) do
        if data.fx and data.fx:IsValid() then
            data.fx:KillFX()
        end
    end
    self.data_list = {}
end

function GaleSkillHyperBurn:AddPos(pos)
    table.insert(self.data_list, {
        pos = pos,
        fx = self:SpawnFX(pos),
    })
end

function GaleSkillHyperBurn:SpawnFX(pos)
    return SpawnAt("gale_skill_hyperburn_ping_fx", pos)
end

function GaleSkillHyperBurn:GetListSize()
    return #self.data_list
end

function GaleSkillHyperBurn:Launch(end_pos)
    local start_pos = self.inst:GetPosition() + Vector3(0, 1, 0)
    local towards = end_pos - start_pos
    local towards_norm = towards:GetNormalized()
    local towards_len = towards:Length()

    local step = 3
    local indexs = {}
    if towards_len <= 1 then
        indexs = { 1, }
    else
        for i = 1, towards_len, step do
            table.insert(indexs, i)
        end
    end
    for _, i in pairs(indexs) do
        local cur_pos = start_pos + towards_norm * i
        local segment = SpawnAt("gale_skill_hyperburn_line_fx", cur_pos)
        segment.vfx:DoEmit(towards_norm * 0.8)
        if cur_pos.y < 0.5 then
            segment.vfx:EnableDepth(true)
        end
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local onocean = TheWorld.Map:IsOceanAtPoint(x, y, z)
    local attack_dist = onocean and 2 or 3
    local fire_damage_multi = onocean and 0.25 or 1

    GaleCommon.AoeForEach(self.inst, end_pos, attack_dist, nil, { "INLIMBO", "FX" }, nil,
        function(attacker, target)
            if target.components.combat and target.components.health then
                if attacker.components.combat:CanTarget(target) and
                    not attacker.components.combat:IsAlly(target) then
                    if target.components.burnable then
                        target.components.burnable:Ignite(true, nil, attacker)
                    end

                    if not target.components.health:IsDead() then
                        target.components.combat:GetAttacked(attacker, GetRandomMinMax(16, 20), nil,
                            "electric")
                    end

                    if not target.components.health:IsDead() then
                        target.components.health:DoFireDamage(fire_damage_multi * GetRandomMinMax(16, 20), attacker,
                            true)
                    end
                end
            elseif target.components.burnable then
                if target:HasTag("campfire") and target.components.fueled then
                    target.components.fueled:DoDelta(GetRandomMinMax(40, 80))
                else
                    target.components.burnable:Ignite(true, nil, attacker)
                end
            end
        end,
        function(attacker, target)
            return (target.components.combat and target.components.health)
                or target.components.burnable
        end
    )


    if onocean then
        local splashfx = SpawnAt("crab_king_waterspout", end_pos)
        splashfx.Transform:SetScale(1, 0.7, 0.7)
    else
        local groundfx = SpawnAt("gale_skill_hyperburn_burntground", end_pos, { 1.2, 1.2, 1.2 })
        local explofx = SpawnAt("gale_skill_hyperburn_explo_fx", end_pos)
        local explofx2 = SpawnAt("gale_bomb_projectile_explode", end_pos)

        explofx2.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
        -- explofx2.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
        -- explofx2.SoundEmitter:PlaySound("gale_sfx/battle/explode")
        -- explofx2.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/explode")
        -- explofx2.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
    end

    self.inst.SoundEmitter:PlaySound("gale_sfx/battle/active_grenade_fire")
    -- self.inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    -- self.inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    ShakeAllCameras(CAMERASHAKE.FULL, .35, .015, 0.8, end_pos, 33)
end

function GaleSkillHyperBurn:PopList()
    return table.remove(self.data_list, 1)
end

function GaleSkillHyperBurn:PopAndLaunch()
    local data = self:PopList()
    if data.fx and data.fx:IsValid() then
        data.fx:KillFX()
    end
    self:Launch(data.pos)
end

function GaleSkillHyperBurn:StartPeriodicLaunch()
    self:StopPeriodicLaunch()

    self.task = self.inst:DoPeriodicTask(self.period, function()
        if self:GetListSize() > 0 then
            self:PopAndLaunch()
        end

        if self:GetListSize() <= 0 then
            self:StopPeriodicLaunch()
        end
    end)
end

function GaleSkillHyperBurn:StopPeriodicLaunch()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function GaleSkillHyperBurn:GetTimeRemain()
    return self.period * self:GetListSize()
end

return GaleSkillHyperBurn
