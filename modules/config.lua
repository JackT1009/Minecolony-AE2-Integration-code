return {
    REFRESH = 5,            -- Full refresh interval
    DIRECTION = "up",       -- Warehouse direction
    MAX_WIDTH = 30,         -- Max characters per line
    STATUS_COLORS = {
        stocked = colors.green,
        craftable = colors.yellow,
        missing = colors.red,
        header = colors.blue
    }
}
