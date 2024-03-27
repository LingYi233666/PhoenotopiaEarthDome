local function DrawPoints(start_pos,finish_pos)
    local result = {start_pos,finish_pos}
    local dist = (finish_pos - start_pos):Length()
    local num_max_points = dist * 1.5

    while #result <= num_max_points do
        local j = 1 
        while j < #result do
            if result[j + 1] ~= nil then
                local vstart = result[j]
                local vend = result[j + 1]

                local dx, dz = vend.x - vstart.x, vend.z - vstart.z
                local angle = math.atan2(dx, dz) + (math.random(80) - 40) * DEGREES - 1.57
                local lenght = math.sqrt(dx * dx + dz * dz) / 2

                table.insert(result, j + 1, 
                    Vector3(vstart.x + math.cos(angle) * lenght,0,vstart.z - math.sin(angle) * lenght))
            else

            end
            j = j + 2
        end

    end

    return result
end

return {
    DrawPoints = DrawPoints,
}