const sdl = @import("sdl.zig");
const Self = @This();

const Error = error{InitFail};

width: i32,
height: i32,

ptr: *sdl.c.SDL_Window,

pub fn init(title: [*c]const u8, w: i32, h: i32) !Self {
    const ptr = sdl.c.SDL_CreateWindow(title, 0, 0, w, h, sdl.c.SDL_WINDOW_SHOWN);
    if (ptr == null)
        return Error.InitFail;
    errdefer sdl.c.SDL_DestroyWindow(ptr);
    return Self{
        .width = w,
        .height = h,
        .ptr = ptr.?,
    };
}

pub fn deinit(self: Self) void {
    sdl.c.SDL_DestroyWindow(self.ptr);
}
