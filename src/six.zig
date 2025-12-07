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
    input.header(6, 3);
    const in = try input.get(6);
    const M = try toLineMat(in);
    defer gpa.free(M.matrix);

    var op: u8 = ' ';
    var sum_cur: u64 = 0;
    var sum_total: u64 = 0;
    for (0..M.cols) |i| {
        if (op == ' ') {
            op = parseOp(M.matrix, i);
            sum_cur = switch (op) {
                '*' => 1,
                '+' => 0,
                else => unreachable,
            };
        }

        const col_num = parseIntV(M.matrix, i);
        if (col_num == 0) {
            sum_total += sum_cur;
            op = ' ';
            continue;
        }

        sum_cur = switch (op) {
            '*' => sum_cur * col_num,
            '+' => sum_cur + col_num,
            else => unreachable,
        };
    }
    sum_total += sum_cur;

    std.debug.print("Grand total: {}\n", .{sum_total});
}

fn toLineMat(buf: []const u8) !struct { matrix: [][]const u8, rows: u64, cols: u64 } {
    const row_count = std.mem.count(u8, buf, "\n");
    const row_len = if (std.mem.indexOf(u8, buf, "\n")) |i| i else unreachable;
    var mat = try gpa.alloc([]const u8, row_count);

    var line_it = std.mem.splitScalar(u8, buf, '\n');
    for (0..row_count) |i| {
        const line = line_it.next();
        if (line) |l| {
            if (l.len == 0) {
                break;
            }
            mat[i] = l;
        } else {
            break;
        }
    }

    return .{ .matrix = mat, .cols = row_len, .rows = row_count };
}

fn parseIntV(buf: [][]const u8, col_idx: u64) u64 {
    var bufv = gpa.alloc(u8, buf.len) catch unreachable;
    defer gpa.free(bufv);
    @memset(bufv, ' ');

    for (0..buf.len) |i| {
        bufv[i] = buf[i][col_idx];
    }

    return std.fmt.parseInt(u64, std.mem.trim(u8, bufv, " *+"), 10) catch 0;
}

fn parseOp(buf: [][]const u8, col_idx: u64) u8 {
    return buf[buf.len - 1][col_idx];
}
