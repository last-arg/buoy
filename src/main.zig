// use "./debug.zig".; // TODO: move debug functions to its own file
const std = @import("std");
const warn = std.debug.warn;
const mem = std.mem;
const Allocator = mem.Allocator;
const os = std.os;
const child = os.ChildProcess;
// const BufMap = std.BufMap;
const ArrayList = std.ArrayList;
const LinkedList = std.LinkedList;
const hash_map = std.hash_map;
const HashMap = std.HashMap;

const xlib = @import("xlib.zig");
const xatom = @cImport({
    @cInclude("X11/Xproto.h");
    @cInclude("X11/Xatom.h");
});
const xrandr = @import("Xrandr.zig");

const None = 0;

const NotifyPointer = 5;

const ShiftMask = (1 << 0);
const Mod1Mask = (1 << 3);

const NoEventMask = 0;
const ButtonPressMask = (1 << 2);
const ButtonReleaseMask = (1 << 3);
const EnterWindowMask = (1 << 4);
const LeaveWindowMask = (1 << 5);
const PointerMotionMask = (1 << 6);
const ExposureMask = (1 << 15);
const StructureNotifyMask = (1 << 17);
const SubstructureNotifyMask = (1 << 19);
const SubstructureRedirectMask = (1 << 20);
const FocusChangeMask = (1 << 21);
const PropertyChangeMask = (1 << 22);


const LeftPointer: c_uint = 68;

const CopyFromParent: c_uint = 0;


const RevertToPointerRoot = @intCast(c_int, xlib.PointerRoot);


const CurrentTime: c_ulong = 0;

// Window attributes for CreateWindow and ChangeWindowAttributes 
const CWBackPixmap = (1 << 0);
const CWBackPixel = (1 << 1);
const CWBorderPixmap = (1 << 2);
const CWBorderPixel = (1 << 3);
const CWBitGravity = (1 << 4);
const CWWinGravity = (1 << 5);
const CWBackingStore = (1 << 6);
const CWBackingPlanes = (1 << 7);
const CWBackingPixel = (1 << 8);
const CWOverrideRedirect = (1 << 9);
const CWSaveUnder = (1 << 10);
const CWEventMask = (1 << 11);
const CWDontPropagate = (1 << 12);
const CWColormap = (1 << 13);
const CWCursor = (1 << 14);


const Screen = struct {
    index: c_int, // TODO: or use somekind of id ???
    has_mouse: bool,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    groups: LinkedList(u8),
    windows: LinkedList(xlib.Window),
};

const Group = struct {
    index: u8,
    windows: LinkedList(xlib.Window),
    // active_screen: // TODO: might be needed when moving hidden group to new screen.
                      // Should also able to get it from group windows.
                      // If there are no windows it will still be ok.
};

const Window = struct {
    id: xlib.Window,
    screen_index: c_int, // TODO: Change to screen/monitor id/name/index ???
    group_index: u8,
    // x: c_int,
    // y: c_int,
    // width: c_int,
    // height: c_int,
};

const WindowsHashMap = HashMap(c_ulong, Window, getWindowHash, comptime hash_map.getAutoEqlFn(c_ulong));

// ------- CONFIG -------
const BORDER_WIDTH = 10;
// NOTE: window width/height without border
var window_min_width: i32 = 100;
var window_min_height: i32 = 100;
var number_of_groups: u8 = 10;
var default_color: xlib.XColor = undefined;
var active_color: xlib.XColor = undefined;

pub fn main() !void {
    var active_window: ?*Window = null;
    var active_mouse_screen: c_int = undefined;

    var attr: xlib.XWindowAttributes = undefined;
    var start: xlib.XButtonEvent = undefined;
    var ev: xlib.XEvent = undefined;
    const dpy = xlib.XOpenDisplay(null);

    var dummy_win: xlib.Window = undefined;

    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    if (dpy == null) {
      return error.FailedXOpenDisplay;
    }

    var screen_count = xlib.XScreenCount(dpy);
    warn("xlib screen count: {}\n", screen_count);

    var default_screen = xlib.XDefaultScreen(dpy);
    var default_root = xlib.XDefaultRootWindow(dpy);
    var default_width: c_int = xlib.XDisplayWidth(dpy, default_screen);
    var default_height: c_int = xlib.XDisplayHeight(dpy, default_screen);

    warn("xlib screen index: {} | root id: {} | resolution: {}x{}\n\n", default_screen, default_root, default_width, default_height);


    var left_pointer = xlib.XCreateFontCursor(dpy, LeftPointer);
    _ = xlib.XDefineCursor(dpy, default_root, left_pointer);


    _ = xlib.XSelectInput(dpy, default_root, SubstructureRedirectMask|SubstructureNotifyMask|ButtonReleaseMask|PointerMotionMask);

    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"t")), Mod1Mask, default_root, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"e")), Mod1Mask, default_root, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );


    _ = xlib.XSetErrorHandler(errorHandler);


    // TODO: Implement defer
    var screens = LinkedList(Screen).init();

    var windows = WindowsHashMap.init(allocator);
    defer windows.deinit();



    // Monitor setup
    // TODO: Monitor is added/removed
    // TODO: Group/Workspace number has to be greater or equal to screen/monitor count

    // NOTE: Function 'XRRGetMonitors' requires minimum RandR version 1.5
    // This also detects 'monitors' in Xephyr test environment
    //
    // NOTE: If want to support older xrandr versions than 1.5 have to
    // use different functions: XRRGetScreenResources(Current),
    // XRRGetOutputInfo, XRRGetCrtcInfo. But these won't work in test
    // environment where Xephyr tries to emulate multi monitor setup.
    var nmon: c_int = undefined;
    const dpy_xrandr = @ptrCast(?*xrandr.Display, dpy);
    var monitor_info = xrandr.XRRGetMonitors(dpy_xrandr, default_root, xrandr.True, &nmon);
    warn("xrandr monitor count: {}\n", nmon);


    // Create groups
    var groups = ArrayList(Group).init(allocator);
    defer groups.deinit();
    // Make sure there are atleast as many groups as there are monitors
    if (number_of_groups < @intCast(u8, nmon)) number_of_groups = @intCast(u8, nmon);
    try groups.resize(number_of_groups);
    {
        var i: u8 = 0;
        while (i < number_of_groups) : (i += 1) {
            var group = Group {
                .index = i,
                .windows = LinkedList(xlib.Window).init(),
            };
            groups.set(i, group);
        }
    }


    var j: usize = 0;
    while (j < @intCast(usize, nmon)) : (j += 1) {
        // warn("{}\n", monitor_info.?[j]);
        var monitor = monitor_info.?[j];

        var screen = Screen {
            .has_mouse = (j == 0),
             // TODO: use xrandr name field instead ???
             // TODO: Change type to some other integer ???
            .index = @intCast(c_int, j),
            .groups = LinkedList(u8).init(),
            .x = monitor.x,
            .y = monitor.y,
            .width = monitor.width,
            .height = monitor.height,
            .windows = std.LinkedList(xlib.Window).init(),
        };

        var group_node = try screen.groups.createNode(@intCast(u8, j), allocator);
        screen.groups.prepend(group_node);

        var node_ptr = try screens.createNode(screen, allocator);
        screens.append(node_ptr);


        // TODO: warp mouse pointer middle of primary monitor ???
        // NOTE: Xephyr test environment doesn't have primary monitor
        if (j == 0) {
            // TODO: Set it to primary monitor ???
            active_mouse_screen = screen.index;
        }
    }

    // TODO: client communication
    // TODO: XInternAtom
    // TODO: XChangeProperty

    var net_name = xlib.XInternAtom(dpy, c"_NET_WM_NAME", xlib.False);
    var net_check = xlib.XInternAtom(dpy, c"_NET_SUPPORTING_WM_CHECK", xlib.False);
    var net_nr_of_desktops = xlib.XInternAtom(dpy, c"_NET_NUMBER_OF_DESKTOPS", xlib.False);
    var net_current_desktop = xlib.XInternAtom(dpy, c"_NET_CURRENT_DESKTOP", xlib.False);

    // Number of desktops (it doesn't have to be number of screens/monitors)
    var data = @ptrCast(?[*]const u8, &([]u8{2}));

    // Intial desktop number
    var data2 = @ptrCast(?[*]const u8, &([]u8{0}));

    // _ = xlib.XChangeProperty(dpy, default_root, net_nr_of_desktops, xatom.XA_CARDINAL, 32, xlib.PropModeReplace, data, 1);
    // _ = xlib.XChangeProperty(dpy, default_root, net_current_desktop, xatom.XA_CARDINAL, 32, xlib.PropModeReplace, data2, 1);



    // Set colors
    // TODO: color on different screens/monitors ???
    // TODO: defer XFreeColors
    _ = xlib.XAllocNamedColor(dpy, xlib.XDefaultColormap(dpy, xlib.XDefaultScreen(dpy)), c"grey", &default_color, &default_color);

    _ = xlib.XAllocNamedColor(dpy, xlib.XDefaultColormap(dpy, xlib.XDefaultScreen(dpy)), c"blue", &active_color, &active_color);



    // Add/Discover existing windows
    var children: ?[*](xlib.Window) = undefined; 
    var n_children: c_uint = undefined;

    _ = xlib.XQueryTree(dpy, default_root, &dummy_win, &dummy_win, &children, &n_children);

    warn("Existing children {}\n", n_children);
    if (children != null) {
        var i: c_uint = 0;
        while (i < n_children) : (i += 1) {
            var win_id = children.?[i];
            _ = xlib.XGetWindowAttributes(dpy, win_id, &attr);

            // Find screen that the window is on
            var node = screens.first;
            while (node != null) : (node = node.?.next) {
                var screen = node.?.data;
                var screen_width = screen.x + screen.width;
                var screen_height = screen.y + screen.height;

                if (attr.x >= screen.x and attr.x < screen_width
                    and attr.y >= screen.y and attr.y < screen_height) {
                    break;
                }
            }

            // If window isn't found on any screen put window on the first screen
            if (node == null) {
                node = screens.first;
            }

            try addWindow(dpy, win_id, attr, BORDER_WIDTH, default_color, &node.?.data, allocator, &windows, &groups);
        }
    }

    _ = xlib.XFree(children);


    // var set_attr: xlib.XSetWindowAttributes = xlib.XSetWindowAttributes {
    //     .override_redirect = xlib.True,
    // };
    // var nofocus = xlib.XCreateSimpleWindow(dpy, default_root, -10, -10, 1, 1, 0, 0, 0);

    // Set active_window
    var mouse_screen = getActiveMouseScreen(screens);
    if (mouse_screen.windows.first != null) {
        var win_id = mouse_screen.windows.first.?.data;
        warn("Set active window: {}\n", win_id);
        _ = xlib.XGetWindowAttributes(dpy, win_id, &attr);
        var event_send: xlib.XConfigureEvent = xlib.XConfigureEvent {
            .type = xlib.FocusIn,
            .event = win_id,
            .window = win_id,
            .serial = 0,
            .send_event = 1,
            .display = dpy,
            .x = attr.y,
            .y = attr.x,
            .width = attr.width,
            .height = attr.height,
            .border_width = attr.border_width,
            .above = None,
            .override_redirect = attr.override_redirect,
        };
        // TODO: try enter mask instead ???
        _ = xlib.XSendEvent(dpy, win_id, xlib.False, EnterWindowMask, @ptrCast(*xlib.XEvent, @alignCast(8, &event_send)));
    }


    start.window = 0;

    // TODO: Don't know if needed
    // _ = xlib.XFlush(dpy);
    // _ = xlib.XSync(dpy, xlib.False);


    debugScreens(screens, windows);
    debugWindows(windows);
    debugGroups(groups);

    warn("----START LOOP----\n");

    while (true) {
        _ = xlib.XNextEvent(dpy, &ev);

        //
        // Event types
        // https://tronche.com/gui/x/xlib/events/types.html
        // 


        // if (ev.type != 6) warn("{} ", ev.type);
        switch (ev.type) {
            xlib.CreateNotify => warn("create notify\n"),
            xlib.DestroyNotify => {
                warn("destroy notify\n");
                warn("\tid: {}\n", ev.xdestroywindow);

                var win = windows.get(ev.xdestroywindow.window);
                if (win == null) continue;

                var next_active_window: ?xlib.Window = null;
                var screen = getScreen(win.?.value.screen_index, screens);

                // Remove window from Group
                var group_win_node = groups.toSlice()[win.?.value.group_index].windows.first;
                while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                    if (group_win_node.?.data == win.?.value.id) {
                        groups.toSlice()[win.?.value.group_index].windows.remove(group_win_node.?);
                        groups.toSlice()[win.?.value.group_index].windows.destroyNode(group_win_node.?, allocator);
                        break;
                    }
                }

                // Remove window from Screen
                var screen_win = screen.windows.first;
                while (screen_win != null) : (screen_win = screen_win.?.next) {
                    if (screen_win.?.data == win.?.value.id) {
                        if (screen_win.?.next != null) {
                            next_active_window = screen_win.?.next.?.data;
                        }
                        screen.windows.remove(screen_win.?);
                        screen.windows.destroyNode(screen_win.?, allocator);
                        break;
                    }
                }

                _ = windows.remove(win.?.value.id);

                // Set new active window
                if (next_active_window != null) {
                    _ = xlib.XSetInputFocus(dpy, next_active_window.?, xlib.RevertToParent, CurrentTime);
                } else if (active_window != null) {
                    _ = xlib.XSetWindowBorder(dpy, active_window.?.id, default_color.pixel);
                    active_window = null;
                }


                debugScreens(screens, windows);
                debugWindows(windows);
                debugGroups(groups);
            },
            xlib.ReparentNotify => warn("reparent notify\n"),
            xlib.FocusIn => {
                // warn("focus in\n");
                // warn("\tid: {}\n", ev.xfocus);

                // NOTE: NotifyPointer makes sure unmapped window isn't re-added to
                // screen's windows list
                // NOTE: active_window check might not be needed
                if ((active_window != null and
                    active_window.?.id == ev.xfocus.window)
                    or ev.xfocus.detail == NotifyPointer) {
                    continue;
                }

                warn("focus in\n");
                // warn("\tid: {}\n", ev.xfocus);

                if (active_window != null and active_window.?.id != ev.xfocus.window) {
                    _ = xlib.XSetWindowBorder(dpy, active_window.?.id, default_color.pixel);
                }

                
                var win = windows.get(ev.xfocus.window);
                if (win != null) {
                    // Move window infront of screen stack
                    var win_screen = getScreen(win.?.value.screen_index, screens);
                    // warn("{}\n", win_screen);
                    var win_node = win_screen.windows.first;
                    while (win_node != null) : (win_node = win_node.?.next) {
                        if (win_node.?.data == ev.xfocus.window) {
                            win_screen.windows.remove(win_node.?);
                            win_screen.windows.prepend(win_node.?);
                            break;
                        }
                    }


                    // Move window infront of group stack
                    var group_index = win.?.value.group_index;
                    var group = groups.toSlice();
                    var group_win_node = group[group_index].windows.first;
                    while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                        if (group_win_node.?.data == win.?.value.id) {
                            group[group_index].windows.remove(group_win_node.?);
                            group[group_index].windows.prepend(group_win_node.?);
                            break;
                        }
                    }
                }

                _ = xlib.XSetWindowBorder(dpy, ev.xfocus.window, active_color.pixel);
                _ = xlib.XRaiseWindow(dpy, ev.xfocus.window);
                active_window = &win.?.value;                
            },
            xlib.FocusOut => {
                warn("focus out\n");
                warn("\tid: {}\n", ev.xfocus.window);
            },
            xlib.MapNotify => {
                warn("map notify\n");
            },
            xlib.UnmapNotify => {
                warn("unmap notify\n");
                // warn("{}\n", ev.xunmap);

                if (active_window == null or active_window.?.id != ev.xunmap.window) continue;


                // Remove window from screens.windows
                // TODO: Have to re-check this in connection with Groups, Window and Screens
                // var win = windows.get(ev.xunmap.window);
                // var win_screen = getScreen(win.?.value.screen_index, screens);
                // var node = win_screen.windows.first;
                // var next_active_window: ?xlib.Window = null;
                // while (node != null) : (node = node.?.next) {
                //     if (node.?.data == ev.xunmap.window) {
                //         if (node.?.next != null) {
                //             next_active_window = node.?.next.?.data;
                //         }

                //         win_screen.windows.remove(node.?);
                //         win_screen.windows.destroyNode(node.?, allocator); 

                //         break;
                //     }
                // }


                // if (next_active_window != null) {
                //     _ = xlib.XSetInputFocus(dpy, next_active_window.?, xlib.RevertToParent, CurrentTime);
                // } else {
                //     _ = xlib.XSetWindowBorder(dpy, active_window.?.id, default_color.pixel);
                // }

                // active_window = null;
            },
            xlib.ConfigureNotify => {
                // warn("configure notify\n");
            },
            xlib.EnterNotify => {
                if (start.window != 0 or 
                    ev.xcrossing.mode != xlib.NotifyNormal) {
                    continue;
                }
                warn("enter notify\n");
                warn("\tid: {}\n", ev.xcrossing);

                if (start.window == 0) {
                    _ = xlib.XSetInputFocus(dpy, ev.xcrossing.window, xlib.RevertToParent, CurrentTime);
                }
            },
            xlib.LeaveNotify => {
                // warn("{}\n", ev.xcrossing);

                if (start.window != 0 or active_window == null or 
                    ev.xcrossing.detail == xlib.NotifyInferior or
                    ev.xcrossing.detail == xlib.NotifyNonlinearVirtual) continue;
                warn("leave notify\n");

                var mouse_active = getActiveMouseScreen(screens);
                if (mouse_active.index != active_window.?.screen_index) {
                    var win = mouse_active.windows.first;
                    if (win != null) {
                        _ = xlib.XSetInputFocus(dpy, win.?.data, xlib.RevertToParent, CurrentTime);
                    } else {
                        _ = xlib.XSetWindowBorder(dpy, active_window.?.id, default_color.pixel);
                        active_window = null;
                    }
                }
            },
            xlib.MapRequest => {
                warn("map request\n");
                // warn("{}\n", ev.xmaprequest.window);

                var result = xlib.XGetWindowAttributes(dpy, ev.xmaprequest.window, &attr);
                if (result == 0 or attr.override_redirect == 1) {
                    continue;
                }

                var mouse_active = getActiveMouseScreen(screens);
                try addWindow(dpy, ev.xmaprequest.window, attr, BORDER_WIDTH, default_color, mouse_active, allocator, &windows, &groups);
                _ = xlib.XSetInputFocus(dpy, ev.xmaprequest.window, xlib.RevertToParent, CurrentTime);

                    debugScreens(screens, windows);
                    debugWindows(windows);
                    debugGroups(groups);
            },
            xlib.ConfigureRequest => {
                warn("configure request\n");
                var changes = xlib.XWindowChanges {
                    .x = ev.xconfigurerequest.x,
                    .y = ev.xconfigurerequest.y,
                    .width = ev.xconfigurerequest.width,
                    .height = ev.xconfigurerequest.height,
                    .border_width = ev.xconfigurerequest.border_width,
                    .sibling = ev.xconfigurerequest.above,
                    .stack_mode = ev.xconfigurerequest.detail,
                };

                _ = xlib.XConfigureWindow(dpy, ev.xconfigurerequest.window, @intCast(c_uint, ev.xconfigurerequest.value_mask), &changes);
            },
            xlib.ButtonPress => {
                warn("button press\n");
                // warn("{}\n", ev.xbutton);
                if (ev.xbutton.window != 0) {
                    // TODO: try to remove this get attrs function
                    _ = xlib.XGetWindowAttributes(dpy, ev.xbutton.window, &attr);
                    start = ev.xbutton;
                }
            },
            xlib.ButtonRelease => {
                warn("button release\n");

                if (start.window != 0) {
                    if (start.button == 1) {
                        var win = windows.get(start.window);
                        // Check if window was moved to another window
                        var mouse_active_screen = getActiveMouseScreen(screens);
                        if (win != null and win.?.value.screen_index != mouse_active_screen.index) {
                            // Move window to new group
                            var groups_slice = groups.toSlice();
                            var old_group_index = win.?.value.group_index;
                            var new_group_index = mouse_active_screen.groups.first.?.data;
                            var group_win_node = groups_slice[old_group_index].windows.first;
                            while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                                if (group_win_node.?.data == win.?.value.id) {
                                    groups_slice[old_group_index].windows.remove(group_win_node.?);
                                    groups_slice[new_group_index].windows.prepend(group_win_node.?);
                                    break;
                                }
                            }


                            // Change window attributes
                            // Move window to new screen
                            var win_screen = getScreen(win.?.value.screen_index, screens);
                            var node = win_screen.windows.first;
                            while (node != null) : (node = node.?.next) {
                                if (node.?.data == start.window) {
                                    win_screen.windows.remove(node.?);
                                    mouse_active_screen.windows.prepend(node.?);
                                    win.?.value.screen_index = mouse_active_screen.index;
                                    win.?.value.group_index = new_group_index;
                                    break;
                                }
                            }
                        }
                    }
                
                    start.window = 0;
                }

                debugScreenWindows(screens);
                debugWindows(windows);
                debugGroups(groups);
            },
            xlib.MotionNotify=> {
                // warn("motion notify\n");
                // warn("{}\n", ev.xmotion);

                var new_mouse_screen: ?*Screen = undefined;
                var current_mouse_active_screen = getActiveMouseScreen(screens);
                if (screens.len > 1) {
                    new_mouse_screen = checkActiveScreen(ev.xmotion.x_root, ev.xmotion.y_root, screens, current_mouse_active_screen);

                    if (new_mouse_screen != null) {
                        active_mouse_screen = new_mouse_screen.?.index;
                    }
                }


                if (start.window != 0) {
                    if (start.button == 1) {
                        if (start.state == @intCast(c_uint, Mod1Mask|ShiftMask)) {
                            var xdiff = ev.xbutton.x_root - start.x_root;
                            var ydiff = ev.xbutton.y_root - start.y_root;

                            _ = xlib.XMoveWindow(dpy, start.window,
                                          attr.x + xdiff,
                                          attr.y + ydiff);
                        }
                        else {
                            motionKeepWindowInBounds(dpy, active_mouse_screen, start, ev.xbutton, attr, screens);
                        }
                    }
                    else if (start.button == 3) {
                        if (start.state == @intCast(c_uint, Mod1Mask|ShiftMask)) {
                            var xdiff = ev.xbutton.x_root - start.x_root;
                            var ydiff = ev.xbutton.y_root - start.y_root;

                            // TODO: Fix bug that takes width/height to negative numbers
                            _ = xlib.XResizeWindow(dpy, start.window,
                                          @intCast(c_uint, attr.width + xdiff),
                                          @intCast(c_uint, attr.height + ydiff));
                        }
                        else {
                            var window = windows.get(start.window);
                            motionKeepWindowInBounds(dpy, window.?.value.screen_index, start, ev.xbutton, attr, screens);
                        }
                    }

                } else if (new_mouse_screen != null and
                    (ev.xmotion.subwindow == 0 or 
                     (active_window != null and active_window.?.id != ev.xmotion.subwindow))) {

                    // TODO: window won't loose focus if other screen has no windows
                    var new_mouse_active_screen = getScreen(new_mouse_screen.?.index, screens);
                    if (new_mouse_active_screen.windows.first != null) {
                        warn("active window\n");
                        var focus_win = new_mouse_active_screen.windows.first.?.data;
                        _ = xlib.XSetInputFocus(dpy, focus_win, xlib.RevertToParent, CurrentTime);
                    }  
                    else if (active_window != null) {
                        warn("no windows");
                        _ = xlib.XSetWindowBorder(dpy, active_window.?.id, default_color.pixel);
                        _ = xlib.XSetInputFocus(dpy, @intCast(c_ulong, xlib.PointerRoot), xlib.RevertToParent, CurrentTime);
                        active_window = null;
                    }
                }
            },
            xlib.KeyPress => {
                warn("key press\n");
                if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"e"))) {
                    // moveMouseToAnotherScreen(dpy, ev.xkey.root, screens, ev.xkey.x_root, ev.xkey.y);


                } 
                else if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"t"))) {
                    warn("open xterm\n");
                    warn("\troot id: {}\n", ev.xkey.root);
                        
                    var argv = []const []const u8{"xterm"};


                    var child_result = try child.init(argv, allocator);
                    var env_map = try os.getEnvMap(allocator);
                    // try env_map.set("DISPLAY", ":1.0");
                    child_result.env_map = env_map;
                    _ = try child.spawn(child_result);

                }
                else if (ev.xkey.window != 0) {
                    if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"F1"))) {
                    // warn("{}\n", ev.xkey);

                    // If windows focuses stretches screens
                    // - window is focused on non active screen (active mouse screen)
                    // - window is move to active mouse screen
                    // - first item of active screen becomes active

                    // TODO
                    // Move window to another screen
                    // - unfocus window
                    // - move window to other screen
                    // - find new window to focus on active screen
                    // Transform window x, y, width and height ???

                    var win = windows.get(ev.xkey.window);
                    _ = xlib.XGetWindowAttributes(dpy, ev.xkey.window, &attr);
                    warn("{}\n", attr);


                    if (win != null) {
                        // var active_screen = win.?.value.screen;
                        var active_screen = getScreen(win.?.value.screen_index, screens);
                        var next_screen: Screen = undefined;
                        var new_x: c_int = undefined;
                        var new_y: c_int = undefined;
                        warn("nr: {}\n", active_screen.index);
                        // TODO: works with two screens only
                       if (active_screen.index ==0) {
                            next_screen = screens.first.?.next.?.data;
                            new_x = next_screen.x + attr.x;
                            new_y = next_screen.y + attr.y;                        
                        }
                        else {
                            next_screen = screens.first.?.data;
                            new_x = attr.x - next_screen.x;
                            new_y = attr.y - next_screen.y;                        
                        }

                        var width_ratio = @intToFloat(f32, next_screen.width) / @intToFloat(f32, active_screen.width);
                        var height_ratio = @intToFloat(f32, next_screen.height) / @intToFloat(f32, active_screen.height);

                        var new_width = @floatToInt(c_uint, @intToFloat(f32, attr.width) * width_ratio);
                        var new_height = @floatToInt(c_uint, @intToFloat(f32, attr.height) * height_ratio);

                        var node = active_screen.windows.first;
                        while (node != null) : (node = node.?.next) {
                            if (node.?.data == win.?.value.id) {
                                active_screen.windows.remove(node.?);
                                active_screen.index = next_screen.index;
                                active_screen.windows.prepend(node.?);
                                // active_window = null;
                                break;
                            }
                        }

                        debugScreenWindows(screens);
                        debugWindows(windows);

                        warn("{} {}\n", new_x, new_y);
                        warn("{} {}\n", new_width, new_height);

                        _ = xlib.XMoveResizeWindow(dpy, win.?.value.id, new_x, new_y, new_width, new_height);

                    }

                    } else if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"w"))) {
                        var result = xlib.XGetWindowAttributes(dpy, ev.xkey.window, &attr);
                        if (result != 0) {
                            var mouse_active_screen = getActiveMouseScreen(screens);
                            setWindowInsideScreen(dpy, ev.xkey.window, attr, mouse_active_screen);
                        }
                    }
                }
            },
            xlib.ClientMessage => warn("client message\n"),
            xlib.KeyRelease => {
                warn("key release\n");
            },
            xlib.CirculateRequest => warn("circulate request\n"),
            else => warn("ignore event\n"),
        }

    }

}


fn debugMouse(dpy: ?*xlib.Display, default_root: xlib.Window) void {
    var dummy: xlib.Window = undefined;
    var child_: xlib.Window = undefined;
    var x: c_int = undefined;
    var y: c_int = undefined;
    var win_x: c_int = undefined;
    var win_y: c_int = undefined;
    var mask: c_uint = undefined;

    _ = xlib.XQueryPointer(dpy, default_root, &dummy, &child_, &x, &y, &win_x, &win_y, &mask);

    warn("\ndummy id: {}\n", dummy);
    warn("child id: {}\n", child_);
    warn("root pos: {}x{}\n", x, y);
    warn("win pos :{}x{}\n", win_x, win_y);
    // warn("{}\n", mask);
}



fn moveMouseToAnotherScreen(dpy: ?*xlib.Display, root: xlib.Window, screens: LinkedList(Screen), x: c_int, y: c_int) void {
    // TODO: separate this loop into pure function
    var new_screen: Screen = undefined;
    var node = screens.first;
    while (node != null) : (node = node.?.next) {
        if (node.?.data.has_mouse) {
            if (node.?.next != null) {
                new_screen = node.?.next.?.data;
            } else {
                new_screen = screens.first.?.data;
            }
            break;
        }
    }

    var dest_x = new_screen.x + @divTrunc(new_screen.width, 2);
    var dest_y = new_screen.y + @divTrunc(new_screen.height, 2);

    var root_attr: xlib.XWindowAttributes = undefined;
    _ = xlib.XGetWindowAttributes(dpy, root, &root_attr);

    _ = xlib.XWarpPointer(dpy, root, root, 
                          root_attr.x, root_attr.y,
                          @intCast(c_uint, root_attr.width), 
                          @intCast(c_uint, root_attr.height),
                          dest_x, dest_y,);
}




fn motionKeepWindowInBounds(dpy: ?*xlib.Display, screen_index: c_int, start: xlib.XButtonEvent, xbutton: xlib.XButtonEvent, w_attr: xlib.XWindowAttributes, screens: LinkedList(Screen)) void {
    var x: i32 = w_attr.x;
    var y: i32 = w_attr.y;
    var width: i32 = std.math.max(1, w_attr.width);
    var height: i32 = std.math.max(1, w_attr.height);
    var xdiff: c_int = xbutton.x_root - start.x_root;
    var ydiff: c_int = xbutton.y_root - start.y_root;
    var screen = getScreen(screen_index, screens);


    if (start.button == 1) {
        x += xdiff;
        y += ydiff;

        var new_win_geometry = inBoundsWindowGeometry(x, y, width, height, screen);

        if (width > screen.width) {
            new_win_geometry.x = screen.x + 1;
        }

        if (height > screen.height) {
            new_win_geometry.y = screen.y + 1;
        }

        _ = xlib.XMoveWindow(dpy, start.window, new_win_geometry.x, new_win_geometry.y);

    }
    else if (start.button == 3) {
        width = w_attr.width + xdiff;
        height = w_attr.height + ydiff;

        var new_win_geometry = inBoundsWindowGeometry(x, y, width, height, screen);

        _ = xlib.XResizeWindow(dpy, start.window,
                            std.math.max(1, @intCast(c_uint, new_win_geometry.width)),
                            std.math.max(1, @intCast(c_uint, new_win_geometry.height)));
    }
}



const WindowGeometry = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};


fn inBoundsWindowGeometry(x: i32, y: i32, width: i32, height: i32, screen: *Screen) WindowGeometry {
    var screen_width = screen.width;
    var screen_height = screen.height;
    var new_x = std.math.max(1, x - screen.x);
    var new_y = std.math.max(1, y - screen.y);
    var new_width = width;
    var new_height = height;        


    // Width and x coordinate
    var win_total_width = new_width + 2 * BORDER_WIDTH;

    if ((new_x + win_total_width) >= screen_width) {
        new_x = new_x - (new_x + win_total_width - screen_width);
        new_width = screen_width - 2 * BORDER_WIDTH - (x - screen.x) - 1;
    }

    new_x = std.math.max(1, new_x + screen.x - 1);

    if (new_width < window_min_width) {
        new_width = window_min_width;
    }


    // Height and y coordinate
    var win_total_height = new_height + 2 * BORDER_WIDTH;

    if ((new_y + win_total_height) >= screen_height) {
        new_y = new_y - (new_y + win_total_height - screen_height);
        new_height = screen_height - 2 * BORDER_WIDTH - (y - screen.y) - 1;
    }

    new_y = std.math.max(1, new_y + screen.y - 1);

    if (new_height < window_min_height) {
        new_height = window_min_height;
    }


    return WindowGeometry {
        .x = new_x,
        .y = new_y,
        .width = new_width,
        .height = new_height,
    };
}


fn setWindowInsideScreen(dpy: ?*xlib.Display, window: xlib.Window, w_attr: xlib.XWindowAttributes, screen: *Screen) void {
    var screen_width = screen.width;
    var screen_height = screen.height;
    var x = w_attr.x - screen.x;
    var y = w_attr.y - screen.y;
    var width = w_attr.width;
    var height = w_attr.height;        


    // Width and x coordinate
    var win_total_width = width + 2 * BORDER_WIDTH;

    if (win_total_width >= screen_width) {
        width = screen_width - 2 * BORDER_WIDTH - 2;
    }

    win_total_width = width + 2 * BORDER_WIDTH;

    if ((x + win_total_width) >= screen_width) {
        x = x - (x + win_total_width - screen_width) - 1;
    }

    x = std.math.max(1, x);


    // Height and y coordinate
    var win_total_height = height + 2 * BORDER_WIDTH;

    if (win_total_height >= screen_height) {
        height = screen_height - 2 * BORDER_WIDTH - 2;
    }

    win_total_height = height + 2 * BORDER_WIDTH;

    if ((y + win_total_height) >= screen_height) {
        y = y - (y + win_total_height - screen_height) - 1;
    }

    y = std.math.max(1, y);

    _ = xlib.XMoveResizeWindow(dpy, window, x + screen.x, y + screen.y, @intCast(c_uint, width), @intCast(c_uint, height));
}


fn setWindowKeyAndButtonEvents(dpy: ?*xlib.Display, win: xlib.Window) void {

    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"F1")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    // _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"e")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"w")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );


    _ = xlib.XGrabButton(dpy, 1, Mod1Mask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 1, Mod1Mask|ShiftMask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 3, Mod1Mask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 3, Mod1Mask|ShiftMask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);


    _ = xlib.XSelectInput(dpy, win, EnterWindowMask|LeaveWindowMask|FocusChangeMask|SubstructureNotifyMask);

}



extern fn errorHandlerStart(dpy: ?*xlib.Display, e: *xlib.XErrorEvent) c_int {
    return -1;
}

extern fn errorHandler(dpy: ?*xlib.Display, e: *xlib.XErrorEvent) c_int {
    warn("error handler\n");

    if (e.error_code == xlib.BadWindow) {
        warn("ERROR: BadWindow\n");
        return 0;
    }

    return errorHandlerStart(dpy, e);
}



fn checkActiveScreen(x: c_int, y: c_int, screens: LinkedList(Screen), active_screen: *Screen) ?*Screen {
    var screen = screens.first;
    while (screen != null) : (screen = screen.?.next) {
        if (screen.?.data.index == active_screen.index) continue;
        if (isPointerInScreen(screen.?.data, x, y)) { 
            warn("Change screen {}\n", screen.?.data.index);
            active_screen.has_mouse = false;
            screen.?.data.has_mouse = true;
            return &screen.?.data;
        }
    }

    return null;
}


fn isPointerInScreen(screen: Screen, x: c_int , y: c_int) bool {
    var screen_x_right = screen.x + screen.width;
    var screen_y_right = screen.y + screen.height;

    return (x >= screen.x)  and (x <= screen_x_right) 
            and (y >= screen.y) and (y <= screen_y_right);
}


fn debugScreens(screens: LinkedList(Screen), windows: WindowsHashMap) void {
    var item = screens.first;
    warn("\n----Screens----\n");
    while (item != null) : (item = item.?.next) {
        var screen = item.?.data;
        warn("Screen |> index: {}", screen.index);
        warn(" | groups:");
        debugGroupsArray(screen.groups);
        warn(" | windows:");
        debugWindowsList(screen.windows, windows);
        warn("\n");
    }
}

fn debugWindowsList(screen_windows: LinkedList(xlib.Window), windows: WindowsHashMap) void {
    var item = screen_windows.first;
    while (item != null) : (item = item.?.next) {
        var win = windows.get(item.?.data);
        if (win != null) {
            warn(" {}({})", item.?.data, win.?.value.group_index);
        }
    }
}

fn debugGroupsArray(groups: LinkedList(u8)) void {
    var group_node = groups.first;
    while (group_node != null) : (group_node = group_node.?.next) {
        warn(" {}", group_node.?.data);
    }
}


// TODO: remove ???
fn debugScreenWindows(ll: LinkedList(Screen)) void {
    var item = ll.first;
    warn("\n----Screens----\n");
    while (item != null) : (item = item.?.next) {
        warn("Screen: {} | has_mouse: {}\n", item.?.data.index, item.?.data.has_mouse);
       warn("\twindows:");
        var w_node = item.?.data.windows.first;
        while (w_node != null) : (w_node = w_node.?.next) {
            warn(" {}", w_node.?.data);
        }
        warn("\n");
    }
}


fn addWindow(dpy: ?*xlib.Display, win: xlib.Window, win_attr: xlib.XWindowAttributes, border_width: c_uint, border_color: xlib.XColor, screen: *Screen, allocator: *Allocator, windows: *WindowsHashMap, group: *ArrayList(Group)) !void {
    _ = xlib.XSetWindowBorder(dpy, win, border_color.pixel);
    _ = xlib.XSetWindowBorderWidth(dpy, win, border_width);

    // // Spawn location is middle of screen
    // var x = @divExact(active_screen.width, 2) - @divExact(attr.width, 2) - BORDER_WIDTH + active_screen.x;
    // var y = @divExact(active_screen.height, 2) - @divExact(attr.height, 2) - BORDER_WIDTH + active_screen.y;


    // // TODO: Spawn window where ever I want
    // // Might have to pass x and y as parameters
    setWindowInsideScreen(dpy, win, win_attr, screen);


    setWindowKeyAndButtonEvents(dpy, win);
    _ = xlib.XRaiseWindow(dpy, win);

    var group_index = blk: {

        var first_window = screen.windows.first;
        if (first_window != null) {
            var win_info = windows.get(first_window.?.data);
            if (win_info != null) {
                break :blk win_info.?.value.group_index;
            } else {
                break :blk screen.groups.first.?.data;
            }
        } else {
            break :blk screen.groups.first.?.data;
        }
    };
    warn("index: {}", group_index);

    var new_window = Window {
        .id = win,
        .screen_index = screen.index,
        .group_index = group_index,
    };

    // Add to windows hash map
    // TODO: fn putOrGet ???
    _ = try windows.put(win, new_window);
    var kv = windows.get(win);

    // Add to screen's linked list windows attribute
    // NOTE: screen.windows and group.windows share nodes
    var win_node = try screen.windows.createNode(win, allocator);
    screen.windows.prepend(win_node);
    var group_win_node = try group.toSlice()[group_index].windows.createNode(win, allocator);
    group.toSlice()[group_index].windows.prepend(group_win_node);

    _ = xlib.XMapWindow(dpy, win);
}


fn getWindowHash(id: c_ulong) u32 {
            return @intCast(u32, id);
}


fn debugWindows(windows: WindowsHashMap) void {
    var iter = windows.iterator();
    var item = iter.next();
    warn("\n----Windows----\n");
    while (item != null) : (item = iter.next()) {
        warn("Window |> ");
        warn("id: {} | screen: {} | group: {}\n", item.?.value.id, item.?.value.screen_index, item.?.value.group_index);
   }
}



fn getScreen(screen_index: c_int, screens: LinkedList(Screen)) *Screen {
    var window_screen_node = screens.first;
    while (window_screen_node != null) : (window_screen_node = window_screen_node.?.next) {
        if (window_screen_node.?.data.index == screen_index) {
            break;
        }
    }

    return &window_screen_node.?.data;
}


fn getActiveMouseScreen(screens: LinkedList(Screen)) *Screen {
    var node = screens.first;
    while (node != null) : (node = node.?.next) {
        if (node.?.data.has_mouse) break;
    }

    return &node.?.data;
}

fn debugGroups(groups: ArrayList(Group)) void {
    warn("\n----Groups----\n");
    for (groups.toSliceConst()) |group| {
        warn("Group {} | windows:", group.index);
        var win = group.windows.first;
        while (win != null) : (win = win.?.next) {
            warn(" {}", win.?.data);
        }
        warn("\n");
    }
}
