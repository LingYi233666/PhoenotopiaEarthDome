local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local GaleDarkVisionHover = Class(Widget, function(self,owner) 
	Widget._ctor(self, "GaleDarkVisionHover") 

	self.owner = owner
    self.percent = 1.0


	self.hover = self:AddChild(UIAnim())
    self.hover:SetClickable(false)
    self.hover:SetHAnchor(ANCHOR_MIDDLE)
    self.hover:SetVAnchor(ANCHOR_MIDDLE)
    self.hover:GetAnimState():SetBank("gale_dark_vision_ui")
    self.hover:GetAnimState():SetBuild("gale_dark_vision_ui")
    self.hover:GetAnimState():AnimateWhilePaused(false)
    -- self.hover:SetScaleMode(SCALEMODE_FILLSCREEN)    

    local my_w,my_h = 852,480
    local scr_w, scr_h = TheSim:GetScreenSize() 

    self.hover:SetScale(scr_w / my_w,scr_h / my_h)
end)

local SPEED = 3 
function GaleDarkVisionHover:Start()
    if self.task then
        KillThread(self.task)
    end
    TheFocalPoint.SoundEmitter:PlaySound("gale_sfx/skill/dark_vision")
    self.task = self.owner:StartThread(function()
        -- Close Eyes 
        self.percent = 1
        while self.percent > 0 do
            self.hover:GetAnimState():SetPercent("open",self.percent)

            self.percent = math.max(0,self.percent - SPEED * FRAMES / self.hover:GetAnimState():GetCurrentAnimationLength())

            Sleep(0)
        end
        SendModRPCToServer(MOD_RPC["gale_rpc"]["dark_vision_ui2server"],true)
        -- Open Eyes 
        while self.percent < 0.8 do
            self.hover:GetAnimState():SetPercent("open",self.percent)

            self.percent = math.max(0,self.percent + SPEED * FRAMES / self.hover:GetAnimState():GetCurrentAnimationLength())

            Sleep(0)
        end

        self.task = nil 
    end)
end

function GaleDarkVisionHover:End()
    if self.task then
        KillThread(self.task)
    end
    self.task = self.owner:StartThread(function()
        -- Close Eyes 
        self.percent = 0.8 
        while self.percent > 0 do
            self.hover:GetAnimState():SetPercent("open",self.percent)

            self.percent = math.max(0,self.percent - SPEED * FRAMES / self.hover:GetAnimState():GetCurrentAnimationLength())

            Sleep(0)
        end

        SendModRPCToServer(MOD_RPC["gale_rpc"]["dark_vision_ui2server"],false)

        -- Open Eyes 
        while self.percent < 1 do
            self.hover:GetAnimState():SetPercent("open",self.percent)

            self.percent = math.max(0,self.percent + SPEED * FRAMES / self.hover:GetAnimState():GetCurrentAnimationLength())

            Sleep(0)
        end

        self.task = nil 

        self:Kill()
    end)
end

return GaleDarkVisionHover