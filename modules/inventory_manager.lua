local config = require("modules.config")

local InventoryManager = {
    cache = {items = {}, craftables = {}, time = 0}
}

function InventoryManager.new(bridge)
    return setmetatable({bridge = bridge}, {__index = InventoryManager})
end

function InventoryManager:get_items()
    if os.time() - self.cache.time > config.CACHE_TIME then
        self.cache.items = self.bridge.listItems() or {}
        self.cache.craftables = self.bridge.listCraftableItems() or {}
        self.cache.time = os.time()
    end
    return self.cache.items, self.cache.craftables
end

function InventoryManager:get_status(item_name, needed)
    local items, craftables = self:get_items()
    local available = 0
    
    -- Count available items
    for _, stack in pairs(items) do
        if stack.name == item_name then
            available = available + stack.count
            if available >= needed then break end
        end
    end

    -- Check craftability
    local craftable = false
    for _, c in pairs(craftables) do
        if c.name == item_name then
            craftable = true
            break
        end
    end

    return {
        name = item_name:gsub("^.+:", ""),  -- Strip mod prefix
        needed = needed,
        available = math.min(available, needed),
        craftable = craftable,
        status = available >= needed and "/" or craftable and "M" or "P"
    }
end

return InventoryManager
