local wezterm = require "wezterm"
local act = wezterm.action

---Flag for if the system is windows or not
local is_windows = string.find(wezterm.target_triple, "windows") ~= nil

---The base folders in which to retrieve their children
local project_base = {}

---Run a desired command
---@param cmd string
---@return string
local command_run = function(cmd)
	local stdout

	if is_windows then
		-- INFO: Assumes on windows you are running powershell
		_, stdout, _ = wezterm.run_child_process({
			"powershell",
			"-command",
			cmd
		})
	else
		_, stdout, _ = wezterm.run_child_process({
			os.getenv("SHELL"),
			"-c",
			cmd
		})
	end

	return stdout
end

---Retrieve the directories found within the base_path table
---@return { id: string, label: string }[]
local get_directories = function()
	local folders = {}

	for _, base_path in ipairs(project_base) do
		local command = nil
		if is_windows then
			command = "(Get-ChildItem -Path " .. base_path .. ").FullName"
		else
			command = "find " .. base_path .. " -mindepth 1 -maxdepth 1 -type d"
		end

		if command ~= nil then
			local out = command_run(command)
			for _, path in ipairs(wezterm.split_by_newlines(out)) do
				local updated_path = string.gsub(path, wezterm.home_dir, "~")
				table.insert(folders, { id = path, label = updated_path })
			end
		end
	end

	return folders
end

---The switching between workspaces
local workspace_switcher = function()
	return wezterm.action_callback(function(window, pane)
		local workspaces = get_directories()

		window:perform_action(
			act.InputSelector({
				action = wezterm.action_callback(
					function(inner_window, inner_pane, id, label)
						if not id and not label then
							-- INFO: Do nothing
						else
							local full_path = string.gsub(
								label,
								"^~",
								wezterm.home_dir
							)

							if
								full_path:sub(1, 1) == "/" or
								full_path:sub(3, 3) == "\\"
							then
								inner_window:perform_action(
									act.SwitchToWorkspace({
										name = label,
										spawn = {
											label = "Workspace: " ..label,
											cwd = full_path
										}
									}),
									inner_pane
								)
							else
								inner_window:perform_action(
									act.SwitchToWorkspace({
										name = id
									}),
									inner_pane
								)
							end
						end
					end
				),
				title = "Wezterm Sessionizer",
				choices = workspaces,
				fuzzy = true
			}),
			pane
		)
	end)
end

---List the active workspaces
local active_workspaces = function()
	return act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" }
end

---Configure the default key bindings
---@param config table
local configure = function(config)
	table.insert(config.keys, {
		key = "f",
		mods = "LEADER",
		action = workspace_switcher()
	})

	table.insert(config.keys, {
		key = "s",
		mods = "LEADER",
		action = active_workspaces()
	})
end

---Configure the project paths
---@param paths table
local set_projects = function(paths)
	project_base = paths
end

return {
	configure = configure,
	set_projects = set_projects,
	switch_workspace = workspace_switcher,
	active_workspaces = active_workspaces
}
