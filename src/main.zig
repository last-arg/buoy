// use "./debug.zig".; // TODO: move debug functions to its own file
const std = @import("std");
const fmt = std.fmt;
const cstr = std.cstr;
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
var window_min_width: i32 = 100; // NOTE: without border
var window_min_height: i32 = 100; // NOTE: without border
var number_of_groups: u8 = 10;
var default_color: xlib.XColor = undefined;
var active_color: xlib.XColor = undefined;

var group_cstrings: []const [*]const u8 = undefined;

pub fn main() !void {
    var active_window: ?*Window = null;
    var attr: xlib.XWindowAttributes = undefined;
    var start: xlib.XButtonEvent = undefined;
    var ev: xlib.XEvent = undefined;
    const dpy = xlib.XOpenDisplay(null);

    var dummy_win: xlib.Window = undefined;
    var exact_color: xlib.XColor = undefined;

    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    if (dpy == null) {
      return error.FailedToOpenDisplay;
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


    // TODO: Replace/Remove hardcoded c string values.
    // @GroupKeys
    group_cstrings = []const [*]const u8{c"1", c"2", c"3", c"4", c"5", c"6", c"7", c"8", c"9", c"0"};
    {
        // TODO: convert number to string and string to c string
        // var buffer: [1]u8 = undefined;
        // var buf = buffer[0..];
        // var i: u8 = 0;
        // while (i < number_of_groups) : (i += 0) {
        for (group_cstrings) |str| {
            // _ = fmt.formatIntBuf(buf, i, 10, false, 0);
            // var key_str = try cstr.addNullByte(allocator, buf);
            _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(str)), Mod1Mask, default_root, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );
        }
    }

    _ = xlib.XSetErrorHandler(errorHandler);


    // TODO: Implement defer
    var screens = LinkedList(Screen).init();

    var windows = WindowsHashMap.init(allocator);
    defer windows.deinit();


    // Monitor setup
    // TODO: Monitor is added/removed

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
            // TODO: use primary monitor attribute to set has_mouse
            // TODO: warp mouse pointer middle of primary monitor ???
            // NOTE: Xephyr test environment doesn't have primary monitor
            .has_mouse = (j == 1),
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
    // NOTE: exact_color returns exact RGB values
    // default/active_color return closest hardware RGB values
    var default_colormap = xlib.XDefaultColormap(dpy, xlib.XDefaultScreen(dpy));
    _ = xlib.XAllocNamedColor(dpy, default_colormap, c"grey", &default_color, &exact_color);

    _ = xlib.XAllocNamedColor(dpy, default_colormap, c"blue", &active_color, &exact_color);
    defer {
        _ = xlib.XFreeColors(dpy, default_colormap, &default_color.pixel, 1, 0);
        _ = xlib.XFreeColors(dpy, default_colormap, &active_color.pixel, 1, 0);
    }


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
    if (getActiveMouseScreen(screens).windows.first) |screen_win_node| {
        var win_id = screen_win_node.data;
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
        switch (ev.type) {
            xlib.CreateNotify => {
                warn("create notify\n");
            },
            xlib.DestroyNotify => {
                warn("destroy notify\n");
                warn("\tid: {}\n", ev.xdestroywindow);

                var win = windows.get(ev.xdestroywindow.window);
                if (win == null) continue;

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
                        screen.windows.remove(screen_win.?);
                        screen.windows.destroyNode(screen_win.?, allocator);
                        break;
                    }
                }

                // Remove group from Screen
                // TODO: remove group from Screen if no windows in Group ???
                // TODO: At the moment code removes group even if there are more
                // windows in that group.
                // if (screen.groups.len > 1) {
                //     var screen_group = screen.groups.first;
                //     while (screen_group != null) : (screen_group = screen_group.?.next) {
                //         if (screen_group.?.data == win.?.value.group_index) {
                //             screen.groups.remove(screen_group.?);
                //             screen.groups.destroyNode(screen_group.?, allocator);
                //             break;
                //         }
                //     }
                // }

                // Remove window from windows hash map
                _ = windows.remove(win.?.value.id);

                // Set new active window
                updateFocus(dpy, null, screen.windows.first, default_color, active_color);
                debugScreens(screens, windows);
                debugWindows(windows);
                debugGroups(groups);
            },
            xlib.ReparentNotify => warn("reparent notify\n"),
            xlib.FocusIn => {
                warn("focus in\n");
                // warn("\tid: {}\n", ev.xfocus);
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
            },
            xlib.ConfigureNotify => {
                // warn("configure notify\n");
            },
            xlib.EnterNotify => {
                if (start.window != 0 or
                    ev.xcrossing.detail == xlib.NotifyInferior or
                    ev.xcrossing.mode != xlib.NotifyNormal) {
                    continue;
                }

                warn("enter notify\n");
                warn("\tid: {}\n", ev.xcrossing);

// TODO: Can maybe remove ???
                if (start.window == 0) {
                    var win = windows.get(ev.xcrossing.window);
                    var active_mouse_screen = getActiveMouseScreen(screens);
                    var old_active_window = active_mouse_screen.windows.first;

                    if (win == null or (old_active_window != null and ev.xcrossing.window == old_active_window.?.data)) continue;


                    // Move window infront of Screen windows
                    var win_screen = getScreen(win.?.value.screen_index, screens);
                    var win_node = win_screen.windows.first;
                    while (win_node != null) : (win_node = win_node.?.next) {
                        if (win_node.?.data == ev.xfocus.window) {
                            win_screen.windows.remove(win_node.?);
                            win_screen.windows.prepend(win_node.?);
                            break;
                        }
                    }

                    // Move group index infront of Screen groups
                    var group_node = win_screen.groups.first;
                    if (win_screen.groups.len > 1 and group_node.?.data != win.?.value.group_index) {
                        while (group_node != null) : (group_node = group_node.?.next) {
                            if (group_node.?.data == win.?.value.group_index) {
                                win_screen.groups.remove(group_node.?);
                                win_screen.groups.prepend(group_node.?);
                                break;
                            }
                        }
                    }

                    // Move window infront of Group windows
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

                    // Update focus
                    updateFocus(dpy, old_active_window, active_mouse_screen.windows.first, default_color, active_color);
                }
            },
            xlib.LeaveNotify => {
                warn("leave notify\n");
            },
            xlib.MapRequest => {
                warn("map request\n");
                // warn("{}\n", ev.xmaprequest.window);

                var result = xlib.XGetWindowAttributes(dpy, ev.xmaprequest.window, &attr);
                if (result == 0 or attr.override_redirect == 1) {
                    continue;
                }

                if (!windows.contains(ev.xmaprequest.window)) {
                    var mouse_active = getActiveMouseScreen(screens);
                    var old_active_window = mouse_active.windows.first;
                    try addWindow(dpy, ev.xmaprequest.window, attr, BORDER_WIDTH, default_color, mouse_active, allocator, &windows, &groups);

                    _ = xlib.XMapWindow(dpy, ev.xmaprequest.window);

                    // Update focus
                    updateFocus(dpy, old_active_window, mouse_active.windows.first, default_color, active_color);




                }

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

                // Check for screen/monitor change
                var current_mouse_active_screen = getActiveMouseScreen(screens);
                var old_active_window = current_mouse_active_screen.windows.first;
                var has_active_screen_changed = hasActiveScreenChanged(ev.xmotion.x_root, ev.xmotion.y_root, screens, current_mouse_active_screen);

                if (has_active_screen_changed) {
                    current_mouse_active_screen = getActiveMouseScreen(screens);
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
                            motionKeepWindowInBounds(dpy, current_mouse_active_screen.index, start, ev.xbutton, attr, screens);
                        }
                    }
                    else if (start.button == 3) {
                        if (start.state == @intCast(c_uint, Mod1Mask|ShiftMask)) {
                            var xdiff = ev.xbutton.x_root - start.x_root;
                            var ydiff = ev.xbutton.y_root - start.y_root;

                            var new_width = attr.width + xdiff;
                            if (new_width < window_min_width) {
                                new_width = window_min_width;
                            }
                            var new_height = attr.height + ydiff;
                            if (new_height < window_min_height) {
                                new_height = window_min_height;
                            }
                            _ = xlib.XResizeWindow(dpy, start.window,
                                                   @intCast(c_uint, new_width),
                                                   @intCast(c_uint, new_height));
                        }
                        else {
                            var window = windows.get(start.window);
                            motionKeepWindowInBounds(dpy, window.?.value.screen_index, start, ev.xbutton, attr, screens);
                        }
                    }

                } else if (has_active_screen_changed and
                    ev.xmotion.subwindow == 0) {

                    // NOTE: Have to make sure old screen's active window looses active
                    // color.
                    // TODO: Do I want the window to loose focus if there is no window
                    // in the new window ???
                    if (old_active_window) |old_win| {
                        _ = xlib.XSetWindowBorder(dpy, old_win.data, default_color.pixel);
                    }
                    updateFocus(dpy, null, current_mouse_active_screen.windows.first, default_color, active_color);
                }
            },
            xlib.KeyPress => {
                warn("key press\n");
                // warn("{}\n", ev.xkey);

                if (default_root == ev.xkey.window) {
                    // Root window events
                    if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"e"))) {
                        // moveMouseToAnotherScreen(dpy, ev.xkey.root, screens, ev.xkey.x_root, ev.xkey.y);

                    } else if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"t"))) {
                        warn("open xterm\n");
                            
                        var argv = []const []const u8{"xterm"};

                        var child_result = try child.init(argv, allocator);
                        var env_map = try os.getEnvMap(allocator);
                        child_result.env_map = env_map;
                        _ = try child.spawn(child_result);

                    } else {
                        // TODO: change this to window's active screen ???
                        // More accurate would be to say that active screen
                        // would have top priority over mouse active screen
                        var active_mouse_screen = getActiveMouseScreen(screens);
                        var screen_group_node = active_mouse_screen.groups.first;
                        var old_active_window = active_mouse_screen.windows.first;


                        // TODO: @GroupKeys
                        for (group_cstrings) |c_str, i| {
                            if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c_str))) {
                                // TODO: check selected group status
                                // Based on status group can be:
                                // - move to the front
                                // - hidden/remove from screen/monitor
                                // - displayed
                                warn("group status: {}\n", i);

                                var win = blk: {
                                    if (active_mouse_screen.windows.first != null) {
                                        break :blk windows.get(active_mouse_screen.windows.first.?.data);
                                    }
                                    break :blk null;
                                };


                                if (active_mouse_screen.groups.len > 1 and
                                    ((win != null and win.?.value.group_index == i) or
                                     (win == null and active_mouse_screen.groups.first.?.data == i))) {

warn("-----HIDE WINDOWS----\n");
                                    // Remove group from Screen
                                    while (screen_group_node != null) : (screen_group_node = screen_group_node.?.next) {
                                        if (screen_group_node.?.data == i) {
                                            active_mouse_screen.groups.remove(screen_group_node.?);
                                            active_mouse_screen.groups.destroyNode(screen_group_node.?, allocator);
                                            break;
                                        }
                                    }
                                    // Remove windows from Screen.windows list
                                    var node = active_mouse_screen.windows.first;
                                    while (node != null) : (node = node.?.next) {
                                        var win_info = windows.get(node.?.data);
                                        if (win_info != null and win_info.?.value.group_index == i) {
                                            _ = xlib.XUnmapWindow(dpy, win_info.?.value.id);
                                            active_mouse_screen.windows.remove(node.?);
                                            active_mouse_screen.windows.destroyNode(node.?, allocator);
                                        }
                                    }

                                    // New active window
                                    updateFocus(dpy, old_active_window, active_mouse_screen.windows.first, default_color, active_color);
                                } else {
                                    warn("-----RAISE WINDOWS----\n");

                                    // TODO: check if other Screen groups have group
                                    var new_node: ?*LinkedList(u8).Node = null;
                                    while (screen_group_node != null) : (screen_group_node = screen_group_node.?.next) {
                                        if (screen_group_node.?.data == i) {
                                            new_node = screen_group_node.?;
                                            active_mouse_screen.groups.remove(screen_group_node.?);
                                            break;
                                        }
                                    }

                                    if (new_node == null) {
                                        new_node = try active_mouse_screen.groups.createNode(@intCast(u8, i), allocator);

                                        warn("new node \n");
                                        var group_win_node = groups.at(i).windows.last;
                                        while (group_win_node != null) : (group_win_node = group_win_node.?.prev) {
                                            var new_win_node = try active_mouse_screen.windows.createNode(group_win_node.?.data, allocator);
                                            active_mouse_screen.windows.prepend(new_win_node);
                                            _ = xlib.XMapWindow(dpy, group_win_node.?.data);
                                            _ = xlib.XRaiseWindow(dpy, group_win_node.?.data);

                                        }
                                    } else {
                                        warn("old node \n");
                                        var group_win_node = groups.at(i).windows.last;
                                        while (group_win_node != null) : (group_win_node = group_win_node.?.prev) {
                                            warn("raise old: {}\n", group_win_node.?.data);
                                            _ = xlib.XRaiseWindow(dpy, group_win_node.?.data);
                                            // TODO: Make it more efficient.
                                            // Try to make it into one loop
                                            var win_node = active_mouse_screen.windows.first;
                                            while (win_node != null) : (win_node = win_node.?.next) {
                                                if (win_node.?.data == group_win_node.?.data) {
                                                    active_mouse_screen.windows.remove(win_node.?);
                                                    active_mouse_screen.windows.prepend(win_node.?);
                                                    break;
                                                }
                                            }
                                        }
                                    }

                                    active_mouse_screen.groups.prepend(new_node.?);

                                    updateFocus(dpy, old_active_window, active_mouse_screen.windows.first, default_color, active_color);
                                }

                                break;
                            }

                        }

                        debugScreens(screens, windows);
                    }
                } else if (windows.contains(ev.xkey.window)) {
                    // General window events
                    if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"F1"))) {
                        // Test
                        warn("window event\n");
                    } else if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"w"))) {
                        var result = xlib.XGetWindowAttributes(dpy, ev.xkey.window, &attr);
                        if (result != 0) {
                            var mouse_active_screen = getActiveMouseScreen(screens);
                            setWindowInsideScreen(dpy, ev.xkey.window, attr, mouse_active_screen);
                        }
                    } else {
                        // TODO: @GroupKeys
                        for (group_cstrings) |str, i| {
                            if (ev.xkey.keycode == xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(str))) {
                                warn("move window to group: {}\n", i);
                                break;
                            }
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

    // Keyboard
    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"F1")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    // _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"e")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(c"w")), Mod1Mask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );

    // TODO: @GroupKeys
    for (group_cstrings) |str| {
        _ = xlib.XGrabKey(dpy, xlib.XKeysymToKeycode(dpy, xlib.XStringToKeysym(str)), Mod1Mask|ShiftMask, win, xlib.True, xlib.GrabModeAsync, xlib.GrabModeAsync, );
    }


    // Mouse 
    _ = xlib.XGrabButton(dpy, 1, Mod1Mask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 1, Mod1Mask|ShiftMask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 3, Mod1Mask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);

    _ = xlib.XGrabButton(dpy, 3, Mod1Mask|ShiftMask, win, xlib.True, ButtonPressMask|ButtonReleaseMask|PointerMotionMask, xlib.GrabModeAsync, xlib.GrabModeAsync, 0, 0);


    _ = xlib.XSelectInput(dpy, win, EnterWindowMask|SubstructureNotifyMask);
    // _ = xlib.XSelectInput(dpy, win, EnterWindowMask|LeaveWindowMask|FocusChangeMask|SubstructureNotifyMask);



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



fn hasActiveScreenChanged(x: c_int, y: c_int, screens: LinkedList(Screen), active_screen: *Screen) bool {
    var screen = screens.first;
    while (screen != null) : (screen = screen.?.next) {
        if (screen.?.data.index == active_screen.index) continue;
        if (isPointerInScreen(screen.?.data, x, y)) { 
            warn("Change screen {}\n", screen.?.data.index);
            active_screen.has_mouse = false;
            screen.?.data.has_mouse = true;
            return true;
        }
    }

    return false;
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
    // _ = xlib.XRaiseWindow(dpy, win);

    var group_index = blk: {

        // TODO: remove ???
        // var first_window = screen.windows.first;
        // if (first_window != null) {
        //     var win_info = windows.get(first_window.?.data);
        //     if (win_info != null) {
        //         break :blk win_info.?.value.group_index;
        //     } else {
        //         break :blk screen.groups.first.?.data;
        //     }
        // } else {
            break :blk screen.groups.first.?.data;
        // }
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

    // _ = xlib.XMapWindow(dpy, win);
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




fn updateFocus(dpy: ?*xlib.Display, old_node: ?*LinkedList(xlib.Window).Node, new_node: ?*LinkedList(xlib.Window).Node, default: xlib.XColor, active: xlib.XColor) void {

    if (new_node) |new_win| {
        if (old_node) |old_win| {
            _ = xlib.XSetWindowBorder(dpy, old_win.data, default.pixel);
        }

        _ = xlib.XSetWindowBorder(dpy, new_win.data, active.pixel);
        _ = xlib.XSetInputFocus(dpy, new_win.data, xlib.RevertToParent, CurrentTime);
        _ = xlib.XRaiseWindow(dpy, new_win.data);
    }
}
