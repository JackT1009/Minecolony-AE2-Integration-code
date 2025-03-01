-- Updater.lua
local GITHUB_USER = "JackT1009"
local GITHUB_REPO = "Minecolony-AE2-Integration-code"
local GITHUB_BRANCH = "ColonyBrain-Test-Branch"

local githubPath = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..GITHUB_REPO.."/"..GITHUB_BRANCH

local files = {
    "startup.lua",
    "modules/colony.lua",
    "modules/display.lua"
}

-- Delete old files
print("Cleaning old files...")
fs.delete("startup.lua")
if fs.exists("modules") then
    fs.delete("modules")
end
fs.makeDir("modules")

-- Download fresh files
print("Downloading updates:")
for _, path in ipairs(files) do
    local url = githubPath.."/"..path
    print("- "..path)
    local response = http.get(url)
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
    else
        print("✗ Failed: "..path)
    end
    sleep(0.5) -- Rate limiting
end

print("Update complete! Run 'startup' to launch")
