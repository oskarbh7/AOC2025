//!
//!
//! day eight
//!
//!

const std = @import("std");
const ArrayList = @import("std").ArrayList;
const HashMap = @import("std").AutoHashMap;
const input = @import("input.zig");
const print = @import("std").debug.print;

const BoxSet = HashMap(Box, {});
const Box = @Vector(3, i64);
const BoxPair = struct {
    a: u64,
    b: u64,
    d: u64,

    pub fn init(a: anytype, b: anytype, d: anytype) BoxPair {
        return .{ .a = @intCast(a), .b = @intCast(b), .d = @intCast(d) };
    }

    pub fn lessThan(_: void, a: BoxPair, b: BoxPair) bool {
        return a.d < b.d;
    }

    pub fn format(self: BoxPair, w: *std.io.Writer) std.io.Writer.Error!void {
        try w.print("({}) <-- {:8} --> ({})", .{ self.a, self.d, self.b });
    }
};

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
}

fn first(arena: std.mem.Allocator) !void {
    input.header(8, 1);

    const N = 1000;
    const in = try input.get(8);
    const boxes = try parseInput(arena, in);
    const num = boxes.items.len;

    var box_pairs: ArrayList(BoxPair) = .empty;
    for (0..num) |i| {
        for (i + 1..num) |j| {
            try box_pairs.append(arena, .init(i, j, dist(boxes.items[i], boxes.items[j])));
        }
    }
    std.sort.pdq(BoxPair, box_pairs.items, {}, BoxPair.lessThan);

    const circuits = try arena.alloc(u64, num);
    for (0..num) |i| circuits[i] = i;

    for (0..N) |i| {
        const pair = box_pairs.items[i];
        join(circuits, pair.a, pair.b);
    }

    var circuit_groups: HashMap(u64, ArrayList(*const Box)) = .init(arena);
    for (0..num) |i| {
        const box_ptr = &boxes.items[i];
        const box_set = find(circuits, i);
        var circuit_box_list: ArrayList(*const Box) = if (circuit_groups.get(box_set)) |list| list else .empty;
        try circuit_box_list.append(arena, box_ptr);
        try circuit_groups.put(box_set, circuit_box_list);
    }

    const group_sizes = try arena.alloc(u64, num);
    @memset(group_sizes, 0);
    for (0..num) |i| {
        group_sizes[find(circuits, i)] += 1;
    }
    std.sort.pdq(u64, group_sizes, {}, std.sort.desc(u64));

    const result = group_sizes[0] * group_sizes[1] * group_sizes[2];
    print("result: {}\n", .{result});
}

fn second(arena: std.mem.Allocator) !void {
    input.header(8, 2);
    const in = try input.get(8);

    const boxes = try parseInput(arena, in);
    const num = boxes.items.len;

    var box_pairs: ArrayList(BoxPair) = .empty;
    for (0..num) |i| {
        for (i + 1..num) |j| {
            try box_pairs.append(arena, .init(i, j, dist(boxes.items[i], boxes.items[j])));
        }
    }
    std.sort.pdq(BoxPair, box_pairs.items, {}, BoxPair.lessThan);

    const circuits = try arena.alloc(u64, num);
    for (0..num) |i| circuits[i] = i;

    for (0..box_pairs.items.len) |i| {
        const pair = box_pairs.items[i];
        join(circuits, pair.a, pair.b);
        if (allInOne(circuits)) {
            const b1 = boxes.items[pair.a];
            const b2 = boxes.items[pair.b];
            const result = b1[0] * b2[0];
            print("Result:  {}\n", .{result});
            break;
        }
    }
}

fn allInOne(sets: []u64) bool {
    const first_set = find(sets, 0);
    for (1..sets.len) |i| {
        if (first_set != find(sets, i)) return false;
    }
    return true;
}

fn find(sets: []u64, x: u64) u64 {
    if (sets[x] == x) {
        return x;
    }
    return find(sets, sets[x]);
}

fn join(sets: []u64, x: u64, y: u64) void {
    const set_x = find(sets, x);
    const set_y = find(sets, y);
    sets[set_y] = set_x;
}

fn dist(a: Box, b: Box) i64 {
    return (b[0] - a[0]) * (b[0] - a[0]) +
        (b[1] - a[1]) * (b[1] - a[1]) +
        (b[2] - a[2]) * (b[2] - a[2]);
}

fn parseInput(arena: std.mem.Allocator, in: []const u8) !ArrayList(Box) {
    var boxes: ArrayList(Box) = .empty;

    var in_it = std.mem.splitScalar(u8, in, '\n');
    while (in_it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var box: Box = .{ 0, 0, 0 };
        var box_idx: u64 = 0;
        var line_it = std.mem.splitScalar(u8, line, ',');
        while (line_it.next()) |coord| {
            if (coord.len == 0) {
                break;
            }

            box[box_idx] = try std.fmt.parseInt(i64, coord, 10);
            box_idx += 1;
        }

        try boxes.append(arena, box);
    }

    return boxes;
}
