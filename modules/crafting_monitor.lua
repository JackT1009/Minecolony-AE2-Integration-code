-- modules/crafting_monitor.lua
local CraftMonitor = {} -- THIS LINE MUST BE FIRST
CraftMonitor.__index = CraftMonitor -- PROPER METATABLE SETUP
 
function CraftMonitor.new(bridge, chat)
    local self = setmetatable({}, CraftMonitor)
    self.bridge = bridge
    self.chat = chat
    self.patterns = {}
    self.config = settings.load("config.cfg") or {
        export_direction = "down",
        alert_player = "@YourUsername"
    }
    return self -- RETURN THE INSTANCE
end
 
function CraftMonitor:rescanPatterns()
    self.patterns = {}
    local items = self.bridge.listItems() or {}
    for _, item in pairs(items) do
        if item and item.isCraftable then
            self.patterns[item.name] = true
        end
    end
end
 
function CraftMonitor:processItem(item, amount)
    -- Rest of your processItem logic
    -- ...
end
 
return CraftMonitor
