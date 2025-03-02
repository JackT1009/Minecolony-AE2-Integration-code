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
    
    -- Verify bridge capabilities
    if not self.bridge.listItems or not self.bridge.listCraftables then
        self:logDebug("ERR: Bridge missing methods")
        return "X", 0
    end

    -- Physical items
    local total = 0
    local allItems = self.bridge.listItems() or {}
    for _, stack in pairs(allItems) do
        if stack.name == item then
            total = total + (tonumber(stack.count) or 0
        end
    end

    -- Craftables (METHOD NAME FIXED)
    local hasPattern = false
    local success, craftables = pcall(function()
        return self.bridge.listCraftables()  -- OR TRY self.bridge.getCraftables()
    end)
    
    if success then
        for _, craftable in pairs(craftables) do
            if craftable.name == item then
                hasPattern = true
                break
            end
        end
    else
        self:logDebug("Bridge error: "..craftables)
    end

    -- Status logic
    if total >= amount then
        return "/", total
    elseif hasPattern then
        return "M", total
    else
        return "P", total
    end
end

-- Rest of file remains unchanged from previous versions
