-- Initialize peripherals
local colony = require("modules/colony")
local display = require("modules/display")

-- Main loop
while true do
    local requests = colony.getRequests()
    display.showRequests(requests)
    sleep(5)
end
