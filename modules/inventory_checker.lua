local InventoryChecker = {}
InventoryChecker.__index = InventoryChecker

function InventoryChecker.new(bridge)
    local self = setmetatable({}, InventoryChecker)
    self.bridge = bridge
    return self
end

function InventoryChecker:getItemStatus(item, amount)
    if not self.bridge then return "X", 0 end
    
    -- Get physical item count
    local total = 0
    local items = self.bridge.listItems(item) or {}
    for _, stack in pairs(items) do
        total = total + (stack.count or 0)
    end

    if total >= amount then
        return "/", total  -- Fully stocked
    else
        -- Check for crafting pattern
        local hasPattern = false
        local craftables = self.bridge.listCraftables() or {}
        for _, craftable in pairs(craftables) do
            if craftable.name == item then
                hasPattern = true
                break
            end
        end

        if hasPattern then
            return "M", total  -- Partial stock, pattern exists
        else
            return "P", total  -- Missing pattern
        end
    end
end

function InventoryChecker:getAllStatuses(requests)
    local statuses = {}
    for _, req in pairs(requests) do
        local status, available = self:getItemStatus(req.name, req.count)
        statuses[#statuses+1] = {
            name = req.name,
            needed = req.count,
            available = available,
            status = status
        }
    end
    return statuses
end

return InventoryChecker
