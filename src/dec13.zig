const std = @import("std");

const Vector2D = struct {
    x: usize,
    y: usize,
    fn scale(self: @This(), s: usize) Vector2D {
        return Vector2D{ .x = self.x * s, .y = self.y * s };
    }
    fn add(self: @This(), o: Vector2D) Vector2D {
        return Vector2D{ .x = self.x + o.x, .y = self.y + o.y };
    }
    fn inside(self: @This(), edge: Vector2D) bool {
        return self.x <= edge.x and self.y <= edge.y;
    }
    fn eq(self: @This(), o: Vector2D) bool {
        return std.meta.eql(self, o);
    }
};

const PRIZE_SPACE = Vector2D{
    .x = 10_000_000_000_000,
    .y = 10_000_000_000_000,
};

fn solve2_one(but_a: Vector2D, but_b: Vector2D, prize: Vector2D) ?usize {
    const limit_a = @divTrunc(prize.x, but_a.x);
    const limit_b = @divTrunc(prize.x, but_b.x);
    if (but_a.scale(limit_a).eq(prize)) return 3 * limit_a;
    if (but_b.scale(limit_b).eq(prize)) return limit_b;
    if (but_b.x * but_a.y == but_a.x * but_b.y) @panic("i optimistically did not code for this edge case");
    const convex = but_a.scale(limit_a).y < prize.y;
    var low_a: usize = 0;
    var high_a: usize = limit_a;
    while (low_a < high_a) {
        const mid_a = @divTrunc(high_a + low_a, 2);
        const av = but_a.scale(mid_a);
        const mid_b = @divTrunc(prize.x - av.x, but_b.x);
        const bv = but_b.scale(mid_b);
        const p = av.add(bv);
        if (p.eq(prize))
            return 3 * mid_a + mid_b;
        if ((p.y < prize.y) == convex) {
            high_a = mid_a;
        } else {
            low_a = @max(mid_a, low_a + 1);
        }
    }
    for (high_a..high_a + but_a.x) |scan_a| {
        const av = but_a.scale(scan_a);
        const scan_b = @divTrunc(prize.x - av.x, but_b.x);
        const bv = but_b.scale(scan_b);
        const p = av.add(bv);
        if (p.eq(prize)) {
            return 3 * scan_a + scan_b;
        }
    }
    return null;
}

test solve2_one {
    try std.testing.expectEqual(null, solve2_one(
        Vector2D{ .x = 94, .y = 34 },
        Vector2D{ .x = 22, .y = 67 },
        (Vector2D{ .x = 8400, .y = 5400 }).add(PRIZE_SPACE),
    ));
    try std.testing.expect(null != solve2_one(
        Vector2D{ .x = 26, .y = 66 },
        Vector2D{ .x = 67, .y = 21 },
        (Vector2D{ .x = 12748, .y = 12176 }).add(PRIZE_SPACE),
    ));
    try std.testing.expectEqual(null, solve2_one(
        Vector2D{ .x = 17, .y = 86 },
        Vector2D{ .x = 84, .y = 37 },
        (Vector2D{ .x = 7870, .y = 6450 }).add(PRIZE_SPACE),
    ));
    try std.testing.expectEqual(102851800151 * 3 + 107526881786, solve2_one(
        Vector2D{ .x = 69, .y = 23 },
        Vector2D{ .x = 27, .y = 71 },
        (Vector2D{ .x = 18641, .y = 10279 }).add(PRIZE_SPACE),
    ));
}

fn solve_one(but_a: Vector2D, but_b: Vector2D, prize: Vector2D) ?usize {
    var best: ?usize = null;
    var n_a: usize = 0;
    var n_b: usize = 100;
    while (true) {
        const current = but_a.scale(n_a).add(but_b.scale(n_b));
        if (std.meta.eql(current, prize)) {
            const cost = @as(usize, n_a) * 3 + n_b;
            if (best == null) {
                best = cost;
            } else {
                best = @min(best.?, cost);
            }
        }
        if (current.inside(prize)) {
            if (n_a == 100) return best;
            n_a += 1;
        } else {
            if (n_b == 0) return best;
            n_b -= 1;
        }
    }
}

test solve_one {
    try std.testing.expectEqual(280, solve_one(
        Vector2D{ .x = 94, .y = 34 },
        Vector2D{ .x = 22, .y = 67 },
        Vector2D{ .x = 8400, .y = 5400 },
    ));
    try std.testing.expectEqual(null, solve_one(
        Vector2D{ .x = 26, .y = 66 },
        Vector2D{ .x = 67, .y = 21 },
        Vector2D{ .x = 12748, .y = 12176 },
    ));
    try std.testing.expectEqual(200, solve_one(
        Vector2D{ .x = 17, .y = 86 },
        Vector2D{ .x = 84, .y = 37 },
        Vector2D{ .x = 7870, .y = 6450 },
    ));
    try std.testing.expectEqual(null, solve_one(
        Vector2D{ .x = 69, .y = 23 },
        Vector2D{ .x = 27, .y = 71 },
        Vector2D{ .x = 18641, .y = 10279 },
    ));
}

fn read_vector(line: []const u8, p_x: usize) Vector2D {
    const comma = std.mem.indexOfScalar(u8, line, ',').?;
    return Vector2D{
        .x = std.fmt.parseInt(usize, line[p_x..comma], 10) catch unreachable,
        .y = std.fmt.parseInt(usize, line[comma + 4 .. line.len], 10) catch unreachable,
    };
}

fn solve2(data: []const u8) usize {
    var i_p = std.mem.splitSequence(u8, data, "\n\n");
    var sum: usize = 0;
    while (i_p.next()) |prize_data| {
        var i_l = std.mem.splitScalar(u8, prize_data, '\n');
        const but_a = read_vector(i_l.next().?, 12);
        const but_b = read_vector(i_l.next().?, 12);
        const prize = read_vector(i_l.next().?, 9).add(PRIZE_SPACE);
        if (solve2_one(but_a, but_b, prize)) |cost| {
            sum += cost;
        }
    }
    return sum;
}

test solve2 {
    const data =
        \\Button A: X+94, Y+34
        \\Button B: X+22, Y+67
        \\Prize: X=8400, Y=5400
        \\
        \\Button A: X+26, Y+66
        \\Button B: X+67, Y+21
        \\Prize: X=12748, Y=12176
        \\
        \\Button A: X+17, Y+86
        \\Button B: X+84, Y+37
        \\Prize: X=7870, Y=6450
        \\
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
    ;
    try std.testing.expect(solve2(data) > 0);
}

fn solve(data: []const u8) usize {
    var i_p = std.mem.splitSequence(u8, data, "\n\n");
    var sum: usize = 0;
    while (i_p.next()) |prize_data| {
        var i_l = std.mem.splitScalar(u8, prize_data, '\n');
        const but_a = read_vector(i_l.next().?, 12);
        const but_b = read_vector(i_l.next().?, 12);
        const prize = read_vector(i_l.next().?, 9);
        if (solve_one(but_a, but_b, prize)) |cost| {
            sum += cost;
        }
    }
    return sum;
}

test solve {
    const data =
        \\Button A: X+94, Y+34
        \\Button B: X+22, Y+67
        \\Prize: X=8400, Y=5400
        \\
        \\Button A: X+26, Y+66
        \\Button B: X+67, Y+21
        \\Prize: X=12748, Y=12176
        \\
        \\Button A: X+17, Y+86
        \\Button B: X+84, Y+37
        \\Prize: X=7870, Y=6450
        \\
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
    ;
    try std.testing.expectEqual(480, solve(data));
}

pub fn main() void {
    const data = @embedFile("input13.txt");
    std.debug.print("Cost Incorrect: {}\n", .{solve(data)});
    std.debug.print("Cost Corrent  : {}\n", .{solve2(data)});
}
