local awful = require("awful")
local gears = require("gears")
local lain = require("lain")
local wibox = require("wibox")
local beautiful = require("beautiful")

local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

-- Custom Widgets
local awsm_icon = wibox.widget.imagebox(beautiful.awesome_icon)

myvolume = lain.widget.pulse({
	timeout = 30,
	settings = function()
		if volume_now == "M" then
			widget:set_markup("   " .. volume_now)
		elseif volume_now == "0%" then
			widget:set_markup("  " .. volume_now)
		else
			widget:set_markup("   " .. volume_now)
		end
	end,
})

mybrightness = lain.widget.brt({
	timeout = 30,
	settings = function()
		widget:set_markup("󰃠  " .. brightness_now .. "%")
	end,
})

awful.screen.connect_for_each_screen(function(s)
	-- Each screen has its own tag table.
	--awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, s, awful.layout.layouts[1])
	local names = { "www", "term", "apps", "files", "slack", "wapp", "docs", "social", "mail", "utils", "XI", "XII" }

	awful.tag(names, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	local mycpu = lain.widget.cpu({
		settings = function()
			widget:set_markup("  " .. cpu_now.usage .. "%")
		end,
	})
	local mymem = lain.widget.mem({
		settings = function()
			widget:set_markup("  " .. mem_now.used)
		end,
	})
	local mybattery = lain.widget.bat({
		timeout = 5,
		settings = function()
			local bat_icon = "  "
			if type(bat_now.perc) ~= "number" then
				bat_icon = ""
			elseif bat_now.perc < 15 then
				bat_icon = "  "
			end
			widget:set_markup(bat_icon .. bat_now.perc .. "% " .. bat_now.status)
		end,
	})

	local separator = wibox.widget.textbox(" | ")

	-- Create a textclock widget
	local mytextclock = wibox.widget.textclock("  %a %b %d, %I:%M %p ")

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "bottom", screen = s, height = 25 })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			awsm_icon,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			myvolume,
			separator,
			mycpu,
			separator,
			mymem,
			separator,
			mybrightness,
			separator,
			mybattery,

			separator,
			mytextclock,
			wibox.widget.systray(),
			s.mylayoutbox,
		},
	})
end)
