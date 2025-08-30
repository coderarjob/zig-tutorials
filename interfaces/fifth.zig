const std = @import("std");
const print = std.debug.print;

// This implementation is also quite simple and there are no anyopaque pointers. The interface
// exists as a separate field in the type which requires it (like a mixin). Calling methods on the
// interface calls the actual implementation and a pointer to the container struct is passed. I
// think this is similar to how the new Io interface works in the std lib.
const Speaker = struct {
    sayfn: *const fn (this: *const Speaker, what: []const u8) void,
    pub inline fn say(self: *const Speaker, what: []const u8) void {
        self.sayfn(self, what);
    }
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
                .sayfn = Human.say_hello,
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
                .sayfn = Dog.bark,
            },
        };
    }
};

pub fn demo() void {
    print("====== {s} ======\n", .{@typeName(@This())});

    const man = Human.create(12);
    const dog = Dog.create(283);

    var speaker = &man.speaker;
    speaker.say("Hello");
    // the `Speaker.say()` method is optional. We could instead call the interface function pointer
    // like so, `speaker.sayfn(speaker, "Hello")`. Note that without the `say` method, the function
    // pointer could itself be named `say`.

    speaker = &dog.speaker;
    speaker.say("Bark");
}
