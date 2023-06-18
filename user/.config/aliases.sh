alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias tree='lsd --tree'

alias 'cd..'='cd ..'
alias 'cd,,'='cd ..'

alias 'dps'='doas pacman -Syu'
alias 'sl'='ls'
alias 'rmm'='rmtrash'


alias reboot='loginctl reboot'
alias poweroff='loginctl poweroff'
alias suspend='awesome-client "suspend()"'
alias hibernate='awesome-client "hibernate()"'

alias f='fdisk -l'

alias motherboard='cat /sys/devices/virtual/dmi/id/board_{vendor,name,version}'

alias cat='bat'
alias diff='difft'
alias ti='hyperfine'
alias man='batman'

alias dust='dust --reverse'

alias iforgothowtosyncfork='printf "# Sync your fork\ngit fetch upstream\ngit checkout master\ngit merge upstream/master\n"'
alias gitignorenowork='printf "#Remember to commit everything changed before you do this!\ngit rm -rf --cached .\ngit add .\n"'
alias iuploadedmycreditcardnumbertogitwhatnow='printf "git filter-repo --invert-paths --path <path to the file or directory>"\n'
alias mountqcow2='printf "# Mount\ndoas modprobe nbd max_part=8\ndoas qemu-nbd --connect=/dev/nbd0 IMAGE.qcow2\ndoas mount /dev/nbd0 MNT\n\n# Umount\ndoas umount MNT\ndoas qemu-ndp --disconnect /dev/nbd0"'
alias blkiduuid='blkid -s UUID -o value /dev/vda1'

alias awesomesuperbroken='xmodmap -e "clear mod4"; xmodmap -e "add mod4 = Super_L Super_L Super_L Hyper_L"'

alias watch='watch -c'

alias publicip='curl ifconfig.me'

alias timer='termdown'
alias cagea='cage -d -s -- alacritty'
alias slazygit='lazygit --git-dir=$(git rev-parse --git-dir)'

alias awesome='sh $HOME/.config/awesome/run/run.sh'
alias dwl='sh $HOME/.config/dwl/run/run.sh'
alias river='sh $HOME/.config/river/run.sh'
