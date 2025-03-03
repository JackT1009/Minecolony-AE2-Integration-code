local config = require("modules.config")

local InventoryManager = {
    last_update = 0,
    cached_items = {},
    cached_craftables = {}
}

function InventoryManager.new(bridge)
    return setmetatable({bridge = bridge}, {__index = InventoryManager})
end

function InventoryManager:refresh_cache()
    if os.time() - self.last_update >= config.REFRESH_INTERVAL then
        self.cached_items = self.bridge.listItems() or {}
        self.cached_craftables = self.bridge.listCraftableItems() or {}
        self.last_update = os.time()
    end
end

function InventoryManager:get_status(item_name, needed)
    self:refresh_cache()
    
    local available = 0
    for _, stack in pairs(self.cached_items) do
        if stack.name == item_name then
            available = available + (stack.count or 0)
        end
    end

    local craftable = false
    for _, craft in pairs(self.cached_craftables) do
        if craft.name == item_name then craftable = true break end
    end

    return {
        name = item_name:gsub("^.+:", ""),
        available = available,
        needed = needed,
        status = available >= needed and "stocked" or craftable and "craftable" or "missing"
    }
end

return InventoryManager
