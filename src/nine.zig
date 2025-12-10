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

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
}

const Vec = @Vector(2, i64);
const Edge = [2]Vec;
const Line = [2]Vec;
const Rect = struct {
    a: Vec,
    b: Vec,
    T: u64,

    pub fn init(a: Vec, b: Vec) Rect {
        return .{ .a = a, .b = b, .T = calcArea(a, b) };
    }

    pub fn greaterThan(_: void, a: Rect, b: Rect) bool {
        return a.T > b.T;
    }
};

fn calcArea(a: Vec, b: Vec) u64 {
    return @abs(a[0] - b[0] + 1) * @abs(a[0] - b[1] + 1);
}

fn rayR(a: Vec) Line {
    const right: Vec = .{ 1000, 0 };
    return .{ a, a + right };
}

fn crossZSign(a: Line, b: Line) i64 {
    const a_dir = dirVec(a);
    const b_dir = dirVec(b);
    const cross = a_dir[0] * b_dir[1] - a_dir[1] * b_dir[0];
    return if (cross < 0) -1 else if (cross > 0) 1 else 0;
}

fn dirVec(a: Line) Vec {
    return a[1] - a[0];
}

fn dirNorm(a: Line) Vec {
    const dir = dirVec(a);
    return .{
        if (dir[0] > 0) 1 else if (dir[0] < 0) -1 else 0,
        if (dir[1] > 0) 1 else if (dir[1] < 0) -1 else 0,
    };
}

fn pointOfIntersection(a: Line, b: Line) Vec {
    const a_dir = dirNorm(a);
    const b_dir = dirNorm(b);

    var a_p = a[0];
    while (true) {
        defer a_p += a_dir;
        var b_p = b[0];
        while (true) {
            defer b_p += b_dir;
            if (std.mem.eql(Vec, &.{a_p}, &.{b_p})) {
                return a_p;
            }

            if (std.mem.eql(Vec, &.{b_p}, &.{b[1]})) {
                break;
            }
        }

        if (std.mem.eql(Vec, &.{a_p}, &.{a[1]})) {
            break;
        }
    }

    return .{ -1, -1 };
}

/// Ignores colinear intersections
fn doIntersect(a: Line, b: Line) bool {
    const a1b1: Line = .{ a[0], b[0] };
    const a1b2: Line = .{ a[0], b[1] };
    const b1a1: Line = .{ b[0], a[0] };
    const b1a2: Line = .{ b[0], a[1] };

    const Z1 = crossZSign(a, a1b1);
    const Z2 = crossZSign(a, a1b2);
    const Z3 = crossZSign(b, b1a1);
    const Z4 = crossZSign(b, b1a2);

    return Z1 != Z2 and Z3 != Z4;
}

fn second(arena: std.mem.Allocator) !void {
    input.header(9, 2);
    const buf_w = 100;
    const buf_h = 11;
    var buf: [buf_w * buf_h]u8 = undefined;
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
    const lines = try makePolyLines(arena, points);
    const rects = try makeRects(arena, points);
    // const N = points.len;

    print("Points:\n", .{});
    for (points) |p| print("{any}\n", .{p});
    print("Lines:\n", .{});
    for (lines) |l| print("{any}\n", .{l});
    print("Rects:\n", .{});
    for (rects) |r| print("{any}\n", .{r});

    resetBuf(&buf);
    printPolygon(&buf, buf_w, 1, 1, points, '#', "main {}", .{2});
    printBuf(&buf, buf_w, buf_h);

    const poly_m = measurePolygon(points);
    const lines_to_intersect = [_]Line{
        .{ .{ 2, 3 }, .{ 7, 3 } },
        .{ .{ 9, 5 }, .{ 9, 7 } },
    };

    for (0..buf_h - 1) |y| {
        const padding = 4;
        const x_offs: [2]u64 = .{ 1 * poly_m.width, 2 * poly_m.width + padding };
        const line: Line = .{ .{ 0, @intCast(y) }, .{ @intCast(poly_m.width - 1), @intCast(y) } };

        print("line: {any}, lines_to_intersect: {any}\n", .{ line, lines_to_intersect });

        resetBuf(&buf);
        for (lines_to_intersect, 0..) |li, i| {
            const did_intersect = doIntersect(line, li);
            printPolygon(&buf, buf_w, x_offs[i], 0, &li, 'O', "is:{}", .{did_intersect});
            printPolygon(&buf, buf_w, x_offs[i], 0, &line, '#', "is:{}", .{did_intersect});
        }
        printBuf(&buf, buf_w, buf_h);
    }

    for (0..poly_m.width) |x| {
        const padding = 4;
        const x_offs: [2]u64 = .{ 1 * poly_m.width, 2 * poly_m.width + padding };
        const line: Line = .{ .{ @intCast(x), 0 }, .{ @intCast(x), @intCast(poly_m.width - 1) } };

        print("line: {any}, lines_to_intersect: {any}\n", .{ line, lines_to_intersect });

        resetBuf(&buf);
        for (lines_to_intersect, 0..) |li, i| {
            const did_intersect = doIntersect(line, li);
            print("intersect at: {any}\n", .{pointOfIntersection(line, li)});
            printPolygon(&buf, buf_w, x_offs[i], 0, &li, 'O', "is:{}", .{did_intersect});
            printPolygon(&buf, buf_w, x_offs[i], 0, &line, '#', "is:{}", .{did_intersect});
        }
        printBuf(&buf, buf_w, buf_h);
    }

    const final_rect: ?Rect = null;
    if (final_rect) |r| {
        print("Largest possible rectangle area: {any}\n", .{r});
    }
}

fn isInside(p: Vec, line: Edge) bool {
    const p1 = line[0];
    const p2 = line[1];
    if (p[0] == p1[0] and p[0] == p2[0]) {
        if (@min(p1[1], p2[1]) <= p[1] and p[1] <= @max(p1[1], p2[1])) {
            return true;
        }
    }
    if (p[1] == p1[1] and p[1] == p2[1]) {
        if (@min(p1[0], p2[0]) <= p[0] and p[0] <= @max(p1[0], p2[0])) {
            return true;
        }
    }
    return false;
}

fn makeRects(arena: std.mem.Allocator, points: []Vec) ![]Rect {
    var rects: ArrayList(Rect) = .empty;
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            try rects.append(arena, .init(points[i], points[j]));
        }
    }
    return try rects.toOwnedSlice(arena);
}

fn makePolyLines(arena: std.mem.Allocator, poly_corners: []Vec) ![]Line {
    var lines: ArrayList(Edge) = .empty;
    for (0..poly_corners.len) |i| {
        try lines.append(arena, .{
            poly_corners[i],
            poly_corners[(i + 1) % poly_corners.len],
        });
    }
    return try lines.toOwnedSlice(arena);
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

fn printPolygon(
    buf: []u8,
    buf_width: u64,
    x: u64,
    y: u64,
    poly_corners: []const Vec,
    char: u8,
    comptime title: []const u8,
    args: anytype,
) void {
    const xs: i64 = @intCast(x);
    const ys: i64 = @intCast(y);
    // const poly_m = measurePolygon(poly_corners);
    _ = std.fmt.bufPrint(buf[y * buf_width + x ..], "[" ++ title ++ "]", args) catch unreachable;
    for (poly_corners) |c| {
        const cx: u64 = @intCast(xs + c[0]);
        const cy: u64 = @intCast(ys + c[1] + 1);
        if (buf[cy * buf_width + cx] != '.') {
            buf[cy * buf_width + cx] = 'X';
        } else {
            buf[cy * buf_width + cx] = char;
        }
    }
}

fn measurePolygon(poly_corners: []const Vec) struct {
    x_min: i64,
    y_min: i64,
    x_max: i64,
    y_max: i64,
    width: u64,
    height: u64,
} {
    var x_min: i64 = std.math.maxInt(i64);
    var y_min: i64 = std.math.maxInt(i64);
    var x_max: i64 = 0;
    var y_max: i64 = 0;

    for (poly_corners) |c| {
        x_min = @min(x_min, c[0]);
        y_min = @min(y_min, c[1]);
        x_max = @max(x_max, c[0]);
        y_max = @max(y_max, c[1]);
    }

    return .{
        .x_min = x_min,
        .y_min = y_min,
        .x_max = x_max,
        .y_max = y_max,
        .width = @intCast(x_max - x_min + 1),
        .height = @intCast(y_max - y_min + 1),
    };
}

fn resetBuf(buf: []u8) void {
    @memset(buf, '.');
}

fn printBuf(buf: []u8, buf_width: u64, buf_height: u64) void {
    for (0..buf_height) |y| {
        for (0..buf_width) |x| {
            print("{c}", .{buf[y * buf_width + x]});
        }
        print("\n", .{});
    }
}
