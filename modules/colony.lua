local Colony = {}

function Colony.getRequests()
    local integrator = peripheral.find("colonyIntegrator")
    if not integrator then return {} end
    
    local requests = {}
    for _, req in pairs(integrator.getRequests() or {}) do
        if req.items and req.items[1] then
            local rawName = req.items[1].name
            local cleanName = rawName:lower():gsub(":.*", "")  -- Remove metadata
            table.insert(requests, {
                name = cleanName,
                count = req.count
            })
        end
    end
    return requests
end

return Colony
