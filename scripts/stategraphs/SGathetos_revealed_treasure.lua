require("stategraphs/commonstates")

local GaleCommon = require("util/gale_common")

local function GetEndSeg(inst)
    return inst:IsOnOcean() and (inst.ocean_seg or 72) or 125
end

local events =
{
    EventHandler("onopen", function(inst, data)
        if inst.sg:HasStateTag("deploy") then
            return
        end

        if inst.sg.currentstate.name == "moving" then
            inst.target_img_seg = GetEndSeg(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/open")
        else
            inst.sg:GoToState("open")
        end
    end),

    EventHandler("onclose", function(inst, data)
        if inst.sg:HasStateTag("deploy") then
            return
        end

        if inst.sg.currentstate.name == "moving" then
            inst.target_img_seg = 0
            inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/open")
        else
            inst.sg:GoToState("close")
        end
    end),
}

local searched_xml_dict = {}
local function GetBoardXML(tex_name)
    if searched_xml_dict[tex_name] then
        return searched_xml_dict[tex_name]
    end

    local paths = {
        resolvefilepath("images/override_symbols/athetos_revealed_treasure_boards1.xml"),
        resolvefilepath("images/override_symbols/athetos_revealed_treasure_boards2.xml")
    }

    for _, path in pairs(paths) do
        if TheSim:AtlasContains(path, tex_name) then
            searched_xml_dict[tex_name] = path
            return path
        end
    end
end

local function SetBoardSeg(inst, img_seg)
    inst.img_seg = img_seg

    local tex_name = string.format("board_%d.tex", inst.img_seg)
    local xml_path = GetBoardXML(tex_name)
    inst.AnimState:OverrideSymbol("board", xml_path, tex_name)

    -- inst.board_anim.AnimState:SetPercent("board_open2", img_seg / 139)
end

local function BoardUpdateFn(inst, dt)
    local max_speed = 1

    -- local xml_path = resolvefilepath("images/override_symbols/athetos_revealed_treasure_boards1.xml")
    if inst.img_seg > inst.target_img_seg then
        inst.img_seg = math.ceil(math.max(0, inst.img_seg - inst.sg.statemem.cur_speed))
        -- inst.img_seg = math.max(0, inst.img_seg - inst.sg.statemem.cur_speed)
    elseif inst.img_seg < inst.target_img_seg then
        inst.img_seg = math.floor(math.min(inst.target_img_seg, inst.img_seg + inst.sg.statemem.cur_speed))
        -- inst.img_seg = math.min(inst.target_img_seg, inst.img_seg + inst.sg.statemem.cur_speed)
    end


    if inst.img_seg == 0 then
        inst.AnimState:ClearOverrideSymbol("board")
    else
        SetBoardSeg(inst, inst.img_seg)
    end


    -- dt = math.max(0,dt - FRAMES)
    -- inst.sg.statemem.cur_speed = math.min(max_speed, inst.sg.statemem.cur_speed + FRAMES * 3)


    if inst.img_seg == inst.target_img_seg then
        inst:EnableOpenLoopSound(false)
        inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/reach_end")

        inst.sg:GoToState("idle")
    end
end

local states =
{
    State {
        name = "open",
        tags = { "busy", },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/ding")
        end,

        timeline = {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/open")
                inst.target_img_seg = GetEndSeg(inst)
                inst.sg:GoToState("moving")
            end),
        },
    },

    State {
        name = "close",
        tags = { "busy", },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/open")
            inst.target_img_seg = 0
            inst.sg:GoToState("moving")
        end,
    },

    State {
        name = "moving",
        tags = { "busy", },

        onenter = function(inst)
            inst:EnableOpenLoopSound(true)
            inst.sg.statemem.cur_speed = 1
            -- print("Enter moving")

            -- inst.components.updatelooper:AddOnUpdateFn(BoardUpdateFn)
        end,

        onupdate = function(inst)
            local max_speed = 1

            -- local xml_path = resolvefilepath("images/override_symbols/athetos_revealed_treasure_boards1.xml")
            if inst.img_seg > inst.target_img_seg then
                inst.img_seg = math.ceil(math.max(0, inst.img_seg - inst.sg.statemem.cur_speed))
                -- inst.img_seg = math.max(0, inst.img_seg - inst.sg.statemem.cur_speed)
            elseif inst.img_seg < inst.target_img_seg then
                inst.img_seg = math.floor(math.min(inst.target_img_seg, inst.img_seg + inst.sg.statemem.cur_speed))
                -- inst.img_seg = math.min(inst.target_img_seg, inst.img_seg + inst.sg.statemem.cur_speed)
            end


            if inst.img_seg == 0 then
                inst.AnimState:ClearOverrideSymbol("board")
            else
                SetBoardSeg(inst, inst.img_seg)
            end




            -- dt = math.max(0,dt - FRAMES)
            -- inst.sg.statemem.cur_speed = math.min(max_speed, inst.sg.statemem.cur_speed + FRAMES * 3)



            if inst.img_seg == inst.target_img_seg then
                inst:EnableOpenLoopSound(false)
                inst.SoundEmitter:PlaySound("gale_sfx/athetos_treasure/reach_end")

                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            inst:EnableOpenLoopSound(false)

            if inst.sg.statemem.task then
                inst.sg.statemem.task:Cancel()
            end

            -- inst.components.updatelooper:RemoveOnUpdateFn(BoardUpdateFn)
        end,
    },


    State {
        name = "deploy",
        tags = { "busy", "deploy" },

        onenter = function(inst, data)
            data = data or {}

            inst:AddTag("NOCLICK")

            inst.components.container:Close()
            inst.components.container.canbeopened = false

            inst.AnimState:SetMultColour(0, 0, 0, 1)
            inst.AnimState:PlayAnimation("idle")

            SetBoardSeg(inst, 0)
            inst:EnableOpenLoopSound(false)

            inst.sg.statemem.prefab = data.prefab
            inst.sg.statemem.fx = SpawnAt("gale_skill_mimic_fx", inst)

            SpawnAt("statue_transition_2", inst)

            inst.SoundEmitter:PlaySound("gale_sfx/skill/mimic_pre")

            inst.sg:SetTimeout(2.2)
        end,

        timeline =
        {
            TimeEvent(48 * FRAMES, function(inst)
                inst:Hide()
            end),
        },

        ontimeout = function(inst)
            local pos = inst:GetPosition()
            local prefab = inst.sg.statemem.prefab

            if inst:IsOnOcean() then
                prefab = "athetos_hidden_treasure_seastack"
            elseif prefab == nil then
                prefab = GetRandomItem({
                    "athetos_hidden_treasure_tree",
                    "athetos_hidden_treasure_sapling",
                    "athetos_hidden_treasure_rock_flintless",
                })
            end

            local saved_data = inst:GetSaveRecord()

            if inst.sg.statemem.fx then
                inst.sg.statemem.fx:Remove()
                inst.sg.statemem.fx = nil
            end

            SpawnAt("statue_transition_2", pos)
            SpawnAt(prefab, pos).treasure_data = saved_data

            inst:Remove()
        end,
    },
}

CommonStates.AddIdle(states, nil, "idle")

return StateGraph("SGathetos_revealed_treasure", states, events, "idle")
