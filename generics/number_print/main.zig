const std = @import("std");

fn printi(n: i32) void {
    std.debug.print("integer: {}\n", .{n});
}

fn printd(n: f64) void {
    std.debug.print("float: {}\n", .{n});
}

fn print(comptime n: anytype) void {
    const T = @TypeOf(n);
    if (T == comptime_int) {
        printi(n);
    } else if ((T == comptime_float) or (T == f64) or (T == f32)) {
        printd(n);
    } else {
        unreachable;
    }
}

pub fn main() !void {
    print(103);
    print(3.87);
    print(@as(f32, 1.32));
    print(@as(f64, 7.91));
}
