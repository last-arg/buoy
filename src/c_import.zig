pub use @cImport({
    @cInclude("xcb/xcb.h");
    @cInclude("xcb/xcb_keysyms.h");
    @cInclude("xcb/randr.h");
});

// const xatom = @cImport({
//     @cInclude("X11/Xproto.h");
//     @cInclude("X11/Xatom.h");
// });

// NOTE: Add underscore to avoid redefinition error
pub const _XCB_EVENT_MASK_BUTTON_PRESS = 4;
pub const _XCB_EVENT_MASK_BUTTON_RELEASE = 8;
pub const _XCB_MOD_MASK_SHIFT = 1;
pub const _XCB_MOD_MASK_CONTROL = 4;
pub const _XCB_MOD_MASK_1 = 8;
pub const _XCB_MOD_MASK_2 = 16;
pub const _XCB_GRAB_MODE_SYNC = 0;
pub const _XCB_GRAB_MODE_ASYNC = 1;
pub const XCB_NONE = 0;
pub const XCB_NO_SYMBOL = 0;
pub const _XCB_EVENT_MASK_ENTER_WINDOW = 16;
pub const _XCB_EVENT_MASK_POINTER_MOTION = 64;
pub const _XCB_EVENT_MASK_EXPOSURE = 32768;
pub const _XCB_EVENT_MASK_BUTTON_MOTION = 8192;
pub const _XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY = 524288;
pub const _XCB_TIME_CURRENT_TIME = 0;
pub const _XCB_STACK_MODE_ABOVE = 0;
pub const _XCB_NOTIFY_MODE_NORMAL = 0;

pub const _XCB_NOTIFY_DETAIL_ANCESTOR = 0;
pub const _XCB_NOTIFY_DETAIL_VIRTUAL = 1;
pub const _XCB_NOTIFY_DETAIL_INFERIOR = 2;
pub const _XCB_NOTIFY_DETAIL_NONLINEAR = 3;
pub const _XCB_NOTIFY_DETAIL_NONLINEAR_VIRTUAL = 4;

pub const _XCB_BUTTON_INDEX_ANY = 0;
pub const _XCB_BUTTON_INDEX_1 = 1;
pub const _XCB_BUTTON_INDEX_2 = 2;
pub const _XCB_BUTTON_INDEX_3 = 3;

pub const _XCB_CW_BACK_PIXEL = 2;
pub const _XCB_CW_EVENT_MASK = 2048;
pub const _XCB_CW_CURSOR = 16384;
pub const _XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT = 1048576;
pub const _XCB_CW_BORDER_PIXMAP = 4;
pub const _XCB_INPUT_FOCUS_POINTER_ROOT = 1;
pub const _XCB_INPUT_FOCUS_PARENT = 2;

pub const _XCB_CONFIG_WINDOW_X = 1;
pub const _XCB_CONFIG_WINDOW_Y = 2;
pub const _XCB_CONFIG_WINDOW_WIDTH = 4;
pub const _XCB_CONFIG_WINDOW_HEIGHT = 8;
pub const _XCB_CONFIG_WINDOW_BORDER_WIDTH = 16;
pub const _XCB_CONFIG_WINDOW_SIBLING = 32;
pub const _XCB_CONFIG_WINDOW_STACK_MODE = 64;
pub const _XCB_GRAB_ANY = 0;
pub const _XCB_GC_FOREGROUND = 4;
pub const _XCB_GC_FUNCTION = 1;
pub const _XCB_CW_BORDER_PIXEL = 8;


pub const _XCB_GC_BACKGROUND = 8;
pub const _XCB_GC_SUBWINDOW_MODE = 32768;
pub const _XCB_GC_GRAPHICS_EXPOSURES = 65536;
