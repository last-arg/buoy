// TODO: check for loops. Where need add pointer symbol.
const std = @import("std");
const fmt = std.fmt;
const warn = std.debug.warn;
const panic = std.debug.panic;
const assert = std.debug.assert;
const mem = std.mem;
const meta = std.meta;
const Allocator = mem.Allocator;
const os = std.os;
const child = os.ChildProcess;
const ArrayList = std.ArrayList;
const hash_map = std.hash_map;
const HashMap = std.HashMap;
  
const xlib = @cImport({
    @cInclude("X11/Xlib.h");
    // @cInclude("X11/keysym.h");
});
const xrandr = @import("Xrandr.zig");
use @import("c_import.zig");
use @import("xcb_extern.zig");

const Screen = ScreenFn();
fn ScreenFn() type {
    return struct {
        const Self = @This();
        allocator: *Allocator,
        index: u8,
        root_id: xcb_window_t,
        geo: Geometry,
        groups: ArrayList(u8),
        windows: ArrayList(xcb_window_t),

        pub fn init(index: u8, root_id: xcb_window_t, geo: Geometry, allocator: *Allocator) !Self {
            var screen = Self {
                .index = index,
                .root_id = root_id,
                .allocator = allocator,
                .geo = geo,
                .groups = ArrayList(u8).init(allocator),
                .windows = ArrayList(xcb_window_t).init(allocator),
            };

            try screen.groups.append(index);

            return screen;
        }

        pub fn addWindow(self: *Screen, id: xcb_window_t) void {
            self.windows.insert(0, id) catch {
                warn("Screen.addWidow: Failed to add window.");
            };
        }

        pub fn removeWindow(self: *Screen, id: xcb_window_t) bool {
            var slice = self.windows.toOwnedSlice();
            for (slice) |win_id, i| {
                if (id == win_id) {
                    const head = slice[0..i];
                    const tail = slice[i+1..];

                    self.windows.appendSlice(head) catch {};
                    self.windows.appendSlice(tail) catch {};

                    return true;
                }
            }
            return false;
        }

        pub fn removeGroup(self: *Screen, id: u8) bool {
            var slice = self.groups.toOwnedSlice();
            for (slice) |win_id, i| {
                if (id == win_id) {
                    const head = slice[0..i];
                    const tail = slice[i+1..];

                    self.groups.appendSlice(head) catch {};
                    self.groups.appendSlice(tail) catch {};

                    return true;
                }
            }
            return false;

        }

        pub fn addGroup(self: *Screen, id: u8) void {
            self.groups.insert(0, id) catch {
                warn("Screen.addWidow: Failed to add window.");
            };
        }

        pub fn windowToScreen(self: *Screen, win: *Window, dest_screen: *Screen, groups: []Group) Window {
            _ = self.removeWindow(win.id);
            groups[win.group_index].removeWindow(win.id, self.allocator);

            dest_screen.addWindow(win.id);
            win.screen_index = dest_screen.index;
            win.group_index = dest_screen.groups.at(0);
            groups[win.group_index].addWindow(win.id, self.allocator);

            return win.*;
        }

        pub fn recalculateWindowGeometry(self: *Screen, geo: Geometry, dest_screen: *Screen) Geometry {
            const new_width = @intToFloat(f32, geo.width) * (@intToFloat(f32, dest_screen.geo.width) / @intToFloat(f32, self.geo.width));
            const new_height = @intToFloat(f32, geo.height) * (@intToFloat(f32, dest_screen.geo.height) / @intToFloat(f32, self.geo.height));

            var new_x = geo.x;
            if (dest_screen.geo.x < self.geo.x) {
                new_x -= self.geo.x;
            } else if (dest_screen.geo.x > self.geo.x) {
                new_x += dest_screen.geo.x;
            }

            var new_y = geo.y;
            if (dest_screen.geo.y < self.geo.y) {
                new_y -= self.geo.y;
            } else if (dest_screen.geo.y > self.geo.y) {
                new_y += dest_screen.geo.y;
            }

            return Geometry {
                .x = new_x,
                .y = new_y,
                .width = @floatToInt(u16, new_width),
                .height = @floatToInt(u16, new_height),
            };
        }

    };
}

// TODO: add allocator field
const Group = struct {
    index: u8,
    windows: ArrayList(xcb_window_t),
    str_value: []u8,

    pub fn removeWindow(self: *Group, id: xcb_window_t, allocator: *Allocator) void {
        var slice = self.windows.toOwnedSlice();
        for (slice) |win_id, i| {
            if (id == win_id) {
                const head = slice[0..i];
                const tail = slice[i+1..];

                self.windows = ArrayList(xcb_window_t).fromOwnedSlice(allocator, head);
                self.windows.appendSlice(tail) catch {};

                break;
            }
        }
    }

    pub fn addWindow(self: *Group, id: xcb_window_t, allocator: *Allocator) void {
        self.windows.insert(0, id) catch {
            warn("Group.addWidow: Failed to add window.");
        };
    }
};

const Window = struct {
    id: xcb_window_t,
    screen_index: u8,
    group_index: u8,
    geo: Geometry,
};

const Geometry = struct {
    x: i16,
    y: i16,
    width: u16,
    height: u16,
};

const Point = struct {
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
const g_grid_rows: u8 = 4;
const g_grid_cols: u8 = 4;
var g_grid_total = g_grid_rows * g_grid_cols;
var g_grid_color: u32 = undefined;
var g_grid_show: bool = true;
var g_screen_root: xcb_window_t = undefined;


const g_mod = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
const g_mask_alt = @intCast(u16, @enumToInt(XCB_MOD_MASK_1));
const g_mask_ctrl = @intCast(u16, @enumToInt(XCB_MOD_MASK_CONTROL));
const g_mask_shift = @intCast(u16, @enumToInt(XCB_MOD_MASK_SHIFT));

const MouseAction = enum {
    Resize,
    Move,
    ResizeInBounds,
    MoveInBounds,
};

const MouseEvent = struct {
    const Self = @This();
    index: u8,
    mod: u16,
    action: MouseAction,

    pub fn create(index: u8, mod: u16, action: MouseAction) Self {
        return Self {
            .index = index,
            .mod = mod,
            .action = action,
        };
    }
};


var mouse_mapping = []MouseEvent {
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_1)), g_mod, MouseAction.MoveInBounds),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_1)), g_mod | g_mask_shift, MouseAction.Move),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_3)), g_mod, MouseAction.ResizeInBounds),
    MouseEvent.create(@intCast(u8, @enumToInt(XCB_BUTTON_INDEX_3)), g_mod | g_mask_shift, MouseAction.Resize),
};

const Direction = enum {
    Left,
    Right,
    Up,
    Down,
};

const Action = union(enum) {
    Move: Direction,
    Change: Direction,
    Shift: Direction,
    ToggleGroup: void,
    WindowToGroup: void,
    Spawn: []const []const u8,
    Debug: []const []const u8,
};


const Key = struct {
    const Self = @This();
    // TODO: try to remove 'c string'
    char: [*]const u8,
    mod: u16,
    action: Action,

    pub fn create(char: [*]const u8, mod: u16, action: Action) Self {
        return Self {
            .char = char,
            .mod = mod,
            .action = action,
        };
    }
};

// TODO: move it into main ???
// NOTE: At the moment it is generated in compile time.
// Unlike 'keymap' variable which needs runtime.
var root_keymap = []Key {
    Key.create(c"d", g_mod, Action {.Debug = []const []const u8 {"all"}}),

    Key.create(c"t", g_mod, Action {.Spawn = []const []const u8 {"xterm"}}),
    Key.create(c"r", g_mod, Action {.Spawn = []const []const u8 {"st"}}),

    Key.create(c"1", g_mod, Action {.ToggleGroup = {}}),
    Key.create(c"2", g_mod, Action {.ToggleGroup = {}}),
    Key.create(c"3", g_mod, Action {.ToggleGroup = {}}),
    Key.create(c"4", g_mod, Action {.ToggleGroup = {}}),
    Key.create(c"5", g_mod, Action {.ToggleGroup = {}}),
};



// NOTE: xcb_configure_window mask/values order
// X, Y, WIDTH, HEIGHT, BORDER_WIDTH, SIBLING, STACK_MODE
// TODO: make different functions for position, dimesion, border width ???
const WindowChange = struct {
    id: xcb_window_t,
    mask: u16,
    values: ArrayList(i32),
};

const WindowAttributes = struct {
    id: xcb_window_t,
    mask: u32,
    values: ArrayList(u32),
};
// Byte count: 28
const PackedEvent = struct {
    response_type: u8,
    pad0: u8,
    sequence: u16,
    parent: xcb_window_t,
    window: xcb_window_t,
};


fn EventResultsFn() type {
    return struct {
        const Self = @This();
        const Focus = struct {
            current: xcb_window_t,
            new: xcb_window_t,
        };
        // TODO: make variable that holds next/new/future focus id.
        // Use getFocusedWindow or some other field for current focus id?
        focus: Focus,
        w_attrs: ArrayList(WindowAttributes),
        w_changes: ArrayList(WindowChange),
        w_map: ArrayList(xcb_window_t),
        w_unmap: ArrayList(xcb_window_t),
        // TODO: don't know if needed. Will be good when adding values to
        // changes or attributes.
        allocator: *Allocator,

        pub fn init(allocator: *Allocator) Self {
            return Self {
                .focus = Focus {
                    .current = 0,
                    .new = 0,
                },
                .allocator = allocator,
                .w_attrs = ArrayList(WindowAttributes).init(allocator),
                .w_changes = ArrayList(WindowChange).init(allocator),
                .w_map = ArrayList(xcb_window_t).init(allocator),
                .w_unmap = ArrayList(xcb_window_t).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.w_attrs.deinit();
            self.w_changes.deinit();
            self.w_map.deinit();
            self.w_unmap.deinit();
        }

        pub fn reset(self: *Self) void {
            self.w_attrs.shrink(0);
            self.w_changes.shrink(0);
            self.w_map.shrink(0);
            self.w_unmap.shrink(0);
            // TODO: do it here or out of the struct?
            self.focus.current = self.focus.new;
        }
    };
}
const EventResults = EventResultsFn();

pub fn main() !void {
    var return_pointer: xcb_void_cookie_t = undefined;
    var dpy = xcb_connect(null, null);
    if (xcb_connection_has_error(dpy) > 0) return error.FailedToOpenDisplay;

    // ------- CONFIG -------
    var group_count: u8 = 10;

    // Set keyboard mappings
    var keymap = []Key {
        Key.create(c"h", g_mod | g_mask_ctrl, Action {.Move = Direction.Left}),
        Key.create(c"l", g_mod | g_mask_ctrl, Action {.Move = Direction.Right}),
        Key.create(c"k", g_mod | g_mask_ctrl, Action {.Move = Direction.Up}),
        Key.create(c"j", g_mod | g_mask_ctrl, Action {.Move = Direction.Down}),

        Key.create(c"h", g_mod | g_mask_shift, Action {.Shift = Direction.Left}),
        Key.create(c"l", g_mod | g_mask_shift, Action {.Shift = Direction.Right}),
        Key.create(c"k", g_mod | g_mask_shift, Action {.Shift = Direction.Up}),
        Key.create(c"j", g_mod | g_mask_shift, Action {.Shift = Direction.Down}),

        Key.create(c"h", g_mod, Action {.Change = Direction.Left}),
        Key.create(c"l", g_mod, Action {.Change = Direction.Right}),
        Key.create(c"k", g_mod, Action {.Change = Direction.Up}),
        Key.create(c"j", g_mod, Action {.Change = Direction.Down}),

        Key.create(c"1", g_mod | g_mask_shift, Action {.WindowToGroup = {}}),
        Key.create(c"2", g_mod | g_mask_shift, Action {.WindowToGroup = {}}),
        Key.create(c"3", g_mod | g_mask_shift, Action {.WindowToGroup = {}}),
        Key.create(c"4", g_mod | g_mask_shift, Action {.WindowToGroup = {}}),
        Key.create(c"5", g_mod | g_mask_shift, Action {.WindowToGroup = {}}),
    };

    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    var return_screen: xcb_screen_iterator_t = undefined;
    _ = _xcb_setup_roots_iterator(xcb_get_setup(dpy), &return_screen);
    warn("{}\n", return_screen.data.?[0]);

    var screen_data = return_screen.data.?[0];
    var screen_root = return_screen.data.?[0].root;
    g_screen_root = screen_root;

    var return_cookie: xcb_void_cookie_t = undefined;

    var value_list = []c_int {
        @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT)
        // | @enumToInt(XCB_EVENT_MASK_EXPOSURE)
        // | @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY)
        // | @enumToInt(XCB_EVENT_MASK_STRUCTURE_NOTIFY)
        // | @enumToInt(XCB_EVENT_MASK_POINTER_MOTION),
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
            keysym = xlib.XStringToKeysym(key.char);
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
        panic("Failed to initalize groups' structures");
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
            var group = Group {
                .index = i,
                .windows = ArrayList(xcb_window_t).init(allocator),
                .str_value = val,
            };
            groups.set(i, group);
        }
    }

    // Create Screens
    // TODO: Implement defer
    var screens = ArrayList(Screen).init(allocator);
    defer screens.deinit();
    // TODO: implement fallback (else branch)
    if (number_of_monitors > 0) {
        const mask: u32 = @intCast(u32, @enumToInt(XCB_CW_BACKING_STORE)) 
                        | @intCast(u32, @enumToInt(XCB_CW_OVERRIDE_REDIRECT))
                        | @intCast(u32, @enumToInt(XCB_CW_EVENT_MASK))
                        | @intCast(u32, @enumToInt(XCB_CW_DONT_PROPAGATE));

        const values = []u32 { @intCast(u32, @enumToInt(XCB_BACKING_STORE_ALWAYS))
                             , 1
                             , _XCB_EVENT_MASK_ENTER_WINDOW
                             , 1};

        var j: u8 = 0;
        var return_monitors_iter: xcb_randr_monitor_info_iterator_t = undefined;
        _ = _xcb_randr_get_monitors_monitors_iterator(monitors, &return_monitors_iter);
        while (return_monitors_iter.rem != 0) : ({
            _ = xcb_randr_monitor_info_next(@ptrCast(?[*]struct_xcb_randr_monitor_info_iterator_t ,&return_monitors_iter));
            j += 1;
        }) {
            var monitor = return_monitors_iter.data.?[0];

            var geo = Geometry {
                .x = monitor.x,
                .y = monitor.y,
                .width = monitor.width,
                .height = monitor.height,
            };

            // Create 'root' window
            const win_id = xcb_generate_id(dpy);
            _ = _xcb_create_window(dpy, 0, win_id, g_screen_root,
                                   geo.x, geo.y, geo.width, geo.height,
                                   0,
                                   @intCast(u16, @enumToInt(XCB_WINDOW_CLASS_INPUT_OUTPUT)),
                                   screen_data.root_visual,
                                   mask, @ptrCast(*const c_void, &values),
                                   &return_pointer);

            var screen = try Screen.init(j, win_id, geo, allocator);

            screens.append(screen) catch {
                warn("Failed to add screen.\n");
                continue;
            };

            var rects = try getGridRectangles(allocator, screen);
            _ = _xcb_clear_area(dpy, 1, screen_root, screen.geo.x, screen.geo.y, screen.geo.width, screen.geo.height, &return_cookie);
            drawScreenGrid(dpy, screen_root, rects);

            _ = _xcb_map_window(dpy, win_id, &return_pointer);
        }
    }

    _ = _xcb_set_input_focus(dpy, _XCB_INPUT_FOCUS_PARENT, screens.at(0).root_id, _XCB_TIME_CURRENT_TIME, &return_cookie);

        _ = xcb_flush(dpy);
    std.c.free(@ptrCast(*c_void, &monitors.?[0]));
    var event_results = EventResults.init(allocator);
    defer event_results.deinit();
    {
        var return_tree: xcb_query_tree_cookie_t = undefined;
        _ = _xcb_query_tree(dpy, screen_root, &return_tree);
        var tree_reply = xcb_query_tree_reply(dpy, return_tree, null);
        var children = xcb_query_tree_children(tree_reply);
        var children_count = tree_reply.?[0].children_len;

        var i: u16 = 0;
        while (i < children_count) : (i+=1) {
            warn("{}\n", children.?[i]);
            var win_id = children.?[i];
            var fake_event = PackedEvent {
                .response_type = XCB_MAP_REQUEST,
                .pad0 = 0,
                .sequence = undefined,
                .parent = g_screen_root,
                .window = win_id,
            };

            // TODO: Maybe it is better to fill WindowAttributes, WindowChanges, ...
            // here. Then each window won't be check on every event loop. ???
            // Make map request switch option into function and use it here ???
            _ = _xcb_send_event(dpy, @boolToInt(true), g_screen_root,@intCast(u32, @enumToInt(XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT)), @ptrCast([*]const u8, &fake_event), &return_pointer);
            event_results.focus.new = win_id;
        }
        _ = xcb_flush(dpy);
    }

    var windows = WindowsHashMap.init(allocator);
    defer windows.deinit();
    var window_changes = ArrayList(WindowChange).init(allocator);
    defer window_changes.deinit();
    var map_windows = ArrayList(xcb_window_t).init(allocator);
    defer map_windows.deinit();
    var unmap_windows = ArrayList(xcb_window_t).init(allocator);
    defer unmap_windows.deinit();
    var window_attributes = ArrayList(WindowAttributes).init(allocator);
    defer window_attributes.deinit();



    while (true) {
        var event = xcb_wait_for_event(dpy);
        var ev = event.?[0];
        var res_type = ev.response_type & ~u8(0x80);
        switch (res_type) {
            XCB_DESTROY_NOTIFY => {
                warn("xcb: destroy notify\n");
                var e = @ptrCast(*xcb_destroy_window_request_t, &ev);
                warn("{}\n", e);

                if (windows.get(e.window)) |window| {
                    var group = &groups.toSlice()[window.value.group_index];
                    group.removeWindow(window.value.id, allocator);

                    var screen = getScreen(window.value.screen_index, screens);
                    _ = screen.removeWindow(window.value.id);

                    // TODO: handle group if there is no windows in it anymore ???
                    // Either remove it or keep it around. At the moment
                    // keeping it around seems better choice

                    _ = windows.remove(window.value.id);

                    // TODO: or instead focus window on the screen the mouse
                    // cursor is
                    if (screen.windows.len > 0) {
                        const new_window = screen.windows.at(0);
                        // TODO: rearrange Screen groups if new window's group index
                        // is different
                        var new_window_info = windows.get(new_window);
                        if (new_window_info != null and window.value.group_index != new_window_info.?.value.group_index) {
                            warn("group index changed\n");
                            _ = screen.removeGroup(new_window_info.?.value.group_index);
                            screen.addGroup(new_window_info.?.value.group_index);
                        }
                    }
                }
            },
            XCB_CONFIGURE_REQUEST => {
                warn("xcb: configure request\n");
                var e = @ptrCast(*xcb_configure_request_event_t, &ev);
                warn("{}\n", e);

                var change = configureWindow(allocator, e) catch |err| {
                    warn("configureWindow error: {}\n", err);
                    continue;
                };

                event_results.w_changes.append(change) catch {
                    warn("configure request: Failed to add window to changes array list\n.");
                    continue;
                };
            },
            XCB_CONFIGURE_NOTIFY => {
                warn("xcb: configure notify\n");
                var e = @ptrCast(*xcb_configure_notify_event_t, &ev);
                warn("{}\n", e);
            },
            XCB_SEND_EVENT => {
                warn("send event\n");
            },
            XCB_MAP_REQUEST => {
                warn("xcb: map request\n");
                var e = @ptrCast(*xcb_map_request_event_t, &ev);
warn("{}\n", e);

                // TODO: If I want to treat windows differently that were
                // open before loop started.
                var event_send = ev.response_type & u8(0x80) == 128;
                warn("event_send: {}\n", event_send);
                if (event_send) continue;

                var return_void_pointer: xcb_void_cookie_t = undefined;
                var return_geo: xcb_get_geometry_cookie_t = undefined;
                _ = _xcb_get_geometry(dpy, e.window, &return_geo);
                var geo = xcb_get_geometry_reply(dpy, return_geo, null);

                if (geo == null) continue;

                const win_geo = Geometry {
                    .x = geo.?[0].x,
                    .y = geo.?[0].y,
                    .width = geo.?[0].width,
                    .height = geo.?[0].height,
                };
                var active_screen = getActiveMouseScreen(dpy, screens);
                // TODO: make it possible to spawn windows in different locations
                const new_geo = newGeometryInsideScreen(win_geo, active_screen.*);

                const group_index = active_screen.groups.at(0);
                var group = &groups.toSlice()[group_index];
                const win = try addWindow(allocator, e.window, new_geo, active_screen, group, &windows);
                var attr_mask: u16 = _XCB_CW_EVENT_MASK;
                var attr_values = []u32 {_XCB_EVENT_MASK_ENTER_WINDOW | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY};
                _ = _xcb_change_window_attributes(dpy, e.window, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);

                setWindowEvents(dpy, e.window, keymap[0..]);

                var win_changes = WindowChange {
                    .id = win.id,
                    .mask = 0,
                    .values = ArrayList(i32).init(allocator),
                };

                win_changes.mask |= @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_X))
                                  | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_Y))
                                  | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_WIDTH))
                                  | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_HEIGHT))
                                  | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_BORDER_WIDTH));

                try win_changes.values.appendSlice([]i32 {
                    new_geo.x,
                    new_geo.y,
                    new_geo.width,
                    new_geo.height,
                    g_border_width,
                });

                try event_results.w_changes.append(win_changes);
                try event_results.w_map.append(e.window);

                // TODO: set border default color
            },
            XCB_UNMAP_NOTIFY => {
                warn("xcb: unmap notify\n");
            },
            XCB_MAP_NOTIFY => {
                warn("xcb: map notify\n");
            },
            XCB_EXPOSE => {
                warn("xcb: expose\n");
                // var e = @ptrCast(*xcb_expose_event_t, &ev);
                // warn("{}\n", e);
            },
            XCB_BUTTON_PRESS => {
                buttonpressEvent(allocator, dpy, ev, screens, groups, windows, screen_root);
            },
            XCB_BUTTON_RELEASE => {
                warn("xcb: button release\n");
            },
            XCB_MOTION_NOTIFY => {
                // warn("xcb: motion notify\n");
                // var e = @ptrCast(*xcb_motion_notify_event_t, &ev);
            },
            XCB_KEY_PRESS => {
                warn("xcb: key press before function call\n");
                keypressEvent(allocator, dpy, ev, screens, groups, windows, keymap[0..], &event_results);
            },
            XCB_KEY_RELEASE => {
                warn("xcb: key release\n");
            },
            XCB_ENTER_NOTIFY => {
                // warn("xcb: enter notify\n");
                var e = @ptrCast(*xcb_enter_notify_event_t, &ev);
                // if (e.detail == _XCB_NOTIFY_DETAIL_ANCESTOR) warn("ancestor\n");
                // if (e.detail == _XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL) warn("virtual\n");

                // if (e.detail != _XCB_NOTIFY_DETAIL_ANCESTOR) continue;
                // if (e.detail != _XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL) continue;
                if (e.detail == @intCast(u8, @enumToInt(XCB_NOTIFY_DETAIL_INFERIOR))) continue;
                warn("{}\n", e);

                // const focused_window = getFocusedWindow(dpy);
                // First check if it is screen 'root'
                const screen_root_id: xcb_window_t = blk: {
                    for (screens.toSliceConst()) |s| {
                        if (s.root_id == e.event) {
                            break :blk s.root_id;
                        }
                    }
                    break :blk 0;
                };
                // warn("root_id: {}\n", screen_root_id);
                if (screen_root_id != 0) {
                    warn("focus screen\n");
                    event_results.focus.new = screen_root_id;
                } else if (windows.get(e.event)) |win| {
                    warn("focus window\n");
                    const focused_window = getFocusedWindow(dpy);
                    if (focused_window == win.value.id) continue;
                    var active_screen = getScreen(win.value.screen_index, screens);

                    event_results.focus.new = win.value.id;
                    _ = active_screen.removeWindow(e.event);
                    active_screen.addWindow(e.event);

                    const win_group_index = win.value.group_index;
                    const group_index = active_screen.groups.at(0);
                    if (active_screen.groups.len > 1 and group_index != win_group_index) {
                        _ = active_screen.removeGroup(win_group_index);
                        active_screen.addGroup(win_group_index);
                    }

                    var target_group = &groups.toSlice()[win_group_index];
                    target_group.removeWindow(win.value.id, allocator);
                    target_group.addWindow(win.value.id, allocator);

                    // focusWindow(dpy, win.value.id, g_active_border_color);
                }
            },
            else => {
                warn("xcb: else -> \n");

                if (ev.response_type == 0) {
                    var buf: [1000]u8 = undefined;
                    var e = @ptrCast(*xcb_generic_error_t, &ev);
                    warn("error: {}\n", e);
                    std.c.free(@ptrCast(*c_void, &event.?[0]));
                    _ = xlib.XGetErrorText(@ptrCast(*xlib.struct__XDisplay, dpy), e.error_code, &buf, 1000);
                    warn("msg: {}\n", buf);
                }
            }
        }

        // Focus window
        // @continue
        // var mouse_screen = getActiveMouseScreen(dpy, screens);
        const current_focus = getFocusedWindow(dpy);
        warn("current focus: {}\n", current_focus);
        // const new_focus = blk: {
        //     if (mouse_screen.windows.len > 0) {
        //         break :blk mouse_screen.windows.at(0);
        //     }
        //     break :blk g_screen_root;
        // };
        const new_focus = event_results.focus.new;
        if (current_focus != new_focus) {
            warn("new focus: {}\n", new_focus);
            warn("current focus: {}\n", current_focus);
            const attr_mask = _XCB_CW_BORDER_PIXEL;
            // set default border color if current window if not root
            // if (current_focus != g_screen_root) {
            //     var attr = WindowAttributes {
            //         .id = current_focus,
            //         .mask = attr_mask,
            //         .values = ArrayList(u32).init(allocator),
            //     };
            //     attr.values.append(g_default_border_color) catch {
            //         warn("main loop (change window focus): Failed to add value to attributes values field.\n");
            //     };
            //     event_results.w_attrs.append(attr) catch {
            //         warn("main lopp (): Failed to add attribute.\n");
            //     };
            // }

            // set focused window color
            var attr = WindowAttributes {
                .id = new_focus,
                .mask = attr_mask,
                .values = ArrayList(u32).init(allocator),
            };
            attr.values.append(g_active_border_color) catch {
                warn("main loop (change window focus): Failed to add value to attributes values field.\n");
            };
            event_results.w_attrs.append(attr) catch {
                warn("main lopp (): Failed to add attribute.\n");
            };

            // set window focus
            var change = WindowChange {
                .id = new_focus,
                .mask = _XCB_CONFIG_WINDOW_STACK_MODE,
                .values = ArrayList(i32).init(allocator),
            };
            change.values.append(_XCB_STACK_MODE_ABOVE) catch {
                warn("main loop (change window focus): Failed to add value to change values field.\n");
            };
            event_results.w_changes.append(change) catch {
                warn("main lopp (): Failed to add window change.\n");
            };

            // NOTE: window needs to be visible/mapped to focus it
            _ = _xcb_map_window(dpy, new_focus, &return_pointer);
            _ = _xcb_set_input_focus(dpy, _XCB_INPUT_FOCUS_PARENT, new_focus, _XCB_TIME_CURRENT_TIME, &return_cookie);
        }

        // Set window attributes
        // TODO: X11 error: BadWindow
        // This happens with window that is already "on screen" before starting program
        for (event_results.w_attrs.toSlice()) |attr| {
            warn("event_results: set window attributes =====\n");
            _ = _xcb_change_window_attributes(dpy, attr.id, attr.mask, @ptrCast(?*const c_void, attr.values.toSlice().ptr), &return_pointer);
        }

        // Configure windows
        for (event_results.w_changes.toSlice()) |change| {
            warn("event_results: change window =====\n");
            _ = _xcb_configure_window(dpy, change.id, change.mask, @ptrCast(?*const c_void, change.values.toSlice().ptr), &return_pointer);
        }

        // Unmap windows
        for (event_results.w_unmap.toSlice()) |id| {
            warn("event_results: unmap window =====\n");
            _ = _xcb_unmap_window(dpy, id, &return_pointer);
        }

        // Map windows
        for (event_results.w_map.toSlice()) |id| {
            warn("event_results: map window =====\n");
            _ = _xcb_map_window(dpy, id, &return_pointer);
        }

        _ = xcb_flush(dpy);

        window_attributes.shrink(0);
        window_changes.shrink(0);
        map_windows.shrink(0);
        unmap_windows.shrink(0);

        event_results.reset();

        // warn("END LOOP\n");

    }
}

fn raiseWindow(dpy: ?*xcb_connection_t, window: xcb_window_t) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    const config_values = @ptrCast(?*const c_void, &([]u32 {_XCB_STACK_MODE_ABOVE}));
    _ = _xcb_configure_window(dpy, window, _XCB_CONFIG_WINDOW_STACK_MODE, config_values, &return_pointer);
}


fn moveWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, x: i32, y: i32) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    var win_mask: u16 = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
    var win_values = []i32 {x, y};

    _ = _xcb_configure_window(dpy, window, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
}


fn resizeWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, width: u32, height: u32) void {
    var return_pointer: xcb_void_cookie_t = undefined;
    var win_mask: u16 = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
    var win_values = []u32 {width, height};

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
    var attr_values = []u32 {color};
    _ = _xcb_change_window_attributes(dpy, window, attr_mask, @ptrCast(?*const c_void, &attr_values), &return_cookie);

    const config_values = @ptrCast(?*const c_void, &([]u32 {_XCB_STACK_MODE_ABOVE}));
    _ = _xcb_configure_window(dpy, window, _XCB_CONFIG_WINDOW_STACK_MODE, config_values, &return_cookie);
}


fn unfocusWindow(dpy: ?*xcb_connection_t, window: xcb_window_t, color: u32) void {
    var return_focus: xcb_get_input_focus_cookie_t = undefined;
    _ = _xcb_get_input_focus(dpy, &return_focus);
    var focus_reply = xcb_get_input_focus_reply(dpy, return_focus, null);

    var return_cookie: xcb_void_cookie_t = undefined;
    const attr_mask = _XCB_CW_BORDER_PIXEL;
    var attr_values = []u32 {color};
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

    return Geometry {
        .x = @intCast(i16, new_x),
        .y = @intCast(i16, new_y),
        .width = @intCast(u16, new_width),
        .height = @intCast(u16, new_height),
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

    return Geometry {
        .x = @intCast(i16, x),
        .y = @intCast(i16, y),
        .width = @intCast(u16, width),
        .height = @intCast(u16, height),
    };
}


fn isPointerInScreen(screen: Screen, x: i16 , y: i16) bool {
    var screen_x_right = screen.geo.x + @intCast(i32, screen.geo.width) - 1;
    var screen_y_bottom = screen.geo.y + @intCast(i32, screen.geo.height) - 1;

    return (x >= screen.geo.x)  and (x <= screen_x_right) 
            and (y >= screen.geo.y) and (y <= screen_y_bottom);
}


fn debugScreens(screens: ArrayList(Screen), windows: WindowsHashMap) void {
    var it = screens.iterator();
    var item = it.next();
    warn("\n----Screens----\n");
    while (item != null) : (item = it.next()) {
        var screen = item.?;
        warn("Screen |> index: {}", screen.index);
        warn(" | groups:");
        debugGroupsArray(screen.groups.toSlice());
        warn(" | windows:");
        debugWindowsArray(screen.windows, windows);
        warn("\n");
    }
}

fn debugWindowsArray(screen_windows: ArrayList(xcb_window_t), windows: WindowsHashMap) void {
    for (screen_windows.toSlice()) |win_id| {
        var win = windows.get(win_id);
        if (win != null) {
            warn(" {}({})", win_id, win.?.value.group_index);
        }
    }
}

fn debugGroupsArray(groups: []u8) void {
    for (groups) |group_index| {
        warn(" {}", group_index);
    }
}


// TODO: remove ???
fn debugScreenWindows(ll: ArrayList(Screen)) void {
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


fn addWindow(allocator: *Allocator, win: xcb_window_t, geo: Geometry, screen: *Screen, group: *Group, windows: *WindowsHashMap) !Window {
    var new_window = Window {
        .id = win,
        .screen_index = screen.index,
        .group_index = group.index,
        .geo = geo,
    };

    var result = try windows.put(win, new_window);
    _ = screen.addWindow(win);
    group.addWindow(win, allocator);

    return new_window;
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


fn getScreen(index: u8, screens: ArrayList(Screen)) *Screen {
    return &screens.toSlice()[index];
}


// TODO: redo. Use function that finds pointer position.
fn getActiveMouseScreen(dpy: ?*xcb_connection_t, screens: ArrayList(Screen)) *Screen {
    var return_pointer: xcb_query_pointer_cookie_t = undefined;
    _ = _xcb_query_pointer(dpy, g_screen_root, &return_pointer);
    var pointer_reply = xcb_query_pointer_reply(dpy, return_pointer, null);
    var pointer = pointer_reply.?[0];

    return getScreenOnLocation(pointer.root_x, pointer.root_y, screens) orelse &screens.toSlice()[0];
}

fn debugGroups(groups: ArrayList(Group)) void {
    warn("\n----Groups----\n");
    for (groups.toSliceConst()) |group| {
        warn("Group {} | windows:", group.index);
        for (group.windows.toSlice()) |win_id| {
            warn(" {}", win_id);
        }
        warn("\n");
    }
}


fn setWindowEvents(dpy: ?*xcb_connection_t, window: xcb_window_t, keymap: []Key) void {
    var return_void_pointer: xcb_void_cookie_t = undefined;
    var key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym: xlib.KeySym = undefined;
    var keycode: xcb_keycode_t = undefined;

    for (mouse_mapping) |event| {
        _ = grab_button(dpy, 1, window, _XCB_EVENT_MASK_BUTTON_PRESS, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, window, XCB_NONE, event.index, event.mod, &return_void_pointer);
    }

    for (keymap) |key| {
        keysym = xlib.XStringToKeysym(key.char);
        keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, keysym)).?[0];

        _ = _xcb_grab_key(dpy, 1, window, key.mod, keycode, _XCB_GRAB_MODE_ASYNC,
                          _XCB_GRAB_MODE_ASYNC, &return_void_pointer);

    }

    xcb_key_symbols_free(key_symbols);
}

// TODO: remove width and height after window navigation is done
fn configureWindow(allocator: *Allocator, e: *xcb_configure_request_event_t) !WindowChange {
    // var i: u8 = 0;
    // var config_mask: u16 = 0;
    // var config_values: [3]u32 = undefined; // TODO

    // config_mask = config_mask | _XCB_CONFIG_WINDOW_WIDTH;
    // config_values[i] = 130;
    // i += 1;

    // config_mask = config_mask | _XCB_CONFIG_WINDOW_HEIGHT;
    // config_values[i] = 105;
    // i += 1;

    // config_mask = config_mask | _XCB_CONFIG_WINDOW_BORDER_WIDTH;
    // config_values[i] = g_border_width;
    // i += 1;

    // var return_pointer: xcb_void_cookie_t = undefined;
    // _ = _xcb_configure_window(dpy, win, config_mask, @ptrCast(?*const c_void, &config_values), &return_pointer);

    var i: u8 = 0;
    var config_mask: u16 = 0;
    var config_values: [6]i32 = undefined;

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

    if (i == 0) return error.NoAttributeChanges;

    var change = WindowChange {
        .id = e.window,
        .mask = config_mask,
        .values = ArrayList(i32).init(allocator),
    };
    try change.values.appendSlice(config_values[0..i]);

    return change;
}



// TODO: bad name. resizing and moving happens in bounds
fn resizeAndMoveWindow(dpy: ?*xcb_connection_t, win: xcb_window_t, active_screen: *Screen) void {
    var return_geo: xcb_get_geometry_cookie_t = undefined;
    _ = _xcb_get_geometry(dpy, win, &return_geo);
    var geo = xcb_get_geometry_reply(dpy, return_geo, null);
    var new_geo = getWindowGeometryInside(geo.?[0], active_screen);

    var win_mask: u16 = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y | _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
    var win_values = []i32 {new_geo.x, new_geo.y, new_geo.width, new_geo.height};

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

            var rect = xcb_rectangle_t {
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


fn drawScreenGrid(dpy: ?*xcb_connection_t, screen_root: xcb_window_t, rects: []xcb_rectangle_t) void {
    var return_void: xcb_void_cookie_t = undefined;
    var gc_mask = u32(_XCB_GC_FOREGROUND);
    var gc_values = []u32 {g_grid_color};
    const root_gc_id_ = xcb_generate_id(dpy);
    _ = _xcb_create_gc(dpy, root_gc_id_, screen_root, gc_mask, @ptrCast(?*const c_void, &gc_values), &return_void);
    _ = _xcb_poly_rectangle(dpy, screen_root, root_gc_id_, g_grid_total, @ptrCast(?[*]xcb_rectangle_t, rects.ptr), &return_void);
}

fn drawAllScreenGrids(dpy: ?*xcb_connection_t, allocator: *Allocator, screens: ArrayList(Screen), screen_root: xcb_window_t) !void {
    if (g_grid_show) {
        var screen_node = screens.first;
        while (screen_node != null) : (screen_node = screen_node.?.next) {
            var rects = try getGridRectangles(allocator, screen_node.?.data);
            drawScreenGrid(dpy, screen_root, rects);
        }
    }
}


fn keypressEvent(allocator: *Allocator, dpy: ?*xcb_connection_t, ev: xcb_generic_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap, keymap: []Key, event_results: *EventResults) void {
    warn("xcb: key press\n");
    const e = @intToPtr(*xcb_key_press_event_t, @ptrToInt(&ev));
    // warn("{}\n", e);

    const key_symbols = xcb_key_symbols_alloc(dpy);
    var keysym = xcb_key_press_lookup_keysym(key_symbols, @ptrCast(?[*]xcb_key_press_event_t, e), 0);
    xcb_key_symbols_free(key_symbols);

    for (root_keymap) |key| {
        if (key.mod == e.state and keysym == @intCast(u32, xlib.XStringToKeysym(key.char))) {
            switch (key.action) {
                Action.Spawn => |app| keypressSpawn(allocator, app),
                Action.ToggleGroup => keypressToggleGroup(allocator, dpy, e, screens, groups, windows),
                Action.Debug => {
                    debugScreens(screens, windows);
                    debugWindows(windows);
                    debugGroups(groups);
                },
                Action.Move,
                Action.Shift,
                Action.Change,
                Action.WindowToGroup => return,
            }
            break; // TODO: change to return after refactor
        }
    }

    for (keymap) |key| {
        if (key.mod == e.state and keysym == @intCast(u32, xlib.XStringToKeysym(key.char))) {
            switch (key.action) {
                Action.Move => |direction| {
                    warn("dir: {}\n", direction);
                    if (windows.get(e.event)) |win| {
                        const change = keypressMove(allocator, direction, &win.value, screens, groups) catch {
                            warn("keypressEvent: Failed to get window move changes.\n");
                            return;
                        };
                        event_results.w_changes.append(change) catch {
                            warn("keypressEvent: Failed to add window move changes.\n");
                            return;
                        };
                    }
                },
                Action.Shift => |direction| {
                    warn("dir: {}\n", direction);
                    switch (direction) {
                        Direction.Left => keypressShiftLeft(allocator, dpy, e, screens, groups, windows),
                        Direction.Right => keypressShiftRight(allocator, dpy, e, screens, groups, windows),
                        Direction.Up => keypressShiftUp(allocator, dpy, e, screens, groups, windows),
                        Direction.Down => keypressShiftDown(allocator, dpy, e, screens, groups, windows),
                    }
                },
                Action.Change => |direction| {
                    warn("dir: {}\n", direction);
                    switch (direction) {
                        Direction.Left => keypressChangeLeft(allocator, dpy, e, screens, groups, windows),
                        Direction.Right => keypressChangeRight(allocator, dpy, e, screens, groups, windows),
                        Direction.Up => keypressChangeUp(allocator, dpy, e, screens, groups, windows),
                        Direction.Down => keypressChangeDown(allocator, dpy, e, screens, groups, windows),
                    }
                },
                Action.WindowToGroup => {
                    if (windows.get(e.event)) |win| {
                        const change = keypressWindowToGroup(allocator, dpy, e, screens, groups, &win.value) catch {
                            warn("keypressEvent: Failed to get window move changes.\n");
                            return;
                        };
                        if (change) |c| {
                            event_results.w_changes.append(c) catch {
                                warn("keypressEvent: Failed to add window move changes.\n");
                                return;
                            };
                        } else {
                            event_results.w_unmap.append(e.event) catch {
                                warn("keypressEvent: Failed to add window to unmap array list.\n");
                                return;
                            };
                        }
                    }
                },
                Action.Spawn,
                Action.Debug,
                Action.ToggleGroup => return,
            }
            break; // TODO: change to return after refactor
        }
    }


    _ = xcb_flush(dpy);
}


fn keypressMove(allocator: *Allocator, direction: Direction, win: *Window, screens: ArrayList(Screen), groups: ArrayList(Group)) !WindowChange {
    // TODO: Do I need a separate value for win.geo here ???
    var win_geo = win.geo;
    var screen = getScreen(win.screen_index, screens);
    var mask: u16 = 0;
    var value: i32 = 0;

    switch (direction) {
        Direction.Left => {
            win_geo.x = win_geo.x - @intCast(i16, g_window_move_x);
            mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_X));
            value = win_geo.x;
        },
        Direction.Right => {
            win_geo.x = win_geo.x + @intCast(i16, g_window_move_x);
            mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_X));
            value = win_geo.x;
        },
        Direction.Up => {
            win_geo.y = win_geo.y - @intCast(i16, g_window_move_y);
            mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_Y));
            value = win_geo.y;
        },
        Direction.Down => {
            win_geo.y = win_geo.y + @intCast(i16, g_window_move_y);
            mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_Y));
            value = win_geo.y;
        },
    }

    var change = WindowChange {
        .id = win.id,
        .mask = mask,
        .values = ArrayList(i32).init(allocator),
    };
    try change.values.append(value);

    win.geo = win_geo;

    if (!isLocationInScreen(win_geo.x, win_geo.y, screen.*)) {
        const new_screen = getScreenOnLocation(@intCast(i16, win_geo.x), @intCast(i16, win_geo.y), screens);

        if (new_screen != null and screen.index != new_screen.?.index) {
            _ = screen.windowToScreen(win, new_screen.?, groups.toSlice());
        }
    }

    return change;
}


fn keypressShiftLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift left\n");
    const win = windows.get(e.event);
    if (win == null) return;
    const win_geo = win.?.value.geo;
    var screen = getScreen(win.?.value.screen_index, screens);

    var new_x = @intCast(i32, win_geo.x);
    const tile_width = @intCast(i16, @divTrunc(screen.geo.width - 2 * g_screen_padding, g_grid_cols));

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
        const x = @intCast(i16, win_geo.x - @intCast(i16, tile_width));
        const win_edge_y = win_geo.y + @intCast(i16, win_geo.height + 2 * g_border_width);
        const new_screen = getScreenOnLocation(x, @intCast(i16, win_geo.y) + screen_padding, screens) orelse getScreenOnLocation(x, win_edge_y - screen_padding, screens);
        warn("screen\n");

        if (new_screen != null and screen.index != new_screen.?.index) {
            warn("screen cont\n");
            win.?.value = screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());
            new_x = new_screen.?.geo.x + @intCast(i16, new_screen.?.geo.width) - screen_padding - win_total_width;
        }
    }

    if (new_x != win_geo.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
        win.?.value.geo.x = @intCast(i16, new_x);
    }

}

fn keypressShiftRight(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift right\n");
    const win = windows.get(e.event);
    if (win == null) return;
    const win_geo = win.?.value.geo;
    var screen = getScreen(win.?.value.screen_index, screens);

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
        const x = @intCast(i16, win_geo.x + win_total_width + @intCast(i16, tile_width));
        const win_edge_y = @intCast(i16, win_geo.y) + @intCast(i16, @intCast(u16, win_geo.height) + 2 * g_border_width);
        const new_screen = getScreenOnLocation(x, @intCast(i16, win_geo.y) + screen_padding, screens) orelse getScreenOnLocation(x, win_edge_y - screen_padding, screens);
        warn("screen\n");

        if (new_screen != null and screen.index != new_screen.?.index) {
            warn("screen cont\n");
            win.?.value = screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());
            new_x = new_screen.?.geo.x + screen_padding;
        }
    }

    if (new_x != win_geo.x) {
        moveWindow(dpy, e.event, new_x, win_geo.y);
        win.?.value.geo.x = @intCast(i16, new_x);
    }
}

fn keypressShiftUp(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift up\n");
    const win = windows.get(e.event);
    if (win == null) return;
    const win_geo = win.?.value.geo;
    var screen = getScreen(win.?.value.screen_index, screens);

    var new_y = @intCast(i32, win_geo.y);
    const tile_height: i32 = @divTrunc(screen.geo.height - 2 * g_screen_padding, g_grid_rows);

    const win_total_height = @intCast(i16, @intCast(u16, win_geo.height) + 2 * g_border_width);
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
        const y = @intCast(i16, win_geo.y) - @intCast(i16, tile_height);
        const win_edge_x = @intCast(i16, win_geo.x) + @intCast(i16, @intCast(u16, win_geo.width) + 2 * g_border_width);
        const new_screen = getScreenOnLocation(@intCast(i16, win_geo.x) + screen_padding, y, screens) orelse getScreenOnLocation(win_edge_x - screen_padding, y, screens);
        warn("screen\n");

        if (new_screen != null and screen.index != new_screen.?.index) {
            warn("screen cont\n");
            win.?.value = screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());
            new_y = new_screen.?.geo.y + @intCast(i16, new_screen.?.geo.height) - screen_padding - win_total_height;
        }
    }

    if (new_y != win_geo.y) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
        win.?.value.geo.y = @intCast(i16, new_y);
    }
}

fn keypressShiftDown(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("shift down\n");
    const win = windows.get(e.event);
    if (win == null) return;
    const win_geo = win.?.value.geo;
    var screen = getScreen(win.?.value.screen_index, screens);

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
        const y = win_geo.y + @intCast(i16, win_total_height + tile_height);
        const win_edge_x = win_geo.x + @intCast(i16, win_geo.width + 2 * g_border_width);
        const new_screen = getScreenOnLocation(@intCast(i16, win_geo.x) + screen_padding, y, screens) orelse getScreenOnLocation(win_edge_x - screen_padding, y, screens);
        warn("screen\n");

        if (new_screen != null and screen.index != new_screen.?.index) {
            warn("screen cont\n");
            win.?.value = screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());
            new_y = new_screen.?.geo.y + screen_padding;
        }
    }

    if (new_y != win_geo.y) {
        moveWindow(dpy, e.event, win_geo.x, new_y);
        win.?.value.geo.y = @intCast(i16, new_y);
    }

}

fn keypressChangeLeft(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("keypress change left\n");
    const win = windows.get(e.event);
    const win_geo = win.?.value.geo;
    const screen = getScreen(win.?.value.screen_index, screens);
    var new_screen = screen;

    const win_center = Point {
        .x = win_geo.x + @intCast(i16, win_geo.width / 2) + @intCast(i16, g_border_width),
        .y = win_geo.y + @intCast(i16, win_geo.height / 2) + @intCast(i16, g_border_width),
    };

    const largest_distance = blk: {
        var largest_dim: u16 = 0;
        for (screen.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;

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

    var t1 = Point {
        .x = win_center.x - largest_distance,
        .y = win_center.y - largest_distance,
    };
    var t2 = Point {
        .x = win_center.x - largest_distance,
        .y = win_center.y + largest_distance,
    };

    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = 0;
    var closest_win_distance: u16 = std.math.maxInt(u16);
    for (screen.windows.toSlice()) |win_id| {
        const win_s = windows.get(win_id);
        if (win_s == null) continue;
        const geo = win_s.?.value.geo;

        var closest_win_point = Point {
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
                if (win_id < win.?.value.id and win_id > closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    for (screens.toSlice()) |screen_item, i| {
        if (screen_item.index == screen.index) continue;
        // if (is_left and screen_item.x > screen.geo.x) continue;

        const screen_midpoint = screen_item.geo.y + @intCast(i16, screen_item.geo.height / 2);
        if (screen_midpoint < screen.geo.y or screen_midpoint > screen_bottom_y) continue;

        for (screen_item.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;
            const x_midpoint = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width);

            if (x_midpoint > win_center.x) continue;

            const closest_win_point = Point {
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
                if (win_id < win.?.value.id and win_id > closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                    new_screen = &screens.toSlice()[i];
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
                new_screen = &screens.toSlice()[i];
            } 
        }

    }

    if (closest_win != 0 and closest_win != std.math.maxInt(u32)) {
        _ = new_screen.removeWindow(closest_win);
        new_screen.addWindow(closest_win);
        if (windows.get(closest_win)) |window| {
            var group = &groups.toSlice()[window.value.group_index];
            group.removeWindow(closest_win, allocator);
            group.addWindow(closest_win, allocator);
        }
        unfocusWindow(dpy, win.?.value.id, g_default_border_color);
        focusWindow(dpy, closest_win, g_active_border_color);
    }
}


fn keypressChangeRight(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    warn("keypress change left\n");

    const win = windows.get(e.event);
    const win_geo = win.?.value.geo;
    const screen = getScreen(win.?.value.screen_index, screens);
    var new_screen = screen;

    const win_center = Point {
        .x = win_geo.x + @intCast(i16, win_geo.width / 2) + @intCast(i16, g_border_width),
        .y = win_geo.y + @intCast(i16, win_geo.height / 2) + @intCast(i16, g_border_width),
    };


    const largest_distance = blk: {
        var largest_dim: u16 = 0;

        for (screen.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;

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


    const t1 = Point {
        .x = win_center.x + largest_distance,
        .y = win_center.y - largest_distance,
    };
    const t2 = Point {
        .x = win_center.x + largest_distance,
        .y = win_center.y + largest_distance,
    };

    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = std.math.maxInt(u32);
    var closest_win_distance: u16 = std.math.maxInt(u16);
    for (screen.windows.toSlice()) |win_id| {
        const win_s = windows.get(win_id);
        if (win_s == null) continue;
        const geo = win_s.?.value.geo;

        var closest_win_point = Point {
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
                if (win_id > win.?.value.id and win_id < closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    for (screens.toSlice()) |screen_item, i| {
        if (screen_item.index == screen.index) continue;

        const screen_midpoint = screen_item.geo.y + @intCast(i16, screen_item.geo.height / 2);
        if (screen_midpoint < screen.geo.y or screen_midpoint > screen_bottom_y) continue;

        for (screen_item.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;
            const x_midpoint = geo.x + @intCast(i16, geo.width / 2) + @intCast(i16, g_border_width);
            if (x_midpoint < win_center.x) continue;

            const closest_win_point = Point {
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
                if (win_id > win.?.value.id and win_id < closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                    new_screen = &screens.toSlice()[i];
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
                new_screen = &screens.toSlice()[i];
            } 
        }

    }

    if (closest_win != 0 and closest_win != std.math.maxInt(u32)) {
        _ = new_screen.removeWindow(closest_win);
        new_screen.addWindow(closest_win);
        if (windows.get(closest_win)) |window| {
            var group = &groups.toSlice()[window.value.group_index];
            group.removeWindow(closest_win, allocator);
            group.addWindow(closest_win, allocator);
        }
        unfocusWindow(dpy, win.?.value.id, g_default_border_color);
        focusWindow(dpy, closest_win, g_active_border_color);
    }
}



fn keypressChangeUp(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    const win = windows.get(e.event);
    const win_geo = win.?.value.geo;
    const screen = getScreen(win.?.value.screen_index, screens);
    var new_screen = screen;

    const win_center = Point {
        .x = win_geo.x + @intCast(i16, win_geo.width / 2) + @intCast(i16, g_border_width),
        .y = win_geo.y + @intCast(i16, win_geo.height / 2) + @intCast(i16, g_border_width),
    };


    const largest_distance = blk: {
        var largest_dim: u16 = 0;

        for (screen.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;

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

    const t1 = Point {
        .x = win_center.x - largest_distance,
        .y = win_center.y - largest_distance,
    };
    const t2 = Point {
        .x = win_center.x + largest_distance,
        .y = win_center.y - largest_distance,
    };

    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = 0;
    var closest_win_distance: u16 = std.math.maxInt(u16);
    for (screen.windows.toSlice()) |win_id| {
        const win_s = windows.get(win_id);
        if (win_s == null) continue;
        const geo = win_s.?.value.geo;

        var closest_win_point = Point {
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
                if (win_id < win.?.value.id and win_id > closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    for (screens.toSlice()) |screen_item, i| {
        if (screen_item.index == screen.index) continue;

        const screen_midpoint = screen_item.geo.x + @intCast(i16, screen_item.geo.width / 2);
        if (screen_midpoint < screen.geo.x or screen_midpoint > screen_right_x) continue;
        for (screen_item.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;
            const y_midpoint = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width);

            if (y_midpoint > win_center.y) continue;

            const closest_win_point = Point {
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
                if (win_id < win.?.value.id and win_id > closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                    new_screen = &screens.toSlice()[i];
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
                new_screen = &screens.toSlice()[i];
            } 
        }

    }

    if (closest_win != 0 and closest_win != std.math.maxInt(u32)) {
        _ = new_screen.removeWindow(closest_win);
        new_screen.addWindow(closest_win);
        if (windows.get(closest_win)) |window| {
            var group = &groups.toSlice()[window.value.group_index];
            group.removeWindow(closest_win, allocator);
            group.addWindow(closest_win, allocator);
        }
        unfocusWindow(dpy, win.?.value.id, g_default_border_color);
        focusWindow(dpy, closest_win, g_active_border_color);
    }
}


fn keypressChangeDown(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    const win = windows.get(e.event);
    const win_geo = win.?.value.geo;
    const screen = getScreen(win.?.value.screen_index, screens);
    var new_screen = screen;

    const win_center = Point {
        .x = win_geo.x + @intCast(i16, win_geo.width / 2) + @intCast(i16, g_border_width),
        .y = win_geo.y + @intCast(i16, win_geo.height / 2) + @intCast(i16, g_border_width),
    };


    const largest_distance = blk: {
        var largest_dim: u16 = 0;
        for (screen.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;


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


    const t1 = Point {
        .x = win_center.x - largest_distance,
        .y = win_center.y + largest_distance,
    };
    const t2 = Point {
        .x = win_center.x + largest_distance,
        .y = win_center.y + largest_distance,
    };

    // NOTE: left, up = 0 | right, down = maxInt(u32)
    var closest_win: xcb_window_t = std.math.maxInt(u32);
    var closest_win_distance: u16 = std.math.maxInt(u16);

    for (screen.windows.toSlice()) |win_id| {
        const win_s = windows.get(win_id);
        if (win_s == null) continue;
        const geo = win_s.?.value.geo;

        var closest_win_point = Point {
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
                if (win_id > win.?.value.id and win_id < closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
            } 
        }

    }

    const screen_bottom_y = (screen.geo.y + @intCast(i32, screen.geo.height));
    const screen_right_x = (screen.geo.x + @intCast(i32, screen.geo.width));
    for (screens.toSlice()) |screen_item, i| {

        if (screen_item.index == screen.index) continue;

        const screen_midpoint = screen_item.geo.x + @intCast(i16, screen_item.geo.width / 2);
        if (screen_midpoint < screen.geo.x or screen_midpoint > screen_right_x) continue;
        for (screen_item.windows.toSlice()) |win_id| {
            const win_s = windows.get(win_id);
            if (win_s == null) continue;
            const geo = win_s.?.value.geo;

            const y_midpoint = geo.y + @intCast(i16, geo.height / 2) + @intCast(i16, g_border_width);

            if (y_midpoint < win_center.y) continue;

            const closest_win_point = Point {
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
                if (win_id > win.?.value.id and win_id < closest_win) {
                    closest_win = win_id;
                    closest_win_distance = new_distance;
                    new_screen = &screens.toSlice()[i];
                }
            } else if (new_distance < closest_win_distance) {
                closest_win = win_id;
                closest_win_distance = new_distance;
                new_screen = &screens.toSlice()[i];
            } 
        }

    }

    if (closest_win != 0 and closest_win != std.math.maxInt(u32)) {
        _ = new_screen.removeWindow(closest_win);
        new_screen.addWindow(closest_win);
        if (windows.get(closest_win)) |window| {
            var group = &groups.toSlice()[window.value.group_index];
            group.removeWindow(closest_win, allocator);
            group.addWindow(closest_win, allocator);
        }
        unfocusWindow(dpy, win.?.value.id, g_default_border_color);
        focusWindow(dpy, closest_win, g_active_border_color);
    }
}


// TODO: bug when choosing third group. Only thrid group will be in screen.
fn keypressToggleGroup(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap) void {
    var return_cookie: xcb_void_cookie_t = undefined;
    // TODO: return group instead
    var selected_group_index = blk: {
        var e_ = @intToPtr(?[*]struct_xcb_key_press_event_t, @ptrToInt(e));
        const key_symbols = xcb_key_symbols_alloc(dpy);
        const keysym = xcb_key_press_lookup_keysym(key_symbols, e_, 0);
        xcb_key_symbols_free(key_symbols);
        for (groups.toSlice()) |*group, i| {
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
    const group_index = mouse_screen.groups.at(0);

    if (mouse_screen.groups.len == 1 and selected_group.index == group_index) return;

    // See if group is on any of the screens
    for (screens.toSlice()) |screen_item, i| {
        var item = &screens.toSlice()[i];
        if (item.groups.len == 1 and item.groups.at(0) == selected_group.index) return;
        if (item.groups.len == 1) continue;

        if (item.removeGroup(selected_group.index)) {
            const window_ids = selected_group.windows.toSlice();
            for (window_ids) |_, j| {
                const win_id = window_ids[window_ids.len - 1 - j];
                if (item.removeWindow(win_id)) {
                    _ = _xcb_unmap_window(dpy, win_id, &return_cookie);
                }
            }
            break;
        }
    }


    // Add and map window to screen
    if (selected_group_index != group_index) {
        const window_ids = selected_group.windows.toSlice();
        mouse_screen.addGroup(selected_group.index);
        mouse_screen.windows.insertSlice(0, window_ids) catch {
            warn("keypressToggleGroup: Failed to enter ids into Screen windows");
            return;
        };
        for (window_ids) |_, i| {
            var win = windows.get(window_ids[window_ids.len - 1 - i]);
            if (win == null) continue;

            if (win.?.value.screen_index != mouse_screen.index) {
                var old_screen = getScreen(win.?.value.screen_index, screens);
                win.?.value.geo = old_screen.recalculateWindowGeometry(win.?.value.geo, mouse_screen);
                win.?.value.screen_index = mouse_screen.index;
                moveWindow(dpy, win.?.value.id, win.?.value.geo.x, win.?.value.geo.y);
                resizeWindow(dpy, win.?.value.id, @intCast(u32, win.?.value.geo.width), @intCast(u32, win.?.value.geo.height));

            }

            raiseWindow(dpy, win.?.value.id);
            _ = _xcb_map_window(dpy, win.?.value.id, &return_cookie);
        }
    }

    if (mouse_screen.windows.len > 0) {
        const focused_window = getFocusedWindow(dpy);
        unfocusWindow(dpy, focused_window, g_default_border_color);
        focusWindow(dpy, mouse_screen.windows.at(0), g_active_border_color);
    }
}


// TODO: Something is wrong with window dimension calculations
// TODO: Bug window isn't moved visually. Might be a (xcb_)flush problem.
fn keypressWindowToGroup(allocator: *Allocator, dpy: ?*xcb_connection_t, e: *xcb_key_press_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), win: *Window) !?WindowChange {
    var return_cookie: xcb_void_cookie_t = undefined;
    warn("move window to a group\n");
    // TODO: return group instead.
    var dest_group_index = blk: {
        var e_ = @intToPtr(?[*]struct_xcb_key_press_event_t, @ptrToInt(e));
        const key_symbols = xcb_key_symbols_alloc(dpy);
        const keysym = xcb_key_press_lookup_keysym(key_symbols, e_, 0);
        xcb_key_symbols_free(key_symbols);
        for (groups.toSlice()) |*group, i| {
            const sym = @intCast(u32, xlib.XStringToKeysym(@ptrCast(?[*]const u8, group.str_value[0..].ptr)));
            if (sym == keysym) {
                break :blk i;
            }
        }

        warn("keypressGroupMoveWindow: Didn't find group with key pressed.\n");
        return error.UnknownGroup;
    };

    var dest_group = &groups.toSlice()[dest_group_index];
    // TODO: Bad solution. Doing this because I am using return value to check something
    if (dest_group.index == win.group_index) return error.SameGroup;

    var src_group = &groups.toSlice()[win.group_index];
    src_group.removeWindow(win.id, allocator);
    dest_group.addWindow(win.id, allocator);
    win.group_index = dest_group.index;

    var window_change: ?WindowChange = null;
    var slice = screens.toSlice();
    screen_loop: for (slice) |_, i| {
        var item = &slice[i];
        if (win.screen_index == item.index) continue;
        for (item.groups.toSlice()) |group_index| {
            if (group_index == dest_group.index) {
                item.addWindow(win.id);
                var screen = getScreen(win.screen_index, screens);
                _ = screen.removeWindow(win.id);
                unfocusWindow(dpy, win.id, g_default_border_color);
                win.geo = screen.recalculateWindowGeometry(win.geo, item);
                win.screen_index = item.index;

                window_change = WindowChange {
                    .id = win.id,
                    .mask = @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_X))
                          | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_Y))
                          | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_WIDTH))
                          | @intCast(u16, @enumToInt(XCB_CONFIG_WINDOW_HEIGHT)),
                    .values = ArrayList(i32).init(allocator),
                };
                try window_change.?.values.appendSlice([]i32 {
                    win.geo.x,
                    win.geo.y,
                    win.geo.width,
                    win.geo.height,
                });

                // _ = _xcb_map_window(dpy, win.id, &return_cookie);

                // TODO: Or focus new window the screen the source/target
                // (var window_screen) window was ???
                const mouse_screen = getActiveMouseScreen(dpy, screens);
                if (mouse_screen.windows.len > 0) {
                    focusWindow(dpy, mouse_screen.windows.at(0), g_active_border_color);
                }

                // raiseWindow(dpy, win.id);
                break :screen_loop;
            }
        }
    }

    return window_change;
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


fn buttonpressEvent(allocator: *Allocator, dpy: ?*xcb_connection_t, ev: xcb_generic_event_t, screens: ArrayList(Screen), groups: ArrayList(Group), windows: WindowsHashMap, screen_root: xcb_window_t) void {
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

    var active_screen = getScreen(win.?.value.screen_index, screens);
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
                                win_values = []i32 {new_geometry.width, new_geometry.height};
                            },
                            MouseAction.Resize => {
                                warn("mouse resize.\n");
                                new_geometry = buttonpressMotionResizeWindow(e, e_inside, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_WIDTH | _XCB_CONFIG_WINDOW_HEIGHT;
                                win_values = []i32 {new_geometry.width, new_geometry.height};
                            },
                            MouseAction.MoveInBounds => {
                                // warn("mouse move inbounds.\n");
                                const screen = getScreenOnLocation(e_inside.root_x, e_inside.root_y, screens) orelse active_screen;
                                new_geometry = buttonpressMotionMoveWindowInBounds(e, e_inside, screen, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
                                win_values = []i32 {new_geometry.x, new_geometry.y};
                            },
                            MouseAction.Move => {
                                warn("mouse move.\n");
                                new_geometry = buttonpressMotionMoveWindow(e, e_inside, win.?.value.geo);

                                win_mask = _XCB_CONFIG_WINDOW_X | _XCB_CONFIG_WINDOW_Y;
                                win_values = []i32 {new_geometry.x, new_geometry.y};
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

                var new_screen = getScreenOnLocation(e_inside.root_x, e_inside.root_y, screens);
                if (new_screen != null and win.?.value.screen_index != new_screen.?.index) {
                    warn("window has changed screen\n");

                    win.?.value = active_screen.windowToScreen(&win.?.value, new_screen.?, groups.toSlice());
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

    if (geo.width > screen.geo.width) {
        new_win_geometry.x = screen.geo.x + @intCast(i16, g_screen_padding);
    }

    if (geo.height > screen.geo.height) {
        new_win_geometry.y = screen.geo.y + @intCast(i16, g_screen_padding);
    }

    return new_win_geometry;
}

fn buttonpressMotionMoveWindow(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, geo: Geometry) Geometry {
    const xdiff = e_inside.root_x - e.root_x;
    const ydiff = e_inside.root_y - e.root_y;

    const x: i16 = geo.x + xdiff;
    const y: i16 = geo.y + ydiff;

    return Geometry {
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

    return Geometry {
        .x = geo.x,
        .y = geo.y,
        .width = new_geometry.width,
        .height = new_geometry.height,
    };
}


fn buttonpressMotionResizeWindow(e: *xcb_button_press_event_t, e_inside: *xcb_motion_notify_event_t, geo: Geometry) Geometry {
    const xdiff = e_inside.root_x - e.root_x;
    const ydiff = e_inside.root_y - e.root_y;
    const width = @intCast(i16, geo.width) + xdiff;
    const height = @intCast(i16, geo.height) + ydiff;

    return Geometry {
        .x = geo.x,
        .y = geo.y,
        .width = @intCast(u16, std.math.max(@intCast(i16, g_window_min_width), width)),
        .height = @intCast(u16, std.math.max(@intCast(i16, g_window_min_height), height)),
    };
}


fn getScreenOnLocation(x: i16, y: i16, screens: ArrayList(Screen)) ?*Screen {
    var slice = screens.toSlice();
    for (slice) |screen, i| {
        if (isLocationInScreen(x, y, screen)) {
            return &slice[i];
        }
    }

    return null;
}

fn isLocationInScreen(x: i16, y: i16, screen: Screen) bool {
    const screen_x_right = screen.geo.x + @intCast(i16, screen.geo.width) - 1;
    const screen_y_bottom = screen.geo.y + @intCast(i16, screen.geo.height) - 1;

    return (x >= screen.geo.x)  and (x <= screen_x_right) 
            and (y >= screen.geo.y) and (y <= screen_y_bottom);
}


fn newGeometryInsideScreen(geo: Geometry, screen: Screen) Geometry {
    var screen_width:i32 = screen.geo.width - 2 * g_screen_padding;
    var screen_height:i32 = screen.geo.height - 2 * g_screen_padding;
    var x:i32 = geo.x - screen.geo.x;
    var y:i32 = geo.y - screen.geo.y;
    var width:i32 = geo.width;
    var height:i32 = geo.height;        
    const bw = @intCast(i32, g_border_width);
    const sp = @intCast(i32, g_screen_padding);

    // Width and x coordinate
    var win_total_width = width + 2 * bw;

    if (win_total_width >= screen_width) {
        width = screen_width - 2 * bw;
    }

    win_total_width = width + 2 * bw;

    if ((x + win_total_width) >= screen_width) {
        // x = x - (x + win_total_width - screen_width) - sp;
        x = screen.geo.x + screen_width - sp - win_total_width;
    }

    x = std.math.max(sp, x) + screen.geo.x;


    // Height and y coordinate
    var win_total_height = height + 2 * bw;

    if (win_total_height >= screen_height) {
        height = screen_height - 2 * bw;
    }

    win_total_height = height + 2 * bw;

    if ((y + win_total_height) >= screen_height) {
        y = y - (y + win_total_height - screen_height) - sp;
    }

    y = std.math.max(sp, y) + screen.geo.y;

    return Geometry {
        .x = @intCast(i16, x),
        .y = @intCast(i16, y),
        .width = @intCast(u16, width),
        .height = @intCast(u16, height),
    };
}
