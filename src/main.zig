const std = @import("std");
const fmt = std.fmt;
const cstr = std.cstr;
const warn = std.debug.warn;
const assert = std.debug.assert;
const mem = std.mem;
const Allocator = mem.Allocator;
const os = std.os;
const child = os.ChildProcess;
const ArrayList = std.ArrayList;
const LinkedList = std.LinkedList;
const hash_map = std.hash_map;
const HashMap = std.HashMap;

const xlib = @cImport({
    @cInclude("X11/Xlib.h");
    // @cInclude("X11/keysym.h");
});
const xrandr = @import("Xrandr.zig");
use @import("c_import.zig");
use @import("xcb_extern.zig");

const Screen = struct.{
    id: u32, 
    has_mouse: bool,
    x: i16,
    y: i16,
    width: u16,
    height: u16,
    groups: LinkedList(u8),
    windows: LinkedList(xcb_window_t),

    // TODO: add functions
    // remove/add group
    // other functions ???

    pub fn removeWindow(self: *Screen, id: xcb_window_t, allocator: *Allocator) bool {
        var node = self.windows.first;
        while (node != null) : (node = node.?.next) {
            if (id == node.?.data) {
                self.windows.remove(node.?);
                self.windows.destroyNode(node.?, allocator);
                return true;
            }
        }
        return false;
    }

    pub fn addWindow(self: *Screen, id: xcb_window_t, allocator: *Allocator) void {
        const node = self.windows.createNode(id, allocator) catch |err| {
            warn("Error was raised when trying to add new window to Screen. Error msg: {}\n", err);
            return;
        };
        self.windows.prepend(node);
    }
};

const Group = struct.{
    index: u8,
    windows: LinkedList(xcb_window_t),
    // TODO: add string values

    pub fn removeWindow(self: *Group, id: xcb_window_t, allocator: *Allocator) void {
        var node = self.windows.first;
        while (node != null) : (node = node.?.next) {
            if (id == node.?.data) {
                self.windows.remove(node.?);
                self.windows.destroyNode(node.?, allocator);
                break;
            }
        }
    }

    pub fn addWindow(self: *Group, id: xcb_window_t, allocator: *Allocator) void {
        const node = self.windows.createNode(id, allocator) catch |err| {
            warn("Error was raised when trying to add new window to Group. Error msg: {}\n", err);
            return;
        };
        self.windows.prepend(node);
    }
};

// TODO: add geometry info to Window ???
const Window = struct.{
    id: xcb_window_t,
    screen_id: u32, 
    group_index: u8,
};

const WindowGeometry = struct.{
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};

const Point = struct.{
    x: i32,
    y: i32,
};

const Key = struct.{
    key: [] u8,
    mod: u32,
    // func: (fn(xcb_generic_event_t) void),
};

var Keymap: [] Key = {
    Key.{
        .key = "h", .mod = g_mod | g_mask_shift,
        // .func = ,
    };

    Key.{
        .key = "l", .mod = g_mod | g_mask_shift,
        // .func = ,
    };
};

const WindowsHashMap = HashMap(c_ulong, Window, getWindowHash, comptime hash_map.getAutoEqlFn(c_ulong));

// ------- CONFIG -------
var g_border_width: u16 = 10;
var g_default_border_color: u32  = undefined;
var g_active_border_color: u32 = undefined;
var g_screen_padding: u16 = 5;
var g_window_min_width: u16= 100; // NOTE: without border
var g_window_min_height: u16 = 100; // NOTE: without border
var g_window_move_x: u16 = 50;
var g_window_move_y: u16 = 40;
var g_grid_rows: u8 = 4;
var g_grid_cols: u8 = 4;
var g_grid_total: u16 = undefined;
var g_grid_color: u32 = undefined;
var g_grid_show: bool = true;

var g_mod = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
var g_mask_alt = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
var g_mask_ctrl = @intCast(u16, @enumToInt(_XCB_MOD_MASK_CONTROL));
var g_mask_shift = @intCast(u16, @enumToInt(_XCB_MOD_MASK_SHIFT));

pub fn main() !void {
    var dpy = xcb_connect(null, null);
    if (xcb_connection_has_error(dpy) > 0) return error.FailedToOpenDisplay;

    // ------- CONFIG -------
    var group_count: u8 = 10;
    g_grid_total = g_grid_rows * g_grid_cols;

    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    const root_gc_id = xcb_generate_id(dpy);

    var return_screen: xcb_screen_iterator_t = undefined;
    _ = _xcb_setup_roots_iterator(xcb_get_setup(dpy), &return_screen);
    warn("{}\n", return_screen.data.?[0]);

    var screen_data = return_screen.data.?[0];
    var screen_root = return_screen.data.?[0].root;

    var return_cookie: xcb_void_cookie_t = undefined;

    var value_list = []c_int.{
        @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT)
        // | _XCB_EVENT_MASK_EXPOSURE
        // | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY
        | @enumToInt(XCB_EVENT_MASK_POINTER_MOTION),
    };

    const root_attr_mask = _XCB_CW_EVENT_MASK;
    _ = _xcb_change_window_attributes(dpy, screen_root, root_attr_mask, @ptrCast(?*const c_void, &value_list), &return_cookie);
    // _ = _xcb_free_cursor(dpy, cursor_id, &return_cookie);


    // Set keyboard events
    var group_strings = []const [*]const u8.{c"1", c"2", c"3", c"4", c"5", c"6", c"7", c"8", c"9", c"0"};
    {
        var key_symbols = xcb_key_symbols_alloc(dpy);

        for (group_strings) |char| {
            var keysym = xlib.XStringToKeysym(char);
            var keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];

            _ = _xcb_grab_key(dpy, 1, screen_root, g_mod, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_cookie);
        }

        var t_keysym = xlib.XStringToKeysym(c"t");
        var t_keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, t_keysym)).?[0];
        xcb_key_symbols_free(key_symbols);
        warn("{}\n", t_keysym);
        _ = _xcb_grab_key(dpy, 1, screen_root, g_mod, t_keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_cookie);

    }

    // Set colors
    var return_grey_color_cookie: xcb_alloc_named_color_cookie_t = undefined;
    var return_blue_color_cookie: xcb_alloc_named_color_cookie_t = undefined;
    var return_grid_color_cookie: xcb_alloc_named_color_cookie_t = undefined;
    var default_color_cookie = _xcb_alloc_named_color(dpy, screen_data.default_colormap, 4, c"grey", &return_grey_color_cookie);
    var default_color_reply = xcb_alloc_named_color_reply(dpy, return_grey_color_cookie, null);

    var active_color_cookie = _xcb_alloc_named_color(dpy, screen_data.default_colormap, 4, c"blue", &return_blue_color_cookie);
    var active_color_reply = xcb_alloc_named_color_reply(dpy, return_blue_color_cookie, null);
    var g_grid_color_cookie = _xcb_alloc_named_color(dpy, screen_data.default_colormap, 3, c"red", &return_grid_color_cookie);
    var g_grid_color_reply = xcb_alloc_named_color_reply(dpy, return_grid_color_cookie, null);

    g_default_border_color = default_color_reply.?[0].pixel;
    g_active_border_color = active_color_reply.?[0].pixel;
    g_grid_color = g_grid_color_reply.?[0].pixel;

    
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
            var group = Group.{
                .index = i,
                .windows = LinkedList(xcb_window_t).init(),
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

        var j: u8 = 0;
        var return_monitors_iter: xcb_randr_monitor_info_iterator_t = undefined;
        _ = _xcb_randr_get_monitors_monitors_iterator(monitors, &return_monitors_iter);
        var is_set_has_mouse = false;
        while (return_monitors_iter.rem != 0) : ({
            _ = xcb_randr_monitor_info_next(@ptrCast(?[*]struct_xcb_randr_monitor_info_iterator_t ,&return_monitors_iter));
            j += 1;
        }) {
            var monitor = return_monitors_iter.data.?[0];

            var has_mouse = (pointer.root_x >= monitor.x
                and pointer.root_x <= (monitor.x + @intCast(i16, monitor.width))
                and pointer.root_y >= monitor.y
                and pointer.root_y <= (monitor.y + @intCast(i16, monitor.height)));

            if (!is_set_has_mouse and has_mouse) {
                is_set_has_mouse = true;
            }
            var screen = Screen.{
                // NOTE: Xephyr test environment doesn't have primary monitor
                .has_mouse = has_mouse,
                .id = monitor.name,
                .groups = LinkedList(u8).init(),
                .x = monitor.x,
                .y = monitor.y,
                .width = monitor.width,
                .height = monitor.height,
                .windows = std.LinkedList(xcb_window_t).init(),
            };
            
            var group_node = try screen.groups.createNode(j, allocator);
            screen.groups.prepend(group_node);

            var node_ptr = try screens.createNode(screen, allocator);
            screens.append(node_ptr);

            var rects = try getGridRectangles(allocator, screen);
            _ = _xcb_clear_area(dpy, 1, screen_root, screen.x, screen.y, screen.width, screen.height, &return_cookie);
            drawScreenGrid(dpy, screen_root, root_gc_id, rects);
        }

        // TODO: might have to do this for another methods screen/monitor detection ???
        if (!is_set_has_mouse) {
            var screen_info = screens.first.?.data;
            _ = _xcb_warp_pointer(dpy, screen_root, screen_root, pointer.root_x, pointer.root_y, screen_info.width, screen_info.height, @intCast(i16, screen_info.width / 2), @intCast(i16, screen_info.height / 2), &return_cookie);
            screens.first.?.data.has_mouse = true;
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
        var values = []u32.{g_default_border_color, _XCB_EVENT_MASK_ENTER_WINDOW};
        var i: u16 = 0;
        while (i < children_count) : (i+=1) {
            warn("{}\n", children.?[i]);
            var win = children.?[i];
            var active_screen = blk: {
                var return_geo: xcb_get_geometry_cookie_t = undefined;
                _ = _xcb_get_geometry(dpy, win, &return_geo);
                var geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
                if (getScreenBasedOnCoords(geo.x, geo.y, screens)) |screen|  {
                break :blk screen;
                }

                break :blk &screens.first.?.data;
            };
            var group_index = active_screen.groups.first.?.data;
            var group = &groups.toSlice()[group_index];

            _ = _xcb_change_window_attributes(dpy, win, event_mask, @ptrCast(?*const c_void, &values), &return_cookie);

            configureWindow(dpy, win);
            resizeAndMoveWindow(dpy, win, active_screen);
            setWindowEvents(dpy, win, group_strings);
            _ = addWindow(allocator, win, active_screen, group, &windows);

        }

        if (getActiveMouseScreen(screens).windows.first) |win| {
            focusWindow(dpy, win.data, g_active_border_color);
        }
    }

    _ = xcb_flush(dpy);


    debugScreens(screens, windows);
    debugWindows(windows);
    debugGroups(groups);

    while (true) {
        var ev = xcb_wait_for_event(dpy).?[0];
        var res_type = ev.response_type & ~u8(0x80);
        switch (res_type) {
            XCB_DESTROY_NOTIFY => {
                warn("xcb: destroy notify\n");
                var e = @ptrCast(*xcb_destroy_window_request_t, &ev);
                warn("{}\n", e);

                if (windows.get(e.window)) |window| {
                    var group_windows = &groups.toSlice()[window.value.group_index].windows;
                    var group_window_node = group_windows.first;
                    while (group_window_node != null) : (group_window_node = group_window_node.?.next) {
                        if (group_window_node.?.data == window.value.id) {
                            group_windows.remove(group_window_node.?);
                            group_windows.destroyNode(group_window_node.?, allocator);
                            break;
                        }
                    }

                    var screen = getScreen(window.value.screen_id, screens);
                    var screen_window_node = screen.windows.first;
                    while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
                        if (screen_window_node.?.data == window.value.id) {
                            screen.windows.remove(screen_window_node.?);
                            screen.windows.destroyNode(screen_window_node.?, allocator);
                            break;
                        }
                    }

                    // TODO: handle group if there is no windows in it anymore ???
                    // Either remove it or keep it around. At the moment
                    // keeping it around seems better choice

                    _ = windows.remove(window.value.id);

                    // TODO: or instead focus window on the screen the mouse
                    // cursor is
                    if (screen.windows.first) |new_window| {
                        // TODO: rearrange Screen groups if new window's group index
                        // is different
                        var new_window_info = windows.get(new_window.data);
                        if (new_window_info != null and window.value.group_index != new_window_info.?.value.group_index) {
                            warn("group index changed\n");
                            var screen_group_node = screen.groups.first;
                            while (screen_group_node != null) : (screen_group_node = screen_group_node.?.next) {
                                if (new_window_info.?.value.group_index == screen_group_node.?.data) {
                                    screen.groups.remove(screen_group_node.?);
                                    screen.groups.prepend(screen_group_node.?);
                                    break;
                                }
                            }
                        }
                        focusWindow(dpy, new_window.data, g_active_border_color);
                        _ = xcb_flush(dpy);
                    }
                }
            },
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
                config_values[i] = g_border_width;
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

                _ = xcb_flush(dpy);
            },
            XCB_CONFIGURE_NOTIFY => {
                warn("xcb: configure notify\n");
                var e = @ptrCast(*xcb_configure_notify_event_t, &ev);
                warn("{}\n", e);
                _ = xcb_flush(dpy);
            },
            XCB_MAP_REQUEST => {
                warn("xcb: map request\n");
                var e = @ptrCast(*xcb_map_request_event_t, &ev);
warn("{}\n", e);
                var return_void_pointer: xcb_void_cookie_t = undefined;

                var active_screen = getActiveMouseScreen(screens);
                var group_index = active_screen.groups.first.?.data;
                var group = &groups.toSlice()[group_index];


                setWindowEvents(dpy, e.window, group_strings);

                // TODO: set window location and dimensions
                resizeAndMoveWindow(dpy, e.window, active_screen);

                var attr_mask: u16 = _XCB_CW_EVENT_MASK;
                var attr_values = []u32.{_XCB_EVENT_MASK_ENTER_WINDOW | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY};
                _ = _xcb_change_window_attributes(dpy, e.window, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);


                if (!windows.contains(e.window)) {
                    _ = addWindow(allocator, e.window, active_screen, group, &windows);
                }

                _ = _xcb_map_window(dpy, e.window, &return_void_pointer);

                var focused_window = getFocusedWindow(dpy);
                unfocusWindow(dpy, focused_window, g_default_border_color);
                focusWindow(dpy, e.window, g_active_border_color);

                _ = xcb_flush(dpy);
            },
            XCB_UNMAP_NOTIFY => {
                warn("xcb: unmap notify\n");
                _ = xcb_flush(dpy);
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

                                    var new_win_geometry = inBoundsWindowGeometry(x, y, win_geo.width, win_geo.height, active_screen);

                                    if (win_geo.width > active_screen.width) {
                                        new_win_geometry.x = active_screen.x + @intCast(i32, g_screen_padding);
                                    }

                                    if (win_geo.height > active_screen.height) {
                                        new_win_geometry.y = active_screen.y + @intCast(i32, g_screen_padding);
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


                                    var new_win_geometry = inBoundsWindowGeometry(win_geo.x, win_geo.y, width,height, active_screen);

                                    win_values[0] = new_win_geometry.width;
                                    win_values[1] = new_win_geometry.height;

                                } else if (e.state == (_XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT)) {
                                    win_values[0] = std.math.max(@intCast(i32, g_window_min_width), width);
                                    win_values[1] = std.math.max(@intCast(i32, g_window_min_height), height);
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
                            // warn("{}\n", ev_inside);
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

                if (e.child != 0) continue;

                var new_screen = getNewScreenOnChange(e.root_x, e.root_y, screens, getActiveMouseScreen(screens));

                if (new_screen) |screen| {
                    warn("{}\n", e);
                    var focused_window = getFocusedWindow(dpy);

                    unfocusWindow(dpy, focused_window, g_default_border_color);

                    if (screen.windows.first) |window| {
                        focusWindow(dpy, window.data, g_active_border_color);
                    } else {
                        focusWindow(dpy, screen_root, g_active_border_color);
                    }
                }

                _ = xcb_flush(dpy);
            },
            XCB_KEY_PRESS => {
                try keypressEvent(allocator, dpy, ev, screens, groups, windows, group_strings);
            },
            XCB_KEY_RELEASE => {
                warn("xcb: key release\n");
                _ = xcb_flush(dpy);
            },
            XCB_ENTER_NOTIFY => {
                warn("xcb: enter notify\n");
                var e = @ptrCast(*xcb_enter_notify_event_t, &ev);
                // TODO: when crossing screen from window to window sometimes
                // window focusing won't fire. Problem in this if statement.
                // TODO NOTE: Can also be fixed by removing if statement in
                // motion notify event.
                if (e.detail != _XCB_NOTIFY_DETAIL_ANCESTOR
                    and e.detail != _XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL) continue;

                // warn("xcb: enter notify\n");
                warn("{}\n", e);

                var win = windows.get(e.event);
                var active_screen = getScreen(win.?.value.screen_id, screens);
                var focused_window = getFocusedWindow(dpy);

                if (focused_window == win.?.value.id) continue;

                warn("change window\n");
                unfocusWindow(dpy, focused_window, g_default_border_color);
                focusWindow(dpy, win.?.value.id, g_active_border_color);

                // prependWindowToScreen()
                var win_node = active_screen.windows.first;
                while (win_node != null) : (win_node = win_node.?.next) {
                    if (win_node.?.data == e.event) {
                        active_screen.windows.remove(win_node.?);
                        active_screen.windows.prepend(win_node.?);
                        break;
                    }
                }

                var group_index = win.?.value.group_index;
                // prependGroupToScreen()
                var group_node = active_screen.groups.first;
                if (active_screen.groups.len > 1 and group_node.?.data != group_index) {
                    while (group_node != null) : (group_node = group_node.?.next) {
                        if (group_node.?.data == group_index) {
                            active_screen.groups.remove(group_node.?);
                            active_screen.groups.prepend(group_node.?);
                            break;
                        }
                    }
                }

                // prependWindowToGroup()
                var group = groups.toSlice();
                var group_win_node = group[group_index].windows.first;
                while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                    if (group_win_node.?.data == win.?.value.id) {
                        group[group_index].windows.remove(group_win_node.?);
                        group[group_index].windows.prepend(group_win_node.?);
                        break;
                    }
                }

                _ = xcb_flush(dpy);

// debugScreens(screens, windows);
// debugWindows(windows);
// debugGroups(groups);

            },
            else => {
                warn("xcb: else -> {}\n", ev);

                _ = xcb_flush(dpy);
            }
        }



    }
}

fn raiseWindow(dpy: ?*xcb_connection_t, window: xcb_window_t) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    const config_values = @ptrCast(?*const c_void, &([]u32.{_XCB_STACK_MODE_ABOVE}));
    _ = _xcb_configure_window(dpy, window, _XCB_CONFIG_WINDOW_STACK_MODE, config_values, &return_pointer);
}


fn moveWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, x: i32, y: i32) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    var win_mask: u16 = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
    var win_values = []i32.{x, y};

    _ = _xcb_configure_window(dpy, window, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
}


fn resizeWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, width: u32, height: u32) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    var win_mask: u16 = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
    var win_values = []u32.{width, height};

    _ = _xcb_configure_window(dpy, window, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);


}

fn getFocusedWindow(dpy: ?*xcb_connection_t) xcb_window_t {
    var return_focus: xcb_get_input_focus_cookie_t = undefined;
    _ = _xcb_get_input_focus(dpy, &return_focus);
    var focus_reply = xcb_get_input_focus_reply(dpy, return_focus, null);
    return focus_reply.?[0].focus;
}


fn focusWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, color: u32) void {
    var return_cookie: xcb_void_cookie_t = undefined;

    _ = _xcb_set_input_focus(dpy, _XCB_INPUT_FOCUS_PARENT, window, _XCB_TIME_CURRENT_TIME, &return_cookie);

    const attr_mask = _XCB_CW_BORDER_PIXEL;
    var attr_values = []u32.{color};
    _ = _xcb_change_window_attributes(dpy, window, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);

    const config_values = @ptrCast(?*const c_void, &([]u32.{_XCB_STACK_MODE_ABOVE}));
    _ = _xcb_configure_window(dpy, window, _XCB_CONFIG_WINDOW_STACK_MODE, config_values, &return_cookie);
}


fn unfocusWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, color: u32) void {
    var return_focus: xcb_get_input_focus_cookie_t = undefined;
    _ = _xcb_get_input_focus(dpy, &return_focus);
    var focus_reply = xcb_get_input_focus_reply(dpy, return_focus, null);

    var return_cookie: xcb_void_cookie_t = undefined;
    const attr_mask = _XCB_CW_BORDER_PIXEL;
    var attr_values = []u32.{color};
    _ = _xcb_change_window_attributes(dpy, focus_reply.?[0].focus, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);
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



fn inBoundsWindowGeometry(x: i32, y: i32, width: i32, height: i32, screen: *Screen) WindowGeometry {
    var screen_width: i32 = screen.width;
    var screen_height: i32 = screen.height;
    var new_x = x - screen.x;
    var new_y = y - screen.y;
    var new_width = width;
    var new_height = height;
    const bw = @intCast(i32, g_border_width);
    const sp = @intCast(i32, g_screen_padding);


    // Width and x coordinate
    var win_total_width = new_width + 2 * bw;

    if ((new_x + win_total_width) >= screen_width) {
        new_x = new_x - (new_x + win_total_width - screen_width);
        new_width = screen_width - 2 * bw - (x - screen.x) - sp;
    }

    new_x = std.math.max(sp, new_x - sp) + screen.x;

    if (new_width < @intCast(i32, g_window_min_width)) {
        new_width = g_window_min_width;
    }


    // Height and y coordinate
    var win_total_height = new_height + 2 * bw;

    if ((new_y + win_total_height) >= screen_height) {
        new_y = new_y - (new_y + win_total_height - screen_height);
        new_height = screen_height - 2 * bw - (y - screen.y) - sp;
    }

    new_y = std.math.max(sp, new_y - sp) + screen.y;

    if (new_height < @intCast(i32, g_window_min_height)) {
        new_height = g_window_min_height;
    }

    return WindowGeometry.{
        .x = new_x,
        .y = new_y,
        .width = new_width,
        .height = new_height,
    };
}

fn getWindowGeometryInside(w_attr: xcb_get_geometry_reply_t, screen: *Screen) WindowGeometry {
    var screen_width:i32 = screen.width;
    var screen_height:i32 = screen.height;
    var x:i32 = w_attr.x - screen.x;
    var y:i32 = w_attr.y - screen.y;
    var width:i32 = w_attr.width;
    var height:i32 = w_attr.height;        
    const bw = @intCast(i32, g_border_width);
    const sp = @intCast(i32, g_screen_padding);

    // Width and x coordinate
    var win_total_width = width + 2 * bw;

    if (win_total_width >= screen_width) {
        width = screen_width - 2 * sp;
    }

    win_total_width = width + 2 * bw;

    if ((x + win_total_width) >= screen_width) {
        x = x - (x + win_total_width - screen_width) - sp;
    }

    x = std.math.max(sp, x) + screen.x;


    // Height and y coordinate
    var win_total_height = height + 2 * bw;

    if (win_total_height >= screen_height) {
        height = screen_height - 2 * sp;
    }

    win_total_height = height + 2 * bw;

    if ((y + win_total_height) >= screen_height) {
        y = y - (y + win_total_height - screen_height) - sp;
    }

    y = std.math.max(sp, y) + screen.y;

    return WindowGeometry.{
        .x = x,
        .y = y,
        .width = width,
        .height = height,
    };
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


fn getScreenBasedOnCoords(x: i16, y: i16, screens: LinkedList(Screen)) ?*Screen {
    var screen = screens.first;
    while (screen != null) : (screen = screen.?.next) {
        if (isPointerInScreen(screen.?.data, x, y)) { 
            return &screen.?.data;
        }
    }

    return null;
}


fn isPointerInScreen(screen: Screen, x: i16 , y: i16) bool {
    var screen_x_right = screen.x + @intCast(i32, screen.width) - 1;
    var screen_y_bottom = screen.y + @intCast(i32, screen.height) - 1;

    return (x >= screen.x)  and (x <= screen_x_right) 
            and (y >= screen.y) and (y <= screen_y_bottom);
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

fn debugWindowsList(screen_windows: LinkedList(xcb_window_t), windows: WindowsHashMap) void {
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
    var new_window = Window.{
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


fn setWindowEvents(dpy: ?*xcb_connection_t, window: xcb_window_t, group_strings: []const [*]const u8) void {
    var return_void_pointer: xcb_void_cookie_t = undefined;
    var key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym: xlib.KeySym = undefined;
    var keycode: xcb_keycode_t = undefined;
    var move_strings = []const [*]const u8.{c"h", c"j", c"k", c"l"};

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_1, _XCB_MOD_MASK_1, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_1, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_3, _XCB_MOD_MASK_1, &return_void_pointer);

    _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, _XCB_BUTTON_INDEX_3, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, &return_void_pointer);

    // Window navigation
    for (move_strings) |str| {
        keysym = xlib.XStringToKeysym(str);
        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];
            _ = _xcb_grab_key(dpy, 1, window, _XCB_MOD_MASK_1, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_void_pointer);

        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];
            _ = _xcb_grab_key(dpy, 1, window, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_void_pointer);

        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];
            _ = _xcb_grab_key(dpy, 1, window, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_CONTROL, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_void_pointer);
    }

    // Window movement between groups
    for (group_strings) |char| {
        keysym = xlib.XStringToKeysym(char);
        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];

        _ = _xcb_grab_key(dpy, 1, window, _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_void_pointer);
    }

    xcb_key_symbols_free(key_symbols);
}

// TODO: remove width and height after window navigation is done
fn configureWindow(dpy: ?*xcb_connection_t, win: xcb_window_t) void {
    var i: u8 = 0;
    var config_mask: u16 = 0;
    var config_values: [3]u32 = undefined; // TODO

    config_mask = config_mask | _XCB_CONFIG_WINDOW_WIDTH;
    config_values[i] = 130;
    i += 1;

    config_mask = config_mask | _XCB_CONFIG_WINDOW_HEIGHT;
    config_values[i] = 105;
    i += 1;

    config_mask = config_mask | _XCB_CONFIG_WINDOW_BORDER_WIDTH;
    config_values[i] = g_border_width;
    i += 1;

    var return_pointer: xcb_void_cookie_t = undefined;
    _ = _xcb_configure_window(dpy, win, config_mask, @ptrCast(?*const c_void, &config_values), &return_pointer);

    var return_cookie: xcb_void_cookie_t = undefined;
    const attr_mask = _XCB_CW_BORDER_PIXEL | _XCB_CW_EVENT_MASK;
    var attr_values = []u32.{g_default_border_color, _XCB_EVENT_MASK_ENTER_WINDOW | _XCB_EVENT_MASK_BUTTON_PRESS};
    _ = _xcb_change_window_attributes(dpy, win, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);
}



// TODO: bad name. resizing and moving happens in bounds
fn resizeAndMoveWindow(dpy: ?*xcb_connection_t, win: xcb_window_t, active_screen: *Screen) void {
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, win, &return_geo);
    var geo = xcb_get_geometry_reply(dpy, return_geo, null);
    var new_geo = getWindowGeometryInside(geo.?[0], active_screen);

    var win_mask: u16 = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y | _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
    var win_values = []i32.{new_geo.x, new_geo.y, new_geo.width, new_geo.height};

    var return_pointer: xcb_void_cookie_t = undefined;
    _ = _xcb_configure_window(dpy, win, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
}


// TODO: pass only Window id (not whole Window) and return new Screen id ???
fn moveWindowBetweenScreens(dpy: ?*xcb_connection_t, window_info: *Window, source_screen: Screen, dest_screen: Screen) void {
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, window_info.id, &return_geo);
    var geo = xcb_get_geometry_reply(dpy, return_geo, null);

    var new_width = @intToFloat(f32, geo.?[0].width) * (@intToFloat(f32, dest_screen.width) / @intToFloat(f32, source_screen.width));
    var new_height = @intToFloat(f32, geo.?[0].height) * (@intToFloat(f32, dest_screen.height) / @intToFloat(f32, source_screen.height));

    var new_x = geo.?[0].x;
    if (dest_screen.x < source_screen.x) {
    new_x -= source_screen.x;
    } else if (dest_screen.x > source_screen.x) {
    new_x += dest_screen.x;
    }

    var new_y = geo.?[0].y;
    if (dest_screen.y < source_screen.y) {
    new_y -= source_screen.y;
    } else if (dest_screen.y > source_screen.y) {
    new_y += dest_screen.y;
    }

    moveWindow(dpy, window_info.id, new_x, new_y);
    resizeWindow(dpy, window_info.id, @floatToInt(u32, new_width), @floatToInt(u32, new_height));

    window_info.screen_id = dest_screen.id;
}

fn pointInTriangle(p: Point, a: Point, b: Point, c: Point) bool {
    var c_a_y = c.y - a.y;
    var c_a_x = c.x - a.x;
    var p_a_y = p.y - a.y;
    var b_a_y = b.y - a.y;

    var w1_top = a.x * c_a_y + p_a_y * c_a_x - p.x * c_a_y;
    var w1_bottom = b_a_y * c_a_x - (b.x - a.x) * c_a_y;
    var w1 = @intToFloat(f32, w1_top) / @intToFloat(f32, w1_bottom);

    var w2_top = @intToFloat(f32, p.y - a.y) - w1 * @intToFloat(f32, b_a_y);
    var w2 = w2_top / @intToFloat(f32, c_a_y);
    return w1 >= 0 and w2 >= 0;
}

fn getGridRectangles(allocator: *Allocator, screen: Screen) ![]xcb_rectangle_t {
    var gc_rects = ArrayList(xcb_rectangle_t).init(allocator);
    defer gc_rects.deinit();

    const tile_width = @divTrunc(screen.width - 2 * g_screen_padding, g_grid_cols);
    const tile_height = @divTrunc(screen.height - 2 * g_screen_padding, g_grid_rows);
    warn("col rem: {}\n", @rem(screen.width - 2 * g_screen_padding, g_grid_cols));
    warn("row rem: {}\n", @rem(screen.height - 2 * g_screen_padding, g_grid_rows));

    var row = u8(0);
    while (row < g_grid_rows) : (row+=1) {
        var col = u8(0);
        while (col < g_grid_cols) : (col+=1) {
            var width = tile_width - 1;
            var height = tile_height - 1;

            // TODO: set a config which allows which tiles to 'stretch' ???
            // Top, right, bottom, left?
            if (col == (g_grid_cols - 1)) {
                width += @rem(screen.width - 2 * g_screen_padding, g_grid_cols);
            }

            if (row == (g_grid_rows - 1)) {
                height += @rem(screen.height - 2 * g_screen_padding, g_grid_rows);
            }

            var rect = xcb_rectangle_t.{
                .x = screen.x + @intCast(i16, tile_width * col + g_screen_padding),
                .y = screen.y + @intCast(i16, tile_height * row + g_screen_padding),
                .width = width,
                .height = height,
            };

            try gc_rects.append(rect);
        }
    }

    return gc_rects.toOwnedSlice();
}


fn getGridCols(allocator: *Allocator, screen: Screen) !ArrayList(i32) {
    var col_locations = ArrayList(i32).init(allocator);

    const tile_width = @divTrunc(screen.width - 2 * g_screen_padding, g_grid_cols);

    var col = u8(0);
    while (col < g_grid_cols) : (col+=1) {
        var loc = screen.x + @intCast(i16, tile_width * col + g_screen_padding);
        try col_locations.append(loc);
    }

    return col_locations;
}


fn getGridRows(allocator: *Allocator, screen: Screen) !ArrayList(i32) {
    var row_locations = ArrayList(i32).init(allocator);

    const tile_height = @divTrunc(screen.height - 2 * g_screen_padding, g_grid_rows);

    var row = u8(0);
    while (row < g_grid_rows) : (row+=1) {
        var loc = screen.y + @intCast(i16, tile_height * row + g_screen_padding);
        try row_locations.append(loc);
    }

    return row_locations;
}


fn drawScreenGrid(dpy: ?*xcb_connection_t, screen_root: xcb_window_t, root_gc_id: xcb_gcontext_t, rects: []xcb_rectangle_t) void {
    var return_void: xcb_void_cookie_t = undefined;
    var gc_mask = u32(_XCB_GC_FOREGROUND);
    var gc_values = []u32.{g_grid_color};
    // var pix = xcb_generate_id(dpy);
    // _ = _xcb_create_pixmap(dpy, 24, pix, screen_root, 600, 500, &return_void);
    _ = _xcb_create_gc(dpy, root_gc_id, screen_root, gc_mask, @ptrCast(?*const c_void, &gc_values), &return_void);
    // gc_mask = _XCB_GC_FOREGROUND;
    // gc_values = []u32.{g_default_border_color};
    // var id = xcb_generate_id(dpy);
    // _ = _xcb_create_gc(dpy, id, screen_root, gc_mask, @ptrCast(?*const c_void, &gc_values), &return_void);

    _ = _xcb_poly_rectangle(dpy, screen_root, root_gc_id, g_grid_total, @ptrCast(?[*]xcb_rectangle_t, rects.ptr), &return_void);
}

fn drawAllScreenGrids(dpy: ?*xcb_connection_t, allocator: *Allocator, screens: LinkedList(Screen), screen_root: xcb_window_t, root_gc_id: xcb_gcontext_t) !void {
    if (g_grid_show) {
        var screen_node = screens.first;
        while (screen_node != null) : (screen_node = screen_node.?.next) {
            var rects = try getGridRectangles(allocator, screen_node.?.data);
            drawScreenGrid(dpy, screen_root, root_gc_id, rects);
        }
    }
}


fn keypressEvent(allocator: *Allocator, dpy: ?*xcb_connection_t, ev: xcb_generic_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap, group_strings: []const [*]const u8) !void {
    var return_cookie: xcb_void_cookie_t = undefined;
    warn("xcb: key press\n");
    const e = @intToPtr(*xcb_key_press_event_t, @ptrToInt(&ev));
    warn("{}\n", e);

    const key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym = xcb_key_press_lookup_keysym(key_symbols, @ptrCast(?[*]xcb_key_press_event_t, e), 0);
    xcb_key_symbols_free(key_symbols);

    if (e.state == g_mod | _XCB_MOD_MASK_CONTROL) {
        warn("ctrl move\n");
        const is_left = keysym == @intCast(u32, xlib.XStringToKeysym(c"h"));
        const is_up = keysym == @intCast(u32, xlib.XStringToKeysym(c"k"));
        const is_right = keysym == @intCast(u32, xlib.XStringToKeysym(c"l"));
        const is_down = keysym == @intCast(u32, xlib.XStringToKeysym(c"j"));

        if (keysym == @intCast(u32, xlib.XStringToKeysym(c"h"))) {
            keypressMoveLeft(allocator, dpy, e, screens, groups, windows);
        } else if (keysym == @intCast(u32, xlib.XStringToKeysym(c"l"))) {
            keypressMoveRight(allocator, dpy, e, screens, groups, windows);
        }


        if (is_left or is_up or is_right or is_down) {
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            var win = windows.get(e.event);
            var screen = getScreen(win.?.value.screen_id, screens);
            var new_x = win_geo.x + blk: {
                if (is_left) break :blk -@intCast(i16, g_window_move_x);
                if (is_right) break :blk @intCast(i16, g_window_move_x);
                break :blk 0;
            };
            var new_y = win_geo.y + blk: {
                if (is_down) break :blk @intCast(i16, g_window_move_y);
                if (is_up) break :blk -@intCast(i16, g_window_move_y);
                break :blk 0;
            };

            var new_edge_x = @intCast(i16, new_x) + @intCast(i16, win_geo.width + 2 * g_border_width);
            var new_edge_y = @intCast(i16, new_y) + @intCast(i16, win_geo.height + 2 * g_border_width);

            // if (is_left or is_right) {
            //     if ((new_x > screen.x and new_x < screen.x + @intCast(i16, screen.width))
            //     or (new_edge_x > screen.x and new_edge_x < screen.x + @intCast(i16, screen.width))) {
            //         moveWindow(dpy, e.event, new_x, win_geo.y);
            //     } else {
            //         const x = if (is_left) new_edge_x else new_x;
            //         const new_screen = getScreenBasedOnCoords(x, new_y, screens) orelse getScreenBasedOnCoords(x, new_edge_y, screens);

            //         if (new_screen != null and screen.id != new_screen.?.id) {
            //             moveWindow(dpy, e.event, new_x, win_geo.y);

            //             _ = screen.removeWindow(win.?.value.id, allocator);
            //             screen.addWindow(win.?.value.id, allocator);

            //             var group_index = screen.groups.first.?.data;
            //             var new_group_index = new_screen.?.groups.first.?.data;

            //             var groups_slice = groups.toSlice();
            //             groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            //             groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            //             win.?.value.screen_id = new_screen.?.id;
            //             win.?.value.group_index = new_group_index;
            //         }
            //     }
            // } else
            if (is_up or is_down) {
                if ((new_y > screen.y and new_y < screen.y + @intCast(i16, screen.height))
                or (new_edge_y > screen.y and new_edge_y < screen.y + @intCast(i16, screen.height))) {
                    moveWindow(dpy, e.event, win_geo.x, new_y);
                } else {
                    const y = if (is_up) new_edge_y else new_y;
                    const new_screen = getScreenBasedOnCoords(new_x, new_y, screens) orelse getScreenBasedOnCoords(new_edge_x, y, screens);

                    if (new_screen != null and screen.id != new_screen.?.id) {
                        moveWindow(dpy, e.event, win_geo.x, new_y);

                        _ = screen.removeWindow(win.?.value.id, allocator);
                        screen.addWindow(win.?.value.id, allocator);

                        var group_index = screen.groups.first.?.data;
                        var new_group_index = new_screen.?.groups.first.?.data;

                        var groups_slice = groups.toSlice();
                        groups_slice[group_index].removeWindow(win.?.value.id, allocator);
                        groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

                        win.?.value.screen_id = new_screen.?.id;
                        win.?.value.group_index = new_group_index;

                    }
                }
            }

        }

    } else if (e.state == g_mod) {
        const is_left = keysym == @intCast(u32, xlib.XStringToKeysym(c"h"));
        const is_up = keysym == @intCast(u32, xlib.XStringToKeysym(c"k"));
        const is_right = keysym == @intCast(u32, xlib.XStringToKeysym(c"l"));
        const is_down = keysym == @intCast(u32, xlib.XStringToKeysym(c"j"));

        if (is_left or is_up or is_right or is_down) {

            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            const win = windows.get(e.event);
            const screen = getScreen(win.?.value.screen_id, screens);
            var new_screen = screen;

            const win_center = Point.{
                .x = win_geo.x + @intCast(i16, win_geo.width / 2) + @intCast(i16, g_border_width),
                .y = win_geo.y + @intCast(i16, win_geo.height / 2) + @intCast(i16, g_border_width),
            };


            const largest_distance = blk: {
                var largest_dim: u16 = 0;
                var screen_window_node = screen.windows.first.?.next;
                while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
                    _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
                    const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

                    if (geo.width > largest_dim) {
                        largest_dim = geo.width;
                    }

                    if (geo.height > largest_dim) {
                        largest_dim = geo.height;
                    }
                }

                const half_dim: i32 = @divTrunc(largest_dim, 2) + g_border_width;
                const x_distance = screen.x + @intCast(i32, screen.width) - win_center.x + half_dim;
                const y_distance = screen.y + @intCast(i32, screen.height) - win_center.y + half_dim;
                if (x_distance > y_distance) {
                    break :blk x_distance;
                } else {
                    break :blk y_distance;
                }
            };

            // @ChangeBasedOnDirection
            // getPointBasedOnDirection(key) ???
            //
            var t1 = Point.{
                .x = undefined,
                .y = undefined,
            };
            var t2 = Point.{
                .x = undefined,
                .y = undefined,
            };
            if (is_left) {
                t1 = Point.{
                    .x = win_center.x - largest_distance,
                    .y = win_center.y - largest_distance,
                };
                t2 = Point.{
                    .x = win_center.x - largest_distance,
                    .y = win_center.y + largest_distance,
                };
            } else if (is_up) {
                t1 = Point.{
                    .x = win_center.x - largest_distance,
                    .y = win_center.y - largest_distance,
                };
                t2 = Point.{
                    .x = win_center.x + largest_distance,
                    .y = win_center.y - largest_distance,
                };
            } else if (is_right) {
                t1 = Point.{
                    .x = win_center.x + largest_distance,
                    .y = win_center.y - largest_distance,
                };
                t2 = Point.{
                    .x = win_center.x + largest_distance,
                    .y = win_center.y + largest_distance,
                };
            } else if (is_down) {
                t1 = Point.{
                    .x = win_center.x - largest_distance,
                    .y = win_center.y + largest_distance,
                };
                t2 = Point.{
                    .x = win_center.x + largest_distance,
                    .y = win_center.y + largest_distance,
                };
            }

            var window_node = screen.windows.first.?.next;
            var closest_win: xcb_window_t = blk: {
                if (is_right or is_down) {
                    break :blk std.math.maxInt(u32);
                }

                break :blk u32(0);
            };
            var closest_win_distance: u16 = std.math.maxInt(u16);
            while (window_node != null) : (window_node = window_node.?.next) {
                _ = _xcb_get_geometry(dpy, window_node.?.data, &return_geo);
                const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

                var closest_win_point = Point.{
                    .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                    .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
                };

                if (pointInTriangle(closest_win_point, win_center, t1, t2)) {
                    var new_distance = blk: {
                        var p1 = try std.math.powi(i32, win_center.x - closest_win_point.x, 2);
                        var p2 = try std.math.powi(i32, win_center.y - closest_win_point.y, 2);
                        break :blk std.math.sqrt(p1 + p2);
                    };

                    if (new_distance == 0 or new_distance == closest_win_distance) {
                        if ((is_right or is_down) and window_node.?.data > win.?.value.id and window_node.?.data < closest_win) {
                            closest_win = window_node.?.data;
                            closest_win_distance = new_distance;
                        } else if ((is_left or is_up) and window_node.?.data < win.?.value.id and window_node.?.data > closest_win) {
                            closest_win = window_node.?.data;
                            closest_win_distance = new_distance;
                        }
                    } else if (new_distance < closest_win_distance) {
                        closest_win = window_node.?.data;
                        closest_win_distance = new_distance;
                    } 
                }

            }

            // TODO: Improve screen checking. ??? Edge case
            // At the moment all the screens on the same 'row' are checked.
            // Need to only check previous(opposite direction of movement)
            // screen and all the next(direction of movement) screens.
            // Edge case: Window spans multiple screens and window's
            // midpoint is located on the previous screen.
            const screen_bottom_y = (screen.y + @intCast(i32, screen.height));
            const screen_right_x = (screen.x + @intCast(i32, screen.width));
            var screen_node = screens.first;
            while (screen_node != null) : (screen_node = screen_node.?.next) {
                if (screen_node.?.data.id == screen.id) continue;
                // if (is_left and screen_node.?.data.x > screen.x) continue;
                // if (is_right and screen_node.?.data.x < screen.x) continue;
                // if (is_up and screen_node.?.data.y > screen.y) continue;
                // if (is_down and screen_node.?.data.y < screen.y) continue;

                // @ChangeBasedOnDirection
                if (is_left or is_right) {
                    const screen_midpoint = screen_node.?.data.y + @intCast(i16, screen_node.?.data.height / 2);
                    if (screen_midpoint < screen.y or screen_midpoint > screen_bottom_y) continue;
                } else if (is_up or is_down) {
                    const screen_midpoint = screen_node.?.data.x + @intCast(i16, screen_node.?.data.width / 2);
                    if (screen_midpoint < screen.x or screen_midpoint > screen_right_x) continue;
                }

                var screen_window_node = screen_node.?.data.windows.first;
                while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
                    _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
                    const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
                    const x_midpoint = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width);
                    const y_midpoint = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width);
                    // @ChangeBasedOnDirection
                    if (is_left and x_midpoint > win_center.x) {
                        continue;
                    } else if (is_up and y_midpoint > win_center.y) {
                        continue;
                    } else if (is_right and x_midpoint < win_center.x) {
                        continue;
                    } else if (is_down and y_midpoint < win_center.y) {
                        continue;
                    }

                    const closest_win_point = Point.{
                        .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                        .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
                    };

                    const new_distance = blk: {
                        var p1 = try std.math.powi(i32, win_center.x - closest_win_point.x, 2);
                        var p2 = try std.math.powi(i32, win_center.y - closest_win_point.y, 2);
                        break :blk std.math.sqrt(p1 + p2);
                    };

                    if (new_distance == 0 or new_distance == closest_win_distance) {
                        if ((is_right or is_down) and screen_window_node.?.data > win.?.value.id and screen_window_node.?.data < closest_win) {
                            closest_win = screen_window_node.?.data;
                            closest_win_distance = new_distance;
                        } else if ((is_left or is_up) and screen_window_node.?.data < win.?.value.id and screen_window_node.?.data > closest_win) {
                            closest_win = screen_window_node.?.data;
                            closest_win_distance = new_distance;
                        }
                    } else if (new_distance < closest_win_distance) {
                        closest_win = screen_window_node.?.data;
                        closest_win_distance = new_distance;
                    } 
                }

            }

            if (closest_win != 0 and closest_win != std.math.maxInt(u32)) {
                var screen_window_node = new_screen.windows.first.?.next;
                while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
                    if (screen_window_node.?.data == closest_win) {
                        new_screen.windows.remove(screen_window_node.?);
                        new_screen.windows.prepend(screen_window_node.?);
                        break;
                    }
                }
                unfocusWindow(dpy, win.?.value.id, g_default_border_color);
                focusWindow(dpy, closest_win, g_active_border_color);
            }
        } else if (keysym == @intCast(u32, xlib.XStringToKeysym(c"t"))) {
            warn("open xterm\n");
            var argv = []const []const u8.{"xterm"};
            var child_result = try child.init(argv, allocator);
            var env_map = try os.getEnvMap(allocator);
            child_result.env_map = &env_map;
            _ = try child.spawn(child_result);
        } else {
            var groups_slice = groups.toSlice();
            group_start: for (group_strings) |char, i| {
                // TODO: Empty group is first but there is also
                // active window. Have to hide either of them if selected
                if (keysym == @intCast(u32, xlib.XStringToKeysym(char))) {
                    warn("group press\n");
                    var active_screen = blk: {
                        if (e.child != 0) {
                            var win = windows.get(e.child);
                            break :blk getScreen(win.?.value.screen_id, screens);
                        }
                        break :blk getActiveMouseScreen(screens);
                    };

                    var selected_group = groups_slice[i];
                    var active_group = groups_slice[active_screen.groups.first.?.data];

                    if (active_screen.groups.len == 1 and selected_group.index == active_group.index) break;


                    var group_screen = blk: {
                        var screen_node = screens.first;
                        while (screen_node != null) : (screen_node = screen_node.?.next) {
                            // NOTE: Breaks out the whole loop
                            // Happens if group was found on another screen
                            // and that screen only has one group
                            if (screen_node.?.data.groups.len == 1 and screen_node.?.data.groups.first.?.data == selected_group.index and screen_node.?.data.id != active_screen.id) {
                                break :group_start;
                            }

                            var group_node = screen_node.?.data.groups.first;
                            while (group_node != null) : (group_node = group_node.?.next) {
                                if (group_node.?.data == selected_group.index) {
                                    warn("screen {} has group {}\n", screen_node.?.data.id, selected_group.index);
                                    screen_node.?.data.groups.remove(group_node.?);
                                    screen_node.?.data.groups.destroyNode(group_node.?, allocator);
                                    break :blk &screen_node.?.data;
                                }
                            }

                        }
                        break :blk null;
                    };


                    // Remove and unmap windows from existing group's screen
                    if (group_screen) |screen| {
                        warn("group existed on another screen");
                        var window_node = selected_group.windows.last;
                        while (window_node != null) : (window_node = window_node.?.prev) {
                            const id = window_node.?.data;

                            if (screen.removeWindow(id, allocator)) {
                                _ = _xcb_unmap_window(dpy, window_node.?.data, &return_cookie);
                            }
                        }
                    }

                    if (active_group.index != selected_group.index) {

                        // Add and map windows to Screen from Group's windows
                        var group_window_node = selected_group.windows.last;
                        while (group_window_node != null) : (group_window_node = group_window_node.?.prev) {

                            active_screen.addWindow(group_window_node.?.data, allocator);

                            var window_info = windows.get(group_window_node.?.data);
                            if (window_info.?.value.screen_id != active_screen.id) {
                                var window_screen = getScreen(window_info.?.value.screen_id, screens);
                                moveWindowBetweenScreens(dpy, &window_info.?.value, window_screen.*, active_screen.*);
                            }

                            raiseWindow(dpy, window_info.?.value.id);
                            _ = _xcb_map_window(dpy, group_window_node.?.data, &return_cookie);

                        }

                        var new_group_node = try active_screen.groups.createNode(@intCast(u8, i), allocator);
                        active_screen.groups.prepend(new_group_node);
                    }

                    if (active_screen.windows.first) |window_id| {
                        var focused_window = getFocusedWindow(dpy);
                        unfocusWindow(dpy, focused_window, g_default_border_color);
                        focusWindow(dpy, window_id.data, g_active_border_color);
                    }

                    break;
                }
            }

    debugScreens(screens, windows);
    debugWindows(windows);
    debugGroups(groups);
        }

    } else if (e.state == _XCB_MOD_MASK_1 | _XCB_MOD_MASK_SHIFT) {
        const is_left = keysym == @intCast(u32, xlib.XStringToKeysym(c"h"));
        const is_up = keysym == @intCast(u32, xlib.XStringToKeysym(c"k"));
        const is_right = keysym == @intCast(u32, xlib.XStringToKeysym(c"l"));
        const is_down = keysym == @intCast(u32, xlib.XStringToKeysym(c"j"));

        if (is_left) {
            warn("shift left\n");
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            const win = windows.get(e.event);
            var screen = getScreen(win.?.value.screen_id, screens);

            var new_x = @intCast(i32, win_geo.x);
            const tile_width: i32 = @divTrunc(screen.width - 2 * g_screen_padding, g_grid_cols);

            const win_total_width = @intCast(i16, win_geo.width + 2 * g_border_width);
            var x_tile_locations = try getGridCols(allocator, screen.*);
            defer x_tile_locations.deinit();

            const screen_padding = @intCast(i16, g_screen_padding);
            const win_edge_x = win_geo.x + win_total_width;
            const win_abs_x = win_geo.x - screen.x - screen_padding;
            const win_abs_edge_x = win_abs_x + win_total_width;
            var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_x) / @intToFloat(f32, tile_width)));
            var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_x) / @intToFloat(f32, tile_width)));

            var on_left = @rem(win_abs_x, tile_width) == 0;
            var on_right = (screen.x + @intCast(i16, screen.width) - screen_padding == win_edge_x) or (@rem(win_abs_edge_x, tile_width) == 0);

            if (on_left or (@intCast(i32, x_tile_locations.len) == grid_loc)) {
                grid_loc -= 1;
            }

            if (on_right or win_total_width < tile_width) {
                grid_edge_loc -= 1;
            }

            if (grid_loc >= 0 and grid_loc < @intCast(i32, x_tile_locations.len)) {
                new_x = x_tile_locations.at(@intCast(usize, grid_loc));
                const new_edge_x = new_x + win_total_width;
                const screen_edge = screen.x + @intCast(i32, screen.width) - screen_padding;

                if ((new_edge_x > screen_edge and win_edge_x < screen_edge)
                    or (win_edge_x > screen_edge and new_edge_x < screen_edge)
                ) {
                    new_x = screen_edge - win_total_width;
                }
                warn("inside\n");
            } else if (grid_edge_loc > 0 and grid_edge_loc < @intCast(i32, x_tile_locations.len)) {
                warn("outside\n");
                var index = @intCast(usize, grid_edge_loc);
                const right_edge = x_tile_locations.at(index);
                new_x = right_edge - win_total_width;
            } else {
                const x = win_geo.x - @intCast(i16, tile_width);
                const win_edge_y = win_geo.y + @intCast(i16, win_geo.height + 2 * g_border_width);
                const new_screen = getScreenBasedOnCoords(x, win_geo.y + screen_padding, screens) orelse getScreenBasedOnCoords(x, win_edge_y - screen_padding, screens);
                warn("screen\n");

                if (new_screen != null and screen.id != new_screen.?.id) {
                warn("screen cont\n");
                    _ = screen.removeWindow(win.?.value.id, allocator);
                    new_screen.?.addWindow(win.?.value.id, allocator);

                    const group_index = screen.groups.first.?.data;
                    const new_group_index = new_screen.?.groups.first.?.data;
                    const groups_slice = groups.toSlice();

                    groups_slice[group_index].removeWindow(win.?.value.id, allocator);
                    groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

                    win.?.value.screen_id = new_screen.?.id;
                    win.?.value.group_index = new_group_index;

                    new_x = new_screen.?.x + @intCast(i16, new_screen.?.width) - screen_padding - win_total_width;
                }
            }

            if (new_x != win_geo.x) {
                moveWindow(dpy, e.event, new_x, win_geo.y);
            }
        } else if (is_right) {
            warn("shift right\n");
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            const win = windows.get(e.event);
            var screen = getScreen(win.?.value.screen_id, screens);

            var new_x = @intCast(i32, win_geo.x);
            const tile_width: i32 = @divTrunc(screen.width - 2 * g_screen_padding, g_grid_cols);

            const win_total_width = @intCast(i16, win_geo.width + 2 * g_border_width);
            const breakpoints = try getGridCols(allocator, screen.*);
            defer breakpoints.deinit();
            const brkpts_len = @intCast(i32, breakpoints.len);

            const screen_padding = @intCast(i16, g_screen_padding);
            const screen_edge = screen.x + @intCast(i32, screen.width) - screen_padding;
            const win_edge_x = win_geo.x + win_total_width;
            const win_abs_x = win_geo.x - screen.x - screen_padding;
            const win_abs_edge_x = win_abs_x + win_total_width;
            var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_x) / @intToFloat(f32, tile_width)));
            var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_x) / @intToFloat(f32, tile_width)));

            const on_left = @rem(win_abs_x, tile_width) == 0;
            const on_right = (screen.x + @intCast(i16, screen.width) - screen_padding == win_edge_x) or (@rem(win_abs_edge_x, tile_width) == 0);

            if (grid_loc != -1 or (on_right and grid_loc == -1)) {
                grid_loc += 1;
            }

            if (win_total_width < tile_width and (win_edge_x >= screen_edge or grid_loc == -1)) {
                grid_loc += 1;
            }

            grid_edge_loc += 1;

            if (grid_loc >= 0 and grid_loc < brkpts_len) {
                new_x = breakpoints.at(@intCast(usize, grid_loc));
                const new_edge_x = new_x + win_total_width;

                if ((new_edge_x > screen_edge and win_edge_x < screen_edge)
                    or (win_edge_x > screen_edge and new_edge_x < screen_edge)
                ) {
                    new_x = screen_edge - win_total_width;
                }
                warn("inside\n");
            } else if (grid_edge_loc > 0 and grid_edge_loc < brkpts_len) {
                warn("outside\n");
                var index = @intCast(usize, grid_edge_loc);
                const right_edge = breakpoints.at(index);
                new_x = right_edge - win_total_width;
            } else if (win_total_width < tile_width and grid_loc == brkpts_len) {
                warn("window width < tile width\n");
                new_x = screen_edge - win_total_width;
            } else {
                const x = win_geo.x + win_total_width + @intCast(i16, tile_width);
                const win_edge_y = win_geo.y + @intCast(i16, win_geo.height + 2 * g_border_width);
                const new_screen = getScreenBasedOnCoords(x, win_geo.y + screen_padding, screens) orelse getScreenBasedOnCoords(x, win_edge_y - screen_padding, screens);
                warn("screen\n");

                if (new_screen != null and screen.id != new_screen.?.id) {
                warn("screen cont\n");
                    _ = screen.removeWindow(win.?.value.id, allocator);
                    new_screen.?.addWindow(win.?.value.id, allocator);

                    const group_index = screen.groups.first.?.data;
                    const new_group_index = new_screen.?.groups.first.?.data;
                    const groups_slice = groups.toSlice();

                    groups_slice[group_index].removeWindow(win.?.value.id, allocator);
                    groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

                    win.?.value.screen_id = new_screen.?.id;
                    win.?.value.group_index = new_group_index;

                    new_x = new_screen.?.x + screen_padding;
                }
            }

            if (new_x != win_geo.x) {
                moveWindow(dpy, e.event, new_x, win_geo.y);
            }
        } else if (is_up) {
            warn("shift up\n");
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            const win = windows.get(e.event);
            var screen = getScreen(win.?.value.screen_id, screens);

            var new_y = @intCast(i32, win_geo.y);
            const tile_height: i32 = @divTrunc(screen.height - 2 * g_screen_padding, g_grid_rows);

            const win_total_height = @intCast(i16, win_geo.height + 2 * g_border_width);
            var breakpoints = try getGridRows(allocator, screen.*);
            defer breakpoints.deinit();

            const screen_padding = @intCast(i16, g_screen_padding);
            const win_edge_y = win_geo.y + win_total_height;
            const win_abs_y = win_geo.y - screen.y - screen_padding;
            const win_abs_edge_y = win_abs_y + win_total_height;
            var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_y) / @intToFloat(f32, tile_height)));
            var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_y) / @intToFloat(f32, tile_height)));

            var on_top = @rem(win_abs_y, tile_height) == 0;
            var on_bottom = (screen.y + @intCast(i16, screen.height) - screen_padding == win_edge_y) or (@rem(win_abs_edge_y, tile_height) == 0);

            if (on_top or (@intCast(i32, breakpoints.len) == grid_loc)) {
                grid_loc -= 1;
            }

            if (on_bottom or win_total_height < tile_height) {
                grid_edge_loc -= 1;
            }

            if (grid_loc >= 0 and grid_loc < @intCast(i32, breakpoints.len)) {
                new_y = breakpoints.at(@intCast(usize, grid_loc));
                const new_edge_y = new_y + win_total_height;
                const screen_edge = screen.y + @intCast(i32, screen.height) - screen_padding;

                if ((new_edge_y > screen_edge and win_edge_y < screen_edge)
                    or (win_edge_y > screen_edge and new_edge_y < screen_edge)
                ) {
                    new_y = screen_edge - win_total_height;
                }
                warn("inside {}\n", new_y);
            } else if (grid_edge_loc > 0 and grid_edge_loc < @intCast(i32, breakpoints.len)) {
                warn("outside\n");
                var index = @intCast(usize, grid_edge_loc);
                const bottom_edge = breakpoints.at(index);
                new_y = bottom_edge - win_total_height;
            } else {
                const y = win_geo.y - @intCast(i16, tile_height);
                const win_edge_x = win_geo.x + @intCast(i16, win_geo.width + 2 * g_border_width);
                const new_screen = getScreenBasedOnCoords(win_geo.x + screen_padding, y, screens) orelse getScreenBasedOnCoords(win_edge_x - screen_padding, y, screens);
                warn("screen\n");

                if (new_screen != null and screen.id != new_screen.?.id) {
                warn("screen cont\n");
                    _ = screen.removeWindow(win.?.value.id, allocator);
                    new_screen.?.addWindow(win.?.value.id, allocator);

                    const group_index = screen.groups.first.?.data;
                    const new_group_index = new_screen.?.groups.first.?.data;
                    const groups_slice = groups.toSlice();

                    groups_slice[group_index].removeWindow(win.?.value.id, allocator);
                    groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

                    win.?.value.screen_id = new_screen.?.id;
                    win.?.value.group_index = new_group_index;

                    new_y = new_screen.?.y + @intCast(i16, new_screen.?.height) - screen_padding - win_total_height;
                }
            }

            if (new_y != win_geo.y) {
                moveWindow(dpy, e.event, win_geo.x, new_y);
            }
        } else if (is_down) {
            warn("shift down\n");
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, e.event, &return_geo);
            const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

            const win = windows.get(e.event);
            var screen = getScreen(win.?.value.screen_id, screens);

            var new_y = @intCast(i32, win_geo.y);
            const tile_height: i32 = @divTrunc(screen.height - 2 * g_screen_padding, g_grid_rows);

            const win_total_height = @intCast(i16, win_geo.height + 2 * g_border_width);
            var breakpoints = try getGridRows(allocator, screen.*);
            defer breakpoints.deinit();
            const brkpts_len = @intCast(i32, breakpoints.len);

            const screen_padding = @intCast(i16, g_screen_padding);
            const screen_edge = screen.y + @intCast(i32, screen.height) - screen_padding;
            const win_edge_y = win_geo.y + win_total_height;
            const win_abs_y = win_geo.y - screen.y - screen_padding;
            const win_abs_edge_y = win_abs_y + win_total_height;
            var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_y) / @intToFloat(f32, tile_height)));
            var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_y) / @intToFloat(f32, tile_height)));

            var on_top = @rem(win_abs_y, tile_height) == 0;
            var on_bottom = (screen.y + @intCast(i16, screen.height) - screen_padding == win_edge_y) or (@rem(win_abs_edge_y, tile_height) == 0);

            if (grid_loc != -1 or (on_bottom and grid_loc == -1)) {
                grid_loc += 1;
            }

            if (win_total_height < tile_height and (win_edge_y >= screen_edge or grid_loc == -1)) {
                grid_loc += 1;
            }

            grid_edge_loc += 1;

            if (grid_loc >= 0 and grid_loc < brkpts_len) {
                new_y = breakpoints.at(@intCast(usize, grid_loc));
                const new_edge_y = new_y + win_total_height;

                if ((new_edge_y > screen_edge and win_edge_y < screen_edge)
                    or (win_edge_y > screen_edge and new_edge_y < screen_edge)
                ) {
                    new_y = screen_edge - win_total_height;
                }
                warn("inside\n");
            } else if (grid_edge_loc > 0 and grid_edge_loc < brkpts_len) {
                warn("outside\n");
                var index = @intCast(usize, grid_edge_loc);
                const bottom_edge = breakpoints.at(index);
                new_y = bottom_edge - win_total_height;
            } else if (win_total_height < tile_height and grid_loc == brkpts_len) {
                warn("window width < tile width\n");
                new_y = screen_edge - win_total_height;
            } else {
                const y = win_geo.y + win_total_height + @intCast(i16, tile_height);
                const win_edge_x = win_geo.x + @intCast(i16, win_geo.width + 2 * g_border_width);
                const new_screen = getScreenBasedOnCoords(win_geo.x + screen_padding, y, screens) orelse getScreenBasedOnCoords(win_edge_x - screen_padding, y, screens);
                warn("screen\n");

                if (new_screen != null and screen.id != new_screen.?.id) {
                warn("screen cont\n");
                    _ = screen.removeWindow(win.?.value.id, allocator);
                    new_screen.?.addWindow(win.?.value.id, allocator);

                    const group_index = screen.groups.first.?.data;
                    const new_group_index = new_screen.?.groups.first.?.data;
                    const groups_slice = groups.toSlice();

                    groups_slice[group_index].removeWindow(win.?.value.id, allocator);
                    groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

                    win.?.value.screen_id = new_screen.?.id;
                    win.?.value.group_index = new_group_index;

                    new_y = new_screen.?.y + screen_padding;
                }
            }

            if (new_y != win_geo.y) {
                moveWindow(dpy, e.event, win_geo.x, new_y);
            }
        } else {
            for (groups.toSlice()) |const_target_group, i| {
                var target_group = &groups.toSlice()[i];
                if (keysym == @intCast(u32, xlib.XStringToKeysym(group_strings[i]))) {
                var window = windows.get(e.event);
                if (target_group.index == window.?.value.group_index) break;

                warn("move window to a group\n");
                var window_screen = getScreen(window.?.value.screen_id, screens);
                var group_windows = &groups.toSlice()[window.?.value.group_index].windows;
                var group_node = group_windows.first;
                while (group_node != null) : (group_node = group_node.?.next) {
                    if (group_node.?.data == window.?.value.id) {
                        group_windows.remove(group_node.?);
                        group_windows.destroyNode(group_node.?, allocator);
                        break;
                    }
                }

                var screen_node = screens.first;
                screen_loop: while (screen_node != null) : (screen_node = screen_node.?.next) {
                    var window_node = screen_node.?.data.windows.first;
                    while (window_node != null) : (window_node = window_node.?.next) {
                        if (window_node.?.data == window.?.value.id) {
                            unfocusWindow(dpy, window.?.value.id, g_default_border_color);
                            screen_node.?.data.windows.remove(window_node.?);
                            screen_node.?.data.windows.destroyNode(window_node.?, allocator);
                            break :screen_loop;
                        }
                    }
                }

                _ = _xcb_unmap_window(dpy, window.?.value.id, &return_cookie);

                var new_node = try target_group.windows.createNode(window.?.value.id, allocator);
                target_group.windows.prepend(new_node);
                window.?.value.group_index = target_group.index;

                screen_node = screens.first;
                screen_loop: while (screen_node != null) : (screen_node = screen_node.?.next) {
                    var screen_group_node = screen_node.?.data.groups.first;
                    while (screen_group_node != null) : (screen_group_node = screen_group_node.?.next) {
                        if (screen_group_node.?.data == target_group.index) {
                            var new_win_node = try screen_node.?.data.windows.createNode(window.?.value.id, allocator);
                            screen_node.?.data.windows.prepend(new_win_node);

                            if (window.?.value.screen_id != screen_node.?.data.id) {
                                moveWindowBetweenScreens(dpy, &window.?.value, window_screen.*, screen_node.?.data);
                            }
                            // raiseWindow(dpy, window.?.value.id);
                            _ = _xcb_map_window(dpy, window.?.value.id, &return_cookie);
                            break :screen_loop;
                        }
                    }
                }


                // TODO: Or focus new window the screen the source/target
                // (var window_screen) window was ???
                if (getActiveMouseScreen(screens).windows.first) |new_focus| {
                    focusWindow(dpy, new_focus.data, g_active_border_color);
                }

                break;
                }
            }
        }
    debugScreens(screens, windows);
    debugWindows(windows);
    debugGroups(groups);

    }

    _ = xcb_flush(dpy);
}


fn keypressMoveLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("move left func\n");
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    var win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);
    var new_x = win_geo.x - @intCast(i16, g_window_move_x);

    var new_edge_x = @intCast(i16, new_x) + @intCast(i16, win_geo.width + 2 * g_border_width);
    if (new_x > screen.x or new_edge_x > screen.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    } else {
        const new_screen = getScreenBasedOnCoords(new_edge_x, win_geo.y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, new_x, win_geo.y);

            _ = screen.removeWindow(win.?.value.id, allocator);
            new_screen.?.addWindow(win.?.value.id, allocator);

            var group_index = screen.groups.first.?.data;
            var new_group_index = new_screen.?.groups.first.?.data;

            var groups_slice = groups.toSlice();
            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;
        }
    }
}


fn keypressMoveRight(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("move right func\n");
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    var win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);
    var new_x = win_geo.x + @intCast(i16, g_window_move_x);

    var new_edge_x = @intCast(i16, new_x) + @intCast(i16, win_geo.width + 2 * g_border_width);
    if ((new_x < screen.x + @intCast(i16, screen.width))
    or  (new_edge_x < screen.x + @intCast(i16, screen.width))) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    } else {
        const new_screen = getScreenBasedOnCoords(new_x, win_geo.y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, new_x, win_geo.y);

            _ = screen.removeWindow(win.?.value.id, allocator);
            new_screen.?.addWindow(win.?.value.id, allocator);

            var group_index = screen.groups.first.?.data;
            var new_group_index = new_screen.?.groups.first.?.data;

            var groups_slice = groups.toSlice();
            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;
        }
    }
}
