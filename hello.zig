const std = @import("std");
const print = std.debug.print;

const Point = struct {
    x: i32,
    y: i32,
};

fn dbg(v: anytype) void {
    const src = @src();
    print("{s}:{} value is {}\n", .{ src.file, src.line, v });
}

pub fn main() !void {
    const p: Point = .{ .x = 10, .y = 12 };
    dbg(p);
    print("{any}", .{p});

    const t = 11;
    const m, const n = switch(t) {
        10 => .{2,3},
        else => .{5, 6}
    };

    print("({}, {})\n", .{m, n});
}

