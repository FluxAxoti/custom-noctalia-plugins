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

function loadGames()
    table.clear(manifestFiles)
    success, err = pcall(function()
        local_games = noctalia.listDir(game_path)
    end)

    for _, game in local_games do
        for id, manifest in noctalia.listDir(manifestPath) do
            if string.gsub(manifest, ".json", "") == game then
                table.insert(manifestFiles, noctalia.json.decode(noctalia.readFile(manifestPath.."/"..manifest)))
            end
        end
    end
end

loadGames()

function onQuery(query)
    loadGames()
    local game_results = {}
    local results = {}
    if not success or #manifestFiles == 0 then
        launcher.setResults(query, {{id = "failed", title = "No games found", subtitle = "No installed games were found", glyph = "x", score = 0}})
    else
        for _, manifest in manifestFiles do
            local subtitle
            if not noctalia.fileExists(iconPath.."/"..manifest["biz"]..".ico") then
                subtitle = noctalia.listDir(game_path.."/"..manifest["biz"])[1]
                if subtitle == nil then
                    subtitle = "No version hash found, please check your installation."
                end
                noctalia.notify("TwintailLauncher Provider", "Downloading icons..")
                noctalia.download(manifest["assets"]["game_icon"], iconPath.."/"..manifest["biz"]..".ico", function(resp)
                    table.insert(game_results, {id = manifest["biz"], title = manifest["display_name"], subtitle = subtitle, icon = iconPath.."/"..manifest["biz"]..".ico", score = 0})
                    launcher.setResults(query, game_results)
                end)
            else
                subtitle = noctalia.listDir(game_path.."/"..manifest["biz"])[1]
                if subtitle == nil then
                    subtitle = "No version hash found, please check your installation."
                end
                table.insert(game_results, {id = manifest["biz"], title = manifest["display_name"], subtitle = subtitle, icon = iconPath.."/"..manifest["biz"]..".ico", score = 0})
            end
        end

        if #noctalia.listDir(iconPath.."/") >= #manifestFiles then
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
        for _, manifest in manifestFiles do
            if manifest["biz"] == id then
                noctalia.runAsync(executable.." --install "..noctalia.listDir(game_path.."/"..manifest["biz"])[1])
            end
        end
    end
end
