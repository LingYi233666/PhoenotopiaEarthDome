local TicToc = Class(function(self)
    self.savetime = nil 
    self.rate = 1000 -- return time in ms 
    
    self:Tic()
end)

function TicToc:Tic()
    self.savetime = GetTime()
end

function TicToc:Toc()
    return self.rate * (GetTime() - self.savetime)
end

-- local TicToc = require("util/tictoc")

return TicToc