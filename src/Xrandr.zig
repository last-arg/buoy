pub const Rotation = c_ushort;
pub const SizeID = c_ushort;
pub const SubpixelOrder = c_ushort;
pub const Connection = c_ushort;
pub const XRandrRotation = c_ushort;
pub const XRandrSizeID = c_ushort;
pub const XRandrSubpixelOrder = c_ushort;
pub const XRandrModeFlags = c_ulong;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int,
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*c_void;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = ?[*]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const off_t = __off_t;
pub const pid_t = __pid_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const clock_t = __clock_t;
pub const clockid_t = __clockid_t;
pub const time_t = __time_t;
pub const timer_t = __timer_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = u8;
pub const u_int16_t = c_ushort;
pub const u_int32_t = c_uint;
pub const u_int64_t = c_ulong;
pub const register_t = c_long;
pub fn __uint16_identity(__x: __uint16_t) __uint16_t {
    return __x;
}
pub fn __uint32_identity(__x: __uint32_t) __uint32_t {
    return __x;
}
pub fn __uint64_identity(__x: __uint64_t) __uint64_t {
    return __x;
}
pub const __sigset_t = extern struct {
    __val: [16]c_ulong,
};
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t,
    tv_usec: __suseconds_t,
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t,
    tv_nsec: __syscall_slong_t,
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
pub const fd_set = extern struct {
    __fds_bits: [16]__fd_mask,
};
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: ?[*]fd_set, noalias __writefds: ?[*]fd_set, noalias __exceptfds: ?[*]fd_set, noalias __timeout: ?[*]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: ?[*]fd_set, noalias __writefds: ?[*]fd_set, noalias __exceptfds: ?[*]fd_set, noalias __timeout: ?[*]const struct_timespec, noalias __sigmask: ?[*]const __sigset_t) c_int;
pub extern fn gnu_dev_major(__dev: __dev_t) c_uint;
pub extern fn gnu_dev_minor(__dev: __dev_t) c_uint;
pub extern fn gnu_dev_makedev(__major: c_uint, __minor: c_uint) __dev_t;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint,
    __writers: c_uint,
    __wrphase_futex: c_uint,
    __writers_futex: c_uint,
    __pad3: c_uint,
    __pad4: c_uint,
    __cur_writer: c_int,
    __shared: c_int,
    __rwelision: i8,
    __pad1: [7]u8,
    __pad2: c_ulong,
    __flags: c_uint,
};
pub const struct___pthread_internal_list = extern struct {
    __prev: ?[*]struct___pthread_internal_list,
    __next: ?[*]struct___pthread_internal_list,
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int,
    __count: c_uint,
    __owner: c_int,
    __nusers: c_uint,
    __kind: c_int,
    __spins: c_short,
    __elision: c_short,
    __list: __pthread_list_t,
};
pub const struct___pthread_cond_s = extern struct {
    @"": extern union {
        __wseq: c_ulonglong,
        __wseq32: extern struct {
            __low: c_uint,
            __high: c_uint,
        },
    },
    @"": extern union {
        __g1_start: c_ulonglong,
        __g1_start32: extern struct {
            __low: c_uint,
            __high: c_uint,
        },
    },
    __g_refs: [2]c_uint,
    __g_size: [2]c_uint,
    __g1_orig_size: c_uint,
    __wrefs: c_uint,
    __g_signals: [2]c_uint,
};
pub const pthread_t = c_ulong;
pub const pthread_mutexattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const XID = c_ulong;
pub const Mask = c_ulong;
pub const Atom = c_ulong;
pub const VisualID = c_ulong;
pub const Time = c_ulong;
pub const Window = XID;
pub const Drawable = XID;
pub const Font = XID;
pub const Pixmap = XID;
pub const Cursor = XID;
pub const Colormap = XID;
pub const GContext = XID;
pub const KeySym = XID;
pub const KeyCode = u8;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __clang_max_align_nonce1: c_longlong,
    __clang_max_align_nonce2: c_longdouble,
};
pub extern fn _Xmblen(str: ?[*]u8, len: c_int) c_int;
pub const XPointer = ?[*]u8;
pub const struct__XExtData = extern struct {
    number: c_int,
    next: ?[*]struct__XExtData,
    free_private: ?extern fn(?[*]struct__XExtData) c_int,
    private_data: XPointer,
};
pub const XExtData = struct__XExtData;
pub const XExtCodes = extern struct {
    extension: c_int,
    major_opcode: c_int,
    first_event: c_int,
    first_error: c_int,
};
pub const XPixmapFormatValues = extern struct {
    depth: c_int,
    bits_per_pixel: c_int,
    scanline_pad: c_int,
};
pub const XGCValues = extern struct {
    function: c_int,
    plane_mask: c_ulong,
    foreground: c_ulong,
    background: c_ulong,
    line_width: c_int,
    line_style: c_int,
    cap_style: c_int,
    join_style: c_int,
    fill_style: c_int,
    fill_rule: c_int,
    arc_mode: c_int,
    tile: Pixmap,
    stipple: Pixmap,
    ts_x_origin: c_int,
    ts_y_origin: c_int,
    font: Font,
    subwindow_mode: c_int,
    graphics_exposures: c_int,
    clip_x_origin: c_int,
    clip_y_origin: c_int,
    clip_mask: Pixmap,
    dash_offset: c_int,
    dashes: u8,
};
pub const struct__XGC = @OpaqueType();
pub const GC = ?*struct__XGC;
pub const Visual = extern struct {
    ext_data: ?[*]XExtData,
    visualid: VisualID,
    class: c_int,
    red_mask: c_ulong,
    green_mask: c_ulong,
    blue_mask: c_ulong,
    bits_per_rgb: c_int,
    map_entries: c_int,
};
pub const Depth = extern struct {
    depth: c_int,
    nvisuals: c_int,
    visuals: ?[*]Visual,
};
pub const struct__XDisplay = @OpaqueType();
pub const Screen = extern struct {
    ext_data: ?[*]XExtData,
    display: ?*struct__XDisplay,
    root: Window,
    width: c_int,
    height: c_int,
    mwidth: c_int,
    mheight: c_int,
    ndepths: c_int,
    depths: ?[*]Depth,
    root_depth: c_int,
    root_visual: ?[*]Visual,
    default_gc: GC,
    cmap: Colormap,
    white_pixel: c_ulong,
    black_pixel: c_ulong,
    max_maps: c_int,
    min_maps: c_int,
    backing_store: c_int,
    save_unders: c_int,
    root_input_mask: c_long,
};
pub const ScreenFormat = extern struct {
    ext_data: ?[*]XExtData,
    depth: c_int,
    bits_per_pixel: c_int,
    scanline_pad: c_int,
};
pub const XSetWindowAttributes = extern struct {
    background_pixmap: Pixmap,
    background_pixel: c_ulong,
    border_pixmap: Pixmap,
    border_pixel: c_ulong,
    bit_gravity: c_int,
    win_gravity: c_int,
    backing_store: c_int,
    backing_planes: c_ulong,
    backing_pixel: c_ulong,
    save_under: c_int,
    event_mask: c_long,
    do_not_propagate_mask: c_long,
    override_redirect: c_int,
    colormap: Colormap,
    cursor: Cursor,
};
pub const XWindowAttributes = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    depth: c_int,
    visual: ?[*]Visual,
    root: Window,
    class: c_int,
    bit_gravity: c_int,
    win_gravity: c_int,
    backing_store: c_int,
    backing_planes: c_ulong,
    backing_pixel: c_ulong,
    save_under: c_int,
    colormap: Colormap,
    map_installed: c_int,
    map_state: c_int,
    all_event_masks: c_long,
    your_event_mask: c_long,
    do_not_propagate_mask: c_long,
    override_redirect: c_int,
    screen: ?[*]Screen,
};
pub const XHostAddress = extern struct {
    family: c_int,
    length: c_int,
    address: ?[*]u8,
};
pub const XServerInterpretedAddress = extern struct {
    typelength: c_int,
    valuelength: c_int,
    type: ?[*]u8,
    value: ?[*]u8,
};
pub const struct_funcs = extern struct {
    create_image: ?extern fn(?*struct__XDisplay, ?[*]Visual, c_uint, c_int, c_int, ?[*]u8, c_uint, c_uint, c_int, c_int) ?[*]struct__XImage,
    destroy_image: ?extern fn(?[*]struct__XImage) c_int,
    get_pixel: ?extern fn(?[*]struct__XImage, c_int, c_int) c_ulong,
    put_pixel: ?extern fn(?[*]struct__XImage, c_int, c_int, c_ulong) c_int,
    sub_image: ?extern fn(?[*]struct__XImage, c_int, c_int, c_uint, c_uint) ?[*]struct__XImage,
    add_pixel: ?extern fn(?[*]struct__XImage, c_long) c_int,
};
pub const struct__XImage = extern struct {
    width: c_int,
    height: c_int,
    xoffset: c_int,
    format: c_int,
    data: ?[*]u8,
    byte_order: c_int,
    bitmap_unit: c_int,
    bitmap_bit_order: c_int,
    bitmap_pad: c_int,
    depth: c_int,
    bytes_per_line: c_int,
    bits_per_pixel: c_int,
    red_mask: c_ulong,
    green_mask: c_ulong,
    blue_mask: c_ulong,
    obdata: XPointer,
    f: struct_funcs,
};
pub const XImage = struct__XImage;
pub const XWindowChanges = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    sibling: Window,
    stack_mode: c_int,
};
pub const XColor = extern struct {
    pixel: c_ulong,
    red: c_ushort,
    green: c_ushort,
    blue: c_ushort,
    flags: u8,
    pad: u8,
};
pub const XSegment = extern struct {
    x1: c_short,
    y1: c_short,
    x2: c_short,
    y2: c_short,
};
pub const XPoint = extern struct {
    x: c_short,
    y: c_short,
};
pub const XRectangle = extern struct {
    x: c_short,
    y: c_short,
    width: c_ushort,
    height: c_ushort,
};
pub const XArc = extern struct {
    x: c_short,
    y: c_short,
    width: c_ushort,
    height: c_ushort,
    angle1: c_short,
    angle2: c_short,
};
pub const XKeyboardControl = extern struct {
    key_click_percent: c_int,
    bell_percent: c_int,
    bell_pitch: c_int,
    bell_duration: c_int,
    led: c_int,
    led_mode: c_int,
    key: c_int,
    auto_repeat_mode: c_int,
};
pub const XKeyboardState = extern struct {
    key_click_percent: c_int,
    bell_percent: c_int,
    bell_pitch: c_uint,
    bell_duration: c_uint,
    led_mask: c_ulong,
    global_auto_repeat: c_int,
    auto_repeats: [32]u8,
};
pub const XTimeCoord = extern struct {
    time: Time,
    x: c_short,
    y: c_short,
};
pub const XModifierKeymap = extern struct {
    max_keypermod: c_int,
    modifiermap: ?[*]KeyCode,
};
pub const Display = struct__XDisplay;
pub const struct__XPrivate = @OpaqueType();
pub const struct__XrmHashBucketRec = @OpaqueType();
pub const _XPrivDisplay = ?[*]extern struct {
    ext_data: ?[*]XExtData,
    private1: ?*struct__XPrivate,
    fd: c_int,
    private2: c_int,
    proto_major_version: c_int,
    proto_minor_version: c_int,
    vendor: ?[*]u8,
    private3: XID,
    private4: XID,
    private5: XID,
    private6: c_int,
    resource_alloc: ?extern fn(?*struct__XDisplay) XID,
    byte_order: c_int,
    bitmap_unit: c_int,
    bitmap_pad: c_int,
    bitmap_bit_order: c_int,
    nformats: c_int,
    pixmap_format: ?[*]ScreenFormat,
    private8: c_int,
    release: c_int,
    private9: ?*struct__XPrivate,
    private10: ?*struct__XPrivate,
    qlen: c_int,
    last_request_read: c_ulong,
    request: c_ulong,
    private11: XPointer,
    private12: XPointer,
    private13: XPointer,
    private14: XPointer,
    max_request_size: c_uint,
    db: ?*struct__XrmHashBucketRec,
    private15: ?extern fn(?*struct__XDisplay) c_int,
    display_name: ?[*]u8,
    default_screen: c_int,
    nscreens: c_int,
    screens: ?[*]Screen,
    motion_buffer: c_ulong,
    private16: c_ulong,
    min_keycode: c_int,
    max_keycode: c_int,
    private17: XPointer,
    private18: XPointer,
    private19: c_int,
    xdefaults: ?[*]u8,
};
pub const XKeyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    root: Window,
    subwindow: Window,
    time: Time,
    x: c_int,
    y: c_int,
    x_root: c_int,
    y_root: c_int,
    state: c_uint,
    keycode: c_uint,
    same_screen: c_int,
};
pub const XKeyPressedEvent = XKeyEvent;
pub const XKeyReleasedEvent = XKeyEvent;
pub const XButtonEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    root: Window,
    subwindow: Window,
    time: Time,
    x: c_int,
    y: c_int,
    x_root: c_int,
    y_root: c_int,
    state: c_uint,
    button: c_uint,
    same_screen: c_int,
};
pub const XButtonPressedEvent = XButtonEvent;
pub const XButtonReleasedEvent = XButtonEvent;
pub const XMotionEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    root: Window,
    subwindow: Window,
    time: Time,
    x: c_int,
    y: c_int,
    x_root: c_int,
    y_root: c_int,
    state: c_uint,
    is_hint: u8,
    same_screen: c_int,
};
pub const XPointerMovedEvent = XMotionEvent;
pub const XCrossingEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    root: Window,
    subwindow: Window,
    time: Time,
    x: c_int,
    y: c_int,
    x_root: c_int,
    y_root: c_int,
    mode: c_int,
    detail: c_int,
    same_screen: c_int,
    focus: c_int,
    state: c_uint,
};
pub const XEnterWindowEvent = XCrossingEvent;
pub const XLeaveWindowEvent = XCrossingEvent;
pub const XFocusChangeEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    mode: c_int,
    detail: c_int,
};
pub const XFocusInEvent = XFocusChangeEvent;
pub const XFocusOutEvent = XFocusChangeEvent;
pub const XKeymapEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    key_vector: [32]u8,
};
pub const XExposeEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    count: c_int,
};
pub const XGraphicsExposeEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    drawable: Drawable,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    count: c_int,
    major_code: c_int,
    minor_code: c_int,
};
pub const XNoExposeEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    drawable: Drawable,
    major_code: c_int,
    minor_code: c_int,
};
pub const XVisibilityEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    state: c_int,
};
pub const XCreateWindowEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    parent: Window,
    window: Window,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    override_redirect: c_int,
};
pub const XDestroyWindowEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
};
pub const XUnmapEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    from_configure: c_int,
};
pub const XMapEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    override_redirect: c_int,
};
pub const XMapRequestEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    parent: Window,
    window: Window,
};
pub const XReparentEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    parent: Window,
    x: c_int,
    y: c_int,
    override_redirect: c_int,
};
pub const XConfigureEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    above: Window,
    override_redirect: c_int,
};
pub const XGravityEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    x: c_int,
    y: c_int,
};
pub const XResizeRequestEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    width: c_int,
    height: c_int,
};
pub const XConfigureRequestEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    parent: Window,
    window: Window,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    above: Window,
    detail: c_int,
    value_mask: c_ulong,
};
pub const XCirculateEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    event: Window,
    window: Window,
    place: c_int,
};
pub const XCirculateRequestEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    parent: Window,
    window: Window,
    place: c_int,
};
pub const XPropertyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    atom: Atom,
    time: Time,
    state: c_int,
};
pub const XSelectionClearEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    selection: Atom,
    time: Time,
};
pub const XSelectionRequestEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    owner: Window,
    requestor: Window,
    selection: Atom,
    target: Atom,
    property: Atom,
    time: Time,
};
pub const XSelectionEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    requestor: Window,
    selection: Atom,
    target: Atom,
    property: Atom,
    time: Time,
};
pub const XColormapEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    colormap: Colormap,
    new: c_int,
    state: c_int,
};
pub const XClientMessageEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    message_type: Atom,
    format: c_int,
    data: extern union {
        b: [20]u8,
        s: [10]c_short,
        l: [5]c_long,
    },
};
pub const XMappingEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    request: c_int,
    first_keycode: c_int,
    count: c_int,
};
pub const XErrorEvent = extern struct {
    type: c_int,
    display: ?*Display,
    resourceid: XID,
    serial: c_ulong,
    error_code: u8,
    request_code: u8,
    minor_code: u8,
};
pub const XAnyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
};
pub const XGenericEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    extension: c_int,
    evtype: c_int,
};
pub const XGenericEventCookie = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    extension: c_int,
    evtype: c_int,
    cookie: c_uint,
    data: ?*c_void,
};
pub const union__XEvent = extern union {
    type: c_int,
    xany: XAnyEvent,
    xkey: XKeyEvent,
    xbutton: XButtonEvent,
    xmotion: XMotionEvent,
    xcrossing: XCrossingEvent,
    xfocus: XFocusChangeEvent,
    xexpose: XExposeEvent,
    xgraphicsexpose: XGraphicsExposeEvent,
    xnoexpose: XNoExposeEvent,
    xvisibility: XVisibilityEvent,
    xcreatewindow: XCreateWindowEvent,
    xdestroywindow: XDestroyWindowEvent,
    xunmap: XUnmapEvent,
    xmap: XMapEvent,
    xmaprequest: XMapRequestEvent,
    xreparent: XReparentEvent,
    xconfigure: XConfigureEvent,
    xgravity: XGravityEvent,
    xresizerequest: XResizeRequestEvent,
    xconfigurerequest: XConfigureRequestEvent,
    xcirculate: XCirculateEvent,
    xcirculaterequest: XCirculateRequestEvent,
    xproperty: XPropertyEvent,
    xselectionclear: XSelectionClearEvent,
    xselectionrequest: XSelectionRequestEvent,
    xselection: XSelectionEvent,
    xcolormap: XColormapEvent,
    xclient: XClientMessageEvent,
    xmapping: XMappingEvent,
    xerror: XErrorEvent,
    xkeymap: XKeymapEvent,
    xgeneric: XGenericEvent,
    xcookie: XGenericEventCookie,
    pad: [24]c_long,
};
pub const XEvent = union__XEvent;
pub const XCharStruct = extern struct {
    lbearing: c_short,
    rbearing: c_short,
    width: c_short,
    ascent: c_short,
    descent: c_short,
    attributes: c_ushort,
};
pub const XFontProp = extern struct {
    name: Atom,
    card32: c_ulong,
};
pub const XFontStruct = extern struct {
    ext_data: ?[*]XExtData,
    fid: Font,
    direction: c_uint,
    min_char_or_byte2: c_uint,
    max_char_or_byte2: c_uint,
    min_byte1: c_uint,
    max_byte1: c_uint,
    all_chars_exist: c_int,
    default_char: c_uint,
    n_properties: c_int,
    properties: ?[*]XFontProp,
    min_bounds: XCharStruct,
    max_bounds: XCharStruct,
    per_char: ?[*]XCharStruct,
    ascent: c_int,
    descent: c_int,
};
pub const XTextItem = extern struct {
    chars: ?[*]u8,
    nchars: c_int,
    delta: c_int,
    font: Font,
};
pub const XChar2b = extern struct {
    byte1: u8,
    byte2: u8,
};
pub const XTextItem16 = extern struct {
    chars: ?[*]XChar2b,
    nchars: c_int,
    delta: c_int,
    font: Font,
};
pub const XEDataObject = extern union {
    display: ?*Display,
    gc: GC,
    visual: ?[*]Visual,
    screen: ?[*]Screen,
    pixmap_format: ?[*]ScreenFormat,
    font: ?[*]XFontStruct,
};
pub const XFontSetExtents = extern struct {
    max_ink_extent: XRectangle,
    max_logical_extent: XRectangle,
};
pub const struct__XOM = @OpaqueType();
pub const XOM = ?*struct__XOM;
pub const struct__XOC = @OpaqueType();
pub const XOC = ?*struct__XOC;
pub const XFontSet = ?*struct__XOC;
pub const XmbTextItem = extern struct {
    chars: ?[*]u8,
    nchars: c_int,
    delta: c_int,
    font_set: XFontSet,
};
pub const XwcTextItem = extern struct {
    chars: ?[*]wchar_t,
    nchars: c_int,
    delta: c_int,
    font_set: XFontSet,
};
pub const XOMCharSetList = extern struct {
    charset_count: c_int,
    charset_list: ?[*](?[*]u8),
};
pub const XOMOrientation_LTR_TTB = 0;
pub const XOMOrientation_RTL_TTB = 1;
pub const XOMOrientation_TTB_LTR = 2;
pub const XOMOrientation_TTB_RTL = 3;
pub const XOMOrientation_Context = 4;
pub const XOrientation = extern enum {
    XOMOrientation_LTR_TTB = 0,
    XOMOrientation_RTL_TTB = 1,
    XOMOrientation_TTB_LTR = 2,
    XOMOrientation_TTB_RTL = 3,
    XOMOrientation_Context = 4,
};
pub const XOMOrientation = extern struct {
    num_orientation: c_int,
    orientation: ?[*]XOrientation,
};
pub const XOMFontInfo = extern struct {
    num_font: c_int,
    font_struct_list: ?[*](?[*]XFontStruct),
    font_name_list: ?[*](?[*]u8),
};
pub const struct__XIM = @OpaqueType();
pub const XIM = ?*struct__XIM;
pub const struct__XIC = @OpaqueType();
pub const XIC = ?*struct__XIC;
pub const XIMProc = ?extern fn(XIM, XPointer, XPointer) void;
pub const XICProc = ?extern fn(XIC, XPointer, XPointer) c_int;
pub const XIDProc = ?extern fn(?*Display, XPointer, XPointer) void;
pub const XIMStyle = c_ulong;
pub const XIMStyles = extern struct {
    count_styles: c_ushort,
    supported_styles: ?[*]XIMStyle,
};
pub const XVaNestedList = ?*c_void;
pub const XIMCallback = extern struct {
    client_data: XPointer,
    callback: XIMProc,
};
pub const XICCallback = extern struct {
    client_data: XPointer,
    callback: XICProc,
};
pub const XIMFeedback = c_ulong;
pub const struct__XIMText = extern struct {
    length: c_ushort,
    feedback: ?[*]XIMFeedback,
    encoding_is_wchar: c_int,
    string: extern union {
        multi_byte: ?[*]u8,
        wide_char: ?[*]wchar_t,
    },
};
pub const XIMText = struct__XIMText;
pub const XIMPreeditState = c_ulong;
pub const struct__XIMPreeditStateNotifyCallbackStruct = extern struct {
    state: XIMPreeditState,
};
pub const XIMPreeditStateNotifyCallbackStruct = struct__XIMPreeditStateNotifyCallbackStruct;
pub const XIMResetState = c_ulong;
pub const XIMStringConversionFeedback = c_ulong;
pub const struct__XIMStringConversionText = extern struct {
    length: c_ushort,
    feedback: ?[*]XIMStringConversionFeedback,
    encoding_is_wchar: c_int,
    string: extern union {
        mbs: ?[*]u8,
        wcs: ?[*]wchar_t,
    },
};
pub const XIMStringConversionText = struct__XIMStringConversionText;
pub const XIMStringConversionPosition = c_ushort;
pub const XIMStringConversionType = c_ushort;
pub const XIMStringConversionOperation = c_ushort;
pub const XIMForwardChar = 0;
pub const XIMBackwardChar = 1;
pub const XIMForwardWord = 2;
pub const XIMBackwardWord = 3;
pub const XIMCaretUp = 4;
pub const XIMCaretDown = 5;
pub const XIMNextLine = 6;
pub const XIMPreviousLine = 7;
pub const XIMLineStart = 8;
pub const XIMLineEnd = 9;
pub const XIMAbsolutePosition = 10;
pub const XIMDontChange = 11;
pub const XIMCaretDirection = extern enum {
    XIMForwardChar = 0,
    XIMBackwardChar = 1,
    XIMForwardWord = 2,
    XIMBackwardWord = 3,
    XIMCaretUp = 4,
    XIMCaretDown = 5,
    XIMNextLine = 6,
    XIMPreviousLine = 7,
    XIMLineStart = 8,
    XIMLineEnd = 9,
    XIMAbsolutePosition = 10,
    XIMDontChange = 11,
};
pub const struct__XIMStringConversionCallbackStruct = extern struct {
    position: XIMStringConversionPosition,
    direction: XIMCaretDirection,
    operation: XIMStringConversionOperation,
    factor: c_ushort,
    text: ?[*]XIMStringConversionText,
};
pub const XIMStringConversionCallbackStruct = struct__XIMStringConversionCallbackStruct;
pub const struct__XIMPreeditDrawCallbackStruct = extern struct {
    caret: c_int,
    chg_first: c_int,
    chg_length: c_int,
    text: ?[*]XIMText,
};
pub const XIMPreeditDrawCallbackStruct = struct__XIMPreeditDrawCallbackStruct;
pub const XIMIsInvisible = 0;
pub const XIMIsPrimary = 1;
pub const XIMIsSecondary = 2;
pub const XIMCaretStyle = extern enum {
    XIMIsInvisible = 0,
    XIMIsPrimary = 1,
    XIMIsSecondary = 2,
};
pub const struct__XIMPreeditCaretCallbackStruct = extern struct {
    position: c_int,
    direction: XIMCaretDirection,
    style: XIMCaretStyle,
};
pub const XIMPreeditCaretCallbackStruct = struct__XIMPreeditCaretCallbackStruct;
pub const XIMTextType = 0;
pub const XIMBitmapType = 1;
pub const XIMStatusDataType = extern enum {
    XIMTextType = 0,
    XIMBitmapType = 1,
};
pub const struct__XIMStatusDrawCallbackStruct = extern struct {
    type: XIMStatusDataType,
    data: extern union {
        text: ?[*]XIMText,
        bitmap: Pixmap,
    },
};
pub const XIMStatusDrawCallbackStruct = struct__XIMStatusDrawCallbackStruct;
pub const struct__XIMHotKeyTrigger = extern struct {
    keysym: KeySym,
    modifier: c_int,
    modifier_mask: c_int,
};
pub const XIMHotKeyTrigger = struct__XIMHotKeyTrigger;
pub const struct__XIMHotKeyTriggers = extern struct {
    num_hot_key: c_int,
    key: ?[*]XIMHotKeyTrigger,
};
pub const XIMHotKeyTriggers = struct__XIMHotKeyTriggers;
pub const XIMHotKeyState = c_ulong;
pub const XIMValuesList = extern struct {
    count_values: c_ushort,
    supported_values: ?[*](?[*]u8),
};
pub extern var _Xdebug: c_int;
pub extern fn XLoadQueryFont(arg0: ?*Display, arg1: ?[*]const u8) ?[*]XFontStruct;
pub extern fn XQueryFont(arg0: ?*Display, arg1: XID) ?[*]XFontStruct;
pub extern fn XGetMotionEvents(arg0: ?*Display, arg1: Window, arg2: Time, arg3: Time, arg4: ?[*]c_int) ?[*]XTimeCoord;
pub extern fn XDeleteModifiermapEntry(arg0: ?[*]XModifierKeymap, arg1: KeyCode, arg2: c_int) ?[*]XModifierKeymap;
pub extern fn XGetModifierMapping(arg0: ?*Display) ?[*]XModifierKeymap;
pub extern fn XInsertModifiermapEntry(arg0: ?[*]XModifierKeymap, arg1: KeyCode, arg2: c_int) ?[*]XModifierKeymap;
pub extern fn XNewModifiermap(arg0: c_int) ?[*]XModifierKeymap;
pub extern fn XCreateImage(arg0: ?*Display, arg1: ?[*]Visual, arg2: c_uint, arg3: c_int, arg4: c_int, arg5: ?[*]u8, arg6: c_uint, arg7: c_uint, arg8: c_int, arg9: c_int) ?[*]XImage;
pub extern fn XInitImage(arg0: ?[*]XImage) c_int;
pub extern fn XGetImage(arg0: ?*Display, arg1: Drawable, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint, arg6: c_ulong, arg7: c_int) ?[*]XImage;
pub extern fn XGetSubImage(arg0: ?*Display, arg1: Drawable, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint, arg6: c_ulong, arg7: c_int, arg8: ?[*]XImage, arg9: c_int, arg10: c_int) ?[*]XImage;
pub extern fn XOpenDisplay(arg0: ?[*]const u8) ?*Display;
pub extern fn XrmInitialize() void;
pub extern fn XFetchBytes(arg0: ?*Display, arg1: ?[*]c_int) ?[*]u8;
pub extern fn XFetchBuffer(arg0: ?*Display, arg1: ?[*]c_int, arg2: c_int) ?[*]u8;
pub extern fn XGetAtomName(arg0: ?*Display, arg1: Atom) ?[*]u8;
pub extern fn XGetAtomNames(arg0: ?*Display, arg1: ?[*]Atom, arg2: c_int, arg3: ?[*](?[*]u8)) c_int;
pub extern fn XGetDefault(arg0: ?*Display, arg1: ?[*]const u8, arg2: ?[*]const u8) ?[*]u8;
pub extern fn XDisplayName(arg0: ?[*]const u8) ?[*]u8;
pub extern fn XKeysymToString(arg0: KeySym) ?[*]u8;
pub extern fn XSynchronize(arg0: ?*Display, arg1: c_int) ?extern fn(?*Display) c_int;
pub extern fn XSetAfterFunction(arg0: ?*Display, arg1: ?extern fn(?*Display) c_int) ?extern fn(?*Display) c_int;
pub extern fn XInternAtom(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int) Atom;
pub extern fn XInternAtoms(arg0: ?*Display, arg1: ?[*](?[*]u8), arg2: c_int, arg3: c_int, arg4: ?[*]Atom) c_int;
pub extern fn XCopyColormapAndFree(arg0: ?*Display, arg1: Colormap) Colormap;
pub extern fn XCreateColormap(arg0: ?*Display, arg1: Window, arg2: ?[*]Visual, arg3: c_int) Colormap;
pub extern fn XCreatePixmapCursor(arg0: ?*Display, arg1: Pixmap, arg2: Pixmap, arg3: ?[*]XColor, arg4: ?[*]XColor, arg5: c_uint, arg6: c_uint) Cursor;
pub extern fn XCreateGlyphCursor(arg0: ?*Display, arg1: Font, arg2: Font, arg3: c_uint, arg4: c_uint, arg5: ?[*]const XColor, arg6: ?[*]const XColor) Cursor;
pub extern fn XCreateFontCursor(arg0: ?*Display, arg1: c_uint) Cursor;
pub extern fn XLoadFont(arg0: ?*Display, arg1: ?[*]const u8) Font;
pub extern fn XCreateGC(arg0: ?*Display, arg1: Drawable, arg2: c_ulong, arg3: ?[*]XGCValues) GC;
pub extern fn XGContextFromGC(arg0: GC) GContext;
pub extern fn XFlushGC(arg0: ?*Display, arg1: GC) void;
pub extern fn XCreatePixmap(arg0: ?*Display, arg1: Drawable, arg2: c_uint, arg3: c_uint, arg4: c_uint) Pixmap;
pub extern fn XCreateBitmapFromData(arg0: ?*Display, arg1: Drawable, arg2: ?[*]const u8, arg3: c_uint, arg4: c_uint) Pixmap;
pub extern fn XCreatePixmapFromBitmapData(arg0: ?*Display, arg1: Drawable, arg2: ?[*]u8, arg3: c_uint, arg4: c_uint, arg5: c_ulong, arg6: c_ulong, arg7: c_uint) Pixmap;
pub extern fn XCreateSimpleWindow(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint, arg6: c_uint, arg7: c_ulong, arg8: c_ulong) Window;
pub extern fn XGetSelectionOwner(arg0: ?*Display, arg1: Atom) Window;
pub extern fn XCreateWindow(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint, arg6: c_uint, arg7: c_int, arg8: c_uint, arg9: ?[*]Visual, arg10: c_ulong, arg11: ?[*]XSetWindowAttributes) Window;
pub extern fn XListInstalledColormaps(arg0: ?*Display, arg1: Window, arg2: ?[*]c_int) ?[*]Colormap;
pub extern fn XListFonts(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]c_int) ?[*](?[*]u8);
pub extern fn XListFontsWithInfo(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]c_int, arg4: ?[*](?[*]XFontStruct)) ?[*](?[*]u8);
pub extern fn XGetFontPath(arg0: ?*Display, arg1: ?[*]c_int) ?[*](?[*]u8);
pub extern fn XListExtensions(arg0: ?*Display, arg1: ?[*]c_int) ?[*](?[*]u8);
pub extern fn XListProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]c_int) ?[*]Atom;
pub extern fn XListHosts(arg0: ?*Display, arg1: ?[*]c_int, arg2: ?[*]c_int) ?[*]XHostAddress;
pub extern fn XKeycodeToKeysym(arg0: ?*Display, arg1: KeyCode, arg2: c_int) KeySym;
pub extern fn XLookupKeysym(arg0: ?[*]XKeyEvent, arg1: c_int) KeySym;
pub extern fn XGetKeyboardMapping(arg0: ?*Display, arg1: KeyCode, arg2: c_int, arg3: ?[*]c_int) ?[*]KeySym;
pub extern fn XStringToKeysym(arg0: ?[*]const u8) KeySym;
pub extern fn XMaxRequestSize(arg0: ?*Display) c_long;
pub extern fn XExtendedMaxRequestSize(arg0: ?*Display) c_long;
pub extern fn XResourceManagerString(arg0: ?*Display) ?[*]u8;
pub extern fn XScreenResourceString(arg0: ?[*]Screen) ?[*]u8;
pub extern fn XDisplayMotionBufferSize(arg0: ?*Display) c_ulong;
pub extern fn XVisualIDFromVisual(arg0: ?[*]Visual) VisualID;
pub extern fn XInitThreads() c_int;
pub extern fn XLockDisplay(arg0: ?*Display) void;
pub extern fn XUnlockDisplay(arg0: ?*Display) void;
pub extern fn XInitExtension(arg0: ?*Display, arg1: ?[*]const u8) ?[*]XExtCodes;
pub extern fn XAddExtension(arg0: ?*Display) ?[*]XExtCodes;
pub extern fn XFindOnExtensionList(arg0: ?[*](?[*]XExtData), arg1: c_int) ?[*]XExtData;
pub extern fn XEHeadOfExtensionList(arg0: XEDataObject) ?[*](?[*]XExtData);
pub extern fn XRootWindow(arg0: ?*Display, arg1: c_int) Window;
pub extern fn XDefaultRootWindow(arg0: ?*Display) Window;
pub extern fn XRootWindowOfScreen(arg0: ?[*]Screen) Window;
pub extern fn XDefaultVisual(arg0: ?*Display, arg1: c_int) ?[*]Visual;
pub extern fn XDefaultVisualOfScreen(arg0: ?[*]Screen) ?[*]Visual;
pub extern fn XDefaultGC(arg0: ?*Display, arg1: c_int) GC;
pub extern fn XDefaultGCOfScreen(arg0: ?[*]Screen) GC;
pub extern fn XBlackPixel(arg0: ?*Display, arg1: c_int) c_ulong;
pub extern fn XWhitePixel(arg0: ?*Display, arg1: c_int) c_ulong;
pub extern fn XAllPlanes() c_ulong;
pub extern fn XBlackPixelOfScreen(arg0: ?[*]Screen) c_ulong;
pub extern fn XWhitePixelOfScreen(arg0: ?[*]Screen) c_ulong;
pub extern fn XNextRequest(arg0: ?*Display) c_ulong;
pub extern fn XLastKnownRequestProcessed(arg0: ?*Display) c_ulong;
pub extern fn XServerVendor(arg0: ?*Display) ?[*]u8;
pub extern fn XDisplayString(arg0: ?*Display) ?[*]u8;
pub extern fn XDefaultColormap(arg0: ?*Display, arg1: c_int) Colormap;
pub extern fn XDefaultColormapOfScreen(arg0: ?[*]Screen) Colormap;
pub extern fn XDisplayOfScreen(arg0: ?[*]Screen) ?*Display;
pub extern fn XScreenOfDisplay(arg0: ?*Display, arg1: c_int) ?[*]Screen;
pub extern fn XDefaultScreenOfDisplay(arg0: ?*Display) ?[*]Screen;
pub extern fn XEventMaskOfScreen(arg0: ?[*]Screen) c_long;
pub extern fn XScreenNumberOfScreen(arg0: ?[*]Screen) c_int;
pub const XErrorHandler = ?extern fn(?*Display, ?[*]XErrorEvent) c_int;
pub extern fn XSetErrorHandler(arg0: XErrorHandler) XErrorHandler;
pub const XIOErrorHandler = ?extern fn(?*Display) c_int;
pub extern fn XSetIOErrorHandler(arg0: XIOErrorHandler) XIOErrorHandler;
pub extern fn XListPixmapFormats(arg0: ?*Display, arg1: ?[*]c_int) ?[*]XPixmapFormatValues;
pub extern fn XListDepths(arg0: ?*Display, arg1: c_int, arg2: ?[*]c_int) ?[*]c_int;
pub extern fn XReconfigureWMWindow(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_uint, arg4: ?[*]XWindowChanges) c_int;
pub extern fn XGetWMProtocols(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]Atom), arg3: ?[*]c_int) c_int;
pub extern fn XSetWMProtocols(arg0: ?*Display, arg1: Window, arg2: ?[*]Atom, arg3: c_int) c_int;
pub extern fn XIconifyWindow(arg0: ?*Display, arg1: Window, arg2: c_int) c_int;
pub extern fn XWithdrawWindow(arg0: ?*Display, arg1: Window, arg2: c_int) c_int;
pub extern fn XGetCommand(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*](?[*]u8)), arg3: ?[*]c_int) c_int;
pub extern fn XGetWMColormapWindows(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]Window), arg3: ?[*]c_int) c_int;
pub extern fn XSetWMColormapWindows(arg0: ?*Display, arg1: Window, arg2: ?[*]Window, arg3: c_int) c_int;
pub extern fn XFreeStringList(arg0: ?[*](?[*]u8)) void;
pub extern fn XSetTransientForHint(arg0: ?*Display, arg1: Window, arg2: Window) c_int;
pub extern fn XActivateScreenSaver(arg0: ?*Display) c_int;
pub extern fn XAddHost(arg0: ?*Display, arg1: ?[*]XHostAddress) c_int;
pub extern fn XAddHosts(arg0: ?*Display, arg1: ?[*]XHostAddress, arg2: c_int) c_int;
pub extern fn XAddToExtensionList(arg0: ?[*](?[*]struct__XExtData), arg1: ?[*]XExtData) c_int;
pub extern fn XAddToSaveSet(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XAllocColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]XColor) c_int;
pub extern fn XAllocColorCells(arg0: ?*Display, arg1: Colormap, arg2: c_int, arg3: ?[*]c_ulong, arg4: c_uint, arg5: ?[*]c_ulong, arg6: c_uint) c_int;
pub extern fn XAllocColorPlanes(arg0: ?*Display, arg1: Colormap, arg2: c_int, arg3: ?[*]c_ulong, arg4: c_int, arg5: c_int, arg6: c_int, arg7: c_int, arg8: ?[*]c_ulong, arg9: ?[*]c_ulong, arg10: ?[*]c_ulong) c_int;
pub extern fn XAllocNamedColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]const u8, arg3: ?[*]XColor, arg4: ?[*]XColor) c_int;
pub extern fn XAllowEvents(arg0: ?*Display, arg1: c_int, arg2: Time) c_int;
pub extern fn XAutoRepeatOff(arg0: ?*Display) c_int;
pub extern fn XAutoRepeatOn(arg0: ?*Display) c_int;
pub extern fn XBell(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XBitmapBitOrder(arg0: ?*Display) c_int;
pub extern fn XBitmapPad(arg0: ?*Display) c_int;
pub extern fn XBitmapUnit(arg0: ?*Display) c_int;
pub extern fn XCellsOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XChangeActivePointerGrab(arg0: ?*Display, arg1: c_uint, arg2: Cursor, arg3: Time) c_int;
pub extern fn XChangeGC(arg0: ?*Display, arg1: GC, arg2: c_ulong, arg3: ?[*]XGCValues) c_int;
pub extern fn XChangeKeyboardControl(arg0: ?*Display, arg1: c_ulong, arg2: ?[*]XKeyboardControl) c_int;
pub extern fn XChangeKeyboardMapping(arg0: ?*Display, arg1: c_int, arg2: c_int, arg3: ?[*]KeySym, arg4: c_int) c_int;
pub extern fn XChangePointerControl(arg0: ?*Display, arg1: c_int, arg2: c_int, arg3: c_int, arg4: c_int, arg5: c_int) c_int;
pub extern fn XChangeProperty(arg0: ?*Display, arg1: Window, arg2: Atom, arg3: Atom, arg4: c_int, arg5: c_int, arg6: ?[*]const u8, arg7: c_int) c_int;
pub extern fn XChangeSaveSet(arg0: ?*Display, arg1: Window, arg2: c_int) c_int;
pub extern fn XChangeWindowAttributes(arg0: ?*Display, arg1: Window, arg2: c_ulong, arg3: ?[*]XSetWindowAttributes) c_int;
pub extern fn XCheckIfEvent(arg0: ?*Display, arg1: ?[*]XEvent, arg2: ?extern fn(?*Display, ?[*]XEvent, XPointer) c_int, arg3: XPointer) c_int;
pub extern fn XCheckMaskEvent(arg0: ?*Display, arg1: c_long, arg2: ?[*]XEvent) c_int;
pub extern fn XCheckTypedEvent(arg0: ?*Display, arg1: c_int, arg2: ?[*]XEvent) c_int;
pub extern fn XCheckTypedWindowEvent(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: ?[*]XEvent) c_int;
pub extern fn XCheckWindowEvent(arg0: ?*Display, arg1: Window, arg2: c_long, arg3: ?[*]XEvent) c_int;
pub extern fn XCirculateSubwindows(arg0: ?*Display, arg1: Window, arg2: c_int) c_int;
pub extern fn XCirculateSubwindowsDown(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XCirculateSubwindowsUp(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XClearArea(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint, arg6: c_int) c_int;
pub extern fn XClearWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XCloseDisplay(arg0: ?*Display) c_int;
pub extern fn XConfigureWindow(arg0: ?*Display, arg1: Window, arg2: c_uint, arg3: ?[*]XWindowChanges) c_int;
pub extern fn XConnectionNumber(arg0: ?*Display) c_int;
pub extern fn XConvertSelection(arg0: ?*Display, arg1: Atom, arg2: Atom, arg3: Atom, arg4: Window, arg5: Time) c_int;
pub extern fn XCopyArea(arg0: ?*Display, arg1: Drawable, arg2: Drawable, arg3: GC, arg4: c_int, arg5: c_int, arg6: c_uint, arg7: c_uint, arg8: c_int, arg9: c_int) c_int;
pub extern fn XCopyGC(arg0: ?*Display, arg1: GC, arg2: c_ulong, arg3: GC) c_int;
pub extern fn XCopyPlane(arg0: ?*Display, arg1: Drawable, arg2: Drawable, arg3: GC, arg4: c_int, arg5: c_int, arg6: c_uint, arg7: c_uint, arg8: c_int, arg9: c_int, arg10: c_ulong) c_int;
pub extern fn XDefaultDepth(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDefaultDepthOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XDefaultScreen(arg0: ?*Display) c_int;
pub extern fn XDefineCursor(arg0: ?*Display, arg1: Window, arg2: Cursor) c_int;
pub extern fn XDeleteProperty(arg0: ?*Display, arg1: Window, arg2: Atom) c_int;
pub extern fn XDestroyWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XDestroySubwindows(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XDoesBackingStore(arg0: ?[*]Screen) c_int;
pub extern fn XDoesSaveUnders(arg0: ?[*]Screen) c_int;
pub extern fn XDisableAccessControl(arg0: ?*Display) c_int;
pub extern fn XDisplayCells(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDisplayHeight(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDisplayHeightMM(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDisplayKeycodes(arg0: ?*Display, arg1: ?[*]c_int, arg2: ?[*]c_int) c_int;
pub extern fn XDisplayPlanes(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDisplayWidth(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDisplayWidthMM(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XDrawArc(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: c_uint, arg6: c_uint, arg7: c_int, arg8: c_int) c_int;
pub extern fn XDrawArcs(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XArc, arg4: c_int) c_int;
pub extern fn XDrawImageString(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]const u8, arg6: c_int) c_int;
pub extern fn XDrawImageString16(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]const XChar2b, arg6: c_int) c_int;
pub extern fn XDrawLine(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: c_int, arg6: c_int) c_int;
pub extern fn XDrawLines(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XPoint, arg4: c_int, arg5: c_int) c_int;
pub extern fn XDrawPoint(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int) c_int;
pub extern fn XDrawPoints(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XPoint, arg4: c_int, arg5: c_int) c_int;
pub extern fn XDrawRectangle(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: c_uint, arg6: c_uint) c_int;
pub extern fn XDrawRectangles(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XRectangle, arg4: c_int) c_int;
pub extern fn XDrawSegments(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XSegment, arg4: c_int) c_int;
pub extern fn XDrawString(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]const u8, arg6: c_int) c_int;
pub extern fn XDrawString16(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]const XChar2b, arg6: c_int) c_int;
pub extern fn XDrawText(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]XTextItem, arg6: c_int) c_int;
pub extern fn XDrawText16(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]XTextItem16, arg6: c_int) c_int;
pub extern fn XEnableAccessControl(arg0: ?*Display) c_int;
pub extern fn XEventsQueued(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XFetchName(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]u8)) c_int;
pub extern fn XFillArc(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: c_uint, arg6: c_uint, arg7: c_int, arg8: c_int) c_int;
pub extern fn XFillArcs(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XArc, arg4: c_int) c_int;
pub extern fn XFillPolygon(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XPoint, arg4: c_int, arg5: c_int, arg6: c_int) c_int;
pub extern fn XFillRectangle(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: c_uint, arg6: c_uint) c_int;
pub extern fn XFillRectangles(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XRectangle, arg4: c_int) c_int;
pub extern fn XFlush(arg0: ?*Display) c_int;
pub extern fn XForceScreenSaver(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XFree(arg0: ?*c_void) c_int;
pub extern fn XFreeColormap(arg0: ?*Display, arg1: Colormap) c_int;
pub extern fn XFreeColors(arg0: ?*Display, arg1: Colormap, arg2: ?[*]c_ulong, arg3: c_int, arg4: c_ulong) c_int;
pub extern fn XFreeCursor(arg0: ?*Display, arg1: Cursor) c_int;
pub extern fn XFreeExtensionList(arg0: ?[*](?[*]u8)) c_int;
pub extern fn XFreeFont(arg0: ?*Display, arg1: ?[*]XFontStruct) c_int;
pub extern fn XFreeFontInfo(arg0: ?[*](?[*]u8), arg1: ?[*]XFontStruct, arg2: c_int) c_int;
pub extern fn XFreeFontNames(arg0: ?[*](?[*]u8)) c_int;
pub extern fn XFreeFontPath(arg0: ?[*](?[*]u8)) c_int;
pub extern fn XFreeGC(arg0: ?*Display, arg1: GC) c_int;
pub extern fn XFreeModifiermap(arg0: ?[*]XModifierKeymap) c_int;
pub extern fn XFreePixmap(arg0: ?*Display, arg1: Pixmap) c_int;
pub extern fn XGeometry(arg0: ?*Display, arg1: c_int, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: c_uint, arg5: c_uint, arg6: c_uint, arg7: c_int, arg8: c_int, arg9: ?[*]c_int, arg10: ?[*]c_int, arg11: ?[*]c_int, arg12: ?[*]c_int) c_int;
pub extern fn XGetErrorDatabaseText(arg0: ?*Display, arg1: ?[*]const u8, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: ?[*]u8, arg5: c_int) c_int;
pub extern fn XGetErrorText(arg0: ?*Display, arg1: c_int, arg2: ?[*]u8, arg3: c_int) c_int;
pub extern fn XGetFontProperty(arg0: ?[*]XFontStruct, arg1: Atom, arg2: ?[*]c_ulong) c_int;
pub extern fn XGetGCValues(arg0: ?*Display, arg1: GC, arg2: c_ulong, arg3: ?[*]XGCValues) c_int;
pub extern fn XGetGeometry(arg0: ?*Display, arg1: Drawable, arg2: ?[*]Window, arg3: ?[*]c_int, arg4: ?[*]c_int, arg5: ?[*]c_uint, arg6: ?[*]c_uint, arg7: ?[*]c_uint, arg8: ?[*]c_uint) c_int;
pub extern fn XGetIconName(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]u8)) c_int;
pub extern fn XGetInputFocus(arg0: ?*Display, arg1: ?[*]Window, arg2: ?[*]c_int) c_int;
pub extern fn XGetKeyboardControl(arg0: ?*Display, arg1: ?[*]XKeyboardState) c_int;
pub extern fn XGetPointerControl(arg0: ?*Display, arg1: ?[*]c_int, arg2: ?[*]c_int, arg3: ?[*]c_int) c_int;
pub extern fn XGetPointerMapping(arg0: ?*Display, arg1: ?[*]u8, arg2: c_int) c_int;
pub extern fn XGetScreenSaver(arg0: ?*Display, arg1: ?[*]c_int, arg2: ?[*]c_int, arg3: ?[*]c_int, arg4: ?[*]c_int) c_int;
pub extern fn XGetTransientForHint(arg0: ?*Display, arg1: Window, arg2: ?[*]Window) c_int;
pub extern fn XGetWindowProperty(arg0: ?*Display, arg1: Window, arg2: Atom, arg3: c_long, arg4: c_long, arg5: c_int, arg6: Atom, arg7: ?[*]Atom, arg8: ?[*]c_int, arg9: ?[*]c_ulong, arg10: ?[*]c_ulong, arg11: ?[*](?[*]u8)) c_int;
pub extern fn XGetWindowAttributes(arg0: ?*Display, arg1: Window, arg2: ?[*]XWindowAttributes) c_int;
pub extern fn XGrabButton(arg0: ?*Display, arg1: c_uint, arg2: c_uint, arg3: Window, arg4: c_int, arg5: c_uint, arg6: c_int, arg7: c_int, arg8: Window, arg9: Cursor) c_int;
pub extern fn XGrabKey(arg0: ?*Display, arg1: c_int, arg2: c_uint, arg3: Window, arg4: c_int, arg5: c_int, arg6: c_int) c_int;
pub extern fn XGrabKeyboard(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int, arg4: c_int, arg5: Time) c_int;
pub extern fn XGrabPointer(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_uint, arg4: c_int, arg5: c_int, arg6: Window, arg7: Cursor, arg8: Time) c_int;
pub extern fn XGrabServer(arg0: ?*Display) c_int;
pub extern fn XHeightMMOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XHeightOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XIfEvent(arg0: ?*Display, arg1: ?[*]XEvent, arg2: ?extern fn(?*Display, ?[*]XEvent, XPointer) c_int, arg3: XPointer) c_int;
pub extern fn XImageByteOrder(arg0: ?*Display) c_int;
pub extern fn XInstallColormap(arg0: ?*Display, arg1: Colormap) c_int;
pub extern fn XKeysymToKeycode(arg0: ?*Display, arg1: KeySym) KeyCode;
pub extern fn XKillClient(arg0: ?*Display, arg1: XID) c_int;
pub extern fn XLookupColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]const u8, arg3: ?[*]XColor, arg4: ?[*]XColor) c_int;
pub extern fn XLowerWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XMapRaised(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XMapSubwindows(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XMapWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XMaskEvent(arg0: ?*Display, arg1: c_long, arg2: ?[*]XEvent) c_int;
pub extern fn XMaxCmapsOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XMinCmapsOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XMoveResizeWindow(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int, arg4: c_uint, arg5: c_uint) c_int;
pub extern fn XMoveWindow(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_int) c_int;
pub extern fn XNextEvent(arg0: ?*Display, arg1: ?[*]XEvent) c_int;
pub extern fn XNoOp(arg0: ?*Display) c_int;
pub extern fn XParseColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]const u8, arg3: ?[*]XColor) c_int;
pub extern fn XParseGeometry(arg0: ?[*]const u8, arg1: ?[*]c_int, arg2: ?[*]c_int, arg3: ?[*]c_uint, arg4: ?[*]c_uint) c_int;
pub extern fn XPeekEvent(arg0: ?*Display, arg1: ?[*]XEvent) c_int;
pub extern fn XPeekIfEvent(arg0: ?*Display, arg1: ?[*]XEvent, arg2: ?extern fn(?*Display, ?[*]XEvent, XPointer) c_int, arg3: XPointer) c_int;
pub extern fn XPending(arg0: ?*Display) c_int;
pub extern fn XPlanesOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XProtocolRevision(arg0: ?*Display) c_int;
pub extern fn XProtocolVersion(arg0: ?*Display) c_int;
pub extern fn XPutBackEvent(arg0: ?*Display, arg1: ?[*]XEvent) c_int;
pub extern fn XPutImage(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: ?[*]XImage, arg4: c_int, arg5: c_int, arg6: c_int, arg7: c_int, arg8: c_uint, arg9: c_uint) c_int;
pub extern fn XQLength(arg0: ?*Display) c_int;
pub extern fn XQueryBestCursor(arg0: ?*Display, arg1: Drawable, arg2: c_uint, arg3: c_uint, arg4: ?[*]c_uint, arg5: ?[*]c_uint) c_int;
pub extern fn XQueryBestSize(arg0: ?*Display, arg1: c_int, arg2: Drawable, arg3: c_uint, arg4: c_uint, arg5: ?[*]c_uint, arg6: ?[*]c_uint) c_int;
pub extern fn XQueryBestStipple(arg0: ?*Display, arg1: Drawable, arg2: c_uint, arg3: c_uint, arg4: ?[*]c_uint, arg5: ?[*]c_uint) c_int;
pub extern fn XQueryBestTile(arg0: ?*Display, arg1: Drawable, arg2: c_uint, arg3: c_uint, arg4: ?[*]c_uint, arg5: ?[*]c_uint) c_int;
pub extern fn XQueryColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]XColor) c_int;
pub extern fn XQueryColors(arg0: ?*Display, arg1: Colormap, arg2: ?[*]XColor, arg3: c_int) c_int;
pub extern fn XQueryExtension(arg0: ?*Display, arg1: ?[*]const u8, arg2: ?[*]c_int, arg3: ?[*]c_int, arg4: ?[*]c_int) c_int;
pub extern fn XQueryKeymap(arg0: ?*Display, arg1: ?[*]u8) c_int;
pub extern fn XQueryPointer(arg0: ?*Display, arg1: Window, arg2: ?[*]Window, arg3: ?[*]Window, arg4: ?[*]c_int, arg5: ?[*]c_int, arg6: ?[*]c_int, arg7: ?[*]c_int, arg8: ?[*]c_uint) c_int;
pub extern fn XQueryTextExtents(arg0: ?*Display, arg1: XID, arg2: ?[*]const u8, arg3: c_int, arg4: ?[*]c_int, arg5: ?[*]c_int, arg6: ?[*]c_int, arg7: ?[*]XCharStruct) c_int;
pub extern fn XQueryTextExtents16(arg0: ?*Display, arg1: XID, arg2: ?[*]const XChar2b, arg3: c_int, arg4: ?[*]c_int, arg5: ?[*]c_int, arg6: ?[*]c_int, arg7: ?[*]XCharStruct) c_int;
pub extern fn XQueryTree(arg0: ?*Display, arg1: Window, arg2: ?[*]Window, arg3: ?[*]Window, arg4: ?[*](?[*]Window), arg5: ?[*]c_uint) c_int;
pub extern fn XRaiseWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XReadBitmapFile(arg0: ?*Display, arg1: Drawable, arg2: ?[*]const u8, arg3: ?[*]c_uint, arg4: ?[*]c_uint, arg5: ?[*]Pixmap, arg6: ?[*]c_int, arg7: ?[*]c_int) c_int;
pub extern fn XReadBitmapFileData(arg0: ?[*]const u8, arg1: ?[*]c_uint, arg2: ?[*]c_uint, arg3: ?[*](?[*]u8), arg4: ?[*]c_int, arg5: ?[*]c_int) c_int;
pub extern fn XRebindKeysym(arg0: ?*Display, arg1: KeySym, arg2: ?[*]KeySym, arg3: c_int, arg4: ?[*]const u8, arg5: c_int) c_int;
pub extern fn XRecolorCursor(arg0: ?*Display, arg1: Cursor, arg2: ?[*]XColor, arg3: ?[*]XColor) c_int;
pub extern fn XRefreshKeyboardMapping(arg0: ?[*]XMappingEvent) c_int;
pub extern fn XRemoveFromSaveSet(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XRemoveHost(arg0: ?*Display, arg1: ?[*]XHostAddress) c_int;
pub extern fn XRemoveHosts(arg0: ?*Display, arg1: ?[*]XHostAddress, arg2: c_int) c_int;
pub extern fn XReparentWindow(arg0: ?*Display, arg1: Window, arg2: Window, arg3: c_int, arg4: c_int) c_int;
pub extern fn XResetScreenSaver(arg0: ?*Display) c_int;
pub extern fn XResizeWindow(arg0: ?*Display, arg1: Window, arg2: c_uint, arg3: c_uint) c_int;
pub extern fn XRestackWindows(arg0: ?*Display, arg1: ?[*]Window, arg2: c_int) c_int;
pub extern fn XRotateBuffers(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XRotateWindowProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]Atom, arg3: c_int, arg4: c_int) c_int;
pub extern fn XScreenCount(arg0: ?*Display) c_int;
pub extern fn XSelectInput(arg0: ?*Display, arg1: Window, arg2: c_long) c_int;
pub extern fn XSendEvent(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: c_long, arg4: ?[*]XEvent) c_int;
pub extern fn XSetAccessControl(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XSetArcMode(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetBackground(arg0: ?*Display, arg1: GC, arg2: c_ulong) c_int;
pub extern fn XSetClipMask(arg0: ?*Display, arg1: GC, arg2: Pixmap) c_int;
pub extern fn XSetClipOrigin(arg0: ?*Display, arg1: GC, arg2: c_int, arg3: c_int) c_int;
pub extern fn XSetClipRectangles(arg0: ?*Display, arg1: GC, arg2: c_int, arg3: c_int, arg4: ?[*]XRectangle, arg5: c_int, arg6: c_int) c_int;
pub extern fn XSetCloseDownMode(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XSetCommand(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]u8), arg3: c_int) c_int;
pub extern fn XSetDashes(arg0: ?*Display, arg1: GC, arg2: c_int, arg3: ?[*]const u8, arg4: c_int) c_int;
pub extern fn XSetFillRule(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetFillStyle(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetFont(arg0: ?*Display, arg1: GC, arg2: Font) c_int;
pub extern fn XSetFontPath(arg0: ?*Display, arg1: ?[*](?[*]u8), arg2: c_int) c_int;
pub extern fn XSetForeground(arg0: ?*Display, arg1: GC, arg2: c_ulong) c_int;
pub extern fn XSetFunction(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetGraphicsExposures(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetIconName(arg0: ?*Display, arg1: Window, arg2: ?[*]const u8) c_int;
pub extern fn XSetInputFocus(arg0: ?*Display, arg1: Window, arg2: c_int, arg3: Time) c_int;
pub extern fn XSetLineAttributes(arg0: ?*Display, arg1: GC, arg2: c_uint, arg3: c_int, arg4: c_int, arg5: c_int) c_int;
pub extern fn XSetModifierMapping(arg0: ?*Display, arg1: ?[*]XModifierKeymap) c_int;
pub extern fn XSetPlaneMask(arg0: ?*Display, arg1: GC, arg2: c_ulong) c_int;
pub extern fn XSetPointerMapping(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int) c_int;
pub extern fn XSetScreenSaver(arg0: ?*Display, arg1: c_int, arg2: c_int, arg3: c_int, arg4: c_int) c_int;
pub extern fn XSetSelectionOwner(arg0: ?*Display, arg1: Atom, arg2: Window, arg3: Time) c_int;
pub extern fn XSetState(arg0: ?*Display, arg1: GC, arg2: c_ulong, arg3: c_ulong, arg4: c_int, arg5: c_ulong) c_int;
pub extern fn XSetStipple(arg0: ?*Display, arg1: GC, arg2: Pixmap) c_int;
pub extern fn XSetSubwindowMode(arg0: ?*Display, arg1: GC, arg2: c_int) c_int;
pub extern fn XSetTSOrigin(arg0: ?*Display, arg1: GC, arg2: c_int, arg3: c_int) c_int;
pub extern fn XSetTile(arg0: ?*Display, arg1: GC, arg2: Pixmap) c_int;
pub extern fn XSetWindowBackground(arg0: ?*Display, arg1: Window, arg2: c_ulong) c_int;
pub extern fn XSetWindowBackgroundPixmap(arg0: ?*Display, arg1: Window, arg2: Pixmap) c_int;
pub extern fn XSetWindowBorder(arg0: ?*Display, arg1: Window, arg2: c_ulong) c_int;
pub extern fn XSetWindowBorderPixmap(arg0: ?*Display, arg1: Window, arg2: Pixmap) c_int;
pub extern fn XSetWindowBorderWidth(arg0: ?*Display, arg1: Window, arg2: c_uint) c_int;
pub extern fn XSetWindowColormap(arg0: ?*Display, arg1: Window, arg2: Colormap) c_int;
pub extern fn XStoreBuffer(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int, arg3: c_int) c_int;
pub extern fn XStoreBytes(arg0: ?*Display, arg1: ?[*]const u8, arg2: c_int) c_int;
pub extern fn XStoreColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]XColor) c_int;
pub extern fn XStoreColors(arg0: ?*Display, arg1: Colormap, arg2: ?[*]XColor, arg3: c_int) c_int;
pub extern fn XStoreName(arg0: ?*Display, arg1: Window, arg2: ?[*]const u8) c_int;
pub extern fn XStoreNamedColor(arg0: ?*Display, arg1: Colormap, arg2: ?[*]const u8, arg3: c_ulong, arg4: c_int) c_int;
pub extern fn XSync(arg0: ?*Display, arg1: c_int) c_int;
pub extern fn XTextExtents(arg0: ?[*]XFontStruct, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]c_int, arg4: ?[*]c_int, arg5: ?[*]c_int, arg6: ?[*]XCharStruct) c_int;
pub extern fn XTextExtents16(arg0: ?[*]XFontStruct, arg1: ?[*]const XChar2b, arg2: c_int, arg3: ?[*]c_int, arg4: ?[*]c_int, arg5: ?[*]c_int, arg6: ?[*]XCharStruct) c_int;
pub extern fn XTextWidth(arg0: ?[*]XFontStruct, arg1: ?[*]const u8, arg2: c_int) c_int;
pub extern fn XTextWidth16(arg0: ?[*]XFontStruct, arg1: ?[*]const XChar2b, arg2: c_int) c_int;
pub extern fn XTranslateCoordinates(arg0: ?*Display, arg1: Window, arg2: Window, arg3: c_int, arg4: c_int, arg5: ?[*]c_int, arg6: ?[*]c_int, arg7: ?[*]Window) c_int;
pub extern fn XUndefineCursor(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XUngrabButton(arg0: ?*Display, arg1: c_uint, arg2: c_uint, arg3: Window) c_int;
pub extern fn XUngrabKey(arg0: ?*Display, arg1: c_int, arg2: c_uint, arg3: Window) c_int;
pub extern fn XUngrabKeyboard(arg0: ?*Display, arg1: Time) c_int;
pub extern fn XUngrabPointer(arg0: ?*Display, arg1: Time) c_int;
pub extern fn XUngrabServer(arg0: ?*Display) c_int;
pub extern fn XUninstallColormap(arg0: ?*Display, arg1: Colormap) c_int;
pub extern fn XUnloadFont(arg0: ?*Display, arg1: Font) c_int;
pub extern fn XUnmapSubwindows(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XUnmapWindow(arg0: ?*Display, arg1: Window) c_int;
pub extern fn XVendorRelease(arg0: ?*Display) c_int;
pub extern fn XWarpPointer(arg0: ?*Display, arg1: Window, arg2: Window, arg3: c_int, arg4: c_int, arg5: c_uint, arg6: c_uint, arg7: c_int, arg8: c_int) c_int;
pub extern fn XWidthMMOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XWidthOfScreen(arg0: ?[*]Screen) c_int;
pub extern fn XWindowEvent(arg0: ?*Display, arg1: Window, arg2: c_long, arg3: ?[*]XEvent) c_int;
pub extern fn XWriteBitmapFile(arg0: ?*Display, arg1: ?[*]const u8, arg2: Pixmap, arg3: c_uint, arg4: c_uint, arg5: c_int, arg6: c_int) c_int;
pub extern fn XSupportsLocale() c_int;
pub extern fn XSetLocaleModifiers(arg0: ?[*]const u8) ?[*]u8;
pub extern fn XOpenOM(arg0: ?*Display, arg1: ?*struct__XrmHashBucketRec, arg2: ?[*]const u8, arg3: ?[*]const u8) XOM;
pub extern fn XCloseOM(arg0: XOM) c_int;
pub extern fn XSetOMValues(arg0: XOM) ?[*]u8;
pub extern fn XGetOMValues(arg0: XOM) ?[*]u8;
pub extern fn XDisplayOfOM(arg0: XOM) ?*Display;
pub extern fn XLocaleOfOM(arg0: XOM) ?[*]u8;
pub extern fn XCreateOC(arg0: XOM) XOC;
pub extern fn XDestroyOC(arg0: XOC) void;
pub extern fn XOMOfOC(arg0: XOC) XOM;
pub extern fn XSetOCValues(arg0: XOC) ?[*]u8;
pub extern fn XGetOCValues(arg0: XOC) ?[*]u8;
pub extern fn XCreateFontSet(arg0: ?*Display, arg1: ?[*]const u8, arg2: ?[*](?[*](?[*]u8)), arg3: ?[*]c_int, arg4: ?[*](?[*]u8)) XFontSet;
pub extern fn XFreeFontSet(arg0: ?*Display, arg1: XFontSet) void;
pub extern fn XFontsOfFontSet(arg0: XFontSet, arg1: ?[*](?[*](?[*]XFontStruct)), arg2: ?[*](?[*](?[*]u8))) c_int;
pub extern fn XBaseFontNameListOfFontSet(arg0: XFontSet) ?[*]u8;
pub extern fn XLocaleOfFontSet(arg0: XFontSet) ?[*]u8;
pub extern fn XContextDependentDrawing(arg0: XFontSet) c_int;
pub extern fn XDirectionalDependentDrawing(arg0: XFontSet) c_int;
pub extern fn XContextualDrawing(arg0: XFontSet) c_int;
pub extern fn XExtentsOfFontSet(arg0: XFontSet) ?[*]XFontSetExtents;
pub extern fn XmbTextEscapement(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int) c_int;
pub extern fn XwcTextEscapement(arg0: XFontSet, arg1: ?[*]const wchar_t, arg2: c_int) c_int;
pub extern fn Xutf8TextEscapement(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int) c_int;
pub extern fn XmbTextExtents(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle) c_int;
pub extern fn XwcTextExtents(arg0: XFontSet, arg1: ?[*]const wchar_t, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle) c_int;
pub extern fn Xutf8TextExtents(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle) c_int;
pub extern fn XmbTextPerCharExtents(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle, arg5: c_int, arg6: ?[*]c_int, arg7: ?[*]XRectangle, arg8: ?[*]XRectangle) c_int;
pub extern fn XwcTextPerCharExtents(arg0: XFontSet, arg1: ?[*]const wchar_t, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle, arg5: c_int, arg6: ?[*]c_int, arg7: ?[*]XRectangle, arg8: ?[*]XRectangle) c_int;
pub extern fn Xutf8TextPerCharExtents(arg0: XFontSet, arg1: ?[*]const u8, arg2: c_int, arg3: ?[*]XRectangle, arg4: ?[*]XRectangle, arg5: c_int, arg6: ?[*]c_int, arg7: ?[*]XRectangle, arg8: ?[*]XRectangle) c_int;
pub extern fn XmbDrawText(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]XmbTextItem, arg6: c_int) void;
pub extern fn XwcDrawText(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]XwcTextItem, arg6: c_int) void;
pub extern fn Xutf8DrawText(arg0: ?*Display, arg1: Drawable, arg2: GC, arg3: c_int, arg4: c_int, arg5: ?[*]XmbTextItem, arg6: c_int) void;
pub extern fn XmbDrawString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const u8, arg7: c_int) void;
pub extern fn XwcDrawString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const wchar_t, arg7: c_int) void;
pub extern fn Xutf8DrawString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const u8, arg7: c_int) void;
pub extern fn XmbDrawImageString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const u8, arg7: c_int) void;
pub extern fn XwcDrawImageString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const wchar_t, arg7: c_int) void;
pub extern fn Xutf8DrawImageString(arg0: ?*Display, arg1: Drawable, arg2: XFontSet, arg3: GC, arg4: c_int, arg5: c_int, arg6: ?[*]const u8, arg7: c_int) void;
pub extern fn XOpenIM(arg0: ?*Display, arg1: ?*struct__XrmHashBucketRec, arg2: ?[*]u8, arg3: ?[*]u8) XIM;
pub extern fn XCloseIM(arg0: XIM) c_int;
pub extern fn XGetIMValues(arg0: XIM) ?[*]u8;
pub extern fn XSetIMValues(arg0: XIM) ?[*]u8;
pub extern fn XDisplayOfIM(arg0: XIM) ?*Display;
pub extern fn XLocaleOfIM(arg0: XIM) ?[*]u8;
pub extern fn XCreateIC(arg0: XIM) XIC;
pub extern fn XDestroyIC(arg0: XIC) void;
pub extern fn XSetICFocus(arg0: XIC) void;
pub extern fn XUnsetICFocus(arg0: XIC) void;
pub extern fn XwcResetIC(arg0: XIC) ?[*]wchar_t;
pub extern fn XmbResetIC(arg0: XIC) ?[*]u8;
pub extern fn Xutf8ResetIC(arg0: XIC) ?[*]u8;
pub extern fn XSetICValues(arg0: XIC) ?[*]u8;
pub extern fn XGetICValues(arg0: XIC) ?[*]u8;
pub extern fn XIMOfIC(arg0: XIC) XIM;
pub extern fn XFilterEvent(arg0: ?[*]XEvent, arg1: Window) c_int;
pub extern fn XmbLookupString(arg0: XIC, arg1: ?[*]XKeyPressedEvent, arg2: ?[*]u8, arg3: c_int, arg4: ?[*]KeySym, arg5: ?[*]c_int) c_int;
pub extern fn XwcLookupString(arg0: XIC, arg1: ?[*]XKeyPressedEvent, arg2: ?[*]wchar_t, arg3: c_int, arg4: ?[*]KeySym, arg5: ?[*]c_int) c_int;
pub extern fn Xutf8LookupString(arg0: XIC, arg1: ?[*]XKeyPressedEvent, arg2: ?[*]u8, arg3: c_int, arg4: ?[*]KeySym, arg5: ?[*]c_int) c_int;
pub extern fn XVaCreateNestedList(arg0: c_int) XVaNestedList;
pub extern fn XRegisterIMInstantiateCallback(arg0: ?*Display, arg1: ?*struct__XrmHashBucketRec, arg2: ?[*]u8, arg3: ?[*]u8, arg4: XIDProc, arg5: XPointer) c_int;
pub extern fn XUnregisterIMInstantiateCallback(arg0: ?*Display, arg1: ?*struct__XrmHashBucketRec, arg2: ?[*]u8, arg3: ?[*]u8, arg4: XIDProc, arg5: XPointer) c_int;
pub const XConnectionWatchProc = ?extern fn(?*Display, XPointer, c_int, c_int, ?[*]XPointer) void;
pub extern fn XInternalConnectionNumbers(arg0: ?*Display, arg1: ?[*](?[*]c_int), arg2: ?[*]c_int) c_int;
pub extern fn XProcessInternalConnection(arg0: ?*Display, arg1: c_int) void;
pub extern fn XAddConnectionWatch(arg0: ?*Display, arg1: XConnectionWatchProc, arg2: XPointer) c_int;
pub extern fn XRemoveConnectionWatch(arg0: ?*Display, arg1: XConnectionWatchProc, arg2: XPointer) void;
pub extern fn XSetAuthorization(arg0: ?[*]u8, arg1: c_int, arg2: ?[*]u8, arg3: c_int) void;
pub extern fn _Xmbtowc(arg0: ?[*]wchar_t, arg1: ?[*]u8, arg2: c_int) c_int;
pub extern fn _Xwctomb(arg0: ?[*]u8, arg1: wchar_t) c_int;
pub extern fn XGetEventData(arg0: ?*Display, arg1: ?[*]XGenericEventCookie) c_int;
pub extern fn XFreeEventData(arg0: ?*Display, arg1: ?[*]XGenericEventCookie) void;
pub const XSizeHints = extern struct {
    flags: c_long,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    min_width: c_int,
    min_height: c_int,
    max_width: c_int,
    max_height: c_int,
    width_inc: c_int,
    height_inc: c_int,
    min_aspect: extern struct {
        x: c_int,
        y: c_int,
    },
    max_aspect: extern struct {
        x: c_int,
        y: c_int,
    },
    base_width: c_int,
    base_height: c_int,
    win_gravity: c_int,
};
pub const XWMHints = extern struct {
    flags: c_long,
    input: c_int,
    initial_state: c_int,
    icon_pixmap: Pixmap,
    icon_window: Window,
    icon_x: c_int,
    icon_y: c_int,
    icon_mask: Pixmap,
    window_group: XID,
};
pub const XTextProperty = extern struct {
    value: ?[*]u8,
    encoding: Atom,
    format: c_int,
    nitems: c_ulong,
};
pub const XStringStyle = 0;
pub const XCompoundTextStyle = 1;
pub const XTextStyle = 2;
pub const XStdICCTextStyle = 3;
pub const XUTF8StringStyle = 4;
pub const XICCEncodingStyle = extern enum {
    XStringStyle = 0,
    XCompoundTextStyle = 1,
    XTextStyle = 2,
    XStdICCTextStyle = 3,
    XUTF8StringStyle = 4,
};
pub const XIconSize = extern struct {
    min_width: c_int,
    min_height: c_int,
    max_width: c_int,
    max_height: c_int,
    width_inc: c_int,
    height_inc: c_int,
};
pub const XClassHint = extern struct {
    res_name: ?[*]u8,
    res_class: ?[*]u8,
};
pub const struct__XComposeStatus = extern struct {
    compose_ptr: XPointer,
    chars_matched: c_int,
};
pub const XComposeStatus = struct__XComposeStatus;
pub const struct__XRegion = @OpaqueType();
pub const Region = ?*struct__XRegion;
pub const XVisualInfo = extern struct {
    visual: ?[*]Visual,
    visualid: VisualID,
    screen: c_int,
    depth: c_int,
    class: c_int,
    red_mask: c_ulong,
    green_mask: c_ulong,
    blue_mask: c_ulong,
    colormap_size: c_int,
    bits_per_rgb: c_int,
};
pub const XStandardColormap = extern struct {
    colormap: Colormap,
    red_max: c_ulong,
    red_mult: c_ulong,
    green_max: c_ulong,
    green_mult: c_ulong,
    blue_max: c_ulong,
    blue_mult: c_ulong,
    base_pixel: c_ulong,
    visualid: VisualID,
    killid: XID,
};
pub const XContext = c_int;
pub extern fn XAllocClassHint() ?[*]XClassHint;
pub extern fn XAllocIconSize() ?[*]XIconSize;
pub extern fn XAllocSizeHints() ?[*]XSizeHints;
pub extern fn XAllocStandardColormap() ?[*]XStandardColormap;
pub extern fn XAllocWMHints() ?[*]XWMHints;
pub extern fn XClipBox(arg0: Region, arg1: ?[*]XRectangle) c_int;
pub extern fn XCreateRegion() Region;
pub extern fn XDefaultString() ?[*]const u8;
pub extern fn XDeleteContext(arg0: ?*Display, arg1: XID, arg2: XContext) c_int;
pub extern fn XDestroyRegion(arg0: Region) c_int;
pub extern fn XEmptyRegion(arg0: Region) c_int;
pub extern fn XEqualRegion(arg0: Region, arg1: Region) c_int;
pub extern fn XFindContext(arg0: ?*Display, arg1: XID, arg2: XContext, arg3: ?[*]XPointer) c_int;
pub extern fn XGetClassHint(arg0: ?*Display, arg1: Window, arg2: ?[*]XClassHint) c_int;
pub extern fn XGetIconSizes(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]XIconSize), arg3: ?[*]c_int) c_int;
pub extern fn XGetNormalHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints) c_int;
pub extern fn XGetRGBColormaps(arg0: ?*Display, arg1: Window, arg2: ?[*](?[*]XStandardColormap), arg3: ?[*]c_int, arg4: Atom) c_int;
pub extern fn XGetSizeHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints, arg3: Atom) c_int;
pub extern fn XGetStandardColormap(arg0: ?*Display, arg1: Window, arg2: ?[*]XStandardColormap, arg3: Atom) c_int;
pub extern fn XGetTextProperty(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty, arg3: Atom) c_int;
pub extern fn XGetVisualInfo(arg0: ?*Display, arg1: c_long, arg2: ?[*]XVisualInfo, arg3: ?[*]c_int) ?[*]XVisualInfo;
pub extern fn XGetWMClientMachine(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) c_int;
pub extern fn XGetWMHints(arg0: ?*Display, arg1: Window) ?[*]XWMHints;
pub extern fn XGetWMIconName(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) c_int;
pub extern fn XGetWMName(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) c_int;
pub extern fn XGetWMNormalHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints, arg3: ?[*]c_long) c_int;
pub extern fn XGetWMSizeHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints, arg3: ?[*]c_long, arg4: Atom) c_int;
pub extern fn XGetZoomHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints) c_int;
pub extern fn XIntersectRegion(arg0: Region, arg1: Region, arg2: Region) c_int;
pub extern fn XConvertCase(arg0: KeySym, arg1: ?[*]KeySym, arg2: ?[*]KeySym) void;
pub extern fn XLookupString(arg0: ?[*]XKeyEvent, arg1: ?[*]u8, arg2: c_int, arg3: ?[*]KeySym, arg4: ?[*]XComposeStatus) c_int;
pub extern fn XMatchVisualInfo(arg0: ?*Display, arg1: c_int, arg2: c_int, arg3: c_int, arg4: ?[*]XVisualInfo) c_int;
pub extern fn XOffsetRegion(arg0: Region, arg1: c_int, arg2: c_int) c_int;
pub extern fn XPointInRegion(arg0: Region, arg1: c_int, arg2: c_int) c_int;
pub extern fn XPolygonRegion(arg0: ?[*]XPoint, arg1: c_int, arg2: c_int) Region;
pub extern fn XRectInRegion(arg0: Region, arg1: c_int, arg2: c_int, arg3: c_uint, arg4: c_uint) c_int;
pub extern fn XSaveContext(arg0: ?*Display, arg1: XID, arg2: XContext, arg3: ?[*]const u8) c_int;
pub extern fn XSetClassHint(arg0: ?*Display, arg1: Window, arg2: ?[*]XClassHint) c_int;
pub extern fn XSetIconSizes(arg0: ?*Display, arg1: Window, arg2: ?[*]XIconSize, arg3: c_int) c_int;
pub extern fn XSetNormalHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints) c_int;
pub extern fn XSetRGBColormaps(arg0: ?*Display, arg1: Window, arg2: ?[*]XStandardColormap, arg3: c_int, arg4: Atom) void;
pub extern fn XSetSizeHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints, arg3: Atom) c_int;
pub extern fn XSetStandardProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: Pixmap, arg5: ?[*](?[*]u8), arg6: c_int, arg7: ?[*]XSizeHints) c_int;
pub extern fn XSetTextProperty(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty, arg3: Atom) void;
pub extern fn XSetWMClientMachine(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) void;
pub extern fn XSetWMHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XWMHints) c_int;
pub extern fn XSetWMIconName(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) void;
pub extern fn XSetWMName(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty) void;
pub extern fn XSetWMNormalHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints) void;
pub extern fn XSetWMProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]XTextProperty, arg3: ?[*]XTextProperty, arg4: ?[*](?[*]u8), arg5: c_int, arg6: ?[*]XSizeHints, arg7: ?[*]XWMHints, arg8: ?[*]XClassHint) void;
pub extern fn XmbSetWMProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: ?[*](?[*]u8), arg5: c_int, arg6: ?[*]XSizeHints, arg7: ?[*]XWMHints, arg8: ?[*]XClassHint) void;
pub extern fn Xutf8SetWMProperties(arg0: ?*Display, arg1: Window, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: ?[*](?[*]u8), arg5: c_int, arg6: ?[*]XSizeHints, arg7: ?[*]XWMHints, arg8: ?[*]XClassHint) void;
pub extern fn XSetWMSizeHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints, arg3: Atom) void;
pub extern fn XSetRegion(arg0: ?*Display, arg1: GC, arg2: Region) c_int;
pub extern fn XSetStandardColormap(arg0: ?*Display, arg1: Window, arg2: ?[*]XStandardColormap, arg3: Atom) void;
pub extern fn XSetZoomHints(arg0: ?*Display, arg1: Window, arg2: ?[*]XSizeHints) c_int;
pub extern fn XShrinkRegion(arg0: Region, arg1: c_int, arg2: c_int) c_int;
pub extern fn XStringListToTextProperty(arg0: ?[*](?[*]u8), arg1: c_int, arg2: ?[*]XTextProperty) c_int;
pub extern fn XSubtractRegion(arg0: Region, arg1: Region, arg2: Region) c_int;
pub extern fn XmbTextListToTextProperty(display: ?*Display, list: ?[*](?[*]u8), count: c_int, style: XICCEncodingStyle, text_prop_return: ?[*]XTextProperty) c_int;
pub extern fn XwcTextListToTextProperty(display: ?*Display, list: ?[*](?[*]wchar_t), count: c_int, style: XICCEncodingStyle, text_prop_return: ?[*]XTextProperty) c_int;
pub extern fn Xutf8TextListToTextProperty(display: ?*Display, list: ?[*](?[*]u8), count: c_int, style: XICCEncodingStyle, text_prop_return: ?[*]XTextProperty) c_int;
pub extern fn XwcFreeStringList(list: ?[*](?[*]wchar_t)) void;
pub extern fn XTextPropertyToStringList(arg0: ?[*]XTextProperty, arg1: ?[*](?[*](?[*]u8)), arg2: ?[*]c_int) c_int;
pub extern fn XmbTextPropertyToTextList(display: ?*Display, text_prop: ?[*]const XTextProperty, list_return: ?[*](?[*](?[*]u8)), count_return: ?[*]c_int) c_int;
pub extern fn XwcTextPropertyToTextList(display: ?*Display, text_prop: ?[*]const XTextProperty, list_return: ?[*](?[*](?[*]wchar_t)), count_return: ?[*]c_int) c_int;
pub extern fn Xutf8TextPropertyToTextList(display: ?*Display, text_prop: ?[*]const XTextProperty, list_return: ?[*](?[*](?[*]u8)), count_return: ?[*]c_int) c_int;
pub extern fn XUnionRectWithRegion(arg0: ?[*]XRectangle, arg1: Region, arg2: Region) c_int;
pub extern fn XUnionRegion(arg0: Region, arg1: Region, arg2: Region) c_int;
pub extern fn XWMGeometry(arg0: ?*Display, arg1: c_int, arg2: ?[*]const u8, arg3: ?[*]const u8, arg4: c_uint, arg5: ?[*]XSizeHints, arg6: ?[*]c_int, arg7: ?[*]c_int, arg8: ?[*]c_int, arg9: ?[*]c_int, arg10: ?[*]c_int) c_int;
pub extern fn XXorRegion(arg0: Region, arg1: Region, arg2: Region) c_int;
pub const pointer = ?*c_void;
pub const struct__Client = @OpaqueType();
pub const ClientPtr = ?*struct__Client;
pub const struct__Font = @OpaqueType();
pub const FontPtr = ?*struct__Font;
pub const FSID = c_ulong;
pub const AccContext = FSID;
pub const OSTimePtr = ?[*](?[*]struct_timeval);
pub const BlockHandlerProcPtr = ?extern fn(?*c_void, OSTimePtr, ?*c_void) void;
pub const Glyph = XID;
pub const GlyphSet = XID;
pub const Picture = XID;
pub const PictFormat = XID;
pub const XRenderDirectFormat = extern struct {
    red: c_short,
    redMask: c_short,
    green: c_short,
    greenMask: c_short,
    blue: c_short,
    blueMask: c_short,
    alpha: c_short,
    alphaMask: c_short,
};
pub const XRenderPictFormat = extern struct {
    id: PictFormat,
    type: c_int,
    depth: c_int,
    direct: XRenderDirectFormat,
    colormap: Colormap,
};
pub const struct__XRenderPictureAttributes = extern struct {
    repeat: c_int,
    alpha_map: Picture,
    alpha_x_origin: c_int,
    alpha_y_origin: c_int,
    clip_x_origin: c_int,
    clip_y_origin: c_int,
    clip_mask: Pixmap,
    graphics_exposures: c_int,
    subwindow_mode: c_int,
    poly_edge: c_int,
    poly_mode: c_int,
    dither: Atom,
    component_alpha: c_int,
};
pub const XRenderPictureAttributes = struct__XRenderPictureAttributes;
pub const XRenderColor = extern struct {
    red: c_ushort,
    green: c_ushort,
    blue: c_ushort,
    alpha: c_ushort,
};
pub const struct__XGlyphInfo = extern struct {
    width: c_ushort,
    height: c_ushort,
    x: c_short,
    y: c_short,
    xOff: c_short,
    yOff: c_short,
};
pub const XGlyphInfo = struct__XGlyphInfo;
pub const struct__XGlyphElt8 = extern struct {
    glyphset: GlyphSet,
    chars: ?[*]const u8,
    nchars: c_int,
    xOff: c_int,
    yOff: c_int,
};
pub const XGlyphElt8 = struct__XGlyphElt8;
pub const struct__XGlyphElt16 = extern struct {
    glyphset: GlyphSet,
    chars: ?[*]const c_ushort,
    nchars: c_int,
    xOff: c_int,
    yOff: c_int,
};
pub const XGlyphElt16 = struct__XGlyphElt16;
pub const struct__XGlyphElt32 = extern struct {
    glyphset: GlyphSet,
    chars: ?[*]const c_uint,
    nchars: c_int,
    xOff: c_int,
    yOff: c_int,
};
pub const XGlyphElt32 = struct__XGlyphElt32;
pub const XDouble = f64;
pub const struct__XPointDouble = extern struct {
    x: XDouble,
    y: XDouble,
};
pub const XPointDouble = struct__XPointDouble;
pub const XFixed = c_int;
pub const struct__XPointFixed = extern struct {
    x: XFixed,
    y: XFixed,
};
pub const XPointFixed = struct__XPointFixed;
pub const struct__XLineFixed = extern struct {
    p1: XPointFixed,
    p2: XPointFixed,
};
pub const XLineFixed = struct__XLineFixed;
pub const struct__XTriangle = extern struct {
    p1: XPointFixed,
    p2: XPointFixed,
    p3: XPointFixed,
};
pub const XTriangle = struct__XTriangle;
pub const struct__XCircle = extern struct {
    x: XFixed,
    y: XFixed,
    radius: XFixed,
};
pub const XCircle = struct__XCircle;
pub const struct__XTrapezoid = extern struct {
    top: XFixed,
    bottom: XFixed,
    left: XLineFixed,
    right: XLineFixed,
};
pub const XTrapezoid = struct__XTrapezoid;
pub const struct__XTransform = extern struct {
    matrix: [3][3]XFixed,
};
pub const XTransform = struct__XTransform;
pub const struct__XFilters = extern struct {
    nfilter: c_int,
    filter: ?[*](?[*]u8),
    nalias: c_int,
    alias: ?[*]c_short,
};
pub const XFilters = struct__XFilters;
pub const struct__XIndexValue = extern struct {
    pixel: c_ulong,
    red: c_ushort,
    green: c_ushort,
    blue: c_ushort,
    alpha: c_ushort,
};
pub const XIndexValue = struct__XIndexValue;
pub const struct__XAnimCursor = extern struct {
    cursor: Cursor,
    delay: c_ulong,
};
pub const XAnimCursor = struct__XAnimCursor;
pub const struct__XSpanFix = extern struct {
    left: XFixed,
    right: XFixed,
    y: XFixed,
};
pub const XSpanFix = struct__XSpanFix;
pub const struct__XTrap = extern struct {
    top: XSpanFix,
    bottom: XSpanFix,
};
pub const XTrap = struct__XTrap;
pub const struct__XLinearGradient = extern struct {
    p1: XPointFixed,
    p2: XPointFixed,
};
pub const XLinearGradient = struct__XLinearGradient;
pub const struct__XRadialGradient = extern struct {
    inner: XCircle,
    outer: XCircle,
};
pub const XRadialGradient = struct__XRadialGradient;
pub const struct__XConicalGradient = extern struct {
    center: XPointFixed,
    angle: XFixed,
};
pub const XConicalGradient = struct__XConicalGradient;
pub extern fn XRenderQueryExtension(dpy: ?*Display, event_basep: ?[*]c_int, error_basep: ?[*]c_int) c_int;
pub extern fn XRenderQueryVersion(dpy: ?*Display, major_versionp: ?[*]c_int, minor_versionp: ?[*]c_int) c_int;
pub extern fn XRenderQueryFormats(dpy: ?*Display) c_int;
pub extern fn XRenderQuerySubpixelOrder(dpy: ?*Display, screen: c_int) c_int;
pub extern fn XRenderSetSubpixelOrder(dpy: ?*Display, screen: c_int, subpixel: c_int) c_int;
pub extern fn XRenderFindVisualFormat(dpy: ?*Display, visual: ?[*]const Visual) ?[*]XRenderPictFormat;
pub extern fn XRenderFindFormat(dpy: ?*Display, mask: c_ulong, templ: ?[*]const XRenderPictFormat, count: c_int) ?[*]XRenderPictFormat;
pub extern fn XRenderFindStandardFormat(dpy: ?*Display, format: c_int) ?[*]XRenderPictFormat;
pub extern fn XRenderQueryPictIndexValues(dpy: ?*Display, format: ?[*]const XRenderPictFormat, num: ?[*]c_int) ?[*]XIndexValue;
pub extern fn XRenderCreatePicture(dpy: ?*Display, drawable: Drawable, format: ?[*]const XRenderPictFormat, valuemask: c_ulong, attributes: ?[*]const XRenderPictureAttributes) Picture;
pub extern fn XRenderChangePicture(dpy: ?*Display, picture: Picture, valuemask: c_ulong, attributes: ?[*]const XRenderPictureAttributes) void;
pub extern fn XRenderSetPictureClipRectangles(dpy: ?*Display, picture: Picture, xOrigin: c_int, yOrigin: c_int, rects: ?[*]const XRectangle, n: c_int) void;
pub extern fn XRenderSetPictureClipRegion(dpy: ?*Display, picture: Picture, r: Region) void;
pub extern fn XRenderSetPictureTransform(dpy: ?*Display, picture: Picture, transform: ?[*]XTransform) void;
pub extern fn XRenderFreePicture(dpy: ?*Display, picture: Picture) void;
pub extern fn XRenderComposite(dpy: ?*Display, op: c_int, src: Picture, mask: Picture, dst: Picture, src_x: c_int, src_y: c_int, mask_x: c_int, mask_y: c_int, dst_x: c_int, dst_y: c_int, width: c_uint, height: c_uint) void;
pub extern fn XRenderCreateGlyphSet(dpy: ?*Display, format: ?[*]const XRenderPictFormat) GlyphSet;
pub extern fn XRenderReferenceGlyphSet(dpy: ?*Display, existing: GlyphSet) GlyphSet;
pub extern fn XRenderFreeGlyphSet(dpy: ?*Display, glyphset: GlyphSet) void;
pub extern fn XRenderAddGlyphs(dpy: ?*Display, glyphset: GlyphSet, gids: ?[*]const Glyph, glyphs: ?[*]const XGlyphInfo, nglyphs: c_int, images: ?[*]const u8, nbyte_images: c_int) void;
pub extern fn XRenderFreeGlyphs(dpy: ?*Display, glyphset: GlyphSet, gids: ?[*]const Glyph, nglyphs: c_int) void;
pub extern fn XRenderCompositeString8(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, glyphset: GlyphSet, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, string: ?[*]const u8, nchar: c_int) void;
pub extern fn XRenderCompositeString16(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, glyphset: GlyphSet, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, string: ?[*]const c_ushort, nchar: c_int) void;
pub extern fn XRenderCompositeString32(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, glyphset: GlyphSet, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, string: ?[*]const c_uint, nchar: c_int) void;
pub extern fn XRenderCompositeText8(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, elts: ?[*]const XGlyphElt8, nelt: c_int) void;
pub extern fn XRenderCompositeText16(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, elts: ?[*]const XGlyphElt16, nelt: c_int) void;
pub extern fn XRenderCompositeText32(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, elts: ?[*]const XGlyphElt32, nelt: c_int) void;
pub extern fn XRenderFillRectangle(dpy: ?*Display, op: c_int, dst: Picture, color: ?[*]const XRenderColor, x: c_int, y: c_int, width: c_uint, height: c_uint) void;
pub extern fn XRenderFillRectangles(dpy: ?*Display, op: c_int, dst: Picture, color: ?[*]const XRenderColor, rectangles: ?[*]const XRectangle, n_rects: c_int) void;
pub extern fn XRenderCompositeTrapezoids(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, traps: ?[*]const XTrapezoid, ntrap: c_int) void;
pub extern fn XRenderCompositeTriangles(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, triangles: ?[*]const XTriangle, ntriangle: c_int) void;
pub extern fn XRenderCompositeTriStrip(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, points: ?[*]const XPointFixed, npoint: c_int) void;
pub extern fn XRenderCompositeTriFan(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, points: ?[*]const XPointFixed, npoint: c_int) void;
pub extern fn XRenderCompositeDoublePoly(dpy: ?*Display, op: c_int, src: Picture, dst: Picture, maskFormat: ?[*]const XRenderPictFormat, xSrc: c_int, ySrc: c_int, xDst: c_int, yDst: c_int, fpoints: ?[*]const XPointDouble, npoints: c_int, winding: c_int) void;
pub extern fn XRenderParseColor(dpy: ?*Display, spec: ?[*]u8, def: ?[*]XRenderColor) c_int;
pub extern fn XRenderCreateCursor(dpy: ?*Display, source: Picture, x: c_uint, y: c_uint) Cursor;
pub extern fn XRenderQueryFilters(dpy: ?*Display, drawable: Drawable) ?[*]XFilters;
pub extern fn XRenderSetPictureFilter(dpy: ?*Display, picture: Picture, filter: ?[*]const u8, params: ?[*]XFixed, nparams: c_int) void;
pub extern fn XRenderCreateAnimCursor(dpy: ?*Display, ncursor: c_int, cursors: ?[*]XAnimCursor) Cursor;
pub extern fn XRenderAddTraps(dpy: ?*Display, picture: Picture, xOff: c_int, yOff: c_int, traps: ?[*]const XTrap, ntrap: c_int) void;
pub extern fn XRenderCreateSolidFill(dpy: ?*Display, color: ?[*]const XRenderColor) Picture;
pub extern fn XRenderCreateLinearGradient(dpy: ?*Display, gradient: ?[*]const XLinearGradient, stops: ?[*]const XFixed, colors: ?[*]const XRenderColor, nstops: c_int) Picture;
pub extern fn XRenderCreateRadialGradient(dpy: ?*Display, gradient: ?[*]const XRadialGradient, stops: ?[*]const XFixed, colors: ?[*]const XRenderColor, nstops: c_int) Picture;
pub extern fn XRenderCreateConicalGradient(dpy: ?*Display, gradient: ?[*]const XConicalGradient, stops: ?[*]const XFixed, colors: ?[*]const XRenderColor, nstops: c_int) Picture;
pub const RROutput = XID;
pub const RRCrtc = XID;
pub const RRMode = XID;
pub const RRProvider = XID;
pub const XRRScreenSize = extern struct {
    width: c_int,
    height: c_int,
    mwidth: c_int,
    mheight: c_int,
};
pub const XRRScreenChangeNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    root: Window,
    timestamp: Time,
    config_timestamp: Time,
    size_index: SizeID,
    subpixel_order: SubpixelOrder,
    rotation: Rotation,
    width: c_int,
    height: c_int,
    mwidth: c_int,
    mheight: c_int,
};
pub const XRRNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
};
pub const XRROutputChangeNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    output: RROutput,
    crtc: RRCrtc,
    mode: RRMode,
    rotation: Rotation,
    connection: Connection,
    subpixel_order: SubpixelOrder,
};
pub const XRRCrtcChangeNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    crtc: RRCrtc,
    mode: RRMode,
    rotation: Rotation,
    x: c_int,
    y: c_int,
    width: c_uint,
    height: c_uint,
};
pub const XRROutputPropertyNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    output: RROutput,
    property: Atom,
    timestamp: Time,
    state: c_int,
};
pub const XRRProviderChangeNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    provider: RRProvider,
    timestamp: Time,
    current_role: c_uint,
};
pub const XRRProviderPropertyNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    provider: RRProvider,
    property: Atom,
    timestamp: Time,
    state: c_int,
};
pub const XRRResourceChangeNotifyEvent = extern struct {
    type: c_int,
    serial: c_ulong,
    send_event: c_int,
    display: ?*Display,
    window: Window,
    subtype: c_int,
    timestamp: Time,
};
pub const struct__XRRScreenConfiguration = @OpaqueType();
pub const XRRScreenConfiguration = struct__XRRScreenConfiguration;
pub extern fn XRRQueryExtension(dpy: ?*Display, event_base_return: ?[*]c_int, error_base_return: ?[*]c_int) c_int;
pub extern fn XRRQueryVersion(dpy: ?*Display, major_version_return: ?[*]c_int, minor_version_return: ?[*]c_int) c_int;
pub extern fn XRRGetScreenInfo(dpy: ?*Display, window: Window) ?*XRRScreenConfiguration;
pub extern fn XRRFreeScreenConfigInfo(config: ?*XRRScreenConfiguration) void;
pub extern fn XRRSetScreenConfig(dpy: ?*Display, config: ?*XRRScreenConfiguration, draw: Drawable, size_index: c_int, rotation: Rotation, timestamp: Time) c_int;
pub extern fn XRRSetScreenConfigAndRate(dpy: ?*Display, config: ?*XRRScreenConfiguration, draw: Drawable, size_index: c_int, rotation: Rotation, rate: c_short, timestamp: Time) c_int;
pub extern fn XRRConfigRotations(config: ?*XRRScreenConfiguration, current_rotation: ?[*]Rotation) Rotation;
pub extern fn XRRConfigTimes(config: ?*XRRScreenConfiguration, config_timestamp: ?[*]Time) Time;
pub extern fn XRRConfigSizes(config: ?*XRRScreenConfiguration, nsizes: ?[*]c_int) ?[*]XRRScreenSize;
pub extern fn XRRConfigRates(config: ?*XRRScreenConfiguration, sizeID: c_int, nrates: ?[*]c_int) ?[*]c_short;
pub extern fn XRRConfigCurrentConfiguration(config: ?*XRRScreenConfiguration, rotation: ?[*]Rotation) SizeID;
pub extern fn XRRConfigCurrentRate(config: ?*XRRScreenConfiguration) c_short;
pub extern fn XRRRootToScreen(dpy: ?*Display, root: Window) c_int;
pub extern fn XRRSelectInput(dpy: ?*Display, window: Window, mask: c_int) void;
pub extern fn XRRRotations(dpy: ?*Display, screen: c_int, current_rotation: ?[*]Rotation) Rotation;
pub extern fn XRRSizes(dpy: ?*Display, screen: c_int, nsizes: ?[*]c_int) ?[*]XRRScreenSize;
pub extern fn XRRRates(dpy: ?*Display, screen: c_int, sizeID: c_int, nrates: ?[*]c_int) ?[*]c_short;
pub extern fn XRRTimes(dpy: ?*Display, screen: c_int, config_timestamp: ?[*]Time) Time;
pub extern fn XRRGetScreenSizeRange(dpy: ?*Display, window: Window, minWidth: ?[*]c_int, minHeight: ?[*]c_int, maxWidth: ?[*]c_int, maxHeight: ?[*]c_int) c_int;
pub extern fn XRRSetScreenSize(dpy: ?*Display, window: Window, width: c_int, height: c_int, mmWidth: c_int, mmHeight: c_int) void;
pub const XRRModeFlags = c_ulong;
pub const struct__XRRModeInfo = extern struct {
    id: RRMode,
    width: c_uint,
    height: c_uint,
    dotClock: c_ulong,
    hSyncStart: c_uint,
    hSyncEnd: c_uint,
    hTotal: c_uint,
    hSkew: c_uint,
    vSyncStart: c_uint,
    vSyncEnd: c_uint,
    vTotal: c_uint,
    name: ?[*]u8,
    nameLength: c_uint,
    modeFlags: XRRModeFlags,
};
pub const XRRModeInfo = struct__XRRModeInfo;
pub const struct__XRRScreenResources = extern struct {
    timestamp: Time,
    configTimestamp: Time,
    ncrtc: c_int,
    crtcs: ?[*]RRCrtc,
    noutput: c_int,
    outputs: ?[*]RROutput,
    nmode: c_int,
    modes: ?[*]XRRModeInfo,
};
pub const XRRScreenResources = struct__XRRScreenResources;
pub extern fn XRRGetScreenResources(dpy: ?*Display, window: Window) ?*XRRScreenResources;
pub extern fn XRRFreeScreenResources(resources: ?[*]XRRScreenResources) void;
pub const struct__XRROutputInfo = extern struct {
    timestamp: Time,
    crtc: RRCrtc,
    name: ?[*]u8,
    nameLen: c_int,
    mm_width: c_ulong,
    mm_height: c_ulong,
    connection: Connection,
    subpixel_order: SubpixelOrder,
    ncrtc: c_int,
    crtcs: ?[*]RRCrtc,
    nclone: c_int,
    clones: ?[*]RROutput,
    nmode: c_int,
    npreferred: c_int,
    modes: ?[*]RRMode,
};
pub const XRROutputInfo = struct__XRROutputInfo;
pub extern fn XRRGetOutputInfo(dpy: ?*Display, resources: ?*XRRScreenResources, output: RROutput) ?*XRROutputInfo;
pub extern fn XRRFreeOutputInfo(outputInfo: ?[*]XRROutputInfo) void;
pub extern fn XRRListOutputProperties(dpy: ?*Display, output: RROutput, nprop: ?[*]c_int) ?[*]Atom;
pub const XRRPropertyInfo = extern struct {
    pending: c_int,
    range: c_int,
    immutable: c_int,
    num_values: c_int,
    values: ?[*]c_long,
};
pub extern fn XRRQueryOutputProperty(dpy: ?*Display, output: RROutput, property: Atom) ?[*]XRRPropertyInfo;
pub extern fn XRRConfigureOutputProperty(dpy: ?*Display, output: RROutput, property: Atom, pending: c_int, range: c_int, num_values: c_int, values: ?[*]c_long) void;
pub extern fn XRRChangeOutputProperty(dpy: ?*Display, output: RROutput, property: Atom, type_0: Atom, format: c_int, mode: c_int, data: ?[*]const u8, nelements: c_int) void;
pub extern fn XRRDeleteOutputProperty(dpy: ?*Display, output: RROutput, property: Atom) void;
pub extern fn XRRGetOutputProperty(dpy: ?*Display, output: RROutput, property: Atom, offset: c_long, length: c_long, _delete: c_int, pending: c_int, req_type: Atom, actual_type: ?[*]Atom, actual_format: ?[*]c_int, nitems: ?[*]c_ulong, bytes_after: ?[*]c_ulong, prop: ?[*](?[*]u8)) c_int;
pub extern fn XRRAllocModeInfo(name: ?[*]const u8, nameLength: c_int) ?[*]XRRModeInfo;
pub extern fn XRRCreateMode(dpy: ?*Display, window: Window, modeInfo: ?[*]XRRModeInfo) RRMode;
pub extern fn XRRDestroyMode(dpy: ?*Display, mode: RRMode) void;
pub extern fn XRRAddOutputMode(dpy: ?*Display, output: RROutput, mode: RRMode) void;
pub extern fn XRRDeleteOutputMode(dpy: ?*Display, output: RROutput, mode: RRMode) void;
pub extern fn XRRFreeModeInfo(modeInfo: ?[*]XRRModeInfo) void;
pub const struct__XRRCrtcInfo = extern struct {
    timestamp: Time,
    x: c_int,
    y: c_int,
    width: c_uint,
    height: c_uint,
    mode: RRMode,
    rotation: Rotation,
    noutput: c_int,
    outputs: ?[*]RROutput,
    rotations: Rotation,
    npossible: c_int,
    possible: ?[*]RROutput,
};
pub const XRRCrtcInfo = struct__XRRCrtcInfo;
pub extern fn XRRGetCrtcInfo(dpy: ?*Display, resources: ?*XRRScreenResources, crtc: RRCrtc) ?*XRRCrtcInfo;
pub extern fn XRRFreeCrtcInfo(crtcInfo: ?[*]XRRCrtcInfo) void;
pub extern fn XRRSetCrtcConfig(dpy: ?*Display, resources: ?[*]XRRScreenResources, crtc: RRCrtc, timestamp: Time, x: c_int, y: c_int, mode: RRMode, rotation: Rotation, outputs: ?[*]RROutput, noutputs: c_int) c_int;
pub extern fn XRRGetCrtcGammaSize(dpy: ?*Display, crtc: RRCrtc) c_int;
pub const struct__XRRCrtcGamma = extern struct {
    size: c_int,
    red: ?[*]c_ushort,
    green: ?[*]c_ushort,
    blue: ?[*]c_ushort,
};
pub const XRRCrtcGamma = struct__XRRCrtcGamma;
pub extern fn XRRGetCrtcGamma(dpy: ?*Display, crtc: RRCrtc) ?[*]XRRCrtcGamma;
pub extern fn XRRAllocGamma(size: c_int) ?[*]XRRCrtcGamma;
pub extern fn XRRSetCrtcGamma(dpy: ?*Display, crtc: RRCrtc, gamma: ?[*]XRRCrtcGamma) void;
pub extern fn XRRFreeGamma(gamma: ?[*]XRRCrtcGamma) void;
pub extern fn XRRGetScreenResourcesCurrent(dpy: ?*Display, window: Window) ?*XRRScreenResources;
pub extern fn XRRSetCrtcTransform(dpy: ?*Display, crtc: RRCrtc, transform: ?[*]XTransform, filter: ?[*]const u8, params: ?[*]XFixed, nparams: c_int) void;
pub const struct__XRRCrtcTransformAttributes = extern struct {
    pendingTransform: XTransform,
    pendingFilter: ?[*]u8,
    pendingNparams: c_int,
    pendingParams: ?[*]XFixed,
    currentTransform: XTransform,
    currentFilter: ?[*]u8,
    currentNparams: c_int,
    currentParams: ?[*]XFixed,
};
pub const XRRCrtcTransformAttributes = struct__XRRCrtcTransformAttributes;
pub extern fn XRRGetCrtcTransform(dpy: ?*Display, crtc: RRCrtc, attributes: ?[*](?[*]XRRCrtcTransformAttributes)) c_int;
pub extern fn XRRUpdateConfiguration(event: ?[*]XEvent) c_int;
pub const struct__XRRPanning = extern struct {
    timestamp: Time,
    left: c_uint,
    top: c_uint,
    width: c_uint,
    height: c_uint,
    track_left: c_uint,
    track_top: c_uint,
    track_width: c_uint,
    track_height: c_uint,
    border_left: c_int,
    border_top: c_int,
    border_right: c_int,
    border_bottom: c_int,
};
pub const XRRPanning = struct__XRRPanning;
pub extern fn XRRGetPanning(dpy: ?*Display, resources: ?[*]XRRScreenResources, crtc: RRCrtc) ?[*]XRRPanning;
pub extern fn XRRFreePanning(panning: ?[*]XRRPanning) void;
pub extern fn XRRSetPanning(dpy: ?*Display, resources: ?[*]XRRScreenResources, crtc: RRCrtc, panning: ?[*]XRRPanning) c_int;
pub extern fn XRRSetOutputPrimary(dpy: ?*Display, window: Window, output: RROutput) void;
pub extern fn XRRGetOutputPrimary(dpy: ?*Display, window: Window) RROutput;
pub const struct__XRRProviderResources = extern struct {
    timestamp: Time,
    nproviders: c_int,
    providers: ?[*]RRProvider,
};
pub const XRRProviderResources = struct__XRRProviderResources;
pub extern fn XRRGetProviderResources(dpy: ?*Display, window: Window) ?[*]XRRProviderResources;
pub extern fn XRRFreeProviderResources(resources: ?[*]XRRProviderResources) void;
pub const struct__XRRProviderInfo = extern struct {
    capabilities: c_uint,
    ncrtcs: c_int,
    crtcs: ?[*]RRCrtc,
    noutputs: c_int,
    outputs: ?[*]RROutput,
    name: ?[*]u8,
    nassociatedproviders: c_int,
    associated_providers: ?[*]RRProvider,
    associated_capability: ?[*]c_uint,
    nameLen: c_int,
};
pub const XRRProviderInfo = struct__XRRProviderInfo;
pub extern fn XRRGetProviderInfo(dpy: ?*Display, resources: ?[*]XRRScreenResources, provider: RRProvider) ?[*]XRRProviderInfo;
pub extern fn XRRFreeProviderInfo(provider: ?[*]XRRProviderInfo) void;
pub extern fn XRRSetProviderOutputSource(dpy: ?*Display, provider: XID, source_provider: XID) c_int;
pub extern fn XRRSetProviderOffloadSink(dpy: ?*Display, provider: XID, sink_provider: XID) c_int;
pub extern fn XRRListProviderProperties(dpy: ?*Display, provider: RRProvider, nprop: ?[*]c_int) ?[*]Atom;
pub extern fn XRRQueryProviderProperty(dpy: ?*Display, provider: RRProvider, property: Atom) ?[*]XRRPropertyInfo;
pub extern fn XRRConfigureProviderProperty(dpy: ?*Display, provider: RRProvider, property: Atom, pending: c_int, range: c_int, num_values: c_int, values: ?[*]c_long) void;
pub extern fn XRRChangeProviderProperty(dpy: ?*Display, provider: RRProvider, property: Atom, type_0: Atom, format: c_int, mode: c_int, data: ?[*]const u8, nelements: c_int) void;
pub extern fn XRRDeleteProviderProperty(dpy: ?*Display, provider: RRProvider, property: Atom) void;
pub extern fn XRRGetProviderProperty(dpy: ?*Display, provider: RRProvider, property: Atom, offset: c_long, length: c_long, _delete: c_int, pending: c_int, req_type: Atom, actual_type: ?[*]Atom, actual_format: ?[*]c_int, nitems: ?[*]c_ulong, bytes_after: ?[*]c_ulong, prop: ?[*](?[*]u8)) c_int;
pub const struct__XRRMonitorInfo = extern struct {
    name: Atom,
    primary: c_int,
    automatic: c_int,
    noutput: c_int,
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    mwidth: c_int,
    mheight: c_int,
    outputs: ?[*]RROutput,
};
pub const XRRMonitorInfo = struct__XRRMonitorInfo;
pub extern fn XRRAllocateMonitor(dpy: ?*Display, noutput: c_int) ?[*]XRRMonitorInfo;
pub extern fn XRRGetMonitors(dpy: ?*Display, window: Window, get_active: c_int, nmonitors: *c_int) ?[*]XRRMonitorInfo;
pub extern fn XRRSetMonitor(dpy: ?*Display, window: Window, monitor: ?[*]XRRMonitorInfo) void;
pub extern fn XRRDeleteMonitor(dpy: ?*Display, window: Window, name: Atom) void;
pub extern fn XRRFreeMonitors(monitors: ?[*]XRRMonitorInfo) void;
pub const XK_Greek_KAPPA = 1994;
pub const XK_Armenian_ben = 16778594;
pub const XK_Thai_khorakhang = 3494;
pub const XK_Armenian_JE = 16778571;
pub const XK_ISO_Set_Margin_Left = 65063;
pub const XK_Pointer_UpLeft = 65252;
pub const XK_Sinh_au2 = 16780766;
pub const XK_uhorn = 16777648;
pub const X_RRChangeOutputProperty = 13;
pub const XK_Ocircumflexacute = 16785104;
pub const XK_hebrew_zade = 3318;
pub const XK_KP_2 = 65458;
pub const XK_hebrew_finalkaph = 3306;
pub const XK_Hangul_YAE = 3778;
pub const XK_Georgian_san = 16781537;
pub const XK_braille_dots_13 = 16787461;
pub const XK_cacute = 486;
pub const XK_Sys_Req = 65301;
pub const GenericEvent = 35;
pub const XK_tcedilla = 510;
pub const PictOpColorDodge = 53;
pub const XK_Georgian_fi = 16781558;
pub const XK_Acircumflexacute = 16785060;
pub const XK_Ccaron = 456;
pub const XK_division = 247;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const XK_Thai_yoyak = 3522;
pub const BadLength = 16;
pub const XK_Cyrillic_es = 1747;
pub const BadValue = 2;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const XK_braille_dots_14568 = 16787641;
pub const X_RRChangeProviderProperty = 39;
pub const __WCHAR_WIDTH__ = 32;
pub const XK_Armenian_ZA = 16778550;
pub const XK_kana_KO = 1210;
pub const XK_ISO_Group_Lock = 65031;
pub const XK_braille_dots_28 = 16787586;
pub const XK_Pointer_Down = 65251;
pub const XK_hebrew_kuf = 3319;
pub const PictTypeIndexed = 0;
pub const __UINT_LEAST64_MAX__ = c_ulong(18446744073709551615);
pub const XK_kana_SHI = 1212;
pub const XK_Serbian_lje = 1705;
pub const XK_partdifferential = 16785922;
pub const PictOpConjointAtopReverse = 42;
pub const XIMStatusCallbacks = c_long(512);
pub const XK_braille_dots_24567 = 16787578;
pub const XK_Cyrillic_ze = 1754;
pub const XK_Odoubleacute = 469;
pub const RENDER_NAME = c"RENDER";
pub const __PTHREAD_MUTEX_HAVE_PREV = 1;
pub const XIMStringConversionChar = 4;
pub const XK_U = 85;
pub const XK_Serbian_dze = 1711;
pub const XK_Greek_chi = 2039;
pub const __CONSTANT_CFSTRINGS__ = 1;
pub const XK_dead_stroke = 65123;
pub const XNegative = 16;
pub const FilterFast = c"fast";
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __USE_POSIX199309 = 1;
pub const XK_Armenian_je = 16778619;
pub const FilterBilinear = c"bilinear";
pub const XK_Thai_chochoe = 3500;
pub const XK_Armenian_question = 16778590;
pub const XK_ygrave = 16785139;
pub const XK_braille_dots_245 = 16787482;
pub const XK_ISO_Last_Group = 65038;
pub const XK_Armenian_o = 16778629;
pub const XK_Hangul_YU = 3792;
pub const XK_Ukrainian_yi = 1703;
pub const XK_Igrave = 204;
pub const Above = 0;
pub const XK_KP_Decimal = 65454;
pub const XIMStatusNone = c_long(2048);
pub const XK_Ucircumflex = 219;
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const XK_Ohorntilde = 16785120;
pub const XK_dead_U = 65161;
pub const XK_Uogonek = 985;
pub const __SIZEOF_PTRDIFF_T__ = 8;
pub const WindingRule = 1;
pub const XLookupNone = 1;
pub const XK_Thai_saraae = 3553;
pub const XK_Aogonek = 417;
pub const XK_braille_dots_1358 = 16787605;
pub const XK_Uhook = 16785126;
pub const XK_Home = 65360;
pub const FontChange = 255;
pub const XK_Sinh_o2 = 16780764;
pub const XK_Arabic_feh = 1505;
pub const XK_Cyrillic_SCHWA = 16778456;
pub const XK_F17 = 65486;
pub const X_RenderAddGlyphsFromPicture = 21;
pub const X_HAVE_UTF8_STRING = 1;
pub const XK_Cyrillic_ZE = 1786;
pub const XK_questiondown = 191;
pub const XK_Armenian_CHA = 16778569;
pub const XK_braille_dots_357 = 16787540;
pub const DisableScreenInterval = 0;
pub const XK_A = 65;
pub const YXSorted = 2;
pub const __clockid_t_defined = 1;
pub const __UINT_LEAST8_MAX__ = 255;
pub const NotifyPointer = 5;
pub const XK_braille_dots_58 = 16787600;
pub const XK_Dabovedot = 16784906;
pub const XK_hcircumflex = 694;
pub const XK_Page_Up = 65365;
pub const XK_braille_dots_1247 = 16787531;
pub const PropertyDelete = 1;
pub const XK_Dcaron = 463;
pub const InputOutput = 1;
pub const XK_braille_dots_346 = 16787500;
pub const PictOpConjointAtop = 41;
pub const XK_Hangul_YA = 3777;
pub const XK_Thai_maitho = 3561;
pub const XNClientWindow = c"clientWindow";
pub const XK_Greek_finalsmallsigma = 2035;
pub const XK_Hangul_EO = 3779;
pub const XK_Zstroke = 16777653;
pub const XK_braille_dots_1378 = 16787653;
pub const XK_dead_I = 65157;
pub const XK_Arabic_tcheh = 16778886;
pub const X_RenderChangePicture = 5;
pub const __PTRDIFF_MAX__ = c_long(9223372036854775807);
pub const XK_Greek_mu = 2028;
pub const PlaceOnBottom = 1;
pub const BitmapFileInvalid = 2;
pub const XK_udiaeresis = 252;
pub const YSorted = 1;
pub const XK_Arabic_5 = 16778853;
pub const InputOnly = 2;
pub const CoordModePrevious = 1;
pub const XK_Georgian_par = 16781534;
pub const XK_braille_dots_124567 = 16787579;
pub const X_RRQueryVersion = 0;
pub const PictOpDisjointMinimum = 16;
pub const XK_Greek_iotadieresis = 1973;
pub const XK_Georgian_he = 16781553;
pub const XK_Sacute = 422;
pub const XK_Sinh_e = 16780689;
pub const ScreenSaverActive = 1;
pub const __UINTMAX_FMTu__ = c"lu";
pub const X_RenderSetPictureFilter = 30;
pub const XK_braille_dots_23456 = 16787518;
pub const XK_braille_dots_568 = 16787632;
pub const XK_R9 = 65498;
pub const XK_Arabic_noon_ghunna = 16778938;
pub const XK_ColonSign = 16785569;
pub const PolyEdgeSharp = 0;
pub const XK_Hangul_J_Cieuc = 3818;
pub const XK_h = 104;
pub const XK_Arabic_beh = 1480;
pub const __UINTMAX_WIDTH__ = 64;
pub const XYPixmap = 1;
pub const __PTHREAD_MUTEX_USE_UNION = 0;
pub const XK_Hangul_J_Rieul = 3803;
pub const FUNCPROTO = 15;
pub const XK_Hangul_SsangJieuj = 3769;
pub const XK_Serbian_JE = 1720;
pub const XK_ISO_Group_Latch = 65030;
pub const XK_ocaron = 16777682;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const XK_Armenian_ghat = 16778610;
pub const XK_KP_1 = 65457;
pub const XK_Utilde = 989;
pub const XK_Hangul_Codeinput = 65335;
pub const XK_braille_dots_12 = 16787459;
pub const XK_Greek_beta = 2018;
pub const __FD_SETSIZE = 1024;
pub const XK_Arabic_tehmarbuta = 1481;
pub const XK_Greek_MU = 1996;
pub const XK_Katakana = 65318;
pub const XK_kana_comma = 1188;
pub const XK_Hangul_E = 3780;
pub const X_RRSetScreenConfig = 2;
pub const XK_Korean_Won = 3839;
pub const XK_Aring = 197;
pub const __DBL_MAX__ = 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878;
pub const XK_Cyrillic_O = 1775;
pub const GXclear = 0;
pub const XK_Armenian_ZHE = 16778554;
pub const __UINT64_FMTx__ = c"lx";
pub const XK_braille_dots_4578 = 16787672;
pub const XK_Armenian_men = 16778612;
pub const XK_ninesubscript = 16785545;
pub const XK_Sinh_pa = 16780724;
pub const XK_Ibelowdot = 16785098;
pub const PointerRoot = c_long(1);
pub const __restrict_arr = __restrict;
pub const XK_MouseKeys_Enable = 65142;
pub const XK_Escape = 65307;
pub const XK_KP_Insert = 65438;
pub const __UINTPTR_WIDTH__ = 64;
pub const XK_T = 84;
pub const XK_Iogonek = 967;
pub const XK_Armenian_re = 16778624;
pub const XK_Arabic_shadda = 1521;
pub const XK_Georgian_shin = 16781544;
pub const ReparentNotify = 21;
pub const XK_Sinh_ba = 16780726;
pub const __k8 = 1;
pub const XK_Greek_upsilondieresis = 1977;
pub const XK_R10 = 65499;
pub const XK_underscore = 95;
pub const XK_Cyrillic_HA_descender = 16778418;
pub const XK_Cyrillic_ghe_bar = 16778387;
pub const XK_stricteq = 16786019;
pub const XK_Aacute = 193;
pub const XK_Hangul_Ieung = 3767;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const XK_uhornbelowdot = 16785137;
pub const XK_backslash = 92;
pub const __SIZE_FMTo__ = c"lo";
pub const XK_Serbian_dje = 1697;
pub const XK_hebrew_yod = 3305;
pub const XK_Arabic_qaf = 1506;
pub const RR_PROPERTY_RANDR_EDID = c"EDID";
pub const __UINT_FAST16_FMTx__ = c"hx";
pub const XK_Hangul_J_KkogjiDalrinIeung = 3833;
pub const RR_Reflect_X = 16;
pub const XK_braille_dots_3456 = 16787516;
pub const XK_braille_dots_12368 = 16787623;
pub const XK_KP_Next = 65435;
pub const XK_Gabovedot = 725;
pub const XK_iogonek = 999;
pub const XK_Hangul_WI = 3791;
pub const XK_F9 = 65478;
pub const XK_braille_dots_123568 = 16787639;
pub const XK_Return = 65293;
pub const __UINT_FAST64_FMTx__ = c"lx";
pub const XNFontSet = c"fontSet";
pub const XK_F10 = 65479;
pub const XK_Cyrillic_ZHE_descender = 16778390;
pub const XK_Cyrillic_de = 1732;
pub const __SIZE_WIDTH__ = 64;
pub const XK_Idiaeresis = 207;
pub const XK_braille_dots_35678 = 16787700;
pub const XK_Arabic_meem = 1509;
pub const __INT_MAX__ = 2147483647;
pub const XK_KP_Enter = 65421;
pub const XK_oe = 5053;
pub const XK_Hangul_RieulKiyeog = 3754;
pub const __clang_major__ = 6;
pub const XK_Hangul_Hieuh = 3774;
pub const XK_braille_dots_1246 = 16787499;
pub const XK_hebrew_dalet = 3299;
pub const XK_Hiragana = 65317;
pub const RectangleOut = 0;
pub const XK_Delete = 65535;
pub const XK_Lstroke = 419;
pub const XK_braille_dots_4 = 16787464;
pub const XK_braille_dots_345 = 16787484;
pub const __UINT_LEAST16_MAX__ = 65535;
pub const XK_Greek_psi = 2040;
pub const __UINT8_FMTu__ = c"hhu";
pub const UnmapGravity = 0;
pub const XK_Ecircumflex = 202;
pub const XK_iacute = 237;
pub const XK_Arabic_2 = 16778850;
pub const XK_Atilde = 195;
pub const XK_kana_TSU = 1218;
pub const XK_ISO_Partial_Line_Up = 65059;
pub const XK_braille_dots_145678 = 16787705;
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const XK_Hangul_J_SsangKiyeog = 3797;
pub const XK_Tabovedot = 16785002;
pub const RRNotify = 1;
pub const XNDefaultString = c"defaultString";
pub const XK_braille_dots_23457 = 16787550;
pub const XK_Caps_Lock = 65509;
pub const XK_Sinh_ae = 16780679;
pub const XK_dead_circumflex = 65106;
pub const XK_R8 = 65497;
pub const PictOpConjointMaximum = 43;
pub const XK_Cyrillic_DE = 1764;
pub const XK_dead_hook = 65121;
pub const HeightValue = 8;
pub const XK_Georgian_ghan = 16781542;
pub const __UINT32_FMTu__ = c"u";
pub const XK_braille_dots_2345 = 16787486;
pub const XK_wgrave = 16785025;
pub const XK_k = 107;
pub const GXor = 7;
pub const XK_kana_e = 1194;
pub const XK_script_switch = 65406;
pub const XK_cent = 162;
pub const XK_aogonek = 433;
pub const XK_Acircumflex = 194;
pub const __WORDSIZE_TIME64_COMPAT32 = 1;
pub const XK_Uhornhook = 16785132;
pub const XK_Hangul_J_Khieuq = 3819;
pub const XK_Cyrillic_DZHE = 1727;
pub const XK_KP_0 = 65456;
pub const __INT_LEAST16_TYPE__ = short;
pub const XK_Cyrillic_che = 1758;
pub const XK_Greek_TAU = 2004;
pub const XK_BackSpace = 65288;
pub const XK_Cyrillic_che_descender = 16778423;
pub const XK_braille_dots_2478 = 16787658;
pub const XK_approxeq = 16785992;
pub const RR_Capability_SourceOutput = 1;
pub const VisualScreenMask = 2;
pub const GXinvert = 10;
pub const XK_dead_abovereversedcomma = 65125;
pub const __SIZEOF_INT__ = 4;
pub const XK_braille_dots_12567 = 16787571;
pub const XK_braille_dots_13568 = 16787637;
pub const RRSetConfigInvalidTime = 2;
pub const XK_Help = 65386;
pub const XK_Armenian_exclam = 16778588;
pub const XK_igrave = 236;
pub const SelectionNotify = 31;
pub const XK_braille_dots_1468 = 16787625;
pub const XK_W = 87;
pub const X_RenderFreeGlyphs = 22;
pub const PictOpAtopReverse = 10;
pub const XK_Georgian_in = 16781528;
pub const Success = 0;
pub const XK_gcedilla = 955;
pub const __UINT64_FMTo__ = c"lo";
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const __ATOMIC_ACQ_REL = 4;
pub const XK_Thai_chochang = 3498;
pub const XK_Obarred = 16777631;
pub const XK_R11 = 65500;
pub const XK_braille_dots_2458 = 16787610;
pub const XK_KP_Subtract = 65453;
pub const XK_braille_dots_3468 = 16787628;
pub const XK_Zacute = 428;
pub const XK_KP_Begin = 65437;
pub const XK_Ograve = 210;
pub const XK_ohornbelowdot = 16785123;
pub const __INT64_MAX__ = c_long(9223372036854775807);
pub const XK_Hangul_EU = 3793;
pub const FillTiled = 1;
pub const XK_kana_NO = 1225;
pub const XK_acircumflexbelowdot = 16785069;
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const XK_fivesubscript = 16785541;
pub const RR_Reflect_Y = 32;
pub const XK_xabovedot = 16785035;
pub const XK_braille_dots_45 = 16787480;
pub const XK_braille_dots_3457 = 16787548;
pub const XK_Nacute = 465;
pub const XK_Greek_SIGMA = 2002;
pub const PictStandardA1 = 4;
pub const XK_MultipleCandidate = 65341;
pub const XK_idotless = 697;
pub const XK_Arabic_hah = 1485;
pub const X_RRSetProviderOutputSource = 35;
pub const XK_Ukranian_YI = 1719;
pub const _STDC_PREDEF_H = 1;
pub const XNStdColormap = c"stdColorMap";
pub const XK_F8 = 65477;
pub const __FLT16_MAX_EXP__ = 15;
pub const XK_hebrew_he = 3300;
pub const XK_gbreve = 699;
pub const XK_braille_dots_123567 = 16787575;
pub const XK_Armenian_paruyk = 16778590;
pub const XIMStringConversionRetrieval = 2;
pub const XK_Next = 65366;
pub const XK_Zabovedot = 431;
pub const XK_Cyrillic_lje = 1705;
pub const XK_Arabic_peh = 16778878;
pub const PictOpOutReverse = 8;
pub const XK_Georgian_phar = 16781540;
pub const XK_F11 = 65480;
pub const __SIG_ATOMIC_WIDTH__ = 32;
pub const XK_hebrew_zain = 3302;
pub const X_RenderCreateConicalGradient = 36;
pub const __UINT_FAST64_FMTX__ = c"lX";
pub const XK_braille_dots_12345 = 16787487;
pub const XK_C = 67;
pub const XK_Cyrillic_shorti = 1738;
pub const XK_Armenian_KEN = 16778559;
pub const XNDestroyCallback = c"destroyCallback";
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const RRNumberErrors = 4;
pub const XK_Armenian_LYUN = 16778556;
pub const __ID_T_TYPE = __U32_TYPE;
pub const FilterGood = c"good";
pub const XK_braille_dots_5 = 16787472;
pub const XK_Hangul_J_Mieum = 3811;
pub const XK_Thai_phosamphao = 3520;
pub const WestGravity = 4;
pub const XK_Touroku = 65323;
pub const __DBL_MIN_EXP__ = -1021;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const XK_fivesuperior = 16785525;
pub const XK_Arabic_zain = 1490;
pub const InputFocus = c_long(1);
pub const XK_kana_middledot = 1189;
pub const X_RenderQueryVersion = 0;
pub const XK_Greek_EPSILON = 1989;
pub const XK_Sinh_ii = 16780682;
pub const XK_Arabic_madda_above = 16778835;
pub const __FLOAT128__ = 1;
pub const SubPixelHorizontalBGR = 2;
pub const __SIZEOF_SHORT__ = 2;
pub const __UINT16_FMTX__ = c"hX";
pub const XK_Thai_leksun = 3568;
pub const XK_Arabic_3 = 16778851;
pub const __timeval_defined = 1;
pub const XK_kana_fullstop = 1185;
pub const XK_Cyrillic_u = 1749;
pub const XK_Ukranian_yi = 1703;
pub const XK_sevensuperior = 16785527;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const XK_Hangul_WAE = 3785;
pub const XK_Clear = 65291;
pub const XK_Armenian_HO = 16778560;
pub const XK_Uhornacute = 16785128;
pub const FocusIn = 9;
pub const RANDR_MINOR = 5;
pub const XIMPreeditPosition = c_long(4);
pub const __USE_XOPEN2K = 1;
pub const X_RenderQueryPictFormats = 1;
pub const __USE_FORTIFY_LEVEL = 0;
pub const XK_Greek_EPSILONaccent = 1954;
pub const XK_braille_dots_4678 = 16787688;
pub const XK_j = 106;
pub const XK_braille_dots_1458 = 16787609;
pub const XK_Cyrillic_ka = 1739;
pub const __USE_XOPEN2K8 = 1;
pub const Convex = 2;
pub const XK_Uhorn = 16777647;
pub const XK_Zcaron = 430;
pub const XK_Multi_key = 65312;
pub const XK_Break = 65387;
pub const XK_Ocircumflexgrave = 16785106;
pub const PictOpHSLColor = 61;
pub const __DBL_MANT_DIG__ = 53;
pub const X_RenderColorTriangles = 15;
pub const XK_Umacron = 990;
pub const RR_CSyncPositive = 128;
pub const XK_oacute = 243;
pub const XK_Sinh_lla = 16780741;
pub const XK_ogonek = 434;
pub const XK_kana_YA = 1236;
pub const __UID_T_TYPE = __U32_TYPE;
pub const XK_Arabic_hamzaunderalef = 1477;
pub const XK_Ukrainian_YI = 1719;
pub const __SIZEOF_SIZE_T__ = 8;
pub const IconicState = 3;
pub const __UINT_LEAST16_FMTo__ = c"ho";
pub const XK_Ediaeresis = 203;
pub const PictTypeDirect = 1;
pub const XK_ampersand = 38;
pub const XK_Cyrillic_A = 1761;
pub const XK_braille_dots_135678 = 16787701;
pub const XIMHotKeyStateOFF = c_long(2);
pub const XK_Sinh_ra = 16780731;
pub const XK_Arabic_tteh = 16778873;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const XK_Ecaron = 460;
pub const XK_Armenian_TYUN = 16778575;
pub const XK_Cyrillic_ka_vertstroke = 16778397;
pub const _X_RESTRICT_KYWD = restrict;
pub const XK_aacute = 225;
pub const XK_Hangul_PanSios = 3826;
pub const __INT16_MAX__ = 32767;
pub const XK_braille_dots_24568 = 16787642;
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __WINT_WIDTH__ = 32;
pub const GrabFrozen = 4;
pub const XK_Greek_ALPHA = 1985;
pub const XK_Georgian_char = 16781549;
pub const XK_V = 86;
pub const VisualRedMaskMask = 16;
pub const __SHRT_MAX__ = 32767;
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = 2;
pub const WhenMapped = 1;
pub const PictOpDisjointOut = 23;
pub const XK_ecircumflex = 234;
pub const __INT32_FMTd__ = c"d";
pub const XIMStringConversionTopEdge = 4;
pub const XK_PesetaSign = 16785575;
pub const XK_KP_Separator = 65452;
pub const __INTPTR_WIDTH__ = 64;
pub const XK_R12 = 65501;
pub const XK_kana_O = 1205;
pub const XK_Sinh_ha = 16780740;
pub const __INT_FAST32_TYPE__ = int;
pub const ClipByChildren = 0;
pub const XK_ISO_Prev_Group_Lock = 65035;
pub const XK_Thai_sarae = 3552;
pub const __LITTLE_ENDIAN = 1234;
pub const XK_ytilde = 16785145;
pub const XK_kana_ya = 1196;
pub const XK_Thai_chochan = 3496;
pub const XK_braille_dots_234567 = 16787582;
pub const XK_Cyrillic_SHORTI = 1770;
pub const XK_braille_dots_1268 = 16787619;
pub const BadCursor = 6;
pub const XK_etilde = 16785085;
pub const XK_degree = 176;
pub const XK_notidentical = 16786018;
pub const XK_Pause = 65299;
pub const XK_Cyrillic_te = 1748;
pub const __FLT16_HAS_INFINITY__ = 1;
pub const XNBackgroundPixmap = c"backgroundPixmap";
pub const XK_hebrew_taf = 3322;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1;
pub const XK_kana_TE = 1219;
pub const RR_Capability_SinkOffload = 8;
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = 3;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const XK_braille_dots_46 = 16787496;
pub const GraphicsExpose = 13;
pub const XK_braille_dots_257 = 16787538;
pub const XK_eng = 959;
pub const XK_paragraph = 182;
pub const __INT8_FMTd__ = c"hhd";
pub const XK_braille_dots_125678 = 16787699;
pub const XK_Hangul_RieulMieum = 3755;
pub const XK_dead_dasia = 65125;
pub const XK_F12 = 65481;
pub const RR_Capability_SourceOffload = 4;
pub const SubPixelVerticalBGR = 4;
pub const XK_braille_dot_9 = 65529;
pub const XK_braille_dots_12346 = 16787503;
pub const XK_Thai_lekha = 3573;
pub const XK_Hangul_Jeonja = 65336;
pub const XK_Thai_fofa = 3517;
pub const __UINTMAX_MAX__ = c_ulong(18446744073709551615);
pub const XK_Pointer_DblClick5 = 65267;
pub const XK_B = 66;
pub const XK_Ygrave = 16785138;
pub const LineDoubleDash = 2;
pub const XK_braille_dots_134567 = 16787581;
pub const IsUnmapped = 0;
pub const SetModeDelete = 1;
pub const XK_braille_dots_134 = 16787469;
pub const XK_braille_dots_1248 = 16787595;
pub const XK_dead_currency = 65135;
pub const X_RenderCreateRadialGradient = 35;
pub const StaticColor = 2;
pub const XK_KP_Up = 65431;
pub const XK_ediaeresis = 235;
pub const XK_Thai_kokai = 3489;
pub const XK_braille_dots_6 = 16787488;
pub const XK_MouseKeys_Accel_Enable = 65143;
pub const XK_Armenian_vo = 16778616;
pub const XK_kana_HE = 1229;
pub const BadRRMode = 2;
pub const XNFontInfo = c"fontInfo";
pub const XK_eogonek = 490;
pub const HostDelete = 1;
pub const XK_Greek_etaaccent = 1971;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XNDirectionalDependentDrawing = c"directionalDependentDrawing";
pub const XK_Arabic_ddal = 16778888;
pub const MappingFailed = 2;
pub const XK_Cyrillic_TE = 1780;
pub const XK_Thai_khokhon = 3493;
pub const XK_Thai_sosua = 3530;
pub const XK_Arabic_0 = 16778848;
pub const RectangleIn = 1;
pub const __INT_FAST32_FMTi__ = c"i";
pub const VisualBitsPerRGBMask = 256;
pub const XK_braille_dots_2356 = 16787510;
pub const X_RRListOutputProperties = 10;
pub const XK_Armenian_ligature_ew = 16778631;
pub const XK_dead_macron = 65108;
pub const XK_Hangul_AraeA = 3830;
pub const XK_Armenian_tso = 16778625;
pub const XK_dead_tilde = 65107;
pub const XK_ohorngrave = 16785117;
pub const XK_Arabic_fathatan = 1515;
pub const X_RRGetOutputInfo = 9;
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __UINT32_FMTX__ = c"X";
pub const XK_Sinh_uu = 16780684;
pub const XK_Cyrillic_HARDSIGN = 1791;
pub const XK_ecircumflexbelowdot = 16785095;
pub const XK_KP_Right = 65432;
pub const XK_braille_dots_2347 = 16787534;
pub const XK_Tslash = 940;
pub const XK_m = 109;
pub const XK_kana_WA = 1244;
pub const XK_Greek_DELTA = 1988;
pub const __BIT_TYPES_DEFINED__ = 1;
pub const BadGC = 13;
pub const XK_ehook = 16785083;
pub const __ATOMIC_RELEASE = 3;
pub const __SIZEOF_LONG_DOUBLE__ = 16;
pub const XK_kana_SA = 1211;
pub const XK_Sinh_dha = 16780719;
pub const XK_KP_F4 = 65428;
pub const XK_hebrew_zadi = 3318;
pub const NeedFunctionPrototypes = 1;
pub const GrabModeSync = 0;
pub const __SSE2_MATH__ = 1;
pub const PictOpDisjointDst = 18;
pub const XK_braille_dots_1578 = 16787665;
pub const XK_Serbian_NJE = 1722;
pub const BadMatch = 8;
pub const XK_Cyrillic_GHE = 1767;
pub const XK_foursuperior = 16785524;
pub const __STDC_IEC_559__ = 1;
pub const __USE_ISOC99 = 1;
pub const XK_F32 = 65501;
pub const XK_Hstroke = 673;
pub const PictOpDisjointClear = 16;
pub const XIMStringConversionConcealed = 16;
pub const __UINT64_FMTu__ = c"lu";
pub const XK_Pointer_UpRight = 65253;
pub const __GNUC__ = 4;
pub const XK_Iabovedot = 681;
pub const XK_Cyrillic_shha = 16778427;
pub const XK_zacute = 444;
pub const XK_jcircumflex = 700;
pub const X_RRGetProviderProperty = 41;
pub const XK_containsas = 16785931;
pub const _POSIX_C_SOURCE = c_long(200809);
pub const RRNotify_CrtcChange = 0;
pub const XK_Arabic_kasratan = 1517;
pub const __DBL_MAX_EXP__ = 1024;
pub const XK_Arabic_hamza_below = 16778837;
pub const XK_Y = 89;
pub const XK_Ch = 65185;
pub const XK_abovedot = 511;
pub const XK_dead_horn = 65122;
pub const XK_Hangul_J_KiyeogSios = 3798;
pub const PictOpOver = 3;
pub const XK_Cyrillic_CHE_vertstroke = 16778424;
pub const XK_odiaeresis = 246;
pub const XK_Serbian_DZE = 1727;
pub const XIMPreeditNone = c_long(16);
pub const XK_R13 = 65502;
pub const XK_BounceKeys_Enable = 65140;
pub const XK_kana_N = 1245;
pub const NotifyWhileGrabbed = 3;
pub const XK_prolongedsound = 1200;
pub const XK_Hangul_J_RieulKiyeog = 3804;
pub const XK_Georgian_jil = 16781547;
pub const PictOpBlendMinimum = 48;
pub const XK_Cyrillic_TSE = 1763;
pub const XK_Hangul_Dikeud = 3751;
pub const XK_asterisk = 42;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1;
pub const XK_amacron = 992;
pub const XK_Cyrillic_ZHE = 1782;
pub const XK_semicolon = 59;
pub const __SIZEOF_PTHREAD_CONDATTR_T = 4;
pub const XK_diaeresis = 168;
pub const XK_lstroke = 435;
pub const X_RRSetCrtcGamma = 24;
pub const XK_braille_dots_267 = 16787554;
pub const XK_parenright = 41;
pub const WithdrawnState = 0;
pub const XK_braille_dots_47 = 16787528;
pub const XK_kana_RO = 1243;
pub const XK_Thai_saraaa = 3538;
pub const XK_braille_dots_256 = 16787506;
pub const XK_Abreveacute = 16785070;
pub const unix = 1;
pub const XK_Sinh_ae2 = 16780752;
pub const XK_Cyrillic_ha = 1736;
pub const XK_FFrancSign = 16785571;
pub const XNPreeditCaretCallback = c"preeditCaretCallback";
pub const XIMStringConversionBottomEdge = 8;
pub const TrueColor = 4;
pub const __ATOMIC_CONSUME = 1;
pub const XK_Arabic_dad = 1494;
pub const XK_Sinh_tha = 16780717;
pub const XK_F13 = 65482;
pub const XK_Thai_thothong = 3512;
pub const XK_braille_dots_457 = 16787544;
pub const XK_Thai_khokhai = 3490;
pub const XK_Farsi_yeh = 16778956;
pub const XK_braille_dot_8 = 65528;
pub const XK_braille_dots_12347 = 16787535;
pub const XK_Serbian_tshe = 1707;
pub const ConfigureNotify = 22;
pub const XK_Pointer_DblClick4 = 65266;
pub const XK_E = 69;
pub const __INT_LEAST16_FMTd__ = c"hd";
pub const XK_braille_dots_13457 = 16787549;
pub const __INT_LEAST64_FMTd__ = c"ld";
pub const XIMStringConversionLeftEdge = 1;
pub const XK_Greek_horizbar = 1967;
pub const XK_braille_dots_135 = 16787477;
pub const XK_pabovedot = 16784983;
pub const XK_Wcircumflex = 16777588;
pub const XK_braille_dots_7 = 16787520;
pub const X_RenderCompositeGlyphs32 = 25;
pub const XK_Hangul_YE = 3782;
pub const XK_braille_dots_2368 = 16787622;
pub const XK_ETH = 208;
pub const XK_braille_dots_128 = 16787587;
pub const XK_Racute = 448;
pub const RRNotify_ProviderProperty = 4;
pub const XK_dead_E = 65155;
pub const XK_Georgian_don = 16781523;
pub const __SIZEOF_PTHREAD_RWLOCK_T = 56;
pub const X_RRSetCrtcTransform = 26;
pub const __UINT_LEAST16_FMTX__ = c"hX";
pub const XK_Thai_baht = 3551;
pub const __amd64__ = 1;
pub const X_RRDeleteProviderProperty = 40;
pub const XK_Arabic_1 = 16778849;
pub const XK_zcaron = 446;
pub const GrabSuccess = 0;
pub const XK_braille_dots_2567 = 16787570;
pub const __PTRDIFF_FMTi__ = c"li";
pub const XK_braille_dots_2357 = 16787542;
pub const XK_braille_dots_124678 = 16787691;
pub const AllValues = 15;
pub const _BITS_TYPESIZES_H = 1;
pub const XK_Amacron = 960;
pub const RR_Capability_SinkOutput = 2;
pub const XK_Sinh_a = 16780677;
pub const XK_Greek_PHI = 2006;
pub const XK_Georgian_ban = 16781521;
pub const XK_hebrew_doublelowline = 3295;
pub const XK_Hangul_SingleCandidate = 65340;
pub const XK_braille_dots_45678 = 16787704;
pub const XK_Hangul_J_Nieun = 3799;
pub const XK_KP_Multiply = 65450;
pub const QueuedAfterFlush = 2;
pub const XK_wcircumflex = 16777589;
pub const XK_braille_dots_2346 = 16787502;
pub const XK_hebrew_ayin = 3314;
pub const XK_Thai_thothahan = 3511;
pub const __INTMAX_MAX__ = c_long(9223372036854775807);
pub const XK_l = 108;
pub const DefaultExposures = 2;
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const RRNumberEvents = 2;
pub const GXnor = 8;
pub const CenterGravity = 5;
pub const XK_Sinh_ka = 16780698;
pub const XK_Uacute = 218;
pub const XK_Sinh_aa2 = 16780751;
pub const XK_Hangul_Nieun = 3748;
pub const BitmapSuccess = 0;
pub const XK_hstroke = 689;
pub const XK_Thai_khokhuat = 3491;
pub const ControlMapIndex = 2;
pub const LedModeOff = 0;
pub const XK_Cyrillic_U_straight = 16778414;
pub const XK_KP_Space = 65408;
pub const XK_scircumflex = 766;
pub const XK_Armenian_ayb = 16778593;
pub const XK_Eisu_Shift = 65327;
pub const XK_ISO_Next_Group_Lock = 65033;
pub const XK_Scroll_Lock = 65300;
pub const FillOpaqueStippled = 3;
pub const XK_Thai_honokhuk = 3534;
pub const XK_Hangul_I = 3795;
pub const VisualBlueMaskMask = 64;
pub const XK_yen = 165;
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __clang_version__ = c"6.0.1 (tags/RELEASE_601/final)";
pub const __UINT_LEAST8_FMTo__ = c"hho";
pub const XK_hebrew_samekh = 3313;
pub const XK_F33 = 65502;
pub const XK_kana_MO = 1235;
pub const __INTMAX_FMTd__ = c"ld";
pub const LeaveNotify = 8;
pub const NeedNestedPrototypes = 1;
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = 2;
pub const XK_Fabovedot = 16784926;
pub const XK_Sinh_u = 16780683;
pub const XK_rcaron = 504;
pub const XK_Ecircumflexacute = 16785086;
pub const XK_Hangul_SunkyeongeumPieub = 3825;
pub const XK_Thai_sarauu = 3545;
pub const XK_Georgian_tar = 16781538;
pub const XNResourceClass = c"resourceClass";
pub const NeedWidePrototypes = 0;
pub const __ptr_t = [*]void;
pub const XK_dead_doubleacute = 65113;
pub const X_RROldScreenChangeSelectInput = 3;
pub const XK_Arabic_fatha = 1518;
pub const XK_X = 88;
pub const ColormapInstalled = 1;
pub const XK_braille_dots_38 = 16787588;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const AsyncKeyboard = 3;
pub const XK_R14 = 65503;
pub const XK_kana_I = 1202;
pub const XK_KP_Divide = 65455;
pub const RepeatPad = 2;
pub const AllocNone = 0;
pub const XK_at = 64;
pub const XK_Ytilde = 16785144;
pub const _ATFILE_SOURCE = 1;
pub const NoValue = 0;
pub const X_RRDeleteOutputProperty = 14;
pub const XK_braille_dots_467 = 16787560;
pub const RR_PROPERTY_CONNECTOR_NUMBER = c"ConnectorNumber";
pub const __INT_FAST16_FMTi__ = c"hi";
pub const XK_braille_dots_158 = 16787601;
pub const BadName = 15;
pub const VisibilityNotify = 15;
pub const InactiveState = 4;
pub const RR_PROPERTY_BORDER_DIMENSIONS = c"BorderDimensions";
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub const XK_braille_dots_34567 = 16787580;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INT64_C_SUFFIX__ = L;
pub const XK_Cyrillic_EN_descender = 16778402;
pub const XK_Hangul_J_NieunHieuh = 3801;
pub const XK_braille_dots_134578 = 16787677;
pub const XK_ISO_Level5_Lock = 65043;
pub const XK_Thai_rorua = 3523;
pub const __SIG_ATOMIC_MAX__ = 2147483647;
pub const XK_braille_dots_145 = 16787481;
pub const BadImplementation = 17;
pub const __UINT64_MAX__ = c_ulong(18446744073709551615);
pub const XK_Georgian_un = 16781539;
pub const GrabModeAsync = 1;
pub const X_RenderTriangles = 11;
pub const VisualDepthMask = 4;
pub const X_RRGetMonitors = 42;
pub const XK_braille_dots_456 = 16787512;
pub const XK_guillemotleft = 171;
pub const XNFocusWindow = c"focusWindow";
pub const XK_uring = 505;
pub const XK_Imacron = 975;
pub const VisualClassMask = 8;
pub const XK_braille_dots_12348 = 16787599;
pub const XK_braille_dot_7 = 65527;
pub const XK_Cyrillic_u_straight_bar = 16778417;
pub const RRNotify_OutputProperty = 2;
pub const XK_Hangul_OE = 3786;
pub const XK_wacute = 16785027;
pub const XK_D = 68;
pub const XK_Hangul_Phieuf = 3773;
pub const __UINT_FAST16_FMTu__ = c"hu";
pub const XK_braille_dots_1368 = 16787621;
pub const XK_braille_dots_13456 = 16787517;
pub const __INTPTR_FMTi__ = c"li";
pub const XK_Sinh_tta = 16780711;
pub const XK_numbersign = 35;
pub const XK_braille_dots_136 = 16787493;
pub const XK_ohorn = 16777633;
pub const XK_Greek_IOTAaccent = 1956;
pub const XK_Sinh_h2 = 16780675;
pub const __UINT8_FMTo__ = c"hho";
pub const XK_Ebelowdot = 16785080;
pub const GXandInverted = 4;
pub const __UINT_FAST8_FMTu__ = c"hhu";
pub const XK_Thai_phophan = 3518;
pub const PictOpConjointMinimum = 32;
pub const RR_HSkewPresent = 512;
pub const XK_Cyrillic_I_macron = 16778466;
pub const XK_braille_dots_68 = 16787616;
pub const XK_braille_dots_127 = 16787523;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XK_braille_dots_23567 = 16787574;
pub const XK_Greek_UPSILON = 2005;
pub const XK_ISO_Fast_Cursor_Right = 65069;
pub const XK_Hangul_J_RieulHieuh = 3810;
pub const __UINT_LEAST8_FMTX__ = c"hhX";
pub const XK_Arabic_hamza = 1473;
pub const XK_dead_belowdiaeresis = 65132;
pub const XK_Kana_Lock = 65325;
pub const RR_DoubleScan = 32;
pub const XK_imacron = 1007;
pub const __POINTER_WIDTH__ = 64;
pub const XK_Arabic_fullstop = 16778964;
pub const __FLT16_DIG__ = 3;
pub const __SIZEOF_LONG__ = 8;
pub const XK_Thai_thonangmontho = 3505;
pub const XK_ybelowdot = 16785141;
pub const XK_Georgian_hie = 16781554;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XK_Sinh_aa = 16780678;
pub const XK_Georgian_qar = 16781543;
pub const ParentRelative = c_long(1);
pub const XK_ISO_Move_Line_Up = 65057;
pub const __NO_INLINE__ = 1;
pub const XK_abrevetilde = 16785077;
pub const XK_braille_dots_358 = 16787604;
pub const _BITS_PTHREADTYPES_COMMON_H = 1;
pub const XK_Greek_kappa = 2026;
pub const XK_braille_dots_123458 = 16787615;
pub const XK_o = 111;
pub const XK_kana_WO = 1190;
pub const XK_Thai_oang = 3533;
pub const XK_Sinh_ma = 16780728;
pub const ZoomState = 2;
pub const XK_Zenkaku = 65320;
pub const XK_Hangul_Pieub = 3762;
pub const XK_kana_a = 1191;
pub const PictOpConjointInReverse = 38;
pub const PropertyNewValue = 0;
pub const XK_acute = 180;
pub const XK_Armenian_E = 16778551;
pub const XK_kana_CHI = 1217;
pub const XK_ohorntilde = 16785121;
pub const X_RRSetProviderOffloadSink = 34;
pub const NotifyPointerRoot = 6;
pub const XK_dead_caron = 65114;
pub const __DBL_MAX_10_EXP__ = 308;
pub const XK_tcaron = 443;
pub const XK_Kcedilla = 979;
pub const XK_F30 = 65499;
pub const XIMPreeditArea = c_long(1);
pub const KeyRelease = 3;
pub const _DEFAULT_SOURCE = 1;
pub const XK_kana_KA = 1206;
pub const XK_acircumflexgrave = 16785063;
pub const XK_braille_dots_123478 = 16787663;
pub const DisableScreenSaver = 0;
pub const XK_L9 = 65488;
pub const CapButt = 1;
pub const PictOpDst = 2;
pub const XK_Armenian_FE = 16778582;
pub const XK_Sinh_mba = 16780729;
pub const XK_Hangul_SsangSios = 3766;
pub const XK_braille_dots_567 = 16787568;
pub const XK_Arabic_sukun = 1522;
pub const RR_BCast = 1024;
pub const BadPictOp = 2;
pub const XK_Alt_R = 65514;
pub const Button1 = 1;
pub const XK_F25 = 65494;
pub const X_RRGetScreenResources = 8;
pub const XK_Uhornbelowdot = 16785136;
pub const XK_zerosubscript = 16785536;
pub const XK_Sinh_ttha = 16780712;
pub const XK_Armenian_hi = 16778613;
pub const XNHotKey = c"hotKey";
pub const X_RRSetScreenSize = 7;
pub const XK_braille_dots_4568 = 16787640;
pub const YNegative = 32;
pub const AllocAll = 1;
pub const XK_Thai_saraaimaimuan = 3555;
pub const XK_dead_longsolidusoverlay = 65171;
pub const RRNotify_ProviderChange = 3;
pub const GXnand = 14;
pub const XK_kana_u = 1193;
pub const XK_Hangul_J_Ieung = 3816;
pub const __RLIM_T_MATCHES_RLIM64_T = 1;
pub const XK_R15 = 65504;
pub const SetModeInsert = 0;
pub const XK_SlowKeys_Enable = 65139;
pub const XK_Hangul_Khieuq = 3771;
pub const __time_t_defined = 1;
pub const XK_Ukranian_I = 1718;
pub const XK_Armenian_VO = 16778568;
pub const XK_Hiragana_Katakana = 65319;
pub const __INTMAX_C_SUFFIX__ = L;
pub const XK_L10 = 65489;
pub const XK_Armenian_da = 16778596;
pub const __INT16_FMTd__ = c"hd";
pub const XK_Sabovedot = 16784992;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1;
pub const XNAreaNeeded = c"areaNeeded";
pub const XK_dead_greek = 65164;
pub const X_RenderFillRectangles = 26;
pub const XK_ezh = 16777874;
pub const __INTMAX_WIDTH__ = 64;
pub const XK_kana_RI = 1240;
pub const __USE_POSIX = 1;
pub const XK_dead_belowcomma = 65134;
pub const __PDP_ENDIAN = 3412;
pub const SouthWestGravity = 7;
pub const __INT_FAST8_FMTi__ = c"hhi";
pub const XNStatusDrawCallback = c"statusDrawCallback";
pub const XK_Cyrillic_O_bar = 16778472;
pub const XK_Arabic_farsi_yeh = 16778956;
pub const __GCC_ATOMIC_LONG_LOCK_FREE = 2;
pub const XK_Farsi_9 = 16779001;
pub const XK_braille_dot_6 = 65526;
pub const XK_Ukrainian_ie = 1700;
pub const XK_AccessX_Feedback_Enable = 65137;
pub const XK_Thai_maitaikhu = 3559;
pub const XK_G = 71;
pub const __FLT_MANT_DIG__ = 24;
pub const XK_Cyrillic_che_vertstroke = 16778425;
pub const XK_Ugrave = 217;
pub const __STDC__ = 1;
pub const XK_braille_dots_137 = 16787525;
pub const __INTPTR_FMTd__ = c"ld";
pub const __GNUC_PATCHLEVEL__ = 1;
pub const __INT_FAST16_MAX__ = 32767;
pub const __have_pthread_attr_t = 1;
pub const XK_braille_dots_1 = 16787457;
pub const X_RenderAddGlyphs = 20;
pub const XK_DongSign = 16785579;
pub const XK_VoidSymbol = 16777215;
pub const XK_babovedot = 16784899;
pub const XK_Serbian_nje = 1706;
pub const RectanglePart = 2;
pub const XK_Cyrillic_ghe = 1735;
pub const XK_braille_dots_126 = 16787491;
pub const XK_Cyrillic_io = 1699;
pub const XK_hebrew_finalmem = 3309;
pub const __FLT_DENORM_MIN__ = 0.000000;
pub const XK_kana_MU = 1233;
pub const __LDBL_HAS_QUIET_NAN__ = 1;
pub const ShiftMapIndex = 0;
pub const XK_Thai_wowaen = 3527;
pub const XK_Cyrillic_i = 1737;
pub const XK_plus = 43;
pub const __SIZEOF_PTHREAD_MUTEX_T = 40;
pub const XK_nacute = 497;
pub const FocusOut = 10;
pub const __UINT16_FMTu__ = c"hu";
pub const XK_Greek_delta = 2020;
pub const XK_Thai_totao = 3509;
pub const __LDBL_MIN_EXP__ = -16381;
pub const XK_obelowdot = 16785101;
pub const __clang_patchlevel__ = 1;
pub const XK_braille_dots_123457 = 16787551;
pub const XK_Cyrillic_SHA = 1787;
pub const XK_Hangul_J_PieubSios = 3813;
pub const XK_acircumflexhook = 16785065;
pub const ArcChord = 0;
pub const XK_n = 110;
pub const KeymapNotify = 11;
pub const XK_Pabovedot = 16784982;
pub const XK_Georgian_zhar = 16781535;
pub const GrabInvalidTime = 2;
pub const XK_Sinh_gha = 16780701;
pub const __SIZEOF_PTHREAD_COND_T = 48;
pub const XK_Dstroke = 464;
pub const XK_Cyrillic_tse = 1731;
pub const XNVisiblePosition = c"visiblePosition";
pub const XK_Cyrillic_IO = 1715;
pub const XNOMAutomatic = c"omAutomatic";
pub const __USE_ISOC11 = 1;
pub const XK_Cyrillic_zhe = 1750;
pub const XK_Cabovedot = 709;
pub const __UINTMAX_FMTx__ = c"lx";
pub const __INT_LEAST16_MAX__ = 32767;
pub const __UINT32_FMTo__ = c"o";
pub const XK_F31 = 65500;
pub const XK_kana_MA = 1231;
pub const PictOpDisjointXor = 27;
pub const NorthEastGravity = 3;
pub const X_RROldGetScreenInfo = 1;
pub const XK_Cyrillic_E = 1788;
pub const XK_braille_dots_23 = 16787462;
pub const XK_L8 = 65487;
pub const XK_Udoubleacute = 475;
pub const XK_braille_dots_23458 = 16787614;
pub const RR_PROPERTY_GUID = c"GUID";
pub const XK_threesuperior = 179;
pub const XK_Hangul_RieulYeorinHieuh = 3823;
pub const XK_KP_Add = 65451;
pub const VisibilityFullyObscured = 2;
pub const XK_F24 = 65493;
pub const XK_Pointer_Drag_Dflt = 65268;
pub const XK_ncedilla = 1009;
pub const __amd64 = 1;
pub const XK_braille_dots_1467 = 16787561;
pub const __OBJC_BOOL_IS_BOOL = 0;
pub const XK_RepeatKeys_Enable = 65138;
pub const XK_Z = 90;
pub const XNLineSpace = c"lineSpace";
pub const PictOpClear = 0;
pub const XK_Ohook = 16785102;
pub const XK_Pointer_Right = 65249;
pub const XCSUCCESS = 0;
pub const XK_Lbelowdot = 16784950;
pub const XK_Ccircumflex = 710;
pub const XK_Greek_xi = 2030;
pub const XK_hebrew_finalzadi = 3317;
pub const XK_Arabic_heh = 1511;
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
pub const XK_ISO_Lock = 65025;
pub const XK_ocircumflex = 244;
pub const PictOpHardLight = 55;
pub const XK_braille_dots_2457 = 16787546;
pub const XK_eabovedot = 1004;
pub const DirectColor = 5;
pub const RENDER_MAJOR = 0;
pub const XK_Thai_saraa = 3536;
pub const XK_Arabic_ain = 1497;
pub const XK_dead_abovering = 65112;
pub const BadRRCrtc = 1;
pub const XK_SCHWA = 16777615;
pub const XK_dead_o = 65158;
pub const XK_Eth = 208;
pub const BadFont = 7;
pub const XK_Cyrillic_u_macron = 16778479;
pub const XK_Sinh_ng = 16780674;
pub const X_RenderCreateAnimCursor = 31;
pub const XK_kana_TI = 1217;
pub const XK_Greek_phi = 2038;
pub const XK_braille_dots_14567 = 16787577;
pub const XK_braille_dots_12467 = 16787563;
pub const PictStandardA4 = 3;
pub const X_RRQueryOutputProperty = 11;
pub const XK_braille_dots_13567 = 16787573;
pub const XK_braille_dots_12568 = 16787635;
pub const GXorReverse = 11;
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = 0;
pub const XK_braille_dots_147 = 16787529;
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const PictOpConjointClear = 32;
pub const _X_INLINE = @"inline";
pub const RR_CSync = 64;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const XK_braille_dots_1234567 = 16787583;
pub const __INT32_FMTi__ = c"i";
pub const XK_Farsi_8 = 16779000;
pub const __DBL_HAS_INFINITY__ = 1;
pub const XK_Wacute = 16785026;
pub const XK_braille_dot_5 = 65525;
pub const XK_Georgian_an = 16781520;
pub const XK_notelementof = 16785929;
pub const XK_Thai_saraii = 3541;
pub const PolyModeImprecise = 1;
pub const XK_Pointer_DblClick1 = 65263;
pub const XK_F = 70;
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1;
pub const XK_Hangul_J_RieulPieub = 3806;
pub const XK_braille_dots_167 = 16787553;
pub const XK_Georgian_gan = 16781522;
pub const PictOpAtop = 9;
pub const XK_Armenian_accent = 16778587;
pub const XK_Armenian_ini = 16778603;
pub const __FD_ZERO_STOS = c"stosq";
pub const XK_Armenian_AYB = 16778545;
pub const XK_ordfeminine = 170;
pub const XK_Hangul_J_Jieuj = 3817;
pub const PictOpHSLSaturation = 60;
pub const XK_braille_dots_248 = 16787594;
pub const XK_ycircumflex = 16777591;
pub const XK_braille_dots_2 = 16787458;
pub const XK_braille_dots_3467 = 16787564;
pub const PropModePrepend = 1;
pub const XK_kana_HA = 1226;
pub const XNSpotLocation = c"spotLocation";
pub const XK_Greek_tau = 2036;
pub const XK_Thai_yoying = 3501;
pub const XK_aring = 229;
pub const XK_braille_dots_125 = 16787475;
pub const XK_braille_dots_1234578 = 16787679;
pub const _SYS_SYSMACROS_H = 1;
pub const X_RenderScale = 9;
pub const XK_egrave = 232;
pub const XK_kana_TU = 1218;
pub const PictOpConjointOut = 39;
pub const XK_braille_dots_2568 = 16787634;
pub const Bool = int;
pub const XK_ISO_Fast_Cursor_Down = 65071;
pub const XK_Ubelowdot = 16785124;
pub const __HAVE_GENERIC_SELECTION = 1;
pub const __ATOMIC_RELAXED = 0;
pub const __UINT_FAST16_MAX__ = 65535;
pub const XK_ISO_Emphasize = 65074;
pub const XK_Greek_ALPHAaccent = 1953;
pub const X_RRSelectInput = 4;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const XK_braille_dots_123456 = 16787519;
pub const XK_q = 113;
pub const PictOpDifference = 57;
pub const __STDC_HOSTED__ = 1;
pub const XK_ecircumflextilde = 16785093;
pub const XK_Xabovedot = 16785034;
pub const XK_zstroke = 16777654;
pub const __INT_LEAST32_TYPE__ = int;
pub const XK_Cyrillic_SOFTSIGN = 1784;
pub const __FLT16_MIN_EXP__ = -14;
pub const XK_dead_psili = 65124;
pub const SubPixelVerticalRGB = 3;
pub const XK_Hcircumflex = 678;
pub const __PTHREAD_MUTEX_LOCK_ELISION = 1;
pub const AsyncBoth = 6;
pub const XK_kana_SE = 1214;
pub const XK_Last_Virtual_Screen = 65236;
pub const __CLANG_ATOMIC_INT_LOCK_FREE = 2;
pub const XK_registered = 174;
pub const XK_numerosign = 1712;
pub const XIMPreeditNothing = c_long(8);
pub const RR_ClockDivideBy2 = 8192;
pub const RetainPermanent = 1;
pub const XK_ubreve = 765;
pub const XK_Shift_Lock = 65510;
pub const XK_braille_dots_238 = 16787590;
pub const __USE_ISOC95 = 1;
pub const BadDrawable = 9;
pub const XNStringConversionCallback = c"stringConversionCallback";
pub const XK_Sinh_thha = 16780718;
pub const XK_hebrew_mem = 3310;
pub const XK_scedilla = 442;
pub const XNoMemory = -1;
pub const XK_hebrew_beth = 3297;
pub const XNColormap = c"colorMap";
pub const XK_KP_Page_Up = 65434;
pub const XK_Control_L = 65507;
pub const GXset = 15;
pub const RR_HSyncPositive = 1;
pub const XK_Alt_L = 65513;
pub const XK_F27 = 65496;
pub const XK_Armenian_RA = 16778572;
pub const Button3 = 3;
pub const RR_PROPERTY_RANDR_TILE = c"TILE";
pub const VisualGreenMaskMask = 32;
pub const PictOpConjointOutReverse = 40;
pub const XK_Arabic_jeh = 16778904;
pub const __warnattr = msg;
pub const __STD_TYPE = typedef;
pub const XK_Hangul_Sios = 3765;
pub const XK_braille_dots_367 = 16787556;
pub const _LP64 = 1;
pub const XK_braille_dots_35 = 16787476;
pub const XK_Cyrillic_u_straight = 16778415;
pub const __FLT_DIG__ = 6;
pub const RR_PROPERTY_CONNECTOR_TYPE = c"ConnectorType";
pub const XK_braille_dots_2467 = 16787562;
pub const XK_hyphen = 173;
pub const __UINT_LEAST16_FMTu__ = c"hu";
pub const XK_braille_dots_2456 = 16787514;
pub const X_RenderCompositeGlyphs8 = 23;
pub const X_RRGetProviders = 32;
pub const DestroyNotify = 17;
pub const PreferBlanking = 1;
pub const XK_Ecircumflexhook = 16785090;
pub const XK_Eabovedot = 972;
pub const XK_sacute = 438;
pub const XK_braille_dots_1345 = 16787485;
pub const BitmapOpenFailed = 1;
pub const __FLT16_MAX_10_EXP__ = 4;
pub const MappingSuccess = 0;
pub const XK_Armenian_but = 16778589;
pub const FilterNearest = c"nearest";
pub const XK_odoubleacute = 501;
pub const CPLastBit = 12;
pub const XK_Cyrillic_EF = 1766;
pub const XK_Armenian_pyur = 16778627;
pub const XK_Rcaron = 472;
pub const FilterBest = c"best";
pub const __UINT_FAST32_FMTX__ = c"X";
pub const XK_kana_NU = 1223;
pub const XValue = 1;
pub const XK_Cyrillic_zhe_descender = 16778391;
pub const XK_Armenian_NU = 16778566;
pub const XK_Sinh_oo2 = 16780765;
pub const XK_Thai_saraam = 3539;
pub const XK_zabovedot = 447;
pub const XK_Serbian_DJE = 1713;
pub const XK_NewSheqelSign = 16785578;
pub const XK_braille_dots_1258 = 16787603;
pub const XK_Ohornbelowdot = 16785122;
pub const XK_braille_dots_146 = 16787497;
pub const CoordModeOrigin = 0;
pub const XK_Armenian_tche = 16778611;
pub const XK_Eogonek = 458;
pub const XK_Arabic_semicolon = 1467;
pub const __INT32_TYPE__ = int;
pub const XK_Sinh_lu2 = 16780767;
pub const X_RRGetCrtcTransform = 27;
pub const XK_braille_dot_4 = 65524;
pub const XK_Sinh_luu = 16780688;
pub const XK_I = 73;
pub const XK_utilde = 1021;
pub const XK_braille_dots_1367 = 16787557;
pub const XK_AccessX_Enable = 65136;
pub const RENDER_MINOR = 11;
pub const XK_comma = 44;
pub const XK_foursubscript = 16785540;
pub const XK_ISO_Next_Group = 65032;
pub const XK_Pointer_DblClick_Dflt = 65262;
pub const __INT_LEAST8_FMTd__ = c"hhd";
pub const XK_Thai_soso = 3499;
pub const XK_braille_dots_3 = 16787460;
pub const XNStringConversion = c"stringConversion";
pub const XK_braille_dots_13468 = 16787629;
pub const XNMissingCharSet = c"missingCharSet";
pub const __LDBL_REDIR_DECL = name;
pub const XK_braille_dots_67 = 16787552;
pub const X_RRGetPanning = 28;
pub const XK_Pointer_Drag1 = 65269;
pub const SyncBoth = 7;
pub const XK_braille_dots_124 = 16787467;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const XK_braille_dots_1238 = 16787591;
pub const XK_Thai_maiek = 3560;
pub const XK_dead_A = 65153;
pub const NormalState = 1;
pub const XK_Georgian_we = 16781555;
pub const XK_Armenian_yentamna = 16778634;
pub const XK_hebrew_taw = 3322;
pub const X_RenderCompositeGlyphs16 = 24;
pub const XK_kana_NA = 1221;
pub const X_RenderTrapezoids = 10;
pub const __DBL_EPSILON__ = 0.000000;
pub const PictOpConjointDst = 34;
pub const XK_Armenian_nu = 16778614;
pub const GXcopy = 3;
pub const PictStandardRGB24 = 1;
pub const XK_Greek_ETA = 1991;
pub const XK_braille_dots_12367 = 16787559;
pub const XK_Sinh_jha = 16780707;
pub const PseudoColor = 3;
pub const __INT16_FMTi__ = c"hi";
pub const __UINT_FAST32_MAX__ = c_uint(4294967295);
pub const XK_Greek_gamma = 2019;
pub const XK_ISO_Set_Margin_Right = 65064;
pub const XK_Armenian_ke = 16778628;
pub const XK_R1 = 65490;
pub const _Xconst = @"const";
pub const XK_hebrew_samech = 3313;
pub const XK_Thai_lekchet = 3575;
pub const IncludeInferiors = 1;
pub const PropModeAppend = 2;
pub const XK_Scedilla = 426;
pub const NotifyVirtual = 1;
pub const XK_Cyrillic_YU = 1760;
pub const XK_Hangul_J_RieulMieum = 3805;
pub const XK_braille_dots_3568 = 16787636;
pub const XK_Arabic_rreh = 16778897;
pub const XK_Arabic_yeh = 1514;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XK_Armenian_VYUN = 16778578;
pub const XK_p = 112;
pub const XK_Wdiaeresis = 16785028;
pub const XK_Macedonia_KJE = 1724;
pub const XNOrientation = c"orientation";
pub const XK_Ocircumflex = 212;
pub const __UINT32_C_SUFFIX__ = U;
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = 2;
pub const XK_Pointer_DfltBtnPrev = 65276;
pub const XK_C_H = 65189;
pub const XK_macron = 175;
pub const XK_Arabic_heh_goal = 16778945;
pub const XK_onesuperior = 185;
pub const XK_kana_YO = 1238;
pub const __STDC_UTF_16__ = 1;
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const XK_ninesuperior = 16785529;
pub const XK_dead_u = 65160;
pub const XK_Insert = 65379;
pub const XK_Sinh_nya = 16780708;
pub const XNContextualDrawing = c"contextualDrawing";
pub const XCNOMEM = 1;
pub const XK_Armenian_DA = 16778548;
pub const XK_Hangul_J_Sios = 3814;
pub const XK_Cyrillic_ka_descender = 16778395;
pub const X_RenderFreeGlyphSet = 19;
pub const XK_Ohornacute = 16785114;
pub const XK_space = 32;
pub const XK_Armenian_MEN = 16778564;
pub const XK_Zen_Koho = 65341;
pub const XK_Cyrillic_YA = 1777;
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const XK_Ocircumflexbelowdot = 16785112;
pub const Button2 = 2;
pub const XK_F26 = 65495;
pub const XK_Greek_upsilonaccent = 1976;
pub const XK_acircumflex = 226;
pub const QueuedAlready = 0;
pub const XK_LiraSign = 16785572;
pub const XK_Yhook = 16785142;
pub const BadRROutput = 0;
pub const XK_Hangul_RieulTieut = 3758;
pub const XK_braille_dots_34 = 16787468;
pub const XK_Adiaeresis = 196;
pub const XK_Hangul_Cieuc = 3770;
pub const XK_braille_dots_1345678 = 16787709;
pub const XK_kana_yo = 1198;
pub const XK_braille_dots_1245678 = 16787707;
pub const XK_braille_dots_1346 = 16787501;
pub const XK_dead_i = 65156;
pub const XK_Kanji = 65313;
pub const X_RRSetCrtcConfig = 21;
pub const XK_Hangul_PieubSios = 3764;
pub const XK_Abrevegrave = 16785072;
pub const NotifyDetailNone = 7;
pub const XK_kana_TO = 1220;
pub const PictOpAdd = 12;
pub const XK_braille_dots_1357 = 16787541;
pub const PictOpIn = 5;
pub const XK_Armenian_TSO = 16778577;
pub const XK_braille_dots_178 = 16787649;
pub const XK_Begin = 65368;
pub const XK_Armenian_za = 16778598;
pub const XLookupKeySym = 3;
pub const YXBanded = 3;
pub const XK_braille_dots_23467 = 16787566;
pub const XK_Sinh_cha = 16780705;
pub const XK_Hangul_YeorinHieuh = 3829;
pub const XK_Abreve = 451;
pub const XK_Thai_saraue = 3542;
pub const __INT_FAST16_FMTd__ = c"hd";
pub const XK_braille_dot_3 = 65523;
pub const __UINT_LEAST32_FMTu__ = c"u";
pub const XNPreeditStateNotifyCallback = c"preeditStateNotifyCallback";
pub const XK_Pointer_DblClick3 = 65265;
pub const XK_H = 72;
pub const XK_Ocircumflextilde = 16785110;
pub const XK_Greek_theta = 2024;
pub const XK_hebrew_het = 3303;
pub const XK_braille_dots_57 = 16787536;
pub const __k8__ = 1;
pub const XK_uhook = 16785127;
pub const DefaultBlanking = 2;
pub const XK_Agrave = 192;
pub const __GNU_LIBRARY__ = 6;
pub const XK_Babovedot = 16784898;
pub const __FLT_MIN_10_EXP__ = -37;
pub const XK_ISO_Prev_Group = 65034;
pub const XK_Greek_epsilon = 2021;
pub const XK_Hangul_RieulPhieuf = 3759;
pub const XK_Armenian_ken = 16778607;
pub const XK_Greek_IOTAdiaeresis = 1957;
pub const XK_mabovedot = 16784961;
pub const XK_kana_HO = 1230;
pub const RR_PixelMultiplex = 2048;
pub const XIMStringConversionRightEdge = 2;
pub const XK_ecircumflexgrave = 16785089;
pub const XK_braille_dots_12357 = 16787543;
pub const BadPixmap = 4;
pub const RevertToParent = 2;
pub const XK_braille_dots_123 = 16787463;
pub const XK_Page_Down = 65366;
pub const XK_ISO_Level5_Latch = 65042;
pub const XK_yacute = 253;
pub const XK_ISO_Discontinuous_Underline = 65073;
pub const XK_braille_dots_48 = 16787592;
pub const XK_Thai_sorusi = 3529;
pub const __UINT_FAST8_FMTx__ = c"hhx";
pub const XK_Thai_ngongu = 3495;
pub const XK_F5 = 65474;
pub const XK_Greek_alpha = 2017;
pub const XK_Macedonia_GJE = 1714;
pub const __UINT16_FMTx__ = c"hx";
pub const XK_Abrevebelowdot = 16785078;
pub const __UINTPTR_FMTu__ = c"lu";
pub const XK_Thai_ru = 3524;
pub const XK_Hangul_J_RieulTieut = 3808;
pub const XK_ecircumflexhook = 16785091;
pub const __SYSCALL_WORDSIZE = 64;
pub const XK_s = 115;
pub const XK_Pointer_Left = 65248;
pub const __LONG_LONG_MAX__ = c_longlong(9223372036854775807);
pub const X_RenderQueryFilters = 29;
pub const XK_uacute = 250;
pub const XK_Georgian_rae = 16781536;
pub const XK_Hangul_SsangDikeud = 3752;
pub const XK_exclamdown = 161;
pub const XK_Hangul_Romaja = 65334;
pub const XK_Uhorntilde = 16785134;
pub const XK_Hangul_J_RieulPhieuf = 3809;
pub const XK_braille_dots_2367 = 16787558;
pub const PictOpDisjointAtop = 25;
pub const XK_Sinh_sha = 16780737;
pub const XK_braille_dots_578 = 16787664;
pub const XK_braille_dots_15678 = 16787697;
pub const X_RenderQueryPictIndexValues = 2;
pub const SouthEastGravity = 9;
pub const XK_Hangul_NieunHieuh = 3750;
pub const XK_itilde = 949;
pub const XK_Ubreve = 733;
pub const PictOpConjointXor = 43;
pub const XK_Armenian_YECH = 16778549;
pub const XK_kappa = 930;
pub const XK_hebrew_gimmel = 3298;
pub const XK_dead_small_schwa = 65162;
pub const VisualColormapSizeMask = 128;
pub const XK_guillemotright = 187;
pub const XK_F34 = 65503;
pub const RR_UnknownConnection = 2;
pub const __BIGGEST_ALIGNMENT__ = 16;
pub const XK_Lcaron = 421;
pub const __INT64_FMTd__ = c"ld";
pub const XK_kana_KE = 1209;
pub const XK_ucircumflex = 251;
pub const XK_braille_dots_26 = 16787490;
pub const XK_Acircumflextilde = 16785066;
pub const XNCursor = c"cursor";
pub const Button5 = 5;
pub const XK_F21 = 65490;
pub const XK_Hangul_SunkyeongeumPhieuf = 3828;
pub const XK_Abelowdot = 16785056;
pub const __MMX__ = 1;
pub const XK_KP_Equal = 65469;
pub const XK_braille_dots_37 = 16787524;
pub const FamilyDECnet = 1;
pub const XK_Hangul_End = 65331;
pub const X_RenderTriFan = 13;
pub const Mod3MapIndex = 5;
pub const XK_Cyrillic_schwa = 16778457;
pub const __USE_MISC = 1;
pub const __PTRDIFF_FMTd__ = c"ld";
pub const XK_ibelowdot = 16785099;
pub const XK_braille_dots_123467 = 16787567;
pub const X_RR1_0SetScreenConfig = 2;
pub const __UINT_LEAST64_FMTx__ = c"lx";
pub const XK_braille_dots_1347 = 16787533;
pub const XK_Thai_sarauee = 3543;
pub const XK_eacute = 233;
pub const XK_Arabic_hamzaonyeh = 1478;
pub const XK_Hangul_J_SsangSios = 3815;
pub const XK_abreveacute = 16785071;
pub const XK_Cyrillic_je = 1704;
pub const __NO_MATH_INLINES = 1;
pub const __WCHAR_TYPE__ = int;
pub const MappingModifier = 0;
pub const XK_kana_RU = 1241;
pub const RR_PROPERTY_SIGNAL_FORMAT = c"SignalFormat";
pub const XK_Arabic_jeem = 1484;
pub const XK_braille_dots_1356 = 16787509;
pub const XK_braille_dots_1256 = 16787507;
pub const XK_braille_dots_34678 = 16787692;
pub const __PTRDIFF_WIDTH__ = 64;
pub const XConverterNotFound = -3;
pub const XK_sterling = 163;
pub const XK_uhorntilde = 16785135;
pub const XK_ENG = 957;
pub const XK_braille_dot_2 = 65522;
pub const FillStippled = 2;
pub const XK_Pointer_DblClick2 = 65264;
pub const XK_K = 75;
pub const X_RenderCreatePicture = 4;
pub const XK_braille_dots_134568 = 16787645;
pub const XK_dead_breve = 65109;
pub const __USE_ATFILE = 1;
pub const XK_hebrew_finalpe = 3315;
pub const XK_braille_dots_56 = 16787504;
pub const XK_Georgian_chin = 16781545;
pub const XK_Arabic_teh = 1482;
pub const XK_Greek_iota = 2025;
pub const __FLT_DECIMAL_DIG__ = 9;
pub const __DBL_DIG__ = 15;
pub const XK_ihook = 16785097;
pub const XK_ae = 230;
pub const FilterConvolution = c"convolution";
pub const XK_sixsubscript = 16785542;
pub const XK_Hangul_SsangKiyeog = 3746;
pub const NorthWestGravity = 1;
pub const XK_braille_dots_12356 = 16787511;
pub const XYBitmap = 0;
pub const XK_Hangul_J_RieulSios = 3807;
pub const XK_Pointer_Drag3 = 65271;
pub const __UINT_LEAST16_FMTx__ = c"hx";
pub const XK_Thai_lekpaet = 3576;
pub const __VERSION__ = c"4.2.1 Compatible Clang 6.0.1 (tags/RELEASE_601/final)";
pub const XK_Cancel = 65385;
pub const XK_Byelorussian_shortu = 1710;
pub const __UINT_LEAST64_FMTo__ = c"lo";
pub const XK_Cyrillic_JE = 1720;
pub const GXnoop = 5;
pub const XK_braille_dots_23678 = 16787686;
pub const XK_Down = 65364;
pub const XK_Hangul_Start = 65330;
pub const XK_Greek_THETA = 1992;
pub const XK_Hangul_Special = 65343;
pub const XK_Thai_dodek = 3508;
pub const __UINT16_MAX__ = 65535;
pub const XK_Armenian_VEV = 16778574;
pub const PictOpDisjointSrc = 17;
pub const XK_dollar = 36;
pub const __PTHREAD_RWLOCK_INT_FLAGS_SHARED = 1;
pub const __SIZEOF_WINT_T__ = 4;
pub const XK_Sinh_o = 16780692;
pub const XK_F4 = 65473;
pub const XK_Georgian_vin = 16781525;
pub const __WINT_UNSIGNED__ = 1;
pub const XK_R3 = 65492;
pub const ScreenSaverReset = 0;
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
pub const X_RRGetScreenSizeRange = 6;
pub const XK_SingleCandidate = 65340;
pub const XK_Cyrillic_CHE_descender = 16778422;
pub const XK_braille_dots_12378 = 16787655;
pub const XK_Cyrillic_VE = 1783;
pub const XK_r = 114;
pub const XK_1 = 49;
pub const XK_Greek_ZETA = 1990;
pub const RR_PROPERTY_SIGNAL_PROPERTIES = c"SignalProperties";
pub const XNGeometryCallback = c"geometryCallback";
pub const XK_OE = 5052;
pub const X_RRSetPanning = 29;
pub const XK_Ukrainian_I = 1718;
pub const __INT_FAST32_MAX__ = 2147483647;
pub const MotionNotify = 6;
pub const PictOpSrc = 1;
pub const XK_question = 63;
pub const XK_braille_dots_348 = 16787596;
pub const XK_dabovedot = 16784907;
pub const XK_Thai_saraaimaimalai = 3556;
pub const X_RenderSetPictureClipRectangles = 6;
pub const XK_ocircumflexhook = 16785109;
pub const XK_Greek_OMEGA = 2009;
pub const LSBFirst = 0;
pub const XK_greater = 62;
pub const _BITS_BYTESWAP_H = 1;
pub const XK_braille_dots_18 = 16787585;
pub const XK_Ibreve = 16777516;
pub const XK_KP_Left = 65430;
pub const XK_Pointer_Button3 = 65259;
pub const __PRAGMA_REDEFINE_EXTNAME = 1;
pub const XK_Hangul_O = 3783;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const XK_Armenian_KHE = 16778557;
pub const XK_F35 = 65504;
pub const XK_Cyrillic_ef = 1734;
pub const XK_kana_ME = 1234;
pub const XK_period = 46;
pub const XK_KP_Down = 65433;
pub const XK_Hangul_Mieum = 3761;
pub const XK_Scircumflex = 734;
pub const __UINT_FAST64_FMTu__ = c"lu";
pub const XK_Sinh_ri = 16780685;
pub const XNForeground = c"foreground";
pub const __INT_FAST16_TYPE__ = short;
pub const XK_Armenian_PE = 16778570;
pub const XNQueryOrientation = c"queryOrientation";
pub const XK_braille_dots_27 = 16787522;
pub const XK_Sinh_lu = 16780687;
pub const X_RRDestroyMode = 17;
pub const BadPictFormat = 0;
pub const SelectionClear = 29;
pub const XK_Greek_OMICRONaccent = 1959;
pub const GXcopyInverted = 12;
pub const XK_NairaSign = 16785574;
pub const XK_Georgian_can = 16781546;
pub const Button4 = 4;
pub const XK_F20 = 65489;
pub const XK_braille_dots_24678 = 16787690;
pub const __LDBL_DECIMAL_DIG__ = 21;
pub const XK_End = 65367;
pub const XK_kana_conjunctive = 1189;
pub const XK_braille_dots_368 = 16787620;
pub const PictOpConjointOver = 35;
pub const XK_braille_dots_36 = 16787492;
pub const __SIZEOF_FLOAT128__ = 16;
pub const XK_First_Virtual_Screen = 65232;
pub const XK_Greek_sigma = 2034;
pub const RANDR_MAJOR = 1;
pub const XK_Thai_lekhok = 3574;
pub const XK_Sinh_va = 16780736;
pub const XK_Henkan = 65315;
pub const RR_Connected = 0;
pub const XK_Massyo = 65324;
pub const XK_abreve = 483;
pub const __SLONG32_TYPE = int;
pub const _DEBUG = 1;
pub const XK_Sinh_uu2 = 16780758;
pub const GrabNotViewable = 3;
pub const XK_kana_switch = 65406;
pub const CirculateNotify = 26;
pub const Status = int;
pub const XK_ntilde = 241;
pub const XK_KP_End = 65436;
pub const XK_hebrew_nun = 3312;
pub const PictOpLighten = 52;
pub const XK_Greek_IOTAdieresis = 1957;
pub const XK_agrave = 224;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const DontAllowExposures = 0;
pub const XK_Cyrillic_U = 1781;
pub const XK_Armenian_pe = 16778618;
pub const XK_braille_dots_12345678 = 16787711;
pub const XK_braille_dots_1234678 = 16787695;
pub const XK_Greek_OMICRON = 1999;
pub const XK_Arabic_lam = 1508;
pub const XK_braille_dots_1257 = 16787539;
pub const XK_Sinh_la = 16780733;
pub const XIMStatusNothing = c_long(1024);
pub const X_RRCreateMode = 16;
pub const PictOpHSLHue = 59;
pub const XIMStringConversionBuffer = 1;
pub const XK_Cyrillic_KA_descender = 16778394;
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = 2;
pub const XK_Armenian_KE = 16778580;
pub const XK_braille_dot_1 = 65521;
pub const XK_kana_tsu = 1199;
pub const XK_Cyrillic_yu = 1728;
pub const BadRRProvider = 3;
pub const XK_J = 74;
pub const XK_Arabic_damma = 1519;
pub const X_RenderCreateGlyphSet = 17;
pub const AutoRepeatModeOff = 0;
pub const __UINT_LEAST32_FMTo__ = c"o";
pub const __FLT_MIN_EXP__ = -125;
pub const XK_Kanji_Bangou = 65335;
pub const __UINT_LEAST64_FMTu__ = c"lu";
pub const XK_ISO_Continuous_Underline = 65072;
pub const XK_Arabic_heh_doachashmee = 16778942;
pub const __INT_FAST64_FMTd__ = c"ld";
pub const MappingPointer = 2;
pub const RR_Disconnected = 1;
pub const XK_dead_iota = 65117;
pub const NotifyNonlinearVirtual = 4;
pub const XK_Armenian_GHAT = 16778562;
pub const XK_Hangul_Tieut = 3772;
pub const XK_dead_belowring = 65127;
pub const XK_caron = 439;
pub const XK_Sinh_e2 = 16780761;
pub const XK_Thai_lakkhangyao = 3557;
pub const __UINT_LEAST8_FMTx__ = c"hhx";
pub const XK_Pointer_Drag2 = 65270;
pub const XK_Armenian_full_stop = 16778633;
pub const X_PROTOCOL_REVISION = 0;
pub const XK_hebrew_pe = 3316;
pub const XK_braille_dots_156 = 16787505;
pub const XK_Hangul_AraeAE = 3831;
pub const XK_Num_Lock = 65407;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XK_Thai_sosala = 3528;
pub const __DBL_DENORM_MIN__ = 0.000000;
pub const XK_dead_capital_schwa = 65163;
pub const MapRequest = 20;
pub const XK_braille_dots_3458 = 16787612;
pub const XK_F7 = 65476;
pub const XK_Thai_maitri = 3562;
pub const SyncPointer = 1;
pub const __BIG_ENDIAN = 4321;
pub const XK_R2 = 65491;
pub const __LDBL_HAS_DENORM__ = 1;
pub const XK_ubelowdot = 16785125;
pub const XNPreeditAttributes = c"preeditAttributes";
pub const XK_Ocaron = 16777681;
pub const XK_ISO_Left_Tab = 65056;
pub const XK_Cyrillic_ya = 1745;
pub const PictOpDisjointIn = 21;
pub const XK_u = 117;
pub const PictOpDisjointOutReverse = 24;
pub const NorthGravity = 2;
pub const XK_0 = 48;
pub const XK_tintegral = 16785965;
pub const XK_Up = 65362;
pub const XK_Acircumflexgrave = 16785062;
pub const XK_Armenian_shesht = 16778587;
pub const XK_Serbian_je = 1704;
pub const Mod2MapIndex = 4;
pub const __SIZE_FMTu__ = c"lu";
pub const XK_kana_o = 1195;
pub const XK_Select = 65376;
pub const XK_Super_L = 65515;
pub const XK_Odiaeresis = 214;
pub const CirculateRequest = 27;
pub const XK_Armenian_O = 16778581;
pub const PropModeReplace = 0;
pub const XK_Greek_omicron = 2031;
pub const XK_Thai_fofan = 3519;
pub const XK_Cyrillic_dzhe = 1711;
pub const XK_Hangul_Rieul = 3753;
pub const XK_Pointer_Button2 = 65258;
pub const HostInsert = 0;
pub const XK_slash = 47;
pub const XK_ISO_Fast_Cursor_Up = 65070;
pub const PictOpDisjointOverReverse = 20;
pub const XK_Ukrainian_GHE_WITH_UPTURN = 1725;
pub const XK_braille_dots_24 = 16787466;
pub const XK_udoubleacute = 507;
pub const __x86_64__ = 1;
pub const _SYS_SELECT_H = 1;
pub const _SYS_TYPES_H = 1;
pub const XK_F23 = 65492;
pub const XK_Armenian_RE = 16778576;
pub const XK_Cyrillic_GHE_bar = 16778386;
pub const XK_dead_belowbreve = 65131;
pub const XK_Armenian_ho = 16778608;
pub const __LDBL_MIN_10_EXP__ = -4931;
pub const __ORDER_BIG_ENDIAN__ = 4321;
pub const XK_a = 97;
pub const RR_Rotate_270 = 8;
pub const XK_Thai_loling = 3525;
pub const XK_Cyrillic_KA = 1771;
pub const XK_abrevebelowdot = 16785079;
pub const XK_Ihook = 16785096;
pub const RepeatNormal = 1;
pub const __SIZEOF_INT128__ = 16;
pub const XK_kana_SU = 1213;
pub const XK_Linefeed = 65290;
pub const XK_Rcedilla = 931;
pub const XK_c_h = 65187;
pub const XK_Armenian_sha = 16778615;
pub const AlreadyGrabbed = 1;
pub const __glibc_c99_flexarr_available = 1;
pub const __linux = 1;
pub const XK_kcedilla = 1011;
pub const XK_braille_dots_1267 = 16787555;
pub const XK_schwa = 16777817;
pub const __sigset_t_defined = 1;
pub const XK_Eacute = 201;
pub const XK_Acircumflexhook = 16785064;
pub const QueuedAfterReading = 1;
pub const XK_Hangul_KkogjiDalrinIeung = 3827;
pub const __clang__ = 1;
pub const XK_Hangul_Banja = 65337;
pub const __LDBL_DIG__ = 18;
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const XK_Thai_hohip = 3531;
pub const PictOpColorBurn = 54;
pub const XK_Sinh_fa = 16780742;
pub const XK_Thai_leksam = 3571;
pub const XK_Romaji = 65316;
pub const BadPicture = 1;
pub const IsViewable = 2;
pub const XK_L7 = 65486;
pub const _ENDIAN_H = 1;
pub const XK_Ycircumflex = 16777590;
pub const XNQueryICValuesList = c"queryICValuesList";
pub const XK_braille_dots_23468 = 16787630;
pub const StaticGray = 0;
pub const __WORDSIZE = 64;
pub const XK_Armenian_gim = 16778595;
pub const XK_Farsi_3 = 16778995;
pub const XK_Cyrillic_sha = 1755;
pub const XK_Gcircumflex = 728;
pub const XK_Cyrillic_shcha = 1757;
pub const XK_M = 77;
pub const XK_omacron = 1010;
pub const XK_Greek_iotaaccentdieresis = 1974;
pub const XK_braille_dots_12578 = 16787667;
pub const __FLT_HAS_DENORM__ = 1;
pub const XK_ccircumflex = 742;
pub const XK_EuroSign = 8364;
pub const LastExtensionError = 255;
pub const Unsorted = 0;
pub const __FINITE_MATH_ONLY__ = 0;
pub const XK_yhook = 16785143;
pub const __INT_LEAST32_FMTi__ = c"i";
pub const XK_quoteleft = 96;
pub const RR_Rotate_0 = 1;
pub const XK_notapproxeq = 16785991;
pub const XK_Lacute = 453;
pub const __LDBL_EPSILON__ = 0.000000;
pub const XK_braille_dots_234568 = 16787646;
pub const __STDC_UTF_32__ = 1;
pub const XK_Arabic_yeh_baree = 16778962;
pub const XK_uogonek = 1017;
pub const XK_Pointer_Drag5 = 65277;
pub const XK_Thai_thophuthao = 3506;
pub const XK_CruzeiroSign = 16785570;
pub const XK_eth = 240;
pub const FamilyInternet = 0;
pub const XK_ISO_Level2_Latch = 65026;
pub const XK_braille_dots_157 = 16787537;
pub const __SIZEOF_DOUBLE__ = 8;
pub const XK_kana_NE = 1224;
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = 2;
pub const XK_Cyrillic_i_macron = 16778467;
pub const XK_Sinh_i2 = 16780754;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const XK_minus = 45;
pub const __SIZE_FMTX__ = c"lX";
pub const GravityNotify = 24;
pub const XK_Armenian_amanak = 16778588;
pub const XK_Cyrillic_o = 1743;
pub const XK_braceleft = 123;
pub const XK_Georgian_zen = 16781526;
pub const _BITS_TYPES_H = 1;
pub const XK_Sinh_i = 16780681;
pub const XK_F6 = 65475;
pub const XK_Arabic_alef = 1479;
pub const XK_R5 = 65494;
pub const XK_Armenian_cha = 16778617;
pub const PictOpXor = 11;
pub const XK_ugrave = 249;
pub const __PID_T_TYPE = __S32_TYPE;
pub const RR_VSyncPositive = 4;
pub const XK_ISO_First_Group_Lock = 65037;
pub const XCNOENT = 2;
pub const XK_emptyset = 16785925;
pub const XK_grave = 96;
pub const SubPixelHorizontalRGB = 1;
pub const XK_t = 116;
pub const XK_Abrevehook = 16785074;
pub const XK_3 = 51;
pub const XK_Arabic_keheh = 16778921;
pub const XK_hebrew_qoph = 3319;
pub const XlibSpecificationRelease = 6;
pub const MappingNotify = 34;
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = 2;
pub const XK_braille_dots_245678 = 16787706;
pub const RR_PROPERTY_BACKLIGHT = c"Backlight";
pub const XK_Byelorussian_SHORTU = 1726;
pub const XK_Sinh_ddha = 16780714;
pub const XK_Greek_epsilonaccent = 1970;
pub const XK_dead_belowverticalline = 65170;
pub const XK_braille_dots_2345678 = 16787710;
pub const XNResetState = c"resetState";
pub const XK_Ohorn = 16777632;
pub const X_RRConfigureProviderProperty = 38;
pub const FontLeftToRight = 0;
pub const XK_hebrew_zayin = 3302;
pub const XK_Hangul_YI = 3794;
pub const XK_dead_lowline = 65168;
pub const XK_Arabic_ghain = 1498;
pub const XK_AudibleBell_Enable = 65146;
pub const XK_copyright = 169;
pub const AutoRepeatModeDefault = 2;
pub const __SCHAR_MAX__ = 127;
pub const __USE_POSIX2 = 1;
pub const XK_braceright = 125;
pub const XK_Overlay2_Enable = 65145;
pub const XK_ISO_First_Group = 65036;
pub const X_RRGetOutputProperty = 15;
pub const PictOpSoftLight = 56;
pub const XK_Hyper_L = 65517;
pub const LockMapIndex = 1;
pub const __ELF__ = 1;
pub const XK_Pointer_Button1 = 65257;
pub const __LDBL_MANT_DIG__ = 64;
pub const XK_Hangul_PostHanja = 65339;
pub const XK_Ecircumflextilde = 16785092;
pub const XNBackground = c"background";
pub const XK_braille_dots_12458 = 16787611;
pub const XK_Redo = 65382;
pub const XK_apostrophe = 39;
pub const LowerHighest = 1;
pub const XK_threequarters = 190;
pub const __UINT64_FMTX__ = c"lX";
pub const NotifyAncestor = 0;
pub const XK_atilde = 227;
pub const XK_Greek_NU = 1997;
pub const XK_braille_dots_25 = 16787474;
pub const XK_Find = 65384;
pub const PictOpDisjointAtopReverse = 26;
pub const XK_Arabic_kasra = 1520;
pub const XK_Armenian_BEN = 16778546;
pub const XK_F22 = 65491;
pub const PictOpInReverse = 6;
pub const Mod5MapIndex = 7;
pub const XK_sixsuperior = 16785526;
pub const __SSE__ = 1;
pub const XK_Armenian_TO = 16778553;
pub const XK_braille_dots_1456 = 16787513;
pub const XK_Armenian_INI = 16778555;
pub const XK_braille_dots_124578 = 16787675;
pub const __UINTPTR_MAX__ = c_ulong(18446744073709551615);
pub const X_RRConfigureOutputProperty = 12;
pub const __UINT_LEAST8_FMTu__ = c"hhu";
pub const XK_Abrevetilde = 16785076;
pub const XNResourceName = c"resourceName";
pub const XK_Georgian_las = 16781530;
pub const PictOpMinimum = 0;
pub const __SIZEOF_WCHAR_T__ = 4;
pub const __LDBL_MAX__ = inf;
pub const XK_Pointer_DownLeft = 65254;
pub const Mod4MapIndex = 6;
pub const linux = 1;
pub const XK_hebrew_aleph = 3296;
pub const XK_braille_dots_12478 = 16787659;
pub const XK_ccaron = 488;
pub const XK_KP_9 = 65465;
pub const XK_dead_e = 65154;
pub const __UINTPTR_FMTX__ = c"lX";
pub const XK_Greek_iotaaccent = 1972;
pub const XK_Armenian_apostrophe = 16778586;
pub const XK_Arabic_hamzaonalef = 1475;
pub const XK_Arabic_noon = 1510;
pub const XK_kana_closingbracket = 1187;
pub const GCLastBit = 22;
pub const XK_Sinh_na = 16780721;
pub const RRSetConfigFailed = 3;
pub const XK_braille_dots_268 = 16787618;
pub const PictOpScreen = 49;
pub const RRNotify_OutputChange = 1;
pub const XK_Greek_ETAaccent = 1955;
pub const XK_MillSign = 16785573;
pub const XK_L6 = 65485;
pub const X_RRGetCrtcGamma = 23;
pub const XK_Armenian_AT = 16778552;
pub const XK_Armenian_tyun = 16778623;
pub const _POSIX_SOURCE = 1;
pub const XK_EZH = 16777655;
pub const VisualNoMask = 0;
pub const XK_Sinh_ja = 16780706;
pub const XK_Greek_lambda = 2027;
pub const XK_Farsi_2 = 16778994;
pub const XK_Arabic_zah = 1496;
pub const XK_Armenian_to = 16778601;
pub const GXandReverse = 2;
pub const XK_Thai_nikhahit = 3565;
pub const XK_L = 76;
pub const XK_Hangul_Jamo = 65333;
pub const XK_Ecircumflexgrave = 16785088;
pub const __GCC_ATOMIC_INT_LOCK_FREE = 2;
pub const XK_dstroke = 496;
pub const XK_Arabic_question_mark = 1471;
pub const _BITS_STDINT_INTN_H = 1;
pub const XK_Cyrillic_ve = 1751;
pub const XK_braille_dots_678 = 16787680;
pub const XIMPreeditCallbacks = c_long(2);
pub const X_RRDeleteMonitor = 44;
pub const XK_kana_E = 1204;
pub const XK_abelowdot = 16785057;
pub const LineSolid = 0;
pub const XK_RupeeSign = 16785576;
pub const __FLT_MIN__ = 0.000000;
pub const XNStatusStartCallback = c"statusStartCallback";
pub const XK_Thai_leknung = 3569;
pub const RR_HSyncNegative = 2;
pub const XK_Pointer_Drag4 = 65272;
pub const XK_ograve = 242;
pub const __UINT_LEAST32_FMTX__ = c"X";
pub const XK_Armenian_yech = 16778597;
pub const NoExpose = 14;
pub const __UINT_FAST16_FMTo__ = c"ho";
pub const XK_dead_belowtilde = 65130;
pub const XK_Cyrillic_yeru = 1753;
pub const XK_braille_dots_13478 = 16787661;
pub const XK_Next_Virtual_Screen = 65234;
pub const XK_Armenian_at = 16778600;
pub const FilterAliasNone = -1;
pub const XK_Hangul_WA = 3784;
pub const __SIZE_FMTx__ = c"lx";
pub const XK_F1 = 65470;
pub const XK_braille_dots_1678 = 16787681;
pub const BadWindow = 3;
pub const XK_Cyrillic_HA = 1768;
pub const XK_R4 = 65493;
pub const XK_Control_R = 65508;
pub const XK_lcaron = 437;
pub const XK_Greek_LAMBDA = 1995;
pub const XK_F18 = 65487;
pub const XK_Scaron = 425;
pub const X_RRSetMonitor = 43;
pub const GXorInverted = 13;
pub const False = 0;
pub const XK_lcedilla = 950;
pub const RepeatReflect = 3;
pub const XK_w = 119;
pub const XK_Armenian_zhe = 16778602;
pub const XK_ocircumflexacute = 16785105;
pub const NFDBITS = __NFDBITS;
pub const XK_2 = 50;
pub const XK_EcuSign = 16785568;
pub const XNInputStyle = c"inputStyle";
pub const __llvm__ = 1;
pub const BottomIf = 3;
pub const XK_ocircumflextilde = 16785111;
pub const XK_braille_dot_10 = 65530;
pub const __UINT_FAST64_MAX__ = c_ulong(18446744073709551615);
pub const PropertyNotify = 28;
pub const X_RenderCreateSolidFill = 33;
pub const XK_kana_i = 1192;
pub const ClientMessage = 33;
pub const XK_braille_dots_3578 = 16787668;
pub const BadAtom = 5;
pub const XK_kana_SO = 1215;
pub const XK_Hangul_Kiyeog = 3745;
pub const XK_Hangul_RieulSios = 3757;
pub const X_RenderAddTraps = 32;
pub const __PTHREAD_MUTEX_NUSERS_AFTER_KIND = 0;
pub const RR_Rotate_180 = 4;
pub const XK_Greek_pi = 2032;
pub const __INT32_MAX__ = 2147483647;
pub const XK_Execute = 65378;
pub const XK_braille_dots_24578 = 16787674;
pub const XK_hebrew_shin = 3321;
pub const XK_braille_dots_2358 = 16787606;
pub const __UINT_LEAST32_MAX__ = c_uint(4294967295);
pub const XK_tabovedot = 16785003;
pub const XK_Armenian_verjaket = 16778633;
pub const __SIZEOF_PTHREAD_BARRIER_T = 32;
pub const XK_idiaeresis = 239;
pub const XK_Armenian_tsa = 16778606;
pub const ReplayPointer = 2;
pub const LineOnOffDash = 1;
pub const X_RRDeleteOutputMode = 19;
pub const TileShape = 1;
pub const XK_currency = 164;
pub const Nonconvex = 1;
pub const XK_KP_Page_Down = 65435;
pub const __INT_FAST8_MAX__ = 127;
pub const StaticGravity = 10;
pub const XK_c = 99;
pub const XK_Sinh_ii2 = 16780755;
pub const XK_braille_dots_1457 = 16787545;
pub const XK_Greek_IOTA = 1993;
pub const __INTPTR_MAX__ = c_long(9223372036854775807);
pub const XK_braille_dots_123678 = 16787687;
pub const Below = 1;
pub const XK_Greek_omicronaccent = 1975;
pub const __INTMAX_FMTi__ = c"li";
pub const XK_Super_R = 65516;
pub const XK_KP_8 = 65464;
pub const XK_Greek_PI = 2000;
pub const XK_Greek_BETA = 1986;
pub const XK_Armenian_DZA = 16778561;
pub const Expose = 12;
pub const __FLT16_MIN_10_EXP__ = -13;
pub const XK_Cyrillic_EL = 1772;
pub const XK_KP_Delete = 65439;
pub const XK_Greek_switch = 65406;
pub const XK_Sinh_nna = 16780715;
pub const XK_braille_dots_34568 = 16787644;
pub const XK_Hangul_J_PanSios = 3832;
pub const XK_periodcentered = 183;
pub const XK_kana_KU = 1208;
pub const XK_Georgian_nar = 16781532;
pub const XK_L5 = 65484;
pub const PictStandardNUM = 5;
pub const __ATOMIC_SEQ_CST = 5;
pub const XK_ecaron = 492;
pub const XK_Georgian_cil = 16781548;
pub const NotifyInferior = 2;
pub const XK_Thai_leksong = 3570;
pub const X_RenderSetPictureTransform = 28;
pub const XK_ISO_Center_Object = 65075;
pub const XK_Sinh_nja = 16780710;
pub const XK_braille_dots_134678 = 16787693;
pub const XK_Farsi_1 = 16778993;
pub const __SIZEOF_LONG_LONG__ = 8;
pub const XK_ISO_Release_Both_Margins = 65067;
pub const __GNUC_STDC_INLINE__ = 1;
pub const RRNotify_ResourceChange = 5;
pub const __UINT8_MAX__ = 255;
pub const XK_Shift_R = 65506;
pub const XK_O = 79;
pub const XNPreeditDoneCallback = c"preeditDoneCallback";
pub const XK_braille_dots_168 = 16787617;
pub const __UINT16_FMTo__ = c"ho";
pub const __OPENCL_MEMORY_SCOPE_DEVICE = 2;
pub const XK_ISO_Partial_Space_Left = 65061;
pub const XK_acircumflexacute = 16785061;
pub const XK_twosubscript = 16785538;
pub const XK_Hangul_AE = 3776;
pub const FillSolid = 0;
pub const XK_Thai_topatak = 3503;
pub const PictOpSaturate = 13;
pub const __FLT_MAX__ = 340282346999999984391321947108527833088.000000;
pub const XK_Armenian_e = 16778599;
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const XK_braille_dots_468 = 16787624;
pub const XK_Codeinput = 65335;
pub const XK_Georgian_khar = 16781541;
pub const XK_dead_belowmacron = 65128;
pub const XK_braille_dots_23568 = 16787638;
pub const JoinBevel = 2;
pub const XLookupBoth = 4;
pub const __UINTPTR_FMTx__ = c"lx";
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1;
pub const XK_abrevehook = 16785075;
pub const XK_Tcedilla = 478;
pub const __attribute_alloc_size__ = params;
pub const XK_ohornacute = 16785115;
pub const XK_kana_RE = 1242;
pub const __INT_LEAST8_MAX__ = 127;
pub const XK_Cyrillic_a = 1729;
pub const DontPreferBlanking = 0;
pub const PictOpConjointIn = 37;
pub const XK_Cyrillic_LJE = 1721;
pub const XK_braille_dots_25678 = 16787698;
pub const XK_Cyrillic_ha_descender = 16778419;
pub const CapRound = 2;
pub const XK_braille_dots_148 = 16787593;
pub const XK_Macedonia_gje = 1698;
pub const XK_Armenian_GIM = 16778547;
pub const XK_Cyrillic_U_straight_bar = 16778416;
pub const XK_R7 = 65496;
pub const XK_F19 = 65488;
pub const XK_section = 167;
pub const XK_Thai_choching = 3497;
pub const XK_Serbian_LJE = 1721;
pub const XK_gcaron = 16777703;
pub const XK_Sinh_sa = 16780739;
pub const AutoRepeatModeOn = 1;
pub const XK_braille_dots_1235678 = 16787703;
pub const XK_v = 118;
pub const PictOpBlendMaximum = 62;
pub const XK_icircumflex = 238;
pub const XK_because = 16785973;
pub const XK_braille_dots_13678 = 16787685;
pub const XK_5 = 53;
pub const __UINT_FAST32_FMTo__ = c"o";
pub const XK_cabovedot = 741;
pub const XK_uhornhook = 16785133;
pub const __LP64__ = 1;
pub const XK_Armenian_SHA = 16778567;
pub const LASTEvent = 36;
pub const _BITS_PTHREADTYPES_ARCH_H = 1;
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const XK_Cyrillic_NJE = 1722;
pub const GXxor = 6;
pub const XK_Arabic_veh = 16778916;
pub const XK_Ukranian_i = 1702;
pub const XK_Arabic_tah = 1495;
pub const XK_kana_YU = 1237;
pub const XK_braille_dots_12678 = 16787683;
pub const PolyModePrecise = 0;
pub const XK_dead_belowcircumflex = 65129;
pub const XK_Hangul_PreHanja = 65338;
pub const __INO_T_MATCHES_INO64_T = 1;
pub const TopIf = 2;
pub const XK_Tcaron = 427;
pub const __UINT_LEAST32_FMTx__ = c"x";
pub const AsyncPointer = 0;
pub const VisibilityPartiallyObscured = 1;
pub const XK_doubleacute = 445;
pub const XK_zerosuperior = 16785520;
pub const BadRequest = 1;
pub const XK_Ehook = 16785082;
pub const XK_braille_dots_78 = 16787648;
pub const XK_acircumflextilde = 16785067;
pub const XK_Sinh_al = 16780746;
pub const XNStatusDoneCallback = c"statusDoneCallback";
pub const XK_Thai_moma = 3521;
pub const XK_kra = 930;
pub const XK_Emacron = 938;
pub const XK_Sinh_dda = 16780713;
pub const __STDC_VERSION__ = c_long(201112);
pub const XK_dead_grave = 65104;
pub const __INT_LEAST8_FMTi__ = c"hhi";
pub const XNFilterEvents = c"filterEvents";
pub const XK_b = 98;
pub const XK_multiply = 215;
pub const __INT_LEAST16_FMTi__ = c"hi";
pub const XK_umacron = 1022;
pub const XK_Menu = 65383;
pub const XK_Thai_leksi = 3572;
pub const XK_braille_dots_5678 = 16787696;
pub const XK_braille_dots_123468 = 16787631;
pub const _THREAD_SHARED_TYPES_H = 1;
pub const XK_quoteright = 39;
pub const XK_gcircumflex = 760;
pub const XK_kana_yu = 1197;
pub const XK_Arabic_hamza_above = 16778836;
pub const XIMReverse = c_long(1);
pub const NotifyHint = 1;
pub const XK_Hangul_J_Phieuf = 3821;
pub const XK_KP_7 = 65463;
pub const XK_KP_Prior = 65434;
pub const __SIZEOF_PTHREAD_ATTR_T = 56;
pub const Complex = 0;
pub const MapNotify = 19;
pub const __FLT_EVAL_METHOD__ = 0;
pub const __SSE_MATH__ = 1;
pub const XK_Cyrillic_EM = 1773;
pub const __UINT_FAST8_FMTo__ = c"hho";
pub const XK_sevensubscript = 16785543;
pub const X_RRGetScreenInfo = 5;
pub const __INT8_MAX__ = 127;
pub const XK_plusminus = 177;
pub const XK_Cyrillic_I = 1769;
pub const X_RRGetOutputPrimary = 31;
pub const __DBL_DECIMAL_DIG__ = 17;
pub const XK_Georgian_kan = 16781529;
pub const ConfigureRequest = 23;
pub const XK_Uring = 473;
pub const XK_Hangul_KiyeogSios = 3747;
pub const XK_L4 = 65483;
pub const PictOpConjointSrc = 33;
pub const XK_Armenian_TCHE = 16778563;
pub const _SYS_CDEFS_H = 1;
pub const __LDBL_MAX_EXP__ = 16384;
pub const XK_ISO_Fast_Cursor_Left = 65068;
pub const __LONG_MAX__ = c_long(9223372036854775807);
pub const XLookupChars = 2;
pub const XK_Armenian_fe = 16778630;
pub const XK_fabovedot = 16784927;
pub const XK_Farsi_0 = 16778992;
pub const XIMInitialState = c_long(1);
pub const XK_Greek_zeta = 2022;
pub const XK_Greek_upsilonaccentdieresis = 1978;
pub const XK_N = 78;
pub const XK_thorn = 254;
pub const __LDBL_DENORM_MIN__ = 0.000000;
pub const XK_braille_dots_14578 = 16787673;
pub const XK_Gcaron = 16777702;
pub const XK_ch = 65184;
pub const XK_dead_ogonek = 65116;
pub const XK_Georgian_en = 16781524;
pub const XK_Ccedilla = 199;
pub const XK_Sinh_ee2 = 16780762;
pub const DestroyAll = 0;
pub const ReplayKeyboard = 5;
pub const GXequiv = 9;
pub const XK_kana_HI = 1227;
pub const XK_gabovedot = 757;
pub const XK_braille_dots_1348 = 16787597;
pub const __ATOMIC_ACQUIRE = 2;
pub const __FLT16_HAS_DENORM__ = 1;
pub const XK_Mode_switch = 65406;
pub const XK_KP_Home = 65429;
pub const XK_parenleft = 40;
pub const __UINT_FAST8_FMTX__ = c"hhX";
pub const PolyEdgeSmooth = 1;
pub const X_RRListProviderProperties = 36;
pub const XK_Thai_maihanakat_maitho = 3550;
pub const XK_ISO_Move_Line_Down = 65058;
pub const XK_braille_dots_2678 = 16787682;
pub const ReleaseByFreeingColormap = if (@typeId(@typeOf(c_long(1))) == @import("builtin").TypeId.Pointer) @ptrCast(XID, c_long(1)) else if (@typeId(@typeOf(c_long(1))) == @import("builtin").TypeId.Int) @intToPtr(XID, c_long(1)) else XID(c_long(1));
pub const __UINT_FAST16_FMTX__ = c"hX";
pub const PictStandardA8 = 2;
pub const __UINT_FAST32_FMTx__ = c"x";
pub const StippleShape = 2;
pub const XK_ISO_Last_Group_Lock = 65039;
pub const XK_Sinh_ng2 = 16780702;
pub const XK_ISO_Release_Margin_Left = 65065;
pub const XK_F3 = 65472;
pub const XK_R6 = 65495;
pub const XK_Greek_nu = 2029;
pub const __GLIBC_USE_DEPRECATED_GETS = 0;
pub const __x86_64 = 1;
pub const XK_braille_dots_3678 = 16787684;
pub const XK_Lcedilla = 934;
pub const XK_Thai_lekkao = 3577;
pub const __UINTMAX_FMTo__ = c"lo";
pub const XK_y = 121;
pub const XK_CH = 65186;
pub const XK_Arabic_sheen = 1492;
pub const XK_Sinh_luu2 = 16780787;
pub const XK_4 = 52;
pub const XK_dead_invertedbreve = 65133;
pub const X_RenderColorTrapezoids = 14;
pub const XK_Sinh_ga = 16780700;
pub const XK_Hangul_SsangPieub = 3763;
pub const XK_Wgrave = 16785024;
pub const XK_dead_cedilla = 65115;
pub const XK_masculine = 186;
pub const ButtonPress = 4;
pub const XK_Armenian_hyphen = 16778634;
pub const XK_Kana_Shift = 65326;
pub const XK_Sinh_pha = 16780725;
pub const XK_Sinh_ca = 16780704;
pub const XK_Overlay1_Enable = 65144;
pub const EnableAccess = 1;
pub const XK_Zenkaku_Hankaku = 65322;
pub const XK_Egrave = 200;
pub const XK_fourthroot = 16785948;
pub const __FLT_RADIX__ = 2;
pub const XK_Pointer_Button_Dflt = 65256;
pub const XK_Arabic_8 = 16778856;
pub const XK_braille_dots_378 = 16787652;
pub const __GLIBC_MINOR__ = 27;
pub const XNPreeditStartCallback = c"preeditStartCallback";
pub const XK_Cyrillic_hardsign = 1759;
pub const XK_Hangul_J_Kiyeog = 3796;
pub const IsUnviewable = 1;
pub const XK_Thai_nonu = 3513;
pub const XK_Omacron = 978;
pub const __FLT16_DECIMAL_DIG__ = 5;
pub const VisualIDMask = 1;
pub const FontRightToLeft = 1;
pub const XK_brokenbar = 166;
pub const XK_sabovedot = 16784993;
pub const XK_Obelowdot = 16785100;
pub const XK_Sinh_u2 = 16780756;
pub const XK_Ncaron = 466;
pub const RR_PROPERTY_CLONE_LIST = c"CloneList";
pub const __INT64_FMTi__ = c"li";
pub const XK_ccedilla = 231;
pub const XK_Greek_omegaaccent = 1979;
pub const XK_braille_blank = 16787456;
pub const XK_Cyrillic_U_macron = 16778478;
pub const XK_e = 101;
pub const NotifyGrab = 1;
pub const __LDBL_MIN__ = 0.000000;
pub const ZPixmap = 2;
pub const XK_Georgian_har = 16781556;
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __GID_T_TYPE = __U32_TYPE;
pub const XK_Arabic_ha = 1511;
pub const X_RRGetProviderInfo = 33;
pub const FamilyChaos = 2;
pub const XK_WonSign = 16785577;
pub const __UINT_LEAST64_FMTX__ = c"lX";
pub const __clang_minor__ = 0;
pub const XK_overline = 1150;
pub const AllowExposures = 1;
pub const DisableAccess = 0;
pub const XK_Cyrillic_KA_vertstroke = 16778396;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const XK_Ecircumflexbelowdot = 16785094;
pub const XK_KP_6 = 65462;
pub const __UINT_FAST64_FMTo__ = c"lo";
pub const XK_Hangul_J_Hieuh = 3822;
pub const X_RenderCreateLinearGradient = 34;
pub const XK_onehalf = 189;
pub const XK_Sinh_kunddaliya = 16780788;
pub const XK_braille_dots_17 = 16787521;
pub const PictOpDisjointOver = 19;
pub const XK_Cyrillic_EN = 1774;
pub const XK_Greek_PSI = 2008;
pub const RaiseLowest = 0;
pub const XK_lacute = 485;
pub const XK_Cyrillic_o_bar = 16778473;
pub const X_PROTOCOL = 11;
pub const XK_ooblique = 248;
pub const XK_Sinh_aee = 16780680;
pub const __UINT8_FMTX__ = c"hhX";
pub const XK_Cyrillic_YERU = 1785;
pub const XK_L3 = 65482;
pub const XK_Hangul_PreviousCandidate = 65342;
pub const XK_dead_belowdot = 65120;
pub const XK_kana_FU = 1228;
pub const PictOpDarken = 51;
pub const XK_Uhorngrave = 16785130;
pub const XK_Farsi_7 = 16778999;
pub const __UINT8_FMTx__ = c"hhx";
pub const __ORDER_LITTLE_ENDIAN__ = 1234;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const XK_Shift_L = 65505;
pub const XK_Q = 81;
pub const XK_dead_aboveverticalline = 65169;
pub const XK_Ntilde = 209;
pub const MappingKeyboard = 1;
pub const XK_Sinh_ru2 = 16780760;
pub const XK_dead_acute = 65105;
pub const XK_nobreakspace = 160;
pub const XK_onesubscript = 16785537;
pub const XK_Thai_thanthakhat = 3564;
pub const XK_abrevegrave = 16785073;
pub const XK_Cacute = 454;
pub const XK_Greek_XI = 1998;
pub const XK_ebelowdot = 16785081;
pub const Opposite = 4;
pub const XK_Tab = 65289;
pub const XK_ibreve = 16777517;
pub const XK_Armenian_vyun = 16778626;
pub const XK_braille_dots_12358 = 16787607;
pub const XK_Sinh_ruu2 = 16780786;
pub const XK_braille_dots_123578 = 16787671;
pub const __STDC_NO_THREADS__ = 1;
pub const XK_Udiaeresis = 220;
pub const XK_ssharp = 223;
pub const XK_Thai_thothan = 3504;
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = 2;
pub const XK_Oslash = 216;
pub const XK_Cyrillic_ER = 1778;
pub const __GXX_ABI_VERSION = 1002;
pub const XK_notsign = 172;
pub const XK_Cyrillic_CHE = 1790;
pub const RR_Rotate_90 = 2;
pub const XK_kana_NI = 1222;
pub const XK_kana_openingbracket = 1186;
pub const XK_uhornacute = 16785129;
pub const XK_Thai_maichattawa = 3563;
pub const XK_THORN = 222;
pub const XIMStringConversionSubstitution = 1;
pub const XK_voicedsound = 1246;
pub const XK_Hangul = 65329;
pub const __INT_LEAST64_FMTi__ = c"li";
pub const RepeatNone = 0;
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const XK_Yacute = 221;
pub const XK_F2 = 65471;
pub const XK_Greek_LAMDA = 1995;
pub const ResizeRequest = 25;
pub const XK_Arabic_superscript_alef = 16778864;
pub const FamilyServerInterpreted = 5;
pub const BadGlyphSet = 3;
pub const RR_PROPERTY_BORDER = c"Border";
pub const XK_Arabic_dal = 1487;
pub const __FLT16_MANT_DIG__ = 11;
pub const XK_squareroot = 16785946;
pub const XK_ocircumflexgrave = 16785107;
pub const XK_Otilde = 213;
pub const XK_Thai_maihanakat = 3537;
pub const XK_percent = 37;
pub const XK_Hangul_RieulHieuh = 3760;
pub const CreateNotify = 16;
pub const XNBaseFontName = c"baseFontName";
pub const XK_x = 120;
pub const XK_asciicircum = 94;
pub const XK_ahook = 16785059;
pub const XK_7 = 55;
pub const XK_Georgian_hae = 16781552;
pub const XK_Sinh_ya = 16780730;
pub const XNHotKeyState = c"hotKeyState";
pub const XK_Cyrillic_BE = 1762;
pub const __UINT_FAST8_MAX__ = 255;
pub const __DBL_MIN_10_EXP__ = -307;
pub const WidthValue = 4;
pub const __OFF_T_MATCHES_OFF64_T = 1;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const PictOpExclusion = 58;
pub const XK_Hangul_WEO = 3789;
pub const PictOpHSLLuminosity = 62;
pub const XK_Arabic_dammatan = 1516;
pub const XK_ISO_Group_Shift = 65406;
pub const XK_Hangul_SunkyeongeumMieum = 3824;
pub const __UINT_FAST32_FMTu__ = c"u";
pub const XK_Left = 65361;
pub const XK_dead_semivoiced_sound = 65119;
pub const XK_Georgian_jhan = 16781551;
pub const XK_Cyrillic_ie = 1733;
pub const XK_braille_dots_1234 = 16787471;
pub const BadIDChoice = 14;
pub const XK_Georgian_xan = 16781550;
pub const XK_Pointer_Button5 = 65261;
pub const XK_uhorngrave = 16785131;
pub const GXand = 1;
pub const XK_Hangul_RieulPieub = 3756;
pub const XK_Hangul_U = 3788;
pub const XK_braille_dots_237 = 16787526;
pub const XK_Arabic_9 = 16778857;
pub const __FXSR__ = 1;
pub const XK_Cyrillic_el = 1740;
pub const __UINT32_FMTx__ = c"x";
pub const XK_kana_tu = 1199;
pub const XK_Thai_phinthu = 3546;
pub const XK_Hangul_J_Pieub = 3812;
pub const XK_Ocircumflexhook = 16785108;
pub const __SIZE_MAX__ = c_ulong(18446744073709551615);
pub const _BITS_UINTN_IDENTITY_H = 1;
pub const XK_Arabic_ra = 1489;
pub const XK_Prior = 65365;
pub const XK_Armenian_HI = 16778565;
pub const XK_dintegral = 16785964;
pub const XK_Icircumflex = 206;
pub const __tune_k8__ = 1;
pub const XK_Thorn = 222;
pub const XK_d = 100;
pub const __UINT64_C_SUFFIX__ = UL;
pub const __clock_t_defined = 1;
pub const XK_Greek_rho = 2033;
pub const XK_semivoicedsound = 1247;
pub const XK_braille_dots_2468 = 16787626;
pub const X_RRSetOutputPrimary = 30;
pub const PictOpOverlay = 50;
pub const XK_Hangul_Hanja = 65332;
pub const NotifyNormal = 0;
pub const EnterNotify = 7;
pub const XK_KP_F3 = 65427;
pub const RR_VSyncNegative = 8;
pub const XK_KP_5 = 65461;
pub const __USE_POSIX_IMPLICITLY = 1;
pub const XK_Cyrillic_IE = 1765;
pub const XK_braille_dots_23478 = 16787662;
pub const XK_braille_dots_16 = 16787489;
pub const XK_braille_dots_13578 = 16787669;
pub const XK_Greek_lamda = 2027;
pub const XK_dead_a = 65152;
pub const ForgetGravity = 0;
pub const XK_Meta_L = 65511;
pub const XK_StickyKeys_Enable = 65141;
pub const XK_Hangul_A = 3775;
pub const __LDBL_MAX_10_EXP__ = 4932;
pub const XK_Sinh_ssha = 16780738;
pub const PictOpOut = 7;
pub const XK_Ukrainian_ghe_with_upturn = 1709;
pub const XNPreeditState = c"preeditState";
pub const XK_braille_dots_1478 = 16787657;
pub const XK_Undo = 65381;
pub const XK_twosuperior = 178;
pub const XK_L2 = 65481;
pub const XK_Arabic_tatweel = 1504;
pub const XK_Ukrainian_IE = 1716;
pub const XK_Cyrillic_SHHA = 16778426;
pub const __INT_FAST32_FMTd__ = c"d";
pub const RR_DoubleClock = 4096;
pub const XK_Farsi_6 = 16778998;
pub const XNRequiredCharSet = c"requiredCharSet";
pub const XK_bracketleft = 91;
pub const XIMStatusArea = c_long(256);
pub const XK_P = 80;
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = 4;
pub const XK_braille_dots_3478 = 16787660;
pub const XK_Armenian_ra = 16778620;
pub const XIMPreeditEnable = c_long(1);
pub const XK_Arabic_hamzaonwaw = 1476;
pub const __GLIBC__ = 2;
pub const X_RenderCreateCursor = 27;
pub const SouthGravity = 8;
pub const XK_Georgian_on = 16781533;
pub const XK_Cyrillic_nje = 1706;
pub const XK_kana_A = 1201;
pub const __INT_LEAST64_MAX__ = c_long(9223372036854775807);
pub const SyncKeyboard = 4;
pub const XK_Greek_accentdieresis = 1966;
pub const XK_braille_dots_246 = 16787498;
pub const XK_Thai_sarao = 3554;
pub const XK_C_h = 65188;
pub const NotifyUngrab = 2;
pub const XK_quotedbl = 34;
pub const XK_Sinh_dhha = 16780720;
pub const XK_Thai_maiyamok = 3558;
pub const XK_dead_perispomeni = 65107;
pub const CursorShape = 0;
pub const XK_Cyrillic_en_descender = 16778403;
pub const XK_Ydiaeresis = 5054;
pub const XK_Sinh_jnya = 16780709;
pub const XK_dcaron = 495;
pub const XK_Iacute = 205;
pub const XK_Cyrillic_ES = 1779;
pub const __SIZEOF_FLOAT__ = 4;
pub const XK_Itilde = 933;
pub const XK_Armenian_SE = 16778573;
pub const __INT_LEAST32_FMTd__ = c"d";
pub const XK_Greek_omega = 2041;
pub const XK_hebrew_daleth = 3299;
pub const XK_braille_dots_234578 = 16787678;
pub const NotifyNonlinear = 3;
pub const XK_Hangul_WE = 3790;
pub const ColormapUninstalled = 0;
pub const XK_Arabic_khah = 1486;
pub const XK_Sinh_au = 16780694;
pub const XK_Georgian_tan = 16781527;
pub const XK_F14 = 65483;
pub const XK_Armenian_vev = 16778622;
pub const XK_braille_dots_345678 = 16787708;
pub const X_RenderReferenceGlyphSet = 18;
pub const XK_Macedonia_dse = 1701;
pub const XK_Serbian_TSHE = 1723;
pub const BadGlyph = 4;
pub const XK_Ukranian_JE = 1716;
pub const XK_Jcircumflex = 684;
pub const __STDC_IEC_559_COMPLEX__ = 1;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const XK_6 = 54;
pub const XK_ohornhook = 16785119;
pub const XK_Greek_CHI = 2007;
pub const CapProjecting = 3;
pub const XK_kana_U = 1203;
pub const XK_emacron = 954;
pub const XK_Arabic_kaf = 1507;
pub const XK_threesubscript = 16785539;
pub const PictOpConjointOverReverse = 36;
pub const XK_racute = 480;
pub const XK_braille_dots_8 = 16787584;
pub const XK_hebrew_chet = 3303;
pub const __DBL_HAS_DENORM__ = 1;
pub const XK_Greek_RHO = 2001;
pub const __FLT16_HAS_QUIET_NAN__ = 1;
pub const XK_Sinh_ee = 16780690;
pub const XK_ncaron = 498;
pub const VisualAllMask = 511;
pub const PictOpOverReverse = 4;
pub const XK_braille_dots_1235 = 16787479;
pub const XK_less = 60;
pub const __WINT_MAX__ = c_uint(4294967295);
pub const XK_Greek_UPSILONdieresis = 1961;
pub const __STDC_ISO_10646__ = c_long(201706);
pub const Mod1MapIndex = 3;
pub const XK_Print = 65377;
pub const XK_Pointer_Button4 = 65260;
pub const XK_Acircumflexbelowdot = 16785068;
pub const XK_Armenian_se = 16778621;
pub const XK_braille_dots_236 = 16787494;
pub const XK_Arabic_6 = 16778854;
pub const XK_Cyrillic_em = 1741;
pub const PictOpMaximum = 13;
pub const XK_Sinh_nga = 16780703;
pub const DontCareState = 0;
pub const XK_ISO_Level3_Latch = 65028;
pub const XK_adiaeresis = 228;
pub const XK_braille_dots_124568 = 16787643;
pub const XK_Armenian_khe = 16778605;
pub const XK_Sinh_ai = 16780691;
pub const XK_Hangul_J_NieunJieuj = 3800;
pub const XK_breve = 418;
pub const RRSetConfigInvalidConfigTime = 1;
pub const XK_F29 = 65498;
pub const XK_Arabic_switch = 65406;
pub const RR_Capability_None = 0;
pub const XK_Ukranian_je = 1700;
pub const CapNotLast = 0;
pub const XIMHotKeyStateON = c_long(1);
pub const __INT_LEAST32_MAX__ = 2147483647;
pub const XK_Hangul_J_Dikeud = 3802;
pub const XK_g = 103;
pub const XK_ydiaeresis = 255;
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = 1;
pub const ColormapNotify = 32;
pub const XK_braille_dots_1567 = 16787569;
pub const __timespec_defined = 1;
pub const X_RRAddOutputMode = 18;
pub const __LITTLE_ENDIAN__ = 1;
pub const __FLT_HAS_QUIET_NAN__ = 1;
pub const XK_Pointer_Up = 65250;
pub const JoinRound = 1;
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const XK_ISO_Partial_Line_Down = 65060;
pub const XK_Ohornhook = 16785118;
pub const XK_Right = 65363;
pub const XK_KP_F2 = 65426;
pub const LedModeOn = 1;
pub const XK_Armenian_separation_mark = 16778589;
pub const XK_Eisu_toggle = 65328;
pub const XK_KP_4 = 65460;
pub const Always = 2;
pub const XK_Arabic_comma = 1452;
pub const XK_Thai_bobaimai = 3514;
pub const XK_braille_dots_15 = 16787473;
pub const BadAlloc = 11;
pub const XK_Armenian_PYUR = 16778579;
pub const XNVaNestedList = c"XNVaNestedList";
pub const FD_SETSIZE = __FD_SETSIZE;
pub const XK_Thai_khokhwai = 3492;
pub const XK_Thai_thothung = 3510;
pub const XNQueryInputStyle = c"queryInputStyle";
pub const RRSetConfigSuccess = 0;
pub const XK_Armenian_dza = 16778609;
pub const XK_Arabic_seen = 1491;
pub const XK_braille_dots_12468 = 16787627;
pub const XK_Hangul_YEO = 3781;
pub const XK_kana_KI = 1207;
pub const __FLT_MAX_10_EXP__ = 38;
pub const _FEATURES_H = 1;
pub const XK_hebrew_kaph = 3307;
pub const SubPixelUnknown = 0;
pub const XK_L1 = 65480;
pub const XK_Pointer_DfltBtnNext = 65275;
pub const RRNumberRequests = 45;
pub const XK_hebrew_waw = 3301;
pub const XIMStringConversionWrapped = 32;
pub const X_RRGetScreenResourcesCurrent = 25;
pub const __DBL_MIN__ = 0.000000;
pub const ArcPieSlice = 1;
pub const __S32_TYPE = int;
pub const XK_Farsi_5 = 16778997;
pub const XK_Ohorngrave = 16785116;
pub const XK_braille_dots_278 = 16787650;
pub const XK_oslash = 248;
pub const XK_hebrew_tet = 3304;
pub const XK_S = 83;
pub const X_RenderFreePicture = 7;
pub const __gnu_linux__ = 1;
pub const XK_Ahook = 16785058;
pub const NotUseful = 0;
pub const XK_braille_dots_1278 = 16787651;
pub const XK_Macedonia_DSE = 1717;
pub const XK_braille_dots_247 = 16787530;
pub const XK_Pointer_EnableKeys = 65273;
pub const __timer_t_defined = 1;
pub const XK_dead_voiced_sound = 65118;
pub const XK_equal = 61;
pub const XK_Sinh_ai2 = 16780763;
pub const XK_braille_dots_2578 = 16787666;
pub const XK_Hangul_NieunJieuj = 3749;
pub const XK_ISO_Partial_Space_Right = 65062;
pub const __INT_FAST8_FMTd__ = c"hhd";
pub const __USE_POSIX199506 = 1;
pub const XK_otilde = 245;
pub const XK_bracketright = 93;
pub const XK_Hyper_R = 65518;
pub const XNPreeditDrawCallback = c"preeditDrawCallback";
pub const SubPixelNone = 5;
pub const XK_hebrew_gimel = 3298;
pub const XNStatusAttributes = c"statusAttributes";
pub const XK_dead_diaeresis = 65111;
pub const XK_ISO_Release_Margin_Right = 65066;
pub const XK_Thai_phophung = 3516;
pub const __FLT_MAX_EXP__ = 128;
pub const XK_kana_RA = 1239;
pub const XK_ISO_Level3_Lock = 65029;
pub const XK_braille_dots_258 = 16787602;
pub const __INT_FAST64_FMTi__ = c"li";
pub const XK_Cyrillic_e = 1756;
pub const XNArea = c"area";
pub const XK_Mae_Koho = 65342;
pub const XK_dead_abovecomma = 65124;
pub const XIMStringConversionLine = 2;
pub const XK_Greek_upsilon = 2037;
pub const XK_eightsubscript = 16785544;
pub const XK_braille_dots_1234568 = 16787647;
pub const XK_Sinh_oo = 16780693;
pub const XK_F15 = 65484;
pub const GrayScale = 1;
pub const XK_scaron = 441;
pub const XK_Sinh_rii = 16780686;
pub const PlaceOnTop = 0;
pub const XK_Cyrillic_softsign = 1752;
pub const XK_z = 122;
pub const XK_9 = 57;
pub const XK_Ybelowdot = 16785140;
pub const XK_Arabic_maddaonalef = 1474;
pub const XK_braille_dots_1245 = 16787483;
pub const X_RRQueryProviderProperty = 37;
pub const __CHAR_BIT__ = 8;
pub const XK_Oacute = 211;
pub const X_RRGetCrtcInfo = 20;
pub const RRScreenChangeNotify = 0;
pub const XK_Mabovedot = 16784960;
pub const XNQueryIMValuesList = c"queryIMValuesList";
pub const __GNUC_MINOR__ = 2;
pub const XK_Greek_OMEGAaccent = 1963;
pub const RANDR_NAME = c"RANDR";
pub const True = 1;
pub const XK_Hangul_YO = 3787;
pub const __FLT_EPSILON__ = 0.000000;
pub const X_RRGetCrtcGammaSize = 22;
pub const XK_cuberoot = 16785947;
pub const XK_onequarter = 188;
pub const XK_Thai_paiyannoi = 3535;
pub const XK_braille_dots_1236 = 16787495;
pub const XK_dead_O = 65159;
pub const XK_obarred = 16777845;
pub const UnmapNotify = 18;
pub const XK_Ooblique = 216;
pub const X_RenderQueryDithers = 3;
pub const XK_ecircumflexacute = 16785087;
pub const __FLT_HAS_INFINITY__ = 1;
pub const XK_tslash = 956;
pub const XK_exclam = 33;
pub const XK_Meta_R = 65512;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const NULL = if (@typeId(@typeOf(0)) == @import("builtin").TypeId.Pointer) @ptrCast([*]void, 0) else if (@typeId(@typeOf(0)) == @import("builtin").TypeId.Int) @intToPtr([*]void, 0) else ([*]void)(0);
pub const XK_Gbreve = 683;
pub const EastGravity = 6;
pub const XK_braille_dots_235 = 16787478;
pub const XK_Arabic_7 = 16778855;
pub const XK_Hangul_J_YeorinHieuh = 3834;
pub const XK_Arabic_alefmaksura = 1513;
pub const XK_Cyrillic_en = 1742;
pub const XK_dead_doublegrave = 65126;
pub const XK_braille_dots_12456 = 16787515;
pub const NeedVarargsPrototypes = 1;
pub const XIMStringConversionWord = 3;
pub const FirstExtensionError = 128;
pub const XK_Henkan_Mode = 65315;
pub const XK_Hebrew_switch = 65406;
pub const XK_Sinh_aee2 = 16780753;
pub const _BITS_SYSMACROS_H = 1;
pub const XNSeparatorofNestedList = c"separatorofNestedList";
pub const __DBL_HAS_QUIET_NAN__ = 1;
pub const XK_F28 = 65497;
pub const MSBFirst = 1;
pub const XK_braille_dots_2348 = 16787598;
pub const XK_f = 102;
pub const __ORDER_PDP_ENDIAN__ = 3412;
pub const XK_Pointer_Accelerate = 65274;
pub const XK_bar = 124;
pub const __INT16_TYPE__ = short;
pub const XK_Thai_nonen = 3507;
pub const RR_PROPERTY_COMPATIBILITY_LIST = c"CompatibilityList";
pub const XK_hebrew_finalzade = 3317;
pub const XK_braille_dots_1568 = 16787633;
pub const XK_Georgian_man = 16781531;
pub const XK_Hangul_MultipleCandidate = 65341;
pub const XK_Thai_sarau = 3544;
pub const BadAccess = 10;
pub const PictOpDisjointMaximum = 27;
pub const XK_KP_F1 = 65425;
pub const XK_Arabic_thal = 1488;
pub const XK_Greek_eta = 2023;
pub const XK_ISO_Level5_Shift = 65041;
pub const ButtonRelease = 5;
pub const XK_KP_3 = 65459;
pub const XK_Ncedilla = 977;
pub const __SSE2__ = 1;
pub const XK_braille_dots_14 = 16787465;
pub const FamilyInternet6 = 6;
pub const XK_Terminate_Server = 65237;
pub const RR_Interlace = 16;
pub const __UINT32_MAX__ = c_uint(4294967295);
pub const XK_Hankaku = 65321;
pub const EvenOddRule = 0;
pub const XK_Hangul_switch = 65406;
pub const X_RenderTriStrip = 12;
pub const XK_Cyrillic_er = 1746;
pub const KeyPress = 2;
pub const XBufferOverflow = -1;
pub const XK_kana_MI = 1232;
pub const __INT8_FMTi__ = c"hhi";
pub const MappingBusy = 1;
pub const XK_Thai_lu = 3526;
pub const XK_elementof = 16785928;
pub const XK_Macedonia_kje = 1708;
pub const XK_Pointer_DownRight = 65255;
pub const XK_hebrew_resh = 3320;
pub const XK_Farsi_4 = 16778996;
pub const XK_braille_dots_458 = 16787608;
pub const XK_braille_dots_34578 = 16787676;
pub const __INT_FAST64_MAX__ = c_long(9223372036854775807);
pub const XK_Hangul_Jieuj = 3768;
pub const XK_R = 82;
pub const XK_Cyrillic_pe = 1744;
pub const XK_lbelowdot = 16784951;
pub const XK_braille_dots_4567 = 16787576;
pub const XK_braille_dots_13458 = 16787613;
pub const XK_Sinh_bha = 16780727;
pub const XK_hebrew_bet = 3297;
pub const XK_colon = 58;
pub const XK_braille_dots_235678 = 16787702;
pub const XK_Arabic_percent = 16778858;
pub const XNR6PreeditCallback = c"r6PreeditCallback";
pub const XK_cedilla = 184;
pub const XK_Ukrainian_i = 1702;
pub const XK_wdiaeresis = 16785029;
pub const XK_KP_Tab = 65417;
pub const XK_Cyrillic_be = 1730;
pub const XK_Thai_sarai = 3540;
pub const XK_Hangul_J_Tieut = 3820;
pub const XK_kana_HU = 1228;
pub const XK_braille_dots_13467 = 16787565;
pub const JoinMiter = 0;
pub const XK_Sinh_kha = 16780699;
pub const __SIZEOF_POINTER__ = 8;
pub const __TIMER_T_TYPE = [*]void;
pub const __unix = 1;
pub const XK_braille_dots_234678 = 16787694;
pub const XK_mu = 181;
pub const XK_Thai_lochula = 3532;
pub const XK_hebrew_teth = 3304;
pub const XK_braille_dots_14678 = 16787689;
pub const XK_kana_TA = 1216;
pub const __unix__ = 1;
pub const VisibilityUnobscured = 0;
pub const XK_braille_dots_478 = 16787656;
pub const __LDBL_HAS_INFINITY__ = 1;
pub const XK_Thai_dochada = 3502;
pub const XLocaleNotSupported = -2;
pub const XK_Armenian_TSA = 16778558;
pub const __UINTPTR_FMTo__ = c"lo";
pub const XK_ISO_Enter = 65076;
pub const XK_braille_dots_23578 = 16787670;
pub const BadColor = 12;
pub const XK_Prev_Virtual_Screen = 65233;
pub const XK_F16 = 65485;
pub const XK_hebrew_finalnun = 3311;
pub const BitmapNoMemory = 3;
pub const RR_CSyncNegative = 256;
pub const XK_dead_abovedot = 65110;
pub const XK_braille_dots_3567 = 16787572;
pub const XK_rcedilla = 947;
pub const XK_Cyrillic_PE = 1776;
pub const XK_braille_dots_356 = 16787508;
pub const YValue = 2;
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = 2;
pub const XK_Arabic_sad = 1493;
pub const XK_braille_dots_2378 = 16787654;
pub const XK_8 = 56;
pub const XK_braille_dots_138 = 16787589;
pub const SelectionRequest = 30;
pub const XK_Etilde = 16785084;
pub const RetainTemporary = 2;
pub const X_RenderComposite = 8;
pub const XK_PreviousCandidate = 65342;
pub const XK_braille_dots_347 = 16787532;
pub const PictOpDisjointInReverse = 22;
pub const XK_AE = 198;
pub const __linux__ = 1;
pub const XK_braille_dots_1237 = 16787527;
pub const XK_Armenian_lyun = 16778604;
pub const XK_eightsuperior = 16785528;
pub const XK_Arabic_gaf = 16778927;
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
pub const XK_braille_dots_234 = 16787470;
pub const XK_Arabic_4 = 16778852;
pub const XK_Cyrillic_SHCHA = 1789;
pub const XK_braille_dots_12457 = 16787547;
pub const XK_Gcedilla = 939;
pub const PictStandardARGB32 = 0;
pub const __WCHAR_MAX__ = 2147483647;
pub const XK_Arabic_theh = 1483;
pub const XK_Sinh_ndha = 16780723;
pub const XK_Greek_alphaaccent = 1969;
pub const PictOpMultiply = 48;
pub const XK_Greek_GAMMA = 1987;
pub const XK_asciitilde = 126;
pub const __UINTMAX_FMTX__ = c"lX";
pub const XK_ohook = 16785103;
pub const XK_hebrew_lamed = 3308;
pub const XK_Georgian_hoe = 16781557;
pub const XK_ISO_Level3_Shift = 65027;
pub const XK_Arabic_waw = 1512;
pub const XK_Thai_popla = 3515;
pub const XK_Muhenkan = 65314;
pub const XK_i = 105;
pub const XK_ocircumflexbelowdot = 16785113;
pub const XK_Greek_UPSILONaccent = 1960;
pub const XK_Sinh_ndda = 16780716;
pub const timeval = struct_timeval;
pub const timespec = struct_timespec;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const _XExtData = struct__XExtData;
pub const _XGC = struct__XGC;
pub const _XDisplay = struct__XDisplay;
pub const funcs = struct_funcs;
pub const _XImage = struct__XImage;
pub const _XPrivate = struct__XPrivate;
pub const _XrmHashBucketRec = struct__XrmHashBucketRec;
pub const _XEvent = union__XEvent;
pub const _XOM = struct__XOM;
pub const _XOC = struct__XOC;
pub const _XIM = struct__XIM;
pub const _XIC = struct__XIC;
pub const _XIMText = struct__XIMText;
pub const _XIMPreeditStateNotifyCallbackStruct = struct__XIMPreeditStateNotifyCallbackStruct;
pub const _XIMStringConversionText = struct__XIMStringConversionText;
pub const _XIMStringConversionCallbackStruct = struct__XIMStringConversionCallbackStruct;
pub const _XIMPreeditDrawCallbackStruct = struct__XIMPreeditDrawCallbackStruct;
pub const _XIMPreeditCaretCallbackStruct = struct__XIMPreeditCaretCallbackStruct;
pub const _XIMStatusDrawCallbackStruct = struct__XIMStatusDrawCallbackStruct;
pub const _XIMHotKeyTrigger = struct__XIMHotKeyTrigger;
pub const _XIMHotKeyTriggers = struct__XIMHotKeyTriggers;
pub const _XComposeStatus = struct__XComposeStatus;
pub const _XRegion = struct__XRegion;
pub const _Client = struct__Client;
pub const _Font = struct__Font;
pub const _XRenderPictureAttributes = struct__XRenderPictureAttributes;
pub const _XGlyphInfo = struct__XGlyphInfo;
pub const _XGlyphElt8 = struct__XGlyphElt8;
pub const _XGlyphElt16 = struct__XGlyphElt16;
pub const _XGlyphElt32 = struct__XGlyphElt32;
pub const _XPointDouble = struct__XPointDouble;
pub const _XPointFixed = struct__XPointFixed;
pub const _XLineFixed = struct__XLineFixed;
pub const _XTriangle = struct__XTriangle;
pub const _XCircle = struct__XCircle;
pub const _XTrapezoid = struct__XTrapezoid;
pub const _XTransform = struct__XTransform;
pub const _XFilters = struct__XFilters;
pub const _XIndexValue = struct__XIndexValue;
pub const _XAnimCursor = struct__XAnimCursor;
pub const _XSpanFix = struct__XSpanFix;
pub const _XTrap = struct__XTrap;
pub const _XLinearGradient = struct__XLinearGradient;
pub const _XRadialGradient = struct__XRadialGradient;
pub const _XConicalGradient = struct__XConicalGradient;
pub const _XRRScreenConfiguration = struct__XRRScreenConfiguration;
pub const _XRRModeInfo = struct__XRRModeInfo;
pub const _XRRScreenResources = struct__XRRScreenResources;
pub const _XRROutputInfo = struct__XRROutputInfo;
pub const _XRRCrtcInfo = struct__XRRCrtcInfo;
pub const _XRRCrtcGamma = struct__XRRCrtcGamma;
pub const _XRRCrtcTransformAttributes = struct__XRRCrtcTransformAttributes;
pub const _XRRPanning = struct__XRRPanning;
pub const _XRRProviderResources = struct__XRRProviderResources;
pub const _XRRProviderInfo = struct__XRRProviderInfo;
pub const _XRRMonitorInfo = struct__XRRMonitorInfo;
