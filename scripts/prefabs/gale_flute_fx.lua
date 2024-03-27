-- local GaleCommon = require("util/gale_common")
-- local GaleEntity = require("util/gale_entity")

-- local assets = {
--     Asset("ANIM", "anim/gale_flute_fx.zip"),
-- }

-- local function CommonClientFn(inst)
--     MakeInventoryPhysics(inst)
--     RemovePhysicsColliders(inst)
-- end

-- local function CommonServerFn(inst)
--     inst.PopIn = function(inst)
--         inst.Physics:SetMotorVel(0,4,0)
--         GaleCommon.FadeTo(inst,FRAMES * 5,{Vector3(0.2,0.2,0.2),Vector3(1,1,1)})
--     end
-- end

-- return GaleEntity.CreateNormalFx({
--     assets = assets,
--     prefabname = "gale_flute_fx_shang",

--     bank = "gale_flute_fx",
--     build = "gale_flute_fx",
--     anim = "gale_flute_fx_shang",

--     animover_remove = false,
--     clientfn = CommonClientFn,
--     serverfn = CommonServerFn,
-- }),GaleEntity.CreateNormalFx({
--     assets = assets,
--     prefabname = "gale_flute_fx_you",

--     bank = "gale_flute_fx",
--     build = "gale_flute_fx",
--     anim = "gale_flute_fx_you",

--     animover_remove = false,
--     clientfn = CommonClientFn,
--     serverfn = CommonServerFn,
-- }),GaleEntity.CreateNormalFx({
--     assets = assets,
--     prefabname = "gale_flute_fx_mid",

--     bank = "gale_flute_fx",
--     build = "gale_flute_fx",
--     anim = "gale_flute_fx_mid",

--     animover_remove = false,
--     clientfn = CommonClientFn,
--     serverfn = CommonServerFn,
-- }),GaleEntity.CreateNormalFx({
--     assets = assets,
--     prefabname = "gale_flute_fx_zuo",

--     bank = "gale_flute_fx",
--     build = "gale_flute_fx",
--     anim = "gale_flute_fx_zuo",

--     animover_remove = false,
--     clientfn = CommonClientFn,
--     serverfn = CommonServerFn,
-- }),GaleEntity.CreateNormalFx({
--     assets = assets,
--     prefabname = "gale_flute_fx_xia",

--     bank = "gale_flute_fx",
--     build = "gale_flute_fx",
--     anim = "gale_flute_fx_xia",

--     animover_remove = false,
--     clientfn = CommonClientFn,
--     serverfn = CommonServerFn,
-- })
