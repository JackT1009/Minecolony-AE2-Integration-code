local Colony = {}

function Colony.getRequests()
    local integrator = peripheral.find("colonyIntegrator")
    if not integrator then return {} end
    
    local requests = {}
    for _, req in pairs(integrator.getRequests() or {}) do
        if req.items and req.items[1] then
            local rawName = req.items[1].name
            -- Keep mod prefix but remove metadata
            local cleanName = rawName:lower():match("^([^:]+:[^:]+)") or rawName
            table.insert(requests, {
                name = cleanName,  -- e.g. "thermal:tin_ingot"
                count = req.count
            })
        end
    end
    return requests
end

return Colony
