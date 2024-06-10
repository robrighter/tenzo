

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
-- Import the Block and Matrix classes
local blocks = import("blocks")


local grid = blocks.Grid:new(10, 10, 21, 21,10,10) -- Initialize grid with 20 rows and 10 columns, blocks are 32x32 pixels

-- Add some initial blocks to the grid
for row = 1, 10 do  -- Start from the second last row to the first
    if true then
        for col = 1, 10 do
            grid:addBlock(row, col, row-1)
            if col%2 == 0 then
                grid:highlight(row,col)
            end
        end
    end
end



function playdate.update()
    playdate.graphics.clear() -- Clears the screen, necessary to redraw the sprites
    grid:moveBlocksDown() -- Move blocks downward if space is available
    grid:draw() -- Draw the entire grid
end
