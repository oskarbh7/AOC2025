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

    pub fn init(arena: std.mem.Allocator, rows: u64, cols: u64, char_init: u8) Matrix {
        const buf = arena.alloc(u8, rows * cols) catch unreachable;
        @memset(buf, char_init);
        return .{ .buf = buf, .cols = cols, .rows = rows };
    }

    pub fn get(self: *const Matrix, i: u64, j: u64) u8 {
        return self.buf[i * self.cols + j];
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
                const tmp = self.get(i, j);
                self.set(i, j, self.get(j, i));
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
                    sum += self.get(i, k) * self.get(k, i);
                }
                M.set(i, j, sum);
            }
        }

        @memcpy(self.buf, buf);
    }

    pub fn rotateCW(self: Matrix, arena: std.mem.Allocator) Matrix {
        const cols = self.rows;
        const rows = self.cols;
        const buf = arena.alloc(u8, cols * rows) catch unreachable;
        for (0..self.rows) |i| {
            for (0..self.cols) |j| {
                buf[j * cols + (cols - i - 1)] = self.buf[i * cols + j];
            }
        }
        return .{ .buf = buf, .cols = cols, .rows = rows };
    }

    pub fn flipH(self: Matrix, arena: std.mem.Allocator) Matrix {
        const buf = arena.alloc(u8, self.cols * self.rows) catch unreachable;
        @memcpy(buf, self.buf);
        const M: Matrix = .{ .buf = buf, .cols = self.cols, .rows = self.rows };

        for (0..self.rows / 2) |i| {
            for (0..self.cols) |j| {
                const i_inv = self.rows - i - 1;
                const tmp = M.get(i, j);
                M.set(i, j, M.get(i_inv, j));
                M.set(i_inv, j, tmp);
            }
        }

        return M;
    }

    pub fn flipV(self: Matrix, arena: std.mem.Allocator) Matrix {
        const buf = arena.alloc(u8, self.cols * self.rows) catch unreachable;
        @memcpy(buf, self.buf);
        const M: Matrix = .{ .buf = buf, .cols = self.cols, .rows = self.rows };

        for (0..self.rows) |i| {
            for (0..self.cols / 2) |j| {
                const j_inv = self.rows - j - 1;
                const tmp = M.get(i, j);
                M.set(i, j, M.get(i, j_inv));
                M.set(i, j_inv, tmp);
            }
        }

        return M;
    }

    pub fn toString(self: *const Matrix) []u8 {
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
                    w.print("{c: >3}", .{self.get(i - 2, j - 1)}) catch unreachable;
                }
            }
            w.print("\n", .{}) catch unreachable;
        }
        return buf[0..w.end];
    }
};
