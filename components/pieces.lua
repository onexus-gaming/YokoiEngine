local BOTTOM_LEFT = {-1, 1}
local TOP_LEFT = {-1, -1}
local BOTTOM_RIGHT = {1, 1}
local TOP_RIGHT = {1, -1}

local pieces = {
    -- x: 1 -> right
    -- y: 1 -> down
    -- / slash
    {BOTTOM_LEFT, TOP_RIGHT},
    -- \ backslash
    {TOP_LEFT, BOTTOM_RIGHT},
    -- ^ upwards chevron
    {BOTTOM_LEFT, BOTTOM_RIGHT},
    -- v downwards chevron
    {TOP_LEFT, TOP_RIGHT},
}

local connectionRules = {
    [BOTTOM_LEFT] = {{0, 1, TOP_LEFT}, {-1, 1, TOP_RIGHT}, {-1, 0, BOTTOM_RIGHT}},
    [TOP_LEFT] = {{0, -1, BOTTOM_LEFT}, {-1, -1, BOTTOM_RIGHT}, {-1, 0, TOP_RIGHT}},
    [BOTTOM_RIGHT] = {{0, 1, TOP_RIGHT}, {1, 1, TOP_LEFT}, {1, 0, BOTTOM_LEFT}},
    [TOP_RIGHT] = {{0, -1, BOTTOM_RIGHT}, {1, -1, BOTTOM_LEFT}, {1, 0, TOP_LEFT}},
}

--[[ local function concat(t1, t2)
    for i, v in ipairs(t2) do
        table.insert(t1, v)
    end
end ]]

local function directlyConnectedPieces(matrix, x, y)
    --print('dcp', matrix, x, y)
    local piece = pieces[matrix.panels[y][x].piece]

    if piece == nil then
        return {}
    end

    local connected = {{x, y}}

    for i, v in ipairs(piece) do
        --print('cnr', v[1], v[2])
        for j, w in ipairs(connectionRules[v]) do
            local nx = x + w[1]
            local ny = y + w[2]
            --print('check', nx, ny, w[3][1], w[3][2])
            --print(x, y, w[1], w[2], nx, ny)

            if (nx >= 1 and nx <= matrix.size[1]) and (ny >= 1 and ny <= matrix.size[2]) then
                local otherPiece = pieces[matrix.panels[ny][nx].piece]
                --print(otherPiece)

                if otherPiece ~= nil and contains(otherPiece, w[3]) then
                    table.insert(connected, {nx, ny})
                end
            end
        end
    end

    return connected
end

local function walkPath(matrix, x, y, excludes)
    --print(dump(excludes))
    --print('WALK', x, y)
    if not excludes then
        excludes = {[x]={[y]=true}}
    end

    local connected = directlyConnectedPieces(matrix, x, y)

    if x == 1 or x == matrix.size[1] or matrix.panels[y][x].active then
        if not matrix.panels[y][x].active then
            matrix.panels[y][x].active = true
            matrix.panels[y][x].activePiece = matrix.panels[y][x].piece
        end
        return matrix.panels[y][x].active
    else
        if not excludes[x] then
            excludes[x] = {}
        end
        excludes[x][y] = true

        for i, piece in ipairs(connected) do
            if not excludes or not excludes[piece[1]] or not excludes[piece[1]][piece[2]] then
                matrix.panels[y][x].active = walkPath(matrix, piece[1], piece[2], excludes)
            else
                matrix.panels[y][x].active = matrix.panels[piece[2]][piece[1]].active
            end
        end

        return false
    end
end

return {
    pieces = pieces,
    directlyConnectedPieces = directlyConnectedPieces,
    walkPath = walkPath,
}