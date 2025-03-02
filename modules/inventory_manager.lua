local config = require("modules.config")

local InventoryManager = {
    cache = {items = {}, craftables = {}, time = 0}
}

function InventoryManager.new(bridge)
    return setmetatable({bridge = bridge}, {__index = InventoryManager})
end

-- Batch get all items/craftables with caching
function InventoryManager:refresh_data()
    if os.time() - self.cache.time > config.CACHE_TIME then
        self.cache.items = self.bridge.listItems() or {}
        self.cache.craftables = self.bridge.listCraftableItems() or {}
        self.cache.time = os.time()
    end
end

-- Fast status check using cached data
function InventoryManager:get_status(item_name, needed)
    self:refresh_data()
    
    local available = 0
    for _, stack in pairs(self.cache.items) do
        if stack.name == item_name then
            available = available + (stack.count or 0)
            if available >= needed then break end
        end
    end

    local craftable = false
    for _, c in pairs(self.cache.craftables) do
        if c.name == item_name then craftable = true break end
    end

    return {
        name = item_name:gsub("^.+:", ""),  -- Strip mod prefix
        needed = needed,
        available = math.min(available, needed),
        status = available >= needed and "/" or craftable and "M" or "P"
    }
end

return InventoryManager
