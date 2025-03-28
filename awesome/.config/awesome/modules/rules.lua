local awful = require("awful")
local beautiful = require("beautiful")

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"SimpleScreenRecorder",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
				"bubble", -- Browser popups
			},
		},
		properties = { floating = true },
	},

	-- Fullscreen
	{
		rule_any = {
			class = {
				"mpv",
			},
		},
		properties = { fullscreen = true },
	},

	-- Add titlebars to normal clients and dialogs
	{
		rule_any = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = false },
	},

	-- Map apps to workspaces
	{ rule = { class = "Code" }, properties = { screen = 1, tag = "code" } },
	{ rule = { class = "Slack" }, properties = { screen = 1, tag = "slack" } },
	{ rule = { class = "Thunar" }, properties = { screen = 1, tag = "files" } },
	{ rule = { class = "Telegram" }, properties = { screen = 1, tag = "social" } },
	{ rule = { class = "discord" }, properties = { screen = 1, tag = "social" } },
	{ rule = { name = "WhatsApp Web" }, properties = { screen = 1, tag = "wapp" } },
	{ rule = { class = "Soffice" }, properties = { screen = 1, tag = "docs" } },
	{ rule = { class = "thunderbird" }, properties = { screen = 1, tag = "mail" } },
	{ rule = { class = "Gimp*" }, properties = { screen = 1, tag = "XI" } },
}
