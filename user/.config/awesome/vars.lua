userdir	     = os.getenv('HOME')
awesomedir   = userdir.."/.config/awesome"
themefile    = awesomedir.."/theme.lua"

terminal     = "alacritty"
terminal_cmd = terminal.." -e "
editor       = "nvim"
music_player = "alacritty --class cmus --title cmus -e cmus"
music_player_class = "cmus"

alt          = "Mod1"
super        = "Mod4"
ctrl 	     = "Control"
shift        = "Shift"
caps         = "Mod3"

lock_wallpaper = userdir .. '/.config/wallpapers/oneshot/main.png'

default_layout_index = 2

awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center
}
normal_tag_count = 3

no_border_when_1client = true

default_useless_gap = 0
default_border_size = 0

--screens = {"DisplayPort-0"}

screenshots_folder = userdir .. '/Pictures/Screenshots/'
screenshots_date_format = '%x_%X'
screenshot_editor = 'kolourpaint'


lock_command = 'alock -b image:file=' .. lock_wallpaper .. ' -i none'


awful.util.terminal = terminal

ext_noti = false

awful.spawn('xset r rate 400 100')
