//!
//!
//!
//!
//!

const std = @import("std");
const common = @import("common.zig");

pub const Matrix = struct {
    buf: []u8,
    cols: u64,
    rows: u64,

    pub fn idx(self: *const Matrix, i: u64, j: u64) u8 {
        return self.buf[i * self.cols + j];
    }

    pub fn idxPtr(self: *const Matrix, i: u64, j: u64) *u8 {
        return &self.buf[i * self.cols + j];
    }

    pub fn set(self: *const Matrix, i: u64, j: u64, char: u8) void {
        self.buf[i * self.cols + j] = char;
    }

    pub fn transpose(self: *const Matrix) void {
        for (0..self.cols) |i| {
            for (0..self.rows) |j| {
                if (j <= i) {
                    continue;
                }
                const tmp = self.idx(i, j);
                self.set(i, j, self.idx(j, i));
                self.set(j, i, tmp);
            }
        }
    }

    pub fn sqr(self: *const Matrix, arena: std.mem.Allocator) void {
        const buf = arena.alloc(u8, self.cols * self.rows) catch unreachable;
        defer arena.free(buf);
        const M: Matrix = .{ .cols = self.cols, .rows = self.rows, .buf = buf };

        for (0..self.cols) |i| {
            for (0..self.rows) |j| {
                var sum: u8 = 0;
                for (0..self.cols) |k| {
                    sum += self.idx(i, k) * self.idx(k, i);
                }
                M.set(i, j, sum);
            }
        }

        @memcpy(self.buf, buf);
    }

    pub fn toStr(self: *const Matrix) []u8 {
        var buf = common.getBuf();
        var w: std.Io.Writer = .fixed(buf);
        for (0..self.rows + 3) |i| {
            for (0..self.cols + 2) |j| {
                if (i == 0) {
                    if (j == 0 or j == self.cols + 1) {
                        w.print("{c: >3}", .{' '}) catch unreachable;
                    } else {
                        w.print("{: >3}", .{j - 1}) catch unreachable;
                    }
                } else if (i == 1 or i == self.rows + 2) {
                    if (j == 0) {
                        w.print("{c: >3}", .{' '}) catch unreachable;
                    } else {
                        w.print("{s}", .{"-" ** 3}) catch unreachable;
                    }
                } else if (j == 0) {
                    w.print("{:>2}{c}", .{ i - 2, '|' }) catch unreachable;
                } else if (j == self.cols + 1) {
                    w.print("{c: >3}", .{'|'}) catch unreachable;
                } else {
                    w.print("{: >3}", .{self.idx(i - 2, j - 1)}) catch unreachable;
                }
            }
            w.print("\n", .{}) catch unreachable;
        }
        return buf[0..w.end];
    }
};
