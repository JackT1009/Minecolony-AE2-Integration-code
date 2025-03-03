-- config.lua
return {
    REFRESH = 5,            -- Seconds between full refreshes
    DIRECTION = "up",       -- Warehouse side
    MAX_ROWS = 12,          -- Display capacity
    
    -- Precomputed CC color values
    COLORS = {
        stocked = 16384,    -- green
        craftable = 128,    -- yellow
        missing = 32768,    -- red
        header = 256        -- blue
    }
}
