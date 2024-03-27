local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local GaleForestLeaves = Class(Widget, function(self,owner) 
	Widget._ctor(self, "GaleForestLeaves") 
	self.owner = owner

	self.leavesTop = self:AddChild(UIAnim())
    self.leavesTop:SetClickable(false)
    self.leavesTop:SetHAnchor(ANCHOR_MIDDLE)
    self.leavesTop:SetVAnchor(ANCHOR_TOP)
    self.leavesTop:GetAnimState():SetBank("leaves_canopy2")
    self.leavesTop:GetAnimState():SetBuild("leaves_canopy2")
    self.leavesTop:GetAnimState():PlayAnimation("idle", true)
    self.leavesTop:GetAnimState():SetMultColour(1,1,1,1)   
    self.leavesTop:GetAnimState():SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.leavesTop:GetAnimState():UseColourCube(true)
    self.leavesTop:GetAnimState():SetUILightParams(2.0, 4.0, 4.0, 20.0)
    self.leavesTop:GetAnimState():AnimateWhilePaused(false)
    self.leavesTop:SetScaleMode(SCALEMODE_PROPORTIONAL)    
	self.leavesTop:Hide()

	self:MoveToBack()
	self:StartUpdating()
end)




function GaleForestLeaves:UpdateLeaves(dt)

	local wasup = false
	if self.leavestop_intensity and self.leavestop_intensity > 0 then
		wasup = true
	end


	if self.leavesTop then
	    if not self.leavestop_intensity then
	    	self.leavestop_intensity = 0
	    end	 

	    local player = self.owner
	    local nearby_tree_pillar = FindEntity(player, 17.5,nil,nil,{ "INLIMBO"},{ "gale_forest_pillar_tree",})
        -- local nearby_tree_pillar = FindEntity(player, 17.5,function(ent)
        --     return ent.prefab == "pigking"
        -- end,nil,{ "INLIMBO"})
	    self.under_leaves = nearby_tree_pillar ~= nil 


	 	if self.under_leaves then
			self.leavestop_intensity = math.min(1,self.leavestop_intensity+(1/30) )
		else	
		 	self.leavestop_intensity = math.max(0,self.leavestop_intensity-(1/30) )
		end	

	    if self.leavestop_intensity == 0 then

	    	self.leavesTop:Hide()
	    else
	    	self.leavesTop:Show()

			if self.leavestop_intensity == 1 then
		    	if not self.leavesfullyin then
		    		self.leavesTop:GetAnimState():PlayAnimation("idle", true)	
		    		self.leavesfullyin = true
		    	else	
			    	if player:HasTag("moving") then
			    		if not self.leavesmoving then
			    			self.leavesmoving = true
			    			self.leavesTop:GetAnimState():PlayAnimation("run_pre")	
			    			self.leavesTop:GetAnimState():PushAnimation("run_loop", true)					    					    	
			    		end
			    	else
			    		if self.leavesmoving then
			    			self.leavesmoving = nil
			    			self.leavesTop:GetAnimState():PlayAnimation("run_pst")	
			    			self.leavesTop:GetAnimState():PushAnimation("idle", true)	
			    			self.leaves_olddir = nil
			    		end
			    	end
		    	end
		    else
		    	self.leavesfullyin = nil
		    	self.leavesmoving = nil
		    	self.leavesTop:GetAnimState():SetPercent("zoom_in", self.leavestop_intensity)
			end	    	
	    end	   

    end

    self:MoveToBack()
end

function GaleForestLeaves:OnUpdate(dt)
	if TheWorld:HasTag("cave") then 
		self:StopUpdating()
        if self.shown then
            self:Hide()
        end
		
	else
        if not self.shown then
		    self:Show()
        end 
		self:UpdateLeaves(dt)
	end
	
end

return GaleForestLeaves