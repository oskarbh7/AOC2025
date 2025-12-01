//!
//!
//! Get your input
//!
//!

const std = @import("std");
const fs = @import("fs.zig");
const net = @import("net.zig");

pub fn header(day: u32, n: u32) void {
    const str =
        \\
        \\==============
        \\Advent of Code
        \\  Day {}
        \\  Problem {}
        \\==============
        \\
    ;
    std.debug.print(str ++ "\n", .{ day, n });
}

pub fn get(day: u64) ![]u8 {
    _ = std.fs.cwd().openDir("input", .{}) catch |e| {
        switch (e) {
            error.FileNotFound => {
                std.debug.print("get(): input dir not found, creating...\n", .{});
                try std.fs.cwd().makeDir("input");
            },
            else => return e,
        }
    };

    var input_path_buffer: [1 << 10]u8 = undefined;
    const input_path = try std.fmt.bufPrint(&input_path_buffer, "input/{}.txt", .{day});

    const input = fs.read(input_path) catch |e| {
        switch (e) {
            error.FileNotFound => {
                var url_buffer: [1 << 10]u8 = undefined;
                const url = try std.fmt.bufPrint(
                    &url_buffer,
                    "https://adventofcode.com/2025/day/{}/input",
                    .{day},
                );
                const response = try net.fetch(url);
                const input_file = try std.fs.cwd().createFile(input_path, .{ .truncate = true });
                try input_file.writeAll(response);
                return response;
            },
            else => return e,
        }
    };

    return input;
}
