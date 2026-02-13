# CLAUDE.md

## Project overview

`desk` is a macOS utility written in Zig that switches display focus via global keyboard hotkeys. It uses CoreGraphics APIs to warp the mouse cursor and post click events.

## Build & run

```sh
zig build        # build the binary to zig-out/bin/desk
zig build run    # build and run
zig build test   # run tests
```

Requires Zig 0.16+ and macOS with Accessibility permissions granted.

## Project structure

- `src/main.zig` — Entry point, hotkey config, event tap handler, display focus logic
- `src/cg.zig` — Raw CoreGraphics/CoreFoundation C bindings (types, constants, extern functions)
- `build.zig` — Build configuration; links CoreFoundation and CoreGraphics frameworks
- `build.zig.zon` — Package metadata

## Key conventions

- All macOS framework interop goes through `src/cg.zig` — no direct `@cImport` in other files
- Hotkeys are defined in the `hotkeys` array in `main.zig` as `HotKeyConfig` structs (key_code + modifier flags)
- The app runs a `CFRunLoop` — it installs an event tap at startup and then blocks on the run loop
