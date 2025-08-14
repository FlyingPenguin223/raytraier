const std = @import("std");

const sdl = @import("sdl.zig");
const Window = @import("window.zig");
const Renderer = @import("renderer.zig");

const math = @import("zlm.zig");

const Self = @This();

window: Window,
renderer: Renderer,

start_time: u64 = 0,

pub fn init(title: [*c]const u8, w: i32, h: i32) !Self {
    try sdl.init();
    errdefer sdl.deinit();

    const window = try Window.init(title, w, h);
    errdefer window.deinit();

    const renderer = try Renderer.init(window);
    errdefer renderer.deinit();

    return Self{
        .window = window,
        .renderer = renderer,
    };
}

pub fn deinit(self: Self) void {
    self.renderer.deinit();
    self.window.deinit();
    sdl.deinit();
}

pub fn start_drawing(self: *Self) !void {
    try self.renderer.lock_texture();
}

pub fn clear(self: Self) !void {
    try self.renderer.clear();
}

pub fn end_drawing(self: *Self) !void {
    self.renderer.unlock_texture();
    try self.renderer.draw_texture();
    self.renderer.present();
}

pub fn limit_fps(self: *Self, fps: u32) void {
    const end_time = sdl.c.SDL_GetTicks64();
    const time_difference: u64 = end_time - self.start_time;
    // std.log.debug("time_diff: {d}", .{time_difference});
    const wait_time: i64 = 1000 / fps - @as(i64, @intCast(time_difference));
    if (wait_time > 0)
        sdl.c.SDL_Delay(@intCast(wait_time));
    self.start_time = end_time;
}

pub fn draw_pixel(self: Self, x: i32, y: i32, col: math.Vec3) !void {
    try self.renderer.draw_pixel(x, y, @intFromFloat(col.x * 255), @intFromFloat(col.y * 255), @intFromFloat(col.z * 255), 255);
}

pub fn pixel_color(self: Self, x: i32, y: i32) math.Vec3 {
    const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(self.window.width)) * 2 - 1;
    const scaled_y: f32 = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(self.window.height)) * 2 - 1;

    const origin = math.vec3(0, 0, 1);
    const direction = math.vec3(scaled_x, scaled_y, -1);

    const r = 0.5;

    const a: f32 = direction.dot(direction);
    const b: f32 = 2 * origin.dot(direction);
    const c: f32 = origin.dot(origin) - r * r;

    const discriminant = b * b - 4 * a * c;

    if (discriminant > 0) {
        // const t0: f32 = (-b + std.math.sqrt(discriminant)) / (2 * a);
        const t1: f32 = (-b - std.math.sqrt(discriminant)) / (2 * a);

        const pos = direction.scale(t1).add(origin).normalize();
        const light = math.vec3(1, -1, 1).normalize();
        const color = 1 - ((pos.dot(light) + 1) / 2);
        return .{
            .x = color,
            .y = color,
            .z = color,
        };
    } else {
        return .{ .x = 0, .y = 0, .z = 0 };
    }
}
