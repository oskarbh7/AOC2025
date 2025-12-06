//!
//!
//! day six
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

fn first() !void {
    input.header(6, 1);
    const in = try input.get(6);

    var column_ops: ArrayList(u8) = .empty;
    defer column_ops.clearAndFree(gpa);
    var column_sums: ArrayList(u64) = .empty;
    defer column_sums.clearAndFree(gpa);

    var line_it = std.mem.splitScalar(u8, in, '\n');
    while (line_it.next()) |line| {
        if (std.mem.indexOfAny(u8, line, "*+") != null) {
            var column_it = std.mem.splitScalar(u8, line, ' ');
            while (column_it.next()) |column| {
                if (column.len == 0) {
                    continue;
                }
                try column_ops.append(gpa, column[0]);
                try column_sums.append(gpa, if (column[0] == '*') 1 else 0);
            }
        }
    }

    line_it.reset();
    while (line_it.next()) |line| {
        var column_it = std.mem.splitScalar(u8, line, ' ');
        var column_idx: u64 = 0;
        while (column_it.next()) |col| {
            if (col.len == 0) {
                continue;
            }

            if (std.mem.indexOfAny(u8, line, "*+") != null) {
                continue;
            }

            switch (column_ops.items[column_idx]) {
                '+' => column_sums.items[column_idx] += try std.fmt.parseInt(u64, col, 10),
                '*' => column_sums.items[column_idx] *= try std.fmt.parseInt(u64, col, 10),
                else => unreachable,
            }

            column_idx += 1;
        }
    }

    var sum: u64 = 0;
    for (column_sums.items) |s| {
        sum += s;
    }

    std.debug.print("Grand total: {}\n", .{sum});
}

fn second() !void {
    input.header(6, 2);
    const in = try input.get(6);

    var ops: ArrayList(u8) = .empty;
    defer ops.clearAndFree(gpa);
    var rows: ArrayList([]const u8) = .empty;
    defer rows.clearAndFree(gpa);
    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (std.mem.indexOfAny(u8, line, "*+") != null) {
            var line_it = std.mem.splitScalar(u8, line, ' ');
            while (line_it.next()) |line_col| {
                if (line_col.len == 0) {
                    continue;
                }
                try ops.append(gpa, line_col[0]);
            }
            break;
        }

        try rows.append(gpa, line);
    }

    var col_all_spaces = try gpa.alloc(bool, rows.items[0].len);
    defer gpa.free(col_all_spaces);
    @memset(col_all_spaces, true);
    for (rows.items) |row| {
        for (row, 0..) |char, i| {
            if (char != ' ') {
                col_all_spaces[i] = false;
            }
        }
    }

    const col_count = std.mem.count(bool, col_all_spaces, &.{true}) + 1;
    var col_indices = try gpa.alloc([2]u64, col_count);
    defer gpa.free(col_indices);
    var col_idx_prev: u64 = 0;
    var col_break_idx: u64 = 0;
    for (0..col_all_spaces.len) |i| {
        if (col_all_spaces[i]) {
            col_indices[col_break_idx][0] = col_idx_prev;
            col_indices[col_break_idx][1] = i;
            col_break_idx += 1;
            col_idx_prev = i + 1;
        }
    }
    col_indices[col_break_idx][0] = col_idx_prev;
    col_indices[col_break_idx][1] = rows.items[0].len;

    var col_numbers: ArrayList(ArrayList(u64)) = .empty;
    for (0..col_count) |_| {
        try col_numbers.append(gpa, .empty);
    }

    var sum: u64 = 0;
    for (0..col_count) |col_idx| {
        var col_total: u64 = if (ops.items[col_idx] == '*') 1 else 0;

        const col_start = col_indices[col_idx][0];
        const col_end = col_indices[col_idx][1];
        for (col_start..col_end) |line_idx| {
            var col_num_buffer: [32]u8 = undefined;
            var col_num_buffer_idx: u64 = 0;
            for (0..rows.items.len) |row_idx| {
                const char = rows.items[row_idx][line_idx];
                col_num_buffer[col_num_buffer_idx] = char;
                col_num_buffer_idx += 1;
            }

            const col_num_buffer_trim = std.mem.trim(u8, col_num_buffer[0..col_num_buffer_idx], " ");
            const col_num = try std.fmt.parseInt(u64, col_num_buffer_trim, 10);
            switch (ops.items[col_idx]) {
                '*' => col_total *= col_num,
                '+' => col_total += col_num,
                else => unreachable,
            }
        }
        sum += col_total;
    }

    std.debug.print("Grand total: {}\n", .{sum});
}
