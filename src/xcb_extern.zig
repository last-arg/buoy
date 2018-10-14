use @import("c_import.zig");

pub extern fn _xcb_setup_roots_iterator(R: ?[*]const xcb_setup_t, return_screen: *xcb_screen_iterator_t) *xcb_screen_iterator_t;

pub extern fn grab_button(conn: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, event_mask: u16, pointer_mode: u8, keyboard_mode: u8, confine_to: xcb_window_t, cursor: xcb_cursor_t, button: u8, modifiers: u16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_grab_key(c: ?*xcb_connection_t, owner_events: u8, grab_window: xcb_window_t, modifiers: u16, key: xcb_keycode_t, pointer_mode: u8, keyboard_mode: u8, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_change_window_attributes(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u32, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_configure_window(c: ?*xcb_connection_t, window: xcb_window_t, value_mask: u16, value_list: ?*const c_void, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

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

pub extern fn _xcb_set_input_focus(c: ?*xcb_connection_t, revert_to: u8, focus: xcb_window_t, time_0: xcb_timestamp_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_get_input_focus(c: ?*xcb_connection_t, return_pointer: *xcb_get_input_focus_cookie_t) *xcb_get_input_focus_cookie_t;

pub extern fn _xcb_map_window(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_unmap_window(c: ?*xcb_connection_t, window: xcb_window_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;


pub extern fn _xcb_warp_pointer(c: ?*xcb_connection_t, src_window: xcb_window_t, dst_window: xcb_window_t, src_x: i16, src_y: i16, src_width: u16, src_height: u16, dst_x: i16, dst_y: i16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_open_font(c: ?*xcb_connection_t, fid: xcb_font_t, name_len: u16, name: ?[*]const u8, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_create_glyph_cursor(c: ?*xcb_connection_t, cid: xcb_cursor_t, source_font: xcb_font_t, mask_font: xcb_font_t, source_char: u16, mask_char: u16, fore_red: u16, fore_green: u16, fore_blue: u16, back_red: u16, back_green: u16, back_blue: u16, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_free_cursor(c: ?*xcb_connection_t, cursor: xcb_cursor_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;

pub extern fn _xcb_poly_rectangle(c: ?*xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, rectangles_len: u32, rectangles: ?[*]const xcb_rectangle_t, return_pointer: *xcb_void_cookie_t) *xcb_void_cookie_t;
