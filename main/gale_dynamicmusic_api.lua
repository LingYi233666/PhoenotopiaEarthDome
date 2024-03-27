local UpvalueHacker = require("util/upvaluehacker")
local SourceModifierList = require("util/sourcemodifierlist")

AddComponentPostInit("dynamicmusic", function(self)
    local ORIGINAL_FUNCS = {}

    -- print("Gale DynamicMusic Hacking....")
    UpvalueHacker.PrintListenFns(self.inst, "playeractivated")

    local playeractivated_listenfns = UpvalueHacker.GetListenFns(self.inst, "playeractivated")
    for k, v in pairs(playeractivated_listenfns) do
        -- print("print playeractivated_listenfns",v)
        -- UpvalueHacker.PrintUpvalue(v)
        -- dumptable(debug.getinfo(v))

        local StartPlayerListeners = UpvalueHacker.GetUpvalue(v, "StartPlayerListeners")
        local StopPlayerListeners = UpvalueHacker.GetUpvalue(v, "StopPlayerListeners")

        if StartPlayerListeners then
            -- UpvalueHacker.PrintUpvalue(StartPlayerListeners)
            ORIGINAL_FUNCS["StartPlayerListeners"] = StartPlayerListeners
            ORIGINAL_FUNCS["StartBusy"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartBusy")
            ORIGINAL_FUNCS["OnAttacked"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "OnAttacked")
            ORIGINAL_FUNCS["StartDanger"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["OnAttacked"], "StartDanger")
            ORIGINAL_FUNCS["SEASON_DANGER_MUSIC"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartDanger"],
                                                                             "SEASON_DANGER_MUSIC")
            ORIGINAL_FUNCS["SEASON_EPICFIGHT_MUSIC"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartDanger"],
                                                                                "SEASON_EPICFIGHT_MUSIC")
            ORIGINAL_FUNCS["OnInsane"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "OnInsane")
            ORIGINAL_FUNCS["StartTriggeredDanger"] = UpvalueHacker.GetUpvalue(StartPlayerListeners,
                                                                              "StartTriggeredDanger")
            ORIGINAL_FUNCS["TRIGGERED_DANGER_MUSIC"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartTriggeredDanger"],
                                                                                "TRIGGERED_DANGER_MUSIC")
            ORIGINAL_FUNCS["OnEnlightened"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "OnEnlightened")
            ORIGINAL_FUNCS["StartTriggeredWater"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartTriggeredWater")
            ORIGINAL_FUNCS["StartOcean"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartTriggeredWater"], "StartOcean")
            ORIGINAL_FUNCS["StartTriggeredFeasting"] = UpvalueHacker.GetUpvalue(StartPlayerListeners,
                                                                                "StartTriggeredFeasting")
            ORIGINAL_FUNCS["StartFeasting"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartTriggeredFeasting"],
                                                                       "StartFeasting")
            ORIGINAL_FUNCS["StartRacing"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartRacing")
            ORIGINAL_FUNCS["StartHermit"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartHermit")
            ORIGINAL_FUNCS["StartTraining"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartTraining")
            ORIGINAL_FUNCS["StartFarming"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartFarming")
            ORIGINAL_FUNCS["StartBusyTheme"] = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartFarming"], "StartBusyTheme")
            ORIGINAL_FUNCS["StartCarnivalMustic"] = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartCarnivalMustic")
        end

        if StopPlayerListeners then

        end
    end

    local function DoHack(up_func_name, curr_func_name, add_pre, add_pst)
        local old_func = ORIGINAL_FUNCS[curr_func_name]
        local function new_func(...)
            if add_pre then
                if add_pre(...) == false then
                    return
                end
            end

            local ret = old_func(...)

            if add_pst then
                if add_pst(...) == false then
                    return
                end
            end

            return ret
        end
        UpvalueHacker.SetUpvalue(ORIGINAL_FUNCS[up_func_name], new_func, curr_func_name)
    end

    local function PlayingAreaAndReturn()
        local _soundemitter = TheFocalPoint.SoundEmitter
        if _soundemitter:PlayingSound("gale_areabgm") then
            return false
        end
    end

    DoHack("StartPlayerListeners", "StartBusy", PlayingAreaAndReturn)
    DoHack("OnAttacked", "StartDanger", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "OnInsane", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "OnEnlightened", PlayingAreaAndReturn)
    DoHack("StartTriggeredWater", "StartOcean", PlayingAreaAndReturn)
    DoHack("StartTriggeredFeasting", "StartFeasting", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "StartRacing", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "StartHermit", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "StartTraining", PlayingAreaAndReturn)
    DoHack("StartFarming", "StartBusyTheme", PlayingAreaAndReturn)
    DoHack("StartPlayerListeners", "StartCarnivalMustic", PlayingAreaAndReturn)


    function self:UseAreaBgm(path)
        local _soundemitter = TheFocalPoint.SoundEmitter

        _soundemitter:KillSound("gale_areabgm")
        if path then
            _soundemitter:KillSound("busy")
            if self.triggeredlevel == nil then
                _soundemitter:KillSound("danger")
            end
            _soundemitter:PlaySound(path, "gale_areabgm")
        end
    end

    function self:AddAreabgmPauseSource(source, name, duration)
        self.areabgm_pause_modifier:SetModifier(source, true, name)
        if duration then
            self.inst:DoTaskInTime(duration, function()
                self:RemoveAreabgmPauseSource(source, name)
            end)
        end

        self:CheckAreabgmPauseSource()
    end

    function self:RemoveAreabgmPauseSource(source, name)
        self.areabgm_pause_modifier:RemoveModifier(source, name)
        self:CheckAreabgmPauseSource()
    end

    function self:CheckAreabgmPauseSource()
        local _soundemitter = TheFocalPoint.SoundEmitter
        if self.areabgm_pause_modifier:Get() then
            _soundemitter:SetVolume("gale_areabgm", 0.1)
        else
            _soundemitter:SetVolume("gale_areabgm", 1)
        end
    end

    -- ThePlayer.SoundEmitter:PlaySound("gale_sfx/battle/hit_metal")
    ------------------------------------------------------------------------------
    -- Init
    self.last_area_name = nil
    self.last_area_level = 1
    self.played_time = 0
    self.areabgm_pause_modifier = SourceModifierList(self.inst, false, SourceModifierList.boolean)

    -- Add modified TRIGGERED_DANGER_MUSIC here !
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_mini = {
        "gale_bgm/bgm/mini_boss2",
        "gale_bgm/bgm/victory_fanfare",
    }
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_dragon_snare = {
        "",
        "gale_bgm/bgm/p1_boss_battle",
        "gale_bgm/bgm/victory_fanfare",
    }
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_ruinforce = {
        "",
        "gale_bgm/bgm/metalgear_force",
        "gale_bgm/bgm/metalgear_ruinforce",
        "gale_bgm/bgm/victory_fanfare",
    }
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_katash = {
        "",
        "gale_bgm/bgm/katash_theme",
        "",
        "gale_bgm/bgm/victory_fanfare",
    }
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_phalanx = {
        "gale_bgm/bgm/phalanx_battle",
        "gale_bgm/bgm/victory_fanfare",
    }
    ORIGINAL_FUNCS.TRIGGERED_DANGER_MUSIC.galeboss_mother_brain = {
        "gale_bgm/bgm/final_battle_intro", --3.5s
        "gale_bgm/bgm/final_battle",
    }
    -- Add modified Area Bgm here !
    self.area_bgm_list = {
        -- panselo = {
        --     {"gale_bgm/bgm/p1_panselo"},
        -- },
        duri_forest = {
            { "gale_bgm/bgm/p1_duri_forest" },
        },
        duri_forest_night = {
            { "gale_bgm/bgm/duri_forest_old" },
        },
        eco_dome = {
            { "gale_bgm/bgm/p1_anuri_temple_full" },
        },
        sanctuary = {
            { "gale_bgm/bgm/sanctuary" },
        }
    }

    -- Update
    self.inst:DoPeriodicTask(0, function()
        local data = ThePlayer and ThePlayer:IsValid() and ThePlayer.components.areaaware:GetCurrentArea()
        local room = ThePlayer and ThePlayer:IsValid() and
            TheWorld.components.gale_interior_room_manager:GetRoom(ThePlayer:GetPosition())
        local current_area_name = nil
        local current_area_level = self.last_area_level
        local dt = FRAMES

        self.triggeredlevel = UpvalueHacker.GetUpvalue(ORIGINAL_FUNCS["StartTriggeredDanger"], "_triggeredlevel")
        if self.triggeredlevel == nil then
            if data then
                -- if string.find(data.id,"PigKingdom") then
                --     current_area_name = "anuri_temple"
                -- end
                if string.find(data.id, "duri_forest") then
                    if TheWorld.state.phase == "night" then
                        -- current_area_name = "duri_forest_night"
                    else
                        current_area_name = "duri_forest"
                    end
                end
            end

            if room then
                if room:HasTag("eco_dome") then
                    if room:HasTag("sanctuary") then
                        current_area_name = "sanctuary"
                    else
                        current_area_name = "eco_dome"
                    end
                end
            end

            if current_area_name == nil or current_area_name ~= self.last_area_name or current_area_level ~= self.last_area_level then
                self.played_time = 0
            else
                self.played_time = self.played_time + dt
            end

            if current_area_name ~= self.last_area_name then
                current_area_level = 1
            end

            local bgm_path = nil
            if current_area_name and current_area_level then
                local bgm_duration = self.area_bgm_list[current_area_name][current_area_level][2]
                if bgm_duration == nil then

                elseif self.played_time >= bgm_duration then
                    current_area_level = current_area_level + 1
                end
                bgm_path = self.area_bgm_list[current_area_name][current_area_level][1]
            end

            if current_area_name ~= self.last_area_name or current_area_level ~= self.last_area_level then
                self:UseAreaBgm(bgm_path)
            end
        else
            current_area_name = nil
            current_area_level = 1
            self:UseAreaBgm(nil)
        end

        self.last_area_name = current_area_name
        self.last_area_level = current_area_level



        -- if ThePlayer and ThePlayer:HasTag("attack") then
        --     -- local playeractivated_listenfns = UpvalueHacker.GetListenFns(self.inst,"playeractivated")
        --     -- for k,v in pairs(playeractivated_listenfns) do
        --     --     local StartPlayerListeners = UpvalueHacker.GetUpvalue(v,"StartPlayerListeners")
        --     --     if StartPlayerListeners then
        --     --         local StartDanger = UpvalueHacker.GetUpvalue(StartPlayerListeners,"OnAttacked","StartDanger")
        --     --         StartDanger(ThePlayer)
        --     --         break
        --     --     end
        --     -- end
        --     -- ORIGINAL_FUNCS["StartDanger"](ThePlayer)
        -- end
    end)

    local SEASON_DANGER_MUSIC = ORIGINAL_FUNCS["SEASON_DANGER_MUSIC"]
    local SEASON_DANGER_MUSIC_origin = shallowcopy(SEASON_DANGER_MUSIC)
    local typhon_combat_music = "gale_bgm/bgm/typhon_combat"

    for k, v in pairs(SEASON_DANGER_MUSIC) do
        SEASON_DANGER_MUSIC[k] = nil
    end

    local SEASON_DANGER_MUSIC_metatable = getmetatable(SEASON_DANGER_MUSIC)

    local function WrapTyphonFn(tab, key)
        if ThePlayer then
            local x, y, z = ThePlayer:GetPosition():Get()
            local typhons = TheSim:FindEntities(x, y, z, 30, { "_combat", "_health", "typhon" }, { "INLIMBO" })
            if #typhons > 0 then
                return typhon_combat_music
            end
        end

        return SEASON_DANGER_MUSIC_origin[key]
    end

    -- print("origin_SEASON_DANGER_MUSIC is:")
    -- dumptable(origin_SEASON_DANGER_MUSIC)

    if SEASON_DANGER_MUSIC_metatable == nil then
        print("setting metatable ...")
        SEASON_DANGER_MUSIC = setmetatable(SEASON_DANGER_MUSIC, {
            __index = WrapTyphonFn,
        })
    else
        SEASON_DANGER_MUSIC_metatable.__index = WrapTyphonFn
    end



    -- print("SEASON_DANGER_MUSIC_metatable is:")
    -- print(SEASON_DANGER_MUSIC_metatable)
    -- SEASON_DANGER_MUSIC_metatable.__index = function(tab,key)
    --     if ThePlayer then
    --         local x,y,z = ThePlayer:GetPosition():Get()
    --         local typhons = TheSim:FindEntities(x, y, z, 30, {"_combat","_health","typhon"}, {"INLIMBO"})
    --         if #typhons > 0 then
    --             return typhon_combat_music
    --         end
    --     end

    --     return origin_SEASON_DANGER_MUSIC[key]
    -- end
end)

-- AddPlayerPostInit(function(inst)
--     if not TheNet:IsDedicated() then
--         inst:AddComponent("gale_areabgm")
--     end
-- end)

AddClientModRPCHandler("gale_rpc", "add_areabgm_pause_source", function(source, name, duration)
    if TheWorld then
        TheWorld.components.dynamicmusic:AddAreabgmPauseSource(source, name, duration)
    end
end)

AddClientModRPCHandler("gale_rpc", "remove_areabgm_pause_source", function(source, name)
    if TheWorld then
        TheWorld.components.dynamicmusic:RemoveAreabgmPauseSource(source, name)
    end
end)

-- if inst._parent ~= nil and TheFocalPoint.entity:GetParent() == inst._parent then
--     TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/get_gold")
-- end

AddClientModRPCHandler("gale_rpc", "play_clientside_sound", function(path, force_play_on_danger, force_play_when_areabgm)
    if ThePlayer and TheFocalPoint and TheFocalPoint.SoundEmitter and TheFocalPoint.entity:GetParent() == ThePlayer then
        if TheFocalPoint.SoundEmitter:PlayingSound("danger") and not force_play_on_danger then
            return
        end

        if TheFocalPoint.SoundEmitter:PlayingSound("gale_areabgm") and not force_play_when_areabgm then
            return
        end

        TheFocalPoint.SoundEmitter:PlaySound(path)
    end
end)
