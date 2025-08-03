const std = @import("std");
const print = std.debug.print;

fn dbg(msg: []const u8, i: anytype) void {
    print("{s}:{} = {any}\n", .{msg, @TypeOf(i), i});
}

pub fn main() void {
    const ar1 = [_]u8{ 1, 2, 50, 10 };
    dbg("ar1", ar1);
    dbg("ar1.len", ar1.len);
    //print("ar1[5] = {}\n", .{ ar1[ar1.len] });

    print("\n", .{});
    const ar2 = [_:0]u8{ 1, 2, 50, 10 };
    dbg("ar2", ar2);
    dbg("ar2.len", ar2.len);
    dbg("ar2[5]", .{ ar2[ar2.len] });

    print("\n", .{});
    const ar3 = [_]u8{1} ** 10;
    dbg("ar3", ar3);
    dbg("ar3.len", ar3.len);
}
