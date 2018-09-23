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
zig translate-c /nix/store/sma8yp1cb1f936j7lr1j244614jd241x-libxcb-1.12-dev/include/xcb/xcb.h $NIX_CFLAGS_COMPILE > ./xcb.zig


TODO:
Check Xephyr options for tty or vt
