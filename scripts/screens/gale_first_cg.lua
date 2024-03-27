local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local GalePptSequence = require("widgets/gale_ppt_sequence")

local GaleFirstCG = Class(Screen, function(self,on_finish_fn)
    Screen._ctor(self, "GaleFirstCG")
	TheInput:ClearCachedController()

    self.ppt_seq = self:AddChild(GalePptSequence.FirstPlay())
    self.ppt_seq:SetVAnchor(ANCHOR_MIDDLE)
    self.ppt_seq:SetHAnchor(ANCHOR_MIDDLE)
    self.ppt_seq:SetPosition(0,0,0)
    self.ppt_seq:FadeIn(1)

    self.finishing = false 
    self.can_click = false 
    self.on_finish_fn = on_finish_fn 
    self.continue_btns = {
        [CONTROL_ACCEPT] = true,
        [CONTROL_ACTION] = true,
        [CONTROL_ATTACK] = true,
    }

    self.inst:DoTaskInTime(4,function()
        self.ppt_seq:DoMouseClick()
        TheFrontEnd:GetSound():PlaySound("gale_bgm/bgm/p1_intro_sequence","gale_intro_music")
    end)
    self.inst:DoTaskInTime(6,function()
        self.ppt_seq:DoMouseClick()
        self.can_click = true 
    end)
end)

function GaleFirstCG:OnControl(control, down)
    
    if down and self.can_click then 
        if self.continue_btns[control] == true then
            if self.ppt_seq:AtEnd() and not self.finishing then
                TheFrontEnd:GetSound():KillSound("gale_intro_music")
                self.finishing = true
                if self.on_finish_fn then
                    self.on_finish_fn()
                end
                TheFrontEnd:PopScreen(self)

            else 

                self.ppt_seq:DoMouseClick()
    
                if self.ppt_seq.current_page == 9 then
                    TheFrontEnd:GetSound():KillSound("gale_intro_music")
                end
            end
        end
    end 


    if GaleFirstCG._base.OnControl(self,control, down) then
        return true
    end
end

return GaleFirstCG