local GaleCommon = require("util/gale_common")

local phase_desc = {
    "treasurechest contains 3 cookies",
    "treasurechest is locked(player can use hammer to break it), contains 2 cookies",
    "treasurechest contains 1 cookies,some spidermines nearby",
    "treasurechest contains nothing,when opened,is explodes,and summon katash",
    "katash is defeated,he is going to hardware LAB(waitting for next update...)"
}

local function RandomDropContainerItems(chest)
    for _, v in pairs(chest.components.container:GetAllItems()) do
        local radius = GetRandomMinMax(10, 20)
        local offset = FindWalkableOffset(chest:GetPosition(),
                                          math.random() * TWOPI,
                                          radius,
                                          5,
                                          nil,
                                          false,
                                          nil,
                                          true,
                                          true
        ) or Vector3(0, 0, 0)

        local x, y, z = (chest:GetPosition() + offset):Get()
        chest.components.container:DropItemAt(v, x, y, z)
    end
end

local init_items = {
    {
        gale_ckptfood_nutri_food = 3,
    },

    {
        gale_ckptfood_nutri_food = 2,
        gears = 1,
    },

    {
        gale_ckptfood_nutri_food = 2,
        gears = 1,
        transistor = 1,
        spider_warrior = 3,
    },

    {

    },

    {

    },
}

local function GiveItemToChest(chest, tab, clear_old)
    if clear_old then
        chest.components.container:DestroyContents()
    end
    for name, num in pairs(tab) do
        for i = 1, num do
            chest.components.container:GiveItem(
                SpawnAt(name, chest)
            )
        end
    end
end

local phase_update_fn = {
    function(self, onload)
        local treasurechest = self.entities.treasurechest
        if not onload then
            GiveItemToChest(treasurechest, init_items[1], true)
        end
    end,
    function(self, onload)
        local treasurechest = self.entities.treasurechest

        if not onload then
            GiveItemToChest(treasurechest, init_items[2], true)
            treasurechest:SetLocked(true)
        end
    end,
    function(self, onload)
        local treasurechest = self.entities.treasurechest

        if not onload then
            GiveItemToChest(treasurechest, init_items[3], true)
            treasurechest:SetLocked(true)
        end
    end,
    function(self, onload)
        local treasurechest = self.entities.treasurechest

        if not onload then
            treasurechest.components.container:DestroyContents()
            treasurechest:SetLocked(true)
        end
    end,

    function(self, onload)
        -- TODO:Respawn a safebox
    end,
}

local function DoExplode(source, attacker)
    attacker = attacker or source

    local explo = SpawnAt("gale_bomb_projectile_explode", source)
    explo.Transform:SetScale(1.5, 1.5, 1.5)
    explo.SoundEmitter:PlaySound("gale_sfx/battle/p1_explode")
    explo:SpawnChild("gale_normal_explode_vfx")

    local ring = SpawnAt("gale_laser_ring_fx", source)
    ring.Transform:SetScale(0.9, 0.9, 0.9)
    ring.AnimState:SetFinalOffset(3)
    ring.AnimState:SetLayer(LAYER_GROUND)
    ring.AnimState:HideSymbol("circle")
    ring.AnimState:HideSymbol("glow_2")
    ring.AnimState:HideSymbol("lightning01")

    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, source, 40)

    GaleCommon.AoeForEach(
        attacker,
        source:GetPosition(),
        2.8,
        nil,
        { "INLIMBO" },
        nil,
        function(attacker, v)
            if v.components.combat then
                local basedamage = GetRandomMinMax(60, 120)

                v.components.combat:GetAttacked(attacker, basedamage)
                v:PushEvent("knockback", { knocker = explo, radius = GetRandomMinMax(1.2, 1.4) + v:GetPhysicsRadius(.5) })
            elseif v.components.inventoryitem then
                if v.Physics then
                    GaleCommon.LaunchItem(v, source, 5)
                end
            elseif v.components.workable ~= nil
                and v.components.workable:CanBeWorked()
                and v.components.workable.action ~= ACTIONS.NET then
                v.components.workable:WorkedBy(attacker, 5)
            end
        end,
        function(inst, v)
            local is_combat = v.components.combat and v.components.health and not v.components.health:IsDead()
                and not (v.sg and v.sg:HasStateTag("dead"))
                and not v:HasTag("playerghost")
            local is_inventory = v.components.inventoryitem
            return v and v:IsValid()
                and (is_combat or is_inventory or v.components.workable)
        end
    )
end

local GaleBossKatashSpawner = Class(function(self, inst)
    self.inst = inst

    self.phase = 0
    self.landing_day = -5
    self.next_phase = 0
    self.phase_update_clock = 0
    -- self.phase_update_duration = TUNING.TOTAL_DAY_TIME * 5
    self.phase_update_duration = 5
    self.statemem = {}

    self.entities = {
        spaceship = nil,
        treasurechest = nil,
        katash = nil,
    }

    self._on_katash_defeated = function(katash, data)
        if self.phase < 5 then
            print("Katash defeated ! Set next phase to 5...")
            self:SetNextPhase(5)
        end
    end

    self._on_chest_open = function(chest, data)
        self.statemem.chest_opened = true

        print(chest, "_on_chest_open")

        if self.phase == 4 and self.entities.katash == nil then
            print("Spawn katash !!!!!")
            local offset = FindWalkableOffset(
                chest:GetPosition(),
                math.random() * TWOPI,
                5,
                15,
                nil,
                false,
                nil,
                false,
                false
            ) or Vector3(0, 0, 0)


            DoExplode(chest)
            chest.components.container:DropEverything()
            chest:Hide()

            self.inst:DoTaskInTime(1, function()
                local katash = self:SpawnKatash(chest:GetPosition() + offset, data.doer)
                chest.components.container:DropEverything()
                chest:Remove()
                self:SetEntity("treasurechest", nil)
            end)

            -- SpawnAt("gale_fire_explode_vfx",chest)
        end
    end

    self._start_phase_update_timer = function()
        if self.phase == 1 then
            if self.statemem.chest_opened then
                self:SetNextPhase(2)
            end
        elseif self.phase == 2 then
            if self.statemem.chest_opened then
                self:SetNextPhase(3)
            end
        elseif self.phase == 3 then
            if self.statemem.chest_opened then
                self:SetNextPhase(4)
            end
        elseif self.phase == 4 then
            -- Going to phase 5 is in self._on_katash_defeated
        end

        if self.phase < self.next_phase then
            print(self.inst, "GaleBossKatashSpawner._start_phase_update_timer !")
            self.inst:StartUpdatingComponent(self)
        end
    end

    self._stop_phase_update_timer = function()
        print(self.inst, "GaleBossKatashSpawner._stop_phase_update_timer !")
        self.inst:StopUpdatingComponent(self)
    end



    inst:DoTaskInTime(5 * FRAMES, function()
        print("[GaleBossKatashSpawner]list entities:")
        print(self:GetDebugString())
        print("statemem =")
        dumptable(self.statemem)
    end)
end)

function GaleBossKatashSpawner:Init(spaceship, treasurechest)
    self:SetEntity("spaceship", spaceship)
    self:SetEntity("treasurechest", treasurechest)
    self:SetPhase(1)
    self:SetNextPhase(1)
    self.landing_day = TheWorld.state.cycles - 5
end

function GaleBossKatashSpawner:SetEntity(name, ent)
    self.entities[name] = ent
    if ent then
        if name == "treasurechest" then
            self:InitListenerForTreasurechest(ent)
        elseif name == "katash" then
            self:InitListenerForKatash(ent)
        end
    end
end

function GaleBossKatashSpawner:SetNextPhase(nextphase)
    self.next_phase = nextphase
end

function GaleBossKatashSpawner:SetPhase(newphase, onload)
    self.phase = newphase
    self.next_phase = newphase

    if phase_update_fn[newphase] then
        phase_update_fn[newphase](self, onload)
    end
end

function GaleBossKatashSpawner:SpawnKatash(pos, target)
    local katash = SpawnAt("galeboss_katash", pos)
    katash.sg:GoToState("intro_teleportin", { target = target })
    self:SetEntity("katash", katash)
    return katash
end

function GaleBossKatashSpawner:InitListenerForTreasurechest(chest)
    self.inst:ListenForEvent("onopen", self._on_chest_open, chest)
    self.inst:ListenForEvent("entitysleep", self._start_phase_update_timer, chest)
    self.inst:ListenForEvent("entitywake", self._stop_phase_update_timer, chest)
end

function GaleBossKatashSpawner:InitListenerForKatash(katash)
    self.inst:ListenForEvent("galeboss_katash_defeated", self._on_katash_defeated, katash)
end

function GaleBossKatashSpawner:TimeSinceLanding()
    return TheWorld.state.cycles - self.landing_day
end

function GaleBossKatashSpawner:OnUpdate(dt)
    if self.phase_update_clock < self.phase_update_duration then
        self.phase_update_clock = self.phase_update_clock + dt
        print(string.format("GaleBossKatashSpawner OnUpdate:%.2f%%",
                            100 * self.phase_update_clock / self.phase_update_duration))
        return
    end

    if self.entities.treasurechest and FindClosestPlayerToInst(self.entities.treasurechest, 40) == nil then
        if self.phase < self.next_phase then
            print(self.inst, "GaleBossKatashSpawner Go to next phase " .. tostring(self.next_phase))
            self.statemem = {}
            self:SetPhase(self.next_phase)
        end
        self.phase_update_clock = 0
        self.inst:StopUpdatingComponent(self)
    end
end

function GaleBossKatashSpawner:OnSave()
    local data = {
        entities = {},
        phase = self.phase,
        next_phase = self.next_phase,
        phase_update_clock = self.phase_update_clock,
        phase_update_duration = self.phase_update_duration,
        landing_day = self.landing_day,
        statemem = self.statemem,
    }
    local references = {}

    for name, ent in pairs(self.entities) do
        if ent and ent:IsValid() then
            data.entities[name] = ent.GUID
            table.insert(references, ent.GUID)
        end
    end

    return data, references
end

function GaleBossKatashSpawner:OnLoad(data)
    if data ~= nil then
        if data.statemem ~= nil then
            self.statemem = data.statemem
        end
        if data.phase ~= nil then
            self:SetPhase(data.phase, true)
        end
        if data.next_phase ~= nil then
            self:SetNextPhase(data.next_phase)
        end
        if data.phase_update_clock ~= nil then
            self.phase_update_clock = data.phase_update_clock
        end
        -- if data.phase_update_duration ~= nil then
        --     self.phase_update_duration = data.phase_update_duration
        -- end
        if data.landing_day ~= nil then
            self.landing_day = data.landing_day
        end

        if self.next_phase > self.phase then
            self.inst:StartUpdatingComponent(self)
        end
    end
end

function GaleBossKatashSpawner:LoadPostPass(newents, savedata)
    if savedata.entities ~= nil then
        for name, guid in pairs(savedata.entities) do
            local ent = newents[guid]
            if ent ~= nil then
                self:SetEntity(name, ent.entity)
            end
        end
    end
end

function GaleBossKatashSpawner:GetDebugString()
    local result = ""
    result = result .. "phase = " .. self.phase .. "," .. tostring(phase_desc[self.phase]) .. "\n"
    result = result .. "next_phase = " .. self.next_phase .. "," .. tostring(phase_desc[self.next_phase]) .. "\n"
    result = result .. "spaceship = " .. tostring(self.entities.spaceship) .. "\n"
    result = result .. "treasurechest = " .. tostring(self.entities.treasurechest) .. "\n"
    result = result .. "katash = " .. tostring(self.entities.katash)

    return result
end

return GaleBossKatashSpawner
