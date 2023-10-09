push = require 'push'

Class = require 'class'

require 'Container'
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Catchit')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['stored'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['explode'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    player = Container(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT - 10, 20, 5)
    player_score = 0
    life = 3
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, 5, 4, 4)

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball:reset()
        ball.x = math.random(-5, VIRTUAL_WIDTH - 5)
        ball.dy = 50 + player_score * 4
        gameState = 'play'

    elseif gameState == 'play' then
        if ball:collides(player) then
            sounds['stored']:play()
            player_score = player_score + 1
            gameState = 'serve'
            
        end
        if ball.y > VIRTUAL_HEIGHT then
            sounds['explode']:play()
            life = life - 1
            if life == 0 then
                gameState = 'done'
            else 
                gameState = 'serve'
            end
        end
    end
    
    if love.keyboard.isDown('left') then
        player.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        player.dx = PADDLE_SPEED
    else
        player.dx = 0
    end
    if gameState == 'play' then
        ball:update(dt)
    end
    player:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            ball:reset()
            ball.x = math.random(-5, VIRTUAL_WIDTH - 5)
            ball.dy = math.random(50,70)
            gameState = 'play'
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            gameState = 'serve'

            ball:reset()
            player_score = 0
        end
    end
end

function love.draw()

    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to CatchIt!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to play!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- show the score before ball is rendered so it can move over the text
    displayScore()
    displayLife()

    player:render()
    ball:render()

    -- display FPS for debugging; simply comment out to remove
    displayFPS()

    -- end our drawing to push
    push:finish()
end

function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player_score), VIRTUAL_WIDTH / 2,
        VIRTUAL_HEIGHT / 3)
end

function displayLife()
    love.graphics.setFont(smallFont)
    love.graphics.print('Life: ' ..tostring(life), VIRTUAL_WIDTH - 50, 20)
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end



    