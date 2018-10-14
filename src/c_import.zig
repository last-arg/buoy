pub use @cImport({
    @cInclude("xcb/xcb.h");
    @cInclude("xcb/xcb_keysyms.h");
    @cInclude("xcb/randr.h");
});

// const xatom = @cImport({
//     @cInclude("X11/Xproto.h");
//     @cInclude("X11/Xatom.h");
// });
