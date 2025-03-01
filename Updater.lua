
-- Updater.lua
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

-- STRICT FILENAME VALIDATION
local files = {
    "startup.lua",          -- .lua NOT ,lua
    "modules/colony.lua",   -- .lua extension
    "modules/display.lua",  -- .lua extension
    "Updater.lua"           -- .lua extension
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

-- SELF-UPDATE WITH VALIDATION
local function updateSelf()
    print("Checking for updater updates...")
    if downloadFile("Updater.lua.new") then  -- .lua.new
        local bat = fs.open("update.bat", "w")
        bat.write([[
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

-- MAIN EXECUTION
print("=== Minecolony Updater ===")
local needsReboot = updateSelf()

fs.delete("startup.lua")
if fs.exists("modules") then fs.delete("modules") end
fs.makeDir("modules")

local success = true
for _, path in ipairs(files) do
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X FAILED: "..path)
        print("Verify file exists at:")
        print("https://raw.githubusercontent.com/"..
            GITHUB_USER.."/"..GITHUB_REPO.."/"..
            GITHUB_BRANCH.."/"..path)
        success = false
    end
end

if success then
    print("/ SUCCESS! System updated")
    if needsReboot then
        print("Restarting updater...")
        sleep(3)
        shell.run("update.bat")
    else
        print("Run 'startup' to launch")
    end
else
    print("X CRITICAL ERRORS - Manual fix required")
end
