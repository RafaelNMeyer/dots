xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
autorandr -c
xset r rate 200 50
xset s off -dpms
~/.scripts/top_bar.sh
exec dunst &
exec dwm
