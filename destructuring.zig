const std = @import("std");
const print = @import("std").debug.print;

fn divmod(numerator: u32, denominator: u32) struct { u32, u32 } {
    return .{ numerator / denominator, numerator % denominator };
}

pub fn main() void {
    // Destructuring structures
    const div, const mod = divmod(10, 3);

    print("10 / 3 = {}\n", .{div});
    print("10 % 3 = {}\n", .{mod});

    // Anonymous structs can be created without specifying field names, and are referred to as
    // "tuples"
    const a, const b = .{ 12, 13 };

    print("(a, b) = ({},{})\n", .{ a, b });

    // Destructuring vectors
    const v = @Vector(4, i32){ 1, 2, 3, 4 };
    const v1, const v2, _, _ = v;
    print("[{},{},_,_]", .{v1, v2});
}
