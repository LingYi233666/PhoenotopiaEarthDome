require("json")

local function onjson_data(self,json_data)
    -- print("Server GalePortalManager:SetJsonData ",json_data)
    self.inst.replica.gale_portal_manager:SetJsonData(json_data)
end

local GalePortalManager = Class(function(self,inst)
	self.inst = inst

    self.portals = {}
    self.json_data = "{}"

    -- inst:DoTaskInTime(0.1,function()
	-- 	self:SearchPortalInEnts()
	-- end)
end,nil,{
    json_data = onjson_data
})

function GalePortalManager:SearchPortalInEnts()
    self.portals = {}
	for _,v in pairs(Ents) do 
		if v.components.gale_portal then 
			self:AddPortal(v)
		end
	end
end

function GalePortalManager:AddPortal(portal)
    self.portals[portal] = true 
    self:UpdateJson()
end

function GalePortalManager:RemovePortal(portal)
    self.portals[portal] = nil 
    self:UpdateJson()
end

function GalePortalManager:GetPortalByGUID(guid)
    for portal,_ in pairs(self.portals) do 
        if portal.GUID == guid then
            return portal
        end
    end
end

local function WrapedPos(pos)
    return {x = pos.x,z = pos.z}
end

function GalePortalManager:UpdateJson()
	local tab = {}
	for portal,_ in pairs(self.portals) do 
        table.insert(tab,{guid = portal.GUID,pos = WrapedPos(portal:GetPosition())})
	end

	self.json_data = json.encode(tab)
end

return GalePortalManager