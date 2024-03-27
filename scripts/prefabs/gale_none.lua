local assets =
{
	Asset( "ANIM", "anim/gale.zip" ),
	Asset( "ANIM", "anim/ghost_gale_build.zip" ),
}

local skins =
{
	normal_skin = "gale",
	ghost_skin = "ghost_gale_build",
}

local base_prefab = "gale"

local tags = {"GALE", "CHARACTER"}

return CreatePrefabSkin("gale_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	tags = tags,
	
	skip_item_gen = true,
	skip_giftable_gen = true,
})