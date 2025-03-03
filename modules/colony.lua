-- colony.lua
local Colony = {
    integrator = nil
}

function Colony.initialize(integrator)
    Colony.integrator = integrator
end

function Colony.getRequests()
    if not Colony.integrator then return {} end
    
    local requests = {}
    for _, req in pairs(Colony.integrator.getRequests() or {}) do
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
