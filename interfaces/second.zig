const std = @import("std");
const print = std.debug.print;

// This is a bit more involved interface implementation, but solves the problems described above.
// Another advantage of the following is that since now the compiler can infer exact signature of
// the function at compiletime (within the gen_say), we could now use @call built-in function with
// always_inline modifier.
// Source: https://www.openmymind.net/Zig-Interfaces/

const Speaker = struct {
    sayfn: *const fn (self: *const anyopaque, s: []const u8) void,
    obj: *const anyopaque,

    pub fn init(obj: anytype) Speaker {
        const T = @TypeOf(obj);
        const ptr_info = @typeInfo(T);

        // Here we need an indirection - a function which will take an *anyopaque and convert it
        // to corresponding type.
        const gen = struct {
            fn gen_say(ptr: *const anyopaque, s: []const u8) void {
                const self: T = @ptrCast(@alignCast(ptr));
                // We can call the function directly using this syntax, but @call allows us to
                // pass some modifiers which might be helpful.
                //ptr_info.pointer.child.say(self, s);

                // For info on the @call function https://ziglang.org/documentation/0.14.1/#call
                @call(.always_inline, ptr_info.pointer.child.say, .{ self, s });
            }
        };

        return .{ .obj = obj, .sayfn = gen.gen_say };
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
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human{.id = 193 };
    const dog = Dog{.id = 230 };

    var speaker = man.speaker();
    speaker.say("Hello");

    speaker = dog.speaker();
    speaker.say("Bark");
}
