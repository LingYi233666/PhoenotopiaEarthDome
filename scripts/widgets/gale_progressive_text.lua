local Widget = require "widgets/widget" 
local Image = require "widgets/image"
local Text = require "widgets/text"
local easing = require("easing")

local function charsize(ch)
    if not ch then 
        return 0
    elseif ch >=252 then 
        return 6
    elseif ch >= 248 and ch < 252 then 
        return 5
    elseif ch >= 240 and ch < 248 then 
        return 4
    elseif ch >= 224 and ch < 240 then 
        return 3
    elseif ch >= 192 and ch < 224 then 
        return 2
    elseif ch < 192 then 
        return 1
    end
end

local function utf8len(str)
    local len = 0
    local aNum = 0 --字母个数
    local hNum = 0 --汉字个数
    local currentIndex = 1
    while currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        local cs = charsize(char)
        currentIndex = currentIndex + cs
        len = len +1
        if cs == 1 then 
            aNum = aNum + 1
        elseif cs >= 2 then 
            hNum = hNum + 1
        end
    end
    return len, aNum, hNum
end

-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
local function utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + charsize(char)
        startChar = startChar - 1
    end

    local currentIndex = startIndex

    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + charsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end


-- local function utf8sub(str, startChar, endChars)
-- 	local numChars = endChars - startChar
--     local startIndex = 1
--     while startChar > 1 do
--         local char = string.byte(str, startIndex)
--         startIndex = startIndex + charsize(char)
--         startChar = startChar - 1
--     end

--     local currentIndex = startIndex
	
--     while numChars > 0 and currentIndex <= #str do
--         local char = string.byte(str, currentIndex)
--         currentIndex = currentIndex + charsize(char)
--         numChars = numChars -1
--     end
--     return str:sub(startIndex, currentIndex)
-- end

local GaleProgressiveText = Class(Text,function(self,font, size, text, colour,speed,left_top_pos)
    Text._ctor(self,font, size, "", colour)

    self.full_text = text
    self.speed = speed or 12 
    self.current_id = 1
    self.target_id = nil 
    self.max_id = utf8len(text)
    self.is_updating = false 
    self.is_backward = false 

    left_top_pos = left_top_pos or Vector3(-190,60)

    -- self:SetVAlign(ANCHOR_TOP)
    self:SetHAlign(ANCHOR_LEFT)

    if left_top_pos then
        self:SetLeftTopPosition(left_top_pos.x,left_top_pos.y)
    end
end)

function GaleProgressiveText:AtEnd()
    return self.current_id >= self.max_id
end

function GaleProgressiveText:UpdateTo(target_id)
    self.target_id = math.clamp(target_id,1,self.max_id)
    self.is_backward = self.target_id < self.current_id
    if not self.is_updating then
        self.is_updating = true 
        self:StartUpdating()
    end
end

function GaleProgressiveText:Flush()
    if self.is_updating then
        self.current_id = self.target_id
        self:OnUpdate(FRAMES)
    end
end

function GaleProgressiveText:UpdateToNext(chars)
    chars = chars or "\n"
    local target_id = self.max_id
    for i = self.current_id+1,self.max_id do
        if utf8sub(self.full_text,i,1) == chars then
            target_id = i
            break
        end
    end    
    self:UpdateTo(target_id)
end

function GaleProgressiveText:OnUpdate(dt)
    local should_stop = false 
    self.current_id = self.current_id + dt * self.speed * (self.is_backward and -1 or 1)
    

    if not self.is_backward and self.current_id >= self.target_id then
        self.current_id = self.target_id
        should_stop = true 
    end

    if self.is_backward and self.current_id <= self.target_id then
        self.current_id = self.target_id
        should_stop = true 
    end

    local current_str = self:GetString()
    local next_str = utf8sub(self.full_text,1,math.floor(self.current_id))

    if #current_str ~= #next_str then
        -- TODO:Add click sound here
        
    end

    

    self:SetString(next_str)

    self:ResetPosition(self.left_top_pos.x,self.left_top_pos.y)

    if should_stop then
        self.is_updating = false  
        self:StopUpdating()
    end
end

function GaleProgressiveText:DoMouseClick()
    if self.is_updating then
        self:Flush()
    elseif not self:AtEnd() then
        self:UpdateToNext("\n")
    end
end

function GaleProgressiveText:SetLeftTopPosition(x,y)
    self.left_top_pos = Vector3(x,y,0)
    self:ResetPosition(x,y)
end

function GaleProgressiveText:ResetPosition(x,y)
    local w,h = self:GetRegionSize()
    self:SetPosition(w/2 + x,-h/2 + y)
end

return GaleProgressiveText