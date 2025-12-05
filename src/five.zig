//!
//!
//! day five
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

const Range = struct { min: u64, max: u64 };

fn parseInput(in: []const u8) !struct { ArrayList(u64), ArrayList(Range) } {
    var ranges: ArrayList(Range) = .empty;
    var ids: ArrayList(u64) = .empty;

    var first_pass = true;
    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (line.len == 0) {
            if (first_pass) {
                first_pass = false;
                continue;
            } else {
                break;
            }
        }

        if (first_pass) {
            const middle = if (std.mem.indexOf(u8, line, "-")) |m| m else unreachable;
            const r: Range = .{
                .min = try std.fmt.parseInt(u64, line[0..middle], 10),
                .max = try std.fmt.parseInt(u64, line[middle + 1 ..], 10),
            };
            try ranges.append(gpa, r);
        } else {
            try ids.append(gpa, try std.fmt.parseInt(u64, line, 10));
        }
    }

    return .{ ids, ranges };
}

fn first() !void {
    input.header(5, 1);
    const in = try input.get(5);

    const ids, const ranges = try parseInput(in);
    var sum: u64 = 0;

    outer: for (ids.items) |id| {
        for (ranges.items) |range| {
            if (range.min <= id and id <= range.max) {
                sum += 1;
                continue :outer;
            }
        }
    }

    std.debug.print("Fresh ingredients {}\n", .{sum});
}

fn second() !void {
    input.header(5, 2);
    const in = try input.get(5);

    var ranges: ArrayList(Range) = .empty;
    var in_it = std.mem.splitScalar(u8, in, '\n');
    var k: u64 = 0;
    while (in_it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const middle = if (std.mem.indexOf(u8, line, "-")) |m| m else unreachable;
        var range_new: Range = .{
            .min = try std.fmt.parseInt(u64, line[0..middle], 10),
            .max = try std.fmt.parseInt(u64, line[middle + 1 ..], 10),
        };

        var i: u64 = 0;
        while (i < ranges.items.len) {
            const range_old = ranges.items[i];

            const do_overlap =
                (range_old.min <= range_new.min and range_new.min <= range_old.max) or
                (range_old.min <= range_new.max and range_new.max <= range_old.max);
            if (!do_overlap) {
                i += 1;
                continue;
            }

            _ = ranges.orderedRemove(i);

            range_new.min = @min(range_old.min, range_new.min);
            range_new.max = @max(range_old.max, range_new.max);
        }

        k += 1;
        try ranges.append(gpa, range_new);
    }

    var sum: u64 = 0;
    for (ranges.items) |range| {
        sum += range.max - range.min + 1;
    }

    std.debug.print("Fresh ingredients {}\n", .{sum});
}
