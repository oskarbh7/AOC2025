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
    try first(arena);
    // try second(arena);
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
    reqs: u64,

    pub fn parse(arena: std.mem.Allocator, line: []const u8) !MachineDescr {
        var lights: u64 = 0;
        var buttons: ArrayList(u64) = .empty;
        var reqs: u64 = 0;

        var line_it = std.mem.splitScalar(u8, line, ' ');
        while (line_it.next()) |w| {
            const w_trim = w[1 .. w.len - 1];
            switch (w[0]) {
                '[' => {
                    for (w_trim, 0..) |c, i| {
                        // const idx = w_trim.len - i - 1;
                        if (c == '#') lights += try std.math.powi(u64, 2, i);
                    }
                    print("parsing lights array: {s} = {s}\n", .{ w_trim, printBin(lights) });
                },
                '(' => {
                    var bn: u64 = 0;
                    var w_it = std.mem.splitScalar(u8, w_trim, ',');
                    while (w_it.next()) |n| {
                        if (n.len == 0) break;
                        const idx = try std.fmt.parseInt(u8, n, 10);
                        bn += try std.math.powi(u64, 2, idx);
                    }
                    print("parsing bn: {s} = {s}\n", .{ w_trim, printBin(bn) });
                    try buttons.append(arena, bn);
                },
                '{' => {
                    var w_it = std.mem.splitScalar(u8, w_trim, ',');
                    while (w_it.next()) |n| {
                        if (n.len == 0) break;
                        const idx = try std.fmt.parseInt(u64, n, 10);
                        // print("reqs idx = {}\n", .{idx});
                        reqs += idx;
                        // reqs += try std.math.powi(u64, 2, idx);
                    }
                    print("parsing reqs: {s} = {s}\n", .{ w_trim, printBin(reqs) });
                },
                else => break,
            }
        }

        return .{
            .lights = lights,
            .buttons = try buttons.toOwnedSlice(arena),
            .reqs = reqs,
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
    print("{any}\n", .{arena.ptr});
    const in = try input.get(10);
    // const in =
    //     \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    //     \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    //     \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    //     \\
    // ;

    print("{s}\n", .{in});

    for (0..10) |i| {
        print("{}={s}\n", .{ i, printBin(i) });
    }

    // var machine_descriptions: ArrayList(MachineDescr) = .empty;
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

            // print("i: {}={s}", .{ i, printBin(i) });

            for (buttons, 0..) |b, j| {
                const is_button_pressed = getNthBit(i, j);
                if (is_button_pressed > 0) {
                    // print("\nbutton no.{} ({}={s}) is pressed", .{ j, b, printBin(b) });
                    // print("\tso {}={s}", .{ lights, printBin(lights) });
                    // print(" becomes {}={s}", .{ lights ^ b, printBin(lights ^ b) });
                    lights ^= b;
                }
            }
            // print("\n", .{});

            if (lights == machine_descr.lights) {
                // print(
                //     "\t DONE: {}={s} is now equal to goal {}={s}, it took {} moves (since {s} has {} bits on)!\n",
                //     .{
                //         lights,
                //         printBin(lights),
                //         machine_descr.lights,
                //         printBin(machine_descr.lights),
                //         countBits(i),
                //         printBin(i),
                //         countBits(i),
                //     },
                // );
                best = @min(best, countBits(i));
                // break;
            }
        }

        print("BEST NUMBER OF MOVES: {}\n\n", .{best});
        sum += best;
    }

    // var mem: HashMap()

    print("Result: {}\n", .{sum});
}

fn solve() void {}

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

    print("{s}\n", .{in});

    // print("Largest possible rectangle: {}\n", .{max});
}
