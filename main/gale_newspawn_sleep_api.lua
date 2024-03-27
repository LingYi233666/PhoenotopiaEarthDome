AddStategraphState("wilson", 
	State
    {
        name = "gale_newspawn_sleeping",
        tags = {"busy","sleeping","nopredict"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sleep_loop",true)
            
            inst:AddTag("gale_newspawn_sleeping")
            inst.sg.statemem.this_state = 0
        end,

        onupdate = function(inst)
            if inst.sg.statemem.this_state == 1 then
                inst.sg.statemem.this_state = 2

                inst.sg:RemoveStateTag("sleeping")
                -- TODO:Play wake up anim
                inst.AnimState:PlayAnimation("wakeup")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.this_state == 2 then
                    inst.sg:GoToState("yawn")
                end
            end),
        },      

        onexit = function(inst)
            inst:RemoveTag("gale_newspawn_sleeping")
        end,
    }
)

AddModRPCHandler("gale_rpc","gale_newspawn_wakeup",function(inst)
    if inst.sg and inst.sg.currentstate 
        and inst.sg.currentstate.name == "gale_newspawn_sleeping" 
        and inst.sg.statemem and inst.sg.statemem.this_state == 0 then
        
        inst.sg.statemem.this_state = 1
    end
end)

-- local spear=ThePlayer:SpawnChild("gale_spear_projectile") spear:SetPosition(1,0,0) spear:ForceFacePoint(ThePlayer:GetPosition():Get())



local move_btns = {
    CONTROL_MOVE_UP,
    CONTROL_MOVE_DOWN,
    CONTROL_MOVE_LEFT,
    CONTROL_MOVE_RIGHT,

    CONTROL_PRIMARY,
    CONTROL_SECONDARY,
    
    CONTROL_ACCEPT,
    CONTROL_ACTION,
    CONTROL_ATTACK,
}

local function IsHUDScreen() 
	local defaultscreen = false 
	if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name  and type(TheFrontEnd:GetActiveScreen().name) == "string"  and TheFrontEnd:GetActiveScreen().name == "HUD" then 
		defaultscreen = true 
	end 
	return defaultscreen 
end  


TheInput:AddGeneralControlHandler(function(control, pressed)
    if IsHUDScreen() and pressed and ThePlayer and ThePlayer:HasTag("gale_newspawn_sleeping") then 
        -- print("New spawn sleep test",control)
        if table.contains(move_btns,control) then 
            SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_newspawn_wakeup"])
        end 
    end
end)