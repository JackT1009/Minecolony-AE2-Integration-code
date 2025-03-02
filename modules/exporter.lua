local Exporter = {}

function Exporter.new(bridge, direction)
    local self = {
        bridge = bridge,
        direction = direction,  -- Now "up"
        debug = {}
    }
    return setmetatable(self, {__index = Exporter})
end

-- ... (rest of exporter.lua remains unchanged) ...
