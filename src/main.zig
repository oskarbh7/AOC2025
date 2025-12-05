//!
//!
//!
//!
//!

const std = @import("std");

const one = @import("one.zig");
const two = @import("two.zig");
const three = @import("three.zig");
const four = @import("four.zig");
const five = @import("five.zig");

var gpa = @import("std").heap.DebugAllocator(.{}).init;
const allocator = gpa.allocator();

pub fn main() !void {
    // try one.run();
    // try two.run();
    // try three.run();
    // try four.run();
    try five.run();
}
