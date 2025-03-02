local Exporter = {}

function Exporter.new(bridge, direction)
    local self = {
        bridge = bridge,
        direction = direction,
        debug = {}
    }
    return setmetatable(self, {__index = Exporter}) -- Fix: Removed extra parenthesis
end

function Exporter:_log(message)
    table.insert(self.debug, message)
end

function Exporter:pushToWarehouse(itemName, amount)
    if not self.bridge or not self.direction then return 0 end
    
    local filter = {
        name = itemName,
        count = amount
    }
    
    local success, exported = pcall(function()
        return self.bridge.exportItem(filter, self.direction)
    end)
    
    if success then
        self:_log(("Exported %dx %s"):format(exported, itemName))
        return exported
    else
        self:_log(("Export failed: %s"):format(tostring(exported)))
        return 0
    end
end

return Exporter
