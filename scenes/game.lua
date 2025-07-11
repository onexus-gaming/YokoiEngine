local pieces = require 'components.pieces'

local unpack = unpack or table.unpack

local NOPIECE = {
    piece = 0,
    visualOffsets = {0, 0},
    updateTime = 0,
    spawnTime = 0,

    hidden = false,

    active = false,
    activePiece = 0,
}

local function lineCap(x1, y1, x2, y2)
    local lw = love.graphics.getLineWidth()/2
    love.graphics.circle('fill', x1, y1, lw)
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.circle('fill', x2, y2, lw)
end

local function rtprint(t)
    --[[ io.write('{ ')
    for k, v in pairs(t) do
        io.write(k..'->')
        if type(v) == 'table' then
            io.write('{ ')
            rtprint(v)
            io.write('}')
        else
            io.write(v..' ')
        end
    end
    io.write(' }') ]]
    print(dump(t))
end

local Game = {
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
        prevLine = {},
        size = {5, 10},
        topLeft = {0, 0},
    },

    skin = {},

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

    resetActiveState = function(self)
        for y = 1, self.matrix.size[2] do
            for x = 1, self.matrix.size[1] do
                self.matrix.panels[y][x].active = false
            end
        end
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

        local connected1 = pieces.piecesConnectedToCorner(self.matrix, self.cursor.position[1], self.cursor.position[2], 1)
        local connected2 = pieces.piecesConnectedToCorner(self.matrix, self.cursor.position[1], self.cursor.position[2]+1, 1)

        print('MOTION')
        print('--')
        rtprint(connected1)
        rtprint(connected2)
        print()
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

        if idA == 0 and idB == 0 then
            self:playSound 'swap0'
        elseif idA > 0 and idB > 0 then
            self:playSound 'swap2'
        else
            self:playSound 'swap1'
        end

        --[[ pieces.walkPath(self.matrix, x, y)
        pieces.walkPath(self.matrix, x, y+1) ]]
        self:resetActiveState()
        for i = 1, self.matrix.size[2] do
            print("TESTING", 1, i)
            pieces.walkPath(self.matrix, 1, i, 2)
        end
    end,

    playSound = function(self, soundID)
        local sound = self.skin.sounds[soundID]

        if sound:isPlaying() then
            sound:stop()
        end
        sound:play()
    end,

    opened = function(self, game, data)
        self.matrix = self.initMatrix(5, 10)
        self.matrix.topLeft = {math.floor((love.graphics.getWidth() - 5*self.visualSize[1])/2), math.floor((love.graphics.getHeight() - 10*self.visualSize[2])/2)}
        for i = 6, 10 do
            self.matrix.panels[i] = self:createRandomLine(2)
        end

        self.skin = skins[data.skin]
        self.skin:init(game, self)
        self.skin:initSounds()
        self.skin:playBGM()
        
        local pc = pieces.directlyConnectedPieces(self.matrix, 1, 1)
        print(rtprint(pc))
    end,

    keypressed = function(self, game, key)
        if key == 'up' then
            self:moveCursor(0, -1)
            self:playSound 'move'
            if love.keyboard.isDown('x') then
                self:doSwap()
            end
        elseif key == 'down' then
            self:moveCursor(0, 1)
            self:playSound 'move'
            if love.keyboard.isDown('x') then
                self:doSwap()
            end
        elseif key == 'left' then
            self:moveCursor(-1, 0)
            self:playSound 'move'
        elseif key == 'right' then
            self:moveCursor(1, 0)
            self:playSound 'move'
        elseif key == 'w' or key == 'x' then
            self:doSwap()
        elseif key == 'q' or key == 's' then
            table.remove(self.matrix.panels, 1)
            table.insert(self.matrix.panels, self:createRandomLine(love.math.random(2, 5)))
            self:playSound 'spawn'
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

        -- active panels
        --[[ for i = 1, self.matrix.size[2] do
            pieces.walkPath(self.matrix, 1, i, 2)
        end ]]
    end,

    draw = function(self, game)
        --local GAME_SCALE = ((love.graphics.getWidth() + love.graphics.getHeight())/2)/700

        self.visualSize = {40*GAME_SCALE, 30*GAME_SCALE}
        self.matrix.topLeft = {math.floor((love.graphics.getWidth() - 5*self.visualSize[1])/2), math.floor((love.graphics.getHeight() - 10*self.visualSize[2])/2)}

        self.skin:background(game, self)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(GAME_SCALE .. ' ' .. 40*GAME_SCALE .. ' ' .. 30*GAME_SCALE, 0, 0)

        -- panels

        --[[ print('--')
        rtprint(connected1)
        rtprint(connected2)
        print() ]]

        for y, line in ipairs(self.matrix.panels) do
            for x, panel in ipairs(self.matrix.panels[y]) do
                love.graphics.setLineWidth(1*GAME_SCALE)
                love.graphics.setColor(0, 0, 0, 0.5)
                love.graphics.rectangle('fill', (x - 1 + panel.visualOffsets[1])*self.visualSize[1] + self.matrix.topLeft[1], (y - 1 + panel.visualOffsets[2])*self.visualSize[2] + self.matrix.topLeft[2], self.visualSize[1], self.visualSize[2])
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle('line', (x - 1 + panel.visualOffsets[1])*self.visualSize[1] + self.matrix.topLeft[1], (y - 1 + panel.visualOffsets[2])*self.visualSize[2] + self.matrix.topLeft[2], self.visualSize[1], self.visualSize[2])

                if panel.piece > 0 then
                    love.graphics.setLineWidth(3*GAME_SCALE)
                    if panel.active then
                        love.graphics.setColor(unpack(self.colors.line))
                    else
                        love.graphics.setColor(unpack(self.colors.piece))
                    end
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
        love.graphics.setLineWidth(5*GAME_SCALE)
        love.graphics.rectangle('line', (self.cursor.visualPosition[1] - 1)*self.visualSize[1] + self.matrix.topLeft[1], (self.cursor.visualPosition[2] - 1)*self.visualSize[2] + self.matrix.topLeft[2], self.visualSize[1], 2*self.visualSize[2])
    end
}

return Game