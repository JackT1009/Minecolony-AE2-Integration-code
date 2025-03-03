local config = require("modules.config")

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
        -- AE2-specific inventory listing
        self.item_counts = {}
        local items = self.bridge.listItems() or {}
        for _, stack in pairs(items) do
            self.item_counts[stack.fingerprint] = stack.amount
        end
        
        -- AE2 craftable detection
        self.craftable_items = {}
        local craftables = self.bridge.listCraftables() or {}
        for _, craft in pairs(craftables) do
            self.craftable_items[craft.fingerprint] = true
        end
        
        self.last_update = os.time()
    end
end

function InventoryManager:get_status(item_name, needed)
    local available = self.item_counts[item_name] or 0
    local craftable = self.craftable_items[item_name] or false

    return {
        name = item_name:gsub("^ae2:", ""):gsub("_", " "):gsub("(%l)(%w*)", function(a,b) return a:upper()..b end),
        available = available,
        needed = needed,
        status = available >= needed and "stocked" or craftable and "craftable" or "missing"
    }
end

return InventoryManager
