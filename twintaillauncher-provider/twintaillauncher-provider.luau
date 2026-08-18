--!nonstrict

local games = {
    {id = "aethergazer_global", title = "Aether Gazer Global", subtitle = "", icon = noctalia.pluginDir().."/icons/aethergazer_global.ico", score = 0},
    {id = "hkrpg_global", title = "Honkai: StarRail Global", subtitle = "", icon = noctalia.pluginDir().."/icons/hkrpg_global.ico", score = 0},
    {id = "bh3_global", title = "Honkai Impact 3rd Global", subtitle = "", icon = noctalia.pluginDir().."/icons/bh3_global.ico", score = 0},
    {id = "wuwa_global", title = "Wuthering Waves Global", subtitle = "", icon = noctalia.pluginDir().."/icons/wuwa_global.ico", score = 0},
    {id = "nap_global", title = "Zenless Zone Zero Global", subtitle = "", icon = noctalia.pluginDir().."/icons/nap_global.ico", score = 0},
    {id = "hk4e_global", title = "Genshin Impact Global", subtitle = "", icon = noctalia.pluginDir().."/icons/hk4e_global.ico", score = 0},
    {id = "pgr_global", title = "Punishing: Gray Raven Global", subtitle = "", icon = noctalia.pluginDir().."/icons/pgr_global.ico", score = 0},
    {id = "sdsgc_global", title = "SevenDeadlySins: Grand Cross Global", subtitle = "", icon = noctalia.pluginDir().."/icons/sdsgc_global.ico", score = 0},
    {id = "endfield_global", title = "Arknights: Endfield", subtitle = "", icon = noctalia.pluginDir().."/icons/endfield_global.ico", score = 0}
}
local executable: string

function onQuery(query)
    local game_results = {}
    local results = {}
    local game_path: string
    local local_games: {string}
    if noctalia.getConfig("flatpak") ~= false then
        executable = "flatpak run app.twintaillauncher.ttl"
        game_path = noctalia.expandPath("~/.var/app/app.twintaillauncher.ttl/data/twintaillauncher/games")
    else
        executable = noctalia.getConfig("exec_command")
        game_path = noctalia.expandPath("~/.local/share/twintaillauncher/games")
    end
    local_games = noctalia.listDir(game_path)
    for id, game in games do
        for local_id, local_game in local_games do
            for _, hash in noctalia.listDir(game_path.."/"..local_game) do
                if game.id == local_game then
                    game["subtitle"] = hash
                    table.insert(game_results, game)
                end
            end
        end
    end

    launcher.setResults(query, game_results)

    for _, game in game_results do
        local formatted_game = string.gsub(string.gsub(string.lower(game["title"]), " ", ""), ":", "")
        local formatted_query = string.gsub(string.gsub(string.lower(query), " ", ""), ":", "")
        if formatted_game:find(formatted_query, 1, true) then
          table.insert(results, game)
        end
    end
    launcher.setResults(query, results)
end

function onActivate(id)
    for _, game in games do
        if game["id"] == id then
            noctalia.runAsync(executable.." --install "..game["subtitle"])
        end
    end
end
