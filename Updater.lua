-- ColonyBrain/Updater.lua (Must use .lua extension)
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

-- Exact file paths (case-sensitive)
local files = {
    "ColonyBrain/startup.lua",           -- .lua not ,lua
    "ColonyBrain/modules/colony.lua",    -- colony not colonj
    "ColonyBrain/modules/display.lua",   -- .lua extension
    "ColonyBrain/Updater.lua"            -- .lua extension
}

local function downloadFile(path)
    local url = "https://raw.githubusercontent.com/"..
        GITHUB_USER.."/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/"..path
    
    for i = 1, MAX_RETRIES do
        local response = http.get(url)
        if response then
            local dir = string.match(path, "(.+)/[^/]+$") or ""
            if not fs.exists(dir) then fs.makeDir(dir) end
            
            local file = fs.open(path, "w")
            file.write(response.readAll())
            file.close()
            return true
        end
        sleep(2)
    end
    return false
end

-- Main execution
print("=== ColonyBrain Updater ===")
fs.delete("ColonyBrain")  -- Full cleanup
fs.makeDir("ColonyBrain/modules")

local success = true
for _, path in ipairs(files) do
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X Verify file exists:")
        print(url)
        success = false
    end
end

if success then
    print("/ Success! Run:")
    print("cd ColonyBrain")
    print("startup")
else
    print("X Manual fix required")
end
