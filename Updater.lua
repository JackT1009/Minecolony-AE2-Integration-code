-- Updater.lua
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"
local MAX_RETRIES = 3

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
        else
            print("Attempt "..i.." failed for "..path)
            sleep(2) -- Wait before retry
        end
    end
    return false
end

-- Main
print("Starting update...")
fs.delete("startup.lua")
if fs.exists("modules") then fs.delete("modules") end
fs.makeDir("modules")

local files = {
    "startup.lua",
    "modules/colony.lua",
    "modules/display.lua"
}

local success = true
for _, path in ipairs(files) do
    print("Downloading "..path)
    if not downloadFile(path) then
        print("X Critical error downloading "..path)
        print("Verify URL exists:")
        print("https://raw.githubusercontent.com/"..
            GITHUB_USER.."/"..GITHUB_REPO.."/"..
            GITHUB_BRANCH.."/"..path)
        success = false
        break
    end
end

if success then
    print("/ Update complete! Run 'startup'")
else
    print("X Update failed! Manual steps:")
    print("1. Check GitHub repo is public")
    print("2. Verify file paths")
    print("3. Ask server admin if HTTP is allowed")
end
