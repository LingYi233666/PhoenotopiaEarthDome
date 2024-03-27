local Image = require "widgets/image"
local Widget = require "widgets/widget"

local ComingSoonTip = Class(Image,function(self)
    Image._ctor(self,"images/ui/work_in_progress.xml","work_in_progress.tex")
end)

return ComingSoonTip