-- Start redshift if not running
run_if_not_running_pgrep({"redshift"}, function() awful.spawn("redshift -r") end)

-- Hide the mouse after 3 seconds of inactivity
os.execute("killall unclutter")
awful.spawn("unclutter --timeout 2 --jitter 20 --ignore-scrolling --start-hidden")

-- Set the keyboard layout to pl
os.execute("setxkbmap pl")
 

local function xmodmap(cmd)
	os.execute("xmodmap -e \""..cmd.."\"")
end
--awful.spawn("setxkbmap -option caps:menu")
-- Remap Caps Lock to Mod5
xmodmap("clear mod4")
xmodmap("add mod4 = Super_L Super_L Super_L Hyper_L")
xmodmap("clear lock")
xmodmap("keycode 66 = Super_R Super_R Super_R Super_R")
xmodmap("add mod3 = Super_R")

awful.spawn("start-pulseaudio-x11")

-- Clipbooard manager
awful.spawn("clipmenud")

-- Mute mic at startup
awful.spawn("amixer set Capture nocap")


-- Bluetooth
--awful.spawn("bluetoothctl connect MacOrSomething")

-- Launch after_init.lua after waiting a bit
awful.spawn.easy_async_with_shell("sleep 0.1", 
    function(_,_,_,_) require("after_init") end
)

-- Launch after_5sec.lua after waiting 5 seconds
awful.spawn.easy_async_with_shell("sleep 5", 
    function(_,_,_,_) require("after_5sec") end
)

run_if_not_running_pgrep("keepassxc")

run_if_not_running_pgrep({"tutanota"}, function() awful.spawn("tutanota-desktop") end)

run_if_not_running_pgrep("blueman-applet")
