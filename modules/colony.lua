local colony = {}
local integrator = peripheral.find("colonyIntegrator")

function colony.getRequests()
    if not integrator then
        error("Colony Integrator not found!")
    end
    
    local rawRequests = integrator.getRequests() or {}
    local processed = {}
    
    for _, req in pairs(rawRequests) do
        if req.items and req.items[1] then
            table.insert(processed, {
                name = req.items[1].name,
                count = req.count
            })
        end
    end
    
    return processed
end

return colony
