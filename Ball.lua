--
Ball = Class{}

BALL_RADIUS = 10
BALL_DX = 150
BALL_DX_MIN = 10
BALL_DY = 150
BALL_DY_MIN = 10

function Ball:init(x, y, radius)
    self.x = x
    self.y = y
    self.radius = radius

    self.dx = math.random(2) == 1 and -1 * BALL_DX or BALL_DX
    self.dy = math.random(2) == 1 and -1 * BALL_DY or BALL_DY
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 
    self.y = VIRTUAL_HEIGHT / 2 
    self.dx = math.random(2) == 1 and -1 * BALL_DX or BALL_DX
    self.dy = math.random(2) == 1 and -1 * BALL_DY or BALL_DY
    
end

function Ball:collides(player)

    if self.x - self.radius > player.x + player.width or player.x > self.x + self.radius then
        return false
    end

    
    if self.y - self.radius > player.y + player.height or player.y > self.y + self.radius then
        return false
    end 


    return true
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.circle('fill', self.x, self.y, self.radius)
end