//!
//!
//! day seven
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const input = @import("input.zig");

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
}

fn first(arena: std.mem.Allocator) !void {
    input.header(7, 1);
    const in = try input.get(7);

    const M = try strToMat(arena, in);

    var splits: u64 = 0;
    for (1..M.row_count) |i| {
        const row_above = M.rows[i - 1];
        var row_current = M.rows[i];

        for (0..M.col_count) |j| {
            const char_above = row_above[j];
            const char_current = row_current[j];

            if (char_above == 'S' or char_above == '|') {
                if (char_current == '^') {
                    splits += 1;
                    if (j > 0) {
                        row_current[j - 1] = '|';
                    }
                    if (j < M.col_count - 1) {
                        row_current[j + 1] = '|';
                    }
                } else {
                    row_current[j] = '|';
                }
            }
        }
    }

    std.debug.print("Grand total splits: {}\n", .{splits});
}

const Point = struct { i: i64, j: i64 };
var mem: std.AutoHashMap(Point, u64) = undefined;

fn second(arena: std.mem.Allocator) !void {
    input.header(7, 2);
    mem = .init(arena);
    const in = try input.get(7);

    const view_2D: View2D = .init(in);
    const beam_idx = if (std.mem.indexOf(u8, view_2D.buf, "S")) |i| i else unreachable;

    const timelines = secondRec(view_2D, 1, @intCast(beam_idx));

    std.debug.print("Grand total timelines: {}\n", .{timelines});
}

fn secondRec(view: View2D, row: i64, beam_idx: i64) u64 {
    if (mem.get(.{ .i = row, .j = beam_idx })) |mem_res| return mem_res;

    if (row == view.row_count) {
        return 1;
    }

    if (!view.inBounds(row, beam_idx)) {
        return 0;
    }

    // std.debug.print("secondRec({}, {}), current row: {s}\n", .{ row, beam_idx, view.getRow(@intCast(row)) });

    const res = switch (view.idx(@intCast(row), @intCast(beam_idx)).*) {
        '^' => secondRec(view, row + 1, beam_idx - 1) + secondRec(view, row + 1, beam_idx + 1),
        else => secondRec(view, row + 1, beam_idx),
    };

    mem.put(.{ .i = row, .j = beam_idx }, res) catch unreachable;
    return res;
}

const View2D = struct {
    buf: []const u8,
    row_count: u64,
    col_count: u64,

    pub fn init(buf: []const u8) View2D {
        const row_len = if (std.mem.indexOf(u8, buf, "\n")) |l| l else unreachable;
        const row_count = std.mem.count(u8, buf, "\n");
        return .{ .buf = buf, .row_count = row_count, .col_count = row_len };
    }

    pub fn idx(self: *const View2D, i: u64, j: u64) *const u8 {
        return &self.buf[i * (self.col_count + 1) + j];
    }

    pub fn inBounds(self: *const View2D, i: i64, j: i64) bool {
        return i >= 0 and i < self.row_count and j >= 0 and j < self.col_count;
    }

    pub fn getRow(self: *const View2D, i: u64) []const u8 {
        return self.buf[i * (self.col_count + 1) .. (i + 1) * (self.col_count + 1)];
    }
};

fn strToMat(
    arena: std.mem.Allocator,
    buf: []const u8,
) !struct {
    rows: [][]u8,
    backing: []u8,
    row_count: u64,
    col_count: u64,
} {
    const row_len = if (std.mem.indexOf(u8, buf, "\n")) |l| l else unreachable;
    const row_count = std.mem.count(u8, buf, "\n");

    const buf_copy = try arena.alloc(u8, buf.len);
    std.mem.copyForwards(u8, buf_copy, buf);

    var rows = try arena.alloc([]u8, row_count);
    var row_idx: u64 = 0;
    var buf_it = std.mem.splitScalar(u8, buf_copy, '\n');
    while (buf_it.next()) |line| {
        if (line.len == 0) {
            break;
        }
        rows[row_idx] = @constCast(line);
        row_idx += 1;
    }

    return .{
        .rows = rows,
        .backing = buf_copy,
        .row_count = row_count,
        .col_count = row_len,
    };
}
