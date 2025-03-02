local InventoryChecker = {}
InventoryChecker.__index = InventoryChecker

function InventoryChecker.new(bridge)
    local self = setmetatable({}, InventoryChecker)
    self.bridge = bridge
    self.debugLog = {}
    return self
end

function InventoryChecker:logDebug(message)
    table.insert(self.debugLog, message)
end

function InventoryChecker:getItemStatus(item, amount)
    self.debugLog = {}
    if not self.bridge then return "X", 0 end
    
    self:logDebug("Checking: "..item)
    
    -- Physical item count
    local total = 0
    local allItems = self.bridge.listItems() or {}
    for _, stack in pairs(allItems) do
        if stack.name == item then
            local count = tonumber(stack.count) or 0
            total = total + count
            self:logDebug("- Found: "..count.."x "..stack.name)
        end
    end
    
    self:logDebug("Total: "..total.." / Needed: "..amount)
    
    -- Pattern check (CRITICAL FIX HERE)
    local hasPattern = false
    local craftables = self.bridge.listCraftables() or {}  -- Corrected method name
    for _, craftable in pairs(craftables) do
        if craftable.name == item then
            hasPattern = true
            break
        end
    end

    if total >= amount then
        return "/", total
    elseif hasPattern then
        return "M", total
    else
        return "P", total
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

function InventoryChecker:getDebugLog()
    return self.debugLog
end

return InventoryChecker
