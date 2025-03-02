local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

-- Load modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")
local Exporter = require("modules/exporter")

-- Configure
local WAREHOUSE_DIRECTION = "up"
local REFRESH_INTERVAL = 10  -- Seconds
local exporter = Exporter.new(bridge, WAREHOUSE_DIRECTION)

Display.initialize(monitor)
local checker = InventoryChecker.new(bridge)

-- Main loop
while true do
    local startTime = os.epoch("utc")
    local requests = Colony.getRequests()
    local statuses, debugInfo = checker:getAllStatuses(requests)
    
    -- Auto-craft logic
    for _, item in ipairs(statuses) do
        if item.status == "M" then
            local amountToCraft = item.needed - item.available
            local isCrafting = bridge.isItemCrafting({name = item.name})
            
            if not isCrafting then
                local success, err = pcall(bridge.craftItem, {
                    name = item.name,
                    count = amountToCraft
                })
                table.insert(debugInfo, success and 
                    "Crafting "..amountToCraft.."x "..item.name or 
                    "Craft error: "..tostring(err))
            end
        end
    end
    
    -- Export logic + track sent items
    for _, item in ipairs(statuses) do
        if item.status == "/" then
            local exported = exporter:pushToWarehouse(item.name, item.needed)
            if exported > 0 then
                item.sent = true  -- Mark as sent
                table.insert(debugInfo, "Sent "..exported.."x "..item.name)
            end
        end
    end
    
    -- Calculate time left
    local elapsed = (os.epoch("utc") - startTime) / 1000
    local timeLeft = math.max(REFRESH_INTERVAL - math.floor(elapsed), 0)
    
    -- Update display
    Display.show(statuses, debugInfo, timeLeft)
    
    -- Wait remaining time
    sleep(REFRESH_INTERVAL - elapsed)
end
