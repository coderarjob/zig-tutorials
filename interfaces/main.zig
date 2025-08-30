// first, second and third are similar. Uses opaque pointers to point to implementations.
// fourth is an limited but easier & cleaner way to implement interfaces.
// fifth provides similar extensibility as the first, but is easier & cleaner.
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
