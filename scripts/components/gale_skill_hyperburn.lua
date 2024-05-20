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

function GaleSkillHyperBurn:Launch(pos)
    -- TODO: Put HyperBurn at here
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

local GaleEntity = require("util/gale_entity")

GaleEntity.CreateNormalFx({
    prefabname = "gale_skill_hyperburn_ping_fx",
    assets = {
        Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
        Asset("ANIM", "anim/deerclops_mutated.zip"),
        Asset("ANIM", "anim/deer_ice_circle.zip"),
    },

    bank = "deerclops",
    build = "deerclops_mutated",
    animover_remove = false,

    clientfn = function(inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetFinalOffset(1)

        inst.AnimState:PlayAnimation("target_fx_pre")
        inst.AnimState:PushAnimation("target_fx", true)

        inst.AnimState:SetMultColour(1, 0, 0, 1)

        local ICE_LANCE_RADIUS = 5.5
        local my_dist = 2.5
        local s = my_dist / ICE_LANCE_RADIUS

        inst.Transform:SetScale(s, s, s)
    end,

    serverfn = function(inst)
        inst.KillFX = function(inst)
            inst.AnimState:PlayAnimation("target_fx_pst")
            inst:ListenForEvent("animover", inst.Remove)
        end
    end,
})

return GaleSkillHyperBurn
