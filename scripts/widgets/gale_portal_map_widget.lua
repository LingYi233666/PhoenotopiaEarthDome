local Widget = require "widgets/widget"
local Image = require "widgets/image"

local GalePortalMapWidget = Class(Widget, function(self,owner)
    Widget._ctor(self, "GalePortalMapWidget")
	self.owner = owner

    self.minimap = TheWorld.minimap.MiniMap

    self.img = self:AddChild(Image())
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    -- self.img.inst.ImageWidget:SetBlendMode( BLENDMODE.Additive )

	self.minimap:ResetOffset()
end)

function GalePortalMapWidget:WorldPosToMapPos(x,y,z)
    return self.minimap:WorldPosToMapPos(x,y,z)
end

function GalePortalMapWidget:MapPosToWorldPos(x,y,z)
    return self.minimap:MapPosToWorldPos(x,y,z)
end

function GalePortalMapWidget:SetTextureHandle(handle)
	self.img.inst.ImageWidget:SetTextureHandle( handle )
end

function GalePortalMapWidget:OnZoomIn(  )
	if self.shown then
		self.minimap:Zoom( -1 )
	end
end

function GalePortalMapWidget:OnZoomOut( )
	if self.shown and self.minimap:GetZoom() < 20 then
		self.minimap:Zoom( 1 )
	end
end

function GalePortalMapWidget:UpdateTexture()
	local handle = self.minimap:GetTextureHandle()
	self:SetTextureHandle( handle )
end

function GalePortalMapWidget:ResetOffset()
	self.minimap:ResetOffset()
end

function GalePortalMapWidget:Offset(dx,dy)
	self.minimap:Offset(dx,dy)
end


function GalePortalMapWidget:OnShow()
	self.minimap:ResetOffset()
end

function GalePortalMapWidget:OnHide()

end

return GalePortalMapWidget
