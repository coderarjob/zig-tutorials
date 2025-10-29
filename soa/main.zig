// Soa(T, N) generates 'Struct of Arrays' for struct T, where each field of T becomes an array in
// the new type. Its is inspired by the MultiArrayList type in the Zig standard library, but has
// much less features and thus simpler.
// Further read: https://brevzin.github.io/c++/2025/05/02/soa/
//
// Goal:
// const Point = struct {
//  x: u32,
//  y: u32
// }
//
// const SoaPoints = Soa(Point, N);
//
// const SoaPoints = struct {
//  xs: [N]u32,
//  ys: [N]u32,
// }

const std = @import("std");
const StructField = std.builtin.Type.StructField;

fn Soa(comptime T: type, comptime N: usize) type {
    const ti = @typeInfo(T);
    const si = ti.@"struct";
    const in_fields = si.fields;

    // Construct fields for the new struct. It will have as may fields as in the input struct T,
    // just their type is going to be an array.
    var out_fields: [in_fields.len]StructField = undefined;

    for (in_fields, &out_fields) |in_field, *out_field| {
        out_field.* = in_field;
        out_field.name = in_field.name ++ "s";
        out_field.type = [N]in_field.type;
    }

    return @Type(.{
        .@"struct" = .{
            .layout = .auto,
            .decls = si.decls, // Works also if assigned `&.{}`.
            .fields = &out_fields,
            .is_tuple = false,
        },
    });
}

pub fn main() !void {
    const Point = struct {
        x: u32,
        y: u32,
    };

    const PointsSoa = Soa(Point, 5);
    const t = PointsSoa{ .xs = .{ 0, 1, 2, 3, 4 }, .ys = .{ 5, 6, 7, 8, 9 } };

    std.debug.print("xs: {any}\nys: {any}\n", .{ t.xs, t.ys });
}

test "when there are not paddings - sizes must match" {
    const Point = struct {
        x: u32,
        y: u32,
    };

    const PointsSoa = Soa(Point, 100);

    // Since Point struct has no padding bytes both Array Of Sructs and Struct of Array must have
    // same size.
    try std.testing.expect(@sizeOf(Point) == 2 * @sizeOf(u32));
    try std.testing.expect(@sizeOf(Point) == 8);
    try std.testing.expect(@sizeOf([100]Point) == @sizeOf(PointsSoa));
}

test "when there are paddings - SOA type should take less space" {
    const Point = struct {
        x: u32,
        y: u32,
        origin: bool,
    };

    const PointsSoa = Soa(Point, 100);

    // Due to padding bytes, Point structure requires 12 bytes (3 extra padding bytes).
    // In Soa(Point, 1) there are no padding, so its size if only whats required i.e. 9 bytes.
    try std.testing.expect(@sizeOf(Point) == 12);

    // For some reason, `@sizeOf(Soa(Point, 1))` is coming to be 12. May be compiler is allocating
    // from a preallocated (and thus already aligned) buffer. To bypass this we are doing the
    // following and then per item size is coming to be 9 bytes as expected.
    try std.testing.expect(@sizeOf(PointsSoa) / 100 == 9);

    // Its now obvious why the following will be true
    try std.testing.expect(@sizeOf([100]Point) > @sizeOf(PointsSoa));

    // Some stats for fun!
    std.debug.print("Size of 100 Point: {} bytes\n", .{@sizeOf([100]Point)});
    std.debug.print("Size of 100 Point SoAs: {} bytes\n", .{@sizeOf(PointsSoa)});
}
