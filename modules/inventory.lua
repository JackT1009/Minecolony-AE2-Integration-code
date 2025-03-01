-- modules/inventory.lua
local ItemDB = {}  -- THIS MUST BE FIRST LINE
ItemDB.__index = ItemDB  -- PROPER METATABLE SETUP
 
function ItemDB.new(bridge)
    local self = setmetatable({}, ItemDB)
    self.bridge = bridge
    self.items = {}
    self.cooldowns = {}
    return self  -- CRUCIAL RETURN STATEMENT
end
 
function ItemDB:track(item, amount, success)
    -- Your tracking logic here
end
 
function ItemDB:get_priority(item)
    -- Your priority logic here
    return 1  -- Temporary placeholder
end
 
return ItemDB  -- MUST RETURN MODULE AT END
