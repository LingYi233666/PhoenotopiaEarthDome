local function GaleModAddRecipe2(name, ingredients, tech, config, filters, ...)
    -- For quick search build image
    if config then
        if config.atlas == nil and config.image == nil then
            config.image = name .. ".tex"
            config.atlas = "images/inventoryimages/" .. name .. ".xml"
        end
    end

    return AddRecipe2(name, ingredients, tech, config, filters, ...)
end


GaleModAddRecipe2(
    "gale_crowbar",
    {
        Ingredient("goldnugget", 2),
        Ingredient("flint", 4),
    },
    TECH.NONE,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_bombbox_duplicate",
    {
        Ingredient("gunpowder", 5),
        Ingredient("meat", 8),
        Ingredient("papyrus", 3),
    },
    TECH.NONE,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_cookpot_item_duplicate",
    {
        -- Ingredient("portablecookpot_item", 1),
        Ingredient("cutstone", 3),
        Ingredient("charcoal", 6),
        Ingredient("twigs", 6),
        Ingredient("transistor", 4),
    },
    TECH.NONE,
    {
        builder_tag = "gale",
        image = "portablecookpot_item.tex",
        -- atlas = "images/inventoryimages.xml",
    },
    { "CHARACTER", "COOKING" }
)

GaleModAddRecipe2(
    "gale_flute_duplicate",
    {
        Ingredient("panflute", 1),
        Ingredient("yellowgem", 1),
    },
    TECH.NONE,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "MAGIC" }
)


GaleModAddRecipe2(
    "gale_spear",
    {
        Ingredient("spear", 1),
        Ingredient("wagpunk_bits", 2),
        Ingredient("blue_cap", 1),
    },
    TECH.NONE,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_lamp",
    {
        Ingredient("lantern", 1),
        Ingredient("transistor", 2),
        Ingredient("gears", 1),
        Ingredient("twigs", 3),
    },
    TECH.SCIENCE_TWO,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "LIGHT" }
)

GaleModAddRecipe2(
    "gale_lamp_lv2",
    {
        Ingredient("gale_lamp", 1, "images/inventoryimages/gale_lamp.xml"),
        Ingredient("bluegem", 2),
        Ingredient("thulecite", 1),
        Ingredient("trinket_6", 3),
    },
    TECH.SCIENCE_TWO,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "LIGHT" }
)

-- GaleModAddRecipe2(
--     "gale_fran_door",
--     {
--         Ingredient("gears", 2),
--         Ingredient("transistor", 4),
--         Ingredient("bluegem", 10),
--     },
--     TECH.SCIENCE_TWO,
--     {
--         builder_tag = "gale",
--         placer = "gale_fran_door_placer",
--         atlas = "images/map_icons/gale_fran_door.xml",

--     },
--     { "CHARACTER", "STRUCTURES" }
-- )

GaleModAddRecipe2(
    "gale_fran_door_item",
    {
        Ingredient("gears", 2),
        Ingredient("transistor", 4),
        Ingredient("bluegem", 10),
    },
    TECH.LOST,
    {
        -- builder_tag = "gale",
    },
    { "STRUCTURES", "MAGIC" }
)

GaleModAddRecipe2(
    "gale_sky_striker_blade_fire",
    {
        Ingredient("galeboss_ruinforce_core", 1, "images/inventoryimages/galeboss_ruinforce_core.xml"),
        Ingredient("transistor", 1),
        Ingredient("heatrock", 1),
    },
    TECH.SCIENCE_TWO,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "athetos_medkit_small",
    {
        Ingredient("spidergland", 1),
        Ingredient("honey", 1),
        Ingredient("goldnugget", 1),
    },
    TECH.LOST,
    {

    },
    { "RESTORATION" }
)

GaleModAddRecipe2(
    "athetos_medkit_mid",
    {
        Ingredient("athetos_medkit_small", 2, "images/inventoryimages/athetos_medkit_small.xml"),
    },
    TECH.LOST,
    {

    },
    { "RESTORATION" }
)

GaleModAddRecipe2(
    "athetos_medkit_big_plan1",
    {
        Ingredient("athetos_medkit_small", 3, "images/inventoryimages/athetos_medkit_small.xml"),
    },
    TECH.LOST,
    {
        image = "athetos_medkit_big.tex",
        atlas = "images/inventoryimages/athetos_medkit_big.xml",
        product = "athetos_medkit_big",
    },
    { "RESTORATION" }
)

GaleModAddRecipe2(
    "athetos_medkit_big_plan2",
    {
        Ingredient("athetos_medkit_small", 1, "images/inventoryimages/athetos_medkit_small.xml"),
        Ingredient("athetos_medkit_mid", 1, "images/inventoryimages/athetos_medkit_mid.xml"),
    },
    TECH.LOST,
    {
        image = "athetos_medkit_big.tex",
        atlas = "images/inventoryimages/athetos_medkit_big.xml",
        product = "athetos_medkit_big",
    },
    { "RESTORATION" }
)

GaleModAddRecipe2(
    "athetos_fertilizer",
    {
        Ingredient("nightmarefuel", 1),
        Ingredient("papyrus", 4),
        Ingredient("cutgrass", 8),
        Ingredient("twigs", 5),
        Ingredient("poop", 10),
        Ingredient("spoiled_food", 7),
        Ingredient("nitre", 6),
    },
    TECH.LOST,
    {

    },
    { "GARDENING" }
)

GaleModAddRecipe2(
    "athetos_neuromod",
    {
        Ingredient("nightmarefuel", 8),
        Ingredient("goldnugget", 5),
        Ingredient("stinger", 1),
    },
    TECH.LOST,
    {

    },
    { "MAGIC" }
)

GaleModAddRecipe2(
    "msf_silencer_pistol",
    {
        Ingredient("gears", 1),
        Ingredient("goldnugget", 6),
        Ingredient("stinger", 3),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "msf_clip_pistol",
    {
        Ingredient("goldnugget", 2),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "msf_ammo_9mm_pistol",
    {
        Ingredient("goldnugget", 1),
        Ingredient("gunpowder", 2),
        Ingredient("rocks", 4),
    },
    TECH.LOST,
    {
        numtogive = 14,
    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "athetos_health_upgrade_node",
    {
        Ingredient("goldnugget", 3),
        Ingredient("redgem", 10),
        Ingredient("gears", 1),
    },
    TECH.LOST,
    {

    },
    { "RESTORATION" }
)

GaleModAddRecipe2(
    "athetos_grenade_elec_plan1",
    {
        Ingredient("lightninggoathorn", 1),
        Ingredient("transistor", 3),
        Ingredient("nitre", 1)
    },
    TECH.LOST,
    {
        numtogive = 5,
        image = "athetos_grenade_elec.tex",
        atlas = "images/inventoryimages/athetos_grenade_elec.xml",
        product = "athetos_grenade_elec",
    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "athetos_grenade_elec_plan2",
    {
        Ingredient("feather_canary", 1),
        Ingredient("transistor", 3),
        Ingredient("nitre", 1)
    },
    TECH.LOST,
    {
        numtogive = 5,
        image = "athetos_grenade_elec.tex",
        atlas = "images/inventoryimages/athetos_grenade_elec.xml",
        product = "athetos_grenade_elec",
    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "athetos_portable_turret_item",
    {
        Ingredient("boards", 2),
        Ingredient("cutstone", 4),
        Ingredient("transistor", 3),
        Ingredient("gears", 2),

        Ingredient("redgem", 1),
        Ingredient("yellowgem", 1),
        Ingredient("greengem", 1),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS", "CHARACTER" }
)

GaleModAddRecipe2(
    "athetos_magic_potion",
    {
        Ingredient("nightmarefuel", 1),
        Ingredient("blue_cap_cooked", 1),
        Ingredient("goldnugget", 2),
        Ingredient("stinger", 1),
    },
    TECH.LOST,
    {

    },
    { "RESTORATION", "CHARACTER" }
)

GaleModAddRecipe2(
    "gale_blaster_katash",
    {
        Ingredient("transistor", 4),
        Ingredient("wagpunk_bits", 8),
        Ingredient("redgem", 1),
        Ingredient("bluegem", 4),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "galeboss_katash_blade",
    {
        Ingredient("transistor", 2),
        Ingredient("wagpunk_bits", 4),
        Ingredient("purplegem", 1),
        Ingredient("lightninggoathorn", 1),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_hammer",
    {
        Ingredient("hammer", 1),
        Ingredient("wagpunk_bits", 2),
        Ingredient("cutstone", 2),
        Ingredient("twigs", 4),
    },
    TECH.SCIENCE_ONE,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "TOOLS", "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_mace",
    {
        Ingredient("livinglog", 3),
        Ingredient("thulecite", 4),
        Ingredient("moonrocknugget", 8),
    },
    TECH.SCIENCE_TWO,
    {
        builder_tag = "gale",
    },
    { "CHARACTER", "MAGIC", "WEAPONS" }
)

GaleModAddRecipe2(
    "gale_trinket_rabbit",
    {
        Ingredient("rabbit", 1),
        Ingredient("manrabbit_tail", 1),
        Ingredient("carrot", 1),

    },
    TECH.NONE,
    {
        builder_tag = "gallop",
    },
    { "CHARACTER", "DECOR" }
)

GaleModAddRecipe2(
    "gale_destruct_item_table",
    {
        Ingredient("boards", 4),
        Ingredient("wagpunk_bits", 2),
        Ingredient("papyrus", 1),
        Ingredient("blue_cap", 1),
    },
    TECH.NONE,
    {
        builder_tag = "gale_destruct_item_table_builder",
        placer = "gale_destruct_item_table_placer",
    },
    { "CHARACTER", "STRUCTURES" }
)


GaleModAddRecipe2(
    "athetos_amulet_berserker_fixed",
    {
        Ingredient("athetos_amulet_berserker_broken", 1, "images/inventoryimages/athetos_amulet_berserker_broken.xml"),
        Ingredient("wagpunk_bits", 3),
    },
    TECH.SCIENCE_TWO,
    {

    },
    { "WEAPONS" }
)

GaleModAddRecipe2(
    "athetos_amulet_berserker",
    {
        Ingredient("redgem", 1),
        Ingredient("transistor", 2),
        Ingredient("wagpunk_bits", 6),
    },
    TECH.LOST,
    {

    },
    { "WEAPONS" }
)
