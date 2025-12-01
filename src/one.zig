//!
//!
//! day one
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const input = @import("input.zig");

var debug_allocator = @import("std").heap.DebugAllocator(.{}).init;
const gpa = debug_allocator.allocator();

const Direction = enum { left, right, none };
const Dial = struct {
    dir: Direction = .none,
    n: u32 = 0,

    pub fn format(self: Dial, w: *std.Io.Writer) std.Io.Writer.Error!void {
        try w.print("[{s}, {}]", .{ @tagName(self.dir), self.n });
    }
};

pub fn run() !void {
    try first();
    try second();
}

fn first() !void {
    input.header(1, 1);

    const in = try input.get(1);
    var dial_list: ArrayList(Dial) = .empty;

    var dial: Dial = .{};
    var num_buffer: [32]u8 = undefined;
    var num_buffer_idx: u32 = 0;
    for (in) |char| {
        switch (char) {
            'L' => dial.dir = .left,
            'R' => dial.dir = .right,
            '0'...'9' => {
                num_buffer[num_buffer_idx] = char;
                num_buffer_idx += 1;
            },
            '\n' => {
                dial.n = try std.fmt.parseInt(u32, num_buffer[0..num_buffer_idx], 10);
                try dial_list.append(gpa, dial);
                dial = .{};
                num_buffer_idx = 0;
            },
            else => unreachable,
        }
    }

    var dial_position: i32 = 50;
    var dial_position_at_0: u32 = 0;

    for (dial_list.items) |dial_current| {
        if (dial_current.dir == .left) {
            dial_position += as(i32, dial_current.n);
        } else {
            dial_position -= as(i32, dial_current.n);
        }
        dial_position = @mod(dial_position, 100);
        dial_position_at_0 += if (dial_position == 0) 1 else 0;
    }

    std.debug.print("dial was at 0 {} times...\n", .{dial_position_at_0});
}

fn second() !void {
    input.header(1, 2);

    const in = try input.get(1);
    var dial_list: ArrayList(Dial) = .empty;

    var dial: Dial = .{};
    var num_buffer: [32]u8 = undefined;
    var num_buffer_idx: u32 = 0;
    for (in) |char| {
        switch (char) {
            'L' => dial.dir = .left,
            'R' => dial.dir = .right,
            '0'...'9' => {
                num_buffer[num_buffer_idx] = char;
                num_buffer_idx += 1;
            },
            '\n' => {
                dial.n = try std.fmt.parseInt(u32, num_buffer[0..num_buffer_idx], 10);
                try dial_list.append(gpa, dial);
                dial = .{};
                num_buffer_idx = 0;
            },
            else => unreachable,
        }
    }

    var dial_position: i32 = 50;
    var dial_position_at_0: u32 = 0;

    for (dial_list.items) |dial_current| {
        const was_at_zero = dial_position == 0;
        if (dial_current.dir == .left) {
            dial_position += as(i32, dial_current.n);
        } else {
            dial_position -= as(i32, dial_current.n);
        }
        dial_position_at_0 += @abs(@divTrunc(dial_position, 100));
        dial_position_at_0 += if (dial_position <= 0 and !was_at_zero) 1 else 0;
        dial_position = @mod(dial_position, 100);
    }

    std.debug.print("dial crossed 0 {} times...\n", .{dial_position_at_0});
}

fn as(comptime T: type, n: anytype) T {
    return @as(T, @intCast(n));
}
