local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local TEMPLATES = require("widgets/redux/templates")
local Image = require "widgets/image"
local AnimButton = require "widgets/animbutton"
local UIAnimButton = require "widgets/uianimbutton"


local GaleLampUi = Class(Widget, function(self, owner, lamp)
    Widget._ctor(self, "GaleLampUi")

    local src_w, src_h = TheSim:GetScreenSize()

    self.owner = owner
    self.lamp = lamp

    self.delta_stored = 0
    self.delta_stored_max = 25
    self.last_crack_time = GetTime()

    self.joy_mid_pos_local = Vector3(0, 0)
    self.joy_radius = 125
    self.joy_enable = false
    self.joy_old_pos = Vector3(self.joy_radius, 0, 0)

    self.bg = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
    self.bg:SetSize(700, 700)

    local r, g, b = unpack(UICOLOURS.BROWN_DARK)
    self.bg:SetTint(0, 0, 0, 0)

    -- self.linkstick = self:AddChild(Image("images/ui/lamp/gale_lamp_link2.xml", "gale_lamp_link2.tex"))
    self.linkstick = self:AddChild(UIAnim())
    self.linkstick:GetAnimState():SetBank("gale_lamp")
    self.linkstick:GetAnimState():SetBuild("gale_lamp")
    self.linkstick:GetAnimState():PlayAnimation("link")

    self.middle = self:AddChild(UIAnim())
    -- self.middle = self:AddChild(Image("images/ui/lamp/gale_lamp_middle.xml", "gale_lamp_middle.tex"))
    self.middle:GetAnimState():SetBank("gale_lamp")
    self.middle:GetAnimState():SetBuild("gale_lamp")
    self.middle:GetAnimState():PlayAnimation("wheel")
    self.middle:GetAnimState():SetMultColour(150 / 255, 133 / 255, 97 / 255, 1)
    self.middle:SetScale(0.6)



    local joy_scale = 0.5
    self.joystick = self:AddChild(UIAnim())
    self.joystick:GetAnimState():SetBank("joystick")
    self.joystick:GetAnimState():SetBuild("joystick")
    self.joystick:GetAnimState():PlayAnimation("idle", true)
    self.joystick:SetScale(joy_scale)
    -- self.joystick:GetAnimState():SetScale(joy_scale,joy_scale,joy_scale)

    self.mouse_handler = TheInput:AddMoveHandler(function(mx, my)
        if self.joy_enable then
            local xdiff = mx - self:GetWorldPosition().x
            local ydiff = my - self:GetWorldPosition().y

            if not self.focus or math.sqrt(xdiff * xdiff + ydiff * ydiff) - self.joy_radius <= -75 then
                self.joy_enable = false
                return
            end

            local xdiff_stick = mx - self.joystick:GetWorldPosition().x
            local ydiff_stick = my - self.joystick:GetWorldPosition().y

            local angle = math.atan2(ydiff, xdiff)
            local angle_col_stick = math.atan2(ydiff_stick, xdiff_stick)

            -- print("angle(du):",angle * 180 / PI)
            self:UpdateStick(angle, angle_col_stick)



            local joy_pos = self.joystick:GetPosition()
            local cross_result = self.joy_old_pos.x * joy_pos.y - self.joy_old_pos.y * joy_pos.x
            local delta = self.joy_old_pos:Dot(joy_pos) / (self.joy_old_pos:Length() * joy_pos:Length())
            delta = math.acos(delta) * 180 / PI

            self.delta_stored = self.delta_stored + math.abs(delta)
            if self.delta_stored >= self.delta_stored_max and GetTime() - self.last_crack_time >= 0.15 then
                SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_lamp_crack"], self.lamp)
                self.delta_stored = 0
                self.last_crack_time = GetTime()
            end

            if cross_result < 0 then
                -- print("Shun !!!",delta)
                -- delta = delta * 0.03
                delta = delta * 0.15
            elseif cross_result > 0 then
                -- print("Ni !!!",delta)
                -- delta = -delta * 0.1
                delta = -delta * 0.3
            end

            SendModRPCToServer(MOD_RPC["gale_rpc"]["gale_lamp_dodelta"], self.lamp, delta)

            self.joy_old_pos = joy_pos
        end
    end)

    -- self:SetVAnchor(ANCHOR_MIDDLE)
    -- self:SetHAnchor(ANCHOR_MIDDLE)

    self:UpdateStick(0, 0)
end)

function GaleLampUi:GetStickAnim(angle)
    if angle > 0 then
        if angle < PI / 8 then
            return "3"
        elseif angle < 3 * PI / 8 then
            return "1:30"
        elseif angle < 5 * PI / 8 then
            return "12"
        elseif angle < 7 * PI / 8 then
            return "10:30"
        elseif angle < 9 * PI / 8 then
            return "9"
        elseif angle < 11 * PI / 8 then
            return "7:30"
        elseif angle < 13 * PI / 8 then
            return "6"
        elseif angle < 15 * PI / 8 then
            return "4:30"
        else
            return "3"
        end
    else
        if angle > -1 * PI / 8 then
            return "3"
        elseif angle > -3 * PI / 8 then
            return "4:30"
        elseif angle > -5 * PI / 8 then
            return "6"
        elseif angle > -7 * PI / 8 then
            return "7:30"
        elseif angle > -9 * PI / 8 then
            return "9"
        elseif angle > -11 * PI / 8 then
            return "10:30"
        elseif angle > -13 * PI / 8 then
            return "12"
        elseif angle > -15 * PI / 8 then
            return "1:30"
        else
            return "3"
        end
    end

    return "idle"
end

function GaleLampUi:UpdateStick(angle, angle_col_stick)
    local final_pos = self.joy_mid_pos_local + Vector3(math.cos(angle), math.sin(angle)) * self.joy_radius

    self.middle:SetRotation(-angle * 180 / PI)

    -- local link_w,link_h = self.linkstick:GetSize()
    self.linkstick:SetRotation(-angle * 180 / PI)
    -- self.linkstick:SetPosition(self.joy_mid_pos_local + Vector3(math.cos(angle),math.sin(angle)) * link_w / 2)

    self.joystick:SetPosition(final_pos)
    self.joystick:GetAnimState():PlayAnimation(self:GetStickAnim(angle_col_stick))
end

function GaleLampUi:OnControl(control, down)
    if not self.focus then
        self.joy_enable = false
        return false
    end

    if self.joystick.focus and down and control == CONTROL_ACCEPT then
        self.joy_enable = true
    end

    if control == CONTROL_ACCEPT and not down then
        self.joy_enable = false
    end


    return GaleLampUi._base.OnControl(self, control, down)
end

function GaleLampUi:Kill()
    self.mouse_handler:Remove()
    self.mouse_handler = nil

    return GaleLampUi._base.Kill(self)
end

-- local GaleLampUi=require("widgets/gale_lamp_ui") ThePlayer.HUD.controls.GaleLampUi=ThePlayer.HUD.controls:AddChild(GaleLampUi(ThePlayer))

return GaleLampUi
