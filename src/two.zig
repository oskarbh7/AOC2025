//!
//!
//! day two
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

const Range = struct {
    min: u64 = 0,
    max: u64 = 0,
};

fn parseInput(in: []u8) !ArrayList(Range) {
    var ranges: ArrayList(Range) = .empty;

    try ranges.append(gpa, .{});
    var range_current: Range = .{};
    var in_anchor: u64 = 0;
    for (0..in.len) |i| {
        const char = in[i];
        switch (char) {
            '-' => {
                range_current.min = try std.fmt.parseInt(u64, in[in_anchor..i], 10);
                in_anchor = i + 1;
            },

            ',', '\n' => {
                range_current.max = try std.fmt.parseInt(u64, in[in_anchor..i], 10);
                try ranges.append(gpa, range_current);
                in_anchor = i + 1;
            },

            '0'...'9' => {},

            else => unreachable,
        }
    }

    return ranges;
}

fn first() !void {
    input.header(2, 1);
    const in = try input.get(2);

    var ranges = try parseInput(in);
    defer ranges.clearAndFree(gpa);

    var count: u64 = 0;
    var sum: u64 = 0;
    for (ranges.items) |r| {
        for (r.min..r.max + 1) |i| {
            if (!isValid(i)) {
                count += 1;
                sum += i;
            }
        }
    }

    std.debug.print("Number of invalid IDs was {}, and their sum is: {}\n", .{ count, sum });
}

fn isValid(id: u64) bool {
    var id_buffer: [20]u8 = undefined;
    const id_slice = std.fmt.bufPrint(&id_buffer, "{}", .{id}) catch unreachable;

    if (id_slice.len % 2 != 0) {
        return true;
    }
    for (0..id_slice.len / 2) |i| {
        const f = id_slice[i];
        const s = id_slice[i + id_slice.len / 2];
        if (f != s) {
            return true;
        }
    }
    return false;
}

fn second() !void {
    input.header(2, 2);
    const in = try input.get(2);

    var ranges = try parseInput(in);
    defer ranges.clearAndFree(gpa);

    var count: u64 = 0;
    var sum: u64 = 0;
    for (ranges.items) |r| {
        for (r.min..r.max + 1) |i| {
            const is_valid = isValid2(i);
            if (is_valid) continue;
            count += 1;
            sum += i;
        }
    }

    std.debug.print("Number of invalid IDs was {}, and their sum is: {}\n", .{ count, sum });
}

fn isValid2(id: u64) bool {
    var id_buffer: [20]u8 = undefined;
    const id_slice = std.fmt.bufPrint(&id_buffer, "{}", .{id}) catch unreachable;

    if (id_slice.len < 2) {
        return true;
    }

    for (1..id_slice.len / 2 + 1) |i| {
        if (isStringMadeOfSubstring(id_slice, id_slice[0..i])) {
            return false;
        }
    }

    return true;
}

fn isStringMadeOfSubstring(str: []const u8, sub_str: []const u8) bool {
    if (str.len % sub_str.len != 0) {
        return false;
    }
    const n: u64 = str.len / sub_str.len;
    return substringCount(str, sub_str) == n;
}

fn substringCount(str: []const u8, sub_str: []const u8) u64 {
    var count: u64 = 0;
    for (0..str.len / sub_str.len) |i| {
        if (std.mem.eql(u8, str[i * sub_str.len .. (i + 1) * sub_str.len], sub_str)) {
            count += 1;
        }
    }
    return count;
}

test "substring count" {
    const str_0 = "abc";
    const str_1 = "abcabcabcabc";
    std.debug.assert(substringCount(str_1, str_0) == 4);
}

test "isStringMadeOfSubstring" {
    const str_0 = "abc";
    const str_1 = "abcabcabcabc";
    const str_2 = "abcabcabcabca";
    const str_3 = "abcabc";

    const str_4 = "1188511885";
    const str_5 = "11885";

    const str_6 = "99";
    const str_7 = "9";

    std.debug.assert(isStringMadeOfSubstring(str_1, str_0));
    std.debug.assert(!isStringMadeOfSubstring(str_2, str_0));
    std.debug.assert(isStringMadeOfSubstring(str_3, str_0));
    std.debug.assert(isStringMadeOfSubstring(str_4, str_5));
    std.debug.assert(isStringMadeOfSubstring(str_6, str_7));
}

test "isValid2" {
    const num_0 = 824824824;
    const num_1 = 1188511885;
    const num_2 = 565656;
    const num_3 = 99;

    std.debug.assert(!isValid2(num_0));
    std.debug.assert(!isValid2(num_1));
    std.debug.assert(!isValid2(num_2));
    std.debug.assert(!isValid2(num_3));
}

fn as(comptime T: type, n: anytype) T {
    return @as(T, @intCast(n));
}
