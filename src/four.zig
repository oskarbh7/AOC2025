//!
//!
//! day four
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const input = @import("input.zig");

var debug_allocator = @import("std").heap.DebugAllocator(.{}).init;
const gpa = debug_allocator.allocator();

pub fn run() !void {
    try first();
    try second();
}

fn parseInput(in: []const u8) ![][]u8 {
    const line_no: u64 = std.mem.count(u8, in, "\n");
    const line_len: u64 = if (std.mem.indexOf(u8, in, "\n")) |i| i else unreachable;
    var in_it = std.mem.splitScalar(u8, in, '\n');

    var arr: [][]u8 = try gpa.alloc([]u8, line_no);
    for (0..line_no) |i| {
        const line = if (in_it.next()) |l| l else unreachable;
        arr[i] = try gpa.alloc(u8, line_len);
        @memcpy(arr[i], line);
    }

    return arr;
}

fn first() !void {
    input.header(4, 1);
    const in = try input.get(4);
    const grid = try parseInput(in);

    var sum: u64 = 0;
    for (0..grid.len) |i| {
        const grid_line = grid[i];
        for (0..grid_line.len) |j| {
            if (grid[i][j] != '@') {
                continue;
            }
            const neighbor_count = countNeighbors(grid, i, j);
            sum += if (neighbor_count < 4) 1 else 0;
        }
    }

    std.debug.print("Rolls of paper: {}\n", .{sum});
}

fn second() !void {
    input.header(4, 2);
    const in = try input.get(4);
    const grid = try parseInput(in);

    var sum: u64 = 0;
    while (true) {
        var removed: u64 = 0;
        for (0..grid.len) |i| {
            for (0..grid[i].len) |j| {
                if (grid[i][j] != '@') {
                    continue;
                }

                const neighbor_count = countNeighbors(grid, i, j);
                if (neighbor_count >= 4) {
                    continue;
                }

                grid[i][j] = 'x';
                removed += 1;
                sum += 1;
            }
        }

        if (removed == 0) {
            break;
        }
    }

    std.debug.print("Rolls of paper: {}\n", .{sum});
}

fn pri(grid: [][]u8) void {
    for (0..grid.len) |i| {
        for (0..grid[0].len) |j| {
            std.debug.print("{c}", .{grid[i][j]});
        }
        std.debug.print("\n", .{});
    }
}

fn countNeighbors(grid: [][]u8, i: u64, j: u64) u64 {
    var count: u64 = 0;
    const i_min = i -| 1;
    const j_min = j -| 1;
    const i_max = @min(i + 2, grid.len);
    const j_max = @min(j + 2, grid[0].len);
    for (i_min..i_max) |i_cur| {
        for (j_min..j_max) |j_cur| {
            if (i_cur == i and j_cur == j) {
                continue;
            }
            count += if (grid[i_cur][j_cur] == '@') 1 else 0;
        }
    }
    return count;
}

fn isInBounds(grid: [][]u8, i: u64, j: u64) bool {
    return i >= 0 and i < grid.len and j >= 0 and j < grid[0].len;
}
