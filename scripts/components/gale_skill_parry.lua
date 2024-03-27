local GaleCommon = require("util/gale_common")

local GOOD_PARRY_TIME_THRESHOLD = 0.33

local function DefaultParrtTestFnWrapper(deg)
    local function TestFn(player, attacker, damage, weapon, stimuli)
        local weapon = player.components.combat:GetWeapon()
        local tar_deg = GaleCommon.GetFaceAngle(player, attacker)


        return (player.sg
            and player.sg:HasStateTag("parrying")
            and -deg / 2 <= tar_deg
            and tar_deg <= deg / 2
            and player.components.gale_stamina
            and player.components.gale_stamina.current >= damage / 2) and weapon
    end

    return TestFn
end

local function onparry_start_time(self, val)
    self.inst.replica.gale_skill_parry:SetIsParrying(val ~= nil)
end

local GaleSkillParry = Class(function(self, inst)
                                 self.inst = inst


                                 self.parry_start_time = nil
                                 self.parry_history = {}

                                 self.parrytestfn = DefaultParrtTestFnWrapper(120)
                                 self.parrycallback = nil

                                 ----------------------------------------------------------------------------------

                                 self._on_attacked = function(inst, data)
                                     local damage = data.damage
                                     local redirected = data.redirected
                                     local attacker = data.attacker

                                     if redirected then
                                         if GetTime() - self.parry_start_time <= GOOD_PARRY_TIME_THRESHOLD then
                                             inst.SoundEmitter:PlaySound(
                                                 "dontstarve/creatures/lava_arena/trails/hide_pre", nil, 0.5)
                                             inst:SpawnChild("gale_greatparry_vfx").Transform:SetPosition(0.5, 0, 0)
                                         else
                                             if inst.components.gale_stamina then
                                                 inst.components.gale_stamina:DoDelta(-damage / 2)
                                                 inst.components.gale_stamina:Pause(1)
                                             end
                                         end

                                         table.insert(self.parry_history, MergeMaps(data, { time = GetTime() }))

                                         if self.parrycallback then
                                             self.parrycallback(self.inst, attacker, damage)
                                         end
                                     end
                                 end

                                 self._not_parry_state = function()
                                     if not (inst.sg:HasStateTag("preparrying") or inst.sg:HasStateTag("parrying")) then
                                         self:StopParry()
                                     end
                                 end

                                 self._force_stop = function()
                                     self:StopParry()
                                 end
                             end, nil, {
                                 parry_start_time = onparry_start_time
                             })

function GaleSkillParry:IsParrying()
    return self.parry_start_time ~= nil
end

function GaleSkillParry:TryParry(attacker, damage, weapon, stimuli)
    return self.parrytestfn ~= nil and self.parrytestfn(self.inst, attacker, damage, weapon, stimuli)
end

function GaleSkillParry:StartParry()
    if self:IsParrying() then
        return
    end

    self.parry_start_time = GetTime()
    self.rotate_task = self.inst:DoPeriodicTask(0, function()
        self.inst:ForceFacePoint(self.inst.components.gale_control_key_helper:GetMousePosition())
    end)
    self.inst.sg:GoToState("gale_parry_pre")
    self.inst:ListenForEvent("attacked", self._on_attacked)
    -- self.inst:ListenForEvent("death",self._force_stop)
    self.inst:ListenForEvent("newstate", self._not_parry_state)
end

function GaleSkillParry:StopParry()
    if not self:IsParrying() then
        return
    end

    if self.rotate_task then
        self.rotate_task:Cancel()
        self.rotate_task = nil
    end

    if self.inst.sg:HasStateTag("parrying") then
        local counter_target = nil
        for i = #self.parry_history, 1, -1 do
            local parrydata = self.parry_history[i]
            if parrydata.time - self.parry_start_time <= GOOD_PARRY_TIME_THRESHOLD
                and self.inst.components.combat:CanTarget(parrydata.attacker) then
                counter_target = parrydata.attacker
            end
        end


        if counter_target and counter_target:IsNear(self.inst, self.inst.components.combat:GetAttackRange() + 1.3) then
            self.inst.sg:GoToState("gale_parry_counter_near", { target = counter_target })
        else
            self.inst.AnimState:PlayAnimation("parry_pst")
            self.inst.sg:GoToState("idle", true)
        end
    end
    self.inst:RemoveEventCallback("attacked", self._on_attacked)
    -- self.inst:RemoveEventCallback("death",self._force_stop)
    self.inst:RemoveEventCallback("newstate", self._not_parry_state)

    self.parry_history = {}
    self.parry_start_time = nil
end

return GaleSkillParry
