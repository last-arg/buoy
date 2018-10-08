// TODO: Try to remove/replace xlib functions
// XStringToKeysym
// TODO: Monitor/Screen is added/removed
// TODO: maybe it is possible to combine functions getWindowGeometryInside and inBoundsWindowGeometry

// use @import("debug.zig"); // TODO: move debug functions to its own file
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

// NOTE: At the bottom of the file there are manually imported external wrapper functions
use @cImport({
    @cInclude("xcb/xcb.h");
    @cInclude("xcb/xcb_keysyms.h");
    @cInclude("xcb/randr.h");
});


// NOTE: Add underscore to avoid redefinition error
const _XCB_EVENT_MASK_BUTTON_PRESS = 4;
const _XCB_EVENT_MASK_BUTTON_RELEASE = 8;
const _XCB_MOD_MASK_SHIFT = 1;
const _XCB_MOD_MASK_1 = 8;
const _XCB_MOD_MASK_2 = 16;
const _XCB_GRAB_MODE_SYNC = 0;
const _XCB_GRAB_MODE_ASYNC = 1;
const XCB_NONE = 0;
const XCB_NO_SYMBOL = 0;
const _XCB_EVENT_MASK_ENTER_WINDOW = 16;
const _XCB_EVENT_MASK_POINTER_MOTION = 64;
const _XCB_EVENT_MASK_EXPOSURE = 32768;
const _XCB_EVENT_MASK_BUTTON_MOTION = 8192;
const _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY = 524288;
const _XCB_TIME_CURRENT_TIME = 0;

const _XCB_BUTTON_INDEX_ANY = 0;
const _XCB_BUTTON_INDEX_1 = 1;
const _XCB_BUTTON_INDEX_2 = 2;
const _XCB_BUTTON_INDEX_3 = 3;

const _XCB_CW_BACK_PIXEL = 2;
const _XCB_CW_EVENT_MASK = 2048;
const _XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT = 1048576;
const _XCB_CW_BORDER_PIXMAP = 4;

const _XCB_CONFIG_WINDOW_X = 1;
const _XCB_CONFIG_WINDOW_Y = 2;
const _XCB_CONFIG_WINDOW_WIDTH = 4;
const _XCB_CONFIG_WINDOW_HEIGHT = 8;
const _XCB_CONFIG_WINDOW_BORDER_WIDTH = 16;
const _XCB_CONFIG_WINDOW_SIBLING = 32;
const _XCB_CONFIG_WINDOW_STACK_MODE = 64;
const _XCB_GRAB_ANY = 0;
const _XCB_GC_FOREGROUND = 4;
const _XCB_CW_BORDER_PIXEL = 8;


const Screen = struct {
    id: u32, // TODO: or use somekind of id ???
    has_mouse: bool,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
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
    screen_id: u32, // TODO: Change to screen/monitor id/name/index ???
    group_index: u8,
    // x: c_int,
    // y: c_int,
    // width: c_int,
    // height: c_int,
};

const WindowGeometry = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};


const WindowsHashMap = HashMap(c_ulong, Window, getWindowHash, comptime hash_map.getAutoEqlFn(c_ulong));




pub fn main() !void {
    // ------- CONFIG -------
    const BORDER_WIDTH: u16 = 10;
    var window_min_width: u16= 100; // NOTE: without border
    var window_min_height: u16 = 100; // NOTE: without border
    var group_count: u8 = 10;
    var screen_padding: u16 = 2;
    // var active_color: xlib.XColor = undefined;
    // var group_cstrings: []const [*]const u8 = undefined;

    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    var dpy = xcb_connect(null, null);
    if (xcb_connection_has_error(dpy) > 0) return error.FailedToOpenDisplay;

    var return_screen: xcb_screen_iterator_t = undefined;
    _ = _xcb_setup_roots_iterator(xcb_get_setup(dpy), &return_screen);
    warn("{}\n", return_screen.data.?[0]);

    var screen_data = return_screen.data.?[0];
    var screen_root = return_screen.data.?[0].root;

    var return_cookie: xcb_void_cookie_t = undefined;

    var value_list = []c_uint{
        _XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT
        | _XCB_EVENT_MASK_POINTER_MOTION
        // | _XCB_EVENT_MASK_EXPOSURE
        // | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
    };
    _ = _xcb_change_window_attributes(dpy, screen_root, _XCB_CW_EVENT_MASK, @ptrCast(?*const c_void, &value_list), &return_cookie);


    // Set keyboard and mouse events
    {
        var key_symbols = xcb_key_symbols_alloc(dpy);
        var t_keysym = xlib.XStringToKeysym(c"t");
        var t_keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, t_keysym)).?[0];
        _ = _xcb_grab_key(dpy, 1, screen_root, _XCB_MOD_MASK_1, t_keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_cookie);

        xcb_key_symbols_free(key_symbols);
    }

    // Set colors
    var return_grey_color_cookie: xcb_alloc_named_color_cookie_t = undefined;
    var return_blue_color_cookie: xcb_alloc_named_color_cookie_t = undefined;
    var default_color_cookie = _xcb_alloc_named_color(dpy, screen_data.default_colormap, 4, c"grey", &return_grey_color_cookie);

    var active_color_cookie = _xcb_alloc_named_color(dpy, screen_data.default_colormap, 4, c"blue", &return_blue_color_cookie);
    var default_color_reply = xcb_alloc_named_color_reply(dpy, return_grey_color_cookie, null);
    var active_color_reply = xcb_alloc_named_color_reply(dpy, return_blue_color_cookie, null);

    var default_border_color = default_color_reply.?[0].pixel;
    var active_border_color = active_color_reply.?[0].pixel;

    
    // Setup: Screens, Groups, Windows

    // NOTE: Function 'XRRGetMonitors/xcb_randr_get_monitors' requires minimum RandR version 1.5
    // This also detects 'monitors' in Xephyr test environment
    //
    // NOTE: If want to support older xrandr versions than 1.5 have to
    // use different functions: XRRGetScreenResources(Current),
    // XRRGetOutputInfo, XRRGetCrtcInfo. But these won't work in test
    // environment where Xephyr tries to emulate multi monitor setup.
    var return_monitor_cookie: xcb_randr_get_monitors_cookie_t = undefined;
    _ = _xcb_randr_get_monitors(dpy, screen_root, 1, &return_monitor_cookie);
    var monitors = xcb_randr_get_monitors_reply(dpy, return_monitor_cookie, null);
    var number_of_monitors = monitors.?[0].nMonitors;

    // Create Groups
    var groups = ArrayList(Group).init(allocator);
    defer groups.deinit();
    // Make sure there are atleast as many groups as there are monitors
    if (group_count < @intCast(u8, number_of_monitors)) group_count = @intCast(u8, number_of_monitors);
    try groups.resize(group_count);
    {
        var i: u8 = 0;
        while (i < group_count) : (i += 1) {
            var group = Group {
                .index = i,
                .windows = LinkedList(xlib.Window).init(),
            };
            groups.set(i, group);
        }
    }

    // Create Screens
    // TODO: Implement defer
    var screens = LinkedList(Screen).init();
    // TODO: implement fallback (else branch)
    if (number_of_monitors > 0) {
        // Pointer/Mouse location
        var return_pointer: xcb_query_pointer_cookie_t = undefined;
        _ = _xcb_query_pointer(dpy, screen_root, &return_pointer);
        var pointer_reply = xcb_query_pointer_reply(dpy, return_pointer, null);
        var pointer = pointer_reply.?[0];
        warn("{}\n", pointer);

        var j: u8 = 0;
        var return_monitors_iter: xcb_randr_monitor_info_iterator_t = undefined;
        _ = _xcb_randr_get_monitors_monitors_iterator(monitors, &return_monitors_iter);
        while (return_monitors_iter.rem != 0) : ({
            _ = xcb_randr_monitor_info_next(@ptrCast(?[*]struct_xcb_randr_monitor_info_iterator_t ,&return_monitors_iter));
            j += 1;
        }) {
            var monitor = return_monitors_iter.data.?[0];

            // TODO: what every result is false
            // Solution: warp pointer to a screen and set it true.
            // This has to take place after this while loop
            var has_mouse = (pointer.root_x >= monitor.x
                and pointer.root_x <= (monitor.x + @intCast(i16, monitor.width))
                and pointer.root_y >= monitor.y
                and pointer.root_y <= (monitor.y + @intCast(i16, monitor.height)));

            warn("{}\n", has_mouse);
            var screen = Screen {
                // NOTE: Xephyr test environment doesn't have primary monitor
                .has_mouse = has_mouse,
                .id = monitor.name,
                .groups = LinkedList(u8).init(),
                .x = monitor.x,
                .y = monitor.y,
                .width = monitor.width,
                .height = monitor.height,
                .windows = std.LinkedList(xlib.Window).init(),
            };
            
            var group_node = try screen.groups.createNode(j, allocator);
            screen.groups.prepend(group_node);

            var node_ptr = try screens.createNode(screen, allocator);
            screens.append(node_ptr);
        }
    }

    std.c.free(@ptrCast(*c_void, &monitors.?[0]));

    // Add existing windows
    var windows = WindowsHashMap.init(allocator);
    defer windows.deinit();

    {
        var return_tree: xcb_query_tree_cookie_t = undefined;
        _ = _xcb_query_tree(dpy, screen_root, &return_tree);
        var tree_reply = xcb_query_tree_reply(dpy, return_tree, null);
        var children = xcb_query_tree_children(tree_reply);
        var children_count = tree_reply.?[0].children_len;

        var event_mask: u32 = _XCB_CW_BORDER_PIXEL | _XCB_CW_EVENT_MASK;
        var values = []u32{default_border_color, _XCB_EVENT_MASK_ENTER_WINDOW};
        var i: u16 = 0;
        while (i < children_count) : (i+=1) {
            warn("{}\n", children.?[i]);
            var win = children.?[i];
            // TODO: find in which screen window is.
            // Fallback to first or primary screen.
            var active_screen = &screens.first.?.data;
            var group_index = active_screen.groups.first.?.data;
            var group = &groups.toSlice()[group_index];

            _ = _xcb_change_window_attributes(dpy, win, event_mask, @ptrCast(?*const c_void, &values), &return_cookie);

            configureWindow(dpy, win, BORDER_WIDTH, default_border_color);
            resizeAndMoveWindow(dpy, win, active_screen, screen_padding, BORDER_WIDTH);
            setWindowEvents(dpy, win, screen_root);
            _ = addWindow(allocator, win, active_screen, group, &windows);

        }

        // TODO: focus first window
    }

    debugScreens(screens, windows);
    debugWindows(windows);
    debugGroups(groups);

    _ = xcb_flush(dpy);

    while (true) {
        var ev = xcb_wait_for_event(dpy).?[0];
        // warn("{}\n", ev.?[0]);
        var res_type = ev.response_type & ~u8(0x80);
        switch (res_type) {
            XCB_CONFIGURE_REQUEST => {
                warn("xcb: configure request\n");
                var e = @ptrCast(*xcb_configure_request_event_t, &ev);
                warn("{}\n", e);

                var i: u8 = 0;
                var config_mask: u16 = 0;
                var config_values: [7]i32 = undefined;
                var win = e.window;
                // warn("{}\n", e);

                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_X);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_X) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_X;
                    config_values[i] = e.x;
                    i += 1;
                }
                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_Y);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_Y) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_Y;
                    config_values[i] = e.y;
                    i += 1;
                }
                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_WIDTH);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_WIDTH) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_WIDTH;
                    config_values[i] = e.width;
                    i += 1;
                }
                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_HEIGHT);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_HEIGHT) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_HEIGHT;
                    config_values[i] = e.height;
                    i += 1;
                }

                config_mask = config_mask | _XCB_CONFIG_WINDOW_BORDER_WIDTH;
                config_values[i] = BORDER_WIDTH;
                i += 1;

                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_SIBLING);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_SIBLING) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_SIBLING;
                    config_values[i] = @intCast(i32, e.sibling);
                    i += 1;
                }

                // warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_STACK_MODE);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_STACK_MODE) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_STACK_MODE;
                    config_values[i] = e.stack_mode;
                    i += 1;
                }

                var return_pointer: xcb_void_cookie_t = undefined;
                _ = _xcb_configure_window(dpy, win, config_mask, @ptrCast(?*const c_void, &config_values), &return_pointer);


                // var return_cookie: xcb_void_cookie_t = undefined;
                var attr_mask: u16 = _XCB_CW_BORDER_PIXEL | _XCB_CW_EVENT_MASK;
                var attr_values = []u32{default_border_color, _XCB_EVENT_MASK_ENTER_WINDOW};
                _ = _xcb_change_window_attributes(dpy, win, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);


                _ = xcb_flush(dpy);
            },
            XCB_CONFIGURE_NOTIFY => {
                warn("xcb: configure notify\n");
                _ = xcb_flush(dpy);
            },
            XCB_MAP_REQUEST => {
                warn("xcb: map request\n");
                var e = @ptrCast(*xcb_map_request_event_t, &ev);
warn("{}\n", e);
                var return_void_pointer: xcb_void_cookie_t = undefined;
                _ = _xcb_map_window(dpy, e.window, &return_void_pointer);


                var screen = getActiveMouseScreen(screens);
                var group_index = screen.groups.first.?.data;
                var group = &groups.toSlice()[group_index];
                _ = addWindow(allocator, e.window, screen, group, &windows);

                setWindowEvents(dpy, e.window, screen_root);

                // TODO: set window location and dimensions
                var active_screen = getActiveMouseScreen(screens);
                resizeAndMoveWindow(dpy, e.window, active_screen, screen_padding, BORDER_WIDTH);



                _ = xcb_flush(dpy);

debugScreens(screens, windows);
debugWindows(windows);
debugGroups(groups);
            },
            XCB_MAP_NOTIFY => {
                warn("xcb: map notify\n");
                _ = xcb_flush(dpy);
            },
            XCB_EXPOSE => {
                warn("xcb: expose\n");

                _ = xcb_flush(dpy);
            },
            XCB_BUTTON_PRESS => {
                warn("xcb: button press\n");
                var e = @ptrCast(*xcb_button_press_event_t, &ev);
                warn("{}\n", e);

                var return_grab_cookie: xcb_grab_pointer_cookie_t = undefined;
                var cursor = u32(0);
                _ = _xcb_grab_pointer(dpy, 0, e.event,
                                      _XCB_EVENT_MASK_BUTTON_RELEASE | _XCB_EVENT_MASK_POINTER_MOTION,
                                      _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC,
                                      screen_root, cursor, _XCB_TIME_CURRENT_TIME,
                                      &return_grab_cookie);

                var grab_pointer = xcb_grab_pointer_reply(dpy, return_grab_cookie, null);
                var is_grabbed = true;

                var return_geo: xcb_get_geometry_cookie_t = undefined;
                _ = _xcb_get_geometry(dpy, e.event, &return_geo);
                var win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
                // TODO: get screen that the window is on
                var win = windows.get(e.event);

                var active_screen = getScreen(win.?.value.screen_id, screens);

                while (is_grabbed) {
                    var ev_inside = xcb_wait_for_event(dpy).?[0];
                    switch (ev_inside.response_type & ~u8(0x80)) {
                        // TODO: what if some other event happens here: configure, map, etc
                        XCB_MOTION_NOTIFY => {
                            // warn("xcb inside: motion notify\n");
                            var e_inside = @ptrCast(*xcb_motion_notify_event_t, &ev_inside);
                            var win_mask: u16 = 0;
                            var win_values: [2]i32 = undefined;
                            var xdiff = e_inside.root_x - e.root_x;
                            var ydiff = e_inside.root_y - e.root_y;

                            if (e.detail == _XCB_BUTTON_INDEX_1) {
                                win_mask = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
                                var x: i32 = win_geo.x + xdiff;
                                var y: i32 = win_geo.y + ydiff;

                                if (e.state == _XCB_MOD_MASK_1) {
                                    if (getNewScreenOnChange(e_inside.root_x, e_inside.root_y, screens, active_screen)) |new_screen| {
                                        active_screen = new_screen;
                                    }

                                    var new_win_geometry = inBoundsWindowGeometry(x, y, win_geo.width, win_geo.height, BORDER_WIDTH, screen_padding, window_min_width, window_min_height, active_screen);

                                    if (win_geo.width > active_screen.width) {
                                        new_win_geometry.x = active_screen.x + @intCast(i32, screen_padding);
                                    }

                                    if (win_geo.height > active_screen.height) {
                                        new_win_geometry.y = active_screen.y + @intCast(i32, screen_padding);
                                    }

                                    win_values[0] = new_win_geometry.x;
                                    win_values[1] = new_win_geometry.y;

                                } else if (e.state == (_XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT)) {
                                    win_values[0] = x;
                                    win_values[1] = y;
                                }

                            } else if (e.detail == _XCB_BUTTON_INDEX_3) {
                                win_mask = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
                                var width = @intCast(i32, win_geo.width) + xdiff;
                                var height = @intCast(i32, win_geo.height) + ydiff;

                                if (e.state == _XCB_MOD_MASK_1) {


                                    var new_win_geometry = inBoundsWindowGeometry(win_geo.x, win_geo.y, width,height, BORDER_WIDTH, screen_padding, window_min_width, window_min_height, active_screen);

                                    win_values[0] = new_win_geometry.width;
                                    win_values[1] = new_win_geometry.height;

                                } else if (e.state == (_XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT)) {
                                    win_values[0] = std.math.max(@intCast(i32, window_min_width), width);
                                    win_values[1] = std.math.max(@intCast(i32, window_min_height), height);
                                }
                            }

                            var return_pointer: xcb_void_cookie_t = undefined;
                            _ = _xcb_configure_window(dpy, e.event, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
                            _ = xcb_flush(dpy);
                        },
                        XCB_BUTTON_RELEASE => {
                            warn("xcb inside: button release\n");
                            var e_inside = @ptrCast(*xcb_button_release_event_t, &ev_inside);
                            is_grabbed = false;
                            if (e_inside.detail != _XCB_BUTTON_INDEX_1) continue;
                            warn("{}\n", e_inside);

                            if (getNewScreenOnChange(e_inside.root_x, e_inside.root_y, screens, active_screen)) |new_screen| {
                                active_screen = new_screen;
                            }
                            if (win.?.value.screen_id != active_screen.id) {
                                warn("window has changed screen\n");

                                // changeWindowGroup() new_group_index
                                var groups_slice = groups.toSlice();
                                var old_group_index = win.?.value.group_index;
                                var new_group_index = active_screen.groups.first.?.data;
                                var group_win_node = groups_slice[old_group_index].windows.first;
                                while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                                    if (group_win_node.?.data == win.?.value.id) {
                                        groups_slice[old_group_index].windows.remove(group_win_node.?);
                                        groups_slice[new_group_index].windows.prepend(group_win_node.?);
                                        break;
                                    }
                                }

                                // changeWindowScreen()
                                var old_screen = getScreen(win.?.value.screen_id, screens);
                                var node = old_screen.windows.first;
                                while (node != null) : (node = node.?.next) {
                                    if (node.?.data == win.?.value.id) {
                                        old_screen.windows.remove(node.?);
                                        active_screen.windows.prepend(node.?);
                                        win.?.value.screen_id = active_screen.id;
                                        win.?.value.group_index = new_group_index;
                                        break;
                                    }
                                }
                            }

debugScreens(screens, windows);
debugWindows(windows);
debugGroups(groups);
                        },
                        else => {
                            warn("xcb inside: else\n");
                        }
                    }
                }

                var return_ungrab_cookie: xcb_void_cookie_t = undefined;
                _ = _xcb_ungrab_pointer(dpy, _XCB_TIME_CURRENT_TIME, &return_ungrab_cookie);

                _ = xcb_flush(dpy);
            },
            XCB_BUTTON_RELEASE => {
                warn("xcb: button release\n");
                _ = xcb_flush(dpy);
            },
            XCB_MOTION_NOTIFY => {
                // warn("xcb: motion notify\n");
                var e = @ptrCast(*xcb_motion_notify_event_t, &ev);
                // warn("{}\n", e);

                var current_mouse_screen = getActiveMouseScreen(screens);
                var has_screen_changed = hasActiveScreenChanged(e.root_x, e.root_y, screens, current_mouse_screen);

                _ = xcb_flush(dpy);
            },
            XCB_KEY_PRESS => {
                warn("xcb: key press\n");
                var e = @ptrCast(*xcb_key_press_event_t, &ev);
warn("{}\n", e);

                var key_symbols = xcb_key_symbols_alloc(dpy);
                var keysym = xcb_key_symbols_get_keysym(key_symbols, e.detail, 0);
                xcb_key_symbols_free(key_symbols);

                if (keysym == @intCast(u32, xlib.XStringToKeysym(c"t"))) {
                    warn("open xterm\n");
                    var argv = []const []const u8{"xterm"};
                    var child_result = try child.init(argv, allocator);
                    var env_map = try os.getEnvMap(allocator);
                    child_result.env_map = env_map;
                    _ = try child.spawn(child_result);
                }

                _ = xcb_flush(dpy);
            },
            XCB_KEY_RELEASE => {
                warn("xcb: key release\n");
                _ = xcb_flush(dpy);
            },
            XCB_ENTER_NOTIFY => {
                warn("xcb: enter notify\n");
                var e = @ptrCast(*xcb_enter_notify_event_t, &ev);
warn("{}\n", e);

                var win = windows.get(e.event);
                var mouse_screen = getActiveMouseScreen(screens);


                var win_screen = getScreen(win.?.value.screen_id, screens);
                warn("{}\n", win_screen.id);

                _ = xcb_flush(dpy);
            },
            else => {
                warn("xcb: else -> {}\n", ev);

                _ = xcb_flush(dpy);
            }
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





fn inBoundsWindowGeometry(x: i32, y: i32, width: i32, height: i32, border_width: i32, screen_padding: i32, window_min_width: i32, window_min_height: i32, screen: *Screen) WindowGeometry {
    var screen_width:i32 = screen.width;
    var screen_height:i32 = screen.height;
    var new_x = std.math.max(screen_padding, x - screen.x);
    var new_y = std.math.max(screen_padding, y - screen.y);
    var new_width = width;
    var new_height = height;        


    // Width and x coordinate
    var win_total_width = new_width + 2 * border_width;

    if ((new_x + win_total_width) >= screen_width) {
        new_x = new_x - (new_x + win_total_width - screen_width);
        new_width = screen_width - 2 * border_width - (x - screen.x) - screen_padding;
    }

    new_x = std.math.max(screen_padding, new_x + screen.x - screen_padding);

    if (new_width < window_min_width) {
        new_width = window_min_width;
    }


    // Height and y coordinate
    var win_total_height = new_height + 2 * border_width;

    if ((new_y + win_total_height) >= screen_height) {
        new_y = new_y - (new_y + win_total_height - screen_height);
        new_height = screen_height - 2 * border_width - (y - screen.y) - screen_padding;
    }

    new_y = std.math.max(screen_padding, new_y + screen.y - screen_padding);

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

fn getWindowGeometryInside(w_attr: xcb_get_geometry_reply_t, screen: *Screen, border_width: i32, screen_padding: i32) WindowGeometry {
    var screen_width:i32 = screen.width;
    var screen_height:i32 = screen.height;
    var x:i32 = w_attr.x - screen.x;
    var y:i32 = w_attr.y - screen.y;
    var width:i32 = w_attr.width;
    var height:i32 = w_attr.height;        

    // Width and x coordinate
    var win_total_width = width + 2 * border_width;

    if (win_total_width >= screen_width) {
        width = screen_width - 2 * screen_padding;
    }

    win_total_width = width + 2 * border_width;

    if ((x + win_total_width) >= screen_width) {
        x = x - (x + win_total_width - screen_width) - screen_padding;
    }

    x = std.math.max(screen_padding, x) + screen.x;


    // Height and y coordinate
    var win_total_height = height + 2 * border_width;

    if (win_total_height >= screen_height) {
        height = screen_height - 2 * screen_padding;
    }

    win_total_height = height + 2 * border_width;

    if ((y + win_total_height) >= screen_height) {
        y = y - (y + win_total_height - screen_height) - screen_padding;
    }

    y = std.math.max(screen_padding, y) + screen.y;

    return WindowGeometry {
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
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



fn getNewScreenOnChange(x: i16, y: i16, screens: LinkedList(Screen), active_screen: *Screen) ?*Screen {
    var screen = screens.first;
    while (screen != null) : (screen = screen.?.next) {
        if (screen.?.data.id == active_screen.id) continue;
        if (isPointerInScreen(screen.?.data, x, y)) { 
            warn("Change screen {}\n", screen.?.data.id);
            active_screen.has_mouse = false;
            screen.?.data.has_mouse = true;
            return &screen.?.data;
        }
    }

    return null;
}



fn hasActiveScreenChanged(x: i16, y: i16, screens: LinkedList(Screen), active_screen: *Screen) bool {
    var screen = screens.first;
    while (screen != null) : (screen = screen.?.next) {
        if (screen.?.data.id == active_screen.id) continue;
        if (isPointerInScreen(screen.?.data, x, y)) { 
            warn("Change screen {}\n", screen.?.data.id);
            active_screen.has_mouse = false;
            screen.?.data.has_mouse = true;
            return true;
        }
    }

    return false;
}


fn isPointerInScreen(screen: Screen, x: i16 , y: i16) bool {
    var screen_x_right = screen.x + @intCast(i32, screen.width);
    var screen_y_right = screen.y + @intCast(i32, screen.height);

    return (x >= screen.x)  and (x <= screen_x_right) 
            and (y >= screen.y) and (y <= screen_y_right);
}


fn debugScreens(screens: LinkedList(Screen), windows: WindowsHashMap) void {
    var item = screens.first;
    warn("\n----Screens----\n");
    while (item != null) : (item = item.?.next) {
        var screen = item.?.data;
        warn("Screen |> id: {}", screen.id);
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


fn addWindow(allocator: *Allocator, win: xcb_window_t, screen: *Screen, group: *Group, windows: *WindowsHashMap) !void {
    var new_window = Window {
        .id = win,
        .screen_id = screen.id,
        .group_index = group.index,
    };

    // Add to windows hash map
    // TODO: fn putOrGet ???
    _ = try windows.put(win, new_window);
    // var kv = windows.get(win);

    // Add into screen's window linked list
    var win_node = try screen.windows.createNode(win, allocator);
    screen.windows.prepend(win_node);
    // Add into groups' window linked list
    var group_win_node = try group.windows.createNode(win, allocator);
    group.windows.prepend(group_win_node);
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
        warn("id: {} | screen: {} | group: {}\n", item.?.value.id, item.?.value.screen_id, item.?.value.group_index);
   }
}



fn getScreen(screen_id: u32, screens: LinkedList(Screen)) *Screen {
    var window_screen_node = screens.first;
    while (window_screen_node != null) : (window_screen_node = window_screen_node.?.next) {
        if (window_screen_node.?.data.id == screen_id) {
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


// TODO: maybe can remove screen_root ???
fn setWindowEvents(dpy: ?*xcb_connection_t, window: xcb_window_t, screen_root: u32) void {
    var return_void_pointer: xcb_void_cookie_t = undefined;

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_1, _XCB_MOD_MASK_1, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_1, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_3, _XCB_MOD_MASK_1, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_3, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, &return_void_pointer);

}

fn configureWindow(dpy: ?*xcb_connection_t, win: xcb_window_t, border_width: u16, border_color: u32) void {
    var i: u8 = 0;
    var config_mask: u16 = 0;
    var config_values: [1]u32 = undefined;

    config_mask = config_mask | _XCB_CONFIG_WINDOW_BORDER_WIDTH;
    config_values[i] = border_width;
    i += 1;

    var return_pointer: xcb_void_cookie_t = undefined;
    _ = _xcb_configure_window(dpy, win, config_mask, @ptrCast(?*const c_void, &config_values), &return_pointer);

    var return_cookie: xcb_void_cookie_t = undefined;
    const attr_mask = _XCB_CW_BORDER_PIXEL | _XCB_CW_EVENT_MASK;
    var attr_values = []u32{border_color, _XCB_EVENT_MASK_ENTER_WINDOW | _XCB_EVENT_MASK_BUTTON_PRESS};
    _ = _xcb_change_window_attributes(dpy, win, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);
}



// TODO: bad name. resizing and moving happens in bounds
fn resizeAndMoveWindow(dpy: ?*xcb_connection_t, win: xcb_window_t, active_screen: *Screen, screen_padding: u16, border_width: u16) void {
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, win, &return_geo);
    var geo = xcb_get_geometry_reply(dpy, return_geo, null);
    warn("{}\n", geo.?[0]);
    var new_geo = getWindowGeometryInside(geo.?[0], active_screen, border_width, screen_padding);
    warn("--------------\n{}\n", new_geo);

    var win_mask: u16 = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y | _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
    var win_values = []i32{new_geo.x, new_geo.y, new_geo.width, new_geo.height};

    var return_pointer: xcb_void_cookie_t = undefined;
    _ = _xcb_configure_window(dpy, win, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
}



pub extern fn _xcb_setup_roots_iterator(R: ?[*]const xcb_setup_t, return_screen: *xcb_screen_iterator_t) *xcb_screen_iterator_t;

pub extern fn grab_button(conn: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, button: u8, modifiers: u16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_grab_key(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, modifiers: u16, key: xcb_keycode_t, pointer_mode: u8, keyboard_mode: u8, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_change_window_attributes(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_configure_window(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_map_window(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_free_pixmap(c: ?*xcb_connection_t, pixmap: xcb_pixmap_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_create_pixmap(c: ?*xcb_connection_t, depth: u8, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_create_gc(c: ?*xcb_connection_t, cid: xcb_gcontext_t, drawable: xcb_drawable_t, value_mask: u32, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_change_gc(c: ?*xcb_connection_t, gc: xcb_gcontext_t, value_mask: u32, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_alloc_named_color(c: ?*xcb_connection_t, cmap: xcb_colormap_t, name_len: u16, name: ?[*]const u8, return_pointer: *xcb_alloc_named_color_cookie_t) *xcb_alloc_named_color_cookie_t;




pub extern fn _xcb_randr_get_monitors(c: ?*xcb_connection_t, window: xcb_window_t, get_active: u8, return_pointer: *xcb_randr_get_monitors_cookie_t) *xcb_randr_get_monitors_cookie_t;

pub extern fn _xcb_randr_get_monitors_monitors_iterator(R: ?[*]const xcb_randr_get_monitors_reply_t, return_pointer: *xcb_randr_monitor_info_iterator_t) *xcb_randr_monitor_info_iterator_t;

pub extern fn _xcb_query_tree(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_query_tree_cookie_t) *xcb_query_tree_cookie_t;

pub extern fn _xcb_query_pointer(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_query_pointer_cookie_t) *xcb_query_pointer_cookie_t;


pub extern fn _xcb_get_geometry(c: ?*xcb_connection_t, drawable: xcb_drawable_t, return_pointer: *xcb_get_geometry_cookie_t) *xcb_get_geometry_cookie_t;

pub extern fn _xcb_grab_pointer(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, time_0: xcb_timestamp_t, return_pointer: *xcb_grab_pointer_cookie_t) *xcb_grab_pointer_cookie_t;

pub extern fn _xcb_ungrab_pointer(c: ?*xcb_connection_t, time_0: xcb_timestamp_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;


// pub extern fn _xcb_translate_coordinates(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16, return_pointer: *xcb_translate_coordinates_cookie_t) *xcb_translate_coordinates_cookie_t;
