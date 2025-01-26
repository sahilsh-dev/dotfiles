local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local os = require("os")

globalkeys = gears.table.join(
	awful.key({ modkey }, "w", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.bydirection("down")
	end, { description = "move window down", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.bydirection("up")
	end, { description = "move window up", group = "client" }),
	awful.key({ modkey }, "h", function()
		awful.client.focus.bydirection("left")
	end, { description = "move window left", group = "client" }),
	awful.key({ modkey }, "l", function()
		awful.client.focus.bydirection("right")
	end, { description = "move window right", group = "client" }),

	-- User Hotkeys
	awful.key({ modkey }, "e", function()
		awful.spawn("thunar")
	end),
	awful.key({ modkey }, "b", function()
		awful.spawn("firefox")
	end),
	awful.key({ modkey }, "s", function()
		awful.spawn("flameshot gui")
	end),
	awful.key({ modkey }, "v", function()
		awful.spawn("code")
	end),

	awful.key({ modkey }, "g", function()
		awful.util.spawn("rofimoji")
	end),
	-- awful.key({ modkey }, "x", function () os.execute("betterlockscreen -l blur") end),

	awful.key({}, "XF86MonBrightnessDown", function()
		os.execute("brightnessctl s 10%-")
		mybrightness.update({ do_notify = true })
	end),
	awful.key({}, "XF86MonBrightnessUp", function()
		os.execute("brightnessctl s +10%")
		mybrightness.update({ do_notify = true })
	end),

	-- Volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		os.execute("pamixer -i 10")
		myvolume.update({ do_notify = true })
	end),
	awful.key({}, "XF86AudioLowerVolume", function()
		os.execute("pamixer -d 10")
		myvolume.update({ do_notify = true })
	end),
	awful.key({}, "XF86AudioMute", function()
		os.execute("pamixer -t")
		myvolume.update({ do_notify = true })
	end),

	-- Playerctl control (incompatible with mpd below)
	awful.key({}, "XF86AudioNext", function()
		os.execute("playerctl next -p $(playerctl -l | grep mpd | head -n 1)")
	end),
	awful.key({}, "XF86AudioPrev", function()
		os.execute("playerctl previous -p $(playerctl -l | grep mpd | head -n 1)")
	end),
	awful.key({}, "XF86AudioPlay", function()
		os.execute("playerctl play-pause -p $(playerctl -l | grep mpd | head -n 1)")
	end),

	-- Layout manipulation
	awful.key({ modkey, "Control" }, "h", function()
		awful.client.swap.bydirection("left")
	end, { description = "swap with client on left", group = "client" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.client.swap.bydirection("right")
	end, { description = "swap with client on right", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.client.swap.bydirection("down")
	end, { description = "swap with client on down", group = "client" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.client.swap.bydirection("up")
	end, { description = "swap with client on up", group = "client" }),

	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incmwfact(0.05)
	end),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.incwfact(0.1)
	end),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.incwfact(-0.1)
	end),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Control" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey }, "c", function()
		awful.tag.incncol(1, nil, true)
	end),
	awful.key({ modkey, "Shift" }, "c", function()
		awful.tag.incncol(-1, nil, true)
	end),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey, "Shift" }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" }),
	-- Menubar
	awful.key({ modkey }, "r", function()
		awful.spawn(".config/rofi/scripts/launcher_t2")
	end, { description = "launcher rofi", group = "launcher" }),
	awful.key({ modkey }, "p", function()
		awful.spawn(".config/rofi/scripts/powermenu_t2")
	end, { description = "rofi powermenu", group = "launcher" })
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key({ modkey }, "t", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
	awful.key({ modkey }, "z", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 12 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
					tag:view_only()
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
