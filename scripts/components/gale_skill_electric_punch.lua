local function onanim_index(self, anim_index)
    self.inst.replica.gale_skill_electric_punch:SetAnimIndex(anim_index)
end

local GaleSkillElectricPunch = Class(function(self, inst)
                                         self.inst = inst
                                         self.enable = false
                                         self.anim_index = 0

                                         inst:ListenForEvent("performaction", function(_, data)
                                             if not self.enable then
                                                 return
                                             end

                                             local buffered_action = data.action
                                             local action = buffered_action.action

                                             if action == ACTIONS.ATTACK then
                                                 self:PickAnimIndex()
                                             end
                                         end)
                                     end, nil, {
                                         anim_index = onanim_index,
                                     })

-- inst:AddComponent("gale_skill_electric_punch")
-- inst.components.gale_skill_electric_punch:CreateWeapon()

function GaleSkillElectricPunch:IsEnabled()
    return self.enable
end

function GaleSkillElectricPunch:SetEnabled(enable)
    self.enable = enable
    self:PickAnimIndex()
end

function GaleSkillElectricPunch:CreateWeapon()
    if self.punch_weapon and self.punch_weapon:IsValid() then
        return self.punch_weapon
    end

    self.punch_weapon = CreateEntity()

    --[[Non-networked entity]]
    self.punch_weapon.entity:AddTransform()

    self.punch_weapon.persists = false

    self.punch_weapon:AddComponent("weapon")
    self.punch_weapon.components.weapon:SetDamage(34)
    self.punch_weapon.components.weapon:SetRange(0)
    self.punch_weapon.components.weapon:SetElectric(1, 1.5)
    self.punch_weapon.components.weapon:SetOnAttack(function(wp, attacker, target)
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)
    end)

    self.punch_weapon:AddComponent("planardamage")
    self.punch_weapon.components.planardamage:SetBaseDamage(34)

    self.inst:AddChild(self.punch_weapon)

    return self.punch_weapon
end

function GaleSkillElectricPunch:GetWeapon()
    return self.punch_weapon
end

function GaleSkillElectricPunch:PickAnimIndex()
    if not self.enable then
        self.anim_index = 0
        return
    end

    local item = self.inst.components.inventory and self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if item then
        -- if self.anim_index == 0 then
        --     self.anim_index = math.random(2)
        -- elseif self.anim_index == 1 then
        --     self.anim_index = 2
        -- else
        --     self.anim_index = 1
        -- end
        if self.anim_index == 0 then
            self.anim_index = 1
        else
            self.anim_index = 0
        end
    else
        if self.anim_index == 0 then
            self.anim_index = math.random(2)
        elseif self.anim_index == 1 then
            self.anim_index = 2
        else
            self.anim_index = 1
        end
    end
end

function GaleSkillElectricPunch:GetAnimIndex()
    return self.anim_index
end

function GaleSkillElectricPunch:CanPunch(target)
    local range = target:GetPhysicsRadius(0) + self.inst.components.combat.attackrange

    return self:IsEnabled() and self:GetAnimIndex() > 0 and self:GetAnimIndex() < 3
        and distsq(target:GetPosition(), self.inst:GetPosition()) <= range * range
end

function GaleSkillElectricPunch:GetDebugString()
    return string.format("Enable: %s, Anim index: %d", tostring(self.enable), self.anim_index)
end

return GaleSkillElectricPunch
