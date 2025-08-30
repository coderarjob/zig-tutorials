const std = @import("std");
const print = std.debug.print;

// This is the most standard implementation an Interface in Zig. Its is intuitive with very few
// magic. But like everything there are drawbacks, and they are:
// 1. Human.say_hello, Dog.bark is now no longer methods of those types, since the first argument is
// anyopaque and not Human or Dog. This is odd, because they are actually methods but does not look
// like that.
// 2. If there are a large number of functions, then passing them along might be a problem. Some
// types in the std library creates a separate struct called VTable to pass around function
// 3. We cannot use @call function to call the final method in the Speaker.say method.
// pointers.
// Source: https://www.openmymind.net/Zig-Interfaces/

const Speaker = struct {
    sayfn: *const fn (self: *const anyopaque, s: []const u8) void,
    obj: *const anyopaque,

    pub fn say(self: Speaker, s: []const u8) void {
        self.sayfn(self.obj, s);
    }
};

const Human = struct {
    id: u32,
    const Self = @This();
    pub fn speaker(self: *const Self) Speaker {
        return .{ .sayfn = say_hello, .obj = self };
    }
    pub fn say_hello(ptr: *const anyopaque, s: []const u8) void {
        const self: *const Self = @ptrCast(@alignCast(ptr));
        print("Human with ID:{} says {s}\n", .{ self.id, s });
    }
};

const Dog = struct {
    id: u32,
    const Self = @This();
    pub fn speaker(self: *const Self) Speaker {
        return .{ .sayfn = bark, .obj = self };
    }
    pub fn bark(ptr: *const anyopaque, s: []const u8) void {
        const self: *const Self = @ptrCast(@alignCast(ptr));
        print("Dog with ID:{} says {s}\n", .{ self.id, s });
    }
};

pub fn demo() void {
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human{.id = 33 };
    const dog = Dog{.id = 727 };

    var speaker = man.speaker();
    speaker.say("Hello");

    speaker = dog.speaker();
    speaker.say("Bark");
}
