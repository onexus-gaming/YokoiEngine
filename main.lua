SOUNDS = {
    'move',
    'dashUp',
    'dashDown',
    'dashLeft',
    'dashRight',

    'swap0',
    'swap1',
    'swap2',

    'line0',
    'line1',
    'line2',

    'clearLow',
    'clearMid',
    'clearHigh',
    'clearVeryHigh',

    'spawn',
    'danger0',
    'danger1',
}

novum = require 'novum'

novum.title = "Yokoi Engine"

function deepCopy(t)
    local nt = {}

    for k, v in pairs(t) do
        if type(v) == 'table' then
            nt[k] = deepCopy(v)
        else
            nt[k] = v
        end
    end

    return nt
end

function contains(t, val)
    for i, v in ipairs(t) do
        if v == val then return true end
    end
    return false
end

function find(t, val)
    for i, v in ipairs(t) do
        if v == val then return i end
    end
    return nil
end

function isBlockInSet(t, x, y)
    for i, v in ipairs(t) do
        if v[1] == x and v[2] == y then
            return true
        end
    end
    return false
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

GAME_SCALE = ((love.graphics.getWidth() + love.graphics.getHeight())/2)/700

novum:discoverAllScenes()
novum:hookCallback('draw', function(game)
    GAME_SCALE = ((love.graphics.getWidth() + love.graphics.getHeight())/2)/700
end)

skins = {}

-- load all skins
function loadSkins()
    local files = love.filesystem.getDirectoryItems('skins')

    for i, v in ipairs(files) do
        local info = love.filesystem.getInfo('skins/' .. v, 'directory')

        if info then
            skins[v] = require('skins.' .. v)
            skins[v].initSounds = function(self)
                self.sounds = {}
                for j, w in ipairs(SOUNDS) do
                    self.sounds[w] = love.audio.newSource('skins/' .. v .. '/sounds/' .. w .. '.ogg', 'static')
                end
            end
            skins[v].stopSounds = function(self)
                for k, v in pairs(self.sounds) do
                    v:stop()
                end
            end
            skins[v].clearSounds = function(self)
                for k, v in pairs(self.sounds) do
                    self.sounds[k] = nil
                end
            end
        end
    end
end
loadSkins()

novum:switchSceneInstant('game', {
    skin = 'default',
})