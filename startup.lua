-- startup.lua
local config = settings.load("config.cfg") or {
    debug_mode = true,
    export_direction = "down",
    alert_player = "@YourUsername"
}
 
local col = peripheral.find("colonyIntegrator")
local bridge = peripheral.find("meBridge")
local chat = peripheral.find("chatBox")
local mon = peripheral.find("monitor") or peripheral.wrap("right")
 
-- Load modules
local ItemDB = require("modules.inventory")
local CraftMonitor = require("modules.crafting_monitor")
local Predictor = require("modules.prediction")
 
local itemDB = ItemDB.new(bridge)
local craftMon = CraftMonitor.new(bridge, chat)
local predictor = Predictor.new()
 
-- UI Settings
local scrollPos = 0
local maxLines = 10
local transfers = {}
local statusSymbols = {
    ["missing_pattern"] = "X", ["crafting"] = "!", ["sent"] = "√",
    ["unavailable"] = "?", ["error"] = "E"
}
 
function displayUI(requests)
    if not mon then return end
    local width, height = mon.getSize()
    mon.clear()
    mon.setBackgroundColor(colors.black)
 
    -- Header with cooldowns
    mon.setCursorPos(1, 1)
    mon.setTextColor(colors.blue)
    mon.write(("Colony Manager %s"):format(os.date("%H:%M")))
 
    -- Cooldown display (right-aligned)
    mon.setCursorPos(width - 15, 1)
    mon.write("Cooldowns: ")
    local cooldownCount = 0
    for item,_ in pairs(itemDB.cooldowns) do
        mon.write(item:sub(1,5).." ")
        cooldownCount = cooldownCount + 1
        if cooldownCount >= 2 then break end -- Limit to 2 items
    end
 
    -- Requests list
    local line = 2
    for i = 1, math.min(#requests, maxLines) do
        local req = requests[i + scrollPos]
        if req and req.item then
            -- Clean item name
            local cleanName = req.item:gsub("minecraft:", "")
                :gsub("_", " ")
                :sub(1, 15)
 
            -- Get status and priority
            local status = craftMon:processItem(req.item, req.amount)
            local priority = itemDB:get_priority(req.item)
 
            -- Set color based on status
            local color = colors.white
            if status == "sent" then color = colors.green
            elseif status == "error" then color = colors.red
            elseif status == "crafting" then color = colors.yellow end
 
            -- Display line
            mon.setCursorPos(1, line)
            mon.setTextColor(color)
            mon.write(string.format("[P%02d] %-15s %s", 
                priority, 
                cleanName, 
                statusSymbols[status] or "?"
            ))
            line = line + 1
        end
    end
end
 
while true do
    local requests = col.getRequests() or {}
    local processed = {}
 
    -- Process requests with error handling
    for _, req in pairs(requests) do
        if req.items and req.items[1] and req.items[1].name then
            local item = req.items[1].name
            local amount = req.count or 0
 
            -- Update tracking systems
            local success, err = pcall(function()
                itemDB:track(item, amount)
                predictor:update(item, amount)
            end)
 
            if success then
                table.insert(processed, {
                    item = item,
                    amount = amount
                })
            else
                chat.sendMessageToPlayer("Tracking error: "..tostring(err), config.alert_player)
            end
        end
    end
 
    -- Update display
    displayUI(processed)
    sleep(5) -- Longer sleep to prevent refresh spam
end
 
-- Diagnostic command
function debugTest(item, amount)
    craftMon:processItem(item, amount)
    chat.sendMessageToPlayer("Test completed for "..item, config.alert_player)
end
