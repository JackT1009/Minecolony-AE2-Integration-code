local Colony = {}

function Colony.getRequests()
    local integrator = peripheral.find("colonyIntegrator")
    if not integrator then return {} end
    
    local requests = {}
    for _, req in pairs(integrator.getRequests() or {}) do
        if req.items and req.items[1] then
            requests[#requests+1] = {
                name = req.items[1].name,
                count = req.count
            }
        end
    end
    return requests
end

return Colony
