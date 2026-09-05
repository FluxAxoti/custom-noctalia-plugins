--!nonstrict
local pluginData = noctalia.pluginDataDir()
local iconPath = pluginData.."/icons"
local manifestPath
local manifestFiles = {}
local game_path
local local_games: {string}

if noctalia.getConfig("flatpak") ~= false then
    executable = "flatpak run app.twintaillauncher.ttl"
    game_path = noctalia.expandPath("~/.var/app/app.twintaillauncher.ttl/data/twintaillauncher/games")
    manifestPath = noctalia.expandPath("~/.var/app/app.twintaillauncher.ttl/data/twintaillauncher/manifests/TwintailTeam/game-manifests")
else
    executable = noctalia.getConfig("exec_command")
    game_path = noctalia.expandPath("~/.local/share/twintaillauncher/games")
    manifestPath = noctalia.expandPath("~/.local/share/twintaillauncher/manifests/TwintailTeam/game-manifests")
end

local success, err = pcall(function()
    local_games = noctalia.listDir(game_path)
end)

for _, game in local_games do
    for id, manifest in noctalia.listDir(manifestPath) do
        if string.find(manifest, game, 1, true) then
            table.insert(manifestFiles, noctalia.json.decode(noctalia.readFile(manifestPath.."/"..manifest)))
        end
    end
end

function onQuery(query)
    local game_results = {}
    local results = {}
    if not success then
        launcher.setResults(query, {{id = "failed", title = "No games found", subtitle = "No installed games were found", glyph = "x", score = 0}})
    else
        for _, manifest in manifestFiles do
            if not noctalia.fileExists(iconPath.."/"..manifest["biz"]..".ico") then
                noctalia.notify("Downloading icons..")
                noctalia.download(manifest["assets"]["game_icon"], iconPath.."/"..manifest["biz"]..".ico", function(resp)
                    table.insert(game_results, {id = manifest["biz"], title = manifest["display_name"], subtitle = noctalia.listDir(game_path.."/"..manifest["biz"])[1], icon = iconPath.."/"..manifest["biz"]..".ico", score = 0})
                    launcher.setResults(query, game_results)
                end)
            else
                table.insert(game_results, {id = manifest["biz"], title = manifest["display_name"], subtitle = noctalia.listDir(game_path.."/"..manifest["biz"])[1], icon = iconPath.."/"..manifest["biz"]..".ico", score = 0})
            end
        end

        if #noctalia.listDir(iconPath.."/") == #local_games then
            for _, game in game_results do
                local formatted_game = string.gsub(string.gsub(string.lower(game["title"]), " ", ""), ":", "")
                local formatted_query = string.gsub(string.gsub(string.lower(query), " ", ""), ":", "")
                if formatted_game:find(formatted_query, 1, true) then
                table.insert(results, game)
                end
            end
            launcher.setResults(query, results)
        end
    end
end

function onActivate(id)
    if not (id == "failed") then
        for _, game in local_games do
            if game == id then
                noctalia.runAsync(executable.." --install "..noctalia.listDir(game_path.."/"..game)[1])
            end
        end
    end
end
