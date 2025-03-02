local bridge = peripheral.find("meBridge")
local monitor = peripheral.find("monitor") or peripheral.wrap("top")

-- Load modules
local Colony = require("modules/colony")
local InventoryChecker = require("modules/inventory_checker")
local Display = require("modules/display")
local Exporter = require("modules/exporter")

-- Configuration
local WAREHOUSE_DIRECTION = "up"
local REFRESH_INTERVAL = 10  -- Seconds
local exporter = Exporter.new(bridge, WAREHOUSE_DIRECTION)

Display.initialize(monitor)
local checker = InventoryChecker.new(bridge)

-- Performance optimizations
local lastCraftCheck = {}
local lastExportCheck = {}

-- Main loop
while true do
    local timerStart = os.time()
    local debugInfo = {}
    
    -- Phase 1: Get requests
    local requests = Colony.getRequests()
    
    -- Phase 2: Get statuses (cached for 2 cycles)
    local statuses = checker:getAllStatuses(requests)
    
    -- Phase 3: Crafting (optimized)
    for _, item in ipairs(statuses) do
        if item.status == "M" and not lastCraftCheck[item.name] then
            local amountToCraft = item.needed - item.available
            local success, err = pcall(bridge.craftItem, {
                name = item.name,
                count = amountToCraft
            })
            if success then
                table.insert(debugInfo, "Crafting "..amountToCraft.."x "..item.name)
                lastCraftCheck[item.name] = true  -- Throttle checks
            else
                table.insert(debugInfo, "Craft error: "..tostring(err))
            end
        end
    end
    
    -- Phase 4: Exporting (batched)
    local exportList = {}
    for _, item in ipairs(statuses) do
        if item.status == "/" and not lastExportCheck[item.name] then
            table.insert(exportList, item)
            lastExportCheck[item.name] = true
        end
    end
    
    for _, item in ipairs(exportList) do
        local exported = exporter:pushToWarehouse(item.name, item.needed)
        if exported > 0 then
            item.sent = true
            table.insert(debugInfo, "Sent "..exported.."x "..item.name)
        end
    end
    
    -- Phase 5: Calculate time
    local elapsed = os.time() - timerStart
    local timeLeft = math.max(REFRESH_INTERVAL - elapsed, 1)  -- Minimum 1s
    
    -- Phase 6: Update display
    Display.show(statuses, debugInfo, timeLeft)
    
    -- Reset craft/export checks every few cycles
    if os.time() % 30 == 0 then  -- Reset every 30 seconds
        lastCraftCheck = {}
        lastExportCheck = {}
    end
    
    sleep(timeLeft)
end
