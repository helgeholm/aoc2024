const std = @import("std");

const V2 = struct {
    x: isize,
    y: isize,
    pub fn ux(self: @This()) usize {
        return @intCast(self.x);
    }
    pub fn uy(self: @This()) usize {
        return @intCast(self.y);
    }
    pub fn impossible_to_tell_the_difference_between(self: @This(), other: V2) bool {
        return self.x == other.x and self.y == other.y;
    }
    pub fn to_pos(self: @This(), width: usize) usize {
        return @intCast(self.y * @as(isize, @intCast(width)) + self.x);
    }
    pub fn from_pos(pos: usize, width: usize) V2 {
        return V2{
            .x = @intCast(@mod(pos, width)),
            .y = @intCast(@divTrunc(pos, width)),
        };
    }
    pub fn add(self: @This(), other: V2) V2 {
        return V2{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};

const Grid = struct {
    w: usize,
    h: usize,
    data: []const u8,
    visited: [][4]bool,
    pub fn initLeaky(alloc: std.mem.Allocator, data: []const u8) !Grid {
        const v = try alloc.alloc([4]bool, data.len);
        const end_nl = data[data.len - 1] == '\n';
        @memset(v, [_]bool{ false, false, false, false });
        return Grid{
            .w = std.mem.indexOfScalar(u8, data, '\n').?,
            .h = std.mem.count(u8, data, "\n") + (if (end_nl) @as(usize, 0) else 1),
            .data = data,
            .visited = v,
        };
    }
    pub fn clearVisited(self: *@This()) void {
        @memset(self.visited, [_]bool{ false, false, false, false });
    }
    pub fn see(self: @This(), pos: V2) u8 {
        return self.data[pos.to_pos(self.w + 1)];
    }
    pub fn where(self: @This(), what: u8) V2 {
        const what_pos = std.mem.indexOfScalar(u8, self.data, what).?;
        return V2.from_pos(what_pos, self.w + 1);
    }
    pub fn visit(self: *@This(), pos: V2, dir: u3) bool {
        if (self.visited[pos.to_pos(self.w + 1)][dir]) return true;
        self.visited[pos.to_pos(self.w + 1)][dir] = true;
        return false;
    }
    pub fn countVisited(self: @This()) usize {
        var count: usize = 0;
        for (self.visited) |v| {
            if (v[0] or v[1] or v[2] or v[3]) count += 1;
        }
        return count;
    }
    pub fn inside(self: @This(), pos: V2) bool {
        return pos.x >= 0 and pos.y >= 0 and pos.x < self.w and pos.y < self.h;
    }
};

fn loops(g: *Grid, obstacle_pos: ?V2) bool {
    const dirs: [4]V2 = [_]V2{ V2{ .x = 0, .y = -1 }, V2{ .x = 1, .y = 0 }, V2{ .x = 0, .y = 1 }, V2{ .x = -1, .y = 0 } };
    var guard_pos = g.where('^');
    var guard_dir: u3 = 0;
    while (g.inside(guard_pos)) {
        while (true) {
            if (g.visit(guard_pos, guard_dir)) return true;
            const next_pos = guard_pos.add(dirs[guard_dir]);
            const obstacled = obstacle_pos != null and next_pos.impossible_to_tell_the_difference_between(obstacle_pos.?);
            if (obstacled or g.inside(next_pos) and g.see(next_pos) == '#') {
                guard_dir = @mod(guard_dir + 1, 4);
            } else {
                guard_pos = next_pos;
                break;
            }
        }
    }
    return false;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    var aa = std.heap.ArenaAllocator.init(gpa.allocator());
    defer aa.deinit();
    const alloc = aa.allocator();
    var g = try Grid.initLeaky(alloc, @embedFile("input06.txt"));
    _ = loops(&g, null);
    std.debug.print("Visited  : {d}\n", .{g.countVisited()});
    var options: usize = 0;
    for (0..g.h) |y_u| {
        const y: isize = @intCast(y_u);
        for (0..g.w) |x_u| {
            const x: isize = @intCast(x_u);
            g.clearVisited();
            if (loops(&g, V2{ .x = x, .y = y })) options += 1;
        }
    }
    std.debug.print("Looptions: {d}\n", .{options});
}
