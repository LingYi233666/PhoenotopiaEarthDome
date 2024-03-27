local GaleTooltip = require("widgets/galetooltip")
local Text = require("widgets/text")
-- local function strip(str,del)
--     local str = tostring(str)
--     if (del)
--     then
--         del = tostring(del)
--     else
--         del = tostring(" ")
--     end
--     i, j = 1, string.len(str)
--     while (i<=string.len(str))
--     do
--         if (string.sub(str,i,i) ~= del)
--         then
--             stringB = i
--             i = string.len(str) + 1
--         else
--             i = i + 1
--         end
--     end
--     while (j > 0)
--     do
--         if (string.sub(str,j,j) ~= del)
--         then
--             stringE = j
--             j = 0
--         else
--             j = j - 1
--         end
--     end
--     newStr = string.sub(str,stringB,stringE)
--     return newStr
-- end

AddReplicableComponent("gale_item_desc")

local COMPLEX_DESC_ENABLE = GetModConfigData("gale_complex_desc_enable", nil, true)


AddClassPostConstruct("widgets/hoverer", function(self)
	self.background = self.text:AddChild(GaleTooltip())
	self.background:SetClickable(false)
	self.background:MoveToBack()
	self.background.bg:SetTint(0.2, 0.2, 0.2, 1)
	for k, v in pairs(self.background.corners) do
		v:MoveToFront()
		v:SetScale(0.6, 0.6)
	end

	if not COMPLEX_DESC_ENABLE then
		self.background:Hide()
	else
		self.background:Show()
	end

	local function GetTarget()
		local target = TheInput:GetHUDEntityUnderMouse()
		local ret_widget = target and target.widget
		if target ~= nil then
			target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
		else
			target = TheInput:GetWorldEntityUnderMouse()
		end

		return target, ret_widget
	end

	local function GetHolder(target)
		local player = self.owner
		if target and target.replica and target.replica.inventoryitem then
			if target.replica.inventoryitem:IsHeldBy(player) then
				return player
			else
				for ent, ui in pairs(player.HUD.controls.containers) do
					if target.replica.inventoryitem:IsHeldBy(ent) then
						return ent
					end
				end
			end
		end
	end


	local old_UpdatePosition = self.UpdatePosition
	self.UpdatePosition = function(self, x, y)
		if not COMPLEX_DESC_ENABLE then
			return old_UpdatePosition(self, x, y)
		end

		local player = self.owner
		local target, ret_widget = GetTarget()

		local holder = target and GetHolder(target)
		local bg_w, bg_h = self.background:GetSize()
		local scr_w, scr_h = TheSim:GetScreenSize()
		local desc_w, desc_h = self.text:GetRegionSize()
		-- local inv_w,inv_h = player.HUD.controls.inv.inv[1].bgimage:GetSize()

		if holder and (holder == player or (holder.replica.container and holder.replica.container:IsSideWidget())) then
			local rx, ry, rz = ret_widget:GetWorldPosition():Get()
			local scale = self:GetScale()
			local w = 0
			local h = 0

			if self.text ~= nil and self.str ~= nil then
				w = math.max(w, bg_w)
				h = math.max(h, bg_h)
			end
			if self.secondarytext ~= nil and self.secondarystr ~= nil then
				local w1, h1 = self.secondarytext:GetRegionSize()
				w = math.max(w, w1)
				h = math.max(h, h1)
			end

			w = w * scale.x * .5
			h = h * scale.y * .5

			local YOFFSETUP = -80
			local YOFFSETDOWN = 31
			local XOFFSET = 200

			if holder == player then
				-- self:SetPosition(
				-- 	rx,
				-- 	math.clamp(y, h + YOFFSETDOWN * scale.y, scr_h - h - YOFFSETUP * scale.y),
				-- 	0
				-- )

				self:SetPosition(
					rx,
					ry + h + 15,
					0
				)
			else
				self:SetPosition(
					math.clamp(x, w + XOFFSET, scr_w - w - XOFFSET),
					ry,
					0
				)
			end
		else
			return old_UpdatePosition(self, x, y)
		end
	end

	local origin_SetString = Text.SetString
	local old_SetString = self.text.SetString
	self.text.SetString = function(text, str, ...)
		local old_ret = old_SetString(text, str, ...)
		if not COMPLEX_DESC_ENABLE then
			return old_ret
		end

		str = self.text:GetString()

		local player = self.owner
		local target, ret_widget = GetTarget()

		local holder = target and GetHolder(target)



		while true do
			if str[#str] ~= "\n" and str[#str] ~= "\t" and str[#str] ~= "\r" and str[#str] ~= " " then
				str = str .. "\n"
				break
			else
				str = string.sub(str, 1, #str - 1)
			end
		end

		if holder and (holder == player or (holder.replica.container and holder.replica.container:IsSideWidget())) then
			if target.replica.gale_item_desc then
				local simple_desc = target.replica.gale_item_desc:GetSimpleDesc()
				local complex_desc = target.replica.gale_item_desc:GetComplexDesc()

				if TheInput:IsKeyDown(KEY_LCTRL) then
					str = str .. complex_desc
				else
					if simple_desc and #simple_desc > 0 then
						str = str .. simple_desc .. "\n左CTRL:详细查看"
					else
						str = str .. "左CTRL:详细查看"
					end
				end
			end
			-- self.text:SetPosition(Vector3(0,80,0))
		end


		origin_SetString(text, str, ...)

		if holder and (holder == player or (holder.replica.container and holder.replica.container:IsSideWidget())) then
			local desc_w, desc_h = self.text:GetRegionSize()
			local bg_w, bg_h = self.background:GetSize()
			self.background.bg:SetSize(desc_w + 20, desc_h + 20)
			self.background:MakeLayout()
			self.background:Show()

			bg_w, bg_h = self.background:GetSize()

			-- if in_container then
			-- 	self.text:SetPosition(-bg_w / 2,0)
			-- else
			-- 	self.text:SetPosition(0,bg_h / 2)
			-- end
			self.text:SetHAlign(ANCHOR_LEFT)
			-- self.text:SetColour(167/255,248/255,228/255,1)
		else
			-- self.text:SetPosition(0,0)
			self.background:Hide()
			self.text:SetHAlign(ANCHOR_MIDDLE)
			-- self.text:SetColour(1,1,1,1)
		end


		local input_pos = TheInput:GetScreenPosition()
		self:UpdatePosition(input_pos.x, input_pos.y)

		return old_ret
	end
end)
