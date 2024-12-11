const std = @import("std");

const STONES = &[_]u64{ 475449, 2599064, 213, 0, 2, 65, 5755, 51149 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    std.debug.print("Result 25: {} stones\n", .{try solve(alloc, STONES, 25)});
    std.debug.print("Result 75: {} stones\n", .{try solve(alloc, STONES, 75)});
}

fn digits(m: u64) u8 {
    var r: u8 = 1;
    var n = m;
    while (n > 9) {
        r += 1;
        n = @divTrunc(n, 10);
    }
    return r;
}

fn add(m: *std.AutoHashMap(u64, u64), v: u64, c: u64) !void {
    const r = try m.*.getOrPut(v);
    if (!r.found_existing) r.value_ptr.* = 0;
    r.value_ptr.* += c;
}

fn solve(allocator: std.mem.Allocator, stones: []const u64, blinks: u64) !u64 {
    var s = std.AutoHashMap(u64, u64).init(allocator);
    defer s.deinit();
    for (stones) |v| {
        try add(&s, v, 1);
    }
    for (0..blinks) |_| {
        var s_o = s;
        s = std.AutoHashMap(u64, u64).init(allocator);
        var i = s_o.iterator();
        while (i.next()) |e| {
            const v = e.key_ptr.*;
            const c = e.value_ptr.*;
            if (v == 0) {
                try add(&s, 1, c);
            } else if (@mod(digits(v), 2) == 0) {
                const div = try std.math.powi(u64, 10, digits(v) / 2);
                try add(&s, @divTrunc(v, div), c);
                try add(&s, @mod(v, div), c);
            } else {
                try add(&s, v * 2024, c);
            }
        }
        s_o.deinit();
    }
    var sum: u64 = 0;
    var i = s.valueIterator();
    while (i.next()) |c| {
        sum += c.*;
    }
    return sum;
}

test solve {
    const test_stones = &[_]u64{ 125, 17 };
    try std.testing.expectEqual(3, try solve(std.testing.allocator, test_stones, 1));
    try std.testing.expectEqual(4, try solve(std.testing.allocator, test_stones, 2));
    try std.testing.expectEqual(5, try solve(std.testing.allocator, test_stones, 3));
    try std.testing.expectEqual(9, try solve(std.testing.allocator, test_stones, 4));
    try std.testing.expectEqual(13, try solve(std.testing.allocator, test_stones, 5));
    try std.testing.expectEqual(22, try solve(std.testing.allocator, test_stones, 6));
    try std.testing.expectEqual(55312, try solve(std.testing.allocator, test_stones, 25));
}
