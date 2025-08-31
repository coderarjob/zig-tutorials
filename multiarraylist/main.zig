// Implementation of a type which does struct of Arrays
// Source: https://brevzin.github.io/c++/2025/05/02/soa/

// Goal:
// const Point = struct {
//  x: u32,
//  y: u32
// }
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

    inline for (in_fields, &out_fields) |in_field, *out_field| {
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
    const Point = struct { x: u32, y: u32 };
    const PointsSoa = Soa(Point, 5);
    const t = PointsSoa{ .xs = .{ 0, 1, 2, 3, 4 }, .ys = .{ 5, 6, 7, 8, 9 } };

    std.debug.print("{any}, {any}", .{ t.xs, t.ys });
}
