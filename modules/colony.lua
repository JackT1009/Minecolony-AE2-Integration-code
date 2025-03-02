local Colony = {}
Colony.__index = Colony

function Colony.getRequests()
    local integrator = peripheral.find("colonyIntegrator")
    if not integrator then return {} end
    
    local rawRequests = integrator.getRequests() or {}
    local processed = {}
    
    for _, req in pairs(rawRequests) do
        if req.items and req.items[1] then
            -- Clean item names
            local rawName = req.items[1].name
            local cleanName = string.lower(string.match(rawName, "([^:]+:[^:]+)"))
            
            table.insert(processed, {
                name = cleanName,
                count = req.count
            })
        end
    end
    
    return processed
end

return Colony
