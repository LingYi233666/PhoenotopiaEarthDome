local GaleCommon = require("util/gale_common")

require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),
}

local states = {

}

CommonStates.AddIdle(states)
CommonStates.AddRunStates(states)
CommonStates.AddCombatStates(states)

return StateGraph("SGgale_skill_mimic_target", states, events, "idle")