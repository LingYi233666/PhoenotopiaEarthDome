local function OnUpdate_Linear(inst)
    local mypos = inst:GetPosition()
    local tarpos = inst.components.complexprojectile.targetpos

    local horizontalSpeed = inst.components.complexprojectile.horizontalSpeed

    local dy = tarpos.y - mypos.y
    local dx = Vector3(tarpos.x,0,tarpos.z):Dist(Vector3(mypos.x,0,mypos.z))
    local dt = dx / horizontalSpeed
    local vy = dy / dt

    -- inst:ForceFacePoint(tarpos:Get())
    inst.Physics:SetMotorVel(horizontalSpeed,vy,0)
end

-- local function OnUpdate_Paracurve(inst,init_vy,ay)
--     local horizontalSpeed = inst.components.complexprojectile.horizontalSpeed

-- end

return {
    OnUpdate_Linear = OnUpdate_Linear,
    -- OnUpdate_Paracurve = OnUpdate_Paracurve,
}