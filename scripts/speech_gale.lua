--[[
	--- This is Wilson's speech file for Don't Starve Together ---
	Write your character's lines here.
	If you want to use another speech file as a base, or use a more up-to-date version, get them from data\scripts\
	
	If you want to use quotation marks in a quote, put a \ before it.
	Example:
	"Like \"this\"."
]]

local MODIFIED_SPEECH = {
	-- 战吼
	BATTLECRY =
	{
		GENERIC = "开洞开洞！",
		PIG = "今晚吃猪肉！",
		PREY = "午餐别跑！",
		SPIDER = "来吧，野兽！",
		SPIDER_WARRIOR = "战斗吧！",

		DEERCLOPS = "势不可挡！",
		DRAGONFLY = "纷争之火，炽烈燃烧。",
	},

	-- 检查
	DESCRIBE = {
		PLAYER = {
			GENERIC = "嗨，%s!",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},

		SHIYE = {
			GENERIC = "你好，皇家守卫%s!",
			ATTACKER = "你为这个世界带来了混乱！",
			MURDERER = "面具杀手！",
			REVIVER = "%s是个好人",
			GHOST = "我得把%s从虚空中拉回来！",
		},

		GALLOP = {
			GENERIC = "斩机加洛普",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},

		FLOWER = "可爱的小花花。",
		GALEBOSS_DRAGON_SNARE = "可能是芮塔的远亲。",

		PUMPKIN = "好大的南瓜啊。",
		PUMPKINCOOKIE = "娜娜婆婆，我好想你...",
		PUMPKIN_COOKED = "要是做成南瓜松饼更好吃。",

		GELBLOB = "长得有点像蒂亚下水道的史莱姆，不过是黑色。",
	},


	ANNOUNCE_EXIT_GELBLOB = "呕，它比那些史莱姆还要臭！",
}

return MODIFIED_SPEECH
