local trigger_tags = { "animal","character","player","monster","stationarymonster","insect","smallcreature","structure","seacreature"}
local trigger_and_inv_tags = ArrayUnion(trigger_tags,{"_inventoryitem"})
local no_trigger_tags = {"FX","INLIMBO","flyer","gale_creatureprox_exclude"}

local GaleCreatureProx = Class(function(self,inst)
    self.inst = inst

    self.dist_near = 0.8
    self.dist_far = 0.9
    self.include_inv = true

    self.ent_check_fn = nil 
    self.on_ents_enter = nil 
    self.on_ents_exit = nil 
    self.on_occupied = nil 
    self.on_empty = nil 

    self.ents = {}

    inst:DoTaskInTime(0,function()
        self:ForceUpdate()
    end)
end)

function GaleCreatureProx:SetDist(near,far)
    self.dist_near = near
    self.dist_far = far
end

function GaleCreatureProx:OnEntitySleep()
    self.inst:StopUpdatingComponent(self)
end

function GaleCreatureProx:OnEntityWake()
    self.inst:StartUpdatingComponent(self)
    self:ForceUpdate()
end

function GaleCreatureProx:ForceUpdate()
    self:OnUpdate(FRAMES)
end

function GaleCreatureProx:OnUpdate(dt,do_debug)
    -- print(self.inst,"updating...")
    local last_ents_cnt = table.count(self.ents)

    local x,y,z = self.inst.Transform:GetWorldPosition()
    local dist_ents = TheSim:FindEntities(x,y,z,
        self.dist_far,
        nil,
        no_trigger_tags,
        self.include_inv and trigger_and_inv_tags or trigger_tags
    )

    if self.ent_check_fn then
        local dist_ents_copy = shallowcopy(dist_ents)
        for k, ent in ipairs(dist_ents_copy) do
            if not self.ent_check_fn(self.inst,ent) then
                RemoveByValue(dist_ents, ent)
            end
        end
    end

    if do_debug then
        print("dist_ents:")
        for k,v in pairs(dist_ents) do
            print(k,v)
        end
    end
    

    local ents_new_entered = {}
    local ents_exited = {}

    for ent,_ in pairs(self.ents) do
        if ent ~= self.inst and not (ent and ent:IsValid() and ent:IsNear(self.inst,self.dist_far)) then
            table.insert(ents_exited,ent)
        end
    end

    if do_debug then
        print("ents_exited:")
        for k,v in pairs(ents_exited) do
            print(k,v)
        end
    end

    for _,v in pairs(ents_exited) do
        self.ents[v] = nil
    end

    for k,v in pairs(dist_ents) do
        if v ~= self.inst and v:IsNear(self.inst,self.dist_near) then
            if not self.ents[v] then
                self.ents[v] = true
                table.insert(ents_new_entered,v)
            end
        end
    end

    if do_debug then
        print("ents_new_entered:")
        for k,v in pairs(ents_new_entered) do
            print(k,v)
        end
    end

    local new_ents_cnt = table.count(self.ents)

    if do_debug then
        print("new ents:")
        for k,v in pairs(self.ents) do
            print(k,v)
        end
    end

    if #ents_new_entered > 0 and self.on_ents_enter then
        self.on_ents_enter(self.inst,ents_new_entered)
    end

    if #ents_exited > 0 and self.on_ents_exit then
        self.on_ents_exit(self.inst,ents_exited)
    end

    if new_ents_cnt > 0 and last_ents_cnt == 0 then
        if self.on_occupied then
            self.on_occupied(self.inst)
        end
        
        self.inst:PushEvent("gale_creatureprox_occupied")
    end

    if new_ents_cnt == 0 and last_ents_cnt > 0 then
        if self.on_empty then
            self.on_empty(self.inst)
        end
        self.inst:PushEvent("gale_creatureprox_empty")
    end



end

return GaleCreatureProx