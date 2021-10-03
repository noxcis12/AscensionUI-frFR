CountdownTimer = {}
CountdownTimer.__index = CountdownTimer
CountdownTimer.time = 0

function CountdownTimer:new(time)
    local self  = {}
    setmetatable(self, CountdownTimer)
    self.time = time or 0
    return self
end

function CountdownTimer:SetTimer(time)
    self.time = time
end 

function CountdownTimer:Update(elapsed)
    if self.time <= 0 then
        return false
    end
    
    self.time = self.time - elapsed
    if self.time > 0 then
        return false
    end
    
    return true
end
