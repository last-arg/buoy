const std = @import("std");
const fmt = std.fmt;
const cstr = std.cstr;
const warn = std.debug.warn;
const panic = std.debug.panic;
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

// TODO: combine ScreenGeometry and Geometry
const ScreenGeometry = struct.{
    x: i16,
    y: i16,
    width: u16,
    height: u16,
};

const Screen = ScreenFn();
fn ScreenFn() type {
    return struct.{
        const Self = @This();
        allocator: *Allocator,
        id: u32,
        geo: ScreenGeometry,
        groups: LinkedList(u8),
        windows: LinkedList(xcb_window_t),

        pub fn init(id: u32, group_index: u8, geo: ScreenGeometry, allocator: *Allocator) !Self {
            var screen = Self.{
                .id = id,
                .allocator = allocator,
                .geo = geo,
                .groups = LinkedList(u8).init(),
                .windows = LinkedList(xcb_window_t).init(),
            };

            // TODO: add group to window
            var group_node = try screen.groups.createNode(group_index, allocator);
            screen.groups.prepend(group_node);

            return screen;
        }

        pub fn addWindow(self: *Screen, id: xcb_window_t) void {
            const node = self.windows.createNode(id, self.allocator) catch |err| {
                warn("Error was raised when trying to add new window to Screen. Error msg: {}\n", err);
                return;
            };
            self.windows.prepend(node);
        }

        pub fn removeWindow(self: *Screen, id: xcb_window_t) bool {
            var node = self.windows.first;
            while (node != null) : (node = node.?.next) {
                if (id == node.?.data) {
                    self.windows.remove(node.?);
                    self.windows.destroyNode(node.?, self.allocator);
                    return true;
                }
            }
            return false;
        }

        pub fn destroyGroup(self: *Screen, id: u8) bool {
            var node = self.groups.first;
            while (node != null) : (node = node.?.next) {
                if (id == node.?.data) {
                    self.groups.remove(node.?);
                    self.groups.destroyNode(node.?, self.allocator);
                    return true;
                }
            }
            return false;
        }

        pub fn addGroup(self: *Screen, id: u8) void {
            const node = self.groups.createNode(id, self.allocator) catch |err| {
                warn("Error was raised when trying to add new group to Screen. Error msg: {}\n", err);
                return;
            };
            self.groups.prepend(node);
        }


        // TODO: separate function for window resizing or add a parameter/flag to this function
        pub fn windowToScreen(self: *Screen, win: *Window, dest_screen: *Screen, groups: []Group) Window {
            // Remove window from self.windows
            _ = self.removeWindow(win.id);
            // Remove window from current group(_index)
            groups[win.group_index].removeWindow(win.id, self.allocator);
            // Add window to dest_screen.windows
            dest_screen.addWindow(win.id);
            win.screen_id = dest_screen.id;
            win.group_index = dest_screen.groups.first.?.data;
            // Add window to dest_screen's first/active group
            groups[win.group_index].addWindow(win.id, self.allocator);

            return win.*;
        }

        // TODO: rename to recalculateWindowGeometry()
        pub fn windowToScreenRender(self: *Screen, dpy: ?*xcb_connection_t, win: *Window, dest_screen: *Screen) void {
            var return_geo: xcb_get_geometry_cookie_t = undefined;
            _ = _xcb_get_geometry(dpy, win.id, &return_geo);
            var geo = xcb_get_geometry_reply(dpy, return_geo, null);

            var new_width = @intToFloat(f32, geo.?[0].width) * (@intToFloat(f32, dest_screen.geo.width) / @intToFloat(f32, self.geo.width));
            var new_height = @intToFloat(f32, geo.?[0].height) * (@intToFloat(f32, dest_screen.geo.height) / @intToFloat(f32, self.geo.height));

            var new_x = geo.?[0].x;
            if (dest_screen.geo.x < self.geo.x) {
                new_x -= self.geo.x;
            } else if (dest_screen.geo.x > self.geo.x) {
                new_x += dest_screen.geo.x;
            }

            var new_y = geo.?[0].y;
            if (dest_screen.geo.y < self.geo.y) {
                new_y -= self.geo.y;
            } else if (dest_screen.geo.y > self.geo.y) {
                new_y += dest_screen.geo.y;
            }

            moveWindow(dpy, win.id, new_x, new_y);
            resizeWindow(dpy, win.id, @floatToInt(u32, new_width), @floatToInt(u32, new_height));

            win.screen_id = dest_screen.id;
        }
    };
}


// TODO: add allocator field
const Group = struct.{
    index: u8,
    windows: LinkedList(xcb_window_t),
    str_value: []u8,

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
    geo: Geometry,
};

const Geometry = struct.{
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};

const Point = struct.{
    x: i32,
    y: i32,
};

fn getWindowHash(id: c_ulong) u32 {
    return @intCast(u32, id);
}

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
var g_screen_root: xcb_window_t = undefined;


const g_mod = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
const g_mask_alt = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
const g_mask_ctrl = @intCast(u16, @enumToInt(XCB_MOD_MASK_CONTROL));
const g_mask_shift = @intCast(u16, @enumToInt(XCB_MOD_MASK_SHIFT));

// TODO: Make 'Move', 'Shift', 'Change' into Direction union ???
const KeyFunc = union(enum).{
    Move: @typeOf(keypressMoveLeft),
    Shift: @typeOf(keypressShiftLeft),
    Change: @typeOf(keypressChangeLeft),
    WindowToGroup: @typeOf(keypressWindowToGroup),
    ToggleGroup: @typeOf(keypressToggleGroup),
    Spawn: []const []const u8,
    Debug: []const []const u8,
};

const Key = struct.{
    const Self = @This();
    char: [1] u8,
    mod: u16,
    func: KeyFunc,

    pub fn create(char: [1]u8, mod: u16, func: KeyFunc) Self {
        return Self.{
            .char = char,
            .mod = mod,
            .func = func,
        };
    }
};


const MouseAction = enum.{
    Resize,
    Move,
    ResizeInBounds,
    MoveInBounds,
};

const MouseEvent = struct.{
    const Self = @This();
    index: u8,
    mod: u16,
    action: MouseAction,

    pub fn create(index: u8, mod: u16, action: MouseAction) Self {
        return Self.{
            .index = index,
            .mod = mod,
            .action = action,
        };
    }
};


var mouse_mapping = []MouseEvent.{
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_1)), g_mod, MouseAction.MoveInBounds),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_1)), g_mod | g_mask_shift, MouseAction.Move),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_3)), g_mod, MouseAction.ResizeInBounds),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_3)), g_mod | g_mask_shift, MouseAction.Resize),
};


var root_keymap = []Key.{
    Key.create("d", g_mod, KeyFunc.{.Debug = []const []const u8.{"all"}}),

    Key.create("t", g_mod, KeyFunc.{.Spawn = []const []const u8.{"xterm"}}),
    Key.create("r", g_mod, KeyFunc.{.Spawn = []const []const u8.{"st"}}),

    Key.create("1", g_mod, KeyFunc.{.ToggleGroup = keypressToggleGroup}),
    Key.create("2", g_mod, KeyFunc.{.ToggleGroup = keypressToggleGroup}),
    Key.create("3", g_mod, KeyFunc.{.ToggleGroup = keypressToggleGroup}),
    Key.create("4", g_mod, KeyFunc.{.ToggleGroup = keypressToggleGroup}),
    Key.create("5", g_mod, KeyFunc.{.ToggleGroup = keypressToggleGroup}),
};

var keymap = []Key.{
    Key.create("h", g_mod | g_mask_ctrl, KeyFunc.{.Move = keypressMoveLeft}),
    Key.create("l", g_mod | g_mask_ctrl, KeyFunc.{.Move = keypressMoveRight}),
    Key.create("k", g_mod | g_mask_ctrl, KeyFunc.{.Move = keypressMoveUp}),
    Key.create("j", g_mod | g_mask_ctrl, KeyFunc.{.Move = keypressMoveDown}),

    Key.create("h", g_mod | g_mask_shift, KeyFunc.{.Shift = keypressShiftLeft}),
    Key.create("l", g_mod | g_mask_shift, KeyFunc.{.Shift = keypressShiftRight}),
    Key.create("k", g_mod | g_mask_shift, KeyFunc.{.Shift = keypressShiftUp}),
    Key.create("j", g_mod | g_mask_shift, KeyFunc.{.Shift = keypressShiftDown}),

    Key.create("h", g_mod, KeyFunc.{.Change = keypressChangeLeft}),
    Key.create("l", g_mod, KeyFunc.{.Change = keypressChangeRight}),
    Key.create("k", g_mod, KeyFunc.{.Change = keypressChangeUp}),
    Key.create("j", g_mod, KeyFunc.{.Change = keypressChangeDown}),

    Key.create("1", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),
    Key.create("2", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),
    Key.create("3", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),
    Key.create("4", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),
    Key.create("5", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),

    Key.create("5", g_mod | g_mask_shift, KeyFunc.{.WindowToGroup = keypressWindowToGroup}),

};


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
    g_screen_root = screen_root;

    var return_cookie: xcb_void_cookie_t = undefined;

    var value_list = []c_int.{
        @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT)
        // | @enumToInt(XCB_EVENT_MASK_EXPOSURE)
        // | @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY)
        | @enumToInt(XCB_EVENT_MASK_POINTER_MOTION),
    };

    const root_attr_mask = _XCB_CW_EVENT_MASK;
    _ = _xcb_change_window_attributes(dpy, screen_root, root_attr_mask, @ptrCast(?*const c_void, &value_list), &return_cookie);
    // _ = _xcb_free_cursor(dpy, cursor_id, &return_cookie);


    // Set keyboard events
    {
        var key_symbols = xcb_key_symbols_alloc(dpy);
        var keysym: xlib.KeySym = undefined;
        var keycode: xcb_keycode_t = undefined;

        for (root_keymap) |key| {
            keysym = xlib.XStringToKeysym(&key.char);
            keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];

            _ = _xcb_grab_key(dpy, 1, screen_root, key.mod, keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_cookie);

        }

        xcb_key_symbols_free(key_symbols);
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
    if (group_count < @intCast(u8, number_of_monitors)) {
        warn("Number of groups is less than monitor count. Changing number of groups to {}", number_of_monitors);
        group_count = @intCast(u8, number_of_monitors);
    }
    if (group_count > 10) {
        warn("Groups count too large. Changing group count to 10");
        group_count = 10;
    }
    groups.resize(group_count) catch {
        panic("Failed to initalize groups' strcutures");
    };

    {
        var buffer: [2]u8 = undefined;
        var out = buffer[0..];
        var i: u8 = 0;
        while (i < group_count) : (i += 1) {
            var count = fmt.formatIntBuf(out, @rem(i + 1, 10), 10, false, 0);
            const val = mem.dupe(allocator, u8, out) catch {
                warn("Creating/Initializing groups error: Failed memory allocation for groups value field.\n");
                continue;
            };
            var group = Group.{
                .index = i,
                .windows = LinkedList(xcb_window_t).init(),
                .str_value = val,
            };
            groups.set(i, group);
        }
    }

    // Create Screens
    // TODO: Implement defer
    var screens = LinkedList(Screen).init();
    // TODO: implement fallback (else branch)
    if (number_of_monitors > 0) {
        var j: u8 = 0;
        var return_monitors_iter: xcb_randr_monitor_info_iterator_t = undefined;
        _ = _xcb_randr_get_monitors_monitors_iterator(monitors, &return_monitors_iter);
        // var is_set_has_mouse = false;
        while (return_monitors_iter.rem != 0) : ({
            _ = xcb_randr_monitor_info_next(@ptrCast(?[*]struct_xcb_randr_monitor_info_iterator_t ,&return_monitors_iter));
            j += 1;
        }) {
            var monitor = return_monitors_iter.data.?[0];

            var geo = ScreenGeometry.{
                .x = monitor.x,
                .y = monitor.y,
                .width = monitor.width,
                .height = monitor.height,
            };

            var screen = try Screen.init(monitor.name, j, geo, allocator);

            var node_ptr = try screens.createNode(screen, allocator);
            screens.append(node_ptr);

            var rects = try getGridRectangles(allocator, screen);
            _ = _xcb_clear_area(dpy, 1, screen_root, screen.geo.x, screen.geo.y, screen.geo.width, screen.geo.height, &return_cookie);
            drawScreenGrid(dpy, screen_root, root_gc_id, rects);
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
            setWindowEvents(dpy, win);
            _ = addWindow(dpy, allocator, win, active_screen, group, &windows);

        }

        if (getActiveMouseScreen(dpy, screens).windows.first) |win| {
            focusWindow(dpy, win.data, g_active_border_color);
        }
    }

    _ = xcb_flush(dpy);

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

                if ((e.value_mask & _XCB_CONFIG_WINDOW_X) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_X;
                    config_values[i] = e.x;
                    i += 1;
                }

                if ((e.value_mask & _XCB_CONFIG_WINDOW_Y) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_Y;
                    config_values[i] = e.y;
                    i += 1;
                }

                if ((e.value_mask & _XCB_CONFIG_WINDOW_WIDTH) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_WIDTH;
                    config_values[i] = e.width;
                    i += 1;
                }

                if ((e.value_mask & _XCB_CONFIG_WINDOW_HEIGHT) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_HEIGHT;
                    config_values[i] = e.height;
                    i += 1;
                }

                if ((e.value_mask & _XCB_CONFIG_WINDOW_SIBLING) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_SIBLING;
                    config_values[i] = @intCast(i32, e.sibling);
                    i += 1;
                }

                if ((e.value_mask & _XCB_CONFIG_WINDOW_STACK_MODE) > 0) {
                    config_mask = config_mask | _XCB_CONFIG_WINDOW_STACK_MODE;
                    config_values[i] = e.stack_mode;
                    i += 1;
                }

                if (i == 0) continue;

                var return_pointer: xcb_void_cookie_t = undefined;
                _ = _xcb_configure_window(dpy, e.window, config_mask, @ptrCast(?*const c_void, &config_values), &return_pointer);

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

                var active_screen = getActiveMouseScreen(dpy, screens);
                var group_index = active_screen.groups.first.?.data;
                var group = &groups.toSlice()[group_index];


                setWindowEvents(dpy, e.window);

                // TODO: set window location and dimensions
                resizeAndMoveWindow(dpy, e.window, active_screen);

                var attr_mask: u16 = _XCB_CW_EVENT_MASK;
                var attr_values = []u32.{_XCB_EVENT_MASK_ENTER_WINDOW | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY};
                _ = _xcb_change_window_attributes(dpy, e.window, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);


                if (!windows.contains(e.window)) {

                    _ = addWindow(dpy, allocator, e.window, active_screen, group, &windows);
                }

                _ = _xcb_map_window(dpy, e.window, &return_void_pointer);

                var focused_window = getFocusedWindow(dpy);
                unfocusWindow(dpy, focused_window, g_default_border_color);
                focusWindow(dpy, e.window, g_active_border_color);

                var config_mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_BORDER_WIDTH));
                var config_values = []i32.{g_border_width};
                _ = _xcb_configure_window(dpy, e.window, config_mask, @ptrCast(?*const c_void, &config_values), &return_void_pointer);

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
                buttonpressEvent(allocator, dpy, ev, screens, groups, windows, screen_root);
            },
            XCB_BUTTON_RELEASE => {
                warn("xcb: button release\n");
                _ = xcb_flush(dpy);
            },
            XCB_MOTION_NOTIFY => {
                // warn("xcb: motion notify\n");
                var e = @ptrCast(*xcb_motion_notify_event_t, &ev);

                if (e.child != 0) continue;

                var new_screen = getNewScreenOnChange(e.root_x, e.root_y, screens, getActiveMouseScreen(dpy, screens));

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
                keypressEvent(allocator, dpy, ev, screens, groups, windows);
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



fn inBoundsWindowGeometry(x: i32, y: i32, width: i32, height: i32, screen: *Screen) Geometry {
    var screen_width: i32 = screen.geo.width;
    var screen_height: i32 = screen.geo.height;
    var new_x = x - screen.geo.x;
    var new_y = y - screen.geo.y;
    var new_width = width;
    var new_height = height;
    const bw = @intCast(i32, g_border_width);
    const sp = @intCast(i32, g_screen_padding);


    // Width and x coordinate
    var win_total_width = new_width + 2 * bw;

    if ((new_x + win_total_width) >= screen_width) {
        new_x = new_x - (new_x + win_total_width - screen_width);
        new_width = screen_width - 2 * bw - (x - screen.geo.x) - sp;
    }

    new_x = std.math.max(sp, new_x - sp) + screen.geo.x;

    if (new_width < @intCast(i32, g_window_min_width)) {
        new_width = g_window_min_width;
    }


    // Height and y coordinate
    var win_total_height = new_height + 2 * bw;

    if ((new_y + win_total_height) >= screen_height) {
        new_y = new_y - (new_y + win_total_height - screen_height);
        new_height = screen_height - 2 * bw - (y - screen.geo.y) - sp;
    }

    new_y = std.math.max(sp, new_y - sp) + screen.geo.y;

    if (new_height < @intCast(i32, g_window_min_height)) {
        new_height = g_window_min_height;
    }

    return Geometry.{
        .x = new_x,
        .y = new_y,
        .width = new_width,
        .height = new_height,
    };
}

fn getWindowGeometryInside(w_attr: xcb_get_geometry_reply_t, screen: *Screen) Geometry {
    var screen_width:i32 = screen.geo.width;
    var screen_height:i32 = screen.geo.height;
    var x:i32 = w_attr.x - screen.geo.x;
    var y:i32 = w_attr.y - screen.geo.y;
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

    x = std.math.max(sp, x) + screen.geo.x;


    // Height and y coordinate
    var win_total_height = height + 2 * bw;

    if (win_total_height >= screen_height) {
        height = screen_height - 2 * sp;
    }

    win_total_height = height + 2 * bw;

    if ((y + win_total_height) >= screen_height) {
        y = y - (y + win_total_height - screen_height) - sp;
    }

    y = std.math.max(sp, y) + screen.geo.y;

    return Geometry.{
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
            // active_screen.has_mouse = false;
            // screen.?.data.has_mouse = true;
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
    var screen_x_right = screen.geo.x + @intCast(i32, screen.geo.width) - 1;
    var screen_y_bottom = screen.geo.y + @intCast(i32, screen.geo.height) - 1;

    return (x >= screen.geo.x)  and (x <= screen_x_right) 
            and (y >= screen.geo.y) and (y <= screen_y_bottom);
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
        warn("Screen: {}\n", item.?.data.index);
       warn("\twindows:");
        var w_node = item.?.data.windows.first;
        while (w_node != null) : (w_node = w_node.?.next) {
            warn(" {}", w_node.?.data);
        }
        warn("\n");
    }
}


fn addWindow(dpy: ?*xcb_connection_t, allocator: *Allocator, win: xcb_window_t, screen: *Screen, group: *Group, windows: *WindowsHashMap) !void {
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, win, &return_geo);
    var geo = xcb_get_geometry_reply(dpy, return_geo, null);

    if (geo == null) {
        warn("addWindow: Failed to get window's geometry information.\n");
        return;
    }

    const win_geo = Geometry.{
        .x = geo.?[0].x,
        .y = geo.?[0].y,
        .width = geo.?[0].width,
        .height = geo.?[0].height,
    };

    warn("new window geo: {}\n", win_geo);

    var new_window = Window.{
        .id = win,
        .screen_id = screen.id,
        .group_index = group.index,
        .geo = win_geo,
    };

    // Add to windows hash map
    // TODO: fn putOrGet ???
    _ = windows.put(win, new_window) catch {
        warn("addWindow: Failed to add window to windows hashmap.\n");
        return;
    };
    // var kv = windows.get(win);

    // Add into screen's window linked list
    var win_node = try screen.windows.createNode(win, allocator);
    screen.windows.prepend(win_node);
    // Add into groups' window linked list
    var group_win_node = try group.windows.createNode(win, allocator);
    group.windows.prepend(group_win_node);
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


// TODO: redo. Use function that finds pointer position.
fn getActiveMouseScreen(dpy: ?*xcb_connection_t, screens: LinkedList(Screen)) *Screen {
    var return_pointer: xcb_query_pointer_cookie_t = undefined;
    _ = _xcb_query_pointer(dpy, g_screen_root, &return_pointer);
    var pointer_reply = xcb_query_pointer_reply(dpy, return_pointer, null);
    var pointer = pointer_reply.?[0];

    return getScreenBasedOnCoords(pointer.root_x, pointer.root_y, screens) orelse &screens.first.?.data;
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


fn setWindowEvents(dpy: ?*xcb_connection_t, window: xcb_window_t) void {
    var return_void_pointer: xcb_void_cookie_t = undefined;
    var key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym: xlib.KeySym = undefined;
    var keycode: xcb_keycode_t = undefined;

    for (mouse_mapping) |event| {
        _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, event.index, event.mod, &return_void_pointer);
    }

    for (keymap) |key| {
        keysym = xlib.XStringToKeysym(&key.char);
        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];

        _ = _xcb_grab_key(dpy, 1, window, key.mod, keycode, _XCB_GRAB_MODE_ASYNC,
                          _XCB_GRAB_MODE_ASYNC, &return_void_pointer);

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
    // config_values[i] = 130;
    i += 1;

    config_mask = config_mask | _XCB_CONFIG_WINDOW_HEIGHT;
    config_values[i] = 105;
    // config_values[i] = 105;
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

    const tile_width = @divTrunc(screen.geo.width - 2 * g_screen_padding, g_grid_cols);
    const tile_height = @divTrunc(screen.geo.height - 2 * g_screen_padding, g_grid_rows);

    var row = u8(0);
    while (row < g_grid_rows) : (row+=1) {
        var col = u8(0);
        while (col < g_grid_cols) : (col+=1) {
            var width = tile_width - 1;
            var height = tile_height - 1;

            // TODO: set a config which allows which tiles to 'stretch' ???
            // Top, right, bottom, left?
            if (col == (g_grid_cols - 1)) {
                width += @rem(screen.geo.width - 2 * g_screen_padding, g_grid_cols);
            }

            if (row == (g_grid_rows - 1)) {
                height += @rem(screen.geo.height - 2 * g_screen_padding, g_grid_rows);
            }

            var rect = xcb_rectangle_t.{
                .x = screen.geo.x + @intCast(i16, tile_width * col + g_screen_padding),
                .y = screen.geo.y + @intCast(i16, tile_height * row + g_screen_padding),
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

    const tile_width = @divTrunc(screen.geo.width - 2 * g_screen_padding, g_grid_cols);

    var col = u8(0);
    while (col < g_grid_cols) : (col+=1) {
        var loc = screen.geo.x + @intCast(i16, tile_width * col + g_screen_padding);
        try col_locations.append(loc);
    }

    return col_locations;
}


fn getGridRows(allocator: *Allocator, screen: Screen) !ArrayList(i32) {
    var row_locations = ArrayList(i32).init(allocator);

    const tile_height = @divTrunc(screen.geo.height - 2 * g_screen_padding, g_grid_rows);

    var row = u8(0);
    while (row < g_grid_rows) : (row+=1) {
        var loc = screen.geo.y + @intCast(i16, tile_height * row + g_screen_padding);
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


fn keypressEvent(allocator: *Allocator, dpy: ?*xcb_connection_t, ev: xcb_generic_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("xcb: key press\n");
    const e = @intToPtr(*xcb_key_press_event_t, @ptrToInt(&ev));
    // warn("{}\n", e);

    const key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym = xcb_key_press_lookup_keysym(key_symbols, @ptrCast(?[*]xcb_key_press_event_t, e), 0);
    xcb_key_symbols_free(key_symbols);

    for (root_keymap) |key| {
        if (key.mod == e.state and keysym == @intCast(u32, xlib.XStringToKeysym(&key.char))) {
            switch (key.func) {
                KeyFunc.Move,
                KeyFunc.Shift,
                KeyFunc.Change,
                KeyFunc.WindowToGroup => return,
                KeyFunc.Spawn => |app| keypressSpawn(allocator, app),
                KeyFunc.ToggleGroup => |f| f(allocator, dpy, e, screens, groups, windows),
                KeyFunc.Debug => {
                    debugScreens(screens, windows);
                    debugWindows(windows);
                    debugGroups(groups);
                },
            }
            break; // TODO: change to return after refactor
        }
    }

    for (keymap) |key| {
        if (key.mod == e.state and keysym == @intCast(u32, xlib.XStringToKeysym(&key.char))) {
            switch (key.func) {
                KeyFunc.Move => |f| f(allocator, dpy, e, screens, groups, windows),
                KeyFunc.Shift => |f| f(allocator, dpy, e, screens, groups, windows),
                KeyFunc.Change => |f| f(allocator, dpy, e, screens, groups, windows),
                KeyFunc.WindowToGroup => |f| f(allocator, dpy, e, screens, groups, windows),
                KeyFunc.Spawn,
                KeyFunc.Debug,
                KeyFunc.ToggleGroup => return,
            }
            break; // TODO: change to return after refactor
        }
    }


    _ = xcb_flush(dpy);
}


fn keypressMoveLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("move left func\n");

    var win = windows.get(e.event);
    if (win == null) return;

    var screen = getScreen(win.?.value.screen_id, screens);
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    var new_x = win_geo.x - @intCast(i16, g_window_move_x);

    var new_edge_x = new_x + @intCast(i16, win_geo.width + 2 * g_border_width);
    if (new_edge_x > screen.geo.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    } else {
        const new_screen = getScreenBasedOnCoords(new_edge_x, win_geo.y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, new_x, win_geo.y);

            // TODO: @changeWindowScreen
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

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

    var win = windows.get(e.event);
    if (win == null) return;

    var screen = getScreen(win.?.value.screen_id, screens);
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    var new_x = win_geo.x + @intCast(i16, g_window_move_x);

    if (new_x < screen.geo.x + @intCast(i16, screen.geo.width)) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    } else {
        const new_screen = getScreenBasedOnCoords(new_x, win_geo.y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, new_x, win_geo.y);

            // TODO: @changeWindowScreen
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

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


fn keypressMoveUp(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("move up func\n");

    var win = windows.get(e.event);
    if (win == null) return;

    var screen = getScreen(win.?.value.screen_id, screens);
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);


    var new_y = win_geo.y - @intCast(i16, g_window_move_y);
    var new_edge_y = new_y + @intCast(i16, win_geo.height + 2 * g_border_width);

    if (new_edge_y > screen.geo.y) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
    } else {
        const new_screen = getScreenBasedOnCoords(win_geo.x, new_edge_y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, win_geo.x, new_y);

            // TODO: @changeWindowScreen
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

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


fn keypressMoveDown(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("move Down func\n");

    var win = windows.get(e.event);
    if (win == null) return;

    var screen = getScreen(win.?.value.screen_id, screens);
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    var new_y = win_geo.y + @intCast(i16, g_window_move_y);

    if (new_y < screen.geo.y + @intCast(i16, screen.geo.height)) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
    } else {
        const new_screen = getScreenBasedOnCoords(win_geo.x, new_y, screens);

        if (new_screen != null and screen.id != new_screen.?.id) {
            moveWindow(dpy, e.event, win_geo.x, new_y);

            // TODO: @changeWindowScreen
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

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


fn keypressShiftLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift left\n");

    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    const win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);

    var new_x = @intCast(i32, win_geo.x);
    const tile_width: i32 = @divTrunc(screen.geo.width - 2 * g_screen_padding, g_grid_cols);

    const win_total_width = @intCast(i16, win_geo.width + 2 * g_border_width);
    var x_tile_locations = getGridCols(allocator, screen.*) catch {
        warn("Failed to get grid breakpoints\n");
        return;
    };
    defer x_tile_locations.deinit();

    const screen_padding = @intCast(i16, g_screen_padding);
    const win_edge_x = win_geo.x + win_total_width;
    const win_abs_x = win_geo.x - screen.geo.x - screen_padding;
    const win_abs_edge_x = win_abs_x + win_total_width;
    var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_x) / @intToFloat(f32, tile_width)));
    var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_x) / @intToFloat(f32, tile_width)));

    var on_left = @rem(win_abs_x, tile_width) == 0;
    var on_right = (screen.geo.x + @intCast(i16, screen.geo.width) - screen_padding == win_edge_x) or (@rem(win_abs_edge_x, tile_width) == 0);

    if (on_left or (@intCast(i32, x_tile_locations.len) == grid_loc)) {
        grid_loc -= 1;
    }

    if (on_right or win_total_width < tile_width) {
        grid_edge_loc -= 1;
    }

    if (grid_loc >= 0 and grid_loc < @intCast(i32, x_tile_locations.len)) {
        new_x = x_tile_locations.at(@intCast(usize, grid_loc));
        const new_edge_x = new_x + win_total_width;
        const screen_edge = screen.geo.x + @intCast(i32, screen.geo.width) - screen_padding;

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
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

            const group_index = screen.groups.first.?.data;
            const new_group_index = new_screen.?.groups.first.?.data;
            const groups_slice = groups.toSlice();

            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;

            new_x = new_screen.?.geo.x + @intCast(i16, new_screen.?.geo.width) - screen_padding - win_total_width;
        }
    }

    if (new_x != win_geo.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    }

}

fn keypressShiftRight(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift right\n");

    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    const win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);

    var new_x = @intCast(i32, win_geo.x);
    const tile_width: i32 = @divTrunc(screen.geo.width - 2 * g_screen_padding, g_grid_cols);

    const win_total_width = @intCast(i16, win_geo.width + 2 * g_border_width);
    const breakpoints = getGridCols(allocator, screen.*) catch {
        warn("Failed to get grid breakpoints\n");
        return;
    };
    defer breakpoints.deinit();
    const brkpts_len = @intCast(i32, breakpoints.len);

    const screen_padding = @intCast(i16, g_screen_padding);
    const screen_edge = screen.geo.x + @intCast(i32, screen.geo.width) - screen_padding;
    const win_edge_x = win_geo.x + win_total_width;
    const win_abs_x = win_geo.x - screen.geo.x - screen_padding;
    const win_abs_edge_x = win_abs_x + win_total_width;
    var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_x) / @intToFloat(f32, tile_width)));
    var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_x) / @intToFloat(f32, tile_width)));

    const on_left = @rem(win_abs_x, tile_width) == 0;
    const on_right = (screen.geo.x + @intCast(i16, screen.geo.width) - screen_padding == win_edge_x) or (@rem(win_abs_edge_x, tile_width) == 0);

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
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

            const group_index = screen.groups.first.?.data;
            const new_group_index = new_screen.?.groups.first.?.data;
            const groups_slice = groups.toSlice();

            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;

            new_x = new_screen.?.geo.x + screen_padding;
        }
    }

    if (new_x != win_geo.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
    }
}

fn keypressShiftUp(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift up\n");

    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    const win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);

    var new_y = @intCast(i32, win_geo.y);
    const tile_height: i32 = @divTrunc(screen.geo.height - 2 * g_screen_padding, g_grid_rows);

    const win_total_height = @intCast(i16, win_geo.height + 2 * g_border_width);
    var breakpoints = getGridRows(allocator, screen.*) catch {
        warn("Failed to get grid breakpoints\n");
        return;
    };
    defer breakpoints.deinit();

    const screen_padding = @intCast(i16, g_screen_padding);
    const win_edge_y = win_geo.y + win_total_height;
    const win_abs_y = win_geo.y - screen.geo.y - screen_padding;
    const win_abs_edge_y = win_abs_y + win_total_height;
    var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_y) / @intToFloat(f32, tile_height)));
    var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_y) / @intToFloat(f32, tile_height)));

    var on_top = @rem(win_abs_y, tile_height) == 0;
    var on_bottom = (screen.geo.y + @intCast(i16, screen.geo.height) - screen_padding == win_edge_y) or (@rem(win_abs_edge_y, tile_height) == 0);

    if (on_top or (@intCast(i32, breakpoints.len) == grid_loc)) {
        grid_loc -= 1;
    }

    if (on_bottom or win_total_height < tile_height) {
        grid_edge_loc -= 1;
    }

    if (grid_loc >= 0 and grid_loc < @intCast(i32, breakpoints.len)) {
        new_y = breakpoints.at(@intCast(usize, grid_loc));
        const new_edge_y = new_y + win_total_height;
        const screen_edge = screen.geo.y + @intCast(i32, screen.geo.height) - screen_padding;

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
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

            const group_index = screen.groups.first.?.data;
            const new_group_index = new_screen.?.groups.first.?.data;
            const groups_slice = groups.toSlice();

            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;

            new_y = new_screen.?.geo.y + @intCast(i16, new_screen.?.geo.height) - screen_padding - win_total_height;
        }
    }

    if (new_y != win_geo.y) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
    }
}

fn keypressShiftDown(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift down\n");

    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, e.event, &return_geo);
    const win_geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);

    const win = windows.get(e.event);
    var screen = getScreen(win.?.value.screen_id, screens);

    var new_y = @intCast(i32, win_geo.y);
    const tile_height: i32 = @divTrunc(screen.geo.height - 2 * g_screen_padding, g_grid_rows);

    const win_total_height = @intCast(i16, win_geo.height + 2 * g_border_width);
    var breakpoints = getGridRows(allocator, screen.*) catch {
        warn("Failed to get grid breakpoints\n");
        return;
    };
    defer breakpoints.deinit();
    const brkpts_len = @intCast(i32, breakpoints.len);

    const screen_padding = @intCast(i16, g_screen_padding);
    const screen_edge = screen.geo.y + @intCast(i32, screen.geo.height) - screen_padding;
    const win_edge_y = win_geo.y + win_total_height;
    const win_abs_y = win_geo.y - screen.geo.y - screen_padding;
    const win_abs_edge_y = win_abs_y + win_total_height;
    var grid_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_y) / @intToFloat(f32, tile_height)));
    var grid_edge_loc = @floatToInt(i32, std.math.floor(@intToFloat(f32, win_abs_edge_y) / @intToFloat(f32, tile_height)));

    var on_top = @rem(win_abs_y, tile_height) == 0;
    var on_bottom = (screen.geo.y + @intCast(i16, screen.geo.height) - screen_padding == win_edge_y) or (@rem(win_abs_edge_y, tile_height) == 0);

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
            _ = screen.removeWindow(win.?.value.id);
            new_screen.?.addWindow(win.?.value.id);

            const group_index = screen.groups.first.?.data;
            const new_group_index = new_screen.?.groups.first.?.data;
            const groups_slice = groups.toSlice();

            groups_slice[group_index].removeWindow(win.?.value.id, allocator);
            groups_slice[new_group_index].addWindow(win.?.value.id, allocator);

            win.?.value.screen_id = new_screen.?.id;
            win.?.value.group_index = new_group_index;

            new_y = new_screen.?.geo.y + screen_padding;
        }
    }

    if (new_y != win_geo.y) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
    }

}

fn keypressChangeLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("keypress change left\n");

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
        const x_distance = screen.geo.x + @intCast(i32, screen.geo.width) - win_center.x + half_dim;
        const y_distance = screen.geo.y + @intCast(i32, screen.geo.height) - win_center.y + half_dim;
        if (x_distance > y_distance) {
            break :blk x_distance;
        } else {
            break :blk y_distance;
        }
    };

    var t1 = Point.{
        .x = win_center.x - largest_distance,
        .y = win_center.y - largest_distance,
    };
    var t2 = Point.{
        .x = win_center.x - largest_distance,
        .y = win_center.y + largest_distance,
    };

    warn("win_center: {}\n", win_center);
    warn("t1: {}\n", t1);
    warn("t2: {}\n", t2);

    var window_node = screen.windows.first.?.next;
    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = 0;
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
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (window_node.?.data < win.?.value.id and window_node.?.data > closest_win) {
                    closest_win = window_node.?.data;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = window_node.?.data;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    var screen_node = screens.first;
    while (screen_node != null) : (screen_node = screen_node.?.next) {
        if (screen_node.?.data.id == screen.id) continue;
        // if (is_left and screen_node.?.data.x > screen.geo.x) continue;

        const screen_midpoint = screen_node.?.data.geo.y + @intCast(i16, screen_node.?.data.geo.height / 2);
        if (screen_midpoint < screen.geo.y or screen_midpoint > screen_bottom_y) continue;

        var screen_window_node = screen_node.?.data.windows.first;
        while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
            _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
            const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
            const x_midpoint = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width);
            if (x_midpoint > win_center.x) continue;

            const closest_win_point = Point.{
                .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
            };

            const new_distance = blk: {
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (screen_window_node.?.data < win.?.value.id and screen_window_node.?.data > closest_win) {
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
}


fn keypressChangeRight(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("keypress change left\n");

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
        const x_distance = screen.geo.x + @intCast(i32, screen.geo.width) - win_center.x + half_dim;
        const y_distance = screen.geo.y + @intCast(i32, screen.geo.height) - win_center.y + half_dim;
        if (x_distance > y_distance) {
            break :blk x_distance;
        } else {
            break :blk y_distance;
        }
    };


    const t1 = Point.{
        .x = win_center.x + largest_distance,
        .y = win_center.y - largest_distance,
    };
    const t2 = Point.{
        .x = win_center.x + largest_distance,
        .y = win_center.y + largest_distance,
    };

    var window_node = screen.windows.first.?.next;
    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = std.math.maxInt(u32);

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
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (window_node.?.data > win.?.value.id and window_node.?.data < closest_win) {
                    closest_win = window_node.?.data;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = window_node.?.data;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    var screen_node = screens.first;
    while (screen_node != null) : (screen_node = screen_node.?.next) {
        if (screen_node.?.data.id == screen.id) continue;
        // if (is_right and screen_node.?.data.x < screen.geo.x) continue;

        const screen_midpoint = screen_node.?.data.geo.y + @intCast(i16, screen_node.?.data.geo.height / 2);
        if (screen_midpoint < screen.geo.y or screen_midpoint > screen_bottom_y) continue;

        var screen_window_node = screen_node.?.data.windows.first;
        while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
            _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
            const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
            const x_midpoint = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width);
            if (x_midpoint < win_center.x) continue;

            const closest_win_point = Point.{
                .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
            };

            const new_distance = blk: {
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (screen_window_node.?.data > win.?.value.id and screen_window_node.?.data < closest_win) {
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
}



fn keypressChangeUp(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
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
        const x_distance = screen.geo.x + @intCast(i32, screen.geo.width) - win_center.x + half_dim;
        const y_distance = screen.geo.y + @intCast(i32, screen.geo.height) - win_center.y + half_dim;
        if (x_distance > y_distance) {
            break :blk x_distance;
        } else {
            break :blk y_distance;
        }
    };

    const t1 = Point.{
        .x = win_center.x - largest_distance,
        .y = win_center.y - largest_distance,
    };
    const t2 = Point.{
        .x = win_center.x + largest_distance,
        .y = win_center.y - largest_distance,
    };

    var window_node = screen.windows.first.?.next;
    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = 0;

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
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (window_node.?.data < win.?.value.id and window_node.?.data > closest_win) {
                    closest_win = window_node.?.data;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = window_node.?.data;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    var screen_node = screens.first;
    while (screen_node != null) : (screen_node = screen_node.?.next) {
        if (screen_node.?.data.id == screen.id) continue;
        // if (is_up and screen_node.?.data.y > screen.geo.y) continue;

        const screen_midpoint = screen_node.?.data.geo.x + @intCast(i16, screen_node.?.data.geo.width / 2);
        if (screen_midpoint < screen.geo.x or screen_midpoint > screen_right_x) continue;

        var screen_window_node = screen_node.?.data.windows.first;
        while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
            _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
            const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
            const y_midpoint = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width);

            if (y_midpoint > win_center.y) continue;

            const closest_win_point = Point.{
                .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
            };

            const new_distance = blk: {
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (screen_window_node.?.data < win.?.value.id and screen_window_node.?.data > closest_win) {
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
}


fn keypressChangeDown(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
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
        const x_distance = screen.geo.x + @intCast(i32, screen.geo.width) - win_center.x + half_dim;
        const y_distance = screen.geo.y + @intCast(i32, screen.geo.height) - win_center.y + half_dim;
        if (x_distance > y_distance) {
            break :blk x_distance;
        } else {
            break :blk y_distance;
        }
    };


    const t1 = Point.{
        .x = win_center.x - largest_distance,
        .y = win_center.y + largest_distance,
    };
    const t2 = Point.{
        .x = win_center.x + largest_distance,
        .y = win_center.y + largest_distance,
    };

    var window_node = screen.windows.first.?.next;
    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = std.math.maxInt(u32);
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
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (window_node.?.data > win.?.value.id and window_node.?.data < closest_win) {
                    closest_win = window_node.?.data;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = window_node.?.data;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    var screen_node = screens.first;
    while (screen_node != null) : (screen_node = screen_node.?.next) {
        if (screen_node.?.data.id == screen.id) continue;
        // if (is_down and screen_node.?.data.y < screen.geo.y) continue;

        const screen_midpoint = screen_node.?.data.geo.x + @intCast(i16, screen_node.?.data.geo.width / 2);
        if (screen_midpoint < screen.geo.x or screen_midpoint > screen_right_x) continue;

        var screen_window_node = screen_node.?.data.windows.first;
        while (screen_window_node != null) : (screen_window_node = screen_window_node.?.next) {
            _ = _xcb_get_geometry(dpy, screen_window_node.?.data, &return_geo);
            const geo = @ptrCast(*struct_xcb_get_geometry_reply_t, &xcb_get_geometry_reply(dpy, return_geo, null).?[0]);
            const y_midpoint = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width);

            if (y_midpoint < win_center.y) continue;

            const closest_win_point = Point.{
                .x = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width),
                .y = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width),
            };

            const new_distance = blk: {
                const p_x = win_center.x - closest_win_point.x;
                const p_y = win_center.y - closest_win_point.y;
                const p1 = p_x * p_x;
                const p2 = p_y * p_y;
                break :blk std.math.sqrt(p1 + p2);
            };

            if (new_distance == 0 or new_distance == closest_win_distance) {
                if (screen_window_node.?.data > win.?.value.id and screen_window_node.?.data < closest_win) {
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
}


fn keypressToggleGroup(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    var return_cookie: xcb_void_cookie_t = undefined;
    var selected_group_index = blk: {
        var e_ = @intToPtr(?[*]struct_xcb_key_press_event_t, @ptrToInt(e));
        const key_symbols = xcb_key_symbols_alloc(dpy);
        const keysym = xcb_key_press_lookup_keysym(key_symbols, e_, 0);
        xcb_key_symbols_free(key_symbols);
        for (groups.toSlice()) |g, i| {
            var group = @intToPtr(*Group, @ptrToInt(&g));
            const sym = @intCast(u32, xlib.XStringToKeysym(@ptrCast(?[*]const u8, group.str_value[0..].ptr)));
            if (sym == keysym) {
                break :blk i;
            }
        }

        warn("keypressToggleGroup: Didn't find group with key pressed.");
        return;
    };

    var selected_group = &groups.toSlice()[selected_group_index];
    var mouse_screen = getActiveMouseScreen(dpy, screens);
    const group_index = mouse_screen.groups.first.?.data;

    if (mouse_screen.groups.len == 1 and selected_group.index == group_index) return;

    // See if group is on any of the screens
    var screen_node = screens.first;
    while (screen_node != null) : (screen_node = screen_node.?.next) {
        if (screen_node.?.data.groups.len == 1 and screen_node.?.data.groups.first.?.data == selected_group.index) return;
        if (screen_node.?.data.groups.len == 1) continue;

        if (screen_node.?.data.destroyGroup(selected_group.index)) {
            // Remove and unmap group's windows from screen
            var window_node = selected_group.windows.last;
            while (window_node != null) : (window_node = window_node.?.prev) {
                if (screen_node.?.data.removeWindow(window_node.?.data)) {
                    _ = _xcb_unmap_window(dpy, window_node.?.data, &return_cookie);
                }
            }
            break;
        }
    }


    // Add and map window to screen
    if (selected_group_index != group_index) {
        mouse_screen.addGroup(selected_group.index);
        var window_node = selected_group.windows.last;
        while (window_node != null) : (window_node = window_node.?.prev) {
            var win = windows.get(window_node.?.data);
            if (win == null) continue;
            _ = mouse_screen.addWindow(win.?.value.id);

            if (win.?.value.screen_id != mouse_screen.id) {
                // TODO: instead get this from where screen_node variable is used
                // in a loop ???
                var old_screen = getScreen(win.?.value.screen_id, screens);
                old_screen.windowToScreenRender(dpy, &win.?.value, mouse_screen);

            }

            raiseWindow(dpy, win.?.value.id);
            _ = _xcb_map_window(dpy, win.?.value.id, &return_cookie);
        }
    }

    if (mouse_screen.windows.first) |window_id| {
        const focused_window = getFocusedWindow(dpy);
        unfocusWindow(dpy, focused_window, g_default_border_color);
        focusWindow(dpy, window_id.data, g_active_border_color);
    }
}


fn keypressWindowToGroup(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    var return_cookie: xcb_void_cookie_t = undefined;
    warn("move window to a group\n");
    // var target_group = &groups.toSlice()[i];
    var dest_group_index = blk: {
    // var dest_group = blk: {
        var e_ = @intToPtr(?[*]struct_xcb_key_press_event_t, @ptrToInt(e));
        const key_symbols = xcb_key_symbols_alloc(dpy);
        const keysym = xcb_key_press_lookup_keysym(key_symbols, e_, 0);
        xcb_key_symbols_free(key_symbols);
        for (groups.toSlice()) |g, i| {
            var group = @intToPtr(*Group, @ptrToInt(&g));
            const sym = @intCast(u32, xlib.XStringToKeysym(@ptrCast(?[*]const u8, group.str_value[0..].ptr)));
            if (sym == keysym) {
                // break :blk @intToPtr(*Group, @ptrToInt(&g));
                break :blk i;
            }
        }

        warn("keypressGroupMoveWindow function: Didn't find group with key pressed.");
        return;
    };

    var dest_group = &groups.toSlice()[dest_group_index];

    var window_kv = windows.get(e.event);
    if (window_kv == null) return;
    var window = window_kv.?.value;
    if (dest_group.index == window.group_index) return;

    const new_node = dest_group.windows.createNode(window.id, allocator) catch {
        warn("keypressMoveWindow function: Failed to create new window node.");
        return;
    };

    var src_group = &groups.toSlice()[window.group_index];
    var group_win_node = src_group.windows.first;
    // Remove window from source group
    while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
        if (group_win_node.?.data == window.id) {
            src_group.windows.remove(group_win_node.?);
            src_group.windows.destroyNode(group_win_node.?, allocator);
            break;
        }
    }

    var screen_node = screens.first;
    // Remove window from screen
    screen_loop: while (screen_node != null) : (screen_node = screen_node.?.next) {
        var window_node = screen_node.?.data.windows.first;
        while (window_node != null) : (window_node = window_node.?.next) {
            if (window_node.?.data == window.id) {
                unfocusWindow(dpy, window.id, g_default_border_color);
                screen_node.?.data.windows.remove(window_node.?);
                screen_node.?.data.windows.destroyNode(window_node.?, allocator);
                break :screen_loop;
            }
        }
    }

    _ = _xcb_unmap_window(dpy, window.id, &return_cookie);
    dest_group.windows.prepend(new_node);

    var screen = getScreen(window.screen_id, screens);
    screen_node = screens.first;
    screen_loop: while (screen_node != null) : (screen_node = screen_node.?.next) {
        var screen_group_node = screen_node.?.data.groups.first;
        while (screen_group_node != null) : (screen_group_node = screen_group_node.?.next) {
            if (screen_group_node.?.data == dest_group.index) {
                var new_win_node = screen_node.?.data.windows.createNode(window.id, allocator) catch {
                    warn("keypressMoveWindow function: Failed to create new window node.");
                    return;
                };
                screen_node.?.data.windows.prepend(new_win_node);

                if (window.screen_id != screen_node.?.data.id) {
                    screen.windowToScreenRender(dpy, &window_kv.?.value, &screen_node.?.data);
                }
                // raiseWindow(dpy, window.id);
                _ = _xcb_map_window(dpy, window.id, &return_cookie);
                break :screen_loop;
            }
        }
    }

    window_kv.?.value.group_index = dest_group.index;

    // TODO: Or focus new window the screen the source/target
    // (var window_screen) window was ???
    if (getActiveMouseScreen(dpy, screens).windows.first) |new_focus| {
        focusWindow(dpy, new_focus.data, g_active_border_color);
    }
}

fn keypressSpawn(allocator: *Allocator, argv: []const []const u8) void {
    warn("spawn application: {}\n", argv[0]);
    var child_result = child.init(argv, allocator) catch {
        warn("Failed to create child process.");
        return;
    };
    // TODO: don't return if error
    var env_map = os.getEnvMap(allocator) catch {
        warn("Failed to get environment variables.");
        return;
    };
    child_result.env_map = &env_map;
    _ = child.spawn(child_result) catch {
        warn("Failed to spawn application/program.\n");
    };
}


fn buttonpressEvent(allocator: *Allocator, dpy: ?*xcb_connection_t, ev: xcb_generic_event_t, screens: LinkedList(Screen), groups: ArrayList(Group), windows: WindowsHashMap, screen_root: xcb_window_t) void {
    warn("xcb: button press\n");
    const e = @intToPtr(*xcb_button_press_event_t, @ptrToInt(&ev));
    warn("{}\n", e);

    var return_pointer: xcb_void_cookie_t = undefined;
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
    var new_geometry: Geometry = undefined;
    var win_mask = u16(0);
    var win_values: [2]i32 = undefined;

    while (is_grabbed) {
        var ev_inside = xcb_wait_for_event(dpy).?[0];
        switch (ev_inside.response_type & ~u8(0x80)) {
            // TODO: what if some other event happens here: configure, map, etc
            XCB_MOTION_NOTIFY => {
                // TODO: move this outside of while loop
                for (mouse_mapping) |event| {
                    if (event.mod == e.state and event.index == e.detail) {

                        var e_inside = @ptrCast(*xcb_motion_notify_event_t, &ev_inside);
                        switch (event.action) {
                            MouseAction.ResizeInBounds => {
                                warn("mouse resize inbounds.\n");
                                new_geometry = buttonpressMotionResizeWindowInBounds(e, e_inside, active_screen, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
                                win_values = []i32.{new_geometry.width, new_geometry.height};
                            },
                            MouseAction.Resize => {
                                warn("mouse resize.\n");
                                new_geometry = buttonpressMotionResizeWindow(e, e_inside, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
                                win_values = []i32.{new_geometry.width, new_geometry.height};
                            },
                            MouseAction.MoveInBounds => {
                                warn("mouse move inbounds.\n");
                                const screen = getNewScreenOnChange(e_inside.root_x, e_inside.root_y, screens, active_screen) orelse active_screen;
                                new_geometry = buttonpressMotionMoveWindowInBounds(e, e_inside, screen, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
                                win_values = []i32.{new_geometry.x, new_geometry.y};
                            },
                            MouseAction.Move => {
                                warn("mouse move.\n");
                                new_geometry = buttonpressMotionMoveWindow(e, e_inside, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
                                win_values = []i32.{new_geometry.x, new_geometry.y};
                            },
                        }
                    }
                }

                _ = _xcb_configure_window(dpy, e.event, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
                _ = xcb_flush(dpy);
            },
            XCB_BUTTON_RELEASE => {
                warn("xcb inside: button release\n");
                var e_inside = @ptrCast(*xcb_button_release_event_t, &ev_inside);
                is_grabbed = false;
                win.?.value.geo = new_geometry;

                if (e_inside.detail != _XCB_BUTTON_INDEX_1) continue;
                warn("{}\n", e_inside);

                var new_screen = getNewScreenOnChange(e_inside.root_x, e_inside.root_y, screens, active_screen) orelse null;
                // if (getNewScreenOnChange(e_inside.root_x, e_inside.root_y, screens, active_screen)) |new_screen| {
                //     active_screen = new_screen;
                // }
                if (new_screen != null and win.?.value.screen_id != new_screen.?.id) {
                    warn("window has changed screen\n");

                    win.?.value = active_screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());

                    // changeWindowGroup() new_group_index
                    // var groups_slice = groups.toSlice();
                    // var old_group_index = win.?.value.group_index;
                    // var new_group_index = active_screen.groups.first.?.data;
                    // var group_win_node = groups_slice[old_group_index].windows.first;
                    // while (group_win_node != null) : (group_win_node = group_win_node.?.next) {
                    //     if (group_win_node.?.data == win.?.value.id) {
                    //         groups_slice[old_group_index].windows.remove(group_win_node.?);
                    //         groups_slice[new_group_index].windows.prepend(group_win_node.?);
                    //         break;
                    //     }
                    // }

                    // // changeWindowScreen()
                    // var old_screen = getScreen(win.?.value.screen_id, screens);
                    // var node = old_screen.windows.first;
                    // while (node != null) : (node = node.?.next) {
                    //     if (node.?.data == win.?.value.id) {
                    //         old_screen.windows.remove(node.?);
                    //         active_screen.windows.prepend(node.?);
                    //         win.?.value.screen_id = active_screen.id;
                    //         win.?.value.group_index = new_group_index;
                    //         break;
                    //     }
                    // }
                }
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
}


fn buttonpressMotionMoveWindowInBounds(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, screen: *Screen, geo: Geometry) Geometry {
    const xdiff = e_inside.root_x - e.root_x;
    const ydiff = e_inside.root_y - e.root_y;
    const x: i32 = geo.x + xdiff;
    const y: i32 = geo.y + ydiff;

    var new_win_geometry = inBoundsWindowGeometry(x, y, geo.width, geo.height, screen);

    if (geo.width > @intCast(i32, screen.geo.width)) {
        new_win_geometry.x = screen.geo.x + @intCast(i32, g_screen_padding);
    }

    if (geo.height > @intCast(i32, screen.geo.height)) {
        new_win_geometry.y = screen.geo.y + @intCast(i32, g_screen_padding);
    }

    return new_win_geometry;
}

fn buttonpressMotionMoveWindow(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, geo: Geometry) Geometry {
    const xdiff = e_inside.root_x - e.root_x;
    const ydiff = e_inside.root_y - e.root_y;

    const x: i32 = geo.x + xdiff;
    const y: i32 = geo.y + ydiff;

    return Geometry.{
        .x = x,
        .y = y,
        .width = geo.width,
        .height = geo.height,
    };
}

fn buttonpressMotionResizeWindowInBounds(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, screen: *Screen, geo: Geometry) Geometry {
    var xdiff = e_inside.root_x - e.root_x;
    var ydiff = e_inside.root_y - e.root_y;
    var width = @intCast(i32, geo.width) + xdiff;
    var height = @intCast(i32, geo.height) + ydiff;

    var new_geometry = inBoundsWindowGeometry(geo.x, geo.y, width,height, screen);

    return Geometry.{
        .x = geo.x,
        .y = geo.y,
        .width = new_geometry.width,
        .height = new_geometry.height,
    };
}


fn buttonpressMotionResizeWindow(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, geo: Geometry) Geometry {
    const xdiff = e_inside.root_x - e.root_x;
    const ydiff = e_inside.root_y - e.root_y;
    const width = @intCast(i32, geo.width) + xdiff;
    const height = @intCast(i32, geo.height) + ydiff;

    return Geometry.{
        .x = geo.x,
        .y = geo.y,
        .width = std.math.max(@intCast(i32, g_window_min_width), width),
        .height = std.math.max(@intCast(i32, g_window_min_height), height),
    };
}
