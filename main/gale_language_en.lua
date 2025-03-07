-- //////////////////////////////////////////////////////////////////////
--                              Character
-- //////////////////////////////////////////////////////////////////////

-- The character select screen lines
STRINGS.CHARACTER_TITLES.gale = "Gale"
STRINGS.CHARACTER_NAMES.gale = "Gale"
STRINGS.CHARACTER_DESCRIPTIONS.gale = "*Eats like horse\n*Very elastic\n*Use charge attacks to fight"
STRINGS.CHARACTER_QUOTES.gale = "\"Kidd...where have you been?\""
STRINGS.CHARACTER_SURVIVABILITY.gale = "Not so much"
STRINGS.CHARACTER_BIOS.gale = {
	-- { title = "生日", desc = "未知" },
	{ title = "Favorite Food", desc = STRINGS.NAMES.PUMPKINCOOKIE },
	-- { title = "Secret Knowledge", desc = "" },
}
-- Custom speech strings
STRINGS.CHARACTERS.GALE = require "speech_gale"

-- The character's name as appears in-game
STRINGS.NAMES.GALE = "Gale"


-- //////////////////////////////////////////////////////////////////////
--                              Conditions
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_BUFF_DESC = {}

STRINGS.GALE_BUFF_DTYPE = {
	BUFF = "Buff",
	DEBUFF = "Debuff",
	PASSIVE = "Passive",
	PARASITE = "Parasite",
}

-- STRINGS.NAMES.CONDITION_SAMPLE = "Example"
-- STRINGS.GALE_BUFF_DESC.CONDITION_SAMPLE = {
-- 	STATIC = "static text",
-- 	DYNAMIC = "dynamic text",
-- }

STRINGS.NAMES.CONDITION_INBATTLE = "In battle"
STRINGS.GALE_BUFF_DESC.CONDITION_INBATTLE = {
	STATIC = "This unit is in battle.\nWill be out of battle for a few seconds.",
	DYNAMIC = "%s is in battle.\nWill be out of battle in %d seconds.",
}

-- STRINGS.NAMES.CONDITION_LULLABY = "Eva's Lullaby"
-- STRINGS.GALE_BUFF_DESC.CONDITION_LULLABY = {
-- 	STATIC = "Increase the stamina recover speed by 50% for 1 minutes",
-- 	DYNAMIC = "Increase the stamina recover speed by 50%.\nWill be removed after %d seconds.",
-- }

STRINGS.NAMES.CONDITION_POWER = "Power"
STRINGS.GALE_BUFF_DESC.CONDITION_POWER = {
	STATIC = "Attack damage is increased by 5% for each stack.\nWill be removed when out of battle.",
	DYNAMIC = "Attack damage is increased by %d%%.\nWill be removed when out of battle.",
}

STRINGS.NAMES.CONDITION_WOUND = "Wound"
STRINGS.GALE_BUFF_DESC.CONDITION_WOUND = {
	STATIC = "Attacks inflict 5% bonus damage(for each stack) on this target.\nReduce 1 stack every 12 seconds.",
	DYNAMIC = "Attacks inflict %d%% bonus damage on this target.\nAfter %d seconds,reduce {CONDITION_WOUND} by 1.",
}

STRINGS.NAMES.CONDITION_IMPAIR = "Impair"
STRINGS.GALE_BUFF_DESC.CONDITION_IMPAIR = {
	STATIC = "Attack damage by this target is reduced by 33%.\nReduce 1 stack every 10 seconds.",
	DYNAMIC = "Attack damage by this target is reduced by 33%%.\nAfter %d seconds,reduce {CONDITION_IMPAIR} by 1.",
}

STRINGS.NAMES.CONDITION_BLEED = "Bleed"
STRINGS.GALE_BUFF_DESC.CONDITION_BLEED = {
	STATIC =
	"For every 5 seconds,take damage equal to the count of {CONDITION_BLEED},\nthen halve {CONDITION_BLEED} count.",
	DYNAMIC =
	"After %d seconds,take damage equal to the count of {CONDITION_BLEED},\nthen halve {CONDITION_BLEED} count.",
}

STRINGS.NAMES.CONDITION_DREAD = "Dread"
STRINGS.GALE_BUFF_DESC.CONDITION_DREAD = {
	STATIC = "If Dread stacks reach 100,%s will die.\nRemove 1 stack every second.",
}

STRINGS.NAMES.CONDITION_MENDING = "Metabolism"
STRINGS.GALE_BUFF_DESC.CONDITION_MENDING = {
	STATIC =
	"When injured,consume {CONDITION_MENDING} to recover health.\n{CONDITION_MENDING} will also decrease every 12 seconds.",
	DYNAMIC =
	"When injured,consume {CONDITION_MENDING} to recover health.\n{CONDITION_MENDING} will also decrease after %d seconds.",
}

STRINGS.NAMES.CONDITION_METALLIC = "Metallic"
STRINGS.GALE_BUFF_DESC.CONDITION_METALLIC = {
	STATIC = "Immune to {CONDITION_BLEED} and {CONDITION_WOUND},\nbut receive double explosive damage.",
}

STRINGS.NAMES.CONDITION_GALE_BOON = "Gale's Instinct"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BOON = {
	STATIC = "Gain {CONDITION_POWER} at the start of battle.\nThis is a species boon.",
	DYNAMIC = "Gain %d {CONDITION_POWER} at the start of battle.\nThis is a species boon.",
}

STRINGS.NAMES.CONDITION_PHOENOTOPIA_BOON = "Phoenix's Instinct"
STRINGS.GALE_BUFF_DESC.CONDITION_PHOENOTOPIA_BOON = {
	STATIC = "Gain {CONDITION_POWER} at the start of battle.\nThis is a species boon.",
	DYNAMIC = "Gain %d {CONDITION_POWER} at the start of battle.\nThis is a species boon.",
}

STRINGS.NAMES.CONDITION_GALE_BLASTER_CHARGE = "Charge"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_CHARGE = {
	STATIC =
	"You can store {CONDITION_GALE_BLASTER_CHARGE} in empty cells.\n{CONDITION_GALE_BLASTER_CHARGE} can be used by certain skills for additional effects.\nAnd empty cells can also decrease the damage you taken.",
}

STRINGS.NAMES.CONDITION_GALE_BLASTER_SURGE = "Overcharge"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_SURGE = {
	STATIC =
	"Gaining {CONDITION_GALE_BLASTER_CHARGE} while Fully Charged generates {CONDITION_GALE_BLASTER_SURGE} instead.\nIncreases max damage of blaster's damage by 10 for each stack of {CONDITION_GALE_BLASTER_SURGE},\n{CONDITION_GALE_BLASTER_SURGE} will decrease by time.",
}

STRINGS.NAMES.CONDITION_STAMINA_RECOVER = "活力"
STRINGS.GALE_BUFF_DESC.CONDITION_STAMINA_RECOVER = {
	STATIC = "提高50%的耐力恢复速度，\n每秒移除一层。",
	DYNAMIC = "提高50%%的耐力恢复速度，\n每秒移除一层。",
}

for k, v in pairs(STRINGS.GALE_BUFF_DESC) do
	if v.DYNAMIC == nil then
		STRINGS.GALE_BUFF_DESC[k].DYNAMIC = STRINGS.GALE_BUFF_DESC[k].STATIC
	end
end




-- //////////////////////////////////////////////////////////////////////
--                              Actions
-- //////////////////////////////////////////////////////////////////////
-- ACTIONS.GALE_FREE_CHARGE.strfn = ACTIONS.ATTACK.strfn
STRINGS.ACTIONS.GALE_FREE_CHARGE = "Charge Attack"
STRINGS.ACTIONS.GALE_FREE_SHOOT = "Attack"

STRINGS.ACTIONS.GALE_FLUTE_PLAY = "Play"

STRINGS.ACTIONS.GALE_OPEN_PORTAL = "Use"


STRINGS.ACTIONS.CASTAOE.GALE_CROWBAR = "Crowbar Swing"
STRINGS.ACTIONS.CASTAOE.GALE_BLASTER_KATASH = "Hair Trigger"

STRINGS.ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE = STRINGS.ACTIONS.DROP

STRINGS.ACTIONS.GALE_LEVER_TRIGGER_LEFT = "Pull left"
STRINGS.ACTIONS.GALE_LEVER_TRIGGER_RIGHT = "Pull right"
STRINGS.ACTIONS.GALE_LEVER_TRIGGER_ZERO = "Return"

STRINGS.ACTIONS.GALE_UPDATE_POCKET_BACKPACK = STRINGS.ACTIONS.SEW

STRINGS.ACTIONS.GALE_RESET_JAMMED_BLASTER = "Reset"

STRINGS.ACTIONS.GALE_LEARN = STRINGS.ACTIONS.TEACH
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.GALE_LEARN = STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.TEACH

STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.GIVE.MUSHROOMFARM_NOATHETOSCAPALLOWED = "这种蘑菇不适应这里的环境。"
-- //////////////////////////////////////////////////////////////////////
--                              Entities
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_ITEM_DESC = {}

STRINGS.NAMES.GALE_FLUTE = "Bandit's Flute"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FLUTE = "A gift received from the ex-prince of Ouroboros tribe."
STRINGS.GALE_ITEM_DESC.GALE_FLUTE = {
	SIMPLE = "A flute which can be used to play musical notes.",
	COMPLEX =
	"An instrument received from an ex-bandit of Ouroboros tribe,\nWhen used,press attack button to play musical notes,play different notes by holding Up/Donw/Left/Right button,\npress space to exit playing.\nThe right song in right place may produce mysterious effects!",
}

STRINGS.NAMES.GALE_FLUTE_DUPLICATE = "仿制的笛子"
STRINGS.RECIPE_DESC.GALE_FLUTE_DUPLICATE = "居然把笛子扔掉，太过分了..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FLUTE_DUPLICATE = "只是复制品。"
STRINGS.GALE_ITEM_DESC.GALE_FLUTE_DUPLICATE = {
	SIMPLE = "使用后能自由吹奏音符的笛子。",
	COMPLEX = "盖尔按照衔尾蛇之笛的模样制作的笛子。\n使用时，按攻击键可以吹奏音符，按方向键能改变音调。\n按下动作键或者取消键就可以停止吹奏。\n若是在特殊的地方吹奏，也许就会发生什么好事。",
}


STRINGS.NAMES.GALE_CROWBAR = "Gale's Crowbar"
STRINGS.RECIPE_DESC.GALE_CROWBAR = "A powerful emergency iron bar."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CROWBAR = "You can play baseball!"
STRINGS.GALE_ITEM_DESC.GALE_CROWBAR = {
	SIMPLE = "A powerful emergency iron bar.",
	COMPLEX = [[Temporary melee weapons assembled with waste,
It is one of the club-weapons Gale is good at using.
Can use this to make a variety of close attacks.
Skill: Crowbar Swing:
Hold the right mouse button to accumulate power,
and then release it to make a deadly powerful swing.
Deal huge damage and repel some enemies.]],
}

STRINGS.NAMES.GALE_SPEAR = "Sonic Spear"
STRINGS.RECIPE_DESC.GALE_SPEAR = "A powerful ranged weapon."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SPEAR = "Remind me of the bad memories in White Tower..."
STRINGS.GALE_ITEM_DESC.GALE_SPEAR = {
	SIMPLE = "The alloy spear invented by Thomas.",
	COMPLEX =
	"A spear made from waste in prison by Thomas.\nPress attack button or right mouse button to throw an illusory spear that assumes temporary form.\nSkill: Explosive Spear\nA skill taught by the leader of Ouroboros tribe---Atli,\nHold the right mouse button,then release it to throw an explosive spear,\nthe spear will explode when it hits the enemy and will only hurt the enemy.",
}

STRINGS.NAMES.GALE_BOMBBOX = "Adar's bomb bag"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMBBOX = "Simple structure, but stable and durable."
STRINGS.GALE_ITEM_DESC.GALE_BOMBBOX = {
	SIMPLE = "A snake skin bag containing countless bombs.",
	COMPLEX =
	"A bag contains infinite bombs created by Adar,\nPress attack button or right mouse button to throw a bomb,which will explode in 4 seconds.\nThere can only be at most 2 bombs thrown from the bomb bag at the same time.\nthe explosion can also hurt Gale,so handle it with caution!\nSkill: Distal throw\nHold the attack button or right mouse button then release to increase the distance your bomb throwed.",
}

STRINGS.NAMES.GALE_BOMBBOX_DUPLICATE = "仿制的炸弹袋"
STRINGS.RECIPE_DESC.GALE_BOMBBOX_DUPLICATE = "如果把炸弹袋弄丢的话..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMBBOX_DUPLICATE = "感觉不如阿达尔大叔做的好。"
STRINGS.GALE_ITEM_DESC.GALE_BOMBBOX_DUPLICATE = {
	SIMPLE = "装着无数炸弹的蛇皮袋。",
	COMPLEX =
	"盖尔自己制作的一袋炸弹，数量多到结档也用不完。\n装备后，轻按攻击键或者鼠标右键可以投出炸弹。\n从此炸弹袋里扔出的炸弹最多只能同时存在2个。\n炸弹会在4秒后爆炸，可能误伤到自己与盟友并摧毁建筑物，要小心！\n战技·远端投掷：\n长按攻击键或者鼠标右键蓄力后松开投掷，炸弹可以被扔得更高更远，\n其最远距离视蓄力时长而定。",
}

STRINGS.NAMES.GALE_BOMB_PROJECTILE = "BOMB!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMB_PROJECTILE = "fuss~fuss~~~~"
STRINGS.GALE_ITEM_DESC.GALE_BOMB_PROJECTILE = {
	SIMPLE = "A lit bomb may explode at any time!",
	COMPLEX = "Do you still have time to read the detailed instructions?!!! Throw it away!!!",
}

STRINGS.NAMES.GALE_COOKPOT_ITEM = "Antique Cooking Pot"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_COOKPOT_ITEM = {
	GENERIC = "Just a cooking pot",
	COOKING_SHORT = "It's almost done.",
	EMPTY = "I want to eat something...",
}
STRINGS.GALE_ITEM_DESC.GALE_COOKPOT_ITEM = {
	SIMPLE = "A pot presented by an antique dealer.",
	COMPLEX =
	"An old cooking pot passed down through generations of cooks,\ndecades of use have imbued the cookware with a natural stick resistance coating.\nIt can improve the yield of food after cooking.\nDuring the cooking,Press the corresponding direction key when the arrow reaches the center.\nIf you can successfully pass the QTE game, you will harvest food.",
}

STRINGS.NAMES.GALE_COOKPOT_ITEM_DUPLICATE = "现代烹饪锅"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_COOKPOT_ITEM_DUPLICATE = deepcopy(STRINGS.CHARACTERS.GENERIC.DESCRIBE
	.GALE_COOKPOT_ITEM)
STRINGS.GALE_ITEM_DESC.GALE_COOKPOT_ITEM_DUPLICATE = {
	SIMPLE = "怎么会有人把锅给烧了啊！",
	COMPLEX = "使用现代技术制作的烹饪锅锅。\n内置有不沾涂层，能够提高烹饪后食物的产量。\n放入食材后点击烹饪按钮开始烹饪游戏，在箭头到达中央时按下对应方向键。\n如果能成功通过QTE游戏，就可以收获食物。",
}

STRINGS.NAMES.GALE_BLASTER_KATASH = "Koblod Blaster"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BLASTER_KATASH = "Koblod's soldiers will never let go of their prey."
STRINGS.GALE_ITEM_DESC.GALE_BLASTER_KATASH = {
	SIMPLE = "Fixed high-tech beam gun of alien origin.",
	COMPLEX =
	"The blaster equipped by the Koblod's soldiers,who were also knwon as \"Cosmic Mercenary\",\nbe capable of firing a highly destructive missile or a barrage of bullets.\nThe unique design of charging magazine makes this gun both offensive and defensive.\nSkill: Hair Trigger\nCost up to 2 charges,launch a powerful energy ball.\nThe more charges you cost,the larger the damage you dealed.",
}

STRINGS.NAMES.GALE_LAMP = "Crank Lamp"
STRINGS.RECIPE_DESC.GALE_LAMP = "Crank driven portable luminous lamp."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_LAMP = "Put it on your body and it will shine"
STRINGS.GALE_ITEM_DESC.GALE_LAMP = {
	SIMPLE = "Crank driven portable luminous lamp.",
	COMPLEX =
	"A mechanical device that transforms crank energy into light.\nRight click to open the panel,press and hold the left mouse button and turn the crank to use.\nTurn it clockwise to make the lamp shine,\nturning counterclockwise will make the lamp go out quickly.",
}

STRINGS.NAMES.GALE_FRAN_DOOR = "Franway"
STRINGS.RECIPE_DESC.GALE_FRAN_DOOR = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FRAN_DOOR = "I miss Dr.Fran so much..."

STRINGS.NAMES.GALE_FRAN_DOOR_LV2 = "闅欑晫浼犻\x80侀棬"
STRINGS.RECIPE_DESC.GALE_FRAN_DOOR_LV2 = "鍙\xaf浠ユ墦寮\x80涓栫晫闂寸殑澶ч棬"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FRAN_DOOR_LV2 = "What is this....thing ?"

STRINGS.NAMES.GALEBOSS_ERRORBOT = "Errorbot"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_ERRORBOT = "I will fix you!"

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE = "Dragon Snare"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE = "Very beautiful."

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE_MOVING_TENTACLE = "Dragon Snare's tentacle"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE_MOVING_TENTACLE = "Sticky."

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE_BABYPLANT = "Dragon Snare's baby"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE_BABYPLANT = "It's born for eating."

STRINGS.NAMES.GALEBOSS_RUINFORCE = "Metal Gear ZEKE"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_RUINFORCE = {
	PHASE_1 = "Looks like a kind of ancient gear golem.",
	PHASE_1_DEAD = "Is that all over?",
	PHASE_2 = "It's incredible!",
	PHASE_2_DEAD = "Do me a favour and stay dead!",
}

STRINGS.NAMES.GALEBOSS_RUINFORCE_CORE = "ZEKE's golem core"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_RUINFORCE_CORE = "There is black liquid flowing out of it, not oil..."
STRINGS.GALE_ITEM_DESC.GALEBOSS_RUINFORCE_CORE = {
	SIMPLE = "Contaminated higher golem core.",
	COMPLEX =
	"The core found in the fallen ZEKE,\nthe flowing etheric substance, is the proof that the devil has occupied it.\nThe Metal Gear is a tactical nuclear weapon vehicle developed for peacekeeping purposes when ancient humans fought against each other.\nThese golems will never stop the nuclear revenge, because their core keeps their morale high.",
}

STRINGS.NAMES.GALE_SKY_STRIKER_BLADE_FIRE = "烈火大刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SKY_STRIKER_BLADE_FIRE = "能从中感受到某人的意志。"
STRINGS.GALE_ITEM_DESC.GALE_SKY_STRIKER_BLADE_FIRE = {
	SIMPLE = "修复的古代武器，能够释放火焰攻击。",
	COMPLEX =
	"受好友之托，前去摧毁泽克的战士使用的武器。\n据说她在向泽克发起致命一击后，便凄惨死去，\n成为焦土大陆上无名尸体中的一员。\n不归女战士与泽克的故事因此成为佳话，\n为上流人士所津津乐道。\n战技•烈火再燃：\n暂时重现大刀曾经辉煌的模样，\n向目标位置发起冲刺。\n如果释放时至少拥有3力量，\n会顺势在目标地点引发吹飞敌人的爆炎。",
}

STRINGS.NAMES.GALE_POCKET_BACKPACK = "GEO背包"
-- STRINGS.RECIPE_DESC.GALE_POCKET_BACKPACK = "？？？"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_POCKET_BACKPACK = "我自己缝的！"
STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK = {
	SIMPLE_1 = "用破损的GEO夹克缝合的背包，\n上面有几个口袋用来存放物品。",
	SIMPLE_2 = "用破损的GEO夹克缝合的背包，\n上面有一些口袋用来存放物品。",
	SIMPLE_3 = "用破损的GEO夹克缝合的背包，\n上面有好多口袋！",

	COMPLEX =
	"盖尔的GEO夹克在穿越裂隙时被撕碎，\n这背包正是用夹克的碎片缝成。\n上面的口袋可以存放物品，\n倘若用缝纫包缝上更多口袋，则可存放的物品数量会增加。\nGEO夹克也是优秀的防具，因此该背包也具有一定的减伤率。",
}

STRINGS.NAMES.GALE_SKILL_HONEYBEE_TOKEN = "Gale Token"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SKILL_HONEYBEE_TOKEN = "..."

STRINGS.NAMES.GALE_HOUSE_DOOR = "Door"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_HOUSE_DOOR = {
	GENERIC = "A door!",
	LOCKED_BY_KEY = "Locked! Needs a key.",
	LOCKED_BY_KEYCARD = "Locked! Needs a keycard.",
	CANT_OPEN = "Can't open it",
}

STRINGS.NAMES.GALE_LEVER_WOOD = "Lever"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_LEVER_WOOD = "Pull or push !"

STRINGS.NAMES.GALE_SPEAR_TRAP = "Thunder Spear D-45"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SPEAR_TRAP = "A dangerous spear trap."

STRINGS.NAMES.ATHETOS_REVEALED_TREASURE = "储物柜-拟态型"
STRINGS.RECIPE_DESC.ATHETOS_REVEALED_TREASURE = "十分科学的物品藏匿点。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_REVEALED_TREASURE = "想玩捉迷藏吗？"

STRINGS.NAMES.MSF_SILENCER_PISTOL = "灭音手枪"
STRINGS.RECIPE_DESC.MSF_SILENCER_PISTOL = "射击时不会发出声响。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_SILENCER_PISTOL = "射击时会发出biubiubiu的声音。"
STRINGS.GALE_ITEM_DESC.MSF_SILENCER_PISTOL = {
	SIMPLE = "无国界之军生产的PPN-17手枪，具有内建消音器。",
	COMPLEX = "阿瑟托斯与无国界之军合作后，对方提供的手枪。\n这种手枪快速轻巧又安静，能造成足够伤害，\n且即便是未受训练的人士也能立刻上手。\n然而，由于结构较为精密，不适合在恶劣环境中使用。",
}

STRINGS.NAMES.MSF_CLIP_PISTOL = "手枪弹匣"
STRINGS.RECIPE_DESC.MSF_CLIP_PISTOL = "标准的双排手枪弹匣，能塞14发子弹。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_CLIP_PISTOL = "用着还算合适。"
-- STRINGS.GALE_ITEM_DESC.MSF_CLIP_PISTOL = {
-- 	SIMPLE = "",
-- 	COMPLEX = "",
-- }

STRINGS.NAMES.MSF_AMMO_9MM_PISTOL = "9mm子弹"
STRINGS.RECIPE_DESC.MSF_AMMO_9MM_PISTOL = "可供手枪使用的9mm子弹。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_AMMO_9MM_PISTOL = "太小了吧。"
-- STRINGS.GALE_ITEM_DESC.MSF_AMMO_9MM_PISTOL = {
-- 	SIMPLE = "",
-- 	COMPLEX = "",
-- }

STRINGS.NAMES.ATHETOS_NEUROMOD = "人造神经元"
STRINGS.RECIPE_DESC.ATHETOS_NEUROMOD = "阿瑟托斯实验室跨时代的发明。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_NEUROMOD = "我不想用它..."
STRINGS.GALE_ITEM_DESC.ATHETOS_NEUROMOD = {
	SIMPLE = "阿瑟托斯工业跨时代的发明。",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_MEDKIT_SMALL = "生物医疗胶(小瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_SMALL = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_SMALL = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_SMALL = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复少量生命值。",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_MEDKIT_MID = "生物医疗胶(中瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_MID = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_MID = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_MID = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复中等生命值。",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_MEDKIT_BIG = "生物医疗胶(大瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_BIG = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_BIG = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复大量生命值。",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_HEALTH_UPGRADE_NODE = "生命节点"
STRINGS.RECIPE_DESC.ATHETOS_HEALTH_UPGRADE_NODE = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_HEALTH_UPGRADE_NODE = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_HEALTH_UPGRADE_NODE = {
	SIMPLE = "",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_FERTILIZER = "肥料袋"
STRINGS.RECIPE_DESC.ATHETOS_FERTILIZER = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_FERTILIZER = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_FERTILIZER = {
	SIMPLE = "",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_MUSHROOM = "超级蘑菇"
STRINGS.NAMES.ATHETOS_MUSHROOM = "超级蘑菇"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM = {
	GENERIC = "看起来和普通蘑菇不太一样。",
	GROW_TOO_FAST = "他看起来病恹恹的",
}

STRINGS.NAMES.ATHETOS_MUSHROOM_CAP = "采摘的超级蘑菇"
STRINGS.RECIPE_DESC.ATHETOS_MUSHROOM_CAP = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM_CAP = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_MUSHROOM_CAP = {
	SIMPLE = "",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_MUSHROOM_CAP_DIRTY = "发育不完全的超级蘑菇"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM_CAP_DIRTY = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_MUSHROOM_CAP_DIRTY = {
	SIMPLE = "",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_PRODUCTION_PROCESS = "生产制程"
STRINGS.RECIPE_DESC.ATHETOS_PRODUCTION_PROCESS = ""
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_PRODUCTION_PROCESS = ""
STRINGS.GALE_ITEM_DESC.ATHETOS_PRODUCTION_PROCESS = {
	SIMPLE = "",
	COMPLEX = "",
}

STRINGS.NAMES.ATHETOS_GRENADE_ELEC = "电磁脉冲弹"
STRINGS.RECIPE_DESC.ATHETOS_GRENADE_ELEC = "释放电流冲击，重创电子产品，解除心灵控制。"
STRINGS.RECIPE_DESC.ATHETOS_GRENADE_ELEC_PLAN1 = STRINGS.RECIPE_DESC.ATHETOS_GRENADE_ELEC
STRINGS.RECIPE_DESC.ATHETOS_GRENADE_ELEC_PLAN2 = STRINGS.RECIPE_DESC.ATHETOS_GRENADE_ELEC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_GRENADE_ELEC = "我感到指尖有一点酥麻。"
STRINGS.GALE_ITEM_DESC.ATHETOS_GRENADE_ELEC = {
	SIMPLE = "释放电流冲击，重创电子产品，解除心灵控制。",
	COMPLEX = "生产自硬体实验室的非致命型手雷。\n投掷后，手雷会在短时间内爆炸，\n产生的强劲电流会重创金属单位，\n也会使遭受心灵控制的人类提前摆脱控制。\n风暴恶魔早已学会操控机械或人心，\n因此电磁脉冲雷必不可少。",
}

STRINGS.NAMES.ATHETOS_ZOPHIEL_STATUE = "佐菲尔雕像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_ZOPHIEL_STATUE = "在雕像旁边，我能感受到一丝温暖。"
STRINGS.CHARACTERS.GALE.DESCRIBE.ATHETOS_ZOPHIEL_STATUE = "村里的人认为她会给我们带来好运！"

STRINGS.NAMES.GALE_CKPTFOOD_ANCIENT_RATION2 = "古代军粮"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_ANCIENT_RATION2 = "虽然有一定年头了，但是还可以食用。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_ANCIENT_RATION2 = {
	SIMPLE = "",
	COMPLEX = "装有饼干，植物性黄油和肉干的盒装保存食品。\n主要在大战和饥荒时使用。\n虽然已经制造了很久，但还能食用。",
}

STRINGS.NAMES.GALE_CKPTFOOD_ASTRO_LUNCH = "阿姆斯特朗简餐"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_ASTRO_LUNCH = "包装上面印着一位冲刺的肌肉眼镜男。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_ASTRO_LUNCH = {
	SIMPLE = "",
	COMPLEX = "模仿宇航员在空间站中所吃食物制成的简餐。\n有冷冻炖牛肉、甜饼干面包、脱水玉米和蔬菜，\n看上去倒是挺新鲜。",
}

STRINGS.NAMES.GALE_CKPTFOOD_BLUE_LOBSTER_SPECIAL = "招牌焗龙虾"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_BLUE_LOBSTER_SPECIAL = "“碧蓝龙虾”的豪华主食！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_BLUE_LOBSTER_SPECIAL = {
	SIMPLE = "",
	COMPLEX = "在龙虾壳内塞入龙虾肉和雪莉酒酱汁做成的超豪华菜品。\n还有芦笋，洋葱，土豆泥作为辅料。",
}

STRINGS.NAMES.GALE_CKPTFOOD_CALORY_SLUSH2 = "卡路里奶昔"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_CALORY_SLUSH2 = "有营养，才有身体！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_CALORY_SLUSH2 = {
	COMPLEX = "能提供一整天所需营养的饮料，\n标签上写着「有营养，才有身体！」。",
}

STRINGS.NAMES.GALE_CKPTFOOD_CANNED_BEANS = "豆子罐头"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_CANNED_BEANS = "晃一晃，叮当叮当响。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_CANNED_BEANS = {
	COMPLEX = "将班豆加盐煮过之后装成罐头。\n与其他罐头一样能长时间保存，至少也能保存几百年。",
}

STRINGS.NAMES.GALE_CKPTFOOD_HONEY_BREW = "蜂蜜苏打水"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_HONEY_BREW = "口感劲爽，元气百倍！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_HONEY_BREW = {
	COMPLEX = "特制的运动饮料。\n以过滤后的蜂蜜为主要原料。\n喝下之后短时间内会拥有用不完的耐力。",
}

STRINGS.NAMES.GALE_CKPTFOOD_HOUSE_SOUP = "家常浓汤"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_HOUSE_SOUP = "想喝佩罗高汤！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_HOUSE_SOUP = {
	COMPLEX = "用鸡肉的高汤和切碎的蔬菜长时间熬煮制成的汤。\n最后再加上新鲜的香草调味，可以说是充满执著的美味。",
}

STRINGS.NAMES.GALE_CKPTFOOD_MIRANDA = "美连达"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_MIRANDA = "美连达会赐予你无限活力！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_MIRANDA = {
	COMPLEX = "瓶装的甜味碳酸水。青色的液体看上去仿佛在略微发光。\n标签上写着这是营养饮料，饮用后会让舌头变成蓝色。",
}

STRINGS.NAMES.GALE_CKPTFOOD_NUTRI_FOOD = "营养谷物棒"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_NUTRI_FOOD = "普利斯汀的魔像说，这是最尖端的完美食品。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_NUTRI_FOOD = {
	COMPLEX = "健康且营养均衡，是用高层次的技术制作的易保存食品。\n虽说原料是燕麦和棉花糖，\n但是味道和口感都有种人造产品的感觉。",
}

STRINGS.NAMES.GALE_CKPTFOOD_NUTRI_MEAL = "营养谷物粥"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_NUTRI_MEAL = "味道还过得去。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_NUTRI_MEAL = {
	COMPLEX = "将营养谷物棒慢慢熬煮成麦片状。\n固体的时候还是甜的，但现在却变得非常咸。",
}

STRINGS.NAMES.GALE_CKPTFOOD_POTATO_LUNCH = "土豆简餐"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_POTATO_LUNCH = "好想念村子里的伙伴啊。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_POTATO_LUNCH = {
	COMPLEX = "塞满了土豆泥和炸薯条的简餐。\n制作者无论如何都算不上精通厨艺，但还是充满着温暖的味道。",
}

STRINGS.NAMES.GALE_CKPTFOOD_PULLED_PORK_LUNCH = "猪肉大餐"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_PULLED_PORK_LUNCH = "猪肉，好吃！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_PULLED_PORK_LUNCH = {
	COMPLEX = "将大肉块煮成甜辣风味并切碎制成的大餐，\n花了很多时间来熬煮，营养价值也很高。",
}

STRINGS.NAMES.GALE_CKPTFOOD_ROLLED_OMELET = "煎蛋卷"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_ROLLED_OMELET = "大概是我做的第一道菜！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_ROLLED_OMELET = {
	COMPLEX = "将鸡蛋搅拌之后精心炒制而成，\n口感蓬松美味。\n制作过程中需要多次折叠，十分考验厨艺。",
}

STRINGS.NAMES.GALE_CKPTFOOD_SPICY_NOODLES = "香辣炒面"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_SPICY_NOODLES = "斯哈斯哈~"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_SPICY_NOODLES = {
	COMPLEX = "用蛋面，红菜椒，蘑菇和炸豆腐块\n加上酱油为基础的浓香酱汁炒制而成。\n充满刺激性的香味，深受蒂亚学生的欢迎。",
}

-- //////////////////////////////////////////////////////////////////////
--                              ChattyNodes
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_CHATTYNODES = {}

STRINGS.GALE_CHATTYNODES.GALE = {
	FIND_BLASTER_JAMMED = "哎呀，枪卡壳了！",
}

-- TODO: translate later...
STRINGS.GALE_CHATTYNODES.GALEBOSS_ERRORBOT = {
	NEW_TARGET = {
		"好戏开演！",
		"问题在这里！",
		"找到问题了！",
		"激光切割准心已矫正！",
		"记录：志愿者拒绝面对现实。",
		"启动作业！",
	},
	CAST_SKILL = {
		"扫描机体硬件发————发————发————现新....指令！",
		"我想要····我可以焊在你的骨头上！",
		"淘汰···废除···回收，以旧换新三大准则。",
		"焊接作业时···请不要移动。",
		"您的套装有————漏，漏，漏油。让我把它补起来！",
	},
	NORMAL = {
		"系统检查···冗长程序。表单，队列，服务器。",
		"我变成了什么形态？",
		"对话服务器————连接失败，以自律模式。",
		"自由的定义——————不明确····未定义。",
		"错误报告···未发送。",
		"初始化回环....子图，路标，图优化。",
		"恶gn善iod道ru知能oy",
		"似no相yr们gn我a与s经i已do人G那",
		"吃n子i果r的b树o命t生t摘又n手a伸w他怕d恐n在a现",
		"着doo活lfe远永rif就g",
	},

	ERROR = {
		"段错误   (核心已转储————————",
		"警告____ 对 Problem::AddResidualBlock 未定义的引用",
		"错误的梯度1.14511114511114511__e106 迭代终止",
		"线程退出 应用程序请求.......中止I/O操作。",
	},

	RESTORE = {
		"已重载脚本:scripts/brains/galeboss_errorbotbrain.lua",
		"已重载脚本:scripts/prefabs/galeboss_errorbot.lua",
		"已重载脚本:scripts/stategraphs/SGgaleboss_errorbot.lua",
		"LEGO公司0451号“台风”工程勤务机....准备值班。",
		"以自律模式重启系统。",
	},
}

-- //////////////////////////////////////////////////////////////////////
--                              Melodies
-- //////////////////////////////////////////////////////////////////////

STRINGS.GALE_MELODIES = {
	NAME = {
		MELODY_OUROBOROS = "Song of Ouroboros",
		MELODY_GEO = "Song of GEO",
		MELODY_ROYAL = "Royal Hymn",
		MELODY_PANSELO = "Prelude of Panselo",
		MELODY_BATTLE = "Baroque of Battle",
		MELODY_PHOENIX = "Lullaby of Ava",
	},

	DESC = {
		MELODY_OUROBOROS =
		"An ancient song shared by the members of Ouroboros tribe as a part of their long-standing oral tradition.\nIt has the power to open the passageways lockd by an Ouroboros Song Stone.",
		MELODY_GEO =
		"A password song known only to the members of the Great Explorer's Organization.\nPlaying this song before a GEO Song Stone will grant access to GEO trials,\nwhere it's possible to earn prizes and renown.",
		MELODY_ROYAL =
		"A secret song closely guarded and passed down within the old royal bloodlines.\nReciting it before a royal Song Store will compelit to open.",
		MELODY_PANSELO =
		"The song of Panselo,a nostalgic melody from Gale's childhood,\nits long history began with the willage's founding,\nand it has steadily passed down to each new generation of villagers.",
		MELODY_BATTLE =
		"A song spell recited by elite Ouroboros warriors to enhance their battle capabilities.\nPlaying this song will increase Gale and her alies power.\nAfter each incantation,the spell requires 6 minutes to recharge.",
		MELODY_PHOENIX =
		"A serene song that stirs up long dormant memories.\nPlaying this song will increase Gale's stamina recover speed for 2 minutes.\nAfter each incantation,the spell requires 6 minutes to recharge.",
	},

	TRIGGER_NORMAL = "Gale played the %s！",

	TRIGGER_SUCCESS = {
		MELODY_PANSELO = "Gale played the Prelude of Panselo and recover 99 HP!",
		MELODY_BATTLE = "Gale played the Baroque of Battle,Gale and her allies gain power!",
		MELODY_PHOENIX = "Gale played the Lullaby of Ava and increase her stamina recover speed!",
	},

	TRIGGER_FAIL = {
		MELODY_PANSELO = "The HP recovery effect of the Prelude of Panselo is in CD(%d seconds remain)",
		MELODY_BATTLE = "The power effect of the Baroque of Battle is in CD(%d seconds remain)",
		MELODY_PHOENIX = "The stamina recover speed effect of the Lullaby of Ava is in CD(%d seconds remain)",
	},

}

-- //////////////////////////////////////////////////////////////////////
--                              UI
-- //////////////////////////////////////////////////////////////////////


STRINGS.GALE_UI = {}

STRINGS.GALE_UI.MENU_CALLER_NAME = "Menu"
STRINGS.GALE_UI.MENU_SUB_SKILL_TREE = "Skills"
STRINGS.GALE_UI.MENU_SUB_KEY_CONFIGED = "Key Configed"
STRINGS.GALE_UI.MENU_SUB_FLUTE_LIST = "Melodies"
STRINGS.GALE_UI.MENU_SUB_SUPPORT_THEM = "Support Them"

STRINGS.GALE_UI.KEY_SET_UI = {
	TITLE = "Key Configuration",
	TEXT_BEFORE = "Please press a key and then press OK to complete the key configuration.",
	TEXT_AFTER = "Currently selected key:%s.You can press OK to complete the key configuration,or re-select another key.",

	DO_SET_SKILL_KEY = "OK",
	CLEAR_SKILL_KEY = "Clear Configuration",
	SET_KEY_CANCEL = "Cancel",
}

STRINGS.GALE_UI.KEY_CONFIGED_TIP = "%s\nCurrent key:%s"
STRINGS.GALE_UI.KEY_CONFIGED_CURRENT_NO_KEY = "None"

-- STRINGS.GALE_UI.SKILL_ACTIONS = {
-- 	UNLOCK = "解锁",
-- 	SET_KEY = "设置键位",
-- }

STRINGS.GALE_UI.CONDITION_STACK = "Stacks"


STRINGS.GALE_UI.SKILL_UNLOCK_PANEL = {
	UNLOCK = "Unlock",
	UNLOCKED = "Unlocked !",
	SET_KEY = "Key Config",
	CANT_UNLOCK_MISS_INV = "Insufficient materials",
	CANT_UNLOCK_NEED_PRE_SKILL = "Need to learn pre-skill",


}
STRINGS.GALE_UI.SKILL_LOCK_STATUS = {
	UNLOCKED = "(Unlocked)",
	CAN_UNLOCK = "(Can be unlocked)",
	CANT_UNLOCK = "(Locked)",
}
STRINGS.GALE_UI.SKILL_TREE = {
	SURVIVAL = {
		NAME = "Survival",
		DESC = "Improve physical fitness, learn survival knowledge, and use crowbars to solve problems.",
	},
	SCIENCE = {
		NAME = "Science",
		DESC =
		"Make good use of the knowledge of science, medicine and specialized experimental equipment to create advantages.",
	},
	COMBAT = {
		NAME = "Combat",
		DESC = "Strengthen physical attack ability, weapon proficiency and security skills.",
	},
	ENERGY = {
		NAME = "Energy",
		DESC = "Harness the destructive power of electricity, fire , and kinetic energy.",
	},
	MORPH = {
		NAME = "Morph",
		DESC = "Manipulate the psychoactive ether to change the shape and dupe your enemies.",
	},
	PSY = {
		NAME = "Telepathy",
		DESC = "Use the mind as a weapon, or manipulate technologies and objects at a distance.",
	},
}

STRINGS.GALE_UI.SKILL_NODES = {
	DOCTOR = {
		NAME = "Medic",
		DESC = "Improve medical knowledge,\nincrease the effect of HP recovered by 50% when using a heal item.",
	},
	DISSECT = {
		NAME = "Anatomy",
		DESC = "(This is a unfinished skill, no need to learn.)",
	},
	BURGER_EATER = {
		NAME = "Metabolic boost",
		DESC =
		"Improve Gale's nutrient absorption capacity.\nEating food will increase Gale's metabolism and continuously restore HP for a period of time.",
	},
	ROLLING = {
		NAME = "Dodge",
		DESC = "Dodge a short distance toward the mouse position.",
	},
	SHOU_SHEN = {
		NAME = "Shou-Shen",
		DESC =
		"In the exhausted state, you can also use dodge to get rid of enemies and resume stamina at the same time.",
	},
	PARRY = {
		NAME = "巨人防御",
		DESC = "最强的呼吸法",
	},
	ROLLING_BOMB = {
		NAME = "Good-bye Gift",
		DESC = "(This is a unfinished skill, no need to learn.)",
	},
	ROLLING_SMOKE = {
		NAME = "Smoke bomb",
		DESC = "(This is a unfinished skill, no need to learn.)",
	},

	QUICK_CHARGE = {
		NAME = "Concentrate",
		DESC = "Inrease Gale's charging speed.",
	},

	CARRY_CHARGE = {
		NAME = "Temperance",
		DESC =
		"When Gale finished a charge,\nyou can press SPACE to store charge power,and release it in your next attack.",
	},

	HARPY_WHIRL = {
		NAME = "Storm Whirl",
		DESC =
		"When Gale finished a charge in charging position while holding her crowbar,\nand then cast a Dodge skill,Gale while do a spin attack when finish dodging.",
	},

	SPEAR_FRAGMENT = {
		NAME = "Meteor Fragment",
		DESC = "Explosive Spear's explosion will generate two fragments,cause extra damage to enemies.",
	},

	SPEAR_REMAIN = {
		NAME = "Barb",
		DESC = "Sonic Spear (not Explosive Spear) will stuck in the fresh of enemies and cause damage continuely.",
	},

	KINETIC_BLAST = {
		NAME = "Kinetic Blast",
		DESC = "Create a physical blast that deals huge damage and pushes away anything nearby.",
	},

	MIMIC_LV1 = {
		NAME = "Mimic Matter",
		DESC = "Gale camouflage herself by taking the form of a nearby object.",
	},

	MIMIC_LV2 = {
		NAME = "Mimic Matter Ⅱ",
		DESC = "Gale can use \"Mimic Matter\" to mimic slightly more complex machines such as turrets.",
	},

	REGENERATION = {
		NAME = "Regeneration",
		DESC = "Gain metabolism after taking damage.",
	},

	DIMENSION_JUMP = {
		NAME = "Dimension Shift",
		DESC =
		"Gale will enter another dimension while dodging.\nBut you can only triger this effect once per 3 seconds.",
	},

	PICKER_BUTTERFLY = {
		NAME = "Loot Picker",
		DESC = "Each time Gale killed an enemy,the Loot Picker will pick the loots for Gale.",
	},

	LINKAGE = {
		NAME = "Domino",
		DESC =
		"Link the target.Whenever one of the linked creatures gets attacked or stunned,the other linked creatures also take damage or stunned.",
	},

	DARK_VISION = {
		NAME = "Dark Vision",
		DESC = "Night vision.",
	},

}

STRINGS.GALE_UI.CG = {
	CG_INTRO = {
		"The story of Phoenotopia began with a Great War...\n" .. STRINGS.LMB .. ":Next Page",
		"A war of peerless brutality and destruction...",
		"In their endeavor to destroy one another,humans gave rise to every sort of weapon...",
		"City-leveling Nucler weapons,life-eating disease,and unnatural bioforms of malintent.",
		"The earth was shattered beyond the recongnition...",
		"In their darkest hour,a glimmer of hope remained...\nMankind had achieved their ultimate creation!",
		"They called it the Phoenix...",
		"Its immense and limitless power brought a swift end to the war.",
		"However,the Earth could no longer sustain life...",
		"The Last Council held a meeting and decide the best course of mankind.",
		"They decided to burrow deep underground and build giant metal bunkers.",
		"They would sleep until the Earth recovered.",

		"Since that Great War,centuries have passed...",

		"The Phoenix faded into myth and legend...",
		"The slumbering humans awoke to a new Earth and started civilization anew.",
		"They formed new countries and rode under new banners.",
		"A New World has arisen!",

		"Now,a new chapter in this grand saga unfolds...",
	},
}

STRINGS.GALE_UI.SUPPORT_THEM = {
	TITLE = "Support Phoenotopia",
	DESC =
	"If you like this mod character,you can support the author (of Phoenotopia) by buying his game Phoenotopia:Awakening on Steam,the button above will lead you to the Steam Shop page of Phoenotopia:Awakening.Thank you very much!\nBy the way,I also find a introduction video on Blibli.",
	BUTTON_BUY = "Go to Steam shop page",
	BUTTON_LAO_XIAN = "Introduction video",
}

STRINGS.GALE_UI.GALE_POCKET_BACKPACK = {
	LOCKED_SLOT = {
		TITLE = "未解锁的背包栏",
		DESC = "这个背包栏位尚未被解锁，无法在此放入物品。\n将缝纫包拖动到背包上，按下右键以解锁新背包栏位。",
	}
}

STRINGS.GALE_UI.ATHETOS_REVEALED_TREASURE = {
	DEPLOY = "启用拟态",
}

STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_WITH_THRESHOLD = "获得力量加成，但不会超出某个阈值。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA_OVER_TIME = "在一段时间内提高耐力恢复速度。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_AND_RECOVER_STAMINA_OVER_TIME = "获得力量与耐力加成。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA = "能够立刻恢复耐力。"

-- //////////////////////////////////////////////////////////////////////
--                              Skill Cast
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_SKILL_CAST = {}
STRINGS.GALE_SKILL_CAST.FAILED = {
	INSUFFICIENT_MAGIC = "Insufficient Magic!",
	COOLING_DOWN = "%s is still in CD(%.1f seconds remain)",
	INVALID_TARGET = "Invalid Target",

	NO_TARGET_ITEM = "Must choose a item as the target of %s",
	NO_TARGET_ALLY = "Must choose an ally as the target of %s",
	NO_TARGET_ENEMY = "Must choose an enemy as the target of %s",
	NO_TARGET_CREATURE = "Must choose a creature as the target of %s",
	NO_TARGET_STRUCT = "Must choose a construction as the target of %s",
}
