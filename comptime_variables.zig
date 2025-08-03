const std = @import("std");
const expect = std.testing.expect;

// What is happening:
// y is equal to 2 at compile time, so the `if (y != 2)` does not trigger. This if statement is also
// evaluated at compile time since `y` is known at compile time.
// If we replaced `if (y != 2)` with `if (x != 2)`. Now since `x` is not a compile time variable
// the compiler will not know if block will get executed, and thus the @compileError get hit.

test "comptime vars" {
    var x: i32 = 1;
    comptime var y: i32 = 1;

    x += 1;
    y += 1;

    try expect(x == 2);
    try expect(y == 2);

    if (x != 2) {
        // This compile error never triggers because y is a comptime variable,
        // and so `y != 2` is a comptime value, and this if is statically evaluated.
        @compileError("wrong y value");
    }
}
