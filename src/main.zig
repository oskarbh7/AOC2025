//!
//!
//!
//!
//!

const std = @import("std");

const one = @import("one.zig");
const two = @import("two.zig");
const three = @import("three.zig");

pub fn main() !void {
    // try one.run();
    // try two.run();
    try three.run();
}
