Dependencies:
Xrandr >= 1.5
Xlib



Testing (after virtual desktop(s) are up. ):
zig build
DISPLAY=:1 ./zig-cache/buoy


To run a program/application:
DISPLAY=:1 xterm
or
xterm -display :1


Testing environments

Setup:
Run script 'run_test_env'. Only xinerama detects these fake dual screens.



Zig translate-c example (in nixos):
zig translate-c ./translate.h $NIX_CFLAGS_COMPILE > ./translate.zig


TODO:
Check Xephyr options for tty or vt
