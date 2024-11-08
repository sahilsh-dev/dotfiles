-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local os = require("os")
local lain = require("lain")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
awful.spawn.easy_async_with_shell("~/.config/awesome/autorun.sh")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!!!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- - Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

mymainmenu = awful.menu({
    items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
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
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
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
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


-- Widgets
local myvolume = lain.widget.pulse {
    timeout = 30,
    settings = function ()
        widget:set_markup(" Vol " .. volume_now)
    end
}
local mybrightness = lain.widget.brt {
    timeout = 60,
    settings = function ()
        widget:set_markup("Bt " .. brightness_now .. "%")
    end
}

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, s, awful.layout.layouts[1])
    local names = { "www", "term", "code", "files", "apps", "social", "docs", "www", "mail", "X", "XI", "XII" }

    awful.tag(names, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    local mycpu = lain.widget.cpu {
        settings = function()
            widget:set_markup("Cpu " .. cpu_now.usage .. "%")
        end
    }
    local mymem = lain.widget.mem {
        settings = function ()
            widget:set_markup("Mem " .. mem_now.used)
        end
    }
    local mybattery = lain.widget.bat {
        timeout = 10,
        settings = function()
           widget:set_markup(bat_now.perc .. "% " .. bat_now.status)
        end
    }

    local separator = wibox.widget.textbox(" | ")

    -- Create a textclock widget
    mytextclock = wibox.widget.textclock("%a %b %d, %I:%M %p ")

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s, height = 25 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        {             -- Right widgets
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
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "w", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),

    awful.key({ modkey, }, "j", function() awful.client.focus.bydirection('down') end,
    { description = "move window down", group = "client" }),
    awful.key({ modkey, }, "k", function() awful.client.focus.bydirection('up') end,
    { description = "move window up", group = "client" }),
    awful.key({ modkey, }, "h", function() awful.client.focus.bydirection('left') end,
    { description = "move window left", group = "client" }),
    awful.key({ modkey, }, "l", function() awful.client.focus.bydirection('right') end,
    { description = "move window right", group = "client" }),

    -- User Hotkeys
    awful.key({ modkey }, "e", function () awful.spawn( "thunar" ) end),
    awful.key({ modkey }, "b", function () awful.spawn( "google-chrome" ) end),
    awful.key({ modkey }, "s", function () awful.spawn( "flameshot gui" ) end),
    awful.key({ modkey }, "v", function () awful.spawn( "code" ) end),

    -- awful.key({ modkey }, "g", function () awful.util.spawn( "rofi -modi emoji -show emoji" ) end),
    -- awful.key({ modkey }, "x", function () os.execute("betterlockscreen -l blur") end),

    awful.key({}, "XF86MonBrightnessDown", function ()
        os.execute("brightnessctl s 10%-")
        mybrightness.update({ do_notify=true })
    end),
    awful.key({}, "XF86MonBrightnessUp", function ()
        os.execute("brightnessctl s +10%")
        mybrightness.update({ do_notify=true })
    end),

    -- Volume control
    awful.key({}, "XF86AudioRaiseVolume", function ()
        os.execute("pamixer -i 10")
        myvolume.update({ do_notify=true })
    end),
    awful.key({}, "XF86AudioLowerVolume", function ()
        os.execute("pamixer -d 10")
        myvolume.update({ do_notify=true })
    end),
    awful.key({}, "XF86AudioMute", function ()
        os.execute("pamixer -t")
        myvolume.update({ do_notify=true })
    end),

    -- Playerctl control (incompatible with mpd below)
    awful.key({}, "XF86AudioNext", function () os.execute("playerctl next -p $(playerctl -l | grep mpd | head -n 1)")       end),
    awful.key({}, "XF86AudioPrev", function () os.execute("playerctl previous -p $(playerctl -l | grep mpd | head -n 1)")   end),
    awful.key({}, "XF86AudioPlay", function () os.execute("playerctl play-pause -p $(playerctl -l | grep mpd | head -n 1)") end),

    -- Layout manipulation
    awful.key({ modkey, "Control" }, "h", function () awful.client.swap.bydirection("left") end,
        { description = "swap with client on left", group = "client"}),
    awful.key({ modkey, "Control" }, "l", function () awful.client.swap.bydirection("right") end,
      { description = "swap with client on right", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.client.swap.bydirection("down") end,
      { description = "swap with client on down", group = "client"}),
    awful.key({ modkey, "Control" }, "k", function () awful.client.swap.bydirection("up") end,
      { description = "swap with client on up", group = "client"}),

    awful.key({ modkey, "Shift"    }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey, "Shift"    }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"    }, "k",     function () awful.client.incwfact( 0.1)    end),
    awful.key({ modkey, "Shift"    }, "j",     function () awful.client.incwfact(-0.1)    end),

    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Control" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey }, "c", function () awful.tag.incncol(1, nil, true)    end),
    awful.key({ modkey, "Shift" }, "c", function () awful.tag.incncol(-1, nil, true)    end),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Prompt
    awful.key({ modkey, "Shift" }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),
    -- Menubar
    awful.key({ modkey }, "r", function() awful.spawn(".config/rofi/scripts/launcher_t2") end,
        { description = "launcher rofi", group = "launcher" }),
    awful.key({ modkey }, "p", function() awful.spawn(".config/rofi/scripts/powermenu_t2") end,
        { description = "rofi powermenu", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey }, "q", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, }, "t", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, }, "z", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 12 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                        tag:view_only()
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
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
-- }}}

-- {{{ Rules
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
            placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen
        }
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
                "SimpleScreenRecorder"
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",  -- e.g. Google Chrome's (detached) Developer Tools.
                "bubble" -- Browser popups
            }
        },
        properties = { floating = true }
    },

    -- Fullscreen
    {
        rule_any = {
            class = {
                "mpv",
            },
        },
        properties = { fullscreen = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },

    -- Map apps to workspaces
    { rule = { class = "code" },
      properties = { screen = 1, tag = "code" } },
    { rule = { class = "Thunar" },
      properties = { screen = 1, tag = "files" } },
    { rule = { class = "Telegram" },
      properties = { screen = 1, tag = "social" } },
    { rule = { class = "discord" },
      properties = { screen = 1, tag = "social" } },
    { rule = { name = "WhatsApp Web" },
      properties = { screen = 1, tag = "social" } },
    { rule = { class = "Soffice" } ,
      properties = { screen = 1, tag = "docs" } },
    { rule = { class = "thunderbird" },
      properties = { screen = 1, tag = "mail" } },
    { rule = { class = "Gimp*" },
      properties = { screen = 1, tag = "XI" } },
    { rule = { class = "obsidian" },
      properties = { screen = 1, tag = "apps" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("property::urgent", function(c) c:jump_to() end)
-- }}}
