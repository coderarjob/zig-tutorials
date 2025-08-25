const std = @import("std");

fn CounterMixin(comptime T: type) type {
    return struct {
        pub fn increment(self: *@This()) void {
            // It is not requried to do below check, the compiler will do it. Even without the below
            // check compilation will fail if there is no 'count' field in the `T` type.
            if (!@hasField(T, "count")) {
                @compileError("'count' field is required but missing.");
            }
            var x: *T = @alignCast(@fieldParentPtr("counter", self));
            x.count += 1;
        }
    };
}

const FileNumber = struct {
    count: u32 = 0,
    counter: CounterMixin(@This()) = .{}
};

const Attendance = struct {
    count: u32 = 0,
    counter: CounterMixin(@This()) = .{}
};

pub fn main() !void {
    var f = FileNumber{};
    var a = Attendance{};

    std.debug.print("Before increment: FileNumber {}\n", .{f.count});
    std.debug.print("Before increment: Attendance {}\n", .{a.count});

    f.counter.increment();
    f.counter.increment();

    a.counter.increment();
    a.counter.increment();
    a.counter.increment();

    std.debug.print("After increment: FileNumber {}\n", .{f.count});
    std.debug.print("After increment: Attendance {}\n", .{a.count});

    std.debug.print("{}\n", .{@sizeOf(FileNumber)});
}
