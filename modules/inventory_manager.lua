local config = require("modules.config") or error("Missing config!")
assert(config.REFRESH, "REFRESH missing in config")

local InventoryManager = {
    last_update = 0,
    item_counts = {},
    craftable_items = {}
}

function InventoryManager.new(bridge)
    return setmetatable({bridge = bridge}, {__index = InventoryManager})
end

function InventoryManager:refresh()
    if os.time() - self.last_update >= config.REFRESH then
        -- Refresh item cache
        local items = self.bridge.listItems() or {}
        self.item_counts = {}
        for _, stack in pairs(items) do
            self.item_counts[stack.name] = (self.item_counts[stack.name] or 0) + stack.count
        end
        
        -- Refresh craftables cache
        local craftables = self.bridge.listCraftableItems() or {}
        self.craftable_items = {}
        for _, craft in pairs(craftables) do
            self.craftable_items[craft.name] = true
        end
        
        self.last_update = os.time()
    end
end

function InventoryManager:get_status(item_name, needed)
    local available = self.item_counts[item_name] or 0
    local craftable = self.craftable_items[item_name] or false

    return {
        name = item_name:gsub("^.+:", ""),
        available = available,
        needed = needed,
        status = available >= needed and "stocked" or craftable and "craftable" or "missing"
    }
end

return InventoryManager
