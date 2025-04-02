local GHOSTVISION_COLOURCUBES =
{
    -- day = "images/colour_cubes/ghost_cc.tex",
    -- dusk = "images/colour_cubes/ghost_cc.tex",
    -- night = "images/colour_cubes/ghost_cc.tex",
    -- full_moon = "images/colour_cubes/ghost_cc.tex",

    -- ruins_light_cc.tex
    -- ruins_dark_cc.tex
    -- ruins_dim_cc.tex
    day = "images/colour_cubes/ruins_light_cc.tex",
    dusk = "images/colour_cubes/ruins_light_cc.tex",
    night = "images/colour_cubes/ruins_light_cc.tex",
    full_moon = "images/colour_cubes/ruins_light_cc.tex",


}



local GaleSkillDarkVision = Class(function(self, inst)
    -- Common
    self.inst = inst
    self._enable = net_bool(inst.GUID, "GaleSkillDarkVision._enable", "GaleSkillDarkVision._enable")


    if not TheNet:IsDedicated() then
        -- Client only
        self.HUD_hover = nil

        inst:ListenForEvent("GaleSkillDarkVision._enable", function()
            if not (ThePlayer and ThePlayer == self.inst) then
                return
            end

            if self:IsEnabled() then
                inst.components.playervision:PushForcedNightVision(self.inst, -10, GHOSTVISION_COLOURCUBES)
            else
                inst.components.playervision:PopForcedNightVision(self.inst)
            end
        end)
    end

    if TheNet:GetIsMasterSimulation() then
        -- Server only

        self._client_disable = function()
            if self:IsEnabled() then
                SendModRPCToClient(CLIENT_MOD_RPC["gale_rpc"]["dark_vision_server2sui"], self.inst.userid)
            end
        end

        self._check_magic_enough = function()
            if self.inst.components.gale_magic:GetPercent() <= 0 then
                self._client_disable()
            end
        end

        self._check_magic_enable = function()
            if not self.inst.components.gale_magic:IsEnable() then
                self._client_disable()
            end
        end
    end
end)

-- ThePlayer.components.gale_skill_dark_vision:Enable(true)
function GaleSkillDarkVision:Enable(enable)
    if enable == nil then
        enable = false
    end

    self._enable:set(enable)
    if enable then
        self.inst.components.playervision:PushForcedNightVision(self.inst, -10, GHOSTVISION_COLOURCUBES)
    else
        self.inst.components.playervision:PopForcedNightVision(self.inst)
    end

    local DARK_VISION_GRUEIMMUNITY_NAME = "gale_dark_vision_nightvision"
    if enable then
        self.inst:AddTag("crazy")
        self.inst.components.grue:AddImmunity(DARK_VISION_GRUEIMMUNITY_NAME)
        self.inst.components.gale_magic:AddDeltaTask("gale_skill_dark_vision", -0.2)

        self.inst:ListenForEvent("death", self._client_disable)
        self.inst:ListenForEvent("onremove", self._client_disable)
        self.inst:ListenForEvent("playerdeactivated", self._client_disable)
        self.inst:ListenForEvent("gale_magic_delta", self._check_magic_enough)
        self.inst:ListenForEvent("gale_magic_enable", self._check_magic_enable)
    else
        self.inst:RemoveTag("crazy")
        self.inst.components.grue:RemoveImmunity(DARK_VISION_GRUEIMMUNITY_NAME)
        self.inst.components.gale_magic:CancelDeltaTask("gale_skill_dark_vision")

        self.inst:RemoveEventCallback("death", self._client_disable)
        self.inst:RemoveEventCallback("onremove", self._client_disable)
        self.inst:RemoveEventCallback("playerdeactivated", self._client_disable)
        self.inst:RemoveEventCallback("gale_magic_delta", self._check_magic_enough)
        self.inst:RemoveEventCallback("gale_magic_enable", self._check_magic_enable)
    end
end

function GaleSkillDarkVision:IsEnabled()
    return self._enable:value()
end

return GaleSkillDarkVision
