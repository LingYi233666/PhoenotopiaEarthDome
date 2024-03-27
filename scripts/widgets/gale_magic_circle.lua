local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"

-- ThePlayer.HUD.controls.status.gale_magic_circle:SetPercentMoving(0.33)
-- ThePlayer.HUD.controls.status.gale_magic_circle:SetPercent(0.33)
-- ThePlayer.HUD.controls.status.gale_magic_circle.radius = 170
-- ThePlayer.HUD.controls.status.gale_magic_circle:Test()
local GaleMagicCircle = Class(Widget,function(self,owner)
    Widget._ctor(self, "GaleMagicCircle")

    self.owner = owner

    self.radius = 165

    self.target_bar_alpha = 0
    self.target_percent = 1.0
    self.current_percent = 1.0

    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBank("gale_magic_circle")
	self.bg:GetAnimState():SetBuild("gale_magic_circle")
    self.bg:GetAnimState():SetPercent("idle",1.0)
    self.bg:GetAnimState():SetMultColour(0.1,0.1,0.1,0.6)

    self.circle = self:AddChild(UIAnim())
    self.circle:GetAnimState():SetBank("gale_magic_circle")
	self.circle:GetAnimState():SetBuild("gale_magic_circle")
    -- self.circle:GetAnimState():SetMultColour(1,1,1,0.6)
    -- self.circle:GetAnimState():SetBloomEffectHandle("shaders/anim.ksh")
    -- self.circle:GetAnimState():SetHaunted(true)

    self.bar = self:AddChild(UIAnim())
    self.bar:GetAnimState():SetBank("gale_magic_circle")
	self.bar:GetAnimState():SetBuild("gale_magic_circle")
    self.bar:GetAnimState():PlayAnimation("bar")
    -- self.bar:GetAnimState():SetBloomEffectHandle("shaders/anim.ksh")


    self.inst:ListenForEvent("GaleMagic.current",function(owner)
        if owner ~= self.owner then
            return 
        end

        local percent = self.owner.replica.gale_magic:IsEnable() 
                            and self.owner.replica.gale_magic:GetPercent()
                            or 0
        
        self:SetPercentMoving(percent)
    end,self.owner)

    self.inst:ListenForEvent("GaleMagic.enable",function(owner)
        if owner ~= self.owner then
            return 
        end
        
        local percent = self.owner.replica.gale_magic:IsEnable() 
                            and self.owner.replica.gale_magic:GetPercent()
                            or 0

        self:SetPercentMoving(percent)
    end,self.owner)

    local function UpdateShownHUD(owner)
        if owner ~= self.owner then
            return 
        end

        if self.owner.replica.gale_magic:IsHUDEnable() and not self.shown then
            local percent = self.owner.replica.gale_magic:IsEnable() 
                            and self.owner.replica.gale_magic:GetPercent()
                            or 0
            self:Show()
            self:SetPercent(0)
            self:SetPercentMoving(percent)
        elseif not self.owner.replica.gale_magic:IsHUDEnable() and self.shown then
            self:Hide()
            self:SetPercentMoving(0)
        end
    end

    self.inst:ListenForEvent("GaleMagic.enable_HUD",UpdateShownHUD,self.owner)

    self:SetPercent(0)
    self:Hide()
end)

function GaleMagicCircle:Test()
    if self.task then
        KillThread(self.task)
    end

    self.task = self.inst:StartThread(function()
        local percent = 0

        while percent < 1 do
            self:SetPercent(percent)
            percent = math.min(percent + 0.01,1)

            Sleep(0)
        end
        self:SetPercent(percent)

        self.task = nil 
    end)
end

function GaleMagicCircle:SetBarAlpha(target_bar_alpha)
    self.target_bar_alpha = target_bar_alpha

    if self.alpha_task == nil then
        self.alpha_task = self.inst:StartThread(function()
            local r,g,b,a = self.bar:GetAnimState():GetMultColour()
            local delta_alpha = self.target_bar_alpha - a
            local abs_delta_alpha = math.abs(delta_alpha)

            while abs_delta_alpha > 0 do
                local additive = math.min(0.1,abs_delta_alpha)
                if delta_alpha < 0 then
                    additive = -additive
                end

                self.bar:GetAnimState():SetMultColour(r,g,b,a+additive)

                r,g,b,a = self.bar:GetAnimState():GetMultColour()
                delta_alpha = self.target_bar_alpha - a
                abs_delta_alpha = math.abs(delta_alpha)

                Sleep(0)
            end
    
            self.alpha_task = nil 
        end)
    end
end

function GaleMagicCircle:SetPercentMoving(percent)
    self.target_percent = percent


    if self.percent_task == nil then
        local segment = 1 / 205

        self.percent_task = self.inst:StartThread(function()
            local delta_percent = self.target_percent - self.current_percent
            local abs_delta_percent = math.abs(delta_percent)

            while abs_delta_percent > segment do
                local additive = math.max(segment,abs_delta_percent * 0.2)
                if delta_percent < 0 then
                    additive = -additive
                end

                self:SetPercent(math.clamp(self.current_percent+additive,0,1))


                delta_percent = self.target_percent - self.current_percent
                abs_delta_percent = math.abs(delta_percent)

                Sleep(0)
            end
            self:SetPercent(self.target_percent)
    
            self.percent_task = nil 
        end)
    end
end

function GaleMagicCircle:SetPercent(percent)
    -- print("Set percent",percent)
    self.current_percent = percent

    local visual_percent = math.clamp(percent,0,1)
    local rot = Remap(visual_percent,0,1,-40,-245) * DEGREES
    local pos = Vector3(math.cos(rot),math.sin(rot)) * self.radius

    self.circle:GetAnimState():SetPercent("idle",visual_percent)

    self.bar:SetPosition(pos)
    self.bar:SetRotation(-rot * RADIANS)

    if percent >= 1 or percent <= 0 then
        -- self.bar:Hide()
        -- self.bar.
        self:SetBarAlpha(0)
    else
        -- self.bar:Show()
        self:SetBarAlpha(1)
    end
end


return GaleMagicCircle