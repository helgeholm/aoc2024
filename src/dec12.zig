const std = @import("std");
const Grid = @import("grid.zig").Grid;
const Region = @import("grid.zig").Region;

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
