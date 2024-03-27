AddReplicableComponent("gale_stamina")
AddReplicableComponent("gale_magic")


local GaleStaminaBadge = require("widgets/gale_stamina_badge")
local GaleMagicCircle = require("widgets/gale_magic_circle")

AddClassPostConstruct("widgets/statusdisplays",function(self)
    if self.owner:HasTag("gale") then
        self.gale_stamina_badge = self:AddChild(GaleStaminaBadge(self.owner))
        self.gale_stamina_badge:SetPosition(-62,-52, 0)
        -- self.gale_stamina_badge:SetPosition(-124,35, 0)

        self.gale_magic_circle = self:AddChild(GaleMagicCircle(self.owner))
        self.gale_magic_circle:SetPosition(-62,-52, 0)
        -- self.gale_magic_circle:SetPosition(-124,35, 0)
        self.gale_magic_circle:SetScale(0.5)

        self.boatmeter:SetPosition(-130,80)
    end
end)


AddStategraphState("wilson",State
{
    name = "gale_tired_low_stamina",
    tags = {"busy","nopredict","gale_tired_low_stamina"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()
        inst.AnimState:PlayAnimation("idle_groggy01_pre")
        inst.AnimState:PushAnimation("idle_groggy01_loop", false)
        inst.AnimState:PushAnimation("idle_groggy01_pst", false)

        inst.SoundEmitter:PlaySound("gale_sfx/other/p1_tool_fail")
    end,

    events = {
        EventHandler("attacked", function(inst)
            inst.sg:GoToState("gale_tired_low_stamina_knockback")
        end),

        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})

AddStategraphState("wilson",State
{
    name = "gale_tired_low_stamina_knockback",
    tags = {"busy","nopredict","gale_tired_low_stamina"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()


        inst.sg.statemem.percent = 0.8

        inst.AnimState:SetPercent("buck_pst",inst.sg.statemem.percent)
    end,

    onupdate = function(inst)
        -- ThePlayer.sg:GoToState("gale_tired_low_stamina_knockback")
        if inst.sg.statemem.percent <= 0.72 then
            inst.sg:GoToState("gale_tired_low_stamina_knockback_pst",0.42)
            return 
        end
        inst.sg.statemem.percent = math.max(0,inst.sg.statemem.percent - 3 * FRAMES)
        inst.AnimState:SetPercent("buck_pst",inst.sg.statemem.percent)
    end,

    events = {
        -- EventHandler("animqueueover", function(inst)
        --     if inst.AnimState:AnimDone() then
        --         inst.sg:GoToState("idle")
        --     end
        -- end),
    },

})

AddStategraphState("wilson",State
{
    name = "gale_tired_low_stamina_knockback_pst",
    tags = {"busy","nopredict","gale_tired_low_stamina"},

    onenter = function(inst,percent)
        inst.components.locomotor:Stop()
        inst:ClearBufferedAction()

        inst.AnimState:PlayAnimation("buck_pst")
        local length = inst.AnimState:GetCurrentAnimationLength()
        inst.AnimState:SetTime(length * percent)

        inst.AnimState:SetDeltaTimeMultiplier(0.3)
    end,

    onupdate = function(inst)
        local current = inst.AnimState:GetCurrentAnimationTime() 
        local length = inst.AnimState:GetCurrentAnimationLength() 
        local percent = current / length

        if percent >= 0.66 then
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end
    end,


    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end

})

-- AddPrefabPostInit("player_classified",function(inst)

--     inst.gale_magic_current = net_float(inst.GUID,"GaleMagic.current","GaleMagic.current")
--     inst.gale_magic_max = net_float(inst.GUID,"GaleMagic.max") 

--     inst.gale_magic_enable = net_bool(inst.GUID,"GaleMagic.enable","GaleMagic.enable")
--     inst.gale_magic_enable_HUD = net_bool(inst.GUID,"GaleMagic.enable_HUD","GaleMagic.enable_HUD")

--     if not TheNet:IsDedicated() then
--         return 
--     end
-- end)