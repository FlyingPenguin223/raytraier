const sdl = @import("sdl.zig");

const Self = @This();

keys: [sdl.c.SDL_NUM_SCANCODES]bool = .{false} ** sdl.c.SDL_NUM_SCANCODES,
should_quit: bool = false,

pub fn init() Self {
    return .{};
}

pub fn poll_events(self: *Self) void {
    var e: sdl.c.SDL_Event = undefined;
    while (sdl.c.SDL_PollEvent(&e) != 0) {
        switch (e.type) {
            sdl.c.SDL_QUIT => self.should_quit = true,
            sdl.c.SDL_KEYDOWN => self.keys[e.key.keysym.scancode] = true,
            sdl.c.SDL_KEYUP => self.keys[e.key.keysym.scancode] = false,
            else => {},
        }
    }
}
