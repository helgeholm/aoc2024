const std = @import("std");

pub fn main() !void {
    const data: []const u8 = @embedFile("input03.txt");
    const beans = solve(data);
    const pork = solve2(data);
    std.debug.print("Sum:  {}\n", .{beans});
    std.debug.print("Sum2: {}\n", .{pork});
}

fn solve(data: []const u8) u32 {
    var sum: u32 = 0;
    var rem = data[0..];
    while (true) {
        if (std.mem.indexOf(u8, rem, "mul(")) |p| {
            rem = parseNextMul(rem[p + 4 ..], &sum, true);
        } else {
            return sum;
        }
    }
}

fn solve2(data: []const u8) u32 {
    var sum: u32 = 0;
    var do = true;
    var rem = data[0..];
    while (true) {
        if (std.mem.indexOf(u8, rem, "mul(")) |p| {
            const p_do = std.mem.indexOf(u8, rem, "do()") orelse p;
            const p_dont = std.mem.indexOf(u8, rem, "don't()") orelse p;
            if (p_do < p and p_do < p_dont) {
                do = true;
                rem = rem[p_do + 4 ..];
            } else if (p_dont < p and p_dont < p_do) {
                do = false;
                rem = rem[p_dont + 7 ..];
            } else {
                rem = parseNextMul(rem[p + 4 ..], &sum, do);
            }
        } else {
            return sum;
        }
    }
}

fn parseNextMul(data2: []const u8, sum: *u32, add: bool) []const u8 {
    if (std.mem.indexOf(u8, data2, ",")) |r| {
        if (r < 1 or r > 3) return data2;
        const data3 = data2[r + 1 ..];
        if (std.mem.indexOf(u8, data3, ")")) |q| {
            if (q < 1 or q > 3) return data3;
            const n1 = std.fmt.parseInt(u32, data2[0..r], 10) catch return data2;
            const n2 = std.fmt.parseInt(u32, data3[0..q], 10) catch return data3;
            if (add) sum.* += n1 * n2;
            return data3[q + 1 ..];
        }
    }
    return data2;
}

test solve {
    const input: []const u8 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    try std.testing.expectEqual(161, solve(input[0..]));
}

test solve2 {
    const input: []const u8 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    try std.testing.expectEqual(48, solve2(input[0..]));
}
