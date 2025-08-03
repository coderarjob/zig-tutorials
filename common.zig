const std = @import("std");
const prn = std.debug.print;
pub fn dbg(msg: []const u8, i: anytype) void {
    prn("{s}:{} = {any}\n", .{ msg, @TypeOf(i), i });
}
pub fn section(msg: []const u8) void {
    prn("\n::: {s} :::\n", .{msg});
}
pub fn print(comptime fmt: ?[]const u8, msg: anytype) void {
    if (fmt) |f| {
        prn(f, .{msg});
    } else {
        prn("{s}\n", .{@as([]const u8, msg)}); // The type cast is optional
    }
}
