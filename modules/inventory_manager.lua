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
    -- ... rest of previous code ...
end

return InventoryManager
