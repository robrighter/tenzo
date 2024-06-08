

import 'CoreLibs/graphics'

local screenWidth, screenHeight = playdate.display.getSize()

local paddleWidth, paddleHeight = 20, 60
local paddleX, paddleY = 10, (screenHeight - paddleHeight) / 2

local ballSize = 10
local ballX, ballY = screenWidth - 20, (screenHeight - ballSize) / 2
local ballSpeedX, ballSpeedY = -5, 5
local paddleSpeed = 7
local highScore = playdate.datastore.read("highScore") or 0
local score = 0
local gameIsOver = false
local showTitleScreen = true
local scoreBarHeight = 20

-- Load custom font
local pathToFont = "fonts/diamond_12.fnt"
local customFont = playdate.graphics.font.new(pathToFont) -- Make sure the font file is in your source directory

--if not customFont then
--    error("Failed to load the font from path: " .. pathToFont)
--end

-- Set the font
playdate.graphics.setFont(customFont)

local haikus = {
    "Lonely court awaits\nBall bounces wall to paddle\nEndless rally mourns",
    "Silent echoes call\nBall meets wall in solitude\nPaddle stands alone",
    "Empty field of play\nOne paddle, one ball, one wall\nLonely game goes on",
    "Solo player sighs\nBack and forth the ball replies\nLonely match, no ties",
    "Walls don't talk back much\nPaddle's touch the only friend\nBall bounces, heart breaks"
}
local selectedHaiku = haikus[math.random(#haikus)]

function playdate.update()
    
    if showTitleScreen then
        playdate.graphics.clear()
        playdate.graphics.drawText("LONELY TENNIS", 125, 80)
        playdate.graphics.drawText("[ press A to start ]", 120, 120)
        playdate.graphics.drawText(selectedHaiku, 90, 170)
        if playdate.buttonIsPressed(playdate.kButtonA) then
            showTitleScreen = false
        end
    elseif not gameIsOver then
        -- Input handling for the paddle
        if playdate.buttonIsPressed(playdate.kButtonUp) then
            paddleY = math.max(scoreBarHeight, paddleY - paddleSpeed)
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            paddleY = math.min(screenHeight - paddleHeight, paddleY + paddleSpeed)
        end

        -- Move the ball
        ballX = ballX + ballSpeedX
        ballY = ballY + ballSpeedY

        -- Collision detection with top and bottom screen edges
        if ballY <= scoreBarHeight or ballY + ballSize >= screenHeight then
            ballSpeedY = -ballSpeedY
        end

        -- Check for ball hitting the back wall
        if ballX + ballSize >= screenWidth then
            ballSpeedX = -ballSpeedX  -- Bounce the ball back
            score = score + 1         -- Increase the score
        end

        -- Check for game over condition
        if ballX <= paddleX + paddleWidth then
            if ballY + ballSize < paddleY or ballY > paddleY + paddleHeight then
                gameIsOver = true
                -- Optionally display a game over message here
                playdate.graphics.drawText("Game Over! Score: " .. score, 100, 10)
            else
                ballSpeedX = -ballSpeedX  -- Bounce the ball back
            end
        end

        -- Draw everything
        playdate.graphics.clear()
        -- Draw the score bar
        playdate.graphics.setColor(playdate.graphics.kColorBlack)  -- Score bar background color
        playdate.graphics.fillRect(0, 0, screenWidth, scoreBarHeight)
      -- Set text properties for the score display
        playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)  -- Reverse color for text
        playdate.graphics.drawText("Score: " .. score, 10, 2)  -- Current score on the left
        playdate.graphics.drawText("High Score: " .. highScore, screenWidth - 120, 2)  -- High score on the right
        playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
        playdate.graphics.fillRect(paddleX, paddleY, paddleWidth, paddleHeight)
        playdate.graphics.fillRect(ballX, ballY, ballSize, ballSize)

    else
        playdate.graphics.drawText("Game Over! Score: " .. score, 100, 50)
        playdate.graphics.drawText("[ Press A to restart ]", 100, 80)
        if playdate.buttonIsPressed(playdate.kButtonA) then
            -- Check if current score is a new high score
            if score > highScore then
                highScore = score
                playdate.datastore.write("highScore", highScore)
            end
            -- Reset the game
            ballX, ballY = screenWidth - 20, (screenHeight - ballSize) / 2
            score = 0
            gameIsOver = false
            showTitleScreen = true
            selectedHaiku = haikus[math.random(#haikus)]  -- Select a new haiku
        end
    end
end
