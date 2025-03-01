
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

local files = {
    "ColonyBrain/startup.lua",
    "ColonyBrain/modules/colony.lua",
    "ColonyBrain/modules/display.lua",
    "ColonyBrain/Updater.lua"  -- Self-update
}

local function downloadFile(path)
    local url = "https://raw.githubusercontent.com/"..
        GITHUB_USER.."/"..GITHUB_REPO.."/"..GITHUB_BRANCH.."/"..path
    
    for i = 1, MAX_RETRIES do
        local response = http.get(url)
        if response then
            local file = fs.open(path, "w")
            file.write(response.readAll())
            file.close()
            return true
        end
        sleep(2)
    end
    return false
end

local function updateSelf()
    print("Updating updater...")
    if downloadFile("ColonyBrain/Updater.lua.new") then
        local bat = fs.open("ColonyBrain/update.bat", "w")
        bat.write([[
            cd ColonyBrain
            cp Updater.lua.new Updater.lua
            rm Updater.lua.new
            rm update.bat
            Updater
        ]])
        bat.close()
        return true
    end
    return false
end

-- Main
print("=== ColonyBrain System Updater ===")
local needsReboot = updateSelf()

-- Clean install
if fs.exists("ColonyBrain") then
    fs.delete("ColonyBrain")
end
fs.makeDir("ColonyBrain")
fs.makeDir("ColonyBrain/modules")

local success = true
for _, path in ipairs(files) do
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X Failed: "..path)
        success = false
    end
end

if success then
    print("/ Update complete! Run:")
    print("cd ColonyBrain")
    print("startup")
    if needsReboot then
        print("Restarting...")
        sleep(3)
        shell.run("ColonyBrain/update.bat")
    end
else
    print("X Critical errors - manual fix needed")
end
