
AddClassPostConstruct("widgets/playeravatarpopup", function(self)
    -- print("Ly modified playeravatarpopup !!!")

    local old_UpdateEquipWidgetForSlot = self.UpdateEquipWidgetForSlot

    self.UpdateEquipWidgetForSlot = function(self,image_group, slot, equipdata,...)
        local old_ret = old_UpdateEquipWidgetForSlot(self,image_group, slot, equipdata,...)

        if equipdata ~= nil then
            local equip_item = self.owner.replica.inventory and self.owner.replica.inventory:GetEquippedItem(slot)

            if equip_item then
                local atlas_name = equip_item.replica.inventoryitem:GetAtlas()
                local image_name = equip_item.replica.inventoryitem:GetImage()
                image_group._image:SetTexture(atlas_name,image_name)
            end


            
        end

        return old_ret
    end
end)