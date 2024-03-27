local Polygon = require("util/polygon")
local Rectangle = require("util/rectangle")
local GaleCommon = require("util/gale_common")

local function CreateCameraTarget()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    

    inst:AddTag("NOCLICKED")
    inst:AddTag("NOBLOCK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    return inst
end

local GaleInteriorRoom = Class(function(self,inst)

    ----------------------  Common functions  ----------------------
    self.inst = inst

    self.polygon = nil 
    self.waterarea_polygon_list = {}

    self.physics_obj = nil 

    TheWorld.components.gale_interior_room_manager:Add(inst)
    inst:ListenForEvent("onremove",function ()
        TheWorld.components.gale_interior_room_manager:Remove(inst)
    end)

    inst:DoTaskInTime(0,function()
        inst:ForceFacePoint((inst:GetPosition() + Vector3(1,0,0)):Get())
    end)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")
    -------------------  End of Common functions  ------------------




    ----------------------  Client side only  ----------------------
    if not TheNet:IsDedicated() then
        self.camera_target = CreateCameraTarget() 
        self.camera_target:DoTaskInTime(0,function()
            self.camera_target.Transform:SetPosition(self.inst:GetPosition():Get())
        end)
        
        self.camera_target:ListenForEvent("onremove",function()
            self.camera_target:Remove()
        end,self.inst)

        self.camera_target_update_fn = nil 

        self.camera_target:DoPeriodicTask(0,function()
            -- if TheCamera and TheCamera
            if self.inst and ThePlayer and self.camera_target_update_fn then
                local sourcetbl = TheFocalPoint.components.focalpoint.targets[self.inst]
                if sourcetbl and sourcetbl["gale_interior_room"] then
                    if sourcetbl["gale_interior_room"].target == self.camera_target then
                        self.camera_target_update_fn(self.camera_target,self.inst,ThePlayer)
                    end
                end
            end
            
        end)
    end
    -------------------  End of Client functions  ------------------




    ----------------------  Server side only  ----------------------
    if TheNet:GetIsMasterSimulation() then
        -- Layouts
        self.layouts = {}
        self.layouts_data = {}

        self.extra_built_fn = nil

        self.shore_pos_fn = nil 

        self.inst:ListenForEvent("onremove",function()

            self:DeleteInside()
        end)
    end
    -------------------  End of Server functions  ------------------

end)



function GaleInteriorRoom:SetRectWH(w,h)
    self:SetPolygon(Rectangle(w,h))
end

function GaleInteriorRoom:SetPolygon(polygon)
    self.polygon = nil 

    self.polygon = polygon

    if self.physics_obj and self.physics_obj:IsValid() then
        self.physics_obj:Remove()
        self.physics_obj = nil 
    end

    self.physics_obj = SpawnPrefab("gale_polygon_physics")
    self.physics_obj:AttachPolygon(self.polygon,33)
    
    GaleCommon.AddConstrainedPhysicsObj(self.inst, self.physics_obj)
end

function GaleInteriorRoom:AddWaterPolygon(polygon)
    table.insert(self.waterarea_polygon_list,polygon)
end

function GaleInteriorRoom:IsInside(tar_pos)
    if self.polygon == nil then
        return false
    end

    -- transform tar_pos to a relative pos
    local relative_pos = tar_pos - self.inst:GetPosition()
    
    return self.polygon:IsInside(relative_pos)
end

function GaleInteriorRoom:IsInRoomWaterArea(tar_pos)
    -- transform tar_pos to a relative pos
    local relative_pos = tar_pos - self.inst:GetPosition()

    for _,v in pairs(self.waterarea_polygon_list) do
        if v:IsInside(relative_pos) then
            return true 
        end
    end

    return false
end

function GaleInteriorRoom:SetCameraTargetUpdateFn(fn)
    self.camera_target_update_fn = fn 
end

function GaleInteriorRoom:DeleteInside()
    -- for k,v in pairs(self.layouts) do
    --     if v:IsValid() and self:IsInside(v:GetPosition()) then
    --         v:Remove()
    --     end
    -- end
    for k,v in pairs(Ents) do
        if v and v.IsValid and v:IsValid() 
            and v.entity and v.entity:GetParent() == nil 
            and not v:HasTag("player")
            and v.Transform and self:IsInside(v:GetPosition()) then
            v:Remove()
        end
    end
    self.layouts = {}
end

function GaleInteriorRoom:OnBuilt(builder)
    if not TheNet:GetIsMasterSimulation() then
        return 
    end

    self:SpawnLayouts(self.layouts_data,true)
    if self.extra_built_fn then
        self.extra_built_fn(self.inst,builder)
    end
end

function GaleInteriorRoom:ReBuild(builder)
    self:DeleteInside()
    self.inst:OnBuilt(builder)
end

function GaleInteriorRoom:AddLayout(name,data)
    local ent = SpawnAt(FunctionOrValue(data.prefab),
                                    self.inst:GetPosition(),
                                    nil,
                                    FunctionOrValue(data.offset or Vector3(0,0,0)))
    self.layouts[name] = ent
    if data.fn then
        -- ent,room,new_spawned,on_loaded
        data.fn(ent,self.inst,true)
    end

    return ent
end

function GaleInteriorRoom:SpawnLayouts(datas,force)
    local num_ents = table.count(self.layouts)

    if force or num_ents <= 0 then
        for k,v in pairs(self.layouts) do
            if v:IsValid() then
                v:Remove()
            end
        end
        self.layouts = {}

        for name,data in pairs(datas) do
            local ent = self:AddLayout(name,data)
        end
    else 
        -- print("[GaleInteriorRoom]Can't spawn doors,force:",force,"num_doors:",num_doors)
    end
end

function GaleInteriorRoom:GetShorePos(target)
    return self.shore_pos_fn == nil and self.inst:GetPosition() or self.shore_pos_fn(self.inst,target)
end

function GaleInteriorRoom:OnSave()
    if not TheNet:GetIsMasterSimulation() then
        return {}
    end

    local data = {
        layout_GUIDs = {},
    }
    local references = {}

    for name,ent in pairs(self.layouts) do
        if ent:IsValid() then
            data.layout_GUIDs[name] = ent.GUID
            table.insert(references,ent.GUID)
        end
        
    end

    return data,references
end

function GaleInteriorRoom:OnLoad(data)
    if not TheNet:GetIsMasterSimulation() then
        return 
    end
    if data ~= nil then
        
    end
end

function GaleInteriorRoom:LoadPostPass(newents, savedata)
    if not TheNet:GetIsMasterSimulation() then
        return 
    end

    if savedata ~= nil then
        if savedata.layout_GUIDs ~= nil then
            for name,guid in pairs(savedata.layout_GUIDs) do
                local new_ent = newents[guid]
                if new_ent then
                    self.layouts[name] = new_ent.entity
                    if self.layouts_data[name] and self.layouts_data[name].fn then
                        self.layouts_data[name].fn(new_ent.entity,self.inst,false,true)
                    end
                end
            end
        end
    end
end

function GaleInteriorRoom:GetDebugString()
    local ret = ""
    for name,v in pairs(self.layouts) do
        local cut = string.format("%s %s",name,tostring(v))
        if not v:IsValid() then
            cut = cut.." (Invalid)"
        else 
            cut = cut.." "..tostring(v:GetPosition() - self.inst:GetPosition())
        end
        ret = ret.."\n"..cut
    end

    return ret
end


return GaleInteriorRoom