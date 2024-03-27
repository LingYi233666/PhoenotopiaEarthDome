local GaleCommon = require("util/gale_common")

require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/doaction"

local AthetosPortableTurret = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function SelectTarget(inst)
    if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("attack") or IsEntityDead(inst) then
        return
    end

    local scan_target, attack_target, other_turrets = inst:SelectTarget()
    if attack_target then
        inst:DoTalkSound("attack")
        if GaleCommon.IsTyphonTarget(attack_target) then
            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.COMBAT.TYPHON_3))
        else
            inst.components.talker:Say(GetRandomItem(STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET.COMBAT.THREAT))
        end

        -- for _, fn in pairs(inst.scaned_targets) do
        --     fn:Cancel()
        -- end
        -- inst.scaned_targets = {}


        inst.sg:GoToState("attack", attack_target)
    elseif not inst.sg:HasStateTag("scan_target") and not inst.sg:HasStateTag("sing") and scan_target then
        inst.scaned_targets[scan_target] = inst:DoPeriodicTask(1, function()
            if not scan_target:IsValid()
                or IsEntityDeadOrGhost(scan_target, true)
                or not inst:IsNear(scan_target, inst.components.combat.hitrange + 10) then
                inst.scaned_targets[scan_target]:Cancel()
                inst.scaned_targets[scan_target] = nil
            end
        end)
        inst.sg:GoToState("idle_scan_target", {
            target = scan_target,
        })
    elseif not inst.sg:HasStateTag("sing")
        and attack_target == nil
        and scan_target == nil
        and #other_turrets == 0
        and TheWorld.state.isnight
        and not inst.components.timer:TimerExists("sing_cooldown")
        and FindClosestPlayerToInst(inst, 10, true) ~= nil
    then
        if GetTime() - (inst.last_check_sing_time or 0) > 10 then
            -- print("Checking sing....")
            inst.last_check_sing_time = GetTime()

            if math.random() < 0.001 then
                -- print("Good start sing !")
                inst.components.timer:StartTimer("sing_cooldown", 3600)

                -- Song name: Turret Wife Serenade
                -- Creater: Saint Kitten
                -- Link: http://music.163.com/song?id=1442172986&userid=403163769
                -- Special thanks to Portal 2
                inst.sg:GoToState("sing")
            end
        end
    end
end

function AthetosPortableTurret:OnStart()
    local root = PriorityNode(
        {
            ActionNode(function()
                SelectTarget(self.inst)
            end)
        }, .25)

    self.bt = BT(self.inst, root)
end

return AthetosPortableTurret
