local PIDController = Class(function(self,kp,ki,kd,duration)
    self.kp = kp or 0
    self.ki = ki or 0
    self.kd = kd or 0

    self.error_queue = {}
    self.error_duration = duration or 1
end)

function PIDController:PopErrorsBefore(cur_time)
    cur_time = cur_time or GetTime()
    while #self.error_queue > 0 and self.error_queue[1][1] < cur_time - self.error_duration do
        table.remove(self.error_queue,1)
    end
end

function PIDController:AddError(dx)
    local cur_time = GetTime()
    table.insert(self.error_queue,{
        cur_time,dx
    })
    self:PopErrorsBefore(cur_time)
end

-- function PIDController:GetMeanError()
--     local sum = 0
--     for _,v in pairs(self.error_queue) do
--         sum = sum + v[2]
--     end
--     sum = sum / #self.error_queue

--     return sum
-- end

function PIDController:GetSumError()
    local sum = 0
    for _,v in pairs(self.error_queue) do
        sum = sum + v[2]
    end

    return sum
end

function PIDController:GetFirstError()
    return self.error_queue[1][2]
end

function PIDController:GetLastError()
    return self.error_queue[#self.error_queue][2]
end

function PIDController:GetChangingError()
    if #self.error_queue < 2 then
        return 0
    end
    local d1 = self.error_queue[1]
    local d2 = self.error_queue[#self.error_queue]

    return (d2[2] - d1[2]) / (d2[1] - d1[1])
end

function PIDController:Output(dx)
    if dx then
        self:AddError(dx)
    else 
        self:PopErrorsBefore(GetTime())
    end


    return self.kp * self:GetLastError() + self.ki * self:GetSumError() + self.kd * self:GetChangingError()
end


return PIDController