import 'CoreLibs/graphics'

-- Block Class
Block = {}
Block.__index = Block

function Block:new(row, col, number, width, height)
    local self = setmetatable({}, Block)
    if number < 0 then
        self.blank=true
        self.number = -1
    else
        self.blank=false
        self.number = number
    end
    self.width = width -- Width of the block
    self.height = height -- Height of the block
    self.row = row
    self.col = col
    self.x = 0
    self.y = 0
    self.highlighted = false

    -- Create the sprite
    self.sprite = playdate.graphics.sprite.new()
    self.sprite:setSize(self.width, self.height)
    self.sprite:setCenter(0.5, 0.5) -- Center the sprite
    self.sprite:moveTo(self.x, self.y)
    self.sprite:add()
    local that = self
    function self.sprite:draw(x, y, width, height)
        if that.highlighted then
            playdate.graphics.fillRect(x, y, width-1, height-1)    
            playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
        else
            playdate.graphics.drawRect(x, y, width-1, height-1)
        end
        if not that.blank then
            playdate.graphics.drawText(tostring(that.number), x + 6, y + 2)    
        end
        playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
    end

    return self
end

function Block:calculateSpriteCoordinates(gridStartX, gridStartY)
    self.x = 2+gridStartX + ((self.col - 1) * self.width)
    self.y = 2+gridStartY + ((self.row - 1) * self.height)
end


function Block:draw(offsetx, offsety)
    --self.printProperties()
    self:calculateSpriteCoordinates(offsetx, offsety)
    if self.sprite then
        self.sprite:draw(self.x, self.y, self.width, self.height)
    end
end

function Block:printProperties()
    print({number = self.number, x = self.x, y = self.y})
end

function Block:moveTo(row, col, offsetx, offsety)
    self.row, self.col = row, col
    self:calculateSpriteCoordinates(offsetx, offsety)
    self.sprite:moveTo(self.x, self.y)
end

function Block:remove()
    self.sprite:remove()
end

-- Grid Class
Grid = {}
Grid.__index = Grid

function Grid:new(rows, cols, blockWidth, blockHeight, offsetx, offsety)
    local self = setmetatable({}, Grid)
    self.rows = rows
    self.cols = cols
    self.blockWidth = blockWidth
    self.blockHeight = blockHeight
    self.offsetx = offsetx
    self.offsety = offsety
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
    local block = Block:new(row, col, number, self.blockWidth, self.blockHeight)
    self.grid[row][col] = block
end

function Grid:getBlockAt(row, col)
    return self.grid[row][col]
end

function Grid:highlight(row,col)
    local block = self.grid[row][col]
    if block then
        block.highlighted = true
    end
end

function Grid:unhighlight(row,col)
    local block = self.grid[row][col]
    if block then
        block.highlighted = false
    end
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
    --draw a rectangle around the grid
    playdate.graphics.drawRect(self.offsetx, self.offsety, 3+(self.cols * self.blockWidth), 3+(self.rows * self.blockHeight))

    --draw the blocks
    for row = 1, self.rows do
        for col = 1, self.cols do
            local block = self.grid[row][col]
            if block then
                block:draw(self.offsetx, self.offsety)
            end
        end
    end
end

function Grid:moveBlock(fromRow, fromCol, toRow, toCol)
    local block = self.grid[fromRow][fromCol]
    if block and self.grid[toRow][toCol] == nil then
        self.grid[fromRow][fromCol] = nil
        self.grid[toRow][toCol] = block
        block:moveTo(toRow, toCol, self.offsetx, self.offsety)
    end
end

function Grid:moveBlockForce(fromRow, fromCol, toRow, toCol)
    local block = self.grid[fromRow][fromCol]
    self.grid[toRow][toCol] = block
    block:moveTo(toRow, toCol, self.offsetx, self.offsety)
end

function Grid:swap(row1, col1, row2, col2)
    local block1 = self.grid[row1][col1]
    local block2 = self.grid[row2][col2]
    if block1 and block2 then
        self.grid[row1][col1] = block2
        self.grid[row2][col2] = block1
        block1:moveTo(row2, col2, self.offsetx, self.offsety)
        block2:moveTo(row1, col1, self.offsetx, self.offsety)
    end
end


-- Return Grid and Block to make them accessible outside this file
return { Grid = Grid, Block = Block }