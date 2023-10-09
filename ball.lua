Ball = Class{}


function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Ball:update(dt)
    self.y = self.y + self.dy * dt
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH/2
    self.y = 5
    self.dx = 0
    self.dy = 0
end

function Ball:collides(container)
    if self.y > container.y + container.height or container.y > self.y + self.height then
        return false
    end
    
    if self.x > container.x + container.width or container.x > self.x + self.width then
        return false
    end

    return true
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end


