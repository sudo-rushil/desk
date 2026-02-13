# desk

A lightweight macOS utility that lets you instantly focus any display using keyboard hotkeys. Written in Zig with direct CoreGraphics bindings.

## How it works

`desk` installs a global event tap that listens for hotkey presses. When triggered, it warps the mouse cursor to the center of the target display and posts a click event to shift focus.

### Default keybindings

| Hotkey   | Action          |
| -------- | --------------- |
| `Ctrl+3` | Focus display 1 |
| `Ctrl+2` | Focus display 2 |
| `Ctrl+1` | Focus display 3 |

## Requirements

- macOS
- Zig 0.16+
- Accessibility permissions (System Settings > Privacy & Security > Accessibility)

## Build & Run

```sh
zig build
zig build run
```

The compiled binary is output to `zig-out/bin/desk`.
