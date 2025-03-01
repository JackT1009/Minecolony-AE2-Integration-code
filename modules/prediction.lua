-- Paste into modules/prediction.lua
local Predictor = {}
Predictor.__index = Predictor
 
function Predictor.new()
    return setmetatable({history={}}, Predictor)
end
 
function Predictor:update(item, amount)
    self.history[item] = self.history[item] or {}
    table.insert(self.history[item], {
        time = os.time(),
        amount = amount
    })
end
 
return Predictor
