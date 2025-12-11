//!
//!
//!
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const print = @import("std").debug.print;
const common = @import("common.zig");

const one = @import("one.zig");
const two = @import("two.zig");
const three = @import("three.zig");
const four = @import("four.zig");
const five = @import("five.zig");
const six = @import("six.zig");
const seven = @import("seven.zig");
const eight = @import("eight.zig");
const nine = @import("nine.zig");
const ten = @import("ten.zig");
const eleven = @import("eleven.zig");

const page_allocator = @import("std").heap.page_allocator;
var arena_allocator = @import("std").heap.ArenaAllocator.init(page_allocator);

pub fn main() !void {
    const arena = arena_allocator.allocator();
    defer _ = arena_allocator.reset(.retain_capacity);

    // try one.run();
    // try two.run();
    // try three.run();
    // try four.run();
    // try five.run();
    // try six.run();
    // try seven.run(arena);
    // try eight.run(arena);
    try nine.run(arena);
    // try ten.run(arena);
    // try eleven.run(arena);
}
