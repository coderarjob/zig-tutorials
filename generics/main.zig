const std = @import("std");
const print = std.debug.print;

fn ListType(comptime T: type, comptime Functions: type) type {
    const compare_fn: fn (a: T, b: T) bool = Functions.compare_fn;

    return struct {
        pub fn search(list: []const T, item: T) bool {
            for (list) |li| {
                print("{any}, {any}\n", .{ li, item });
                if (compare_fn(li, item)) return true;
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

pub fn main() void {
    const person_list = [_]Person{ 
        .{ .id = @enumFromInt(10) },
        .{ .id = @enumFromInt(12) },
        .{ .id = @enumFromInt(120) }
    };

    const animal_list = [_]Animal{
        .{ .badgeNumber = @enumFromInt(210) },
        .{ .badgeNumber = @enumFromInt(212) },
        .{ .badgeNumber = @enumFromInt(220) }
    };

    const p = Person{ .id = @enumFromInt(12) };
    const ra = PersonList.search(&person_list, p);
    print("Person search result: {}\n", .{ra});

    const a = Animal{ .badgeNumber = @enumFromInt(12) };
    const rb = AnimalList.search(&animal_list, a);
    print("Animal search result: {}\n", .{rb});
}
