local function onanim_index(self, anim_index)
    self.inst.replica.gale_skill_electric_punch:SetAnimIndex(anim_index)
end

local function onenable(self, enable)
    self.inst.replica.gale_skill_electric_punch:SetEnabled(enable)
end

local PUNCH_RANGE_BASE = 2

local GaleSkillElectricPunch = Class(
    function(self, inst)
        self.inst               = inst
        self.enable             = false
        self.anim_index         = 0
        self.vfxs               = {}

        self._on_perform_action = function(_, data)
            if not self:IsEnabled() then
                return
            end

            local buffered_action = data.action
            local action = buffered_action.action

            if action == ACTIONS.ATTACK
                or action == ACTIONS.CHOP
                or action == ACTIONS.MINE
                or action == ACTIONS.HAMMER then
                self:PickAnimIndex()
            end
        end

        self._on_hit_other      = function(_, data)
            if self:IsEnabled() and data.weapon == self:GetWeapon() then
                -- if inst.components.hunger then
                --     inst.components.hunger:DoDelta(1, true)
                -- end
                if inst.components.gale_magic then
                    inst.components.gale_magic:DoDelta(-0.5)
                end
            end
        end

        self._check_gale_magic  = function()
            if self:IsEnabled() and
                (inst.components.gale_magic:GetPercent() <= 0
                    or not inst.components.gale_magic:IsEnable()) then
                self:SetEnabled(false)
            end
        end

        self._on_equip_change   = function()
            if self:IsEnabled() then
                self:PickAnimIndex()
            end
        end

        self._check_player_dead = function()
            if self:IsEnabled() and (IsEntityDead(inst, true) or (inst.sg and inst.sg:HasStateTag("dead"))) then
                self:SetEnabled(false)
            end
        end

        inst:ListenForEvent("performaction", self._on_perform_action)
        inst:ListenForEvent("onhitother", self._on_hit_other)
        inst:ListenForEvent("gale_magic_delta", self._check_gale_magic)
        inst:ListenForEvent("gale_magic_enable", self._check_gale_magic)
        inst:ListenForEvent("equip", self._on_equip_change)
        inst:ListenForEvent("unequip", self._on_equip_change)
        inst:ListenForEvent("death", self._check_player_dead)
    end, nil, {
        anim_index = onanim_index,
        enable = onenable,
    })

-- inst:AddComponent("gale_skill_electric_punch")
-- inst.components.gale_skill_electric_punch:CreateWeapon()

function GaleSkillElectricPunch:IsEnabled()
    return self.enable
end

function GaleSkillElectricPunch:RemoveFXS()
    for k, v in pairs(self.vfxs) do
        if v and v:IsValid() then
            -- v:Remove()
            v.perish = true
        end
    end

    self.vfxs = {}
end

function GaleSkillElectricPunch:SpawnFXS()
    -- local swap_object_hand_indexs = { 1, 4 }
    -- for i = 0, 19 do
    --     if not table.contains(swap_object_hand_indexs, i) then
    --         -- local vfx = self.inst:SpawnChild("gale_skill_electric_punch_vfx")
    --         -- vfx.entity:AddFollower()
    --         -- vfx.Follower:FollowSymbol(self.inst.GUID, "hand", 0, 0, 0, nil, nil, i, nil, 2)

    --         -- table.insert(self.vfxs, vfx)

    --         local s = 0.2
    --         local fx = self.inst:SpawnChild("cracklehitfx")
    --         fx.entity:AddFollower()
    --         fx.Follower:FollowSymbol(self.inst.GUID, "hand", nil, nil, nil, true, true, i)

    --         fx.AnimState:SetScale(s, s, s)
    --         fx.Transform:SetScale(s, s, s)
    --         fx.persists = false

    --         fx.AnimState:PlayAnimation("crackle_loop")
    --         -- fx.AnimState:SetTime((i - 1) * fx.AnimState:GetCurrentAnimationLength() / fx_num)
    --         -- fx.AnimState:SetAddColour(0 / 255, 0 / 255, 255 / 255, 1)

    --         fx:ListenForEvent("animover", function()
    --             if fx.perish then
    --                 fx:Remove()
    --             else
    --                 fx.AnimState:PlayAnimation("crackle_loop")
    --             end
    --         end)

    --         table.insert(self.vfxs, fx)
    --     end
    -- end

    -- local vfx = self.inst:SpawnChild("gale_skill_electric_punch_vfx")
    -- vfx.entity:AddFollower()
    -- vfx.Follower:FollowSymbol(self.inst.GUID, "torso", 0, -30, 0)

    -- vfx.Transform:SetPosition(0, 0.5, 0)

    -- table.insert(self.vfxs, vfx)

    -- SpawnPrefab("electricchargedfx"):SetTarget(self.inst)
end

function GaleSkillElectricPunch:SetEnabled(enable)
    self.enable = enable
    self:PickAnimIndex()

    if enable then
        self:RemoveFXS()
        self:SpawnFXS()

        SpawnPrefab("electricchargedfx"):SetTarget(self.inst)
        -- SpawnAt("gale_electricchargedfx", self.inst)
        -- local fx = self.inst:SpawnChild("gale_electricchargedfx")
        -- fx.AnimState:SetMultColour(0.3, 0.3, 0.3, 1)
        -- fx.AnimState:SetAddColour(1, 1, 0, 1)

        -- SpawnPrefab("gale_hit_color_adder_yellow"):SetTarget(self.inst)

        self.inst.SoundEmitter:PlaySound("gale_sfx/skill/elec_start")

        -- self.inst.AnimState:SetSymbolLightOverride("hand", 1)
        -- self.inst.AnimState:SetSymbolAddColour("hand", 1, 1, 0, 1)
    else
        self:RemoveFXS()

        SpawnAt("gale_sparks", self.inst)
        self.inst.SoundEmitter:PlaySound("gale_sfx/skill/elec_stop2")

        -- self.inst.AnimState:SetSymbolLightOverride("hand", 0)
        -- self.inst.AnimState:SetSymbolAddColour("hand", 0, 0, 0, 0)
    end
end

function GaleSkillElectricPunch:CreateWeapon()
    if self.punch_weapon and self.punch_weapon:IsValid() then
        return self.punch_weapon
    end

    self.punch_weapon = CreateEntity()

    --[[Non-networked entity]]
    self.punch_weapon.entity:AddTransform()

    self.punch_weapon.persists = false

    self.punch_weapon:AddTag("NOCLICK")
    self.punch_weapon:AddTag("NOBLOCK")

    self.punch_weapon:AddComponent("weapon")
    self.punch_weapon.components.weapon:SetDamage(34)
    self.punch_weapon.components.weapon:SetRange(0)
    self.punch_weapon.components.weapon:SetElectric(1, 2)
    self.punch_weapon.components.weapon:SetOnAttack(function(wp, attacker, target)
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)
    end)

    self.punch_weapon:AddComponent("planardamage")
    self.punch_weapon.components.planardamage:SetBaseDamage(17)

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

function GaleSkillElectricPunch:CanWork(target)
    local range = target:GetPhysicsRadius(0) + PUNCH_RANGE_BASE

    return self:IsEnabled() and distsq(target:GetPosition(), self.inst:GetPosition()) <= range * range
end

function GaleSkillElectricPunch:CanPunch(target)
    if not (target and target:IsValid()) then
        return false
    end

    local range = target:GetPhysicsRadius(0) + PUNCH_RANGE_BASE

    return self:IsEnabled() and self:GetAnimIndex() > 0 and self:GetAnimIndex() < 3
        and distsq(target:GetPosition(), self.inst:GetPosition()) <= range * range
end

function GaleSkillElectricPunch:OnSave()
    local data = {
        enable = self.enable
    }

    return data
end

function GaleSkillElectricPunch:OnLoad(data)
    if data ~= nil then
        if data.enable ~= nil then
            self:SetEnabled(data.enable)
        end
    end
end

function GaleSkillElectricPunch:GetDebugString()
    return string.format("Enable: %s, Anim index: %d", tostring(self.enable), self.anim_index)
end

return GaleSkillElectricPunch
