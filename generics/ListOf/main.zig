const std = @import("std");
const print = std.debug.print;

fn ListType(comptime T: type, comptime Functions: type) type {
    return struct {
        comptime compare_fn: fn (a: T, b: T) bool = Functions.compare_fn,
        inner_list: std.ArrayListUnmanaged(T) = .empty,

        const Self = @This();

        pub fn reserve(self: *Self, gpa: std.mem.Allocator, count: usize) !void {
            try self.inner_list.ensureTotalCapacityPrecise(gpa, count);
        }

        pub fn deinit(self: *Self, gpa: std.mem.Allocator) void {
            self.inner_list.deinit(gpa);
        }

        pub fn insert(self: *Self, item: T) void {
            self.inner_list.appendAssumeCapacity(item);
        }

        pub fn search(self: Self, item: T) bool {
            for (self.inner_list.items) |li| {
                if (self.compare_fn(li, item)) return true;
            }
            return false;
        }
    };
}

const Person = struct {
    id: ID = .undefined,

    const ID = enum(u32) { undefined, _ };
};

const Animal = struct {
    badgeNumber: BadgeNumber = .undefined,

    const BadgeNumber = enum(u32) { undefined, _ };
};

const PersonList = ListType(Person, struct {
    pub fn compare_fn(a: Person, b: Person) bool {
        return a.id == b.id;
    }
});

const AnimalList = ListType(Animal, struct {
    pub fn compare_fn(a: Animal, b: Animal) bool {
        return a.badgeNumber == b.badgeNumber;
    }
});

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var person_list = PersonList{};
    try person_list.reserve(allocator, 3);
    defer person_list.deinit(allocator);

    var animal_list = AnimalList{};
    try animal_list.reserve(allocator, 3);
    defer animal_list.deinit(allocator);

    person_list.insert(.{ .id = @enumFromInt(10) });
    person_list.insert(.{ .id = @enumFromInt(11) });
    person_list.insert(.{ .id = @enumFromInt(12) });

    animal_list.insert(.{ .badgeNumber = @enumFromInt(210) });
    animal_list.insert(.{ .badgeNumber = @enumFromInt(211) });
    animal_list.insert(.{ .badgeNumber = @enumFromInt(212) });

    const p = Person{ .id = @enumFromInt(12) };
    const ra = person_list.search(p);
    print("{any} found: {}\n", .{ p, ra });

    const a = Animal{ .badgeNumber = @enumFromInt(212) };
    const rb = animal_list.search(a);
    print("{any} found: {}\n", .{ a, rb });
}
