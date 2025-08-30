const first = @import("first.zig");
const second = @import("second.zig");
const third = @import("third.zig");
const fourth = @import("fourth.zig");
const fifth = @import("fifth.zig");

pub fn main() void {
    first.demo();
    second.demo();
    third.demo();
    fourth.demo();
    fifth.demo();
}
