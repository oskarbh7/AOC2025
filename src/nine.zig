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
    pub fn ascVert(_: void, self: Line, other: Line) bool {
        return self.a[0] < other.a[0];
    }

    pub fn ascHorz(_: void, self: Line, other: Line) bool {
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
    const in = try input.get(9);
    // const in =
    //     \\7,1
    //     \\11,1
    //     \\11,7
    //     \\9,7
    //     \\9,5
    //     \\2,5
    //     \\2,3
    //     \\7,3
    //     \\
    // ;

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

    std.sort.pdq(Line, lines_vert.items, {}, Line.ascVert);
    std.sort.pdq(Line, lines_horz.items, {}, Line.ascHorz);
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
                // print("\t{any} has too low area ({}), skipping...\n", .{ rect_corners, T });
                continue;
            }

            // Corner tests
            for (rect_corners) |corner| {
                const vert_i = indexOfClosestLineX(lines_vert.items, corner);
                const horz_i = indexOfClosestLineY(lines_horz.items, corner);

                const line_closest_vert = lines_vert.items[vert_i];
                const line_closest_horz = lines_horz.items[horz_i];

                // Passed; inside
                if (line_closest_vert.containsPoint(corner) or
                    line_closest_horz.containsPoint(corner))
                {
                    print("\t{any} passed the line-containment test\n", .{corner});
                    continue;
                }

                const ray: Line = .init(corner + Vec{ 1, 0 }, corner + Vec{ 1 << 20, 0 });

                var did_intersect = false;
                for (vert_i..lines_vert.items.len) |k| {
                    const line_to_intersect = lines_vert.items[k];
                    if (!ray.intersects(line_to_intersect)) {
                        continue;
                    }

                    did_intersect = true;
                    const cross_sign = Line.crossSign(ray.getDir(), line_to_intersect.getDir());
                    // print("{any} intersects {any} with cross sign {}\n", .{ ray, line_to_intersect, cross_sign });
                    // Passed; outside
                    if (cross_sign > 0) {
                        print(
                            "\t{any} passed the ray cast test (sign:{}, line: {any})\n",
                            .{ corner, cross_sign, line_to_intersect },
                        );
                        break;
                    }

                    print("\t{any} FAILED the ray cast test\n", .{corner});
                    continue :j_loop;
                }

                if (!did_intersect) {
                    continue :j_loop;
                }

                // const closest_vert = lines_vert.items[closest_vert_i];
                // const closest_horz = lines_horz.items[closest_horz_i];

                // print("closest line vert to {any} is {any}\n", .{ corner, closest_vert });
                // print("closest line horz to {any} is {any}\n", .{ corner, closest_horz });
            }

            // Line tests
            const dir1 = normalize(rect_corners[1] - rect_corners[0]);
            const dir2 = normalize(rect_corners[2] - rect_corners[1]);
            const dir3 = normalize(rect_corners[3] - rect_corners[2]);
            const dir4 = normalize(rect_corners[0] - rect_corners[3]);
            const rect_lines: [4]Line = .{
                .init(rect_corners[0] + dir1, rect_corners[1] - dir1),
                .init(rect_corners[1] + dir2, rect_corners[2] - dir2),
                .init(rect_corners[2] + dir3, rect_corners[3] - dir3),
                .init(rect_corners[3] + dir4, rect_corners[0] - dir4),
            };

            var x_min: i64 = 0;
            var x_max: i64 = 0;
            for (rect_corners) |corner| {
                x_min = @min(x_min, corner[0]);
                x_max = @max(x_max, corner[0]);
            }

            print(
                "These corners: {any} and these lines: {any}\n",
                .{ rect_corners, rect_lines },
            );

            for (rect_lines) |line| {
                var idx = indexOfClosestLineX(lines_vert.items, .{ x_min, 0 });
                while (lines_vert.items[idx].a[0] <= x_max) {
                    const dir = normalize(lines_vert.items[idx].getDir());
                    const line_to_test = lines_vert.items[idx];
                    const line_to_test_cut: Line = .init(line_to_test.a + dir, line_to_test.b - dir);
                    print(
                        "\tintersection testing {any} against {any}\n",
                        .{ line, line_to_test_cut },
                    );
                    if (line.intersects(line_to_test_cut)) {
                        print(
                            "\t{any} FAILED the rect-line intersection test (against {any})\n",
                            .{ line, line_to_test_cut },
                        );
                        continue :j_loop;
                    }
                    idx += 1;
                    if (idx == lines_vert.items.len) {
                        break;
                    }
                }

                print("\t{any} passed the rect-line intersection test\n", .{line});
            }

            area_max = T;
        }
    }

    print("Largest area: {}\n", .{area_max});
}

fn indexOfClosestLineX(lines: []Line, point: Vec) u64 {
    var lo: u64 = 0;
    var hi: u64 = lines.len;
    while (lo < hi) {
        const mid = (hi + lo) / 2;
        const l = lines[mid];
        if (point[0] < l.a[0]) {
            hi = mid;
        } else if (point[0] > l.a[0]) {
            lo = mid;
        } else {
            return mid;
        }
    }
    while (lo > 0 and lines[lo - 1].a[0] >= point[0]) {
        lo -= 1;
    }
    return lo;
}

fn indexOfClosestLineY(lines: []Line, point: Vec) u64 {
    var lo: u64 = 0;
    var hi: u64 = lines.len;
    while (lo < hi) {
        const mid = (hi + lo) / 2;
        const l = lines[mid];
        if (point[1] < l.a[1]) {
            hi = mid;
        } else if (point[1] > l.a[1]) {
            lo = mid;
        } else {
            return mid;
        }
    }
    while (lo > 0 and lines[lo - 1].a[1] >= point[1]) {
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
