//!
//!
//! day eleven
//!
//!

const std = @import("std");
const Allocator = @import("std").mem.Allocator;
const List = @import("std").ArrayList;
const StringMap = @import("std").StringHashMap;
const Graph = StringMap(List(string));
const common = @import("common.zig");
const input = @import("input.zig");
const print = @import("std").debug.print;
const string = []const u8;

pub fn run(arena: std.mem.Allocator) !void {
    try first(arena);
    try second(arena);
}

fn first(arena: std.mem.Allocator) !void {
    input.header(11, 1);
    const in = try input.get(11);
    const graph = try parse(arena, in);

    const res = countPaths(arena, graph, "you", "out");
    print("\nTotal paths from \"you\" to \"out\": {}\n", .{res});
}

fn countPaths(arena: Allocator, graph: Graph, from: string, to: string) u64 {
    var stack: List([]const u8) = .empty;
    stack.append(arena, from) catch unreachable;

    var sum: u64 = 0;
    while (stack.items.len > 0) {
        const dev = stack.swapRemove(0);
        const outs_found = graph.get(dev);

        if (common.strEql(dev, to)) {
            sum += 1;
        } else if (outs_found) |outs| {
            for (outs.items) |o| {
                stack.append(arena, o) catch unreachable;
            }
        }
    }
    return sum;
}

fn second(arena: std.mem.Allocator) !void {
    input.header(11, 2);
    const in = try input.get(11);
    var graph = try parse(arena, in);
    const nodes_topological = sortTopological(arena, graph);

    const route = [_]string{ "svr", "fft", "dac", "out" };
    var prod: u64 = 1;
    for (0..route.len - 1) |i| {
        const from = route[i];
        const to = route[i + 1];
        const res = calcPaths(arena, &graph, nodes_topological, from, to);
        prod *= res;
    }

    print(
        "Total number of valid paths between {s} and {s}: {}\n",
        .{ route[0], route[route.len - 1], prod },
    );
}

fn sortTopological(arena: Allocator, graph: Graph) []string {
    var in_degrees: StringMap(u64) = .init(arena);
    var nodes_top_sort: List(string) = .empty;
    var queue: List(string) = .empty;

    var graph_it = graph.iterator();
    while (graph_it.next()) |entry| {
        const id = entry.key_ptr.*;
        const neighbors = entry.value_ptr.*.items;
        freqTryAdd(&in_degrees, id);
        for (neighbors) |neighbor| {
            freqIncr(&in_degrees, neighbor);
        }
    }

    var in_degrees_it = in_degrees.iterator();
    while (in_degrees_it.next()) |entry| {
        const id = entry.key_ptr.*;
        const in_degree = entry.value_ptr.*;
        if (in_degree == 0) {
            queue.append(arena, id) catch unreachable;
        }
    }

    while (queue.items.len > 0) {
        const node = queue.swapRemove(0);
        nodes_top_sort.append(arena, node) catch unreachable;
        if (graph.get(node)) |neighbor_list| {
            for (neighbor_list.items) |neighbor| {
                freqDecr(&in_degrees, neighbor);
                if (freqGet(&in_degrees, neighbor) == 0) {
                    queue.append(arena, neighbor) catch unreachable;
                }
            }
        }
    }

    return nodes_top_sort.toOwnedSlice(arena) catch unreachable;
}

fn calcPaths(
    arena: Allocator,
    graph: *Graph,
    nodes: []string,
    from: string,
    to: string,
) u64 {
    const to_adj_list = graph.get(to);
    graph.*.put(to, .empty) catch unreachable;

    var nodes_start: u64 = 0;
    var nodes_end: u64 = 0;
    for (0..nodes.len) |i| {
        if (common.strEql(from, nodes[i])) {
            nodes_start = i;
            continue;
        }
        if (common.strEql(to, nodes[i])) {
            nodes_end = i;
            break;
        }
    }

    const node_slice = nodes[nodes_start .. nodes_end + 1];
    var scores: StringMap(u64) = .init(arena);

    freqIncr(&scores, from);
    for (node_slice) |node| {
        const score = freqGet(&scores, node);
        if (graph.get(node)) |neighbor_list| {
            for (neighbor_list.items) |neighbor| {
                freqAdd(&scores, neighbor, score);
            }
        }
    }

    if (to_adj_list) |al| {
        graph.*.put(to, al) catch unreachable;
    }

    return if (scores.get(to)) |s| s else 0;
}

fn freqAdd(freqs: *StringMap(u64), key: string, to_add: u64) void {
    if (freqs.get(key)) |freq| {
        freqs.put(key, freq + to_add) catch unreachable;
    } else {
        freqs.put(key, to_add) catch unreachable;
    }
}

fn freqDecr(freqs: *StringMap(u64), key: string) void {
    if (freqs.get(key)) |freq| {
        freqs.put(key, freq -| 1) catch unreachable;
    } else {
        freqs.put(key, 0) catch unreachable;
    }
}

fn freqIncr(freqs: *StringMap(u64), key: string) void {
    if (freqs.get(key)) |freq| {
        freqs.put(key, freq + 1) catch unreachable;
    } else {
        freqs.put(key, 1) catch unreachable;
    }
}

fn freqGet(freqs: *StringMap(u64), key: string) u64 {
    if (freqs.get(key)) |freq| {
        return freq;
    } else {
        freqs.put(key, 0) catch unreachable;
        return 0;
    }
}

fn freqTryAdd(freqs: *StringMap(u64), key: string) void {
    if (freqs.get(key) == null) {
        freqs.put(key, 0) catch unreachable;
    }
}

fn parse(arena: std.mem.Allocator, in: string) !Graph {
    var graph: Graph = .init(arena);

    var input_it = std.mem.splitScalar(u8, in, '\n');
    while (input_it.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var line_it = std.mem.splitScalar(u8, line, ' ');
        const word_first = (if (line_it.next()) |w| w else unreachable)[0..3];
        std.debug.assert(word_first.len == 3);
        var output_list: List(string) = .empty;
        while (line_it.next()) |word| {
            if (word.len == 0) {
                continue;
            }

            try output_list.append(arena, word);
        }

        try graph.put(word_first, output_list);
    }

    return graph;
}
