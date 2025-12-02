//!
//!
//!
//!
//!

const std = @import("std");

const one = @import("one.zig");
const two = @import("two.zig");

pub fn main() !void {
    try one.run();
    try two.run();
}
