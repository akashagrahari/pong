--
Player = Class{}

PLAYER_SPEED = 300
PLAYER_WIDTH = 20
PLAYER_LENGTH = 100

BUFFER_WIDTH = 10
BUFFER_HEIGHT = 50

function Player:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Player:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Player:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end