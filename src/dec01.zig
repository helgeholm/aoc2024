const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        _ = gpa.deinit();
    }
    const alloc = gpa.allocator();
    var leftList = std.ArrayList(u32).init(alloc);
    defer leftList.deinit();
    var rightList = std.ArrayList(u32).init(alloc);
    defer rightList.deinit();
    var file = try std.fs.cwd().openFile("input01.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");
        const leftInput = it.next().?;
        const rightInput = it.next().?;
        const leftNum = try std.fmt.parseInt(u32, leftInput, 10);
        const rightNum = try std.fmt.parseInt(u32, rightInput, 10);
        try leftList.append(leftNum);
        try rightList.append(rightNum);
    }
    std.mem.sort(u32, leftList.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, rightList.items, {}, comptime std.sort.asc(u32));
    std.debug.print("*  {}\n", .{solve(leftList.items, rightList.items)});
    std.debug.print("** {}\n", .{try solve2(alloc, leftList.items, rightList.items)});
}

fn solve(left: []u32, right: []u32) u32 {
    var sum: u32 = 0;
    for (0..left.len) |i| {
        sum += if (left[i] < right[i]) right[i] - left[i] else left[i] - right[i];
    }
    return sum;
}

fn solve2(alloc: anytype, left: []u32, right: []u32) !u32 {
    var rights = std.AutoHashMap(u32, u32).init(alloc);
    defer rights.deinit();
    for (right) |v| {
        const r = try rights.getOrPut(v);
        if (!r.found_existing) r.value_ptr.* = 0;
        r.value_ptr.* += 1;
    }
    var sum: u32 = 0;
    for (left) |v| {
        if (rights.get(v)) |r| {
            sum += v * r;
        }
    }
    return sum;
}
