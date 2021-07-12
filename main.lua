--
push = require 'push'
Class = require 'class'

require 'Ball'
require 'Player'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = WINDOW_WIDTH
VIRTUAL_HEIGHT = WINDOW_HEIGHT
-- VIRTUAL_WIDTH = 432
-- VIRTUAL_HEIGHT = 243

SPEED_FACTOR = 1.03
WINNING_SCORE = 10
MIDDLE_LINE_WIDTH = 10
MIDDLE_LINE_HEIGHT = 20

gameState = 'menu'
fpsFlag = true

function initBoard()
    player1 = Player(BUFFER_WIDTH, BUFFER_HEIGHT, PLAYER_WIDTH, PLAYER_LENGTH)
    player2 = Player(VIRTUAL_WIDTH - BUFFER_WIDTH -PLAYER_WIDTH, VIRTUAL_HEIGHT - BUFFER_HEIGHT, PLAYER_WIDTH, PLAYER_LENGTH)

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 , VIRTUAL_HEIGHT / 2 , BALL_RADIUS)
    player1Score = 0
    player2Score = 0

    winningPlayer = 0
end

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong! | Akash Agrahari')

    math.randomseed(os.time())
    titleFont = love.graphics.newFont('fonts/font.ttf', 128)
    textFont = love.graphics.newFont('fonts/font.ttf', 48)
    fpsFont = love.graphics.newFont('fonts/font.ttf', 10)


    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    sounds = {
        ['player'] = love.audio.newSource('sounds/player.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall'] = love.audio.newSource('sounds/wall.wav', 'static'),
        ['yay'] = love.audio.newSource('sounds/yay.wav', 'static')
    }

    initBoard()
end

function love.update(dt)
    
    if gameState == 'play' then
    
        if ball:collides(player1) then
            ball.dx = -ball.dx * SPEED_FACTOR
            ball.x = player1.x + PLAYER_WIDTH + ball.radius

            if ball.dy < 0 then
                ball.dy = -math.random(BALL_DY_MIN, BALL_DY)
            else
                ball.dy = math.random(BALL_DY_MIN, BALL_DY)
            end

            sounds['player']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * SPEED_FACTOR
            ball.x = player2.x - BALL_RADIUS

            if ball.dy < 0 then
                ball.dy = -math.random(BALL_DY_MIN, BALL_DY)
            else
                ball.dy = math.random(BALL_DY_MIN, BALL_DY)
            end
            sounds['player']:play()
        end

        -- detect upper and lower screen boundary 
        if ball.y - ball.radius <= 0 then
            ball.y = ball.radius
            ball.dy = -ball.dy
            sounds['wall']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - BALL_RADIUS then
            ball.y = VIRTUAL_HEIGHT - BALL_RADIUS
            ball.dy = -ball.dy
            sounds['wall']:play()
        end
    end    

    if ball.x - ball.radius < 0 then
        player2Score = player2Score + 1
        ball:reset()
        gameState = 'pause'
        sounds['score']:play()
    end

    if ball.x + ball.radius > VIRTUAL_WIDTH then
        player1Score = player1Score + 1
        ball:reset()
        gameState = 'pause'
        sounds['score']:play()
    end

    if player1Score == WINNING_SCORE then
        winningPlayer = 1
    elseif player2Score == WINNING_SCORE then
        winningPlayer = 2
    end

    if gameState == 'play' then
        -- player 1 movement
        if love.keyboard.isDown('w') then
            player1.dy = -PLAYER_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PLAYER_SPEED
        else
            player1.dy = 0
        end

        -- player 2 movement
        if love.keyboard.isDown('up') then
            player2.dy = -PLAYER_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PLAYER_SPEED
        else
            player2.dy = 0
        end
        
        ball:update(dt)

        player1:update(dt)
        player2:update(dt)
    end

    
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'menu' then
            sounds['yay']:play()
            gameState = 'pause'
        elseif gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            if winningPlayer ~=0 then
                sounds['yay']:play()
                winningPlayer = 0
                player1Score = 0
                player2Score = 0
            else
                gameState = 'play'
            end
        end
    elseif key == 'f' then
        fpsFlag = not fpsFlag
    end
end


function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- love.graphics.circle('fill', 100, 50, 50)
    -- love.graphics.rectangle('fill', 100, 100, 100, 100)
    if gameState == 'menu' then

        love.graphics.clear(40/255, 45/255, 52/255, 255/255)
        love.graphics.setFont(titleFont)
        love.graphics.printf('Pong!', 0, VIRTUAL_HEIGHT/4, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(textFont)
        if math.floor(love.timer.getTime()) % 2 ~= 0 then
            love.graphics.printf('Press enter to start', 0, VIRTUAL_HEIGHT/4 +250, VIRTUAL_WIDTH, 'center')
        end
    else
        displayMiddleLine()


        love.graphics.setFont(textFont)
        -- love.graphics.printf(gameState ..' State!', 0, 20, VIRTUAL_WIDTH, 'center')
        player1:render()
        player2:render()
    
        -- render ball using its class's render method
        ball:render()

        displayScore()

        if winningPlayer ~= 0 then
            displayResult()
        end
    
    end

    if fpsFlag then 
        displayFPS()
    end

    push:finish()
end

function displayScore()
    love.graphics.setFont(textFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 60, 
        VIRTUAL_HEIGHT / 4)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 4)
end

function displayResult()
    love.graphics.setFont(textFont)
    love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, VIRTUAL_HEIGHT/2, VIRTUAL_WIDTH, 'center')
end

function displayMiddleLine()
    c = 5
    while c < VIRTUAL_HEIGHT
    do
        love.graphics.rectangle('fill', VIRTUAL_WIDTH/2 - (MIDDLE_LINE_WIDTH/2), c, MIDDLE_LINE_WIDTH, MIDDLE_LINE_HEIGHT)
        c = c + (MIDDLE_LINE_HEIGHT*2)
    end
end

function displayFPS()
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(0,255,0,255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end