local GaleEntity = require("util/gale_entity")

local should_hide_symbols = {
    "arm_lower",
    "arm_upper",
    "arm_upper_skin",
    "cheeks",
    "face",
    "foot",
    "hair",
    "hairfront",
    "hairpigtails",
    "hair_hat",
    "hand",
    "headbase",
    "headbase_hat",
    "leg",
    "skirt",
    "SWAP_ICON",
    "tail",
    "torso",
    "torso_pelvis",
}

return GaleEntity.CreateNormalFx({
    prefabname = "gale_nail_art_slash_fx",
    assets = {
        Asset("ANIM", "anim/werewilba_actions.zip"),
        Asset("ANIM", "anim/gale_phantom_add.zip"),
        
    },

    bank = "wilson",
    build = "gale",

    clientfn = function(inst)
        inst.Transform:SetFourFaced()

        inst.AnimState:AddOverrideBuild("gale_phantom_add")

        for _,v in pairs(should_hide_symbols) do 
            inst.AnimState:HideSymbol(v)
        end

        inst.AnimState:SetAddColour(1,1,1,1)

        inst.AnimState:SetScale(1.2,1.2,1.2)
    end,

    serverfn = function(inst)
        inst.PickAnim = function (inst,id)
            local anims = {
                "atk_werewilba","atk_2_werewilba",
            }
    
            inst.AnimState:PlayAnimation(anims[id or math.random(1,#anims)])

            inst.AnimState:SetTime(10.1 * FRAMES)
        end
    end,
})

-- c_spawn("gale_nail_art_slash_fx"):PickAnim()