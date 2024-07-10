

import 'CoreLibs/graphics.lua'
import 'CoreLibs/timer.lua'
import 'CoreLibs/crank'

local gfx = playdate.graphics
local screenWidth, screenHeight = playdate.display.getSize()

local highScore = 0
local tilesRemaining = 0
local leastTilesRemaining = 0
local gameData = playdate.datastore.read()
if gameData then
    highScore = gameData.highScore
    leastTilesRemaining = gameData.leastTilesRemaining
end
if leastTilesRemaining == nil then
    leastTilesRemaining = 100
end
local score = 0
local gameIsOver = false
local showTitleScreen = true
local scoreBarHeight = 20
local cursorRow, cursorCol = 1, 1
-- Import the Block and Matrix classes
local blocks = import("blocks")
local gridready = false
local newLineTimerDelay = 20000
local bongoFont = gfx.font.new( "fonts/Bongo" )
local diamondFont = gfx.font.new( "fonts/diamond_12" )
local nontendoFont = gfx.font.new( "fonts/Nontendo-Bold-2x" )
local nontendoLightFont = gfx.font.new( "fonts/Nontendo-Light" )
local nontendoLight2xFont = gfx.font.new( "fonts/Nontendo-Light-2x" )
local oklahomaBoldFont = gfx.font.new( "fonts/Oklahoma-Bold.fnt" )
local isRotating = false
local rotationImage = nil
local rotationDirectionRight = false
local rotationAngle = 0
local ticksPerRevolution = 6
local grid = blocks.Grid:new(10, 10, 21, 21,170,15)
local menu = playdate.getSystemMenu()
local toastMessage = "To play, Line up numbers horizontally in order. Use 'B' to swap adjacent numbers. Use 'A' to swap with the end of the row. Use the crank to rotate the board. Line up 0-9 on one row and score a Tenzo!"


function restartGame()
    print("Restarting Game")
    saveGameData()
    gridready = false
    isRotating = false
    rotationImage = nil
    rotationDirectionRight = false
    score = 0
    tilesRemaining = 100
    grid = blocks.Grid:new(10, 10, 21, 21,170,15)
    -- Add some initial blocks to the grid
    for row = 1, 10 do  -- Start from the second last row to the first
        if true then
            for col = 1, 10 do
                grid:addBlock(row, col, math.random(0,9))    
            end
        end
    end

    gridready = true
end


function processRotationAnimation(isRightRotation)
    isRotating = true
    rotationDirectionRight = isRightRotation
    --Make the image context of the grid
    unhighlightCursor()
    rotationImage = gfx.image.new(212, 212, gfx.kColorWhite)
    gfx.pushContext(rotationImage) 
        grid:draw(true)
    gfx.popContext()
end

function insertRowAtBottom()
    for row = 2, 10 do
        for col = 1, 10 do
            grid:moveBlockForce(row, col, row - 1, col)
        end
    end
    for col = 1, 10 do
        grid:addBlock(10, col, math.random(0,9))
    end
end

function processSequences()
    for row = 1, 10 do
        local sequence = getLongestStraightSequenceOfNumbersInRow(row)
        if #sequence >= 3 then
            --add this sequence to the score
            score = score + factorial(#sequence)
            if score > highScore then
                highScore = score
            end
            for _, block in ipairs(sequence) do
                grid:highlight(block.row, block.col)
            end
            playdate.timer.performAfterDelay(300, function()
                for _, block in ipairs(sequence) do
                    block:remove()
                end
            end)
            
        end
    end
end

function getLongestStraightSequenceOfNumbersInRow(row)
    local sequence = {} -- to store the block objects in the sequence
    local longestSequence = {} -- to store the longest sequence found so far
    local currentNumber = nil -- to keep track of the current number in the sequence
    local currentSequenceLength = 0 -- to keep track of the length of the current sequence
    for col = 1, grid.cols do
        local block = grid:getBlockAt(row, col)
        
        if block.blank then
            -- If the block is blank, reset the current sequence
            currentNumber = nil
            currentSequenceLength = 0
        elseif currentNumber == nil or block.number == (currentNumber+1) then
            -- If the block has the incrment number as the current sequence or it's the first block in the sequence
            currentNumber = block.number
            currentSequenceLength = currentSequenceLength + 1
            table.insert(sequence, block)
            
            if currentSequenceLength >= 3 and currentSequenceLength > #longestSequence then
                -- If the current sequence is longer than the longest sequence found so far, update the longest sequence
                longestSequence = sequence
            end
        else
            -- If the block has a different number than the current sequence, reset the current sequence
            currentNumber = block.number
            currentSequenceLength = 1
            sequence = {block}
        end
    end
    
    return longestSequence
end

function checkForAvailableMoves()
    for i = 0, 7 do
        local group = {i, i+1, i+2}
        local found = {false, false, false}
        for row = 1, grid.rows do
            for col = 1, grid.cols do
                local block = grid:getBlockAt(row, col)
                if block.number == group[1] then
                    found[1] = true
                elseif block.number == group[2] then
                    found[2] = true
                elseif block.number == group[3] then
                    found[3] = true
                end
            end
        end
        if found[1] and found[2] and found[3] then
            return true
        end
    end
    return false
end

function factorial(n)
  if n <= 0 then
    return 1
  else
    return n * factorial(n-1)
  end
end

function unhighlightCursor()
    grid:unhighlight(cursorRow,cursorCol)
    grid:unhighlight(cursorRow,cursorCol+1)
end

function highlightCursor()
    grid:highlight(cursorRow,cursorCol)
    grid:highlight(cursorRow,cursorCol+1)
end


function playdate.update()
    gfx.clear() -- Clears the screen, necessary to redraw the sprites
    tilesRemaining = grid:countRemainingTiles()
    if tilesRemaining < leastTilesRemaining then
        leastTilesRemaining = tilesRemaining
    end
    --Draw the title and the score board
    gfx.setFont(bongoFont)
    gfx.fillRect(0, 0, screenWidth, scoreBarHeight, 0)
    gfx.fillRect(0, screenHeight-130, screenWidth, 150, 0)
    --reverse the text to white
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("TENZO", 10, 7)
    gfx.setColor(gfx.kColorWhite)
    if not isRotating then
        gfx.fillRect(170,15,212,212)
    end
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.setFont(nontendoLightFont)
    if checkForAvailableMoves() == true then
        gfx.drawText("High Score: " .. highScore, 10, 30)
        gfx.drawText("Lowest Tiles Remaining: " .. leastTilesRemaining, 10, 50)
        gfx.drawText("Score: " .. score, 10, 70)
        gfx.drawText("Tiles Remaining: " .. tilesRemaining, 10, 90)
    else
        gfx.drawText("No moves left!", 10, 30)
        gfx.drawText("Start a new game in the menu.", 10, 50)
        gfx.drawText("High Score: " .. highScore, 10, 70)
        gfx.drawText("Score: " .. score, 10, 90)
    end

    --draw the toast message
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextInRect(toastMessage, 10,125, 150, 160)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)

    
    

    gfx.setFont(oklahomaBoldFont)
    grid:moveBlocksDown() -- Move blocks downward if space is available
    if gridready then
        unhighlightCursor()
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
            grid:swap(cursorRow,cursorCol,cursorRow,10)
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            grid:swap(cursorRow,cursorCol,cursorRow,cursorCol+1)
        end
        --detect cranks
        local crankTicks = playdate.getCrankTicks(ticksPerRevolution)
        if crankTicks == 1 then
            processRotationAnimation(true)
        elseif crankTicks == -1 then
            processRotationAnimation(false)
        end
    end
   
    playdate.timer.updateTimers()
    if isRotating then
        --rotate the image of the grid
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        rotationImage:drawRotated(280, 120, rotationAngle)
        if rotationDirectionRight then
            rotationAngle = rotationAngle + 5
        else
            rotationAngle = rotationAngle - 5
        end
        if rotationAngle >= 90 or rotationAngle <= -90 then
            if rotationDirectionRight then
                grid:rotateRight()
            else
                grid:rotateLeft()
            end
            isRotating = false
            rotationAngle = 0
        end
    else
        processSequences()
        highlightCursor()
        grid:draw() -- Draw the entire grid
    end
end

function saveGameData()
    -- Save game data into a table first
    local gameData = {
        highScore = highScore,
        leastTilesRemaining = leastTilesRemaining
    }
    playdate.datastore.write(gameData)
end

-- Automatically save game data when the player chooses
-- to exit the game via the System Menu or Menu button
function playdate.gameWillTerminate()
    saveGameData()
end

-- Automatically save game data when the device goes
-- to low-power sleep mode because of a low battery
function playdate.gameWillSleep()
    saveGameData()
end

--bootstrap the game
local menuItem, error = menu:addMenuItem("Restart Game", restartGame)
restartGame()