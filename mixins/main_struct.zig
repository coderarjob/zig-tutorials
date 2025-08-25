// Mixins are cool but not always required. Here for example, Counter can be self contained -
// containing both field and methods that operate on them. In this simple example, FileNumber &
// Attendance types has no purpose and can just be variables giving context from just the variable
// name.
const std = @import("std");

const Counter = struct {
    count: u32 = 0,
    pub fn increment(self: *@This()) void {
        self.count += 1;
    }
};

const FileNumber = struct { counter: Counter = .{} };
const Attendance = struct { counter: Counter = .{} };

pub fn main() !void {
    var f = FileNumber{};
    var a = Attendance{};

    std.debug.print("Before increment: FileNumber {}\n", .{f.counter.count});
    std.debug.print("Before increment: Attendance {}\n", .{a.counter.count});

    f.counter.increment();
    f.counter.increment();

    a.counter.increment();
    a.counter.increment();
    a.counter.increment();

    std.debug.print("After increment: FileNumber {}\n", .{f.counter.count});
    std.debug.print("After increment: Attendance {}\n", .{a.counter.count});

    std.debug.print("{}\n", .{@sizeOf(FileNumber)});
}
