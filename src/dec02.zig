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
    var highDiff: u32 = 0;
    var lowDiff: u32 = std.math.maxInt(u32);
    var valIt = std.mem.splitSequence(u8, report, " ");
    var pos: usize = 0;
    if (butIgnore) |iPos| {
        if (pos == iPos) _ = valIt.next();
    }
    var currLevel = std.fmt.parseInt(u32, valIt.next().?, 10) catch unreachable;
    while (valIt.next()) |levelStr| {
        pos += 1;
        if (butIgnore) |iPos| {
            if (pos == iPos) continue;
        }
        const level = std.fmt.parseInt(u32, levelStr, 10) catch unreachable;
        var diff: u32 = undefined;
        if (currLevel < level) {
            asc = true;
            diff = level - currLevel;
        } else {
            diff = currLevel - level;
            desc = currLevel > level;
        }
        lowDiff = @min(lowDiff, diff);
        highDiff = @max(highDiff, diff);
        currLevel = level;
    }
    return !(desc and asc) and highDiff <= 3 and lowDiff >= 1;
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
        var safe = false;
        for (0..levels) |skipzer| {
            safe = safe or isSafe(line, skipzer);
        }
        if (safe) validReports += 1;
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
