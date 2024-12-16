const std = @import("std");

const Vec = struct {
    x: i8,
    y: i8,
};

const Robot = struct {
    x: i8,
    y: i8,
    v: Vec,
};

const Room = struct {
    w: u7,
    h: u7,
};

fn tick(r: Room, bots: []Robot) void {
    for (bots) |*bot| {
        const nx: i9 = @as(i9, bot.x) + bot.v.x;
        const ny: i9 = @as(i9, bot.y) + bot.v.y;
        bot.x = @truncate(@mod(nx, r.w));
        bot.y = @truncate(@mod(ny, r.h));
    }
}

test tick {
    var bots: [2]Robot = undefined;
    bots[0] = Robot{ .x = 0, .y = 0, .v = Vec{ .x = 1, .y = 1 } };
    bots[1] = Robot{ .x = 2, .y = 2, .v = Vec{ .x = -5, .y = -5 } };
    tick(Room{ .w = 10, .h = 10 }, bots[0..2]);
    try std.testing.expectEqual(1, bots[0].x);
    try std.testing.expectEqual(7, bots[1].x);
}

fn solve(alloc: std.mem.Allocator, data: []const u8, room: Room, ticks: u8) usize {
    var it_line = std.mem.splitScalar(u8, data, '\n');
    var bots = std.ArrayList(Robot).init(alloc);
    defer bots.deinit();
    while (it_line.next()) |line| {
        if (line.len == 0) break;
        var nums = std.mem.splitAny(u8, line, "=, ");
        _ = nums.next();
        const x = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        const y = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        _ = nums.next();
        const dx = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        const dy = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        (bots.addOne() catch unreachable).* = Robot{ .x = x, .y = y, .v = Vec{ .x = dx, .y = dy } };
    }
    for (ticks) |_| {
        tick(room, bots.items);
    }
    const mx = @divTrunc(room.w, 2);
    const my = @divTrunc(room.h, 2);
    var q0: usize = 0;
    var q1: usize = 0;
    var q2: usize = 0;
    var q3: usize = 0;
    for (bots.items) |bot| {
        if (bot.x < mx) {
            if (bot.y < my) q0 += 1;
            if (bot.y > my) q1 += 1;
        }
        if (bot.x > mx) {
            if (bot.y < my) q2 += 1;
            if (bot.y > my) q3 += 1;
        }
    }
    return q0 * q1 * q2 * q3;
}

fn solve2(alloc: std.mem.Allocator, data: []const u8, room: Room) usize {
    var it_line = std.mem.splitScalar(u8, data, '\n');
    var bots = std.ArrayList(Robot).init(alloc);
    defer bots.deinit();
    while (it_line.next()) |line| {
        if (line.len == 0) break;
        var nums = std.mem.splitAny(u8, line, "=, ");
        _ = nums.next();
        const x = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        const y = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        _ = nums.next();
        const dx = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        const dy = std.fmt.parseInt(i8, nums.next().?, 10) catch unreachable;
        (bots.addOne() catch unreachable).* = Robot{ .x = x, .y = y, .v = Vec{ .x = dx, .y = dy } };
    }
    var ticks: usize = 0;
    for (0..68) |_| {
        ticks += 1;
        tick(room, bots.items);
    }
    while (true) {
        for (0..room.h) |r| {
            for (0..room.w) |c| {
                var n: usize = 0;
                for (bots.items) |bot| {
                    if (bot.x == c and bot.y == r) n += 1;
                }
                const l: u8 = if (n == 0) '.' else if (n < 10) '0' + @as(u8, @truncate(n)) else 'X';
                std.debug.print("{c}", .{l});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("{}\n", .{ticks});
        std.Thread.sleep(1_000_000_000);
        for (0..101) |_| {
            ticks += 1;
            tick(room, bots.items);
        }
    }
    return ticks;
}

test solve {
    const data =
        \\p=0,4 v=3,-3
        \\p=6,3 v=-1,-3
        \\p=10,3 v=-1,2
        \\p=2,0 v=2,-1
        \\p=0,0 v=1,3
        \\p=3,0 v=-2,-2
        \\p=7,6 v=-1,-3
        \\p=3,0 v=-1,-2
        \\p=9,3 v=2,3
        \\p=7,3 v=-1,2
        \\p=2,4 v=2,-3
        \\p=9,5 v=-3,-3
    ;
    try std.testing.expectEqual(12, solve(std.testing.allocator, data, Room{ .w = 11, .h = 7 }, 100));
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const saf_fac = solve(alloc, @embedFile("input14.txt"), Room{ .w = 101, .h = 103 }, 100);
    std.debug.print("Safety Factor: {}\n", .{saf_fac});
    const easter = solve2(alloc, @embedFile("input14.txt"), Room{ .w = 101, .h = 103 });
    std.debug.print("Easter Time  : {}\n", .{easter});
}
