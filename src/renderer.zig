const sdl = @import("sdl.zig");
const Window = @import("window.zig");

const Error = error{ InitFail, ClearFail, SetColorFail, DrawFail, LockFail };

const Self = @This();

ptr: *sdl.c.SDL_Renderer,
screen_texture: *sdl.c.SDL_Texture,

locked: bool,

pixels: [*c]u32 = null,
pitch: i32 = undefined,

pub fn init(window: Window) !Self {
    const ptr = sdl.c.SDL_CreateRenderer(window.ptr, 0, 0);
    if (ptr == null)
        return Error.InitFail;
    errdefer sdl.c.SDL_DestroyRenderer(ptr);
    const texture = sdl.c.SDL_CreateTexture(ptr, sdl.c.SDL_PIXELFORMAT_RGBA8888, sdl.c.SDL_TEXTUREACCESS_STREAMING, window.width, window.height);
    if (texture == null)
        return Error.InitFail;
    errdefer sdl.c.SDL_DestroyTexture(texture);
    return Self{
        .ptr = ptr.?,
        .screen_texture = texture.?,
        .locked = false,
    };
}

pub fn deinit(self: Self) void {
    sdl.c.SDL_DestroyTexture(self.screen_texture);
    sdl.c.SDL_DestroyRenderer(self.ptr);
}

pub fn clear(self: Self) !void {
    if (sdl.c.SDL_RenderClear(self.ptr) < 0)
        return Error.ClearFail;
}

pub fn present(self: Self) void {
    sdl.c.SDL_RenderPresent(self.ptr);
}

pub fn lock_texture(self: *Self) !void {
    if (sdl.c.SDL_LockTexture(self.screen_texture, null, @ptrCast(&self.pixels), &self.pitch) < 0)
        return Error.LockFail;
    self.locked = true;
}

pub fn unlock_texture(self: *Self) void {
    sdl.c.SDL_UnlockTexture(self.screen_texture);
    self.locked = false;
}

pub fn draw_texture(self: Self) !void {
    if (sdl.c.SDL_RenderCopy(self.ptr, self.screen_texture, null, null) < 0)
        return Error.DrawFail;
}

pub fn draw_pixel(self: Self, x: i32, y: i32, r: u32, g: u32, b: u32, a: u32) !void {
    if (!self.locked)
        return Error.DrawFail;
    self.pixels[@intCast(y * @divFloor(self.pitch, 4) + x)] = (r << (8 * 3)) + (g << (8 * 2)) + (b << (8 * 1)) + a;
}
