const std = @import("std");

pub fn main() !void {
    const data: []const u8 = @embedFile("input04.txt");
    const egg_smash = solve(data);
    const xmas = solve2(data);
    std.debug.print("Count wrong    : {}\n", .{egg_smash});
    std.debug.print("Count correctly: {}\n", .{xmas});
}

fn solve(data: []const u8) u32 {
    if (std.mem.indexOfScalar(u8, data, '\r') != null) @panic("expect only \\n newlines");
    const width: i32 = @intCast(std.mem.indexOfScalar(u8, data, '\n').? + 1);
    const vectors = [_]i32{ 1, width + 1, width, width - 1, -1, -width - 1, -width, -width + 1 };
    var count: u32 = 0;
    for (0..data.len) |i_u| {
        const i: i32 = @intCast(i_u);
        for (vectors) |v| {
            if (projectionEquals(data, i, v, "XMAS")) count += 1;
        }
    }
    return count;
}

fn solve2(data: []const u8) u32 {
    const width: i32 = @intCast(std.mem.indexOfScalar(u8, data, '\n').? + 1);
    const vectors = [_]i32{ width + 1, -width - 1, width - 1, -width + 1 };
    var count: u32 = 0;
    for (0..data.len) |i_d| {
        const origin: i32 = @intCast(i_d);
        var cross_count: u2 = 0;
        for (vectors) |v| {
            if (projectionEquals(data, origin - v, v, "MAS")) cross_count += 1;
        }
        if (cross_count == 2) count += 1;
    }
    return count;
}

fn projectionEquals(data: []const u8, start: i32, direction: i32, value: []const u8) bool {
    const value_len_i32: i32 = @intCast(value.len);
    const end: i32 = start + direction * (value_len_i32 - 1);
    if (start < 0 or start >= data.len) return false;
    if (end < 0 or end >= data.len) return false;
    for (0..value.len) |i_usize| {
        const i: i32 = @intCast(i_usize);
        const pos: usize = @intCast(start + direction * i);
        if (data[pos] != value[i_usize]) return false;
    }
    return true;
}

test "solve_v0" {
    const data = "XMAS\n";
    try std.testing.expectEqual(1, solve(data));
}

test "solve_v2" {
    const data =
        \\X
        \\M
        \\A
        \\S
    ;
    try std.testing.expectEqual(1, solve(data));
}

test solve {
    const data =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    try std.testing.expectEqual(18, solve(data));
}

test "solve2_v0" {
    const data =
        \\.M.
        \\MAS
        \\.S.
    ;
    try std.testing.expectEqual(0, solve2(data));
}

test "solve2_v0r" {
    const data =
        \\MMS
        \\MAS
        \\MSS
    ;
    try std.testing.expectEqual(1, solve2(data));
}

test solve2 {
    const data =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    try std.testing.expectEqual(9, solve2(data));
}

test "solve2_." {
    const data =
        \\.M.S......
        \\..A..MSMS.
        \\.M.S.MAA..
        \\..A.ASMSM.
        \\.M.S.M....
        \\..........
        \\S.S.S.S.S.
        \\.A.A.A.A..
        \\M.M.M.M.M.
        \\..........
    ;
    try std.testing.expectEqual(9, solve2(data));
}
