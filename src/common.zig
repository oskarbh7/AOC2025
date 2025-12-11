//!
//!
//!
//!
//!

const std = @import("std");

const string = []const u8;

pub const BUF_NUM = 1 << 4;
pub const BUF_SIZE = 1 << 12;

var buffers: [BUF_NUM][BUF_SIZE]u8 = undefined;
var buffers_idx: u64 = 0;

pub fn sprintf(comptime format: []const u8, args: anytype) []u8 {
    return std.fmt.bufPrint(getBuf(), format, args) catch unreachable;
}

pub fn strEql(a: string, b: string) bool {
    return std.mem.eql(u8, a, b);
}

pub fn arrContainsStr(haystack: []string, needle: string) bool {
    for (haystack) |h| {
        if (std.mem.eql(u8, needle, h)) {
            return true;
        }
    }
    return false;
}

pub fn arrToStr(comptime T: type, vec: []const T) []u8 {
    const type_info = @typeInfo(@TypeOf(T));

    var buf = getBuf();
    var buf_idx: u64 = 1;
    switch (type_info) {
        else => {
            for (0..vec.len) |i| {
                const v = vec[i];
                const trailing = if (i < vec.len - 1) ", " else "";
                const buf_slice = switch (@typeInfo(@TypeOf(T))) {
                    .int,
                    .comptime_int,
                    .float,
                    .comptime_float,
                    => std.fmt.bufPrint(buf[buf_idx..], "{}{s}", .{ v, trailing }) catch unreachable,
                    .pointer => std.fmt.bufPrint(buf[buf_idx..], "{s}{s}", .{ v, trailing }) catch unreachable,
                    else => std.fmt.bufPrint(buf[buf_idx..], "{s}{s}", .{ v, trailing }) catch unreachable,
                };
                buf_idx += buf_slice.len;
            }
        },
    }

    buf[0] = '[';
    buf[buf_idx] = ']';
    return buf[0 .. buf_idx + 1];
}

pub fn vecCopyAlc(arena: std.mem.Allocator, comptime T: type, vec: []const T) []T {
    const v = arena.alloc(T, vec.len) catch unreachable;
    @memcpy(v, vec);
    return v;
}

pub fn vecCopyBuf(comptime T: type, buf: []T, vec: []const T) []T {
    @memcpy(buf, vec);
    return buf;
}

pub fn getBuf() []u8 {
    defer buffers_idx = (buffers_idx + 1) % buffers.len;
    return &buffers[buffers_idx];
}

fn strJoin(arena: std.mem.Allocator, strings: [][]const u8) []u8 {
    var len: u64 = 0;
    for (strings) |str| {
        len += str.len;
    }
    const buf = arena.alloc(u8, len) catch unreachable;
    var i: u64 = 0;
    for (strings) |str| {
        @memcpy(buf[i .. i + str.len], str);
        i += str.len;
    }
    return buf;
}

fn strAppend(arena: std.mem.Allocator, str: string, tail: string) []u8 {
    const buf = arena.alloc(u8, str.len + tail.len) catch unreachable;
    @memcpy(buf[0..str.len], str);
    @memcpy(buf[str.len..], tail);
    return buf;
}
