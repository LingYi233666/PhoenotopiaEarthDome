local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local GaleStaminaBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, nil, owner, { 168 / 255, 225 / 255, 42 / 255, 1 }, "gale_status_stamina_2")
	
	self.backing:GetAnimState():SetBank("status_meter")
    self.backing:GetAnimState():SetBuild("status_wet")
    self.backing:GetAnimState():Hide("frame")
    self.backing:GetAnimState():Hide("icon")

    self.staminaarrow = self.underNumber:AddChild(UIAnim())
    self.staminaarrow:GetAnimState():SetBank("sanity_arrow")
    self.staminaarrow:GetAnimState():SetBuild("sanity_arrow")
    self.staminaarrow:GetAnimState():PlayAnimation("neutral")
    self.staminaarrow:SetClickable(false)


    self.val = 100
    self.max = 100
	self.penaltypercent = 0
	
    self:StartUpdating()
end)

function GaleStaminaBadge:SetPercent(val, max,penaltypercent)
    self.val = val
    self.max = max
    Badge.SetPercent(self, self.val, self.max)
	
	self.penaltypercent = penaltypercent or 0
end

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function GaleStaminaBadge:OnUpdate(dt)
    local gale_stamina = self.owner.replica.gale_stamina
    -- if gale_stamina then
    --     if not self:IsVisible() then
    --         self:Show()
    --     end
    --     self:SetPercent(gale_stamina:GetPercent(), gale_stamina:GetMax())
    -- else 
    --     if self:IsVisible() then
    --         self:Hide()
    --     end
    -- end
    self:SetPercent(gale_stamina:GetPercent(), gale_stamina:GetMax())
	
end

return GaleStaminaBadge
