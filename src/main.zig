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

const pa = @import("std").heap.page_allocator;
const alloc_0 = @import("std").heap.ArenaAllocator.init(pa);
var gpa_1 = @import("std").heap.DebugAllocator(.{}).init;
const alloc_1 = gpa_1.allocator();

pub fn main() !void {
    // try one.run();
    // try two.run();
    // try three.run();
    try four.run();
}
