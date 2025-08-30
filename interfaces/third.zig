const std = @import("std");
const print = std.debug.print;

// This is very similar to the second way, only that the 'say' method is passed into
// the 'init'. This makes it possible to have different functions in each type, just like the first
// way. Though I think the second way is the better.
// The previous advantages still hold.
const Speaker = struct {
    sayfn: *const fn (self: *const anyopaque, s: []const u8) void,
    obj: *const anyopaque,

    pub fn init(obj: anytype, sayfn: fn (@TypeOf(obj), []const u8) void) Speaker {
        const T = @TypeOf(obj);

        // Here we need an indirection - a function which will take an *anyopaque and convert it
        // to corresponding type.
        const gen = struct {
            fn gen_say(ptr: *const anyopaque, s: []const u8) void {
                const self: T = @ptrCast(@alignCast(ptr));
                //sayfn(self, s);
                @call(.always_inline, sayfn, .{ self, s });
            }
        };

        return .{
            .obj = obj,
            .sayfn = gen.gen_say,
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
        return Speaker.init(self, speach);
    }
    pub fn speach(self: *const Self, s: []const u8) void {
        print("Human with ID:{} says {s}\n", .{ self.id, s });
    }
};

const Dog = struct {
    id: u32,
    const Self = @This();
    pub fn speaker(self: *const Self) Speaker {
        return Speaker.init(self, bark);
    }
    pub fn bark(self: *const Self, s: []const u8) void {
        print("Dog with ID:{} says {s}\n", .{ self.id, s });
    }
};

pub fn demo() void {
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human{.id = 43 };
    const dog = Dog{.id = 837 };

    var speaker = man.speaker();
    speaker.say("Hello");

    speaker = dog.speaker();
    speaker.say("Bark");
}
