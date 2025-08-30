const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn LinkedList(T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            item: T,
            next: *@This(),
            prev: *@This(),

            fn new(gpa: Allocator, item: T) !*@This() {
                const ret = try gpa.create(@This());
                ret.item = item;
                ret.next = ret;
                ret.prev = ret;
                return ret;
            }
        };

        const Iterator = struct {
            item: ?*const Node,
            list: *const LinkedList(T),

            fn new(list: *const LinkedList(T)) @This() {
                return .{ .item = list.head, .list = list };
            }

            pub fn next_node(self: *@This()) ?*const Node {
                if (self.list.head != null) {
                    if (self.item) |node| {
                        self.item = node.next;
                        return node;
                    }
                }
                return null;
            }

            pub fn next(self: *@This()) ?T {
                if (self.next_node()) |node| {
                    return node.item;
                }
                return null;
            }
        };

        length: usize,
        head: ?*Node,
        allocator: Allocator,

        pub fn new(gpa: Allocator) LinkedList(T) {
            return .{
                .length = 0,
                .head = null,
                .allocator = gpa,
            };
        }

        pub fn free(self: *Self) void {
            while (self.head) |head| {
                self.remove(head);
            }
        }

        pub fn getIterator(self: *const Self) Iterator {
            return Iterator.new(self);
        }

        pub fn remove(self: *Self, node: *const Node) void {
            node.next.prev = node.prev;
            node.prev.next = node.next;

            // We are removing head itself, so head needs to be updated When there remains no items
            // left, head is set to null, otherwise it will point to its next node.
            if (node == self.head.?) {
                self.head = if (self.length == 1) null else node.next;
            }

            self.allocator.destroy(node);

            self.length -= 1;
            return;
        }

        pub fn insert(self: *Self, item: T) !void {
            const newNode = try Node.new(self.allocator, item);

            if (self.head) |head| {
                newNode.next = head;
                newNode.prev = head.prev;
                head.prev.next = newNode;
                head.prev = newNode;
            } else {
                self.head = newNode;
            }
            self.length += 1;
        }
    };
}

const expect = std.testing.expect;
const expectEqualDeep = std.testing.expectEqualDeep;

test "creation and freeing" {
    const allocator = std.testing.allocator;

    var ll = @This().LinkedList(u32).new(allocator);
    defer ll.free();

    try ll.insert(32);
}

test "traversal" {
    const allocator = std.testing.allocator;
    var ll = @This().LinkedList(u32).new(allocator);
    defer ll.free();

    try ll.insert(32);
    try ll.insert(42);
    try ll.insert(52);
    try expect(ll.length == 3);

    var iter = ll.getIterator();
    try expect(iter.next() == 32);
    try expect(iter.next() == 42);
    try expect(iter.next() == 52);
    try expect(iter.next() == 32);
}

test "removal" {
    const allocator = std.testing.allocator;

    var ll = @This().LinkedList(u32).new(allocator);
    defer ll.free();

    try ll.insert(32);
    try ll.insert(42);
    try ll.insert(52);
    try expect(ll.length == 3);

    var iter = ll.getIterator();
    ll.remove(iter.next_node().?);
    try expect(ll.length == 2);

    try expect(iter.next() == 42);
    try expect(iter.next() == 52);
    try expect(iter.next() == 42);
}

test "remove all" {
    const allocator = std.testing.allocator;

    var ll = @This().LinkedList(u32).new(allocator);
    defer ll.free();

    try ll.insert(32);
    try ll.insert(42);
    try ll.insert(52);
    try expect(ll.length == 3);

    var iter = ll.getIterator();
    ll.remove(iter.next_node().?);
    ll.remove(iter.next_node().?);
    ll.remove(iter.next_node().?);
    try expect(ll.length == 0);

    try expect(iter.next() == null);
}

test "list of objects" {
    const allocator = std.testing.allocator;

    const PersonName = struct {
        firstName: []const u8,
        lastName: []const u8,
    };

    const Person = struct {
        id: u32,
        name: PersonName,
    };

    var ll = @This().LinkedList(Person).new(allocator);
    defer ll.free();

    const p1 = Person{ .id = 13, .name = .{ .firstName = "A", .lastName = "BC" } };
    const p2 = Person{ .id = 22, .name = .{ .firstName = "D", .lastName = "EF" } };
    const p3 = Person{ .id = 31, .name = .{ .firstName = "X", .lastName = "YZ" } };

    try ll.insert(p1);
    try ll.insert(p2);
    try ll.insert(p3);
    try expect(ll.length == 3);

    var iter = ll.getIterator();
    ll.remove(iter.next_node().?);
    try expect(ll.length == 2);

    try expectEqualDeep(iter.next().?, p2);
    try expectEqualDeep(iter.next().?, p3);
}
