local display = {}
local mon = peripheral.find("monitor") or term.current()

function display.showRequests(requests)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.write("Colony Requests:")
    
    if #requests == 0 then
        mon.setCursorPos(1,3)
        mon.write("No current requests")
        return
    end
    
    for i, req in ipairs(requests) do
        mon.setCursorPos(1, i+2)
        mon.write(string.format("%-20s x%d", 
            req.name:gsub("minecraft:", ""),
            req.count
        ))
    end
end

return display
