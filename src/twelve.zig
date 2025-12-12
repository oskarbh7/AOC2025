//!
//!
//! day twelve
//!
//!

const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const List = @import("std").ArrayList;
const Matrix = @import("types.zig").Matrix;
const common = @import("common.zig");
const input = @import("input.zig");
const print = @import("std").debug.print;
const string = []const u8;

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    // try second(arena);
}

const Region = struct {
    w: u64,
    h: u64,
    indices: []const u64,
};

fn first(arena: std.mem.Allocator) !void {
    input.header(12, 1);
    const in = try input.get(12);
    // const in = in_test;

    const shapes, const regions = try parse(arena, in);
    const shape_sizes = try arena.alloc(u64, shapes.items.len);
    // const region_sizes = try arena.alloc(u64, regions.items.len);
    // var shape_variants: List([]Matrix) = .empty;

    // for (shapes.items) |s| {
    //     try shape_variants.append(arena, makeVariants(arena, s));
    // }

    for (0..shapes.items.len) |i| {
        const s = shapes.items[i];

        var sum: u64 = 0;
        for (0..s.cols) |s_i| {
            for (0..s.rows) |s_j| {
                const s_ij = s.get(s_i, s_j);
                sum += if (s_ij == '#') 1 else 0;
            }
        }
        shape_sizes[i] = sum;
        // print("{s}\nhas size {}\n\n", .{ s.toString(), sum });
    }

    var sum: u64 = 0;
    for (0..regions.items.len) |i| {
        const r = regions.items[i];

        var need: u64 = 0;
        for (0..r.indices.len) |idx| {
            need += r.indices[idx] * shape_sizes[idx];
        }

        const free = r.w * r.h;
        const ratio: f64 = asF64(free) / asF64(need);
        print("{any}\n\tfree: {}\n\tneed: {}\n\tratio: {}\n\n", .{ r, free, need, ratio });

        if (ratio > 1.25) {
            sum += 1;
        }
    }

    print("\n===============\nTOTAL: {}\n\n", .{sum});

    // for (regions.items) |region| {
    //     print("\n\n>>> TRYING REGION {any}\n=================\n\n", .{region});

    //     const M: Matrix = .init(arena, region.h, region.w, '.');
    //     const S = shape_variants.items;
    //     const L = try arena.alloc(u64, shapes.items.len);
    //     @memcpy(L, region.indices);
    //     const result = fit(arena, M, S, L);

    //     print("Final result: {}\n", .{result});
    // }

    // print("{s}\n", .{in});

    // print("\nTotal paths from \"you\" to \"out\": {}\n", .{res});
}

fn fit(
    arena: Allocator,
    region: Matrix,
    shapes: [][]Matrix,
    shapes_left: []u64,
) u64 {
    if (std.mem.allEqual(u64, shapes_left, 0)) {
        print(
            "found solution (shapes_left: {any}):\n{s}\n\n",
            .{ shapes_left, region.toString() },
        );
        return 1;
    }

    var sum: u64 = 0;
    for (0..region.rows) |i| {
        for (0..region.cols) |j| {
            for (0..shapes.len) |k| {
                if (shapes_left[k] == 0) {
                    continue;
                }

                shapes_left[k] -= 1;
                defer shapes_left[k] += 1;

                for (shapes[k]) |shape| {
                    if (!fits(region, shape, i, j, "#")) {
                        continue;
                    }

                    // print("Trying blittng ({},{}):\n{s}\n", .{shape.toString()});

                    blit(region, shape, i, j, "#");
                    const does_it_fit = fit(arena, region, shapes, shapes_left);
                    if (does_it_fit > 0) {
                        return does_it_fit;
                    }
                    sum += does_it_fit;
                    defer unblit(region, shape, i, j, "#", '.');
                }
            }
        }
    }

    return sum;
}

fn makeVariants(arena: Allocator, M: Matrix) []Matrix {
    var variants = arena.alloc(Matrix, 12) catch unreachable;
    variants[0] = M;
    variants[1] = M.flipH(arena);
    variants[2] = M.flipV(arena);

    var i: u64 = 0;
    while (i < 9) : (i += 3) {
        variants[i + 3] = variants[i].rotateCW(arena);
        variants[i + 4] = variants[i + 3].flipH(arena);
        variants[i + 5] = variants[i + 3].flipV(arena);
    }

    return variants;
}

fn blit(dest: Matrix, src: Matrix, row: u64, col: u64, chars_to_blit: string) void {
    for (0..src.rows) |i| {
        for (0..src.cols) |j| {
            const char_to_blit = src.get(i, j);
            if (std.mem.indexOf(u8, chars_to_blit, &.{char_to_blit})) |_| {
                dest.set(i + row, j + col, char_to_blit);
            }
        }
    }
}

fn unblit(
    dest: Matrix,
    src: Matrix,
    row: u64,
    col: u64,
    chars_blitted: string,
    char_to_unblit_with: u8,
) void {
    for (0..src.rows) |i| {
        for (0..src.cols) |j| {
            const char_to_unblit = src.get(i, j);
            if (std.mem.indexOf(u8, chars_blitted, &.{char_to_unblit})) |_| {
                dest.set(i + row, j + col, char_to_unblit_with);
            }
        }
    }
}

fn fits(dest: Matrix, src: Matrix, row: u64, col: u64, chars_to_blit: string) bool {
    if (src.cols + col > dest.cols) {
        return false;
    }
    if (src.rows + row > dest.rows) {
        return false;
    }

    for (0..src.rows) |i| {
        for (0..src.cols) |j| {
            const char_src = src.get(i, j);
            if (std.mem.indexOf(u8, chars_to_blit, &.{char_src}) == null) {
                continue;
            }

            const i_dest = i + row;
            const j_dest = j + col;
            const char_dest = dest.get(i_dest, j_dest);
            if (std.mem.indexOf(u8, chars_to_blit, &.{char_dest})) |_| {
                return false;
            }
        }
    }
    return true;
}

fn parse(arena: Allocator, in: string) !struct { List(Matrix), List(Region) } {
    var shapes: List(Matrix) = .empty;
    var regions: List(Region) = .empty;

    var in_it = std.mem.splitSequence(u8, in, "\n\n");
    while (in_it.next()) |block| {
        // print("{s}\n======\n", .{block});

        // const line_0 = block_it.next();
        if (std.mem.count(u8, block, "x") > 0) {
            var block_it = std.mem.splitScalar(u8, block, '\n');
            while (block_it.next()) |line| {
                if (line.len == 0) {
                    continue;
                }

                const cutoff = indexOf(line, ':');
                const dim_slice = line[0..cutoff];
                const dim_slice_mid = indexOf(dim_slice, 'x');
                const w = try std.fmt.parseInt(u64, dim_slice[0..dim_slice_mid], 10);
                const h = try std.fmt.parseInt(u64, dim_slice[dim_slice_mid + 1 ..], 10);

                const indices_slice = line[cutoff + 1 ..];
                var indices: List(u64) = .empty;
                var indices_slice_it = std.mem.splitScalar(u8, indices_slice, ' ');
                while (indices_slice_it.next()) |idx_slice| {
                    if (idx_slice.len == 0) {
                        continue;
                    }
                    try indices.append(arena, try std.fmt.parseInt(u64, idx_slice, 10));
                }

                const region: Region = .{
                    .w = w,
                    .h = h,
                    .indices = try indices.toOwnedSlice(arena),
                };
                try regions.append(arena, region);
            }
        } else {
            const start_idx = indexOf(block, '\n') + 1;
            const shape_str = block[start_idx..];
            const cols = indexOf(shape_str, '\n');
            const rows = cols;
            const buf = try arena.alloc(u8, cols * rows);
            var buf_idx: u64 = 0;
            for (block) |char| {
                if (char == '.' or char == '#') {
                    buf[buf_idx] = char;
                    buf_idx += 1;
                }
            }
            const shape: Matrix = .{ .buf = buf, .cols = cols, .rows = rows };
            try shapes.append(arena, shape);
        }
    }

    return .{ shapes, regions };
}

fn indexOf(str: string, needle: u8) u64 {
    return if (std.mem.indexOf(u8, str, &.{needle})) |idx| idx else 0;
}

fn asF64(n: anytype) f64 {
    return @as(f64, @floatFromInt(n));
}

// fn second(arena: std.mem.Allocator) !void {
//     input.header(12, 2);
//     // const in = try input.get(12);
//     const in = in_test;

//     print("{any}\n", .{arena.ptr});
//     print("{s}\n", .{in});
// }

const in_test =
    \\0:
    \\###
    \\##.
    \\##.
    \\
    \\1:
    \\###
    \\##.
    \\.##
    \\
    \\2:
    \\.##
    \\###
    \\##.
    \\
    \\3:
    \\##.
    \\###
    \\##.
    \\
    \\4:
    \\###
    \\#..
    \\###
    \\
    \\5:
    \\###
    \\.#.
    \\###
    \\
    \\4x4: 0 0 0 0 2 0
    \\12x5: 1 0 1 0 2 2
    \\12x5: 1 0 1 0 3 2
    \\
;
