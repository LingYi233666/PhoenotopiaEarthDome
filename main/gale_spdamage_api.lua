local SpDamageUtil = require("components/spdamageutil")


-- ThePlayer.components.combat:GetAttacked(ThePlayer, 0, nil, nil, {planar = 5,gale_mental=1})
-- 心灵伤害
-- TODO: Finish gale_mental_damage_handler component
SpDamageUtil.DefineSpType("gale_mental", {
    GetDamage = function(ent)
        return ent.components.gale_mental_damage_handler ~= nil and ent.components.gale_mental_damage_handler:GetDamage() or
            0
    end,
    GetDefense = function(ent)
        local basedef = 0
        if ent.brain == nil and not ent:HasTag("player") then
            basedef = basedef + 10
        end
        return (ent.components.gale_mental_damage_handler ~= nil and
            ent.components.gale_mental_damage_handler:GetDefense() or 0) + basedef
    end,
})
