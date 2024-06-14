local SpDamageUtil = require("components/spdamageutil")

local function IsMindless(ent)
    if ent:HasTag("player") then
        return false
    end

    return ent.brain == nil or ent:HasTag("soulless") or
        ent:HasTag("chess") or ent:HasTag("mech")
end
-- ThePlayer.components.combat:GetAttacked(ThePlayer, 0, nil, nil, {planar = 5,gale_psychic=1})
SpDamageUtil.DefineSpType("gale_psychic", {
    GetDamage = function(ent)
        return ent.components.gale_spdamage_psychic ~= nil and ent.components.gale_spdamage_psychic:GetDamage() or
            0
    end,
    GetDefense = function(ent)
        local basedef = 0
        if IsMindless(ent) then
            basedef = basedef + 51
        end

        return (ent.components.gale_spdefense_psychic ~= nil and
            ent.components.gale_spdefense_psychic:GetDefense() or 0) + basedef
    end,
})
