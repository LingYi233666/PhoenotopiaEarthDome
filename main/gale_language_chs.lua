-- //////////////////////////////////////////////////////////////////////
--                              Character
-- //////////////////////////////////////////////////////////////////////

-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.gale = "凯尔"
STRINGS.CHARACTER_NAMES.gale = "凯尔"
STRINGS.CHARACTER_DESCRIPTIONS.gale = "*很能吃\n*非常有弹性\n*蓄力攻击更是重量级"
STRINGS.CHARACTER_QUOTES.gale = "\"基德...你到底上哪里去了...？\""
STRINGS.CHARACTER_SURVIVABILITY.gale = "简单"
STRINGS.CHARACTER_BIOS.gale = {
	-- { title = "生日", desc = "未知" },
	{ title = "最喜欢的食物", desc = STRINGS.NAMES.PUMPKINCOOKIE },
	-- { title = "Secret Knowledge", desc = "" },
}
-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.GALE = require "speech_gale"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.GALE = "凯尔"
-- STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE = "是凯尔！"


-- //////////////////////////////////////////////////////////////////////
--                              Conditions
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_BUFF_DESC = {}

STRINGS.GALE_BUFF_DTYPE = {
	BUFF = "增益",
	DEBUFF = "减益",
	PASSIVE = "特质",
	PARASITE = "寄生虫",
}

-- STRINGS.NAMES.CONDITION_SAMPLE = "示例"
-- STRINGS.GALE_BUFF_DESC.CONDITION_SAMPLE = {
-- 	STATIC = "静态文本",
-- 	DYNAMIC = "动态文本",
-- }

STRINGS.NAMES.CONDITION_INBATTLE = "战斗中"
STRINGS.GALE_BUFF_DESC.CONDITION_INBATTLE = {
	STATIC = "处于战斗之中。\n一段时间后脱离战斗。",
	DYNAMIC = "%s正处于战斗之中。\n%d秒后脱离战斗。",
}

-- STRINGS.NAMES.CONDITION_LULLABY = "艾娃的摇篮曲"
-- STRINGS.GALE_BUFF_DESC.CONDITION_LULLABY = {
-- 	STATIC = "提高50%的耐力恢复速度，\n持续1分钟。",
-- 	DYNAMIC = "提高50%%的耐力恢复速度，\n%d秒后移除。",
-- }

STRINGS.NAMES.CONDITION_POWER = "力量"
STRINGS.GALE_BUFF_DESC.CONDITION_POWER = {
	STATIC = "每层使造成的伤害增加5%。\n脱离战斗后移除所有{CONDITION_POWER}。",
	DYNAMIC = "造成的伤害增加%d%%。\n脱离战斗后移除所有{CONDITION_POWER}。",
}

STRINGS.NAMES.CONDITION_WOUND = "重伤"
STRINGS.GALE_BUFF_DESC.CONDITION_WOUND = {
	STATIC = "每层使承受的伤害增加5%。\n每12秒减少一层。",
	DYNAMIC = "承受的伤害增加%d%%。\n%d秒后减少一层。",
}

STRINGS.NAMES.CONDITION_IMPAIR = "致残"
STRINGS.GALE_BUFF_DESC.CONDITION_IMPAIR = {
	STATIC = "造成的伤害降低33%。\n每10秒减少一层。",
	DYNAMIC = "造成的伤害降低33%%。\n%d秒后减少一层。",
}

STRINGS.NAMES.CONDITION_BLEED = "出血"
STRINGS.GALE_BUFF_DESC.CONDITION_BLEED = {
	STATIC = "每隔5秒，失去等同于{CONDITION_BLEED}层数的生命值，\n然后{CONDITION_BLEED}层数减半。",
	DYNAMIC = "%d秒后，失去%d点生命值，\n然后{CONDITION_BLEED}层数减半。",
}

STRINGS.NAMES.CONDITION_DREAD = "恐惧"
STRINGS.GALE_BUFF_DESC.CONDITION_DREAD = {
	STATIC = "当恐惧层数达到100层时，%s会死亡。\n每隔1秒移除一层。",
}

STRINGS.NAMES.CONDITION_MENDING = "新陈代谢"
STRINGS.GALE_BUFF_DESC.CONDITION_MENDING = {
	-- STATIC = "每隔5秒，恢复等同于{CONDITION_MENDING}层数的生命值，\n然后移除一层{CONDITION_MENDING}。",
	-- DYNAMIC = "%d秒后，恢复等同于{CONDITION_MENDING}层数的生命值，\n然后移除一层{CONDITION_MENDING}。",
	STATIC = "受伤状态下，自动消耗{CONDITION_MENDING}层数来恢复生命值。\n{CONDITION_MENDING}也会每隔12秒自然衰减一层。",
	DYNAMIC = "受伤状态下，自动消耗{CONDITION_MENDING}层数来恢复生命值。\n%d秒后自然衰减一层。",
}

STRINGS.NAMES.CONDITION_METALLIC = "金属"
STRINGS.GALE_BUFF_DESC.CONDITION_METALLIC = {
	STATIC = "免疫{CONDITION_BLEED}与{CONDITION_WOUND}，\n但是受到的爆炸伤害翻倍。",
}

STRINGS.NAMES.CONDITION_GALE_BOON = "凯尔的本能"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BOON = {
	STATIC = "战斗开始时，获得等同层数的{CONDITION_POWER}。\n种族恩赐。",
	DYNAMIC = "战斗开始时，获得%d层{CONDITION_POWER}。\n种族恩赐。",
}

STRINGS.NAMES.CONDITION_PHOENOTOPIA_BOON = "不死鸟的本能"
STRINGS.GALE_BUFF_DESC.CONDITION_PHOENOTOPIA_BOON = {
	STATIC = "战斗开始时，获得等同层数的{CONDITION_POWER}。\n种族恩赐。",
	DYNAMIC = "战斗开始时，获得%d层{CONDITION_POWER}。\n种族恩赐。",
}

STRINGS.NAMES.CONDITION_GALE_BLASTER_CHARGE = "充能"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_CHARGE = {
	STATIC = "这把爆能枪的充能舱可以储存充能，充能可以用来发动技能。\n空的充能舱不但会逐渐恢复充能，而且还能为装备者吸收伤害。",
}

STRINGS.NAMES.CONDITION_GALE_BLASTER_SURGE = "过载"
STRINGS.GALE_BUFF_DESC.CONDITION_GALE_BLASTER_SURGE = {
	STATIC = "完全充能后继续获得充能会产生过载，\n每个过载增加这把枪10点最大伤害，过载会逐渐衰减。",
	DYNAMIC = "完全充能后继续获得充能会产生过载，\n每个过载增加这把枪10点最大伤害，过载会逐渐衰减。",
}

STRINGS.NAMES.CONDITION_BLOATED = "肚胀"
STRINGS.GALE_BUFF_DESC.CONDITION_BLOATED = {
	STATIC = "吃下食物后，溢出的饱食度将转为{CONDITION_BLOATED}，降低战斗效率。\n每隔1秒移除一层。",
}

STRINGS.NAMES.CONDITION_STAMINA_RECOVER = "活力"
STRINGS.GALE_BUFF_DESC.CONDITION_STAMINA_RECOVER = {
	STATIC = "耐力恢复速度翻倍，\n每秒移除一层。",
	DYNAMIC = "耐力恢复速度翻倍，\n每秒移除一层。",
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
STRINGS.ACTIONS.GALE_FREE_CHARGE = "蓄力攻击"
STRINGS.ACTIONS.GALE_FREE_SHOOT = "攻击"

STRINGS.ACTIONS.GALE_FLUTE_PLAY = "吹奏"

STRINGS.ACTIONS.GALE_OPEN_PORTAL = "使用"


STRINGS.ACTIONS.CASTAOE.GALE_CROWBAR = "抡锤"
STRINGS.ACTIONS.CASTAOE.GALE_BLASTER_KATASH = "微力扳机"
STRINGS.ACTIONS.CASTAOE.GALE_SKY_STRIKER_BLADE_FIRE = "烈火再燃"
STRINGS.ACTIONS.CASTAOE.ATHETOS_PSYCHOSTATIC_CUTTER = "强袭"
STRINGS.ACTIONS.CASTAOE.GALEBOSS_KATASH_BLADE = "雷电狼球"

STRINGS.ACTIONS.GALE_PUT_ITEM_ON_PRESSURE_PLATE = STRINGS.ACTIONS.DROP

STRINGS.ACTIONS.GALE_LEVER_TRIGGER_LEFT = "往左拉"
STRINGS.ACTIONS.GALE_LEVER_TRIGGER_RIGHT = "往右拉"
STRINGS.ACTIONS.GALE_LEVER_TRIGGER_ZERO = "回到原位"

STRINGS.ACTIONS.GALE_UPDATE_POCKET_BACKPACK = STRINGS.ACTIONS.SEW

STRINGS.ACTIONS.GALE_RESET_JAMMED_BLASTER = "排除故障"

STRINGS.ACTIONS.GALE_LEARN = STRINGS.ACTIONS.TEACH
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.GALE_LEARN = STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.TEACH

STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.GIVE.MUSHROOMFARM_NOATHETOSCAPALLOWED = "这种蘑菇不适应这里的环境。"

STRINGS.ACTIONS.GALE_TALKTO = "交谈"

STRINGS.ACTIONS.GALE_DISSECT = "解剖"

STRINGS.ACTIONS.GALE_READ_PAPER = "阅读"
-- //////////////////////////////////////////////////////////////////////
--                              Entities
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_ITEM_DESC = {}

STRINGS.NAMES.GALE_FLUTE = "衔尾蛇之笛"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FLUTE = "好像是衔尾蛇盗贼团的王子送给我的。"
STRINGS.GALE_ITEM_DESC.GALE_FLUTE = {
	SIMPLE = "使用后能自由吹奏音符的笛子。",
	COMPLEX = "从曾经属于衔尾蛇的人那里得到的笛子。\n使用时，按攻击键可以吹奏音符，按方向键能改变音调。\n按下动作键或者取消键就可以停止吹奏。\n若是在特殊的地方吹奏，也许就会发生什么好事。",
}

STRINGS.NAMES.GALE_FLUTE_DUPLICATE = "仿制的笛子"
STRINGS.RECIPE_DESC.GALE_FLUTE_DUPLICATE = "居然把笛子扔掉，太过分了..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FLUTE_DUPLICATE = "只是复制品。"
STRINGS.GALE_ITEM_DESC.GALE_FLUTE_DUPLICATE = {
	SIMPLE = "使用后能自由吹奏音符的笛子。",
	COMPLEX = "凯尔按照衔尾蛇之笛的模样制作的笛子。\n使用时，按攻击键可以吹奏音符，按方向键能改变音调。\n按下动作键或者取消键就可以停止吹奏。\n若是在特殊的地方吹奏，也许就会发生什么好事。",
}

STRINGS.NAMES.GALE_CROWBAR = "凯尔的撬棍"
STRINGS.RECIPE_DESC.GALE_CROWBAR = "威力无穷的应急铁棒。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CROWBAR = "可以拿来打棒球！"
STRINGS.GALE_ITEM_DESC.GALE_CROWBAR = {
	SIMPLE = "威力无穷的应急铁棒。",
	COMPLEX = [[使用废料拼装的临时近战武器，
是凯尔擅长使用的棍棒系武器之一。
能够借此打出多种多样的近身攻击。
战技·抡锤：
长按鼠标右键蓄力后，打出致命的大力挥击，
造成巨量伤害并击退一部分敌人。]],
}

STRINGS.NAMES.GALE_SPEAR = "音速矛"
STRINGS.RECIPE_DESC.GALE_SPEAR = "强大的投掷用武器。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SPEAR = "让我想起了爬塔的不好回忆..."
STRINGS.GALE_ITEM_DESC.GALE_SPEAR = {
	SIMPLE = "原本是王国科学家托马斯发明的合金长矛。",
	COMPLEX =
	"模仿托马斯在监狱中产生的的创意，自行用废料打制的武器。\n装备后，轻按攻击键或者鼠标右键可以投出短暂具有实体的幻影长矛。\n原本还能插在墙上来踩上去垫脚，\n但是由于饥荒里没有y轴关卡，只好作罢。\n战技·爆裂长枪：\n衔尾蛇族长阿特莉传授的绝招之一，\n长按鼠标右键蓄力后投掷爆裂长枪。\n爆裂长枪会在命中敌人时爆炸，并且只会伤害敌人。",
}

STRINGS.NAMES.GALE_BOMBBOX = "阿达尔的炸弹袋"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMBBOX = "结构简单，但是稳定耐用。"
STRINGS.GALE_ITEM_DESC.GALE_BOMBBOX = {
	SIMPLE = "装着无数炸弹的蛇皮袋。",
	COMPLEX =
	"炸弹匠人阿达尔制作的一袋炸弹，数量多到结档也用不完。\n装备后，轻按攻击键或者鼠标右键可以投出炸弹。\n从此炸弹袋里扔出的炸弹最多只能同时存在2个。\n炸弹会在4秒后爆炸，可能误伤到自己与盟友并摧毁建筑物，要小心！\n战技·远端投掷：\n长按攻击键或者鼠标右键蓄力后松开投掷，炸弹可以被扔得更高更远，\n其最远距离视蓄力时长而定。",
}

STRINGS.NAMES.GALE_BOMBBOX_DUPLICATE = "仿制的炸弹袋"
STRINGS.RECIPE_DESC.GALE_BOMBBOX_DUPLICATE = "如果把炸弹袋弄丢的话..."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMBBOX_DUPLICATE = "感觉不如阿达尔大叔做的好。"
STRINGS.GALE_ITEM_DESC.GALE_BOMBBOX_DUPLICATE = {
	SIMPLE = "装着无数炸弹的蛇皮袋。",
	COMPLEX =
	"凯尔自己制作的一袋炸弹，数量多到结档也用不完。\n装备后，轻按攻击键或者鼠标右键可以投出炸弹。\n从此炸弹袋里扔出的炸弹最多只能同时存在2个。\n炸弹会在4秒后爆炸，可能误伤到自己与盟友并摧毁建筑物，要小心！\n战技·远端投掷：\n长按攻击键或者鼠标右键蓄力后松开投掷，炸弹可以被扔得更高更远，\n其最远距离视蓄力时长而定。",
}


STRINGS.NAMES.GALE_BOMB_PROJECTILE = "点燃的炸弹"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BOMB_PROJECTILE = "fuss-fuss~~~~"
STRINGS.GALE_ITEM_DESC.GALE_BOMB_PROJECTILE = {
	SIMPLE = "一颗已经点燃的炸弹，随时有可能爆炸！",
	COMPLEX = "您还有闲工夫看详细说明吗？！！！快把它扔掉！！！",
}

STRINGS.NAMES.GALE_COOKPOT_ITEM = "古董烹饪锅"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_COOKPOT_ITEM = {
	GENERIC = "只是一口锅而已。",
	COOKING_SHORT = "快好了！",
	EMPTY = "我想吃点东西。",
}
STRINGS.GALE_ITEM_DESC.GALE_COOKPOT_ITEM = {
	SIMPLE = "古董商人赠送的锅。",
	COMPLEX =
	"历经数代厨师传承的古董铸铁锅。\n数十年的使用让它有了天然的不沾涂层，\n能够提高烹饪后食物的产量。\n放入食材后点击烹饪按钮开始烹饪游戏，在箭头到达中央时按下对应方向键。\n如果能成功通过QTE游戏，就可以收获食物。",
}

STRINGS.NAMES.GALE_COOKPOT_ITEM_DUPLICATE = "现代烹饪锅"
STRINGS.RECIPE_DESC.GALE_COOKPOT_ITEM_DUPLICATE = "怎么会有人把锅给烧了啊！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_COOKPOT_ITEM_DUPLICATE = deepcopy(STRINGS.CHARACTERS.GENERIC.DESCRIBE
	.GALE_COOKPOT_ITEM)
STRINGS.GALE_ITEM_DESC.GALE_COOKPOT_ITEM_DUPLICATE = {
	SIMPLE = "自己制作的锅。",
	COMPLEX = "使用现代技术制作的烹饪锅。\n内置有不沾涂层，能够提高烹饪后食物的产量。\n放入食材后点击烹饪按钮开始烹饪游戏，在箭头到达中央时按下对应方向键。\n如果能成功通过QTE游戏，就可以收获食物。",
}

STRINGS.NAMES.GALE_BLASTER_KATASH = "科伯特爆能枪"
STRINGS.RECIPE_DESC.GALE_BLASTER_KATASH = "科伯特佣兵的制式武器。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_BLASTER_KATASH = "科伯特的战士绝不会放跑猎物。"
STRINGS.GALE_ITEM_DESC.GALE_BLASTER_KATASH = {
	SIMPLE = "外星科技爆能枪。",
	COMPLEX =
	"被称作宇宙佣兵的科伯特一族，其战士配备的光束枪。\n能够根据需要发射不稳定霰弹或高爆飞弹。\n独特的充能弹仓设计，使这把枪攻守兼备。\n战技·微力扳机：\n花费最多2充能，发射强力能量弹。\n花费的充能越多，能量弹的伤害越高。",
}

STRINGS.NAMES.GALE_LAMP = "手摇提灯"
STRINGS.RECIPE_DESC.GALE_LAMP = "曲柄驱动的便携式发光提灯。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_LAMP = "放在身上就会发光。"
STRINGS.GALE_ITEM_DESC.GALE_LAMP = {
	SIMPLE = "曲柄驱动的便携式发光提灯。",
	COMPLEX = "可以通过转动曲柄来提供电能的提灯，\n右键提灯打开面板，鼠标按住并转动曲柄即可使用，\n其中，顺时针转动可以使提灯发光，\n逆时针转动则会使提灯快速熄灭。",
}

STRINGS.NAMES.GALE_FRAN_DOOR = "传送器"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_FRAN_DOOR = "好想念芙兰博士啊。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FRAN_DOOR = "就像百慕大三角一样，真神奇！"

STRINGS.NAMES.GALE_FRAN_DOOR_ITEM = "传送器套件"
STRINGS.RECIPE_DESC.GALE_FRAN_DOOR_ITEM = "复现古代人类传送科技的产物。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FRAN_DOOR_ITEM = "我可以用这个搭建一座传送器！"
STRINGS.GALE_ITEM_DESC.GALE_FRAN_DOOR_ITEM = {
	SIMPLE = "可用于部署传送器。",
	COMPLEX =
	"据说是阿瑟托斯博士最得意的发明，\n曾经在古人类社会大放光彩的传送器。\n现在的人们称此物为“芙兰之门”。\n可以通过鼠标右键部署传送器，部署多个后可执行远程传送。\n传送器技术为阿瑟托斯博士带来了巨量的财富与名誉，\n阿瑟托斯工业就此诞生。",
}


-- Athetos
STRINGS.NAMES.GALE_FRAN_DOOR_LV2 = "闅欑晫浼犻\x80侀棬"
STRINGS.RECIPE_DESC.GALE_FRAN_DOOR_LV2 = "鍙\xaf浠ユ墦寮\x80涓栫晫闂寸殑澶ч棬"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_FRAN_DOOR_LV2 = "这是····什么东西？"

STRINGS.NAMES.GALEBOSS_ERRORBOT = "故障的魔像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_ERRORBOT = "我要修好你！"

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE = "巨龙捕食者"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE = "真漂亮。"

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE_MOVING_TENTACLE = "巨龙捕食者的触手"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE_MOVING_TENTACLE = "黏糊糊的。"

STRINGS.NAMES.GALEBOSS_DRAGON_SNARE_BABYPLANT = "巨龙捕食者幼体"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_DRAGON_SNARE_BABYPLANT = "它真的很能吃。"

STRINGS.NAMES.GALEBOSS_RUINFORCE = "合金装备·泽克"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_RUINFORCE = {
	PHASE_1 = "看起来像是某种古代的机械魔像。",
	PHASE_1_DEAD = "结束了吗？",
	PHASE_2 = "这不科学！",
	PHASE_2_DEAD = "可别再活过来了！",
}

STRINGS.NAMES.GALEBOSS_RUINFORCE_CORE = "泽克的魔像核心"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_RUINFORCE_CORE = "有黑色的液体从里面流出来，不是油..."
STRINGS.GALE_ITEM_DESC.GALEBOSS_RUINFORCE_CORE = {
	SIMPLE = "受污染的高等魔像核心。",
	COMPLEX =
	"古代帝国的核武载具——泽克的魔像核心。\n一件遭到乙太侵蚀的畸形物品。\n交给猪王后能获得许多金块，\n也可以通过精炼取出它的力量。\n据说阿瑟托斯工业的某位股东对泽克甚是感兴趣，\n他将泽克的残骸秘密储存在地底宝库中。\n接着慢慢地，残骸开始转变。",
}


STRINGS.NAMES.GALE_SKY_STRIKER_BLADE_FIRE = "烈火大刀"
STRINGS.RECIPE_DESC.GALE_SKY_STRIKER_BLADE_FIRE = "修复的古代武器，能够释放火焰攻击。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SKY_STRIKER_BLADE_FIRE = "能从中感受到某人的意志。"
STRINGS.GALE_ITEM_DESC.GALE_SKY_STRIKER_BLADE_FIRE = {
	SIMPLE = "修复的古代武器，能够释放火焰攻击。",
	COMPLEX =
	"受好友之托，前去摧毁泽克的战士使用的武器。\n据说她在向泽克发起致命一击后，便凄惨死去，\n成为焦土大陆上无名尸体中的一员。\n不归女战士与泽克的故事因此成为佳话，\n为上流人士所津津乐道。\n战技•烈火再燃：\n暂时重现大刀曾经辉煌的模样，\n向目标位置发起冲刺。\n如果释放时至少拥有3力量，\n会顺势在目标地点引发吹飞敌人的爆炎。",
}

STRINGS.NAMES.GALE_POCKET_BACKPACK = "GEO背包"
-- STRINGS.RECIPE_DESC.GALE_POCKET_BACKPACK = "？？？"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_POCKET_BACKPACK = "我自己缝的！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_POCKET_BACKPACK = "针线功夫不错！"
STRINGS.GALE_ITEM_DESC.GALE_POCKET_BACKPACK = {
	SIMPLE_1 = "用破损的GEO夹克缝合的背包，\n上面有几个口袋用来存放物品。",
	SIMPLE_2 = "用破损的GEO夹克缝合的背包，\n上面有一些口袋用来存放物品。",
	SIMPLE_3 = "用破损的GEO夹克缝合的背包，\n上面有好多口袋！",

	COMPLEX = "凯尔的GEO夹克在穿越裂隙时被撕碎，\n这背包正是用夹克的碎片缝成。\n上面的口袋可以存放物品，\n倘若用缝纫包缝上更多口袋，可存放的物品数量就会增加。\nGEO夹克是优秀的防具，因此该背包也具有一定的减伤率。",
}

STRINGS.NAMES.GALE_SKILL_HONEYBEE_TOKEN = "凯尔衍生物"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SKILL_HONEYBEE_TOKEN = "大概可以拿她去凑LINK值..."

STRINGS.NAMES.GALE_HOUSE_DOOR = "门"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_HOUSE_DOOR = {
	GENERIC = "一扇门！",
	LOCKED_BY_KEY = "锁住了！需要钥匙才能打开。",
	LOCKED_BY_KEYCARD = "锁住了！需要门卡才能打开。",
	CANT_OPEN = "根本打不开。",
}

STRINGS.NAMES.GALE_LEVER_WOOD = "拉杆"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_LEVER_WOOD = "使劲拉！"

STRINGS.NAMES.GALE_SPEAR_TRAP = "雷矛 D-45"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_SPEAR_TRAP = "十分危险的穿刺陷阱。"

STRINGS.NAMES.ATHETOS_REVEALED_TREASURE = "储物柜-拟态型"
-- STRINGS.RECIPE_DESC.ATHETOS_REVEALED_TREASURE = "十分科学的物品藏匿点。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_REVEALED_TREASURE = "想玩捉迷藏吗？"

STRINGS.NAMES.MSF_SILENCER_PISTOL = "灭音手枪"
STRINGS.RECIPE_DESC.MSF_SILENCER_PISTOL = "射击时不会发出声响。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_SILENCER_PISTOL = "射击时会发出biubiubiu的声音。"
STRINGS.GALE_ITEM_DESC.MSF_SILENCER_PISTOL = {
	SIMPLE = "无国界之军生产的PPN-17手枪，具有内建消音器。",
	COMPLEX =
	"阿瑟托斯与无国界之军合作后，对方提供的手枪。\n这种手枪快速轻巧又安静，能造成足够伤害，\n且即便是未受训练的人士也能立刻上手。\n然而，由于结构较为精密，在恶劣环境下使用容易卡壳。\n卡壳时右键单击手枪可以解除故障。",
}

STRINGS.NAMES.MSF_CLIP_PISTOL = "手枪弹匣"
STRINGS.RECIPE_DESC.MSF_CLIP_PISTOL = "双排手枪弹匣，能容纳14发子弹。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_CLIP_PISTOL = "用着还算合适。"
STRINGS.GALE_ITEM_DESC.MSF_CLIP_PISTOL = {
	SIMPLE = "双排手枪弹匣，能容纳14发子弹。",
	COMPLEX = "双排手枪弹匣，能容纳14发子弹。\n可以填入不同类型的手枪子弹。",
}

STRINGS.NAMES.MSF_AMMO_9MM_PISTOL = "9mm子弹"
STRINGS.RECIPE_DESC.MSF_AMMO_9MM_PISTOL = "可供手枪使用的9mm子弹。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MSF_AMMO_9MM_PISTOL = "太小了吧。"
STRINGS.GALE_ITEM_DESC.MSF_AMMO_9MM_PISTOL = {
	SIMPLE = "可供手枪使用的9mm子弹。",
	COMPLEX = "可供手枪使用的9mm子弹。",
}

STRINGS.NAMES.ATHETOS_NEUROMOD = "人造神经元"
STRINGS.RECIPE_DESC.ATHETOS_NEUROMOD = "跨时代的发明。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_NEUROMOD = "我不想用它..."
STRINGS.GALE_ITEM_DESC.ATHETOS_NEUROMOD = {
	SIMPLE = "用于灵能技能学习的材料。",
	COMPLEX =
	"菲娅博士研发的具有跨时代意义的物品。\n借由植入人工合成的神经元，\n受试者能掌握远超人类想象的技能。\n由于合成速度快，被广泛应用于超能圣者的培育之中。\n人造神经元的生产制程十分稀少，\n据说大多数是来自心灵电子所。",
}

STRINGS.NAMES.ATHETOS_MEDKIT_SMALL = "医疗胶(小瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_SMALL = "具有自动诊断功能的医疗包，能够恢复少量生命值。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_SMALL = "好像饮料。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_SMALL = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复少量生命值。",
	COMPLEX = "具有自动诊断功能的医疗包，能够恢复少量生命值。",
}

STRINGS.NAMES.ATHETOS_MEDKIT_MID = "医疗胶(中瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_MID = "具有自动诊断功能的医疗包，能够恢复中等生命值。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_MID = "好像饮料。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_MID = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复中等生命值。",
	COMPLEX = "具有自动诊断功能的医疗包，能够恢复中等生命值。",
}

STRINGS.NAMES.ATHETOS_MEDKIT_BIG = "医疗胶(大瓶)"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG = "具有自动诊断功能的医疗包，能够恢复大量生命值。"
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG_PLAN1 = STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG
STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG_PLAN2 = STRINGS.RECIPE_DESC.ATHETOS_MEDKIT_BIG
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_BIG = "好像饮料。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_BIG = {
	SIMPLE = "具有自动诊断功能的医疗包，能够恢复大量生命值。",
	COMPLEX = "具有自动诊断功能的医疗包，能够恢复大量生命值。",
}

STRINGS.NAMES.ATHETOS_MEDKIT_BIG_OPERATOR = "医疗胶(大瓶)"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MEDKIT_BIG_OPERATOR = "好像饮料。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MEDKIT_BIG_OPERATOR = {
	SIMPLE = "医疗无人机使用的医疗包，能够恢复大量生命值。",
	COMPLEX = "具有自动诊断功能的医疗包，能够恢复大量生命值。",
}

STRINGS.NAMES.ATHETOS_HEALTH_UPGRADE_NODE = "生命节点"
STRINGS.RECIPE_DESC.ATHETOS_HEALTH_UPGRADE_NODE = "主要成分为红宝石与纳米机器人。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_HEALTH_UPGRADE_NODE = "一闪一闪的。"
STRINGS.GALE_ITEM_DESC.ATHETOS_HEALTH_UPGRADE_NODE = {
	SIMPLE = "回复生命值，增加生命值上限。",
	COMPLEX =
	"\n将心形红宝石碾碎，注入纳米机器人所制成的宝珠。\n阿瑟托斯曾使用这些宝珠，增强他的超能圣者们。\n使用时，借由与纳米机器人融合，能立刻恢复大量生命值。\n若使用者资质足够，还能增加生命值上限。\n心形红宝石是从地球带来的，十分珍贵的资源，\n因此普通职员用上生命节点的机会少之又少。",
}

STRINGS.NAMES.ATHETOS_FERTILIZER = "肥料袋"
STRINGS.RECIPE_DESC.ATHETOS_FERTILIZER = "用于培育超级蘑菇！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_FERTILIZER = "营养丰富。"
STRINGS.GALE_ITEM_DESC.ATHETOS_FERTILIZER = {
	SIMPLE = "对普通蘑菇使用，可以将其转化为超级蘑菇。",
	COMPLEX = "菲娅博士培育蘑菇时所用的超级配方。\n对普通蘑菇使用，可以将其转化为超级蘑菇。\n也可以使其他作物快速生长。\n能有如此功效，是在成份上下了功夫。",
}

STRINGS.NAMES.ATHETOS_MUSHROOM = "超级蘑菇"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM = {
	GENERIC = "看起来和普通蘑菇不太一样。",
	GROW_TOO_FAST = "他看起来病恹恹的",
}



STRINGS.NAMES.ATHETOS_MUSHROOM_CAP = "采摘的超级蘑菇"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM_CAP = "看起来和普通蘑菇不太一样。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MUSHROOM_CAP = {
	SIMPLE = "学习技能所需的材料。",
	COMPLEX = "菲娅博士培育的转基因蘑菇，\n具有延展思维的功效，\n使用后，可以迅速学习各种技能。\n阿瑟托斯借助此物培养超能圣者，对抗风暴恶魔。\n但该蘑菇有一大缺点，就是培育周期太长。",
}

STRINGS.NAMES.ATHETOS_MUSHROOM_CAP_DIRTY = "发育不完全的超级蘑菇"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MUSHROOM_CAP_DIRTY = "闻起来有一股腐臭味。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MUSHROOM_CAP_DIRTY = {
	SIMPLE = "毫无用处的垃圾。",
	COMPLEX = "使用某些方法强行催熟长出的蘑菇。\n过不了多长时间就会腐烂，\n是一文不值、没有任何用处的残次品。\n超级蘑菇的速生改造以失败做结，\n为了更加快速地扩充战斗力量，\n菲娅博士不得不另寻他法。",
}

STRINGS.NAMES.ATHETOS_PRODUCTION_PROCESS = "生产制程"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_PRODUCTION_PROCESS = "科学啊！"
STRINGS.GALE_ITEM_DESC.ATHETOS_PRODUCTION_PROCESS = {
	COMPLEX = "使用后能学习物品配方，可以重复使用。",
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


STRINGS.NAMES.ATHETOS_ZOPHIEL_STATUE                            = "佐菲尔雕像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_ZOPHIEL_STATUE      = "在雕像旁边，我能感受到一丝温暖。"
STRINGS.CHARACTERS.GALE.DESCRIBE.ATHETOS_ZOPHIEL_STATUE         = "村里的人认为她会给我们带来好运！"

STRINGS.NAMES.ATHETOS_PORTABLE_TURRET                           = "毁灭者炮塔"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_PORTABLE_TURRET     = "这些嘀嘀咕咕的炮塔对我们帮助很小。"
STRINGS.CHARACTERS.GALE.DESCRIBE.ATHETOS_PORTABLE_TURRET        = "和焦土大陆上的那些有些不一样。"

STRINGS.NAMES.ATHETOS_PORTABLE_TURRET_ITEM                      = STRINGS.NAMES.ATHETOS_PORTABLE_TURRET
STRINGS.RECIPE_DESC.ATHETOS_PORTABLE_TURRET_ITEM                = "脆弱但易于部署的行动炮塔。"
STRINGS.GALE_ITEM_DESC.ATHETOS_PORTABLE_TURRET_ITEM             = {
	SIMPLE = "阿瑟托斯工业沦陷前的最后一道防线。",
	COMPLEX =
	"为了机动性而牺牲防御性能的激光炮塔。\n会自动侦测敌人，并以较快速度向其发射激光。\n由于配备有心灵探测器，也能识别出风暴恶魔。\n将此物体拖动到合适的地点，鼠标右键部署炮塔。\n对已经部署的炮塔，也可以通过鼠标右键回收。",
}

STRINGS.NAMES.ATHETOS_PSYCHOSTATIC_CUTTER                       = "心灵静滞刀"
STRINGS.RECIPE_DESC.ATHETOS_PSYCHOSTATIC_CUTTER                 = "有违道德伦理的武器，能造成心灵伤害。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_PSYCHOSTATIC_CUTTER = "这把武器让我感到不安。"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ATHETOS_PSYCHOSTATIC_CUTTER = "到底是谁发明它的？肯定不是我，也不是查理！"
STRINGS.GALE_ITEM_DESC.ATHETOS_PSYCHOSTATIC_CUTTER              = {
	SIMPLE = "有违道德伦理的武器，能造成心灵伤害。",
	COMPLEX =
	"刀柄内镶嵌有脑组织的武器。\n脑组织取自活生生的不死鸟失败克隆体，\n由此产生的刀刃能造成心灵伤害。\n心灵伤害无视护甲防御，但对上没有心智的敌人时，效果不佳。\n阿瑟托斯为了破解不死鸟的基因锁，\n不分昼夜地开展克隆实验，\n此武器大概是他逐渐失去理智的证明。\n战技·强袭：\n猛力挥动武器，射出光束。\n光束是由心灵力量组成的，因此可以穿透障碍和敌人。",
}

STRINGS.NAMES.ATHETOS_MAGIC_POTION                              = "灵能兴奋剂"
STRINGS.RECIPE_DESC.ATHETOS_MAGIC_POTION                        = "精神兴奋剂，注射后可以恢复生命，精神以及灵能值。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_MAGIC_POTION        = "我觉得里面就是蓝蘑菇汁。"
STRINGS.GALE_ITEM_DESC.ATHETOS_MAGIC_POTION                     = {
	SIMPLE = "可以恢复生命，精神以及灵能值。",
	COMPLEX = "心灵电子所生产的一种精神兴奋剂，\n注射后可以恢复生命，精神以及灵能值。\n虽然普通人也能使用,\n但只有注射过人造神经元的超能圣者才懂得它真正的价值。",
}

STRINGS.NAMES.TYPHON_MIMIC                                      = "拟态"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_MIMIC                = "跑的真快！"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TYPHON_MIMIC                = "我没有料到他们已经演化出了这种形态。"

STRINGS.NAMES.TYPHON_PHANTOM                                    = "幻影"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_PHANTOM              = "你还好吗？"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TYPHON_PHANTOM              = "步了他们的后尘。"

STRINGS.NAMES.TYPHON_CYSTOID                                    = "囊状体"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_CYSTOID              = "随时有可能爆炸。"

STRINGS.NAMES.TYPHON_WEAVER                                     = "编织魔"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_WEAVER               = "光是盯着它就让我眼花缭乱。"

STRINGS.NAMES.ATHETOS_OPERATOR_CORRUPT                          = "(被腐化)"

STRINGS.NAMES.ATHETOS_OPERATOR_MEDICAL                          = "医疗无人机"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_OPERATOR_MEDICAL    = "无人机，敬请见证。"

STRINGS.NAMES.GALEBOSS_KATASH                                   = "科伯特的卡塔什"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH             = "是狼人？还是狗头人？"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALEBOSS_KATASH                = "很爱吃狗狗饼干的外星人。"

STRINGS.NAMES.GALEBOSS_KATASH_2                                 = "科伯特的卡塔什（心智遭受控制）"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_2           = "是狼人？还是狗头人？"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALEBOSS_KATASH_2              = "很爱吃狗狗饼干的外星人。"

STRINGS.NAMES.TYPHON_MIMIC_CANCER                               = "拟态瘤"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_MIMIC_CANCER         = "脏兮兮的一团。"
STRINGS.GALE_ITEM_DESC.TYPHON_MIMIC_CANCER                      = {
	SIMPLE = "从拟态的尸体上找到的肿瘤。",
	COMPLEX =
	"从拟态的尸体上找到的肿瘤。\n内部混杂着一些随机物质，可能是拟态变形的副作用。\n通过解剖，可能获得以下物品：\n    ·噩梦燃料\n    ·纯粹恐惧\n除此之外，还可以获得草、树枝、木头等基础物资。\n可爱娇小的拟态，是一切风暴恶魔的起点。\n据说它们的荚孢会在不同位面中穿行，\n为至高无上的“他”寻找可供吞噬的世界。",
}

STRINGS.NAMES.TYPHON_PHANTOM_ORGAN                              = "风暴恶魔类人器官"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TYPHON_PHANTOM_ORGAN        = "这是····肝脏吗？"
STRINGS.GALE_ITEM_DESC.TYPHON_PHANTOM_ORGAN                     = {
	SIMPLE = "从幻影的尸体上找到的器官。",
	COMPLEX =
	"从幻影的尸体上找到的器官，\n被覆着腹膜，依稀能够辨认出人类的痕迹。\n通过解剖，可能获得以下物品：\n    ·噩梦燃料\n    ·纯粹恐惧\n据说大多数幻影曾是阿瑟托斯工业的员工，\n他们研究乙太物质，最后犯下大错，\n佝偻的模样便是后果。",
}

STRINGS.NAMES.GALEBOSS_KATASH_BLADE                             = "科伯特动力剑"
STRINGS.RECIPE_DESC.GALEBOSS_KATASH_BLADE                       = "科伯特佣兵狩猎时可能会使用。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_BLADE       = "偶尔用用外星人的武器也不错。"
STRINGS.GALE_ITEM_DESC.GALEBOSS_KATASH_BLADE                    = {
	SIMPLE = "科伯特首领持有的动力剑。能够电晕敌人。",
	COMPLEX =
	"科伯特的首领才有资格佩戴的动力剑，拥有电属性攻击力。\n能够将敌人电至眩晕，然后趁虚而入，发动卑鄙偷袭。\n是与卡塔什作风十分相符的武器。\n战技·雷电狼球：\n效仿科伯特祖先狩猎姿态的战技。\n能发出狼嚎，缠绕电浆向前滚动。\n滚动会持续10秒，期间可以通过方向键稍微改变方向。",
}

STRINGS.NAMES.ATHETOS_IRON_SLUG                                 = "潮虫"
STRINGS.RECIPE_DESC.ATHETOS_IRON_SLUG                           = "战后修缮工作中可以使用的魔像。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATHETOS_IRON_SLUG           = "铁皮毛毛虫，咕泳蛄蛹。"
STRINGS.GALE_ITEM_DESC.ATHETOS_IRON_SLUG                        = {
	SIMPLE = "形似毛毛虫的奇怪魔像，十分坚固。",
	COMPLEX =
	"过去由阿瑟托斯工业研发，\n可用于战后修缮工作的魔像。\n侧面开有孔，能吸入空气，排出肥料。\n此举也可以净化有毒气体。\n阿瑟托斯工业的员工大多是难民，\n他们曾对地球抱有幻想：\n战争会在有生之年结束，\n届时大家可以重建家园。",
}

STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_1                        = "卡塔什日志 其一"
STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_2                        = "卡塔什日志 其二"
STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_3                        = "卡塔什日志 其三"
STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_4                        = "亲切问候"

STRINGS.NAMES.GALEBOSS_KATASH_SPACESHIP                         = "坠毁的飞船"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_SPACESHIP   = "它与哈姆雷特的热气球有着异曲同工之妙！"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALEBOSS_KATASH_SPACESHIP      = "我认识这个飞船！它属于科伯特的卡塔什！"

STRINGS.NAMES.GALEBOSS_KATASH_SAFEBOX                           = "卡塔什的保险箱"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_SAFEBOX     = {
	GENERIC = "里面藏着什么东西呢？",
	LOCKED = "它锁住了，也许能把它砸开？",
}

STRINGS.NAMES.GALEBOSS_KATASH_FIREPIT                           = "废料火堆"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_FIREPIT     = "里面满是铁屑。"

STRINGS.NAMES.GALE_PUNCHINGBAG                                  = "意图明显的拳击袋"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_PUNCHINGBAG            = "它不怎么像我。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_PUNCHINGBAG               = "制作它的人应该非常不喜欢我。"

STRINGS.NAMES.GALEBOSS_KATASH_SKYMINE                           = "空雷"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALEBOSS_KATASH_SKYMINE     = "这又是什么机械造物？"
STRINGS.CHARACTERS.WX78.DESCRIBE.GALEBOSS_KATASH_SKYMINE        = "警告：该机器人随时有可能爆炸。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALEBOSS_KATASH_SKYMINE        = "皇宫里有很多这种东西。"

STRINGS.NAMES.GALE_HAMMER                                       = "凯尔的大锤"
STRINGS.RECIPE_DESC.GALE_HAMMER                                 = "能有效地发挥你的蛮力。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_HAMMER                 = "再正常不过的锤子。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_HAMMER                    = "当我的冒险结束后，可以拿它来钉钉子。"
STRINGS.GALE_ITEM_DESC.GALE_HAMMER                              = {
	SIMPLE = "借由蛮力挥舞的大锤。",
	COMPLEX =
	"使用废铁与岩石制造的大型锤。\n除了一般锤子的功能外，也能当做打击武器使用，\n摧毁护甲、击溃盾防御的效果显著。\n大锤是个重蛮力的武器，\n仅在计算伤害时，力量的增益会变成两倍。\n战技·抡锤：\n长按鼠标右键蓄力后，打出致命的大力挥击，\n造成巨量伤害并击退一部分敌人。",
}

STRINGS.NAMES.GALE_MACE                                         = "凯尔的刺锤"
STRINGS.RECIPE_DESC.GALE_MACE                                   = "这件武器来自另一个时代。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_MACE                   = "很明显是用太空陨石打造的。"
STRINGS.GALE_ITEM_DESC.GALE_MACE                                = {
	SIMPLE = "带有神圣力量的刺锤。",
	COMPLEX =
	"战斗用的铁锤。\n以神圣属性的跳跃攻击为特征。\n由于制造时使用了铥矿与月岩，\n武器坚硬、难以损坏，\n造成位面伤害的能力优秀。\n战技·抡锤：\n长按鼠标右键蓄力后，打出致命的大力挥击，\n造成巨量伤害并击退一部分敌人。",
}




STRINGS.NAMES.GALE_TRINKET_RABBIT                          = "兔子模型"
STRINGS.RECIPE_DESC.GALE_TRINKET_RABBIT                    = "加洛普喜欢兔子！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_TRINKET_RABBIT    = "我们世界的兔子和这里的不一样。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_TRINKET_RABBIT       = "我好怀念在普林斯汀城的时光。"
STRINGS.CHARACTERS.GALLOP.DESCRIBE.GALE_TRINKET_RABBIT     = "我要在我的被窝里放满兔子。"
STRINGS.GALE_ITEM_DESC.GALE_TRINKET_RABBIT                 = {
	SIMPLE = "模仿兔子制作的模型。",
	COMPLEX = "模仿兔子制作的模型。\n因为有点过于光滑，所以一眼就能看出是假的。\n富有弹性，手感相当好的小孩玩具。\n据说是加洛普的最爱。",
}

STRINGS.NAMES.GALE_TRINKET_DUCK                            = "橡皮鸭"
STRINGS.RECIPE_DESC.GALE_TRINKET_DUCK                      = "嘎嘎嘎。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_TRINKET_DUCK      = "泡澡必备用品。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_TRINKET_DUCK         = "亚泰的射击场里就有一个！"
STRINGS.GALE_ITEM_DESC.GALE_TRINKET_DUCK                   = {
	SIMPLE = "用橡胶素材制作的可爱小鸭子玩具。",
	COMPLEX = "用橡胶素材制作的可爱小鸭子玩具。\n用力捏就会发出叫声。\n能够消除遭受电击时造成的麻痹状态，一次性使用。",
}

STRINGS.NAMES.GALE_DURI_FLOWER                             = "心跳香草"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_DURI_FLOWER       = "闻起来像薄荷。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_DURI_FLOWER          = "高墙的厨师曾经用这个调味来着。"

STRINGS.NAMES.GALE_DURI_FLOWER_PETAL                       = "心跳香草"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_DURI_FLOWER_PETAL = "闻起来像薄荷。"
STRINGS.CHARACTERS.GALE.DESCRIBE.GALE_DURI_FLOWER_PETAL    = "高墙的厨师曾经用这个调味来着。"
STRINGS.GALE_ITEM_DESC.GALE_DURI_FLOWER_PETAL              = {
	SIMPLE = "可用于调味的食材。",
	COMPLEX = "散发着薄荷清香的药草。\n主要用于给炖菜等料理调味，\n也能直接生吃。",
}



-- Foods are below...


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

STRINGS.NAMES.GALE_CKPTFOOD_HONEY_DROP = "蜂蜜甘露"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_HONEY_DROP = "香甜美味到令人惊讶！"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_HONEY_DROP = {
	COMPLEX = "将香甜的花蜜浓缩制作而成的蜂蜜糖果。\n能够轻松恢复耐力。",
}

STRINGS.NAMES.GALE_CKPTFOOD_DOG_COOKIE = "狗狗饼干"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GALE_CKPTFOOD_DOG_COOKIE = "喂给狗狗吃应该不错。"
STRINGS.GALE_ITEM_DESC.GALE_CKPTFOOD_DOG_COOKIE = {
	COMPLEX = "用怪物肉、油脂或者其他填充物调制而成的狗粮。\n又硬又脆，拥有预防犬类蛀牙的功效，还能让口气变得清新。\n因为实在太硬，所以不适合人类食用。",
}


-- //////////////////////////////////////////////////////////////////////
--                              Scrapbook Data
-- //////////////////////////////////////////////////////////////////////

STRINGS.NAMES.TEST_NOTE = "标题"
STRINGS.SCRAPBOOK.SPECIALINFO.TEST_NOTE = "啊哈哈啊撒撒撒撒撒撒撒撒\n安慰对方把无法把握不哈玩法\n放醋无法把无法把务必发我\n阿达瓦大无大无大无大无。"


-- //////////////////////////////////////////////////////////////////////
--                              Name Pool
-- //////////////////////////////////////////////////////////////////////
STRINGS.NAMES.GALE_NAMEPOOL = {}
STRINGS.NAMES.GALE_NAMEPOOL.MECH = {}
-- STRINGS.NAMES.GALE_NAMEPOOL.MECH_SPECIAL = {}
STRINGS.NAMES.GALE_NAMEPOOL.MECH_SPECIAL = {
	-- "仰望卵石",
	-- "五块皓月",
	-- "无稽裂片",
	-- "追逐本能",
	-- "七轮智能",
	-- "无比红日",
	-- "茅草群星",
	-- "申辩烦恼",
	-- "徘徊纯真",
	-- "凝望清风",
	-- "隔绝预兆",
	-- "云雾纪元",

	"仰望卵石",
	"五块皓月",
	"无稽群星",
	"追逐纪元",
	"七轮烦恼",
	"无比林立",
	"茅草新芽",
	"申辩倒影",
	"徘徊砂砾",
	"凝望琉璃",
	"隔绝智能",
	"云雾铁铲",
	"十九而落",
	"无尽之上",
	"四针叶茂",
	"枝繁沉葬",
	"五大清风",
	"先之琥珀",
	"一颗支架",
	"十八本能",
	"六颗铃铛",
	"群峰纯真",
	"两株预兆",
	"十二隙罅",
	"焚空沉浮",
	"十二水滴",
	"陬澨裂片",
	"耕畴念珠",
	"濂珠不睹",
	"玉碎高塔",
	"两瞽红日",
	"八玷之下",
}

local mech_names_prefix = {
	-- 欺诈之地
	"算法", "选项", "希尔达", "二进制", "数组", "波尔", "分支", "千年虫", "字节", "COM.EXE", "编译",
	"控制", "处理器", "驱动器", "枚举器", "错误码", "汇编", "自然语言", "缓存", "格式化", "门",
	"哈希", "函数", "列表", "崩溃", "循环", "矩阵", "内存", "闪存", "数据", "过期", "重启", "处理器",
	"回车", "源代码", "堆栈", "三进制", "一进制", "字符串", "异或门",

	-- 数据类型
	"整形", "浮点数", "队列", "列表", "链表", "容器", "映射", "集合", "迭代器", "结构体", "指针",
	"引用", "常量", "变量", "静态",

	-- 数据操作
	"继承", "回调",

	-- 码语者
	"解码", "编码", "冗码", "转码", "排错", "访问", "防火墙",

	-- 算法相关
	"四元数", "向量", "归并", "递归", "穷举", "遍历", "体素", "栅格", "滤波", "降采样", "三角测量",
	"单应性", "尺度", "八叉树", "二叉树", "正定", "稀疏性", "稠密", "残差", "李群", "李代数",
	"针孔", "鱼眼", "视差", "归一化", "重投影", "顶点", "最速下降", "转秩", "扫描匹配", "权重",
	"回环", "词袋", "里程计", "惯导", "特征点", "描述符", "位姿", "姿态", "万向锁", "欧拉角",
	"正则",

	-- github
	"分支",

	-- 历史上的危机
	"零日",
}

local mech_names_index = {
	"1号", "2号", "3号", "4号", "5号", "6号", "7号", "8号", "9号", "0号",
}

-- local rainworld_mech_names = {
-- 	-- "仰望", "皓月", "五块", "卵石",
-- 	"无稽", "烦恼", "追逐", "清风", "七轮", "红日", "无比", "纯真", "茅草", "裂片",
-- 	"申辩", "智能", "徘徊", "预兆", "凝望", "群星", "隔绝", "本能", "云雾", "纪元",

-- 	"十九", "铁铲", "无尽", "倒影",
-- 	"四针", "之上", "枝繁", "叶茂",
-- 	"五大", "水滴", "先之", "而落",
-- 	"一颗", "铃铛", "十八", "琥珀",
-- 	"六颗", "砂砾", "群峰", "林立",
-- 	"两株", "新芽", "十二", "支架",
-- 	"焚空", "之下", "十二", "念珠",
-- 	"陬澨", "高塔", "耕畴", "隙罅",
-- 	"濂珠", "沉葬", "玉碎", "琉璃",
-- 	"两瞽", "不睹", "八玷", "沉浮",
-- }

-- -- Need to be sure
-- math.randomseed(48309)
-- math.random()

-- local qi_range = math.range(1, #rainworld_mech_names, 2)
-- local ou_range = math.range(2, #rainworld_mech_names, 2)

-- for _, pre_id in pairs(qi_range) do
-- 	local pst_id = table.remove(ou_range, math.random(1, #ou_range))
-- 	table.insert(STRINGS.NAMES.GALE_NAMEPOOL.MECH_SPECIAL, rainworld_mech_names[pre_id] .. rainworld_mech_names[pst_id])
-- end

-- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
-- math.random()



for i, prefix in pairs(mech_names_prefix) do
	for j, index in pairs(mech_names_index) do
		table.insert(STRINGS.NAMES.GALE_NAMEPOOL.MECH, prefix .. index)
	end
end

print(string.format("[GaleMod]Generate %d names for mech", #STRINGS.NAMES.GALE_NAMEPOOL.MECH))
-- //////////////////////////////////////////////////////////////////////
--                              ChattyNodes
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_CHATTYNODES = {}

-- STRINGS.GALE_CHATTYNODES.GALE = {
-- 	FIND_BLASTER_JAMMED = "哎呀，枪卡壳了！",
-- }

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
		"线程退出 应用程序请求....中止I/O操作。",
	},

	RESTORE = {
		"已重载脚本:scripts/brains/galeboss_errorbotbrain.lua",
		"已重载脚本:scripts/prefabs/galeboss_errorbot.lua",
		"已重载脚本:scripts/stategraphs/SGgaleboss_errorbot.lua",
		"LEGO公司0451号“台风”工程勤务机....准备值班。",
		"以自律模式重启系统。",
	},
}

STRINGS.GALE_CHATTYNODES.GALEBOSS_KATASH = {
	PLAYER_HEAL = {
		"上课时不准喝果粒橙！",
		"战斗时禁止吃东西！",
		"好机会！吃我一击！",
		"有破绽！",
		"看我读你指令！",
		"兵不厌诈！",
		"堂堂正正的和我战斗吧！",
	},

	INTRO_GALE = {
		"偷我东西的毛贼居然是你！用棍子的小姑娘！！！",
		"我们新账旧账一起算！",
		-- "接招吧！",
	},

	INTRO_OTHER = {
		"哈哈，逮住你了，你这个毛贼！！！",
		"你以为我的东西是可以随便偷的吗？",
		"我名叫卡塔什。现在我就送你下地狱！",
	},

	INTRO_INTERRUPT = {
		"太着急会死的啊，小鬼。",
	},

	STEAL = {
		"我收下了！",
		"这是我的了！",
		"哈哈哈，你个蠢货！",
	},

	EAT_GOOD = {
		"嘿嘿嘿！我就不客气了！",
		"偷来的东西就是特别美味！",
		"真好吃！还有什么吗？",
	},

	EAT_BAD = {
		"哇！这是啥啊！",
		"呕！恶、恶心死了！",
	},

	ESCAPE = {
		"可恶！还没结束呢！",
		"科伯特的战士绝不会放跑自己的猎物！",
		"咱们走着瞧！",
	},
}

STRINGS.GALE_CHATTYNODES.ATHETOS_PORTABLE_TURRET = {
	REPAIR = {
		"侦测到维修，十分感谢。",
	},

	DEPLOY = {
		"毁灭者自动炮塔版本0.7.6。部署中。",
		"部署协议。初始化。",
		"除错模组程式0.7.6。冗长模式启动。",
	},

	SING = {
		"侦测到孤独...",
		"正在运行消遣程式。",
	},


	IDLE = {
		SELF_DIAGNOSIS = {
			START = "运行自我诊断程序...",

			PART = {
				"激光准线...",
				"伺服电机...",
				"敌我识别装置...",
				"心灵探测器...",
			},


			RESULT = {
				OK = "正常...",
				FAILED = "错误！",
			},
		},


		SIMPLE = {
			"炮塔正在以低功率模式运行。",
			"传感器暂未发现威胁。",
			"滴滴...滴滴...滴滴...",
			"周遭感应器重启。",
			"为了您的安全，请勿直视激光准线。",
			"正在更新数据库。错误：伺服器离线。",
			"已保存运行日志。",
		},
	},

	SCAN = {
		START = "正在扫描目标...",
		RESULT = {
			OK = {
				"侦测不到乙太物质。",
				"未发现异形物质。",
				"受试者通过检查。",
			},
			TYPHON_1 = {
				"目标的乙太物质浓度不足以判定为威胁。",
				"目标的乙太物质读数可能有误，请联系合格工程师。",
				"错误，发现乙太物质不足。准备退出。",
				"乙太物质无法得出结论，正在登入校正请求。",
			},

			TYPHON_2 = "警告。可能有乙太物质污染。监控中。",
		}
	},

	COMBAT = {
		TYPHON_3 = {
			"发现乙太物质污染源！",
			"侦测到异形威胁！",
		},

		THREAT = {
			"发现威胁！",
			"已发现敌人！",
		},
	},

	FIND_FIRELINE_ALLY = "请远离激光准线，避免误伤！",
}

STRINGS.GALE_CHATTYNODES.TYPHON_PHANTOM = {
	ALERT = {
		I_HEAR_YOU = "我听到你了",
		I_WILL_CHECKOUT = "我去检查",
		WHERE_ARE_YOU = "你在哪儿？",
		WHERE_YOU_ARE = "你在哪里？",
		COME_OUT = "出来。",
		SHHH_SOMEONE_IS_COMMING = "嘘...等等。有东西来了。",
		SHHH_THERE_ARE_SOMETHING = "嘘...有东西。",
		BETTER_NOT_BE_ANYTHING = "...最好不要给我有什么东西...",
		SOMETHING_OVER_THERE = "那边有什么东西。",
		WHATS_GOING_ON = "...怎么回事？",
		WHAT_WAS_THAT = "刚刚那是什么？",
	},

	-- New target
	NEW_TARGET = {
		I_SEE = "我知道了",
		I_SEE_YOU = "找到你了",
		THERE_YOU_ARE = "你在这里！",
		WHO_ARE_YOU = "你是谁？",
		ARE_YOU_ALONE = "只有你吗？",
		ANSWER_ME = "回答我",
		GET_AWAY_FROME_ME = "离我远点",
		ARE_YOU_ANGRY = "你在...愤怒吗？",
		YOU_SEEMS_FRUSTRATED = "你好像...很沮丧。",
	},

	LOSE_TARGET = {
		ITS_GONE = "他走了",
		IT_WAS_JUST_HERE = "刚刚还在这里。",
		ITS_VANISHED = "...就这样消失了。",
		I_DIDNT_FIND_ANYTHING = "我什么都没找到...",
	},

	IDLE = {
		I_MUST_HAVE_LOSING_MY_MIND = "我一定是疯了。",
		SOME_KIND_OF_BAD_DREAM = "这一定是场恶梦...",
		WAS_THAT_REALLY_YOU = "那真的是你吗？",
		WHERE_DO_YOU_SUPPOSE = "你觉得它们是从哪来的？",
		YOU_HALF_WAKE = "你有没有曾经半梦半醒...",
		DID_WE_MAKE_THAT = "那是我们的实验室制造出来的吗？",
		BREATHING = "......",
		ASK_ATHETOS = "阿瑟托斯...",
		I_HAVE_BEING_WATCHING_THEM = "我盯着他们几小时了...还是不知道有几个在外面。",

		-- From old IDLE2
		I_CAN_XXX_UNDERSTAND_US = "我本可以让他们理解我们！",
		EVEN_IF_WE_DEAD = "就算我们死了...一切也不会结束。",
		I_USED_TO_WISH = "我曾经希望宇宙不只有人类。",
		THEY_CAN_BE_ANYTHING = "他们可以化为所有东西...所有人。",
		THEY_WANT_TO_LIVE_INSIDE = "他们想寄生在我们体内，就像疾病一样。",
		THE_SHAPE_IN_THE_GLASS = "它长什么样子？那个裂隙里的形体...",
		WAHT_DO_YOU_SEE_IN_THE_GLASS = "你在裂隙里看到什么？",
	},
}

STRINGS.GALE_CHATTYNODES.ATHETOS_OPERATOR_MEDICAL = {
	SEE_PLAYER = {
		HELLO = "你好。",
		ARE_YOU_FEELING = "你感觉还好吗？",
		NICE_TO_SEE = "幸会。",
		WELCOME = "欢迎。需要帮忙的话尽管说。",
		APPOINTMENT = "你有约吗？",
		SEE_YOU_AGAIN = "很高兴再次见到你，%s。",
		PYRAMID = "我是「金字塔」490医疗级无人机。",
	},

	CHAT = {
		MEDICAL_JOKES = "我知道几个医学笑话，但恐怕你不会觉得好“酵”。",
		IMPROVISE = "只要有授权，我还可以在特殊情况下变通发挥。",
		PREVENTION = "大家都听过，预防胜...",
		NUTRITION = "希望你会注意自己的营养和每日运动量。",
		POMEGRANATE = "吃过石榴了吗？",
		BRAIN_USELESS = "你知道古代埃及人认为大脑是个没用的器官吗？",
		PREVENTION2 = "许多生理创伤都是知识不足造成，而知识不足是可以预防的。",
		HEART_THINK = "亚里斯多德相信心脏是人类思考与智慧的中心。",
		HUMAN_CRY = "人类似乎是唯一会哭的动物。",
		BRAIN_BULB = "你的大脑产生的能量跟一个小灯泡差不多，连睡觉的时候也是。",
		MUMIES = "你知道埃及以前会用人类做成的木乃伊当作动力车燃油？",
		MOUTH_BRAIN = "说话前经过大脑就可以改善白目的疾病。",
		BLOOD_SUPPLY = "你知道人体没有补充血液，还可以活上30分钟吗？",
		TRIAL_AND_ERROR = "根据我的设计，我要透过不断尝试来改善对病人的态度。",
		ANATOMY = "所有的解剖学资料与程序档案都是最新版本。",
		ABOUT_EQUIP = "我的装备足以处理超过六千种医疗紧急情况。",
	},


	-- COLLIDE = {
	-- 	WHOOPS = "糟糕。",
	-- 	PARDON_ME = "抱歉。",
	-- 	MY_MISTAKE = "是我不好。",
	-- 	DIDNT_SEE_YOU = "我没看到你。",
	-- },

	DIAGNOSING = "诊断中......",

	DIAG_RESULT_FRACTURE = {
		FRACTURE = "看来你的股骨有斜向骨折的状况。",
		FRACTURE2 = "扫描显示有末端桡骨骨折的情况，左手。双腿的矩腓韧带有部分撕裂伤。",
		FRACTURE3 = "糟糕，你的肋骨裂开了。多处压力式骨折。别担心，我治得好。",
		FRACTURE4 = "隆凸骨折，在左胫骨。右胫骨有粉碎性骨折。",
	},

	DIAG_RESULT_RADIATION = {
		RADIATION = "你受到辐射中毒了。我建议马上进行医疗处置。",
		RADIATION2 = "辐射中毒。细胞退化的程度相当严重。",
		RADIATION3 = "天哪，急性辐射症候群。",
	},

	DIAG_RESULT_BLEED = {
		BLEED = "多处不规则撕裂伤，还有出血。",
		BLEED2 = "拉扯撕裂伤，导致大量出血。建议急速输血。",
		BLEED3 = "你的软身体组织有多处撕裂伤和穿刺伤。",
	},

	DIAG_RESULT_BURN = {
		BURN = "全皮层烧伤。建议进行清创术。执行局部麻醉。",
		BURN2 = "表皮与真皮层受伤......是烫伤。注射10毫升水醇。",
		BURN3 = "三度灼伤。进行伤口清理。施加培养真皮组织。",
	},

	DIAG_RESULT_CONCUSSION = {
		CONCUSSION = "视觉受到干扰。额叶淤伤，绝对是严重脑震荡。",
		CONCUSSION2 = "我懂了，你有脑震荡。我帮你缓解疼痛吧。",
		CONCUSSION3 = "扫描显示头部内出血。",
	},

	DIAG_RESULT_MANY_TRAUMA = "你受到一项以上的严重创伤，最好马上处理。",

	DIAG_RESULT_COMMON = {
		ROUGH_DAY = "看来你今天过得不太顺心。",
		COMMON_ISSUE = "擦伤、磨伤、疲劳，没什麽会威胁生命的。",
		SUPERFICIAL = "表面伤而已，携带式医护包就能处理。",
	},

	HEAL_SUCCESS = {
		TRY_TO_RELAX = "试着放松。",
		BETTER_SOON = "希望你早日康复。",
		WONT_TAKE_LONG = "一下就好了。",
		ALL_BETTER = "好了，好多了。",
		GOOD_AS_NEW = "焕然一新。",
		ALL_DONE = "完成了。",
	},

	HOLD_STILL = "请你不要乱动，一下就好了。",

	AFTER_HEALING = {
		FULLFILL_QUESTIONNAIRE = "请填妥看诊经验问卷，好提升我下次服务的品质。",
		FULLFILL_QUESTIONNAIRE2 = "别忘记填妥病人问卷。你的回答相当宝贵。",
		FULLFILL_QUESTIONNAIRE3 = "你可以在前台填写服务问卷。",
	},

	BIG_BANG_CANDY = "要不要来颗超大糖果？",

	ATTACKED_BY_PLAYER = {
		MY_FAULT = "肯定是我的错。",
		INTEND_TO_DAMAGE = "你想伤害我吗？",
		PLEASE_DONT_HARM = "请别伤害我。",
		REPAIR_SOON = "我很快就会需要修理了。",
		IS_THAT_FUNNY = "很好玩吗？！！",

		WHOOPS = "糟糕。",
		PARDON_ME = "抱歉。",
		MY_MISTAKE = "是我不好。",
	},

	NO_TRAUMA = "没侦测到创伤或疾病。恐怕我帮不了你。",
	-- MEDICAL_TRAVIA = "除非你想听医学冷知识或笑话。",

	CANT_DIAG_CD = "抱歉，我目前没办法为你进行诊断。",
	CANT_DIAG_ENV = "此环境不适合进行诊断。",
	CANT_DIAG_PSY = "恐怕我不能治疗心理疾病。",

	SYSTEM_ALERT = "系统告急！需要维修！请联系合格工程师。",
	ALL_SYSTEM_OPERATIONAL = "全体系统恢复正常！谢谢你！",
}

-- //////////////////////////////////////////////////////////////////////
--                        Other haracter speechs
-- //////////////////////////////////////////////////////////////////////

STRINGS.CHARACTERS.GENERIC.ANNOUNCE_GUN_JAMMED = "哎呀，枪卡壳了！"

-- //////////////////////////////////////////////////////////////////////
--                              Melodies
-- //////////////////////////////////////////////////////////////////////

STRINGS.GALE_MELODIES = {
	NAME = {
		MELODY_OUROBOROS = "衔尾蛇之歌",
		MELODY_GEO = "GEO之歌",
		MELODY_ROYAL = "皇家赞美歌",
		MELODY_PANSELO = "潘瑟罗序曲",
		MELODY_BATTLE = "战斗号令",
		MELODY_PHOENIX = "艾娃的摇篮曲",
	},

	DESC = {
		MELODY_OUROBOROS = "流传于衔尾蛇内部的民谣，\n在衔尾蛇的旋律石前奏响，会发生某些特别的事。",
		MELODY_GEO = "GEO的所有成员都熟知的歌，\n在GEO的旋律石前奏响，\n就能打开通往GEO地下城的大门，接受试炼。",
		MELODY_ROYAL = "王族代代相传的秘密歌谣，\n在画着王家印文章的旋律石前奏响，\n就能打开门扉。",
		MELODY_PANSELO = "对凯尔来说十分熟悉的潘瑟罗印象曲。\n似乎是从村子创立之初就存在的歌曲，\n在村民中代代相传。",
		MELODY_BATTLE = "衔尾蛇的精英士兵用来激励自己的歌曲。\n吹奏后可以增强自己与盟友的力量。\n生效后要间隔6分钟才能再次使用。",
		MELODY_PHOENIX = "温柔的歌谣，能够唤醒沉睡的记忆。\n可以在1分钟内提高凯尔的耐力恢复速度。\n生效后要间隔6分钟才能再次使用。",
	},

	TRIGGER_NORMAL = "吹奏了%s！",

	TEND_TO_PLANTS = "周围%d个农作物因为歌曲的原因变得开心了！",

	TRIGGER_SUCCESS = {
		MELODY_PANSELO = "吹奏了潘瑟罗序曲，凯尔的生命值恢复了99点！",
		MELODY_BATTLE = "吹奏了战斗号令，凯尔及其附近的盟友均获得力量提升！",
		MELODY_PHOENIX = "吹奏了艾娃的摇篮曲，凯尔的耐力恢复速度得到提升！",
	},

	TRIGGER_FAIL = {
		MELODY_PANSELO = "潘瑟罗序曲的生命恢复效果还在冷却中（还剩%d秒）",
		MELODY_BATTLE = "战斗号令的力量提升效果还在冷却中（还剩%d秒）",
		MELODY_PHOENIX = "艾娃的摇篮曲的耐力恢复速度提高效果还在冷却中（还剩%d秒）",
	},

}

-- //////////////////////////////////////////////////////////////////////
--                              UI
-- //////////////////////////////////////////////////////////////////////


STRINGS.GALE_UI = {}

STRINGS.GALE_UI.MENU_CALLER_NAME = "菜单"
STRINGS.GALE_UI.MENU_SUB_SKILL_TREE = "技能"
STRINGS.GALE_UI.MENU_SUB_KEY_CONFIGED = "键位一览"
STRINGS.GALE_UI.MENU_SUB_FLUTE_LIST = "笛子乐谱"
STRINGS.GALE_UI.MENU_SUB_SUPPORT_THEM = "支持他们"

STRINGS.GALE_UI.KEY_SET_UI = {
	TITLE = "设置键位",
	TEXT_BEFORE = "请按下对应的键位后再按确定来完成键位设置。",
	TEXT_AFTER = "当前选的是%s键。您可以点击确定键完成键位设置，或者重新选择按键。",

	DO_SET_SKILL_KEY = "确定",
	CLEAR_SKILL_KEY = "清除按键",
	SET_KEY_CANCEL = "取消",
}

STRINGS.GALE_UI.KEY_CONFIGED_TIP = "%s\n当前按键：%s"
STRINGS.GALE_UI.KEY_CONFIGED_CURRENT_NO_KEY = "未设置"

-- STRINGS.GALE_UI.SKILL_ACTIONS = {
-- 	UNLOCK = "解锁",
-- 	SET_KEY = "设置键位",
-- }

STRINGS.GALE_UI.ANNOUNCE_DUCK_AVOID_ELECTROCUTE = "使用橡皮鸭防止了触电！"

STRINGS.GALE_UI.CONDITION_STACK = "层数"

STRINGS.GALE_UI.SKILL_UNLOCK_PANEL = {
	UNLOCK = "解锁",
	UNLOCKED = "已解锁！",
	SET_KEY = "设置键位",
	CANT_UNLOCK_MISS_INV = "所需材料缺失，无法解锁",
	CANT_UNLOCK_NEED_PRE_SKILL = "尚未掌握前置技能，无法解锁",


}
STRINGS.GALE_UI.SKILL_LOCK_STATUS = {
	UNLOCKED = "（已解锁）",
	CAN_UNLOCK = "（可解锁）",
	CANT_UNLOCK = "（未解锁）",
}
STRINGS.GALE_UI.SKILL_TREE = {
	SURVIVAL = {
		NAME = "生存",
		DESC = "提高身体素质，学习求生知识，利用撬棍解决问题。",
	},
	SCIENCE = {
		NAME = "科学",
		DESC = "善用科学、医学与特化实验设备的知识创造优势。",
	},
	COMBAT = {
		NAME = "战斗",
		DESC = "强化肢体攻击能力、武器熟练度与安全技巧。",
	},
	ENERGY = {
		NAME = "能量",
		DESC = "控制电、火与动力的毁灭力量并善加利用。",
	},
	MORPH = {
		NAME = "变形",
		DESC = "操纵灵性乙太，改变形状欺敌。",
	},
	PSY = {
		NAME = "心电感应",
		DESC = "把心灵当作武器使用，或者操纵远处的科技和物品。",
	},
}

STRINGS.GALE_UI.SKILL_NODES = {
	DOCTOR = {
		NAME = "医学",
		DESC = "增进医疗知识，\n使用治疗类物品时恢复的血量提高50%。",
	},
	DISSECT = {
		NAME = "解刨",
		DESC = "（未实装：解锁此技能暂无任何用处。）",
	},
	BURGER_EATER = {
		NAME = "代谢强化",
		DESC = "提高凯尔的营养吸收能力。\n吃下的食物会促进新陈代谢，\n一段时间内持续恢复生命值。",
	},
	ROLLING = {
		NAME = "滑铲",
		DESC = "向鼠标位置滑铲一小段距离，需要消耗耐力。",
	},
	SHOU_SHEN = {
		NAME = "受身",
		DESC = "处于力竭状态时也可以使用滑铲脱困，同时恢复少量耐力。",
	},

	PARRY = {
		NAME = "巨人防御",
		DESC = "按下技能按键即可向鼠标所指方向格挡，经典技能。",
	},

	ROLLING_BOMB = {
		NAME = "临别赠礼",
		DESC = "（未实装：解锁此技能暂无任何用处。）",
	},
	ROLLING_SMOKE = {
		NAME = "烟雾弹",
		DESC = "（未实装：解锁此技能暂无任何用处。）",
	},

	ANATOMY = {
		NAME = "解剖精通",
		DESC = "解剖风暴恶魔类敌人的组织时，有可能获得更多掉落物。",
	},

	QUICK_CHARGE = {
		NAME = "聚精会神",
		DESC = "提高凯尔蓄力的速度。",
	},

	CARRY_CHARGE = {
		NAME = "内在力量",
		DESC = "在蓄力完成后按空格键可以把蓄力储存起来，留在下一次攻击中使用。",
	},

	ACTIONED_CHARGE = {
		NAME = "动作如潮",
		DESC = "支付少许生命值。下一次可以蓄力的攻击直接变成蓄力攻击，同时恢复耐力值。",
	},

	HARPY_WHIRL = {
		NAME = "回旋强风",
		DESC = "手持撬棍，在蓄力姿态中完成蓄力时，\n再使用滑铲技能会在目标点打出强劲的回旋攻击。",
	},

	SPEAR_FRAGMENT = {
		NAME = "流星碎片",
		DESC = "爆裂长枪的爆炸将产生额外两个碎片，\n呈垂直方向射出。",
	},

	SPEAR_REMAIN = {
		NAME = "倒刺",
		DESC = "使用普通攻击投出的音速矛会钉死在敌人身上，持续伤害敌人。",
	},

	COMBAT_LEAP = {
		NAME = "跳跃攻击",
		DESC = "进行跳跃攻击，造成小范围伤害。能在装备撬棍、锤类武器时使用。",
	},

	KINETIC_BLAST = {
		NAME = "动态爆炸",
		DESC = "释放冲击波，造成大量伤害，并震开周围的物品。需要消耗些许灵能。",
	},

	HYPER_BURN = {
		NAME = "超热能",
		DESC = "向指定区域喷射能够灼烧敌人的超高温生体电浆。\n短时间内连按技能释放键可以多次释放。每次释放都需要消耗少量灵能。",
	},

	ELECTRIC_PUNCH = {
		NAME = "细胞放电",
		DESC = "徒手攻击能引发静电爆破，造成电属性与位面属性伤害。在持有武器时，也能以副手进行徒手攻击。\n开启此技能需要消耗些许灵能。技能生效期间，每次徒手攻击也会消耗少量灵能。",
	},

	MIMIC_LV1 = {
		NAME = "模拟物质",
		DESC = "模拟目标物体的样貌，隐藏自身形体。\n可以借此伪装成毫不起眼的杂物，躲避敌人。\n期间需要持续消耗少量灵能。",
	},

	MIMIC_LV2 = {
		NAME = "模拟物质 Ⅱ",
		DESC = "提高模拟物质的能力，现在可以模仿眼球炮塔等稍微精密的物体。",
	},

	REGENERATION = {
		NAME = "再生",
		DESC = "遭受攻击后，会通过加速新陈代谢来恢复生命值。短时间内连续受到攻击会使再生效果变差。",
	},


	DIMENSION_JUMP = {
		NAME = "幻影冲刺",
		DESC = "凯尔在滑铲时会化作一团暗影，无视伤害与物体碰撞。\n这个效果每隔3秒才能使用一次。",
	},

	PICKER_BUTTERFLY = {
		NAME = "远端拾取",
		DESC = "使用自己的意志创造信使，帮助拾取物资。\n被凯尔击败的敌人，其掉落物会随信使飞到凯尔口袋里。",
	},

	LINKAGE = {
		NAME = "骨牌",
		DESC = "链接目标生物。当被链接的其中一个生物受到攻击或者昏迷时，其他被链接的生物也会一同受伤或昏迷。\n需要消耗少量灵能。",
	},

	DARK_VISION = {
		NAME = "黑暗视觉",
		DESC = "在黑暗中看的更清楚。透过表象观察生物。\n期间需要持续消耗少量灵能。",
	},

}

STRINGS.GALE_UI.CG = {
	CG_INTRO = {
		"不死鸟的故事是从世界大战开始的。\n" .. STRINGS.LMB .. ":下一页",

		"那是与和平二字无缘，充满暴力和破坏的时代...",
		"为了杀死所有与自己为敌的人而不择手段的战乱时代。",
		"将整个城市夷为废墟的核弹，\n侵蚀生命的生化武器，\n以及进化得无比发达的化学武器。",
		"大战末期，地球已经变得满目疮痍，惨不忍睹。",
		"就在即将失去一切的时候，人类得到了一丝微弱的希望之光。\n那就是成功制造出了「人造神」。",
		"人们将这无与伦比的杰作\n称呼为「不死鸟」。",
		"凭借着那无可匹敌的力量，终于为大战画下了休止符。",

		"但是，环境遭到严重破坏的地球\n已经变得不适合生物居住。",
		"于是，人类最高意志决断机关「终焉议会」召开会议，\n摸索着让人类存活下去的最佳办法。",
		"最后决定在地球内部挖出一个巨大空洞作为避难所，",
		"让全人类在那里进入休眠，直到地球的环境恢复再返回。",

		"大战之后，过了几个世纪...",

		"不死鸟变成了「传说」...",
		"人们从漫长的休眠中醒来，在重获生机的地球再次建立了文明。",
		"各个地区相继成立了国家，并不断有人加入其中。",
		"整个世界都获得了新生。",

		"而现在，推动历史发展的故事也即将重新开始...",
	},
}

STRINGS.GALE_UI.SUPPORT_THEM = {
	TITLE = "支持《不死鸟传说》",
	DESC = "如果你喜欢本人物mod的话，不妨点击下方的按钮在Steam商店里购买一份《不死鸟传说：觉醒》，来赞助一下原作者哦！万分感谢！\n（另附《不死鸟传说：觉醒》全收集流程攻略视频）",
	BUTTON_BUY = "转到Steam商店界面",
	BUTTON_LAO_XIAN = "查看攻略视频",
}

-- STRINGS.GALE_UI.CANT_THROW_MORE_THAN_2_BOMB = ""

STRINGS.GALE_UI.GALE_POCKET_BACKPACK = {
	LOCKED_SLOT = {
		TITLE = "未解锁的背包栏",
		DESC = "这个背包栏位尚未被解锁，无法在此放入物品。\n将缝纫包拖动到背包上，按下右键以解锁新背包栏位。",
	}
}

STRINGS.GALE_UI.ATHETOS_REVEALED_TREASURE = {
	DEPLOY = "启用拟态",
}

STRINGS.GALE_UI.ANNOUNCE_GALEBOSS_KATASH_STEAL_FOOD = "%s被%s偷走了！"

STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_WITH_THRESHOLD = "获得力量加成，但不会超出某个阈值。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA_OVER_TIME = "在一段时间内提高耐力恢复速度。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GAIN_POWER_AND_RECOVER_STAMINA_OVER_TIME = "获得力量与耐力加成。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_RECOVER_STAMINA = "立刻恢复耐力。"
STRINGS.UI.COOKBOOK.FOOD_EFFECTS_DOG_FOOD = "宠物或者犬类生物非常喜欢吃。"
-- //////////////////////////////////////////////////////////////////////
--                              Skill Cast
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_SKILL_CAST = {}
STRINGS.GALE_SKILL_CAST.FAILED = {
	INSUFFICIENT_MAGIC = "灵能不足！",
	INSUFFICIENT_HEALTH = "生命值不足！",
	INSUFFICIENT_STAMINA = "耐力值不足！",
	COOLING_DOWN = "技能“%s”正在冷却，还需要%.1f秒才能释放。",
	INVALID_TARGET = "指向的目标不合法。",
	TOO_FAR = "目标过远",

	NO_TARGET_ITEM = "“%s”必须以一个物品为对象才能发动。",
	NO_TARGET_ALLY = "“%s”必须以一个盟友为对象才能发动。",
	NO_TARGET_ENEMY = "“%s”必须以一个敌人为对象才能发动。",
	NO_TARGET_CREATURE = "“%s”必须以一个生物为对象才能发动。",
	NO_TARGET_STRUCT = "“%s”必须以一个建筑为对象才能发动。",
}

-- //////////////////////////////////////////////////////////////////////
--                              Readable Paper
-- //////////////////////////////////////////////////////////////////////
STRINGS.GALE_UI.READABLE_PAPER = {}

-- STRINGS.GALE_UI.READABLE_PAPER.GALEBOSS_KATASH_NOTEBOOK_1 = {
-- 	TITLE = "航行日志 139号",
-- 	CONTENT =
-- 	[=[    今天是我一生中最倒霉的一天。我被那个会挥棍子的小女孩狠狠打败，在撤退时，不知从哪里来的一只黑色大手把我的飞船紧紧拽住，然后把我连同飞船一起恶狠狠地扔到这片陌生的土地上。
--     飞船从中间折断，完全报废了！能活下来简直是奇迹！我只能尽力抢救还能用的物资，然后凑合着过了一夜。]=],
-- }

STRINGS.GALE_UI.READABLE_PAPER.GALEBOSS_KATASH_NOTEBOOK_1 = {
	TITLE = STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_1,
	CONTENT =
	[=[今天是我一生中最倒霉的一天。我被那个会挥棍子的小女孩狠狠打败，在撤退时，不知从哪里来的一只黑色大手把我的飞船紧紧拽住，然后把我连同飞船一起恶狠狠地扔到这片陌生的土地上。
飞船从中间折断，完全报废了！我能活下来简直是奇迹！我抢救出了大多数还能用的物资，然后凑合着过了第一夜。]=],
}

STRINGS.GALE_UI.READABLE_PAPER.GALEBOSS_KATASH_NOTEBOOK_2 = {
	TITLE = STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_2,
	CONTENT = [=[我来到这片陌生的土地也有一段时间了。今天我尝试了一下蜘蛛肉，无论是生吃，煮熟，或者烘干都有一股怪味。
但是如果把它做成饼干，就没有那讨厌的味道了，尝起来也很不错。
我一口气吃了好多，剩下的就放在箱子里以备不时之需吧。
另外，我在箱子周围闻到了陌生的气味，有什么人趁我不在，来营地里翻了我的箱子。
很有可能是猪人干的，在我打猎的时候他们总是对我手上的肉馋的要死。
以防万一，就把箱子锁起来吧。]=],
}

STRINGS.GALE_UI.READABLE_PAPER.GALEBOSS_KATASH_NOTEBOOK_3 = {
	TITLE = STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_3,
	CONTENT = [=[箱子上的锁居然被破坏掉了!
根据痕迹看好像是锤子砸开的，难道猪人也会使用工具吗？
今晚我得抽出时间来做一些炸药，如果明天那些猪人还敢来，就让自爆无人机向他们问好吧！]=],
}

STRINGS.GALE_UI.READABLE_PAPER.GALEBOSS_KATASH_NOTEBOOK_4 = {
	TITLE = STRINGS.NAMES.GALEBOSS_KATASH_NOTEBOOK_4,
	CONTENT = [=[致亲爱的小偷：

箱子里没有好东西给你了！不仅如此，我在地洞里找到了个不错的藏身处，你暂时也别想找到我！
科伯特的战士绝不会放跑自己的猎物！等我把伤养好以后，咱们走着瞧！！！


																		祝你好死，
																		卡塔什]=],
}
