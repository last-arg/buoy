
#include <xcb/xcb.h>
#include <xcb/randr.h>

xcb_screen_iterator_t *_xcb_setup_roots_iterator(const xcb_setup_t *R, xcb_screen_iterator_t *return_screen);

xcb_void_cookie_t *grab_button(xcb_connection_t *conn, uint8_t owner_events, xcb_window_t grab_window, uint16_t event_mask, uint8_t pointer_mode, uint8_t keyboard_mode, xcb_window_t confine_to, xcb_cursor_t cursor, uint8_t button, uint16_t modifiers, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_grab_key(xcb_connection_t *conn, uint8_t owner_events, xcb_window_t grab_window, uint16_t modifiers, xcb_keycode_t key, uint8_t pointer_mode, uint8_t keyboard_mode, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_change_window_attributes(xcb_connection_t *conn, xcb_window_t window, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_configure_window(xcb_connection_t *conn, xcb_window_t window, uint16_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_free_pixmap(xcb_connection_t *conn, xcb_pixmap_t pixmap, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_create_pixmap(xcb_connection_t *conn, uint8_t depth, xcb_pixmap_t pid, xcb_drawable_t drawable, uint16_t width, uint16_t height, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_create_gc(xcb_connection_t *conn, xcb_gcontext_t cid, xcb_drawable_t drawable, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_change_gc(xcb_connection_t *conn, xcb_gcontext_t gc, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer);

xcb_alloc_named_color_cookie_t *_xcb_alloc_named_color(xcb_connection_t *conn, xcb_colormap_t cmap, uint16_t name_len, const char *name, xcb_alloc_named_color_cookie_t *return_pointer);

xcb_randr_get_monitors_cookie_t *_xcb_randr_get_monitors(xcb_connection_t *conn, xcb_window_t window, uint8_t get_active, xcb_randr_get_monitors_cookie_t *return_pointer); 

xcb_randr_monitor_info_iterator_t *_xcb_randr_get_monitors_monitors_iterator(const xcb_randr_get_monitors_reply_t *reply, xcb_randr_monitor_info_iterator_t *return_pointer);

xcb_query_tree_cookie_t *_xcb_query_tree(xcb_connection_t *conn, xcb_window_t window, xcb_query_tree_cookie_t *return_pointer);

xcb_query_pointer_cookie_t *_xcb_query_pointer(xcb_connection_t *conn, xcb_window_t window, xcb_query_pointer_cookie_t *return_pointer);

// NOTE: not on zig side
xcb_translate_coordinates_cookie_t *_xcb_translate_coordinates(xcb_connection_t *conn, xcb_window_t src_window, xcb_window_t dst_window, int16_t src_x, int16_t src_y, xcb_translate_coordinates_cookie_t *return_pointer);

xcb_get_geometry_cookie_t *_xcb_get_geometry(xcb_connection_t *conn, xcb_drawable_t drawable, xcb_get_geometry_cookie_t *return_pointer);

xcb_grab_pointer_cookie_t *_xcb_grab_pointer(xcb_connection_t *conn, uint8_t owner_events, xcb_window_t grab_window, uint16_t event_mask, uint8_t pointer_mode, uint8_t keyboard_mode, xcb_window_t confine_to, xcb_cursor_t cursor, xcb_timestamp_t time, xcb_grab_pointer_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_ungrab_pointer(xcb_connection_t *conn, xcb_timestamp_t time, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_set_input_focus(xcb_connection_t *conn, uint8_t revert_to, xcb_window_t focus, xcb_timestamp_t time, xcb_void_cookie_t *return_pointer);

xcb_get_input_focus_cookie_t *_xcb_get_input_focus(xcb_connection_t *conn, xcb_get_input_focus_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_map_window(xcb_connection_t *conn, xcb_window_t window, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_unmap_window(xcb_connection_t *conn, xcb_window_t window, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_warp_pointer(xcb_connection_t *conn, xcb_window_t src_window, xcb_window_t dst_window, int16_t src_x, int16_t src_y, uint16_t src_width, uint16_t src_height, int16_t dst_x, int16_t dst_y, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_open_font(xcb_connection_t *conn, xcb_font_t fid, uint16_t name_len, const char * name, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_create_glyph_cursor(xcb_connection_t *conn, xcb_cursor_t cid, xcb_font_t source_font, xcb_font_t mask_font, uint16_t source_char, uint16_t mask_char, uint16_t fore_red, uint16_t fore_green, uint16_t fore_blue, uint16_t back_red, uint16_t back_green, uint16_t back_blue, xcb_void_cookie_t *return_pointer);

xcb_void_cookie_t *_xcb_free_cursor(xcb_connection_t *connection, xcb_cursor_t cursor, xcb_void_cookie_t *return_pointer);

