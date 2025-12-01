//!
//!
//! file stuff
//!
//!

const std = @import("std");

const MAX_BYTES = 1 << 16;
var buffer: [MAX_BYTES]u8 = undefined;

pub fn read(path: []const u8) ![]u8 {
    const file_content = try std.fs.cwd().readFile(path, &buffer);
    return file_content;
}
