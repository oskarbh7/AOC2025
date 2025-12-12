//!
//!
//! day nine
//!
//!

const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const List = @import("std").ArrayList;
const HashMap = @import("std").AutoHashMap;
const input = @import("input.zig");
const print = @import("std").debug.print;

const Vec = @Vector(2, i64);
const Line = struct {
    a: Vec,
    b: Vec,

    pub fn init(a: Vec, b: Vec) Line {
        return .{ .a = a, .b = b };
    }

    pub fn getDir(self: Line) Vec {
        return self.b - self.a;
    }

    pub fn cutEnds(self: Line) Line {
        const dir = normalize(self.getDir());
        return .init(self.a + dir, self.b - dir);
    }

    pub fn containsPoint(self: Line, p: Vec) bool {
        const dir_self: Vec = self.b - self.a;
        const dir_self_p: Vec = p - self.a;
        if (crossSign(dir_self, dir_self_p) != 0) {
            return false;
        }

        const x_min = @min(self.a[0], self.b[0]);
        const x_max = @max(self.a[0], self.b[0]);
        const y_min = @min(self.a[1], self.b[1]);
        const y_max = @max(self.a[1], self.b[1]);
        return x_min <= p[0] and p[0] <= x_max and
            y_min <= p[1] and p[1] <= y_max;
    }

    pub fn intersects(self: Line, other: Line) bool {
        const a1_b1: Vec = other.a - self.a;
        const a1_b2: Vec = other.b - self.a;
        const b1_a1: Vec = self.a - other.a;
        const b1_a2: Vec = self.b - other.a;

        const sign_1 = crossSign(self.b - self.a, a1_b1);
        const sign_2 = crossSign(self.b - self.a, a1_b2);
        const sign_3 = crossSign(other.b - other.a, b1_a1);
        const sign_4 = crossSign(other.b - other.a, b1_a2);

        return sign_1 != sign_2 and sign_3 != sign_4;
    }

    pub fn crossSign(a: Vec, b: Vec) i64 {
        const cross = a[0] * b[1] - a[1] * b[0];
        return if (cross < 0) -1 else if (cross > 0) 1 else 0;
    }

    /// Sorting
    pub fn ascX(_: void, self: Line, other: Line) bool {
        return self.a[0] < other.a[0];
    }

    pub fn ascY(_: void, self: Line, other: Line) bool {
        return self.a[1] < other.a[1];
    }
};

pub fn normalize(vec: Vec) Vec {
    return .{
        if (vec[0] < 0) -1 else if (vec[0] > 0) 1 else 0,
        if (vec[1] < 0) -1 else if (vec[1] > 0) 1 else 0,
    };
}

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
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

    var area_max: u64 = 0;
    const points = try parseInput(arena, in);
    for (0..points.len) |i| {
        for (i + 1..points.len) |j| {
            area_max = @max(area_max, calcArea(points[i], points[j]));
        }
    }

    print("Largest area: {}\n", .{area_max});
}

fn second(arena: std.mem.Allocator) !void {
    input.header(9, 2);
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
    const lines = try makeLines(arena, points);
    var lines_vert: List(Line) = .empty;
    var lines_horz: List(Line) = .empty;

    for (lines) |line| {
        print("{any}: ", .{line});
        if (line.a[0] == line.b[0]) {
            try lines_vert.append(arena, line);
            print("vert\n", .{});
        } else {
            try lines_horz.append(arena, line);
            print("horz\n", .{});
        }
    }

    std.sort.pdq(Line, lines_vert.items, {}, Line.ascX);
    std.sort.pdq(Line, lines_horz.items, {}, Line.ascY);
    print("\n\n", .{});

    var area_max: u64 = 0;
    var rect_corners: [4]Vec = undefined;
    for (0..points.len) |i| {
        rect_corners[0] = points[i];

        j_loop: for (i + 1..points.len) |j| {
            rect_corners[2] = points[j];
            rect_corners[1] = .{ rect_corners[0][0], rect_corners[2][1] };
            rect_corners[3] = .{ rect_corners[2][0], rect_corners[0][1] };

            print("Testing the rectangle {any}\n", .{rect_corners});

            const T = calcArea(rect_corners[0], rect_corners[2]);
            if (T <= area_max) {
                continue;
            }

            // Corner tests
            // corner_test: for (rect_corners) |corner| {
            //     var vline_i = indexOfFirstLineWithX(lines_vert.items, corner[0]);
            //     while (vline_i < lines_vert.items.len and lines_vert.items[vline_i].a[0] == corner[0]) {
            //         if (lines_vert.items[vline_i].containsPoint(corner)) {
            //             print("\t{any} passed the corner line-containment test\n", .{corner});
            //             continue :corner_test;
            //         }
            //         vline_i += 1;
            //     }

            //     var hline_i = indexOfFirstLineWithY(lines_horz.items, corner[1]);
            //     while (hline_i < lines_horz.items.len and lines_horz.items[hline_i].a[0] == corner[0]) {
            //         if (lines_horz.items[hline_i].containsPoint(corner)) {
            //             print("\t{any} passed the corner line-containment test\n", .{corner});
            //             continue :corner_test;
            //         }
            //         hline_i += 1;
            //     }

            //     print("\t{any} did NOT pass the corner line-containment test\n", .{corner});
            //     continue :j_loop;
            // }

            // Line intersection tests
            var x_min: i64 = 0;
            var y_min: i64 = 0;
            var x_max: i64 = 0;
            var y_max: i64 = 0;
            for (rect_corners) |corner| {
                x_min = @min(x_min, corner[0]);
                y_min = @min(y_min, corner[1]);
                x_max = @max(x_max, corner[0]);
                y_max = @max(y_max, corner[1]);
            }

            const vline_idx_min = indexOfFirstLineWithX(lines_vert.items, x_min);
            var vline_idx_max = vline_idx_min;
            while (vline_idx_max < lines_vert.items.len and lines_vert.items[vline_idx_min].a[0] <= x_max) {
                vline_idx_max += 1;
            }

            for (@intCast(y_min)..@intCast(y_max + 1)) |y| {
                const rect_line: Line = .init(
                    .{ @intCast(x_min), @intCast(y) },
                    .{ @intCast(x_max), @intCast(y) },
                );
                for (vline_idx_min..vline_idx_max) |vline_idx| {
                    const vline = lines_vert.items[vline_idx].cutEnds();
                    print(
                        "\nTesting intersection between rect line {any} and vline {any}\n",
                        .{ rect_line, vline },
                    );
                    if (rect_line.intersects(vline)) {
                        print("\tFAILED the rect line intersection test\n", .{});
                        continue :j_loop;
                    }
                }
            }

            area_max = T;
        }
    }

    print("Largest area: {}\n", .{area_max});
}

fn indexOfFirstLineWithX(lines: []Line, x: i64) u64 {
    var lo: u64 = 0;
    var hi: u64 = lines.len;
    while (lo < hi) {
        const mid = (hi + lo) / 2;
        const l = lines[mid];
        if (x < l.a[0]) {
            hi = mid;
        } else if (x > l.a[0]) {
            lo = mid;
        } else {
            return mid;
        }
    }
    while (lo > 0 and lines[lo - 1].a[0] >= x) {
        lo -= 1;
    }
    return lo;
}

fn indexOfFirstLineWithY(lines: []Line, y: i64) u64 {
    var lo: u64 = 0;
    var hi: u64 = lines.len;
    while (lo < hi) {
        const mid = (hi + lo) / 2;
        const l = lines[mid];
        if (y < l.a[1]) {
            hi = mid;
        } else if (y > l.a[1]) {
            lo = mid;
        } else {
            return mid;
        }
    }
    while (lo > 0 and lines[lo - 1].a[1] >= y) {
        lo -= 1;
    }
    return lo;
}

fn makeLines(arena: Allocator, points: []Vec) ![]Line {
    var lines: List(Line) = .empty;
    for (0..points.len) |i| {
        try lines.append(arena, .init(points[i], points[(i + 1) % points.len]));
    }
    return try lines.toOwnedSlice(arena);
}

fn calcArea(p1: Vec, p2: Vec) u64 {
    const x_min = @min(p1[0], p2[0]);
    const y_min = @min(p1[1], p2[1]);
    const x_max = @max(p1[0], p2[0]);
    const y_max = @max(p1[1], p2[1]);
    return @intCast((x_max - x_min + 1) * (y_max - y_min + 1));
}

fn parseInput(arena: std.mem.Allocator, in: []const u8) ![]Vec {
    var point_list: List(Vec) = .empty;
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
