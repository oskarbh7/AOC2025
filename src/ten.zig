//!
//!
//! day ten
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const HashMap = @import("std").AutoHashMap;
const input = @import("input.zig");
const print = @import("std").debug.print;

pub fn run(arena: std.mem.Allocator) !void {
    // try first(arena);
    try second(arena);
}

const MachineState = struct {
    lights: []bool,
    depth: u64,

    pub fn init(lights: []bool, depth: u64) MachineState {
        return .{ .lights = lights, .depth = depth };
    }
};

const MachineDescr = struct {
    lights: u64,
    buttons: []u64,
    reqs: []u64,

    pub fn parse(arena: std.mem.Allocator, line: []const u8) !MachineDescr {
        var lights: u64 = 0;
        var buttons: ArrayList(u64) = .empty;
        var reqs: ArrayList(u64) = .empty;

        var line_it = std.mem.splitScalar(u8, line, ' ');
        while (line_it.next()) |w| {
            const w_trim = w[1 .. w.len - 1];
            switch (w[0]) {
                '[' => {
                    for (w_trim, 0..) |c, i| {
                        // const idx = w_trim.len - i - 1;
                        if (c == '#') lights += try std.math.powi(u64, 2, i);
                    }
                },
                '(' => {
                    var bn: u64 = 0;
                    var w_it = std.mem.splitScalar(u8, w_trim, ',');
                    while (w_it.next()) |n| {
                        if (n.len == 0) break;
                        const idx = try std.fmt.parseInt(u8, n, 10);
                        bn += try std.math.powi(u64, 2, idx);
                    }
                    try buttons.append(arena, bn);
                },
                '{' => {
                    var w_it = std.mem.splitScalar(u8, w_trim, ',');
                    while (w_it.next()) |n| {
                        if (n.len == 0) break;
                        try reqs.append(arena, try std.fmt.parseInt(u64, n, 10));
                    }
                },
                else => break,
            }
        }

        return .{
            .lights = lights,
            .buttons = try buttons.toOwnedSlice(arena),
            .reqs = try reqs.toOwnedSlice(arena),
        };
    }
};

var bin_buffers: [1 << 8][64]u8 = undefined;
var bin_buffers_idx: u64 = 0;
fn printBin(n: u64) []const u8 {
    bin_buffers_idx = (bin_buffers_idx + 1) % bin_buffers.len;
    var bin_buf = &bin_buffers[bin_buffers_idx];
    @memset(bin_buf, ' ');
    for (0..64) |i| {
        const bit: u8 = @intCast((n >> @intCast(i)) % 2);
        const idx = 63 - i;
        bin_buf[idx] = bit + '0';
    }
    return std.mem.trimStart(u8, bin_buf, "0");
}

fn getNthBit(num: u64, n: u64) u8 {
    return @intCast((num >> @intCast(n)) % 2);
}

fn countBits(num: u64) u64 {
    var sum: u64 = 0;
    for (0..64) |i| {
        sum += getNthBit(num, i);
    }
    return sum;
}

fn first(arena: std.mem.Allocator) !void {
    input.header(10, 1);
    const in = try input.get(10);

    var sum: u64 = 0;
    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (line.len == 0) break;

        const machine_descr = try MachineDescr.parse(arena, line);
        const buttons = machine_descr.buttons;
        const N = try std.math.powi(u64, 2, buttons.len);
        var best: u64 = std.math.maxInt(u64);
        for (0..N) |i| {
            var lights: u64 = 0;

            for (buttons, 0..) |b, j| {
                const is_button_pressed = getNthBit(i, j);
                if (is_button_pressed > 0) {
                    lights ^= b;
                }
            }
            if (lights == machine_descr.lights) {
                best = @min(best, countBits(i));
            }
        }

        sum += best;
    }

    print("Result: {}\n", .{sum});
}

fn second(arena: std.mem.Allocator) !void {
    input.header(9, 2);
    print("{any}\n", .{arena.ptr});
    // const in = try input.get(9);
    const in =
        \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
        \\
    ;

    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (line.len == 0) break;

        const descr = try MachineDescr.parse(arena, line);
        print("{any}\n", .{descr});
    }

    // print("Largest possible rectangle: {}\n", .{max});
}

fn secondRec(
    arena: std.mem.Allocator,
    W: []u64,
    W_i: u64,
    V: [][]u64,
    T: []const u64,
    T_CUR: []u64,
    best: *u64,
) u64 {
    var sum_weights: u64 = 0;
    for (0..V.len) |i| {
        sum_weights += W[i];

        for (0..V[i].len) |j| {
            T_CUR[j] = W[i] * V[i][j];
        }
    }

    if (sum_weights >= best.*) {
        return 0;
    }

    var all_equal = true;
    for (0..T.len) |i| {
        if (T_CUR[i] > T[i]) {
            return 0;
        }
        if (T_CUR[i] != T[i]) {
            all_equal = false;
        }
    }

    if (all_equal) {
        best.* = sum_weights;
        return sum_weights;
    }
}
