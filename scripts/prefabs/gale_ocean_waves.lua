local GaleEntity = require("util/gale_entity")

local assets = {
    Asset("ANIM", "anim/wave_hurricane.zip"),
    Asset("ANIM", "anim/wave_shimmer.zip"),
    Asset("ANIM", "anim/wave_shimmer_deep.zip"),
    Asset("ANIM", "anim/wave_shimmer_flood.zip"),
    Asset("ANIM", "anim/wave_shimmer_med.zip"),
    Asset("ANIM", "anim/wave_shore.zip"),
}

return GaleEntity.CreateNormalFx({
    prefabname = "gale_wave_shimmer_med",
    assets = assets,

    bank = "shimmer",
    build = "wave_shimmer_med",
    anim = "idle",
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_wave_shimmer",
    assets = assets,

    bank = "shimmer",
    build = "wave_shimmer",
    anim = "idle",
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_wave_shimmer_deep",
    assets = assets,

    bank = "shimmer",
    build = "wave_shimmer_deep",
    anim = "idle",
}),
GaleEntity.CreateNormalFx({
    prefabname = "gale_wave_shimmer_flood",
    assets = assets,

    bank = "wave_shimmer_flood",
    build = "wave_shimmer_flood",
    anim = "idle",
})
-- GaleEntity.CreateNormalFx({
--     prefabname = "gale_wave_shore",
--     assets = assets,

--     bank = "shimmer",
--     build = "wave_shore",
--     anim = "idle",
-- }),
-- GaleEntity.CreateNormalFx({
--     prefabname = "gale_wave_hurricane",
--     assets = assets,

--     bank = "shimmer",
--     build = "wave_hurricane",
--     anim = "idle",
-- })