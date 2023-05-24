local dpi   = require("beautiful.xresources").apply_dpi
hotkeys_popup = require("awful.hotkeys_popup")
hotkeys_popup.hide_without_description = false


local os = os
local my_table = awful.util.table

theme                                           = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/theme"
theme.font                                      = "Sans 11"
theme.font_bold                                 = "Sans Bold 11"

theme.fg_normal                                 = "#bbbbbb"
theme.fg_focus                                  = "#cccccc"
theme.fg_urgent                                 = "#cccccc"
theme.bg_normal                                 = "#000000"
theme.bg_focus                                  = "#005577"
theme.bg_urgent                                 = "#005577"

theme.blocks_fg                                 = "#eeeeee"

theme.hotkeys_bg                                = "#1d1f21"
theme.hotkeys_fg                                = "#fcfcfc"

theme.notification_fg                           = "#fcfcfc"
theme.notification_icon_size                    = 256

theme.border_width                              = dpi(default_border_size)
theme.border_normal                             = "#000000"
theme.border_focus                              = "#ff0000"
theme.border_marked                             = "#ff0000"

theme.tasklist_bg_normal                        = "#000000"
theme.tasklist_bg_focus                         = "#222222"

theme.taglist_fg_urgent                         = theme.bg_urgent
theme.taglist_bg_urgent                         = theme.fg_urgent
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"


theme.menu_height                               = dpi(26)
theme.menu_width                                = dpi(140)
theme.tasklist_plain_task_name                  = false
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(default_useless_gap)

local function create_widget(icon, seconds, cmd)
    local widget = awful.widget.watch(cmd, seconds,
        function(widget, stdout)
	    widget.markup =
	        '<span color="'..theme.blocks_fg..'" font="'..theme.font..'">  '..icon..stdout..'</span>'
        end)
    return widget
end



local function change_colors_if1c(s)
    if not s then return end
    local file = io.open(userdir .."/.config/wallpapers/selected", "r")
    local read_wallpaper
    if file then
        read_wallpaper = file:read()
        file:close()
    end

    if #s.tiled_clients == 0 and
        (read_wallpaper == '#000000' or read_wallpaper == 'oneshot/main.png') then
        for _, w in pairs(s.widgets) do
            w.bg = "#000000"
        end
    else
        for _, w in pairs(s.widgets) do
            w.bg = "#222222"
        end
    end
end

client.connect_signal("tagged", function(c) change_colors_if1c(c.screen) end)
client.connect_signal("untagged", function(c) change_colors_if1c(c.screen) end)
tag.connect_signal("property::selected", function(t) change_colors_if1c(t.screen) end)

local mylayoutbox = require("mylayoutbox")


function theme.at_screen_connect(s)
    s.widgets = {
        spr = wibox.widget.textbox(' '),
        mem = create_widget("󰍛", 2,  'sh -c "$HOME/.config/scripts/bar/mem.sh"'),
        swap = create_widget("", 2,  'sh -c "$HOME/.config/scripts/bar/swap.sh"'),
        cpu = create_widget("", 2,  'sh -c "$HOME/.config/scripts/bar/cpu.sh"'),
        cputemp = create_widget("", 1,  'sh -c "$HOME/.config/scripts/bar/cputemp.sh"'),
        screentemp = create_widget("", 15, 'sh -c "$HOME/.config/scripts/bar/screentemp-redshift.sh"'),
        network = create_widget("", 5, 'sh -c "$HOME/.config/scripts/bar/network-traffic.sh"'),
        updates = create_widget("", 60, 'sh -c "$HOME/.config/scripts/bar/updates.sh"'),
        uptime = create_widget(" ", 60, 'sh -c "$HOME/.config/scripts/bar/uptime.sh"'),
        klayout = create_widget(" ", 1, "cat /tmp/keyboard_layout"),
        date = create_widget("",   1, 'sh -c "$HOME/.config/scripts/bar/date.sh"'),
        layoutbox = mylayoutbox.new(s),
        taglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
        },
        tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.focused, nil),
    }
    for n, w in pairs(s.widgets) do
        s.widgets[n] = wibox.container.background(w, theme.bg_normal)
    end

    -- Set the wallpaper
    ext_init = 1
    assert(loadfile(userdir .. '/.config/wallpapers/wallpaper.lua', 't', _ENV))()

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = theme.menu_height, bg = theme.bg_normal, fg = theme.fg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.widgets.taglist,
            s.widgets.spr, s.widgets.spr, s.widgets.spr,
            s.widgets.layoutbox,
            s.widgets.spr, s.widgets.spr, s.widgets.spr,
        },
        s.widgets.tasklist, -- Middle widget
        {
            layout = wibox.layout.fixed.horizontal,
            s.widgets.mem,
            s.widgets.swap,
            s.widgets.cpu,
            s.widgets.cputemp,
            s.widgets.screentemp,
            s.widgets.network,
            s.widgets.updates,
            s.widgets.uptime,
            s.widgets.klayout,
            s.widgets.date,
            s.widgets.spr, s.widgets.spr, s.widgets.spr,
        }
    }
end

theme.icon_theme = "/usr/share/icons/breeze-dark"

return theme
