
-- Updater.lua (Place this in root directory)
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

-- Files now in repo root (no ColonyBrain folder on GitHub)
local files = {
    "startup.lua",
    "modules/colony.lua",
    "modules/display.lua",
    "Updater.lua"
}

local function downloadFile(path)
    local url = "https://raw.githubusercontent.com/"..
        GITHUB_USER.."/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/"..path
    
    for i = 1, MAX_RETRIES do
        local response = http.get(url)
        if response then
            -- Install to ColonyBrain folder locally
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
fs.delete("ColonyBrain") -- Clean existing install
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
