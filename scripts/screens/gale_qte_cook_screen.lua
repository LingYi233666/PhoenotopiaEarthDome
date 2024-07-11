local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local GaleQteCookArrow = require "screens/gale_qte_cook_arrow"

-- local GaleQteCookScreen = require"screens/gale_qte_cook_screen" TheFrontEnd:PushScreen(GaleQteCookScreen(ThePlayer))
local GaleQteCookScreen = Class(Screen, function(self, owner, product, container, dot_num, per_time, time_remain)
	Screen._ctor(self, "GaleQteCookScreen")
	TheInput:ClearCachedController()

	self.owner = owner
	self.has_ended = false
	self.pausing = false
	self.bar_len = 250
	self.bar_len_vaild = 80
	self.last_tick_time = GetTime()

	self.product = product or "meatballs"
	self.container = container
	self.dot_num = dot_num or 3
	self.per_time = per_time or 1.2
	self.time_remain = time_remain or (self.dot_num * 2.25 * self.per_time)
	self.max_time_remain = self.time_remain

	-- self.bar = self:AddChild(Image("images/ui/qte_cook/hud_cook_interface.xml","hud_cook_interface.tex"))
	self.bar = self:AddChild(UIAnim())
	self.bar:GetAnimState():SetBank("gale_ui_cook_remaster")
	self.bar:GetAnimState():SetBuild("gale_ui_cook_remaster")
	self.bar:GetAnimState():PlayAnimation("bar")
	-- self.bar:SetScale(3)

	self.canno = self:AddChild(UIAnim())
	self.canno:GetAnimState():SetBank("gale_ui_cook_remaster")
	self.canno:GetAnimState():SetBuild("gale_ui_cook_remaster")
	self.canno:GetAnimState():PlayAnimation("canno")

	self.fire = self:AddChild(UIAnim())
	self.fire:GetAnimState():SetBank("gale_ui_cook_remaster")
	self.fire:GetAnimState():SetBuild("gale_ui_cook_remaster")
	self.fire:GetAnimState():PlayAnimation("fire", true)
	self.fire:GetAnimState():SetDeltaTimeMultiplier(0.56)

	self.cooktimer = self:AddChild(UIAnim())
	self.cooktimer:GetAnimState():SetBank("gale_ui_cook_remaster")
	self.cooktimer:GetAnimState():SetBuild("gale_ui_cook_remaster")
	self.cooktimer:GetAnimState():SetPercent("timer", 0.001)
	self.cooktimer:SetPosition(205, 90, 0)
	-- self.dots = self:AddChild(Image("images/ui/qte_cook/cook_dots_10.xml","cook_dots_10.tex"))
	-- self.dots:SetScale(8,10)
	-- self.dots:SetPosition(0,50,0)

	self.dots = {}
	for i = 1, TUNING.GALECOOK.MAX_DOTS_NUM do
		-- local white_block = self:AddChild(Image("images/ui/qte_cook/white_block.xml","white_block.tex"))
		local white_block = self:AddChild(UIAnim())
		white_block:GetAnimState():SetBank("gale_ui_cook_remaster")
		white_block:GetAnimState():SetBuild("gale_ui_cook_remaster")
		white_block:GetAnimState():PlayAnimation("noddles_pst")

		local mid = TUNING.GALECOOK.MAX_DOTS_NUM / 2
		local cur_x = (i > mid) and ((i - mid) * 40 - 290) or (i * 40 - 290)
		local cur_y = (i <= mid) and 110 or 70
		white_block:SetPosition(cur_x, cur_y, 0)
		white_block:SetTooltip(tostring(i))
		-- white_block:SetScale(0.55)
		table.insert(self.dots, white_block)
	end

	self.arrow = self:AddChild(GaleQteCookArrow())
	self.arrow:SetScale(1.2)
	-- self.arrow:SetPosition(300,0)
	self.arrow:SetPosition(self.bar_len, 0)

	self:SetDotNum(self.dot_num)


	-- self:SetVAnchor(ANCHOR_MIDDLE)
	--    self:SetHAnchor(ANCHOR_MIDDLE)


	-- if container then
	-- 	container:ListenForEvent("onremove",function()
	-- 		self:End("INTERRUPTE")
	-- 	end)
	-- end

	-- self:MovingArrow("LEFT", self.per_time)
	self:MovingArrow("RIGHT", self.per_time)
	self:StartUpdating()

	ThePlayer.HUD.GaleQteCookScreen = self
end)

function GaleQteCookScreen:SetDotNum(num)
	self.dot_num = math.min(TUNING.GALECOOK.MAX_DOTS_NUM, num)
	for k, v in pairs(self.dots) do
		if k <= self.dot_num then
			-- v:SetTint(1,1,1,1)
			v:GetAnimState():PlayAnimation("noddles_pst")
		else
			-- v:SetTint(0,0,0,1)
			v:GetAnimState():PlayAnimation("noddles_pre")
		end
	end
end

function GaleQteCookScreen:Close()
	ThePlayer.HUD.GaleQteCookScreen = nil
	TheFrontEnd:PopScreen(self)
end

function GaleQteCookScreen:GuessArrow(guess)
	local pos = self.arrow:GetPosition()
	if not self.arrow.cancel_input then
		if math.abs(pos.x) <= self.bar_len_vaild and guess == self.arrow.arrow_type then
			return true
		else
			return false
		end
	end
end

function GaleQteCookScreen:SpawnSmoke()

end

function GaleQteCookScreen:GetTickPeriod()
	return Remap(self.time_remain / self.max_time_remain, 0, 1, 0.2, 0.55)
end

function GaleQteCookScreen:OnControl(control, down)
	if control == CONTROL_CANCEL and down and not self.has_ended then
		self:End("INTERRUPTE")
		return
	end
	-- print("GaleQteCookScreen OnControl",control,down)
	local data = {
		[CONTROL_MOVE_UP] = "UP",
		[CONTROL_MOVE_DOWN] = "DOWN",
		[CONTROL_MOVE_LEFT] = "LEFT",
		[CONTROL_MOVE_RIGHT] = "RIGHT",
	}

	if data[control] and not self.has_ended then
		-- print("GaleQteCookScreen OnControl",data[control],down)
		if down then
			-- self:RotateArrow(data[control])
			local res = self:GuessArrow(data[control])
			if res == true then
				TheFocalPoint.SoundEmitter:PlaySound("gale_sfx/cooking/cook_positive_sign")
				self:SetDotNum(self.dot_num - 1)
				if self.dot_num <= 0 then
					self:End("SUCCESS")
				end
				self.arrow:RoatteRandom()
				self.fire:GetAnimState():PlayAnimation("fire_up2")
				self.fire:GetAnimState():PushAnimation("fire", true)
			elseif res == false then
				self.pausing = true
				TheFocalPoint.SoundEmitter:PlaySound("gale_sfx/cooking/cook_negative_sign")
				-- self:SetDotNum(self.dot_num)
				-- self.arrow:StopUpdating()
				-- self.arrow.inst:StopWallUpdatingComponent(self.arrow.inst.components.uianim)
				self.arrow:RedFlash(function()
					-- self.arrow.inst:StartWallUpdatingComponent(self.arrow.inst.components.uianim)
					-- self.arrow:StartUpdating()
					self.pausing = false
				end)
				self.owner:ShakeCamera(CAMERASHAKE.FULL, .5, .02, .3)
				self:SpawnSmoke()
			else

			end
		end
	end
	if GaleQteCookScreen._base.OnControl(self, control, down) then
		return true
	end
end

function GaleQteCookScreen:MovingArrow(left_or_right, time)
	self.arrow:CancelMoveTo()
	local tar_pos = Vector3(self.bar_len, 0, 0) * (left_or_right == "RIGHT" and 1 or -1)
	self.arrow:MoveTo(self.arrow:GetPosition(), tar_pos, time, function()
		self:MovingArrow(left_or_right == "RIGHT" and "LEFT" or "RIGHT", time)
	end)
end

function GaleQteCookScreen:End(end_state)
	self.has_ended = true
	self:StopUpdating()
	if end_state == "SUCCESS" then
		print(self, "Game SUCCESS")
	elseif end_state == "FAILED" then
		print(self, "Game FAILED")
	elseif end_state == "INTERRUPTE" then
		print(self, "Game INTERRUPTE")
	end

	if end_state ~= "SUCCESS" then
		TheFocalPoint.SoundEmitter:PlaySound("gale_sfx/cooking/item_stolen")
	end
	SendModRPCToServer(MOD_RPC["gale_rpc"]["cook_qte_end"], end_state, self.product, self.container)

	-- self.arrow:Hide()
	-- self.bar:TintTo({r=1,g=1,b=1,a=1},{r=0,g=0,b=0,a=0},0.5,function( ... )
	-- 	self:Close()
	-- end)

	-- for k,v in pairs(self.dots) do
	-- 	v:TintTo({r=0,g=0,b=0,a=1},{r=0,g=0,b=0,a=0},0.33)
	-- end
	self:Close()
end

function GaleQteCookScreen:OnUpdate(dt)
	local dt_refine = math.min(dt, 1 / 60)

	if not self.has_ended and not self.pausing then
		local x, y = TheSim:GetScreenPos(self.owner:GetPosition():Get())
		self:SetPosition(x + 100, y + 140)
		if not self.arrow.cancel_input then
			local pos = self.arrow:GetPosition()
			if math.abs(pos.x) <= self.bar_len_vaild then
				self.arrow.sanityarrow:SetTint(0, 1, 1, 1)
			else
				self.arrow.sanityarrow:SetTint(1, 1, 1, 1)
			end
		end
		self.time_remain = self.time_remain - dt_refine
		self.cooktimer:GetAnimState():SetPercent("timer", self.time_remain / self.max_time_remain)
		local tick_period = self:GetTickPeriod()
		if GetTime() - self.last_tick_time >= tick_period then
			TheFocalPoint.SoundEmitter:PlaySoundWithParams("gale_sfx/cooking/p1_tick",
				{ intensity = GetRandomMinMax(0.3, 0.4) })
			self.last_tick_time = GetTime()
		end
		if self.time_remain <= 0 then
			self:End("FAILED")
		end
	end
end

return GaleQteCookScreen
