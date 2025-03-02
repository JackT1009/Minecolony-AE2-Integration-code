local config = require("modules.config")

local InventoryManager = {
    cache = {items = {}, craftables = {}, tick = 0}
}

function InventoryManager.new(bridge)
    return setmetatable({bridge = bridge}, {__index = InventoryManager})
end

function InventoryManager:refresh_data()
    local current_tick = os.time() * 20  -- Convert to ticks
    if current_tick - self.cache.tick > config.CACHE_TICKS then
        self.cache.items = self.bridge.listItems() or {}
        self.cache.craftables = self.bridge.listCraftableItems() or {}
        self.cache.tick = current_tick
    end
end

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
        name = item_name:gsub("^.+:", ""),  -- Clean name
        needed = needed,
        available = available,
        status = available >= needed and "/" or craftable and "M" or "P"
    }
end

return InventoryManager
