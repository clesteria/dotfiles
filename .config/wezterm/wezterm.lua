local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- OS

local pane_args

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "pwsh.exe" }
	pane_args = { "wsl.exe -d archlinux" }
end

-- Color scheme

config.color_scheme = "OneHalfDark"

-- Fonts

local fontset = { family = "UDEV Gothic JPDOC", size = 13.0, bold = "Bold", italic = true }
-- local fontset = { family = 'JF Dot Elisa Font 8', size = 6.0, bold = 'Regular', italic = false }
-- local fontset = { family = 'Osaka－等幅', size = 9.0, bold = 'Regular', italic = false }

config.font = wezterm.font(fontset["family"])
config.font_size = fontset["size"]

config.font_rules = {
	{
		intensity = "Bold",
		font = wezterm.font({
			family = fontset["family"],
			weight = fontset["bold"],
		}),
	},
	{
		italic = true,
		font = wezterm.font({
			family = fontset["family"],
			italic = fontset["italic"],
		}),
	},
}

-- UI

config.use_ime = true
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_tabs_in_tab_bar = true
config.window_decorations = "RESIZE"

local bgnum = math.random(2)
local background_filepath = wezterm.config_dir .. "/bg" .. bgnum .. ".png"
local background_file = io.open(background_filepath)
if background_file then
	config.text_background_opacity = 0.4
	config.background = {
		{
			source = {
				File = background_filepath,
			},
			hsb = {
				brightness = 0.05,
				hue = 1.0,
				saturation = 1.0,
			},
			vertical_align = "Middle",
			horizontal_align = "Right",
			height = "100%",
			repeat_x = "NoRepeat",
			repeat_y = "NoRepeat",
			attachment = "Fixed",
		},
	}
end

-- boot settings

wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window({})
	window:gui_window():toggle_fullscreen()

	pane:split({
		direction = "Right",
		args = pane_args,
	})

	pane:split({
		direction = "Bottom",
		args = pane_args,
	})
end)

-- key settings

config.keys = { -- Shift+Enterで改行を送信
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\n"),
	},
}

-- confid end

return config
