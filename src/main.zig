const std = @import("std");

const Display = @import("display.zig");
const Event = @import("event.zig");

const FPS = 60;

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 800;

pub fn main() !void {
    var display = try Display.init("raytraier", SCREEN_WIDTH, SCREEN_HEIGHT);
    defer display.deinit();

    var event = Event.init();

    while (!event.should_quit) {
        event.poll_events();

        try display.start_drawing();
        try display.clear();

        for (0..SCREEN_HEIGHT) |y| {
            for (0..SCREEN_WIDTH) |x| {
                try display.draw_pixel(@intCast(x), @intCast(y), display.pixel_color(@intCast(x), @intCast(y)));
            }
        }

        try display.end_drawing();

        display.limit_fps(FPS);
    }
}
