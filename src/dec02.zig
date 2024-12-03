const std = @import("std");

pub fn main() !void {
    const data: []const u8 = @embedFile("input02.txt");
    const beans = solve(data);
    const sausages = solve2(data);
    std.debug.print("Safe reports: {}\n", .{beans});
    std.debug.print("Safe reports with dampener: {}\n", .{sausages});
}

fn isSafe(report: []const u8, butIgnore: ?usize) bool {
    var desc = false;
    var asc = false;
    var levels = std.mem.splitSequence(u8, report, " ");
    var pos: usize = 0;
    var currLevel: ?u32 = null;
    while (levels.next()) |levelStr| : (pos += 1) {
        if (butIgnore) |i| if (pos == i)
            continue;
        const level = std.fmt.parseInt(u32, levelStr, 10) catch unreachable;
        if (currLevel) |cl| {
            const diff = if (cl < level) level - cl else cl - level;
            asc = asc or cl < level;
            desc = desc or cl > level;
            if (desc and asc or diff > 3 or diff < 1)
                return false;
        }
        currLevel = level;
    }
    return true;
}

fn solve(data: []const u8) u32 {
    var validReports: u32 = 0;
    var lineIt = std.mem.splitSequence(u8, data, "\n");
    while (lineIt.next()) |line| {
        if (line.len == 0) continue;
        if (isSafe(line, null)) validReports += 1;
    }
    return validReports;
}

fn solve2(data: []const u8) u32 {
    var validReports: u32 = 0;
    var lineIt = std.mem.splitSequence(u8, data, "\n");
    while (lineIt.next()) |line| {
        if (line.len == 0) continue;
        const levels = 1 + std.mem.count(u8, line, " ");
        for (0..levels) |skipzer| {
            if (isSafe(line, skipzer)) {
                validReports += 1;
                break;
            }
        }
    }
    return validReports;
}

test solve {
    const input: []const u8 =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    try std.testing.expectEqual(2, solve(input[0..]));
}

test solve2 {
    const input: []const u8 =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    try std.testing.expectEqual(4, solve2(input[0..]));
}
