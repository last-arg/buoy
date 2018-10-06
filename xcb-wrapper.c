
#include "xcb-wrapper.h"

xcb_screen_iterator_t *_xcb_setup_roots_iterator(const xcb_setup_t *R, xcb_screen_iterator_t *return_screen) {
  xcb_screen_iterator_t screen = xcb_setup_roots_iterator(R);
  *return_screen = screen;
  return return_screen;
}

xcb_void_cookie_t *grab_button(xcb_connection_t *conn, uint8_t owner_events, xcb_window_t grab_window, uint16_t event_mask, uint8_t pointer_mode, uint8_t keyboard_mode, xcb_window_t confine_to, xcb_cursor_t cursor, uint8_t button, uint16_t modifiers, xcb_void_cookie_t *return_pointer) {  
  xcb_void_cookie_t result = xcb_grab_button(conn, owner_events, grab_window, event_mask, pointer_mode, keyboard_mode, confine_to, cursor, button, modifiers);
  *return_pointer = result;
  return return_pointer;
}


xcb_void_cookie_t *_xcb_grab_key(xcb_connection_t *conn, uint8_t owner_events, xcb_window_t grab_window, uint16_t modifiers, xcb_keycode_t key, uint8_t pointer_mode, uint8_t keyboard_mode, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_grab_key(conn, owner_events, grab_window, modifiers, key, pointer_mode, keyboard_mode);
  *return_pointer = result;
  return return_pointer;
}

xcb_void_cookie_t *_xcb_change_window_attributes(xcb_connection_t *conn, xcb_window_t window, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_change_window_attributes(conn, window, value_mask, value_list);
  *return_pointer = result;
  return return_pointer;
}


xcb_void_cookie_t *_xcb_configure_window(xcb_connection_t *conn, xcb_window_t window, uint16_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_configure_window(conn, window, value_mask, value_list);
  *return_pointer = result;
  return return_pointer;
}

xcb_void_cookie_t *_xcb_map_window(xcb_connection_t *conn, xcb_window_t window, xcb_void_cookie_t * return_pointer) {
  xcb_void_cookie_t result = xcb_map_window(conn, window);
  *return_pointer = result;
  return return_pointer;
}


xcb_void_cookie_t *_xcb_free_pixmap(xcb_connection_t *conn, xcb_pixmap_t pixmap, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_free_pixmap(conn, pixmap);
  *return_pointer = result;
  return return_pointer;
}


xcb_void_cookie_t *_xcb_create_pixmap(xcb_connection_t *conn, uint8_t depth, xcb_pixmap_t pid, xcb_drawable_t drawable, uint16_t width, uint16_t height, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_create_pixmap(conn, depth, pid, drawable, width, height);
  *return_pointer = result;
  return return_pointer;
}

xcb_void_cookie_t *_xcb_create_gc(xcb_connection_t *conn, xcb_gcontext_t cid, xcb_drawable_t drawable, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_create_gc(conn, cid, drawable, value_mask, value_list);
  *return_pointer = result;
  return return_pointer;
}

xcb_void_cookie_t *_xcb_change_gc(xcb_connection_t *conn, xcb_gcontext_t gc, uint32_t value_mask, const uint32_t *value_list, xcb_void_cookie_t *return_pointer) {
  xcb_void_cookie_t result = xcb_change_gc(conn, gc, value_mask, value_list);
  *return_pointer = result;
  return return_pointer;
}

xcb_alloc_named_color_cookie_t *_xcb_alloc_named_color(xcb_connection_t *conn, xcb_colormap_t cmap, uint16_t name_len, const char *name, xcb_alloc_named_color_cookie_t *return_pointer) {
  xcb_alloc_named_color_cookie_t result = xcb_alloc_named_color(conn, cmap, name_len, name);
  *return_pointer = result;
  return return_pointer;
}

xcb_randr_get_monitors_cookie_t *_xcb_randr_get_monitors(xcb_connection_t *conn, xcb_window_t window, uint8_t get_active, xcb_randr_get_monitors_cookie_t *return_pointer) {
  xcb_randr_get_monitors_cookie_t result = xcb_randr_get_monitors(conn, window, get_active);
  *return_pointer = result;
  return return_pointer;
}

xcb_randr_monitor_info_iterator_t *_xcb_randr_get_monitors_monitors_iterator(const xcb_randr_get_monitors_reply_t *reply, xcb_randr_monitor_info_iterator_t *return_pointer) {
  xcb_randr_monitor_info_iterator_t result = xcb_randr_get_monitors_monitors_iterator(reply);
  *return_pointer = result;
  return return_pointer;
}

xcb_query_tree_cookie_t *_xcb_query_tree(xcb_connection_t *conn, xcb_window_t window, xcb_query_tree_cookie_t *return_pointer) {
  xcb_query_tree_cookie_t result = xcb_query_tree(conn, window);
  *return_pointer = result;
  return return_pointer;
}

xcb_query_pointer_cookie_t *_xcb_query_pointer(xcb_connection_t *conn, xcb_window_t window, xcb_query_pointer_cookie_t *return_pointer) {
  xcb_query_pointer_cookie_t result = xcb_query_pointer(conn, window);
  *return_pointer = result;
  return return_pointer;
}

// NOTE: not on zig side
xcb_translate_coordinates_cookie_t *_xcb_translate_coordinates(xcb_connection_t *conn, xcb_window_t src_window, xcb_window_t dst_window, int16_t src_x, int16_t src_y, xcb_translate_coordinates_cookie_t *return_pointer) {
  xcb_translate_coordinates_cookie_t result = xcb_translate_coordinates(conn, src_window, dst_window, src_x, src_y);
  *return_pointer = result;
  return return_pointer;
}

xcb_get_geometry_cookie_t *_xcb_get_geometry(xcb_connection_t *conn, xcb_drawable_t drawable, xcb_get_geometry_cookie_t *return_pointer) {
  xcb_get_geometry_cookie_t result = xcb_get_geometry(conn, drawable);
  *return_pointer = result;
  return return_pointer;
}
