local InventoryChecker = {}

function InventoryChecker.new(bridge)
    local self = {
        bridge = bridge,
        debug = {}
    }
    return setmetatable(self, {__index = InventoryChecker})
end

function InventoryChecker:_log(message)
    table.insert(self.debug, message)
end

function InventoryChecker:_safeCall(fnName, ...)
    if not self.bridge or not self.bridge[fnName] then
        self:_log("Missing bridge or method: "..(fnName or "nil"))
        return nil, "API error"
    end
    return pcall(self.bridge[fnName], self.bridge, ...)
end

function InventoryChecker:getStock(itemFilter)
    local success, items = self:_safeCall("listItems")
    if not success then return 0 end
    
    local total = 0
    for _, stack in pairs(items) do
        if stack.name and stack.name:lower() == itemFilter.name:lower() then
            total = total + (stack.count or 0)
        end
    end
    return total
end

function InventoryChecker:hasCraftingPattern(itemFilter)
    local success, craftables = self:_safeCall("listCraftableItems")
    if not success then return false end
    
    for _, craftable in pairs(craftables) do
        if craftable.name and craftable.name:lower() == itemFilter.name:lower() then
            return true
        end
    end
    return false
end

function InventoryChecker:getAllStatuses(requests)
    self.debug = {}
    local statuses = {}
    
    for _, req in pairs(requests) do
        local itemFilter = {name = req.name}
        local available = self:getStock(itemFilter)
        local canCraft = self:hasCraftingPattern(itemFilter)
        local status = "X"
        
        if available >= req.count then
            status = "/"
        elseif canCraft then
            status = "M"
        else
            status = "P"
        end
        
        table.insert(statuses, {
            name = req.name,
            needed = req.count,
            available = available,
            status = status
        })
    end
    return statuses, self.debug
end

return InventoryChecker
