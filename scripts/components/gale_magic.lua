local SourceModifierList = require("util/sourcemodifierlist")

local function oncurrent(self,current)
    self.inst.replica.gale_magic:SetCurrent(current)
end

local function onmax(self,max)
    self.inst.replica.gale_magic:SetMax(max)
end

local function onenable(self,enable)
    self.inst.replica.gale_magic:Enable(enable)
end

local function onenable_HUD(self,enable)
    self.inst.replica.gale_magic:EnableHUD(enable)
end

local GaleMagic = Class(function(self,inst)
    self.inst = inst 

    self.current = 100
    self.max = 100 

    self.enable = true
    self.enable_interface = SourceModifierList(inst,true,function(a,b)
        return a and b
    end)
    self.enable_HUD = false

    self.delta_tasks = {}

    self:InitListeners()
end,
nil,
{
    current = oncurrent,
    max = onmax,
    enable = onenable,
    enable_HUD = onenable_HUD,
})

function GaleMagic:UpdateEnable()
    local old_enable = self.enable
    self.enable = self:IsEnable()
    self.inst:PushEvent("gale_magic_enable",{
        enable = self.enable,
        old = old_enable,
    })
end

function GaleMagic:InitListeners()
    ----------------------------------------------------------------------
    self.inst:ListenForEvent("changearea", function(_,area)
        local is_lunacy = area ~= nil and area.tags and table.contains(area.tags, "lunacyarea")
        self.enable_interface:SetModifier(self.inst,not is_lunacy,"lunacyarea")
        self:UpdateEnable()
    end)
    self.inst:ListenForEvent("stormlevel", function(_,data)
        -- local is_lunacy = TheWorld.state.isnight and TheWorld.state.isalterawake
        local in_moonstorm = data ~= nil and data.stormtype == STORM_TYPES.MOONSTORM and data.level > 0
        self.enable_interface:SetModifier(self.inst,not in_moonstorm,"moonstorm")
        self:UpdateEnable()
    end)

    local function OnAlterNight()
        local isalterawake = TheWorld.state.isnight and TheWorld.state.isalterawake
        self.enable_interface:SetModifier(self.inst,not isalterawake,"alterawake")
        self:UpdateEnable()
    end
    self.inst:WatchWorldState("isnight", OnAlterNight)
	self.inst:WatchWorldState("isalterawake", OnAlterNight)

    self.inst:ListenForEvent("on_RIFT_MOON_tile", function(_,on_rift_moon)
        self.enable_interface:SetModifier(self.inst,not on_rift_moon,"rift_moon")
        self:UpdateEnable()
    end)

    ----------------------------------------------------------------------

    self.inst:ListenForEvent("death",function()
        self:CancelAllDeltaTasks()
        self:SetPercent(0)
    end)

    local function OnSkillChange()
        if not self.inst.components.gale_skiller then
            self:EnableHUD(false)
        elseif self.inst.components.gale_skiller:GetTyphonSkillNum() > 0 then
            self:EnableHUD(true)
        else 
            self:EnableHUD(false)
        end
    end

    self.inst:ListenForEvent("gale_skill_learned",OnSkillChange)
    self.inst:ListenForEvent("gale_skill_forgot",OnSkillChange)

    OnAlterNight()
    OnSkillChange()
    self.inst:DoTaskInTime(0,OnSkillChange)
    
end

function GaleMagic:SetVal(val)
    self.current = math.clamp(val,0,self.max)
end

function GaleMagic:SetPercent(percent)
    self:SetVal(self.max * percent)
    self:DoDelta(0)
end

function GaleMagic:DoDelta(delta)
    local old = self.current
    self:SetVal(self.current + delta)

    self.inst:PushEvent("gale_magic_delta",{
        old = old,
        new = self.current,
    })
    return self.current - old 
end

function GaleMagic:Enable(base)
    self.enable_interface:SetModifier(self.inst,base,"base")
end

function GaleMagic:EnableHUD(enable)
    self.enable_HUD = enable
end

function GaleMagic:IsEnable()
    return self.enable_interface:Get()
end


function GaleMagic:CanUseMagic(cost)
    return self:IsEnable() and self.current >= cost 
end

function GaleMagic:GetPercent()
    return self.current / self.max 
end

function GaleMagic:CancelDeltaTask(key)
    if self.delta_tasks[key] == nil then
        return 
    end

    -- KillThread(self.delta_tasks[key])
    self.delta_tasks[key]:Cancel()
    self.delta_tasks[key] = nil 
end

function GaleMagic:CancelAllDeltaTasks()
    for _,key in pairs(table.getkeys(self.delta_tasks)) do
        self:CancelDeltaTask(key)
    end
end

function GaleMagic:AddDeltaTask(key,delta,duration)
    if key == nil then
        return 
    end
    self:CancelDeltaTask(key)

    if duration == nil then
        self.delta_tasks[key] = self.inst:DoPeriodicTask(0,function()
            local seg_delta = FRAMES * FunctionOrValue(delta,self.inst)
            self:DoDelta(seg_delta)
            if (seg_delta > 0 and self.current >= self.max)
                or (seg_delta < 0 and self.current <= 0) then
                self:CancelDeltaTask(key) 
            end
        end)
    else 
        local seg_delta = FRAMES * FunctionOrValue(delta,self.inst) / duration
        local count = (1 / FRAMES) * duration
        local cur_count = 1

        self.delta_tasks[key] = self.inst:DoPeriodicTask(0,function()
            
            
            self:DoDelta(seg_delta)
            if cur_count >= count 
                or (seg_delta > 0 and self.current >= self.max)
                or (seg_delta < 0 and self.current <= 0) then
                    
                self:CancelDeltaTask(key) 
                return
            end
            cur_count = cur_count + 1

        end)
    end
end

function GaleMagic:OnSave()
    return {
        current = self.current
    }
end

function GaleMagic:OnLoad(data)
    if data ~= nil then
        if data.current ~= nil then
            self.current = data.current
            self:DoDelta(0)
        end
    end
end


return GaleMagic