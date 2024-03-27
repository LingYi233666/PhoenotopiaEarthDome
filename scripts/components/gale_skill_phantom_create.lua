local GaleSkillPhantomCreate = Class(function(self,inst)
    self.inst = inst
end)

function GaleSkillPhantomCreate:Create(target)
    target:AddTag("transform_to_phantom")
    target.persists = false 

    target.emrge_vfx = target:SpawnChild("gale_shadow_emerge_vfx")

    target.SoundEmitter:PlaySound("gale_sfx/skill/misc_rumble_loop","emrging")

    target.shake_task = target:DoPeriodicTask(0.5,function()
        ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, 0.5, target, 40)
    end)

    target:DoTaskInTime(1,function()
        target.fade_to_black_task = target:DoPeriodicTask(0,function()
            local r,g,b,a = target.AnimState:GetMultColour()
            r = math.max(0,r - 0.33 * FRAMES)
            g = math.max(0,g - 0.33 * FRAMES)
            b = math.max(0,b - 0.33 * FRAMES)
    
            target.AnimState:SetMultColour(r,g,b,a)
    
            if r <= 0 and g <= 0 and b <= 0 then
                target.fade_to_black_task:Cancel()
                target.fade_to_black_task = nil 
            end
        end)
    end)
    

    target:DoTaskInTime(1.3,function()
        target:StartThread(function()
            for i = 1,math.random(5,7) do
                local rad = math.random() * PI * 2
                local offset = Vector3(math.cos(rad),0,math.sin(rad)) * 0.66
        
                local puddle = SpawnAt("gale_skill_phantom_create_puddle",target:GetPosition() + offset)

                puddle:DoTaskInTime(GetRandomMinMax(14,18),puddle.ResumeAnim)
                Sleep(GetRandomMinMax(0,0.1))
            end
        end)
        
        target:DoPeriodicTask(0.3,function()
            local rad = math.random() * PI * 2
            local offset = Vector3(math.cos(rad),0,math.sin(rad)) * GetRandomMinMax(0,1.2)
    
            SpawnAt("cane_ancient_fx",target:GetPosition() + offset)
        end)

        
    end)

    target:DoTaskInTime(2.2,function()
        target:DoPeriodicTask(0.1,function()
            local rad = math.random() * PI * 2
            local offset = Vector3(math.cos(rad),0,math.sin(rad)) * GetRandomMinMax(0,1.2)
    
            SpawnAt("gale_skill_phantom_create_splash",target:GetPosition() + offset).Transform:SetScale(0.6,0.6,0.6)
        end)
    end)

    target:DoTaskInTime(6,function()
        target.emrge_vfx:Remove()
        target.emrge_vfx = nil 
        -- target.emrge_vfx._emit_point:set(false)
        target.SoundEmitter:KillSound("emrging")

        target.shake_task:Cancel()
        target.shake_task = nil 
    end)
    
    target:DoTaskInTime(6.5,function()
        -- Spawn Phantom
        SpawnAt("statue_transition_2",target)

        local x,y,z = target:GetPosition():Get() 
        local pet = self.inst.components.petleash:SpawnPetAt(x,0,z,"gale_skill_phantom")
        pet.sg:GoToState("reborn")

        
        target:Remove()

    end)
    
end

-- ThePlayer.components.gale_skill_phantom_create:Create(c_findnext("skeleton"))

return GaleSkillPhantomCreate