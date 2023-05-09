/bin/rm -f ~/.zshrc
if [ $(tty) = "/dev/tty1" ]; then
	if [ ! $DISPLAY ]; then
		source ~/.config/zsh/.zshrc
		exec xinit -- vt1
	fi
fi
