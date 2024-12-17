const std = @import("std");

pub fn main() void {
    var buf: [16]u4 = undefined;
    std.debug.print("Original   : {d}\n", .{buf[0..run(51064159, &buf, false)]});
    var goal: [16]u4 = [_]u4{ 2, 4, 1, 5, 7, 5, 1, 6, 0, 3, 4, 6, 5, 5, 3, 0 };
    var new_a: usize = 0;
    while (true) {
        // std.debug.print("{}>\n", .{new_a});
        // skip to partial match
        var l: usize = run(new_a, &buf, false);
        if (l != 16 or !std.mem.eql(u4, buf[12..16], goal[12..16])) {
            var try_skip: usize = 1_000_000_000;
            while (try_skip > 0) {
                l = run(new_a + try_skip, &buf, false);
                if (l != 16 or !std.mem.eql(u4, buf[12..16], goal[12..16])) {
                    new_a += try_skip;
                } else {
                    try_skip = @divTrunc(try_skip, 10);
                }
            }
        }
        // skip to larger partial match
        if (l != 16 or !std.mem.eql(u4, buf[11..16], goal[11..16])) {
            if (!std.mem.eql(u4, buf[12..16], goal[12..16])) break;
            var try_skip: usize = 100_000;
            while (try_skip > 0) {
                // if (@mod(new_a, 10_000_000_000) == 0) {
                // std.debug.print("{}>..\n", .{new_a});
                // }
                l = run(new_a + try_skip, &buf, false);
                if (l != 16 or !std.mem.eql(u4, buf[11..16], goal[11..16])) {
                    new_a += try_skip;
                } else {
                    try_skip = @divTrunc(try_skip, 10);
                }
            }
        }
        // std.debug.print("{}...\n", .{new_a});
        // scan for full match
        var ls: usize = 0;
        while (true) {
            ls = run(new_a, &goal, true);
            if (ls == goal.len) break;
            new_a += 1;
            if (buf[11] != 6) break;
            if (@mod(new_a, 10_000_000_000) == 0) {
                break; // re-check partial match skip
            }
        }
        if (ls == goal.len) break;
    }
    std.debug.print("A for quine: {d}\n", .{new_a});
}

fn run(init_a: u64, buffer: []u4, locked_buffer: bool) usize {
    var out_p: usize = 0;
    var a: u64 = init_a;
    var b: u64 = 0;
    var c: u64 = 0;
    while (a > 0) {
        if (out_p == buffer.len) return buffer.len + 1;
        b = @mod(a, 8);
        b ^= 5;
        c = @divTrunc(a, @as(u64, 1) << @as(u6, @intCast(b)));
        b ^= 6;
        a = @divTrunc(a, 1 << 3);
        b ^= c;
        const out_val: u4 = @intCast(@mod(b, 8));
        if (locked_buffer) {
            if (buffer[out_p] != out_val)
                return 0;
        } else {
            buffer[out_p] = out_val;
        }
        out_p += 1;
    }
    return out_p;
}
