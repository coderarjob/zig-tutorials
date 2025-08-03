const common = @import("common.zig");

pub fn main() void {
    common.section("Basic pointer assignment & dereferencing");
    const a = 0xABCD;
    const b = &a;

    common.dbg("*y", b.*);

    // Slice
    common.section("Slices");
    const c = b[0..1];
    common.dbg("*c", c[0]);

    // Pass value as pointer
    // https://zig.guide/language-basics/pointers
    common.section("Pass value to function using pointers");
    var d: u8 = 22;
    twice_value(&d);
    common.dbg("d", d);

    // Many items pointer
    common.section("Modify array items passed as many items pointer");
    var nums = [_]u8{ 10, 22, 33, 44 };
    twice_values_using_pointers(&nums, nums.len);
    common.dbg("nums", nums);

    // Using Slices
    common.section("Modify array items passed as a slice");
    var nums2 = [_]u8{ 10, 22, 33, 44 };
    twice_values_using_slices(&nums2);
    common.dbg("nums", nums2);

    // Variable pointer to consts
    common.section("Variable pointer to constants");
    const e: u8 = 12;
    const f: u8 = 13;
    var g = &e;
    common.dbg("*g", g.*);

    g = &f;
    common.dbg("*g", g.*);

    // This is illegal, since g points to consts
    //g.* = 10;

    // Const pointer to variables
    common.section("Const pinter to varaibles");
    var h: u8 = 12;
    const i = &h;
    common.dbg("*i", i.*);

    // This is illegal since 'i' pointer is const
    // i = &e;

}

fn twice_value(v: *u8) void {
    v.* *= 2;
}

// Many items pointer points to an unknown number of items, thus we need to pass the size ourselves
fn twice_values_using_pointers(values: [*]u8, len: usize) void {
    // Using poitner indexing
    //var i:u8 = 0;
    //while (i < len) : (i += 1) {
    //    values[i] *= 2;
    //}

    // Using poitner arithmatics
    // For syntax see 'test_while_continue_expression.zig' in https://ziglang.org/documentation/0.14.1/#while
    var head = values;
    var i: u8 = 0;
    while (i < len) : ({
        i += 1;
        head += 1;
    }) {
        head[0] *= 2;
    }
}

fn twice_values_using_slices(values: []u8) void {
    for (values) |*v| {
        v.* *= 2;
    }
}
