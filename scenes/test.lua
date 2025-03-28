local pieces = require 'components.pieces'

local unpack = unpack or table.unpack

local NOPIECE = {
    piece = 0,
    visualOffsets = {0, 0},
    updateTime = 0,
    spawnTime = 0,
    hidden = false,
}

local function lineCap(x1, y1, x2, y2)
    local lw = love.graphics.getLineWidth()/2
    love.graphics.circle('fill', x1, y1, lw)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.circle('fill', x2, y2, lw)
end

local Test = {
    matrix = {
        panels = {
            --[[ {{piece=1,visualOffsets={0,0},updateTime=0}, {piece=2,visualOffsets={0,0},updateTime=0}, {piece=3,visualOffsets={0,0},updateTime=0}, deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {{piece=2,visualOffsets={0,0},updateTime=0}, {piece=1,visualOffsets={0,0},updateTime=0}, deepCopy(NOPIECE), {piece=4,visualOffsets={0,0},updateTime=0}, deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)},
            {deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE), deepCopy(NOPIECE)}, ]]
        },
        size = {5, 10},
        topLeft = {0, 0},
    },

    cursor = {
        position = {1, 1},
        visualPosition = {1, 1},
    },

    visualSize = {40, 30},

    colors = {
        piece  = {0, 1, 0, 1},
        line   = {1, 1, 0, 1},
        cursor = {1, 0, 1, 1},
    },

    initMatrix = function(width, height)
        local matrix = {panels = {}, size = {width, height}}
        
        for i = 1,height do
            table.insert(matrix.panels, {})
            for j = 1,width do
                table.insert(matrix.panels[i], deepCopy(NOPIECE))
            end
        end

        return matrix
    end,

    createRandomLine = function(self, panelAmount)
        local line = {}
        for i = 1, self.matrix.size[1] do
            table.insert(line, deepCopy(NOPIECE))
        end

        for i = 1, panelAmount do
            local randomPanel = love.math.random(1, self.matrix.size[1])
            while line[randomPanel].piece > 0 do
                randomPanel = love.math.random(1, self.matrix.size[1])
            end

            line[randomPanel].piece = love.math.random(1, #pieces.pieces)
            line[randomPanel].spawnTime = love.timer.getTime()
        end

        return line
    end,

    moveCursor = function(self, dx, dy)
        self.cursor.position[1] = self.cursor.position[1] + dx
        if self.cursor.position[1] < 1 then
            self.cursor.position[1] = 1
        end
        if self.cursor.position[1] > self.matrix.size[1] then
            self.cursor.position[1] = self.matrix.size[1]
        end

        self.cursor.position[2] = self.cursor.position[2] + dy
        if self.cursor.position[2] < 1 then
            self.cursor.position[2] = 1
        end
        if self.cursor.position[2] >= self.matrix.size[2] then
            self.cursor.position[2] = self.matrix.size[2] - 1
        end
    end,

    doSwap = function(self)
        local x = self.cursor.position[1]
        local y = self.cursor.position[2]
        local idA = self.matrix.panels[y][x].piece
        local idB = self.matrix.panels[y+1][x].piece

        print(x, y, idA, idB)

        self.matrix.panels[y][x].piece = idB
        self.matrix.panels[y+1][x].piece = idA

        self.matrix.panels[y][x].updateTime = love.timer.getTime()
        self.matrix.panels[y+1][x].updateTime = love.timer.getTime()

        self.matrix.panels[y][x].visualOffsets[2] = 1
        self.matrix.panels[y+1][x].visualOffsets[2] = -1
    end,

    opened = function(self, game)
        self.matrix = self.initMatrix(5, 10)
        self.matrix.topLeft = {math.floor((love.graphics.getWidth() - 5*self.visualSize[1])/2), math.floor((love.graphics.getHeight() - 10*self.visualSize[2])/2)}
        for i = 1, 10 do
            self.matrix.panels[i] = self:createRandomLine(2)
        end
    end,

    keypressed = function(self, game, key)
        if key == 'up' then
            self:moveCursor(0, -1)
        elseif key == 'down' then
            self:moveCursor(0, 1)
        elseif key == 'left' then
            self:moveCursor(-1, 0)
        elseif key == 'right' then
            self:moveCursor(1, 0)
        elseif key == 'space' then
            self:doSwap()
        end
    end,

    update = function(self, game, dt)
        -- animations
        for y, line in ipairs(self.matrix.panels) do
            for x, panel in ipairs(line) do
                if panel.visualOffsets[2] < 0 then
                    panel.visualOffsets[2] = math.min(0, panel.visualOffsets[2] + 10*dt)
                elseif panel.visualOffsets[2] > 0 then
                    panel.visualOffsets[2] = math.max(0, panel.visualOffsets[2] - 10*dt)
                end

                panel.visualOffsets[1] = math.sin(math.pi * panel.visualOffsets[2])/3
            end
        end
        self.cursor.visualPosition[1] = self.cursor.visualPosition[1] + (self.cursor.position[1] - self.cursor.visualPosition[1])*20*dt
        if math.abs(self.cursor.position[1] - self.cursor.visualPosition[1]) <= 0.02 then
            self.cursor.visualPosition[1] = self.cursor.position[1]
        end
        self.cursor.visualPosition[2] = self.cursor.visualPosition[2] + (self.cursor.position[2] - self.cursor.visualPosition[2])*20*dt
        if math.abs(self.cursor.position[2] - self.cursor.visualPosition[2]) <= 0.02 then
            self.cursor.visualPosition[2] = self.cursor.position[2]
        end
    end,

    draw = function(self, game)
        local scale = (math.max(love.graphics.getWidth(), love.graphics.getHeight()))/800

        self.visualSize = {40*scale, 30*scale}
        self.matrix.topLeft = {math.floor((love.graphics.getWidth() - 5*self.visualSize[1])/2), math.floor((love.graphics.getHeight() - 10*self.visualSize[2])/2)}

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(scale .. ' ' .. 40*scale .. ' ' .. 30*scale, 0, 0)

        for y, line in ipairs(self.matrix.panels) do
            for x, panel in ipairs(self.matrix.panels[y]) do
                love.graphics.setLineWidth(1*scale)
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle('line', (x - 1 + panel.visualOffsets[1])*self.visualSize[1] + self.matrix.topLeft[1], (y - 1 + panel.visualOffsets[2])*self.visualSize[2] + self.matrix.topLeft[2], self.visualSize[1], self.visualSize[2])

                if panel.piece > 0 then
                    love.graphics.setLineWidth(3*scale)
                    love.graphics.setColor(unpack(self.colors.piece))
                    local cx = math.floor((x - 1 + panel.visualOffsets[1] + 1/2)*self.visualSize[1] + self.matrix.topLeft[1])
                    local cy = math.floor((y - 1 + panel.visualOffsets[2] + 1/2)*self.visualSize[2] + self.matrix.topLeft[2])
                    --love.graphics.circle('fill', cx, cy, 10)
                    local piece = pieces.pieces[panel.piece]
                    for i, v in ipairs(piece) do
                        --love.graphics.circle('fill', cx + (v[1]/2)*self.visualSize[1], cy + (v[2]/2)*self.visualSize[2], 10)
                        lineCap(cx + (v[1]/2)*self.visualSize[1], cy + (v[2]/2)*self.visualSize[2], cx, cy)
                    end
                end
            end
        end

        -- cursor
        love.graphics.setColor(unpack(self.colors.cursor))
        love.graphics.setLineWidth(5*scale)
        love.graphics.rectangle('line', (self.cursor.visualPosition[1] - 1)*self.visualSize[1] + self.matrix.topLeft[1], (self.cursor.visualPosition[2] - 1)*self.visualSize[2] + self.matrix.topLeft[2], self.visualSize[1], 2*self.visualSize[2])
    end
}

local function rtprint(t)
    for k, v in pairs(t) do
        if type(v) == 'table' then
            io.write('{ ')
            rtprint(v)
            io.write('}')
        else
            io.write(v..' ')
        end
    end
end

--local line = pieces.connectedPieces(Test.matrix, 1, 1)
--print(rtprint(line))

return Test