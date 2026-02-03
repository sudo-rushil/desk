const std = @import("std");
const builtin = @import("builtin");

const c = @import("./cg.zig");

const MaxDisplays = 16;
const TargetDisplays = 3;

const AppState = struct {
    display_ids: [TargetDisplays]c.CGDirectDisplayID,
    display_count: usize,
    event_tap: c.CFMachPortRef,
};

const HotKeyConfig = struct {
    id: u32,
    key_code: u32,
    mods: c.CGEventFlags,
};

const hotkeys = [_]HotKeyConfig{
    .{ .id = 1, .key_code = 18, .mods = c.kCGEventFlagMaskCommand | c.kCGEventFlagMaskControl },
    .{ .id = 2, .key_code = 19, .mods = c.kCGEventFlagMaskCommand | c.kCGEventFlagMaskControl },
    .{ .id = 3, .key_code = 20, .mods = c.kCGEventFlagMaskCommand | c.kCGEventFlagMaskControl },
};

pub fn main() !void {
    if (builtin.os.tag != .macos) {
        std.debug.print("This app only runs on macOS.\n", .{});
        return;
    }

    var state = try loadDisplays();
    logDisplayMap(state);

    try installEventTap(&state);

    std.debug.print("Hotkeys active: Ctrl+Cmd+1/2/3\n", .{});
    std.debug.print("If focus or clicks fail, grant Accessibility permissions.\n", .{});

    c.CFRunLoopRun();
}

fn cgEventMaskBit(event_type: c.CGEventType) c.CGEventMask {
    return @as(c.CGEventMask, 1) << @intCast(event_type);
}

fn loadDisplays() !AppState {
    var ids: [MaxDisplays]c.CGDirectDisplayID = undefined;
    var count: u32 = 0;
    const err = c.CGGetActiveDisplayList(MaxDisplays, &ids, &count);
    if (err != c.kCGErrorSuccess) return error.DisplayListFailed;

    var state = AppState{
        .display_ids = .{0} ** TargetDisplays,
        .display_count = @as(usize, count),
        .event_tap = null,
    };

    var i: usize = 0;
    while (i < TargetDisplays and i < state.display_count) : (i += 1) {
        state.display_ids[i] = ids[i];
    }

    return state;
}

fn logDisplayMap(state: AppState) void {
    if (state.display_count == 0) {
        std.debug.print("No displays detected.\n", .{});
        return;
    }

    var i: usize = 0;
    while (i < TargetDisplays and i < state.display_count) : (i += 1) {
        std.debug.print("Hotkey {d} -> display {d}\n", .{ i + 1, state.display_ids[i] });
    }
}

fn installEventTap(state: *AppState) !void {
    const event_mask = cgEventMaskBit(c.kCGEventKeyDown) | cgEventMaskBit(c.kCGEventKeyUp);
    const tap = c.CGEventTapCreate(
        c.kCGSessionEventTap,
        c.kCGHeadInsertEventTap,
        c.kCGEventTapOptionDefault,
        event_mask,
        keyEventTap,
        state,
    );
    if (tap == null) return error.EventTapFailed;
    state.event_tap = tap;

    const run_loop_source = c.CFMachPortCreateRunLoopSource(null, tap, 0);
    if (run_loop_source == null) return error.EventTapFailed;

    c.CFRunLoopAddSource(c.CFRunLoopGetCurrent(), run_loop_source, c.kCFRunLoopCommonModes);
    c.CGEventTapEnable(tap, true);
}

fn keyEventTap(
    proxy: c.CGEventTapProxy,
    event_type: c.CGEventType,
    event: c.CGEventRef,
    user_info: ?*anyopaque,
) callconv(.c) c.CGEventRef {
    _ = proxy;

    if (user_info == null) return event;
    const state: *AppState = @ptrCast(@alignCast(user_info.?));

    if (event_type == c.kCGEventTapDisabledByTimeout or event_type == c.kCGEventTapDisabledByUserInput) {
        if (state.event_tap) |tap| {
            c.CGEventTapEnable(tap, true);
        }
        return event;
    }

    if (event_type != c.kCGEventKeyDown and event_type != c.kCGEventKeyUp) return event;

    const keycode = @as(u32, @intCast(c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventKeycode)));
    const flags = c.CGEventGetFlags(event);

    for (hotkeys) |hk| {
        if (keycode != hk.key_code) continue;
        if ((flags & hk.mods) != hk.mods) continue;

        if (event_type == c.kCGEventKeyDown) {
            if (isAutoRepeat(event)) return null;
            focusDisplayForHotkey(state, hk.id);
        }
        return null;
    }

    return event;
}

fn isAutoRepeat(event: c.CGEventRef) bool {
    const value = c.CGEventGetIntegerValueField(event, c.kCGKeyboardEventAutorepeat);
    return value != 0;
}

fn focusDisplayForHotkey(state: *AppState, id: u32) void {
    if (id == 0) return;
    const index = @as(usize, id - 1);

    if (index >= state.display_count or index >= TargetDisplays) {
        std.debug.print("No display mapped for hotkey {d}\n", .{id});
        return;
    }

    focusDisplay(state.display_ids[index]);
}

fn focusDisplay(display_id: c.CGDirectDisplayID) void {
    const bounds = c.CGDisplayBounds(display_id);
    const point = c.CGPoint{
        .x = bounds.origin.x + (bounds.size.width / 2.0),
        .y = bounds.origin.y + (bounds.size.height / 2.0),
    };

    _ = c.CGWarpMouseCursorPosition(point);
    _ = c.CGAssociateMouseAndMouseCursorPosition(1);
    postLeftClick(point);
}

fn postLeftClick(point: c.CGPoint) void {
    const down = c.CGEventCreateMouseEvent(null, c.kCGEventLeftMouseDown, point, c.kCGMouseButtonLeft);
    if (down != null) {
        c.CGEventPost(c.kCGHIDEventTap, down);
        c.CFRelease(down);
    }

    const up = c.CGEventCreateMouseEvent(null, c.kCGEventLeftMouseUp, point, c.kCGMouseButtonLeft);
    if (up != null) {
        c.CGEventPost(c.kCGHIDEventTap, up);
        c.CFRelease(up);
    }
}
