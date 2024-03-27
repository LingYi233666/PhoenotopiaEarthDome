local Widget = require "widgets/widget" 
local Image = require "widgets/image"
local easing = require("easing")

local function ModifiedMoveTo(self,easing_func)
    self.easing_func = easing_func

    function self:MoveTo(start, dest, duration, whendone)
        self.pos_start = start
        self.pos_dest = dest
        self.pos_duration = duration
        self.pos_t = 0
    
        if self.pos_whendone then
            self.pos_whendone()
        end
        self.pos_whendone = whendone
    
    
        self:StartUpdating()
        self:SetPosition(start)
    end
    
    function self:CancelMoveTo(run_complete_fn)
        self.pos_t = nil
        if run_complete_fn ~= nil and self.pos_whendone then
            self.pos_whendone()
        end
        self.pos_whendone = nil
    end
    
    function self:OnUpdate(dt)

        local done = false
    
        if self.pos_t then
    
            self.pos_t = self.pos_t + dt
            if self.pos_t < self.pos_duration then
                local valx = self.easing_func( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
                local valy = self.easing_func( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
                local valz = self.easing_func( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
                self:SetPosition(valx, valy, valz)
            else
                local valx = self.pos_dest.x
                local valy = self.pos_dest.y
                local valz = self.pos_dest.z
                self:SetPosition(valx, valy, valz)
    
                self.pos_t = nil
                if self.pos_whendone then
                    local pos_whendonefn = self.pos_whendone
                    self.pos_whendone = nil -- reset this here so that self.pos_whendone can call MoveTo
                    pos_whendonefn()
                end
            end
        end
    
    
        if not self.pos_t then
            self:StopUpdating()
        end
    end
end

local GaleCGImages = Class(Widget, function(self)
	Widget._ctor(self, "GaleCGImages")
    self.images = {}
    self.moving_param = {}
    self.enable_moving = false
end)


function GaleCGImages:DoMouseClick()
    if self.clickfn then
        self.clickfn()
    else 
        self:EnableMoving(true)
    end 
end

-- param:
-- xml_file
-- tex_file
-- start_pos 
-- end_pos 
-- duration 
function GaleCGImages:AddMovingImage(param)
    local ui = self:AddChild(Image(param.xml_file,param.tex_file))
    ModifiedMoveTo(ui,easing.linear)
    ui:SetPosition(param.start_pos)
    ui:MoveToBack()
    -- ui:MoveTo(param.start_pos,param.end_pos,param.duration)
    ui:SetTint(0,0,0,0)
    table.insert(self.images,ui)
    table.insert(self.moving_param,{
        start_pos = param.start_pos,
        end_pos = param.end_pos,
        duration = param.duration,
    })
end

-- 1100,400
function GaleCGImages:SuitScale(window_w)
    local scr_w,scr_h = TheSim:GetScreenSize()

    self:SetScale(scr_w / window_w)
end

function GaleCGImages:EnableMoving(enable)
    if self.enable_moving == false and enable then
        for k,ui in pairs(self.images) do
            local param = self.moving_param[k]
            ui:MoveTo(param.start_pos,param.end_pos,param.duration)
        end
    elseif self.enable_moving == true and not enable then
        for k,ui in pairs(self.images) do
            ui.inst:StopUpdating()
        end
    end

    self.enable_moving = enable
end

function GaleCGImages:FadeIn(duration,when_done)
    for _,v in pairs(self.images) do
        v:TintTo({r=0,g=0,b=0,a=0},{r=1,g=1,b=1,a=1},duration,when_done)
    end
end

function GaleCGImages:FadeOut(duration,when_done)
    for _,v in pairs(self.images) do
        v:TintTo({r=1,g=1,b=1,a=1},{r=0,g=0,b=0,a=0},duration,when_done)
    end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

-- durations:18,14,18,10
-- ThePlayer.HUD.controls.CG_TEST.images[3]:SetPosition(-800 / 1.64,0)
local TheGreatBattleGround = Class(GaleCGImages,function(self)
    GaleCGImages._ctor(self)

    -- mid window width in thr origin image
    self:SuitScale(1100)

    local scale = 1
    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_2A.xml",
        tex_file = "CG_2A.tex",
        start_pos = Vector3(173,0,0),
        end_pos = Vector3((173 - 309),0,0),
        duration = 22,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_2B.xml",
        tex_file = "CG_2B.tex",
        start_pos = Vector3(318,0,0),
        end_pos = Vector3((318 - 585),0,0),
        duration = 22,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_2C.xml",
        tex_file = "CG_2C.tex",
        start_pos = Vector3(455,0,0),
        end_pos = Vector3((455 - 840),0,0),
        duration = 22,
    })
end)

local PhoenixCreated = Class(GaleCGImages,function(self)
    GaleCGImages._ctor(self)

    -- mid window width in thr origin image
    self:SuitScale(1100)

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_1A.xml",
        tex_file = "CG_1A.tex",
        start_pos = Vector3(0,274,0),
        end_pos = Vector3(0,(274 - 127),0),
        duration = 14,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_1B.xml",
        tex_file = "CG_1B.tex",
        start_pos = Vector3(0,133,0),
        end_pos = Vector3(0,(133 - 274),0),
        duration = 14,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_1C.xml",
        tex_file = "CG_1C.tex",
        start_pos = Vector3(0,217,0),
        end_pos = Vector3(0,(217 - 435),0),
        duration = 14,
    })
end)

local MostPeopleDecideToSleep = Class(GaleCGImages,function(self)
    GaleCGImages._ctor(self)

    -- mid window width in thr origin image
    self:SuitScale(1100)

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_3A.xml",
        tex_file = "CG_3A.tex",
        start_pos = Vector3(0,-70,0),
        end_pos = Vector3(0,(-70 + 110),0),
        duration = 18,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_3B.xml",
        tex_file = "CG_3B.tex",
        start_pos = Vector3(0,-119,0),
        end_pos = Vector3(0,(-119 + 265),0),
        duration = 18,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_3C.xml",
        tex_file = "CG_3C.tex",
        start_pos = Vector3(0,-137,0),
        end_pos = Vector3(0,(-137 + 316),0),
        duration = 18,
    })
end)

local PhoenixTheWorldLegacy = Class(GaleCGImages,function(self)
    GaleCGImages._ctor(self)

    -- mid window width in thr origin image
    self:SuitScale(1100)

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_5A.xml",
        tex_file = "CG_5A.tex",
        start_pos = Vector3(0,308,0),
        end_pos = Vector3(0,(308 - 633),0),
        duration = 10,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_5B.xml",
        tex_file = "CG_5B.tex",
        start_pos = Vector3(0,444,0), -- 444 ?
        end_pos = Vector3(0,(444 - 586),0),
        duration = 10,
    })

    self:AddMovingImage({
        xml_file = "images/ui/CG/CG_5C.xml",
        tex_file = "CG_5C.tex",
        start_pos = Vector3(0,407,0),
        end_pos = Vector3(0,(407 - 773),0),
        duration = 10,
    })

    self.first_clicked = false
    self.clickfn = function ()
        if self.first_clicked then
            self:EnableMoving(true)
        else 
            self.first_clicked = true 
        end
    end
end)

return {
    TheGreatBattleGround = TheGreatBattleGround,
    PhoenixCreated = PhoenixCreated,
    MostPeopleDecideToSleep = MostPeopleDecideToSleep,
    PhoenixTheWorldLegacy = PhoenixTheWorldLegacy,
}