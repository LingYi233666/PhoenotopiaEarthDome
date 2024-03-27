local Assets_Lamp = {
    Asset("ANIM", "anim/joystick.zip"),

    Asset( "IMAGE", "images/ui/lamp/gale_lamp_link.tex" ),
    Asset( "ATLAS", "images/ui/lamp/gale_lamp_link.xml" ),

    Asset( "IMAGE", "images/ui/lamp/gale_lamp_link2.tex" ),
    Asset( "ATLAS", "images/ui/lamp/gale_lamp_link2.xml" ),

    Asset( "IMAGE", "images/ui/lamp/gale_lamp_middle.tex" ),
    Asset( "ATLAS", "images/ui/lamp/gale_lamp_middle.xml" ),
}

for _,v in pairs(Assets_Lamp) do
    table.insert(Assets,v)
end


local GaleLampUi = require("widgets/gale_lamp_ui")

AddClassPostConstruct("widgets/containerwidget", function(self)
    local old_Open = self.Open 
    local old_Close = self.Close 
    self.Open = function(self,container, doer,...)
        local old_ret = old_Open(self,container, doer,...)
        if container.prefab == "gale_lamp" then
            self.GaleLampUi = self:AddChild(GaleLampUi(doer,container))

            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/container_open")
        end
        return old_ret
    end

    self.Close = function(self,...)
        if self.GaleLampUi then
            self.GaleLampUi:Kill()
            self.GaleLampUi = nil 

            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/Together_HUD/container_close")
        end

        return old_Close(self,...)
    end

end)

AddModRPCHandler("gale_rpc","gale_lamp_dodelta",function(inst,lamp,delta)
    if lamp.prefab == "gale_lamp" and lamp.components.fueled then
        lamp.components.fueled:DoDelta(delta)
    end
end)

AddModRPCHandler("gale_rpc","gale_lamp_crack",function(inst,lamp,delta)
    if lamp.prefab == "gale_lamp" then
        lamp.SoundEmitter:PlaySound("gale_sfx/lamp/p1_lamp_crank")
    end
end)