local Text = require "widgets/text"



AddClassPostConstruct("widgets/containerwidget", function(self)
    local old_Open = self.Open 
    local old_Close = self.Close 

    self.Open = function(self,container, doer,...)
        local old_ret = old_Open(self,container, doer,...)

        local function UpdateAmmo(pistol)
            self.GaleBlasterAmmoText:SetString(string.format("%02d",pistol._num_ammo:value()))
        end

        if container.prefab == "msf_silencer_pistol" then
            self.GaleBlasterAmmoTitle = self:AddChild(Text(DEFAULTFONT,40,"AMMO"))
            self.GaleBlasterAmmoTitle:SetPosition(0,65)

            self.GaleBlasterAmmoText = self:AddChild(Text(DEFAULTFONT,55,"00"))
            self.GaleBlasterAmmoText:SetPosition(0,25)
            self.GaleBlasterAmmoText.inst:ListenForEvent("inst._num_ammo",UpdateAmmo,container)
            UpdateAmmo(container)
        end
        return old_ret
    end

    self.Close = function(self,...)
        if self.GaleBlasterAmmoTitle then
            self.GaleBlasterAmmoTitle:Kill()
            self.GaleBlasterAmmoTitle = nil 
        end

        if self.GaleBlasterAmmoText then
            self.GaleBlasterAmmoText:Kill()
            self.GaleBlasterAmmoText = nil 
        end

        return old_Close(self,...)
    end

end)