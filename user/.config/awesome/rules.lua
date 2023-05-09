awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            callback = awful.client.setslave,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen,
            size_hints_honor = false,
        }
    }, 

    -- Always on top
    {
	    rule_any = {
            class = {
                "krunner",
		        "leagueclient.exe", "leagueclientux.exe",
                "league of legends.exe",
            }
        },
	    properties = { ontop = true } 
    },
    -- Maximized clients
    {
        rule_any = {
            class = { 
                "ttyper" 
            },
            name = {
                "Minecraft*", 
            }
        },
        properties = { maximized = true, focus = true }
    }, 
    -- Fullscreen clients
    {
        rule_any = {
            class = {
                "league of legends.exe"
            },
        },
        properties = { fullscreen = true }
    }, 
    -- Floating clients
    {
        rule_any = {
            class = {
                "krunner",
		        "leagueclient.exe", "leagueclientux.exe",
		        "riotclientux.exe"
	        },
	        name = {
		        "Picture in picture"
	        },
        },
        properties = { floating = true, size_hints_honor = true }
    }, 
    -- Fixed size clients
    {
        rule_any = {
            class = {
		        "leagueclient.exe", "leagueclientux.exe",
		        "riotclientux.exe"
	        },
        },
        properties = { is_fixed = true }
    },
    -- Titlebars enabled clients
    --[[ {
        rule_any = {
            class = {
	        },
        },
        properties = { titlebars_enabled = true }
    },
    --]]
    {
        rule_any = {
            class = {
		        "leagueclient.exe", "leagueclientux.exe",
     		    "riotclientux.exe", "keepassxc",
                "KeePassXC", "CrossCode"
	        },
        },
        callback = awful.placement.centered,
    },
}

for _, tag in pairs(all_tags) do
    if tag.c_autogenrules and tag.c_apps then
        awful.rules.rules[#awful.rules.rules + 1] = {
            rule_any = tag.c_apps,
            callback = function(c)
                c:move_to_tag(get_tag(all_tags[tag.c_name]))
        end,
        properties = { tag = tag.name },
}
    end
end
