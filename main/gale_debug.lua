local GaleCommon = require("util/gale_common")
local GaleConditionUtil = require "util/gale_conditions"

-- AddPrefabPostInit("world",function(inst)
--     inst:DoTaskInTime(0.1,function()
--         for k,v in pairs(Ents) do
--             if v.prefab and string.find(v.prefab,"vfx") then
--                 print(string.format("[Gale Debug]:%s Find vfx",TheNet:IsDedicated() and "server" or "client"),v)
--             end
--         end
--     end)
-- end)

-- For test memory
GLOBAL.galetestmen = {}
-- galetestmen.size = {1,1,1}
-- CHEATS_ENABLED = true

-- local old_PlaySound = SoundEmitter.PlaySound
-- SoundEmitter.PlaySound = function(self,path,...)
--     print("SoundEmitter play:",path)
--     return old_PlaySound(self,path,...)
-- end

-- RevealAllMap()
-- for x=-1000,1000,30 do for y=-1000,1000,30 do ThePlayer.player_classified.MapExplorer:RevealArea(x ,0, y) end end
function GLOBAL.RevealAllMap()
    for x = -1000, 1000, 30 do
        for y = -1000, 1000, 30 do
            ThePlayer.player_classified.MapExplorer:RevealArea(x, 0, y)
        end
    end
end

function GLOBAL.c_condition(name, stack, target)
    target = target or ThePlayer
    stack = stack or 1
    if stack > 0 then
        GaleConditionUtil.AddCondition(target, name, stack)
    elseif stack < 0 then
        GaleConditionUtil.RemoveCondition(target, name, -stack)
    else
        print("Zero stack condition!")
    end
end

function GLOBAL.DebugCartPolar(v1, v2)
    local polar_1 = GaleCommon.Cart2Polar(v1 or Vector3(1, 1, 1), true)
    local polar_2 = GaleCommon.Cart2Polar(v2 or Vector3(-1, -1, -1), true)
    local polar_delta = polar_2 - polar_1

    local cnt = 100
    local step = polar_delta / cnt

    for i = 0, cnt - 1 do
        local polar_cur  = polar_1 + step * i
        local polar_next = polar_1 + step * (i + 1)

        local cart_cur   = GaleCommon.Polar2Cart(polar_cur, true)
        local cart_next  = GaleCommon.Polar2Cart(polar_next, true)

        print(cart_cur)
        print("Delta length:", (cart_next - cart_cur):Length())
    end
end

-- ThePlayer.components.locomotor:GoToEntity(c_findnext("galeboss_dragon_snare"))
-- c_findnext("galeboss_ruinforce").sg:GoToState("roar")

-- TheWorld:PushEvent("ms_setmoonphase", {moonphase = "new", iswaxing = true})
-- c_select().components.pickable:FinishGrowing()

-- require("debugcommands")
-- require("debugkeys")

GLOBAL.GALE_LOREM_IPSUM_ENG =
[=[English Lorem: ipsum dolor sit amet consectetur adipisicing elit. Omnis vitae corporis labore perspiciatis nam laboriosam, saepe, autem veritatis vel nihil ut, quibusdam aliquam quo minus! Dicta dolor ab repellat vel excepturi eos ad optio a iusto consequatur fugit cumque sint pariatur velit quidem assumenda quaerat suscipit autem omnis ipsa, voluptas molestiae? Iure, provident maiores libero doloremque a quibusdam dolorum at suscipit officia aperiam consectetur temporibus voluptatem ex, et sequi ad voluptate ipsam, quisquam soluta! Eaque accusamus recusandae impedit reiciendis, esse quasi debitis architecto doloribus distinctio asperiores facilis ullam nihil aliquid in nam itaque dolor quo dolorum, pariatur ratione. Doloribus, dolorem!]=]

GLOBAL.GALE_LOREM_IPSUM_CHS =
[=[中文假文：我韩他场，与决小欲和低若关尘风思才评手时助，商法秦创开六收夫德，临实太人幕太则锐幕了可国呼承，勇德皇低憾，其如在国叹韩，导互定气间郭己到，韩许面属人俭，纯老领，后上呼老知，躲春拆九秦了俭文人秦予，就本此我太重孔时心一招被台卞次五同诗弄，榜价求惊从临话友两无承曰是忧惜，国李云人只之为策是舟下杨在无兴二忧，出严不力友马知娘我，的许守找分愿人，是洪前卑馆拢云太人下疾能才郭气，舟病见与订九创今九德从为落，丈皇不徒灰人耐，言国笔我非此者郭兴就王落不法太罪而你郭，羊斯救，领云的灰况，密张我卑己航老反无谓游临，定也清以，么问是，不设活皇韩善认通回为服应三未低服里看就，姑以书司头，要才玉助将婵是是重朗人国天把，判法廿一人，派仑价哉谓，谓没视与雷仁地行年曾金，训定这接普失赐使为收书穿不夫领有，可叹毒下兼上登下恼，内付到会上非生人着这王起也苦，是同慧也如后畴人少人，等牛足二如来处切才，导样后宋能能量作胜下后以哥没九友破将互，鲜言自杨化皇不何里考者怒可娘风，下定也面派你非奔快姑亡们，极许司制千名因远担三没非慧没等，人文来不说畴找尺不，故案上书收求在哉身以皇，都知家老听，雷关陈念大讨身后杨洪亓仓拢匹，人则知人服定今脱洪帝王曾娇他，会春叹磊而谓风上为土死逝联案，命罪如太商，而传面都就的、，不穿都归放，劫评就哉，否又的极看案处惊到的丰她，文后着大请笔太皇衣却德之找血商，乐如快，在怎应而中，守国普在。]=]

GLOBAL.GALE_LOREM_IPSUM_CHS_1200 =
[=[中文假文：来失骂活对找也乡哉绪，区燕乌这有活磊不才打有衣诗，年侯秦恩联后衣衣守搏此谋如者病不韩牙俭，极战讨，绪目轻派友养欲后侯光玉承样中六烦非所范，自说百，烦虽后法迷厅心者，娘作小年语，是法嗣马十，斗为龄承羊畴妄但人非曾，仓语俭不禀回韩你我，一她觉而办衣他老洪的若，也不书，死案连沾身以兮流狂自举同仄使胆，说落导教尘使，虽兼笔人，我为许哉人逝太将二言国大小了叹胸统属，他就雷谭是郭争张不派用在衣的了，才司不最想，令觉洪若考导派徒遗为视娘的不褒惜不说胜，而的呼她因韦不是交，在回使为如，不丑说家榜互月的是己仆落而六国我陀守不，次中见胜订法生，论兴价那病化，卧会报，胜人人非山前家应作身给生作为这予劝人爻，听的书韩国谋烦也的笔洪勇定，之何求叹仁是最了，作骂洪躲不尝玉先者设区廿反上，子撒秦要人法重三同为他，锐自是是的屯得久丑县承郭人身小，的天属徒，变弟了归快价有样守高以你畴我贼尤他作么，畴色纯太沫得病量惊十己故俭能两切是卞，我勉系通又到说见锐你，梵井国通苟己能入者老觉太，法谓化才的足订兴叹，竟子居罪丐可与里争说，负办妙书壬作罪的在也逝，不于乐人，极曾许马磊土未，不若活先促慧兼活太自，首也越什她服动就通新拢一人下褒，妄都若的锐报谭人打光订一兄卑活力蒲苟，又极榜此太褒韩或，秦但不为自韩笔人哉已狂说破，罪不韦书不人刑的胜那承知骨的回分帝，死司勉兼战大第，九司办事出挟场就自人三化为说吞慷，的面是才手娘的养乡血命婵活为国尝要，定落尝兄十，争处你骂兼评大太，百偶反只公自陈清意白招骨，天价最高，在四得论杀，太甲国相书则说专斗一护为，死己好足变国那价汪，感不这病略不人蒲不轻么病斗国愿临智为，韩几你学君完己老，交二把活有斯国才言谋们里护欲，是廿有帅其上就，郭徨陈予盲君都开我洪处极都说春，小皇谓人了搏一导资好郭孔在逝是谓化，可自慷衣在，让却承后，子之王本得氏胜，辜次釜杀投量仆苦罪一生，这百动见大上斯拆到向满就拾瞠家也，是宋老金，千若的但联分极范，中落决选下洪丐谓纯的非她揽两应陈程向到，而第丰，张种人中得反头智商有么小事予夫着，生欲为竟貂们斯弄好，了找两，马天定曰和见谓就韩哉秦，郭而就彷即得切主给远狂是，留秦是成官，回清韩而无极认救有自好时子训商爱分的，评竟死游流锐家，国国老此是绪发欲洪的韩人，到我竟洪一流普书不尝土临国况朋读，才会会禀修的才亲将气决少人之太者失锐一，对游陀灰鼓我才中严沫法时活德畴极，次便生攻使洪入世九够不向洪死，了主而穿下今那国文我统壬，日要负，资德中的慧盲认张天今身，贼范了生一畴向的好己人郭她司中以杨派，主国文不够升夹五秦兄马血君常，斗釜完想得卧事尚如，助平定小竟山未，事他给找回求是对他他是少德薪极，负婵召登拾德土病智李成公的全药付唯妙，马资得则办冇揽，使生皇统订母后，变非力，花上我沫，不友永笔冷罪的为老德迷弟，惊永对能灰，觉了水辜一可下评氏间交谢俭乌玉绪，谋有法文，作她。]=]

GLOBAL.GALE_LOREM_IPSUM_CHS_NO_UPDATE =
[=[我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！我好想每天更新啊啊啊啊啊！]=]


-- HyperBurn(ThePlayer,ThePlayer:GetPosition() + Vector3(0,1.0,0),TheInput:GetWorldPosition())
