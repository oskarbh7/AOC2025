//!
//!
//! day nine
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const HashMap = @import("std").AutoHashMap;
const input = @import("input.zig");
const print = @import("std").debug.print;

const Vec = @Vector(2, i64);
const Edge = [2]Vec;

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
}

fn first(arena: std.mem.Allocator) !void {
    input.header(9, 1);
    // const in = try input.get(9);
    const in =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
        \\
    ;

    const points = try parseInput(arena, in);
    print("{any}\n", .{points});

    // print("Largest possible rectangle: {}\n", .{max});
}

fn second(arena: std.mem.Allocator) !void {
    input.header(9, 2);
    // const in = try input.get(9);
    const in =
        \\7,1
        \\11,1
        \\11,7
        \\9,7
        \\9,5
        \\2,5
        \\2,3
        \\7,3
        \\
    ;

    const points = try parseInput(arena, in);
    print("{any}\n", .{points});

    // print("Largest possible rectangle area: {}\n", .{area_max});
}

fn parseInput(arena: std.mem.Allocator, in: []const u8) ![]Vec {
    var point_list: ArrayList(Vec) = .empty;
    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var p: Vec = @splat(0);
        var line_it = std.mem.splitScalar(u8, line, ',');
        while (line_it.next()) |coord| {
            if (coord.len == 0) {
                break;
            }

            if (p[0] == 0) {
                p[0] = try std.fmt.parseInt(i64, coord, 10);
            } else {
                p[1] = try std.fmt.parseInt(i64, coord, 10);
            }
        }

        try point_list.append(arena, p);
    }

    return try point_list.toOwnedSlice(arena);
}
