local GaleInteriorRoomManager = Class(function(self,inst)
    self.inst = inst

    self.room_entities = {}

    self.start_pos = Vector3(1000,0,1000)
end)

function GaleInteriorRoomManager:Add(ent)
    if not self.room_entities[ent] then
        self.room_entities[ent] = true 
    end
end

function GaleInteriorRoomManager:Remove(ent)
    if self.room_entities[ent] then
        self.room_entities[ent] = nil 
    end
end

function GaleInteriorRoomManager:GetRoom(tar_pos)
    tar_pos.y = 0
    for room,_ in pairs(self.room_entities) do
        if room.components.gale_interior_room:IsInside(tar_pos) then
            return room
        end
    end
end

function GaleInteriorRoomManager:GenerateHousePos()
    if TheWorld.ismastersim then
        local cnt = 0
        for k,v in pairs(self.room_entities) do
            cnt = cnt + 1
        end

        local x_index = cnt % 4
        local y_index = math.floor(cnt / 4)
        local offset = Vector3(80 * x_index,0,80 * y_index)

        return self.start_pos + offset
    else 
        print("GaleInteriorRoomManager:You shouldn't use GenerateHousePos() in client side !!!!")
        return nil 
    end
    
end

return GaleInteriorRoomManager