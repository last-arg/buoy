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

// NOTE: At the bottom of the file there are manually imported external functions
use @cImport({
    @cInclude("xcb/xcb.h");
    @cInclude("xcb/xcb_keysyms.h");
});


// NOTE: Add underscore to avoid redefinition error
const _XCB_EVENT_MASK_BUTTON_PRESS = 4;
const _XCB_EVENT_MASK_BUTTON_RELEASE = 8;
const _XCB_MOD_MASK_2 = 16;
const _XCB_GRAB_MODE_SYNC = 0;
const _XCB_GRAB_MODE_ASYNC = 1;
const _XCB_MOD_MASK_1 = 8;
const XCB_NONE = 0;
const XCB_NO_SYMBOL = 0;
const _XCB_EVENT_MASK_POINTER_MOTION = 64;
const _XCB_EVENT_MASK_EXPOSURE = 32768;
const _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY = 524288;
const _XCB_CW_BACK_PIXEL = 2;
const _XCB_CW_EVENT_MASK = 2048;
const _XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT = 1048576;

const _XCB_CONFIG_WINDOW_X = 1;
const _XCB_CONFIG_WINDOW_Y = 2;
const _XCB_CONFIG_WINDOW_WIDTH = 4;
const _XCB_CONFIG_WINDOW_HEIGHT = 8;
const _XCB_CONFIG_WINDOW_BORDER_WIDTH = 16;
const _XCB_CONFIG_WINDOW_SIBLING = 32;
const _XCB_CONFIG_WINDOW_STACK_MODE = 64;
const _XCB_GRAB_ANY = 0;


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
    // TODO: Change/Add different allocator(s)
    const allocator = std.heap.c_allocator;

    var dpy = xcb_connect(null, null);
    if (xcb_connection_has_error(dpy) > 0) return error.FailedToOpenDisplay;

    var return_screen: xcb_screen_iterator_t = undefined;
    var screen = _xcb_setup_roots_iterator(xcb_get_setup(dpy), &return_screen);
    warn("{}\n", return_screen.data.?[0]);
    // warn("{}\n", screen.data.?[0]);


    var root = return_screen.data.?[0].root;

    var return_cookie: xcb_void_cookie_t = undefined;

    var value_list = []c_uint{
        _XCB_EVENT_MASK_POINTER_MOTION
        | _XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT
        | _XCB_EVENT_MASK_EXPOSURE
        | _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
    };
    _ = _xcb_change_window_attributes(dpy, root, _XCB_CW_EVENT_MASK, @ptrCast(?*const c_void, &value_list), &return_cookie);

    // _ = grab_button(dpy, 0, root, _XCB_EVENT_MASK_BUTTON_PRESS|_XCB_EVENT_MASK_BUTTON_RELEASE, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, root, XCB_NONE, 1, _XCB_MOD_MASK_1, &return_cookie);

    {
        var key_symbols = xcb_key_symbols_alloc(dpy);
    // warn("{}\n", xcb_key_symbols_get_keysym(key_symbols, 84, 0));
    // t -> 84
        // xcb_key_symbols_get_keycode();
        var t_keysym = xlib.XStringToKeysym(c"t");
        var t_keycode = xcb_key_symbols_get_keycode(key_symbols, @intCast(u32, t_keysym)).?[0];
        _ = _xcb_grab_key(dpy, 1, root, _XCB_MOD_MASK_1, t_keycode, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, &return_cookie);

        xcb_key_symbols_free(key_symbols);
    }

    _ = xcb_flush(dpy);

    while (true) {
        var ev = xcb_wait_for_event(dpy).?[0];

        // warn("{}\n", ev.?[0]);
        var res_type = ev.response_type & ~u8(0x80);
        switch (res_type) {
            XCB_CONFIGURE_REQUEST => {
                warn("xcb: configure request\n");
                var e = @ptrCast(*xcb_configure_request_event_t, &ev);
                // var win_values = undefined;
                var i: u8 = 0;
                var win_mask: u16 = 0;
                var win_values: [7]u32 = undefined;
warn("{}\n", e);

warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_X);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_X) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_X;
                    win_values[i] = 10;
                    i += 1;
                }
warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_Y);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_Y) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_Y;
                    win_values[i] = 10;
                    i += 1;
                }
warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_WIDTH);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_WIDTH) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_WIDTH;
                    win_values[i] = e.width;
                    i += 1;
                }
warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_HEIGHT);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_HEIGHT) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_HEIGHT;
                    win_values[i] = e.height;
                    i += 1;
                }

// warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_BORDER_WIDTH);
//                 if ((e.value_mask & _XCB_CONFIG_WINDOW_BORDER_WIDTH) > 0) {
//                     win_mask = win_mask | _XCB_CONFIG_WINDOW_BORDER_WIDTH;
//                     win_values[i] = BORDER_WIDTH;
//                     i += 1;
//                 }

warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_SIBLING);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_SIBLING) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_SIBLING;
                    win_values[i] = e.sibling;
                    i += 1;
                }

warn("{}\n", e.value_mask & _XCB_CONFIG_WINDOW_STACK_MODE);
                if ((e.value_mask & _XCB_CONFIG_WINDOW_STACK_MODE) > 0) {
                    win_mask = win_mask | _XCB_CONFIG_WINDOW_STACK_MODE;
                    win_values[i] = e.stack_mode;
                    i += 1;
                }

                var return_pointer: xcb_void_cookie_t = undefined;
                _ = _xcb_configure_window(dpy, e.window, win_mask, @ptrCast(?*const c_void, &win_values), &return_pointer);
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



                _ = grab_button(dpy, 1, e.window, _XCB_EVENT_MASK_BUTTON_PRESS|_XCB_EVENT_MASK_BUTTON_RELEASE, _XCB_GRAB_MODE_ASYNC, _XCB_GRAB_MODE_ASYNC, root, XCB_NONE, 1, _XCB_MOD_MASK_1, &return_void_pointer);

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

                _ = xcb_flush(dpy);
            },
            XCB_BUTTON_RELEASE => {
                warn("xcb: button release\n");
                _ = xcb_flush(dpy);
            },
            XCB_MOTION_NOTIFY => {
                warn("xcb: motion notify\n");
                _ = xcb_flush(dpy);
            },
            XCB_KEY_PRESS => {
                warn("xcb: key press\n");
                var e = @ptrCast(*xcb_key_press_event_t, &ev);
warn("{}\n", ev);
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






pub extern fn _xcb_setup_roots_iterator(R: ?[*]const xcb_setup_t, return_screen: *xcb_screen_iterator_t) *xcb_screen_iterator_t;

pub extern fn grab_button(conn: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, button: u8, modifiers: u16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_grab_key(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, modifiers: u16, key: xcb_keycode_t, pointer_mode: u8, keyboard_mode: u8, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_change_window_attributes(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_configure_window(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_map_window(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;
