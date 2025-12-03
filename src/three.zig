//!
//!
//! day three
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const input = @import("input.zig");

var debug_allocator = @import("std").heap.DebugAllocator(.{}).init;
const gpa = debug_allocator.allocator();

pub fn run() !void {
    try first();
    try second();
}

fn parseInput(in: []const u8) !ArrayList([]const u8) {
    var lines: ArrayList([]const u8) = .empty;
    var anchor: u64 = 0;
    for (0..in.len) |i| {
        const char = in[i];
        switch (char) {
            '\n' => {
                try lines.append(gpa, in[anchor..i]);
                anchor = i + 1;
            },
            else => {},
        }
    }
    return lines;
}

fn first() !void {
    input.header(3, 1);
    const in = try input.get(3);
    const lines = try parseInput(in);

    var sum: u64 = 0;
    for (lines.items) |line| {
        var one: u8 = 0;
        var two: u8 = 0;
        for (0..line.len) |i| {
            const char = line[i] - '0';
            if (char > one and i < line.len - 1) {
                one = char;
                two = 0;
            } else {
                if (char > two) {
                    two = char;
                }
            }
        }
        sum += one * 10 + two;
    }

    std.debug.print("Sum of battery banks' best joltage: {}\n", .{sum});
}

fn second() !void {
    input.header(3, 2);
    const in = try input.get(3);
    const lines = try parseInput(in);

    const battery_num = 12;
    var batteries: [battery_num]u8 = @splat(0);

    var sum: u64 = 0;
    for (lines.items) |line| {
        @memset(&batteries, 0);
        for (0..line.len) |i| {
            const battery_value = line[i] - '0';
            const remaining = line.len - i - 1;
            const earliest_candidate_idx = if (remaining < battery_num) battery_num - remaining - 1 else 0;
            for (earliest_candidate_idx..battery_num) |j| {
                const candidate_value = batteries[j];
                if (candidate_value < battery_value) {
                    batteries[j] = battery_value;
                    @memset(batteries[j + 1 ..], 0);
                    break;
                }
            }
        }

        const batteries_sum: u64 = blk: {
            var bs: u64 = 0;
            for (0..battery_num) |i| {
                bs *= 10;
                bs += batteries[i];
            }
            break :blk bs;
        };
        sum += batteries_sum;
    }

    std.debug.print("Sum of battery banks' best joltage: {}\n", .{sum});
}
