const std = @import("std");

pub const Region = struct {
    mark: []const u32,
    id: u32,
    width: usize,
    pub fn area(self: @This()) usize {
        return std.mem.count(u32, self.mark, &[_]u32{self.id});
    }
    fn height(self: @This()) usize {
        return @divExact(self.mark.len, self.width);
    }
    fn hasFenceOut(self: @This(), r: isize, c: isize, d: isize) bool {
        if (r < 0 or c < 0 or r >= self.height() or c >= self.width) return false;
        const w: isize = @intCast(self.width);
        const pi = r * w + c;
        if (self.mark[@as(usize, @intCast(pi))] != self.id) return false;
        const po_i: isize = @as(isize, @intCast(pi)) + d;
        if (po_i < 0 or po_i >= self.mark.len) return true;
        const po: usize = @intCast(po_i);
        if ((d == 1 or d == -1) and @divTrunc(po, self.width) != r) return true;
        return self.mark[po] != self.id;
    }
    pub fn sides(self: @This()) usize {
        var count: usize = 0;
        const w: isize = @intCast(self.width);
        for (0..self.width) |c_u| {
            const c: isize = @bitCast(c_u);
            for (0..self.height()) |r_u| {
                const r: isize = @bitCast(r_u);
                if (self.hasFenceOut(r, c, -w) and !self.hasFenceOut(r, c - 1, -w))
                    count += 1;
                if (self.hasFenceOut(r, c, w) and !self.hasFenceOut(r, c - 1, w))
                    count += 1;
                if (self.hasFenceOut(r, c, -1) and !self.hasFenceOut(r - 1, c, -1))
                    count += 1;
                if (self.hasFenceOut(r, c, 1) and !self.hasFenceOut(r - 1, c, 1))
                    count += 1;
            }
        }
        return count;
    }
    pub fn perimeter(self: @This()) usize {
        var n: usize = 0;
        var in = false;
        for (0..self.mark.len) |p| {
            if (@mod(p, self.width) == 0 and in) {
                in = false;
                n += 1;
            }
            if (self.mark[p] == self.id and !in) {
                in = true;
                n += 1;
            }
            if (self.mark[p] != self.id and in) {
                in = false;
                n += 1;
            }
        }
        if (in) n += 1;
        for (0..self.width) |c| {
            in = false;
            for (0..self.height()) |r| {
                if (self.mark[r * self.width + c] == self.id and !in) {
                    in = true;
                    n += 1;
                }
                if (self.mark[r * self.width + c] != self.id and in) {
                    in = false;
                    n += 1;
                }
            }
            if (in) {
                in = false;
                n += 1;
            }
        }
        return n;
    }
};

pub fn Grid(comptime T: type) type {
    return struct {
        data: []const T,
        width: usize,
        height: usize,
        pub fn init(data: []const T, row_separator: T) Grid(T) {
            const len = if (data[data.len - 1] == row_separator) data.len - 1 else data.len;
            const width =
                if (std.mem.indexOfScalar(T, data, row_separator)) |w| w else len;
            const height =
                if (width == 0) 0 else std.mem.count(T, data[0..len], &[_]T{row_separator}) + 1;
            return .{
                .width = width,
                .height = height,
                .data = data[0..len],
            };
        }
        pub fn walkRegions(self: Grid(T), alloc: std.mem.Allocator, callback: anytype) !void {
            const mark = try alloc.alloc(u32, self.width * self.height);
            defer alloc.free(mark);
            @memset(mark, 0);
            var dfs_q = try std.ArrayListUnmanaged(usize).initCapacity(alloc, 4 * mark.len);
            defer dfs_q.deinit(alloc);
            var id: u32 = 0;
            while (true) {
                const start = std.mem.indexOfScalar(u32, mark, 0);
                if (start == null) break;
                const ground = self.data[start.? + @divTrunc(start.?, self.width)];
                id += 1;
                dfs_q.appendAssumeCapacity(start.?);
                while (dfs_q.items.len > 0) {
                    const p = dfs_q.pop();
                    if (mark[p] != 0) continue;
                    const dp = p + @divTrunc(p, self.width);
                    if (self.data[dp] != ground) continue;
                    mark[p] = id;
                    if (p >= self.width) dfs_q.appendAssumeCapacity(p - self.width);
                    if (p < mark.len - self.width) dfs_q.appendAssumeCapacity(p + self.width);
                    if (@mod(p, self.width) != 0) dfs_q.appendAssumeCapacity(p - 1);
                    if (@mod(p + 1, self.width) != 0) dfs_q.appendAssumeCapacity(p + 1);
                }
                callback.call(Region{
                    .mark = mark,
                    .id = id,
                    .width = self.width,
                });
            }
        }
    };
}

test "Grid it" {
    const data =
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
    ;
    var g = Grid(u8).init(data, '\n');
    const Counter = struct {
        n: u3 = 0,
        pub fn call(self: *@This(), _: Region) void {
            self.n += 1;
        }
    };
    var c = Counter{};
    try g.walkRegions(std.testing.allocator, &c);
    try std.testing.expectEqual(5, c.n);
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();
    defer _ = gpa.deinit();
    const cost = try solve(@embedFile("input12.txt"), alloc);
    const cost2 = try solve2(@embedFile("input12.txt"), alloc);
    std.debug.print("Cost Original: {}\n", .{cost});
    std.debug.print("Cost Discount: {}\n", .{cost2});
}

fn solve(data: []const u8, alloc: std.mem.Allocator) !u32 {
    var g = Grid(u8).init(data, '\n');
    const Summer = struct {
        cost: u32 = 0,
        pub fn call(self: *@This(), r: Region) void {
            self.cost += @truncate(r.perimeter() * r.area());
        }
    };
    var s = Summer{};
    try g.walkRegions(alloc, &s);
    return s.cost;
}

fn solve2(data: []const u8, alloc: std.mem.Allocator) !u32 {
    var g = Grid(u8).init(data, '\n');
    const Summer = struct {
        cost: u32 = 0,
        pub fn call(self: *@This(), r: Region) void {
            self.cost += @truncate(r.sides() * r.area());
        }
    };
    var s = Summer{};
    try g.walkRegions(alloc, &s);
    return s.cost;
}

test solve {
    const data =
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
        \\
    ;
    try std.testing.expectEqual(140, try solve(data, std.testing.allocator));
}

test "solve region in region" {
    const data =
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\OXOXO
        \\OOOOO
    ;
    try std.testing.expectEqual(772, try solve(data, std.testing.allocator));
}

test "solve larger" {
    const data =
        \\RRRRIICCFF
        \\RRRRIICCCF
        \\VVRRRCCFFF
        \\VVRCCCJFFF
        \\VVVVCJJCFE
        \\VVIVCCJJEE
        \\VVIIICJJEE
        \\MIIIIIJJEE
        \\MIIISIJEEE
        \\MMMISSJEEE
    ;
    try std.testing.expectEqual(1930, try solve(data, std.testing.allocator));
}

test "solve but don't wrap" {
    const data =
        \\ABB
        \\ABA
        \\ABB
    ;
    try std.testing.expectEqual(8 * 3 + 12 * 5 + 4 * 1, try solve(data, std.testing.allocator));
}

test "solve2 something" {
    const data =
        \\ABB
        \\ABA
        \\ABB
    ;
    try std.testing.expectEqual(4 * 3 + 8 * 5 + 4 * 1, try solve2(data, std.testing.allocator));
}
