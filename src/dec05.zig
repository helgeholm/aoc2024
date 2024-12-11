const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const input = @embedFile("input05.txt");
    std.debug.print("Result correct  : {}\n", .{try solve(alloc, input, false)});
    std.debug.print("Result corrected: {}\n", .{try solve(alloc, input, true)});
}

const Rule = struct { before: u7, after: u7 };

fn solve(alloc: std.mem.Allocator, data: []const u8, rearrange: bool) !u32 {
    var rules = std.ArrayList(Rule).init(alloc);
    defer rules.deinit();
    const pos_rules_end = std.mem.indexOf(u8, data, "\n\n").?;
    var rule_it = std.mem.splitSequence(u8, data[0..pos_rules_end], "\n");
    while (rule_it.next()) |line| {
        var i = std.mem.splitSequence(u8, line, "|");
        const rule = try rules.addOne();
        rule.*.before = try std.fmt.parseInt(u7, i.next().?, 10);
        rule.*.after = try std.fmt.parseInt(u7, i.next().?, 10);
    }
    var result: u32 = 0;
    var patch_it = std.mem.splitSequence(u8, data[pos_rules_end + 2 ..], "\n");
    while (patch_it.next()) |line| {
        if (line.len == 0) continue;
        var page_it = std.mem.splitSequence(u8, line, ",");
        var pages = std.ArrayList(u7).init(alloc);
        defer pages.deinit();
        while (page_it.next()) |page| {
            (try pages.addOne()).* = try std.fmt.parseInt(u7, page, 10);
        }
        if (valid(rules.items, pages.items)) {
            const page_mid: u7 = pages.items[(pages.items.len - 1) / 2];
            if (!rearrange) result += page_mid;
        } else {
            if (rearrange) {
                try doRearrange(rules.items, pages);
                const page_mid: u7 = pages.items[(pages.items.len - 1) / 2];
                result += page_mid;
            }
        }
    }
    return result;
}

fn doRearrange(rules: []const Rule, pages_: std.ArrayList(u7)) !void {
    var pages = pages_;
    var needs_checking = true;
    while (needs_checking) {
        needs_checking = false;
        for (rules) |rule| {
            if (std.mem.indexOfScalar(u7, pages.items, rule.before)) |before_pos| {
                if (std.mem.indexOfScalar(u7, pages.items, rule.after)) |after_pos| {
                    if (before_pos > after_pos) {
                        const page = pages.orderedRemove(before_pos);
                        try pages.insert(after_pos, page);
                        needs_checking = true;
                    }
                }
            }
        }
    }
}

fn valid(rules: []const Rule, pages: []const u7) bool {
    for (rules) |rule| {
        if (std.mem.indexOfScalar(u7, pages, rule.before)) |before_pos| {
            if (std.mem.indexOfScalar(u7, pages, rule.after)) |after_pos| {
                if (before_pos > after_pos) {
                    return false;
                }
            }
        }
    }
    return true;
}

test "solve_1" {
    const data =
        \\1|2
        \\
        \\1,2,3
    ;
    try std.testing.expectEqual(2, try solve(std.testing.allocator, data, false));
    try std.testing.expectEqual(0, try solve(std.testing.allocator, data, true));
}

test solve {
    const data =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    try std.testing.expectEqual(143, try solve(std.testing.allocator, data, false));
    try std.testing.expectEqual(123, try solve(std.testing.allocator, data, true));
}
