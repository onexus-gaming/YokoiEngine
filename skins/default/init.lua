local function val(t)
    return (math.sin(t) + 1) / 2
end

local Skin = {
    BGM = love.audio.newSource('skins/default/shinin.ogg', 'stream'),

    init = function(self, game, scene)
        self.BGM:setLooping(true)
        --[[ scene.colors.piece  = {0, 1, 0, 1}
        scene.colors.line   = {1, 1, 0, 1}
        scene.colors.cursor = {1, 0, 1, 1} ]]
        scene.colors.piece   = {1, 0.5, 0, 1}
        scene.colors.line    = {0, 0.5, 1, 1}
        scene.colors.cursor  = {1, 0, 1, 1}
    end,

    background = function(self, game, scene)
        local t = love.timer.getTime()/4
        --love.graphics.clear(val(t)/2, val(t+1)/2, val(t+2)/2)
        love.graphics.clear(0, 0.25+val(t)/4, 1)
    end,

    playBGM = function(self, game)
        self.BGM:play()
    end,

    updateBGM = function(self, game)
        -- possible updates go here
    end,

    stopBGM = function(self, game)
        self.BGM:stop()
    end,
}

print(Skin.BGM)

return Skin