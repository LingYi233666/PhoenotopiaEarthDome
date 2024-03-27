local GalePortal = Class(function(self,inst)
	self.inst = inst

    self.icon = nil

    inst:AddTag("gale_portal")

    -- inst:DoTaskInTime(0,function ()
    --     self:AddInstToPortals()
    --     self:EnableIcon(true)
    -- end)
	


	inst:ListenForEvent("onremove",function()
		self:RemoveInstFromPortals()
	end)
end)

function GalePortal:EnableIcon(enable)
    if enable then
        if self.icon ~= nil then
            self.icon:Remove()
        end
        self.icon = SpawnPrefab("globalmapicon")
        self.icon:TrackEntity(self.inst)
    else 
        if self.icon ~= nil then
            self.icon:Remove()
            self.icon = nil 
        end
    end
end

function GalePortal:AddInstToPortals()
    TheWorld.net.components.gale_portal_manager:AddPortal(self.inst)
end

function GalePortal:RemoveInstFromPortals()
    TheWorld.net.components.gale_portal_manager:RemovePortal(self.inst)
end

return GalePortal