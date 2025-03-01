local InventoryChecker = {}
InventoryChecker.__index = InventoryChecker

function InventoryChecker.new(bridge)
    local self = setmetatable({}, InventoryChecker)
    self.bridge = bridge
    return self
end

function InventoryChecker:getItemStatus(item, amount)
    if not self.bridge then return "X", 0 end
    
    -- Get available quantity from storage
    local total = 0
    local items = self.bridge.listItems(item) or {}
    for _, stack in pairs(items) do
        total = total + (stack.count or 0)
    end
    
    -- Status logic
    if total >= amount then
        return "/", total
    else
        -- Check if craftable via pattern
        local craftables = self.bridge.listCraftables() or {}
        for _, craftable in pairs(craftables) do
            if craftable.name == item then
                return "P", total
            end
        end
        return "X", total
    end
end

function InventoryChecker:getAllStatuses(requests)
    local statuses = {}
    for _, req in pairs(requests) do
        local status, available = self:getItemStatus(req.name, req.count)
        statuses[#statuses+1] = {
            name = req.name,
            available = available,  -- Now explicitly tracked
            needed = req.count,
            status = status
        }
    end
    return statuses
end

return InventoryChecker
