const std = @import("std");
const print = std.debug.print;

// This implementation is also quite simple and there are no anyopaque pointers. The interface
// exists as a separate field in the type which requires it (like a mixin). Calling methods on the
// interface calls the actual implementation and a pointer to the container struct is passed. I
// think this is similar to how the new Io interface works in the std lib.
const Speaker = struct {
    speak: *const fn (this: *const Speaker, what: []const u8) void,
    pub fn get_parent(self: *const Speaker, comptime T: type, comptime field_name: []const u8) *T {
        return @alignCast(@constCast(@fieldParentPtr(field_name, self)));
    }
};

const Human = struct {
    id: u32,
    speaker: Speaker,

    fn say_hello(this: *const Speaker, what: []const u8) void {
        const self: *Human = this.get_parent(Human, "speaker");
        print("Human with ID:{} says {s}\n", .{ self.id, what });
    }

    pub fn create(id: u32) Human {
        return .{
            .id = id,
            .speaker = .{
                .speak = Human.say_hello,
            },
        };
    }
};

const Dog = struct {
    id: u32,
    speaker: Speaker,

    fn bark(this: *const Speaker, what: []const u8) void {
        const self: *Dog = this.get_parent(Dog, "speaker");
        print("Dog with ID:{} says {s}\n", .{ self.id, what });
    }

    pub fn create(id: u32) Dog {
        return .{
            .id = id,
            .speaker = .{
                .speak = Dog.bark,
            },
        };
    }
};

pub fn demo() void {
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human.create(12);
    const dog = Dog.create(283);

    var speaker = &man.speaker;
    speaker.speak(speaker, "Hello");

    speaker = &dog.speaker;
    speaker.speak(speaker, "Bark");
}
