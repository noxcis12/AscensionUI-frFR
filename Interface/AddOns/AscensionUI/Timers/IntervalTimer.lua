IntervalTimer = {}
IntervalTimer.__index = IntervalTimer
IntervalTimer.interval = 0
IntervalTimer.time = 0

function IntervalTimer:new(interval)
    local self = {}
    setmetatable(self, IntervalTimer)
    self.interval = interval or 0
    self.time = interval or 0
    return self
end

function IntervalTimer:SetInterval(interval)
    self.interval = interval
    self.time = interval
end

function IntervalTimer:Update(elapsed)
    if self.time <= 0 or self.interval <= 0 then
        return false
    end

    self.time = self.time - elapsed
    if self.time > 0 then
        return false
    end

    self.time = self.interval
    return true
end
