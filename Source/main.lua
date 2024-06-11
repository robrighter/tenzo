

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
local cursorRow, cursorCol = 1, 1
-- Import the Block and Matrix classes
local blocks = import("blocks")
local gridready = false


local grid = blocks.Grid:new(10, 10, 21, 21,10,10) -- Initialize grid with 20 rows and 10 columns, blocks are 32x32 pixels

-- Add some initial blocks to the grid
for row = 1, 10 do  -- Start from the second last row to the first
    if true then
        for col = 1, 10 do
            grid:addBlock(row, col, math.random(0,9))
        end
    end
end
gridready = true


function playdate.update()
    playdate.graphics.clear() -- Clears the screen, necessary to redraw the sprites
    grid:moveBlocksDown() -- Move blocks downward if space is available
    if gridready then
        grid:unhighlight(cursorRow,cursorCol)
        grid:unhighlight(cursorRow,cursorCol+1)
        if playdate.buttonJustPressed(playdate.kButtonDown) then
            if cursorRow < grid.rows then
                cursorRow = cursorRow + 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonUp) then
            if cursorRow > 1 then
                cursorRow = cursorRow - 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
            if cursorCol > 1 then
                cursorCol = cursorCol - 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonRight) then
            if (cursorCol-1) < grid.cols then
                cursorCol = cursorCol + 1
            end
        elseif playdate.buttonJustPressed(playdate.kButtonA) then
            grid:swap(cursorRow,cursorCol,cursorRow,cursorCol+1)
        end
        grid:highlight(cursorRow,cursorCol)
        grid:highlight(cursorRow,cursorCol+1)
    end
    
    grid:draw() -- Draw the entire grid
end
