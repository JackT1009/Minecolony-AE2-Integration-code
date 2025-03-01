local InventoryChecker = {}
InventoryChecker.__index = InventoryChecker

function InventoryChecker.new(bridge)
    local self = setmetatable({}, InventoryChecker)
    self.bridge = bridge
    return self
end

function InventoryChecker:getItemStatus(item, amount)
    if not self.bridge then return "X" end
    
    -- Check available stock
    local total = 0
    local items = self.bridge.listItems(item) or {}
    for _, stack in pairs(items) do
        total = total + (stack.count or 0)
        if total >= amount then return "/" end
    end
    
    -- Check crafting capability
    local craftables = self.bridge.listCraftables() or {}
    for _, craftable in pairs(craftables) do
        if craftable.name == item then return "P" end
    end
    
    return "X"
end

function InventoryChecker:getAllStatuses(requests)
    local statuses = {}
    for _, req in pairs(requests) do
        statuses[#statuses+1] = {
            name = req.name,
            count = req.count,
            status = self:getItemStatus(req.name, req.count)
        }
    end
    return statuses
end

return InventoryChecker
