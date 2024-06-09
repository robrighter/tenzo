import 'CoreLibs/graphics'

-- Block Class
Block = {}
Block.__index = Block

function Block:new(x, y, number)
    local self = setmetatable({}, Block)
    self.number = number
    self.width = 20 -- Width of the block
    self.height = 20 -- Height of the block
    self.x = x
    self.y = y

    -- Create the sprite
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:setSize(self.width, self.height)
    self.sprite:setCenter(0.5, 0.5) -- Center the sprite
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()
    local that = self
    function self.sprite:draw(x, y, width, height)
        playdate.graphics.drawRect(x, y, width, height) -- Draw a black rectangle
        playdate.graphics.drawText(tostring(that.number), x + 6, y + 2)
    end

    return self
end

function Block:draw()
    --self.printProperties()
    if self.sprite then
        self.sprite:draw(self.x, self.y, self.width, self.height)
    end
end

function Block:printProperties()
    print({number = self.number, x = self.x, y = self.y})
end

function Block:moveTo(x, y)
    self.x, self.y = x, y
    self.sprite:moveTo(x, y)
end

function Block:remove()
    self.sprite:remove()
end

-- Grid Class
Grid = {}
Grid.__index = Grid

function Grid:new(rows, cols, blockWidth, blockHeight)
    local self = setmetatable({}, Grid)
    self.rows = rows
    self.cols = cols
    self.blockWidth = blockWidth
    self.blockHeight = blockHeight
    self.grid = {}

    for row = 1, rows do
        self.grid[row] = {}
        for col = 1, cols do
            self.grid[row][col] = nil
        end
    end

    return self
end

function Grid:addBlock(row, col, number)
    local x = (col - 1) * self.blockWidth + self.blockWidth / 2 + 1 -- Adjust for 1 px padding
    local y = (row - 1) * self.blockHeight + self.blockHeight / 2 + 1

    local block = Block:new(x, y, number)
    self.grid[row][col] = block
end

function Grid:moveBlocksDown()
    for row = self.rows - 1, 1, -1 do  -- Start from the second last row to the first
        for col = 1, self.cols do
            if self.grid[row][col] and self:isCellEmpty(row + 1, col) then
                -- Move the block downward
                self:moveBlock(row, col, row + 1, col)
            end
        end
    end
end

function Grid:isCellEmpty(row, col)
    if row > self.rows or row < 1 or col > self.cols or col < 1 then
        return false -- Outside grid bounds is considered not empty (prevents blocks from moving out of the grid)
    end
    return self.grid[row][col] == nil
end

function Grid:removeBlock(row, col)
    local block = self.grid[row][col]
    if block then
        block:remove()
        self.grid[row][col] = nil
    end
end

function Grid:draw()
    for row = 1, self.rows do
        for col = 1, self.cols do
            local block = self.grid[row][col]
            if block then
                block:draw() -- Drawing each block
            end
        end
    end
end

function Grid:moveBlock(fromRow, fromCol, toRow, toCol)
    local block = self.grid[fromRow][fromCol]
    if block and self.grid[toRow][toCol] == nil then
        self.grid[fromRow][fromCol] = nil
        self.grid[toRow][toCol] = block
        local x = (toCol - 1) * self.blockWidth + self.blockWidth / 2 + 1
        local y = (toRow - 1) * self.blockHeight + self.blockHeight / 2 + 1
        block:moveTo(x, y)
    end
end


-- Return Grid and Block to make them accessible outside this file
return { Grid = Grid, Block = Block }
