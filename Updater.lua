-- Updater.lua
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3
local UPDATER_NAME = "Updater.lua"

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

-- Self-update mechanism
local function updateSelf()
    print("Checking for updater updates...")
    if downloadFile(UPDATER_NAME..".new") then
        -- Create update script
        local bat = fs.open("update.bat", "w")
        bat.write([[
            copy ]]..UPDATER_NAME..[[.new ]]..UPDATER_NAME..[[
            delete ]]..UPDATER_NAME..[[.new
            delete update.bat
            ]]..UPDATER_NAME..[[
        ]])
        bat.close()
        return true
    end
    return false
end

-- Main
local needsReboot = updateSelf()
local files = {
    "startup.lua",
    "modules/colony.lua",
    "modules/display.lua",
    UPDATER_NAME
}

print("Starting main update...")
fs.delete("startup.lua")
if fs.exists("modules") then fs.delete("modules") end
fs.makeDir("modules")

local success = true
for _, path in ipairs(files) do
    if path == UPDATER_NAME then path = path..".new" end  -- Temp file
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X Failed: "..path)
        success = false
    end
end

if success then
    print("/ Update complete!")
    if needsReboot then
        print("Restarting updater...")
        sleep(2)
        shell.run("update.bat")
    else
        print("Run 'startup' to launch")
    end
else
    print("X Partial update - check errors above")
end
