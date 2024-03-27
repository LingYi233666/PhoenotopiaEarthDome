require("json")

local GalePortalManager = Class(function(self,inst)
	self.inst = inst

    self.portals = {}
    self.json_data = net_string(inst.GUID,"GalePortalManager.json_data","gale_portal_json_dirty")

    inst:ListenForEvent("gale_portal_json_dirty",function()
        self.portals = json.decode(self.json_data:value())
    end)
end)

-- {guid = portal.GUID,pos = WrapedPos(portal:GetPosition())}
function GalePortalManager:SetJsonData(json_data)
    -- print("Client GalePortalManager:SetJsonData ",json_data)
    self.json_data:set(json_data)
    
end

return GalePortalManager