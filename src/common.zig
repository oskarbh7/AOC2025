//!
//!
//!
//!
//!

const std = @import("std");

pub const BUF_NUM = 1 << 8;
pub const BUF_SIZE = 1 << 8;

var buffers: [BUF_NUM][BUF_SIZE]u8 = undefined;
var buffers_idx: u64 = 0;

pub fn sprintf(comptime format: []const u8, args: anytype) []u8 {
    return std.fmt.bufPrint(str(), format, args) catch unreachable;
}

pub fn vecStr(comptime T: type, vec: []const T) []u8 {
    const type_info = @typeInfo(@TypeOf(T));

    var buf = str();
    var buf_idx: u64 = 1;
    switch (type_info) {
        else => {
            for (vec) |v| {
                const buf_slice = switch (@typeInfo(@TypeOf(T))) {
                    .int,
                    .comptime_int,
                    .float,
                    .comptime_float,
                    => std.fmt.bufPrint(buf[buf_idx..], "{}", .{v}) catch unreachable,
                    else => std.fmt.bufPrint(buf[buf_idx..], "{f}", .{v}) catch unreachable,
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

//
// Internal
//

fn str() []u8 {
    defer buffers_idx = (buffers_idx + 1) % buffers.len;
    return &buffers[buffers_idx];
}
