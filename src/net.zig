//!
//!
//! fetch input data
//!
//!

const std = @import("std");
const fs = @import("fs.zig");

var debug_allocator = @import("std").heap.DebugAllocator(.{}).init;
const gpa = debug_allocator.allocator();

pub fn fetch(url: []const u8) ![]u8 {
    var response_writer: std.Io.Writer.Allocating = .init(gpa);

    const session_cookie = try fs.read(".secrets");

    var client: std.http.Client = .{ .allocator = gpa };
    const uri = try std.Uri.parse(url);
    const fetch_result = try client.fetch(
        .{
            .location = .{ .uri = uri },
            .response_writer = &response_writer.writer,
            .extra_headers = &.{
                .{
                    .name = "Cookie",
                    .value = session_cookie,
                },
            },
        },
    );

    const response_slice = response_writer.writer.buffer[0..response_writer.writer.end];

    if (fetch_result.status == .ok) {
        return response_slice;
    } else {
        std.debug.print("Error in fetch(): {s}\n", .{response_slice});
        return error.NotFound;
    }
}
