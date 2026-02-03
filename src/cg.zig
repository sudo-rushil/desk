pub const CGFloat = f64;

pub const CGDirectDisplayID = u32;
pub const CGError = i32;
pub const CGEventFlags = u64;
pub const CGEventType = u32;
pub const CGEventField = u32;
pub const CGEventMask = u64;
pub const CGEventTapLocation = u32;
pub const CGEventTapPlacement = u32;
pub const CGEventTapOptions = u32;
pub const CGMouseButton = u32;

pub const CGEventRef = ?*anyopaque;
pub const CGEventSourceRef = ?*anyopaque;
pub const CGEventTapProxy = ?*anyopaque;
pub const CFMachPortRef = ?*anyopaque;
pub const CFRunLoopSourceRef = ?*anyopaque;
pub const CFRunLoopRef = ?*anyopaque;
pub const CFStringRef = ?*anyopaque;
pub const CFTypeRef = ?*anyopaque;
pub const CFAllocatorRef = ?*anyopaque;

pub const CGPoint = extern struct {
    x: CGFloat,
    y: CGFloat,
};

pub const CGSize = extern struct {
    width: CGFloat,
    height: CGFloat,
};

pub const CGRect = extern struct {
    origin: CGPoint,
    size: CGSize,
};

pub const CGEventTapCallBack = *const fn (
    proxy: CGEventTapProxy,
    event_type: CGEventType,
    event: CGEventRef,
    user_info: ?*anyopaque,
) callconv(.c) CGEventRef;

pub const kCGErrorSuccess: CGError = 0;

pub const kCGEventKeyDown: CGEventType = 10;
pub const kCGEventKeyUp: CGEventType = 11;
pub const kCGEventLeftMouseDown: CGEventType = 1;
pub const kCGEventLeftMouseUp: CGEventType = 2;
pub const kCGEventTapDisabledByTimeout: CGEventType = 0xFFFFFFFE;
pub const kCGEventTapDisabledByUserInput: CGEventType = 0xFFFFFFFF;

pub const kCGMouseButtonLeft: CGMouseButton = 0;

pub const kCGEventFlagMaskControl: CGEventFlags = 0x00040000;
pub const kCGEventFlagMaskCommand: CGEventFlags = 0x00100000;

pub const kCGKeyboardEventAutorepeat: CGEventField = 8;
pub const kCGKeyboardEventKeycode: CGEventField = 9;

pub const kCGHIDEventTap: CGEventTapLocation = 0;
pub const kCGSessionEventTap: CGEventTapLocation = 1;

pub const kCGHeadInsertEventTap: CGEventTapPlacement = 0;

pub const kCGEventTapOptionDefault: CGEventTapOptions = 0x00000000;
pub const kCGEventTapOptionListenOnly: CGEventTapOptions = 0x00000001;

pub extern fn CGGetActiveDisplayList(
    max_displays: u32,
    active_displays: [*]CGDirectDisplayID,
    display_count: *u32,
) CGError;

pub extern fn CGDisplayBounds(display: CGDirectDisplayID) CGRect;

pub extern fn CGWarpMouseCursorPosition(newCursorPosition: CGPoint) CGError;

pub extern fn CGAssociateMouseAndMouseCursorPosition(connected: i32) CGError;

pub extern fn CGEventCreateMouseEvent(
    source: CGEventSourceRef,
    mouseType: CGEventType,
    mouseCursorPosition: CGPoint,
    mouseButton: CGMouseButton,
) CGEventRef;

pub extern fn CGEventPost(tap: CGEventTapLocation, event: CGEventRef) void;

pub extern fn CGEventGetIntegerValueField(event: CGEventRef, field: CGEventField) i64;

pub extern fn CGEventGetFlags(event: CGEventRef) CGEventFlags;

pub extern fn CGEventTapCreate(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    callback: CGEventTapCallBack,
    userInfo: ?*anyopaque,
) CFMachPortRef;

pub extern fn CGEventTapEnable(tap: CFMachPortRef, enable: bool) void;

pub extern fn CFMachPortCreateRunLoopSource(
    allocator: CFAllocatorRef,
    port: CFMachPortRef,
    order: isize,
) CFRunLoopSourceRef;

pub extern fn CFRunLoopAddSource(
    rl: CFRunLoopRef,
    source: CFRunLoopSourceRef,
    mode: CFStringRef,
) void;

pub extern fn CFRunLoopGetCurrent() CFRunLoopRef;

pub extern fn CFRunLoopRun() void;

pub extern fn CFRelease(cf: CFTypeRef) void;

pub extern const kCFRunLoopCommonModes: CFStringRef;
