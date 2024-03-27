local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require"widgets/image"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local MELODY_PAUSE_AREABGM_DURATION = {
    melody_ouroboros = 12,
    melody_geo = 9,
    melody_royal = 11,
    melody_panselo = 13,
    melody_battle = 3,
    melody_phoenix = 4.5,
}

local GaleFluteScreen = Class(Screen, function(self, owner)
    Screen._ctor(self, "GaleFluteScreen")
	TheInput:ClearCachedController()

	self.owner = owner
    self.last_fangxiang = "mid"
    self.pushed_btns = {
        [CONTROL_MOVE_UP] = false,
		[CONTROL_MOVE_DOWN] = false,
		[CONTROL_MOVE_LEFT] = false,
		[CONTROL_MOVE_RIGHT] = false,
    }
    self.exit_btns = {
        -- CONTROL_PRIMARY,
        -- CONTROL_SECONDARY,
        CONTROL_CANCEL,
        CONTROL_ACTION,
    }

    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0, 0, 0, 0)
    self.black:SetOnClick(function() self:Exit() end)

    self.melody_indexs = {}
    for k,v in pairs(TUNING.GALE_MELODY_DEFINE) do 
        self.melody_indexs[k] = 1
    end

    TheFocalPoint.SoundEmitter:PlaySound("gale_sfx/flute/song_secret")
    ThePlayer.HUD.GaleFluteScreen = self 
end)

function GaleFluteScreen:HandleCombo()
    for k,v in pairs(TUNING.GALE_MELODY_DEFINE) do 
        local id = self.melody_indexs[k]
        if v[id] == self.last_fangxiang then 

            -- To the end,success play melody
            if id == #v then 
                -- clear all progress
                for a,_ in pairs(TUNING.GALE_MELODY_DEFINE) do 
                    self.melody_indexs[a] = 1
                end

                
                TheWorld.components.dynamicmusic:AddAreabgmPauseSource(self.owner,"melody_play",MELODY_PAUSE_AREABGM_DURATION[k])

                SendModRPCToServer(MOD_RPC["gale_rpc"]["melody_play"],k)
            else
                self.melody_indexs[k] = self.melody_indexs[k] + 1
            end 
        else
            self.melody_indexs[k] = 1
            if v[1] == self.last_fangxiang then 
                self.melody_indexs[k] = self.melody_indexs[k] + 1
            end
        end
    end
end

function GaleFluteScreen:ResetFangxiang(current,down)
    if down then 
        if current == CONTROL_MOVE_UP then 
            self.last_fangxiang = "shang"
        elseif current == CONTROL_MOVE_DOWN then 
            self.last_fangxiang = "xia"
        elseif current == CONTROL_MOVE_LEFT then 
            self.last_fangxiang = "zuo"
        elseif current == CONTROL_MOVE_RIGHT then 
            self.last_fangxiang = "you"
        end 
    else
        local any_pressed = false
        for k,v in pairs(self.pushed_btns) do 
            if v then 
                if k == CONTROL_MOVE_UP then 
                    self.last_fangxiang = "shang"
                elseif k == CONTROL_MOVE_DOWN then 
                    self.last_fangxiang = "xia"
                elseif k == CONTROL_MOVE_LEFT then 
                    self.last_fangxiang = "zuo"
                elseif k == CONTROL_MOVE_RIGHT then 
                    self.last_fangxiang = "you"
                end 
                any_pressed = true
                break
            end
        end

        if not any_pressed then 
            self.last_fangxiang = "mid"
        end
    end

    SendModRPCToServer(MOD_RPC["gale_rpc"]["flute_fangxiang"],self.last_fangxiang)
end

function GaleFluteScreen:Exit()
    SendModRPCToServer(MOD_RPC["gale_rpc"]["flute_exit_c2s"])
    TheFrontEnd:PopScreen(self)
    ThePlayer.HUD.GaleFluteScreen = nil 
end

function GaleFluteScreen:OnControl(control, down)
    if self.pushed_btns[control] ~= nil or control == CONTROL_ATTACK then 
        self.pushed_btns[control] = down
        self:ResetFangxiang(control, down)
    end 

    -- print(dumptable(self.pushed_btns))
    -- print(self.last_fangxiang)

    local need_to_play = false
    if down then 
        if table.contains(self.exit_btns,control) then 
            self:Exit()
        elseif control == CONTROL_ATTACK then 
            -- Use CD 
            if self.last_play_time and GetTime() - self.last_play_time <= 0.2 then
                need_to_play = false
            else 
                self.last_play_time = GetTime()
                need_to_play = true 
            end
            
        end
    end 

    
    if need_to_play then 
        --play one flute 
        SendModRPCToServer(MOD_RPC["gale_rpc"]["flute_play"],self.last_fangxiang)
        self:HandleCombo()
    end

    if GaleFluteScreen._base.OnControl(self,control, down) then
        return true
    end
end

return GaleFluteScreen