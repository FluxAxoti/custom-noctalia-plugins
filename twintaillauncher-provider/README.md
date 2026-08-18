# TwintailLauncher Provider
---
A way to launch gacha games from TwintailLauncher through Noctalia.

## Plugin

| Field | Value |
| --- | --- |
| ID | `fluxaxoti/twintaillauncher-provider` |
| Entry | Launcher provider: `twintaillauncher-provider` |
| Launcher Prefix | `/ttl` |

## Requirements

Ensure that TwintailLauncher is installed, either from Flatpak or other means, and the correct executable is set in the plugin's settings.

## Usage

Open the Noctalia Launcher, and type /ttl to list all installed games, or search for a specific installed game by adding a query like "arknights" after it. After that, just select a game and let it launch.

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `flatpak` | `boolean` | `true` | Whether or not the user wants to use the Flatpak version |

## Notes

This provider only reads default game directories because it is meant to be used with games installed through TwintailLauncher, thus games installed through Steam wont show up. When having the Flatpak option enabled, it defaults to `~/.var/app/app.twintaillauncher.ttl/data/twintaillauncher/games`, otherwise, it defaults to `~/.local/share/twintaillauncher/games`
