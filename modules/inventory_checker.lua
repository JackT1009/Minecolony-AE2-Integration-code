local InventoryChecker = {}
InventoryChecker.__index = InventoryChecker

function InventoryChecker.new(bridge)
    local self = setmetatable({}, InventoryChecker)
    self.bridge = bridge
    return self
end

function InventoryChecker:getItemStatus(item, amount)
    if not self.bridge then return "X", 0 end
    
    -- Get ALL items and filter manually
    local total = 0
    local allItems = self.bridge.listItems() or {}
    
    for _, stack in pairs(allItems) do
        -- Exact name match (case-sensitive)
        if stack.name == item then
            total = total + (stack.count or 0)
        end
    end

    -- Debugging (remove after testing)
    print("Item:", item, "Total:", total, "Needed:", amount)

    if total >= amount then
        return "/", total
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
            return "M", total
        else
            return "P", total
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
