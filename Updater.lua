-- Updater.lua
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

local files = {
    "startup.lua",
    "modules/colony.lua",
    "modules/display.lua",
    "modules/inventory_checker.lua",
    "modules/exporter.lua",  -- New exporter module
    "Updater.lua"
}

local function downloadFile(path)
    local url = "https://raw.githubusercontent.com/"..
        GITHUB_USER.."/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/"..path
    
    for i = 1, MAX_RETRIES do
        local response = http.get(url)
        if response then
            local localPath = "ColonyBrain/"..path
            local dir = string.match(localPath, "(.+)/[^/]+$") or ""
            if not fs.exists(dir) then fs.makeDir(dir) end
            
            local file = fs.open(localPath, "w")
            file.write(response.readAll())
            file.close()
            return true
        end
        sleep(2)
    end
    return false
end

print("=== ColonyBrain Installer ===")
fs.delete("ColonyBrain")
fs.makeDir("ColonyBrain/modules")

local success = true
for _, path in ipairs(files) do
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X Verify file exists:")
        print("https://raw.githubusercontent.com/"..
            GITHUB_USER.."/"..GITHUB_REPO.."/"..
            GITHUB_BRANCH.."/"..path)
        success = false
    end
end

if success then
    print("/ Success! Run:")
    print("cd ColonyBrain")
    print("startup")
else
    print("X Fix repo structure then retry")
end
