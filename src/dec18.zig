const std = @import("std");

const EXAMPLE_INPUT =
    \\5,4
    \\4,2
    \\4,5
    \\3,0
    \\2,1
    \\6,3
    \\2,4
    \\1,5
    \\0,6
    \\3,3
    \\2,6
    \\5,1
    \\1,2
    \\5,5
    \\2,5
    \\6,5
    \\1,4
    \\0,4
    \\6,4
    \\1,1
    \\6,1
    \\1,0
    \\0,5
    \\1,6
    \\2,0
;

pub fn main() void {
    var g = Grid(71, 71).init;
    const data = @embedFile("input18.txt");
    var it = std.mem.splitScalar(u8, data, '\n');
    var time: u16 = 0;
    var blocked: bool = false;
    while (it.next()) |line| {
        time += 1;
        if (line.len == 0) continue;
        var numbsies = std.mem.splitScalar(u8, line, ',');
        const x = std.fmt.parseInt(u8, numbsies.next().?, 10) catch unreachable;
        const y = std.fmt.parseInt(u8, numbsies.next().?, 10) catch unreachable;
        g.at(y, x).* = time;
        g.pathfind_static(time);
        if (!blocked and g.nav[71 * 71 - 1].min_steps == 0xffff) {
            std.debug.print("First blocking: {d},{d}\n", .{ x, y });
            blocked = true;
        }
    }
    g.pathfind_static(1024);
    std.debug.print("1024-path: {}\n", .{g.nav[71 * 71 - 1]});
}

const Nav = struct {
    from: u16,
    min_steps: u16,
    pub const init: Nav = .{ .from = 0xffff, .min_steps = 0xffff };
};

fn Grid(W: u8, H: u8) type {
    const size: u16 = @as(u16, W) * H;
    return struct {
        corrupted_nanos: [size]u16 = undefined,
        nav: [size]Nav,
        nav_q: [size * 2]u16,
        pub const init: Grid(W, H) = .{
            .corrupted_nanos = [_]u16{0xffff} ** size,
            .nav = [_]Nav{Nav.init} ** size,
            .nav_q = undefined,
        };
        pub fn pathfind_static(self: *@This(), at_time: u16) void {
            self.nav = [_]Nav{Nav.init} ** size;
            self.nav_q[0] = 0;
            self.nav[0].min_steps = 0;
            var nav_q_start: u16 = 0;
            var nav_q_end: u16 = 1;
            while (nav_q_end != nav_q_start) {
                const pos = self.nav_q[nav_q_start];
                nav_q_start = @intCast(@mod(nav_q_start + 1, self.nav_q.len));
                const x: u8 = @intCast(@mod(pos, W));
                const y: u8 = @intCast(@divTrunc(pos, W));
                const dx: [4]i2 = [_]i2{ 1, 0, -1, 0 };
                const dy: [4]i2 = [_]i2{ 0, 1, 0, -1 };
                for (0..dy.len) |d| {
                    const nx: i9 = @as(i9, x) + dx[d];
                    const ny: i9 = @as(i9, y) + dy[d];
                    if (nx >= 0 and nx < W and ny >= 0 and ny < H) {
                        const np: u16 = @as(u16, @intCast(W)) * @as(u16, @intCast(ny)) + @as(u16, @intCast(nx));
                        if (self.corrupted_nanos[np] > at_time and
                            self.nav[np].min_steps > self.nav[pos].min_steps + 1)
                        {
                            self.nav[np].min_steps = self.nav[pos].min_steps + 1;
                            self.nav[np].from = pos;
                            self.nav_q[nav_q_end] = np;
                            nav_q_end = @intCast(@mod(nav_q_end + 1, self.nav_q.len));
                        }
                    }
                }
            }
        }
        pub fn at(self: *@This(), r: u8, c: u8) *u16 {
            return &self.corrupted_nanos[@as(u16, W) * r + c];
        }
        pub fn at_r(self: @This(), r: u8, c: u8) u16 {
            return self.corrupted_nanos[@as(u16, W) * r + c];
        }
        pub fn print(self: @This(), stop: u16) void {
            for (0..H) |r_u| {
                const r: u8 = @intCast(r_u);
                for (0..W) |c_u| {
                    const c: u8 = @intCast(c_u);
                    const t: u16 = self.at_r(r, c);
                    const l: u8 = if (t > 0 and t <= stop) '#' else '.';
                    std.debug.print("{c}", .{l});
                }
                std.debug.print("\n", .{});
            }
        }
    };
}
