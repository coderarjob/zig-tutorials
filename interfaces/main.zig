const std = @import("std");
const print = std.debug.print;

// This is the most standard implementation an Interface in Zig. Its is intuitive with very few
// magic. But like everything there are drawbacks, and they are:
// 1. Human.say_hello, Dog.bark is now no longer methods of those types, since the first argument is
// anyopaque and not Human or Dog. This is odd, because they are actually methods but does not look
// like that.
// 2. If there are a large number of functions, then passing them along might be a problem. Some
// types in the std library creates a separate struct called VTable to pass around function
// pointers.
// Source: https://www.openmymind.net/Zig-Interfaces/

const FirstInterfaceExample = struct {
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
        const man1 = Human{ .id = 14 };
        const man2 = Human{ .id = 18 };
        const dog1 = Dog{ .id = 140 };
        const dog2 = Dog{ .id = 180 };

        var speaker = man1.speaker();
        speaker.say("Hello");

        speaker = man2.speaker();
        speaker.say("Ola");

        speaker = dog1.speaker();
        speaker.say("Baw Bow");

        speaker = dog2.speaker();
        speaker.say("<I do not bark>");
    }
};

// This is a bit more involved interface implementation, but solves the problems described above.
// Source: https://www.openmymind.net/Zig-Interfaces/
const SecondInterfaceExample = struct {
    const Speaker = struct {
        sayfn: *const fn (self: *const anyopaque, s: []const u8) void,
        obj: *const anyopaque,

        pub fn init(obj: anytype) Speaker {
            const T = @TypeOf(obj);
            const ptr_info = @typeInfo(T);

            // Here we need an inderection - a function which will take an *anyopaque and convert it
            // to corresponding type.
            const gen = struct {
                fn gen_say (ptr: *const anyopaque, s: []const u8) void {
                    const self: T = @ptrCast(@alignCast(ptr));
                    ptr_info.pointer.child.say(self, s);
                }
            };

            return .{ 
                .obj = obj, 
                .sayfn = gen.gen_say
            };
        }

        pub fn say(self: Speaker, s: []const u8) void {
            self.sayfn(self.obj, s);
        }
    };

    const Human = struct {
        id: u32,
        const Self = @This();
        pub fn speaker(self: *const Self) Speaker {
            return Speaker.init(self);
        }
        pub fn say(self: *const Self, s: []const u8) void {
            print("Human with ID:{} says {s}\n", .{ self.id, s });
        }
    };

    const Dog = struct {
        id: u32,
        const Self = @This();
        pub fn speaker(self: *const Self) Speaker {
            return Speaker.init(self);
        }
        pub fn say(self: *const Self, s: []const u8) void {
            print("Dog with ID:{} says {s}\n", .{ self.id, s });
        }
    };

    pub fn demo() void {
        const man1 = Human{ .id = 14 };
        const man2 = Human{ .id = 18 };
        const dog1 = Dog{ .id = 140 };
        const dog2 = Dog{ .id = 180 };

        var speaker = man1.speaker();
        speaker.say("Hello");

        speaker = man2.speaker();
        speaker.say("Ola");

        speaker = dog1.speaker();
        speaker.say("Baw Bow");

        speaker = dog2.speaker();
        speaker.say("<I do not bark>");
    }
};

pub fn main() !void {
    FirstInterfaceExample.demo();
    SecondInterfaceExample.demo();
}
