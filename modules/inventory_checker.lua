local InventoryChecker = {
    SAFE_METHODS = {"listItems", "listCraftables", "getCraftables"}
}

function InventoryChecker.new(bridge)
    local self = {
        bridge = bridge,
        debug = {}
    }
    return setmetatable(self, {__index = InventoryChecker})
end

function InventoryChecker:safeCall(method, ...)
    if not self.bridge[method] then return nil, "No "..method.." method" end
    return pcall(function() return self.bridge[method](self.bridge, ...) end)
end

function InventoryChecker:getStock(itemName)
    local total = 0
    local items, err = self:safeCall("listItems")
    if not items then
        table.insert(self.debug, "listItems error: "..err)
        return 0
    end
    
    for _, stack in pairs(items) do
        if stack.name:lower():gsub(":[^:]+$", "") == itemName then
            total = total + (tonumber(stack.count) or 0)
        end
    end
    return total
end

function InventoryChecker:hasPattern(itemName)
    local craftables, err
    craftables, err = self:safeCall("listCraftables") or self:safeCall("getCraftables")
    
    if not craftables then
        table.insert(self.debug, "craftables error: "..err)
        return false
    end
    
    for _, craftable in pairs(craftables) do
        if craftable.name:lower():gsub(":[^:]+$", "") == itemName then
            return true
        end
    end
    return false
end

function InventoryChecker:getAllStatuses(requests)
    local statuses = {}
    self.debug = {}
    
    for _, req in pairs(requests) do
        local available = self:getStock(req.name)
        local hasPattern = self:hasPattern(req.name)
        local status = "X"
        
        if available >= req.count then
            status = "/"
        elseif hasPattern then
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
