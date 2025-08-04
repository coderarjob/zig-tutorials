const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const Printer = struct {
    printfn: *const fn (self: *const anyopaque, s: []const u8) void,
    obj: *const anyopaque,

    pub fn print(self: Printer, s: []const u8) void {
        self.printfn(self.obj, s);
    }
};

const Human = struct {
    id: u32,
    const Self = @This();
    pub fn printer(self: *const Self) Printer {
        return .{ .printfn = say_hello, .obj = self };
    }
    pub fn say_hello(ptr: *const anyopaque, s: []const u8) void {
        const self: *const Self = @ptrCast(@alignCast(ptr));
        print("Human with ID:{} says {s}\n", .{ self.id, s });
    }
};

const Dog = struct {
    id: u32,
    const Self = @This();
    pub fn printer(self: *const Self) Printer {
        return .{ .printfn = bark, .obj = self };
    }
    pub fn bark(ptr: *const anyopaque, s: []const u8) void {
        const self: *const Self = @ptrCast(@alignCast(ptr));
        print("Dog with ID:{} says {s}\n", .{ self.id, s });
    }
};

pub fn main() !void {
    const man1 = Human{ .id = 14 };
    const man2 = Human{ .id = 18 };
    const dog1 = Dog{ .id = 140 };
    const dog2 = Dog{ .id = 180 };

    var printer = man1.printer();
    printer.print("Hello");

    printer = man2.printer();
    printer.print("Ola");

    printer = dog1.printer();
    printer.print("Baw Bow");

    printer = dog2.printer();
    printer.print("<I do not bark>");
}
