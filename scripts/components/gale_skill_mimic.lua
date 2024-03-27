local GaleCommon = require("util/gale_common")

local GaleSkillMimic = Class(function(self, inst)
    self.inst = inst
    self.mimic = nil


    self._on_player_invalid = function()
        if self:IsMimic() then
            self:Stop()
        end
    end

    self._on_mimic_invalid = function()
        if self:IsMimic() then
            self:Stop()
        end
    end

    self._check_magic_enough = function()
        if self:IsMimic() and self.inst.components.gale_magic:GetPercent() <= 0 then
            self:StopWithSG()
        end
    end

    self._check_magic_enable = function()
        if self:IsMimic() and not self.inst.components.gale_magic:IsEnable() then
            self:StopWithSG()
        end
    end

    self.mimic_target = {
        default = {
            bank = "trinkets",
            build = "trinkets",
            anim = "14",
        },

        eyeturret = {
            fn = function(self, target)
                self.mimic = SpawnAt("gale_skill_mimic_eyeturret", self.inst)

                if target and target.prefab then
                    self.mimic.nameoverride = target.prefab
                    self.mimic._mimic_nameoverride:set(target.prefab)
                end

                self.mimic.owner = inst
            end
        },
    }
end)

function GaleSkillMimic:IsValidTarget(target, level)
    if not (target and target:IsValid()) then
        return false,
            string.format(STRINGS.GALE_SKILL_CAST.FAILED.NO_TARGET_ITEM, STRINGS.GALE_UI.SKILL_NODES.MIMIC_LV1.NAME)
    end

    if level == nil then
        if self.inst.components.gale_skiller == nil then
            level = 0
        elseif self.inst.components.gale_skiller:IsLearned("mimic_lv3") then
            level = 3
        elseif self.inst.components.gale_skiller:IsLearned("mimic_lv2") then
            level = 2
        elseif self.inst.components.gale_skiller:IsLearned("mimic_lv1") then
            level = 1
        else
            level = 0
        end
    end


    local is_inv = target.components.inventoryitem
    local is_eyeturret = target.prefab == "eyeturret"

    if level == 1 then
        -- and not is_eyeturret is debug test
        if not is_inv then
            return false,
                string.format(STRINGS.GALE_SKILL_CAST.FAILED.NO_TARGET_ITEM, STRINGS.GALE_UI.SKILL_NODES.MIMIC_LV1.NAME)
        else
            return true
        end
    end

    if level == 2 then
        if not is_inv and not is_eyeturret then
            return false,
                string.format(STRINGS.GALE_SKILL_CAST.FAILED.INVALID_TARGET, STRINGS.GALE_UI.SKILL_NODES.MIMIC_LV1.NAME)
        else
            return true
        end
    end

    return false, string.format(STRINGS.GALE_SKILL_CAST.FAILED.INVALID_TARGET, STRINGS.GALE_UI.SKILL_NODES.MIMIC_LV1
        .NAME)
end

function GaleSkillMimic:Start(target)
    local source = target and self.mimic_target[target.prefab]
    if self.mimic ~= nil then
        self:Stop()
    end

    if source and source.fn then
        source.fn(self, target)
    else
        self.mimic = SpawnAt("gale_skill_mimic_target", self.inst)
        -- self.mimic.name = target and target.name or "???"

        if target and target.prefab then
            self.mimic.nameoverride = target.prefab
            self.mimic._mimic_nameoverride:set(target.prefab)
        end



        local set_bank, set_build, set_anim

        -- If have skin,mimic to default
        local skin_build = target.AnimState:GetSkinBuild()
        if skin_build ~= nil and #skin_build > 0 then
            set_bank = self.mimic_target.default.bank
            set_build = self.mimic_target.default.build
            set_anim = self.mimic_target.default.anim
        else
            if source ~= nil then
                set_bank = source.bank
                set_build = source.build
                set_anim = source.anim

                -- print("Find source Mimic data:",set_bank,set_build,set_anim)
            else
                local anim_data = GaleCommon.GetAnim(target)
                if string.find(anim_data.bank, "[A-Z]") or string.find(anim_data.build, "[A-Z]") or string.find(anim_data.anim, "[A-Z]") then
                    set_bank = self.mimic_target.default.bank
                    set_build = self.mimic_target.default.build
                    set_anim = self.mimic_target.default.anim
                else
                    set_bank = anim_data.bank
                    set_build = anim_data.build
                    set_anim = anim_data.anim
                end
            end

            -- Foods use override symbol to display anim
            if target:HasTag("preparedfood") then
                local swap_a, swap_b = target.AnimState:GetSymbolOverride("swap_food")
                self.mimic.AnimState:OverrideSymbol("swap_food", swap_a, swap_b)

                if target:HasTag("spicedfood") then
                    local swap_a, swap_b = target.AnimState:GetSymbolOverride("swap_garnish")
                    self.mimic.AnimState:OverrideSymbol("swap_garnish", swap_a, swap_b)
                end
            end

            local s1, s2, s3 = target.Transform:GetScale()
            self.mimic.Transform:SetScale(s1, s2, s3)
        end

        self.mimic.AnimState:SetBank(set_bank)
        self.mimic.AnimState:SetBuild(set_build)
        self.mimic.AnimState:PlayAnimation(set_anim)
        self.mimic.idle_anim = set_anim
        self.mimic.walk_anim = set_anim
        self.mimic.run_anim = set_anim
    end




    self.inst:Hide()
    self.follow_task = self.inst:DoPeriodicTask(0, function()
        self.inst.Transform:SetPosition(self.mimic.Transform:GetWorldPosition())
    end)
    -- local delta_time = 0
    -- self.drain_magic_task = self.inst:DoPeriodicTask(delta_time,function()
    --     local consume_magic = (delta_time + FRAMES) * (
    --         (self.mimic:HasTag("moving") or self.mimic:HasTag("busy")) and 5
    --         or 1)
    --     if not (self.inst.components.gale_magic and self.inst.components.gale_magic:CanUseMagic(consume_magic)) then
    --         self:StopWithSG()
    --     else
    --         self.inst.components.gale_magic:DoDelta(-consume_magic)
    --     end
    -- end)
    self.inst.components.gale_magic:AddDeltaTask("gale_skill_mimic", function()
        return (self.mimic:HasTag("moving") or self.mimic:HasTag("busy")) and -1 or -0.1
    end)

    self.mimic.components.combat.redirectdamagefn = function()
        return self.inst
    end

    if self.inst:HasTag("player") then
        self.inst.components.playercontroller.locomotor = self.mimic.components.locomotor
    end

    self.inst:ListenForEvent("death", self._on_player_invalid)
    self.inst:ListenForEvent("onremove", self._on_player_invalid)
    self.inst:ListenForEvent("gale_magic_delta", self._check_magic_enough)
    self.inst:ListenForEvent("gale_magic_enable", self._check_magic_enable)
    self.mimic:ListenForEvent("death", self._on_mimic_invalid)
    self.mimic:ListenForEvent("onremove", self._on_mimic_invalid)

    if self.inst:HasTag("player") then
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["enable_movement_prediction"], self.inst.userid, false)
    end
end

function GaleSkillMimic:StopWithSG()
    self:Stop()
    self.inst.sg:GoToState("gale_mimicing_pst")
    SpawnAt("statue_transition_2", self.inst)
end

function GaleSkillMimic:Stop()
    -- print("trigger GaleSkillMimic:Stop(),self.mimic =",self.mimic)
    self.inst:Show()
    if self.follow_task then
        self.follow_task:Cancel()
        self.follow_task = nil
    end

    -- if self.drain_magic_task then
    --     self.drain_magic_task:Cancel()
    --     self.drain_magic_task = nil
    -- end
    self.inst.components.gale_magic:CancelDeltaTask("gale_skill_mimic")

    if self.inst:HasTag("player") then
        self.inst.components.playercontroller.locomotor = self.inst.components.locomotor
    end

    self.inst:RemoveEventCallback("death", self._on_player_invalid)
    self.inst:RemoveEventCallback("onremove", self._on_player_invalid)
    self.inst:RemoveEventCallback("gale_magic_delta", self._check_magic_enough)
    self.inst:RemoveEventCallback("gale_magic_enable", self._check_magic_enable)
    self.mimic:RemoveEventCallback("death", self._on_mimic_invalid)
    self.mimic:RemoveEventCallback("onremove", self._on_mimic_invalid)

    if self.mimic and self.mimic:IsValid() then
        self.mimic:Remove()
    end
    self.mimic = nil

    if self.inst:HasTag("player") then
        SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["enable_movement_prediction"], self.inst.userid, true)
    end
end

function GaleSkillMimic:IsMimic()
    return self.mimic and self.mimic:IsValid()
end

return GaleSkillMimic
