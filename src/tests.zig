//!
//!
//! tests
//!
//!

const std = @import("std");
comptime {
    _ = @import("one.zig");
    _ = @import("two.zig");
    _ = @import("three.zig");
}
