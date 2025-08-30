const std = @import("std");
const print = std.debug.print;

// This the simplest with no need for opaque pointers, but the disadvantage is that the Speaker is
// need to change for every implementer type. But in some cases for internal interfaces this is the
// ideal solution and is the most faster.

const Speaker = union(enum) {
    dog: Dog,
    human: Human,

    pub fn say(self: Speaker, s: []const u8) void {
        switch (self) {
            .dog => |dog| return dog.bark(s),
            .human => |human| return human.speach(s),
        }
    }
};

const Human = struct {
    id: u32,
    const Self = @This();
    pub fn speaker(self: Self) Speaker {
        return Speaker{ .human = self };
    }
    pub fn speach(self: Self, s: []const u8) void {
        print("Human with ID:{} says {s}\n", .{ self.id, s });
    }
};

const Dog = struct {
    id: u32,
    const Self = @This();
    pub fn speaker(self: Self) Speaker {
        return Speaker{ .dog = self };
    }
    pub fn bark(self: Self, s: []const u8) void {
        print("Dog with ID:{} says {s}\n", .{ self.id, s });
    }
};

pub fn demo() void {
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human{.id = 343 };
    const dog = Dog{.id = 8307 };

    var speaker = man.speaker();
    speaker.say("Hello");

    speaker = dog.speaker();
    speaker.say("Bark");
}
