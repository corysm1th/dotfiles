local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrainsMono Nerd Font Mono")

-- config.window_decorations = "RESIZE"

config.keys = {
	{
		key = "F2",
		mods = "NONE",
		action = wezterm.action.SendString("k_fzf_pod\n"),
	},
	{
		key = "F2",
		mods = "SHIFT",
		action = wezterm.action.SendString("k_fzf_ns\n"),
	},
	{
		key = "F12",
		mods = "NONE",
		action = wezterm.action.SendString("aws_fzf\n"),
	},
	{
		key = "F12",
		mods = "SHIFT",
		action = wezterm.action.SendString("aws_fzf_ec2\n"),
	},
}
return config
