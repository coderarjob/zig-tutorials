const std = @import("std");
const expect = std.testing.expect;
const common = @import("common.zig");

pub fn main() !void {
    common.section("Optional value check using if");
    //if (allocate(100)) |p| {
    //    _ = p;
    //} else {
    //    common.print(null, "Could not allocate. Returned null");
    //}

    common.section("Optional value check using named block and if");
    //const p = alloc: {
    //    if (allocate(100)) |p| break :alloc p;
    //    @panic("Could not allocate. Returned null");
    //};
    //_ = p;

    common.section("Optional value check using if as expression");
    //const a = if (allocate(100)) |b| b else @panic("Could not allocate");
    //_ = a;

    common.section("Optional value check orelse");
    //const b = (allocate(100)) orelse @panic("Could not allocate");
    //_ = b;

    common.section("Optional value with error - try method and orelse");
    //const b = (try allocate_can_fail(100)) orelse @panic("Could not allocate");
    //_ = b;

    common.section("Optional value with error - if else method");
    //const c = if (allocate_can_fail(100)) |v| pass: {
    //    break :pass v orelse @panic("Could not allocate");
    //} else |_| @panic("Error occured");
    //_ = c;

    common.section("Optional value with error - catch and orelse method");
    const c = allocate_can_fail(100) catch @panic("Error occured") orelse @panic("Could not allocate");
    _ = c;
}

fn allocate(comptime bytes: usize) ?[]u8 {
    //var buffer = ([_]u8{1} ** bytes);
    //return &buffer;
    _ = bytes;
    return null;
}

fn allocate_can_fail(comptime bytes: usize) !?[]u8 {
    _ = bytes;
    //return null;
    return error.OutOfMemory;
}
