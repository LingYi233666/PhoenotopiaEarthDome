local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local GaleTooltip = require "widgets/galetooltip"
local ImageButton = require "widgets/imagebutton"
local GaleSkillSlot = require "widgets/galeskillslot"

local GaleSkillTreeWidget = Class(Widget,function(self,owner,tree,desc_ui,start_pos,w,h)
    Widget._ctor(self,"GaleSkillTreeWidget")

    local scr_w,scr_h = TheSim:GetScreenSize()

    self.owner = owner

    self.tree = tree

    self.desc_ui = desc_ui

    self.nodes = {}

    self.start_pos = start_pos or Vector3(-450,-200,0)
    
    self.spacing_w = w or 220
    self.spacing_h = h or 125

    for k,node in pairs(self.tree:ListByLeft(true)) do
        if k > 1 then
            local data = node.data 

            local grid_pos = data.ui_pos
            -- local node_ui = self:AddChild(Text(DEFAULTFONT,40,tostring(STRINGS.GALE_UI.SKILL_NODES[data.code_name:upper()].NAME)))
            
            local skill_atlas = "images/ui/skill_slot/"..data.code_name:lower()..".xml"
            local skill_image = data.code_name:lower()..".tex"
            
            local node_ui = self:AddChild(GaleSkillSlot(data.code_name,skill_atlas,skill_image))
            node_ui:SetScale(0.75)
            node_ui:SetPosition(self:Grid2Pos(grid_pos:Get()))
            node_ui:SetOnClick(function()
                self.desc_ui:SetTarget(data.code_name:upper())
            end)
            
            local poses = {}
            for _,child in pairs(node.childs) do
                local child_grid_pos = child.data.ui_pos
                table.insert(poses,self:Grid2Pos(child_grid_pos:Get()))
                
            end

            if #poses > 0 then
                self:DrawLines(self:Grid2Pos(grid_pos:Get()),poses)
            end
            
            self.nodes[data.code_name:upper()] = node_ui
        end
    end
end)

function GaleSkillTreeWidget:Grid2Pos(x,y)
    return self.start_pos + Vector3(self.spacing_w * x,self.spacing_h * y,0)
end

function GaleSkillTreeWidget:DrawLine(from,to)
    local line = self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex"))
    local delta_pos = to - from

    line:SetVRegPoint(ANCHOR_BOTTOM)
	line:SetHRegPoint(ANCHOR_MIDDLE)

    line:SetPosition(from)
    line:SetRotation(90 - math.atan2(delta_pos.y, delta_pos.x) / DEGREES)
    line:SetSize(8,delta_pos:Length())
    line:MoveToBack()
end

function GaleSkillTreeWidget:DrawLines(start,ends)
    local mid_end = start + Vector3(self.spacing_w / 2,0,0)
    self:DrawLine(start,mid_end)

    local max_y = ends[1].y
    local min_y = ends[1].y
    for _,v in pairs(ends) do
        if v.y > max_y then
            max_y = v.y
        end

        if v.y < min_y then
            min_y = v.y
        end

        self:DrawLine(Vector3(mid_end.x,v.y,0),v)
    end

    if max_y - mid_end.y > 0 then
        self:DrawLine(mid_end,mid_end + Vector3(0,max_y - mid_end.y,0))
    end

    if min_y - mid_end.y < 0 then
        self:DrawLine(mid_end,mid_end + Vector3(0,min_y - mid_end.y,0))
    end
end

function GaleSkillTreeWidget:OnUpdate()
    local can_unlock_skills = self.owner.replica.gale_skiller:GetCanUnlockSkill()
    for name,ui in pairs(self.nodes) do
        if self.owner.replica.gale_skiller:IsLearned(name:lower()) then
            ui:SetLockStatus("UNLOCKED")
        elseif table.contains(can_unlock_skills,name:lower()) then
            ui:SetLockStatus("CAN_UNLOCK")
        else
            ui:SetLockStatus("CANT_UNLOCK")
        end
    end
end

return GaleSkillTreeWidget