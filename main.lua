novum = require "novum"

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

novum:discoverAllScenes()

novum:switchSceneInstant 'test'