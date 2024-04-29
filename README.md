# Sessionizer for Wezterm

---

A tmux like sessionizer for Wezterm that was inspired by [ThePrimeagen's tmux-sessionizer](https://github.com/ThePrimeagen/.dotfiles/blob/master/bin/.local/scripts/tmux-sessionizer)

The sessionizer allows for opening of windows/sessions based on the passed in
directories, as well as fast and intuative switching between active
workspaces/sessions

## Setup

An example configuration calling the plugin

```lua
local wezterm = require "wezterm"
local sessionizer = wezterm.plugin.require("https://github.com/ElCapitanSponge/sessionizer.wezterm")

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

--INFO: The sessionizer lverages the `LEADER` mod
config.leader = {
    key = "a",
    mods = "CTRL",
    timeout_milliseconds = 1000
}

config.keys = {}

-- INFO: The following is the project directories to search
local projects = {
    "~/personal",
    "~/work"
}

sessionizer.set_projects(projects)
sessionizer.configure(config)

return config
```

## USEAGE

To use the sessionizer you have to define and pass through a table of project
folders, that are the paths to your applicable repositores to leverage for the
workspaces.

```lua
local projects = {
    "~/personal",
    "~/work"
}
```

To display the sessionizer all you have to do is press the key combination of
`LEADER` + `f`

To display the active windows/sessions all you have to do is press the key
combination of `LEADER` + `s`

## Change keybinding

To change the keybinding from the default (`LEADER` + `f`):

```lua
config.keys = {
    -- ... other bindings
    {
        key = "w",
        mods = "CTRL|ALT",
        action = sessionizer.switch_workspace()
    }
}
```
