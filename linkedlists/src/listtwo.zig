const std = @import("std");
const expect = std.testing.expect;
const assert = std.debug.assert;

const Node = struct {
    next: ?*Node = null,
    prev: ?*Node = null,

    pub fn init(self: *Node) void {
        self.next = self;
        self.prev = self;
    }

    pub fn insert_before(self: *Node, item: *Node) void {
        // Self must be a valid non-deleted node
        assert(self.next != null and self.prev != null);

        item.next = self;
        item.prev = self.prev;
        self.prev.?.next = item;
        self.prev = item;
    }

    pub fn insert_after(self: *Node, item: *Node) void {
        // Self must be a valid non-deleted node
        assert(self.next != null and self.prev != null);

        item.prev = self;
        item.next = self.next;
        self.next.?.prev = item;
        self.next = item;
    }

    pub fn remove(self: *Node) void {
        // Self must be a valid non-deleted node
        assert(self.next != null and self.prev != null);

        self.prev.?.next = self.next;
        self.next.?.prev = self.prev;
        self.next = null;
        self.prev = null;
    }

    pub fn get_parent(self: *const Node, comptime T: type, comptime field_name: []const u8) *T {
        return @alignCast(@constCast(@fieldParentPtr(field_name, self)));
    }
};

const Iterator = struct {
    head: *Node,
    node: *Node,

    pub fn get_iterator(head: *Node) Iterator {
        return .{
            .head = head,
            .node = head.next.?,
        };
    }

    pub fn next(self: *Iterator) ?*Node {
        if (self.node != self.head) {
            const ret = self.node;
            self.node = self.node.next.?;
            return ret;
        }
        return null;
    }
};

test "creation & initialization" {
    var head = Node{};
    head.init();

    try expect(head.next == &head);
    try expect(head.prev == &head);
}

test "node traversal" {
    var head = Node{};
    var node1 = Node{};
    var node2 = Node{};
    head.init();
    node1.init();
    node2.init();

    head.insert_after(&node1);
    head.insert_after(&node2);

    // head <--> node2 <--> node1
    //   ▲                   ▲
    //   └───────────────────┘

    try expect(head.next == &node2);
    try expect(head.prev == &node1);

    try expect(node1.prev == &node2);
    try expect(node1.next == &head);

    try expect(node2.prev == &head);
    try expect(node2.next == &node1);
}

test "removal" {
    var head = Node{};
    var node1 = Node{};
    var node2 = Node{};
    head.init();
    node1.init();
    node2.init();

    head.insert_after(&node1);
    head.insert_after(&node2);

    // head <--> node2 <--> node1
    //   ▲                   ▲
    //   └───────────────────┘

    node2.remove();

    try expect(node2.next == null);
    try expect(node2.prev == null);

    // head <------------> node1
    //   ▲                   ▲
    //   └───────────────────┘

    try expect(head.next == &node1);
    try expect(head.prev == &node1);

    try expect(node1.prev == &head);
    try expect(node1.next == &head);
}

const Part = struct {
    number: u32,
    available_list_node: Node = .{},

    const Self = @This();
    pub fn new(num: u32) Self {
        var ret = Self{ .number = num };
        ret.available_list_node.init();
        return ret;
    }
};

test "object traversal" {
    var available_list_head = Node{};
    available_list_head.init();

    var part1 = Part.new(22);
    var part2 = Part.new(42);

    available_list_head.insert_after(&part1.available_list_node);
    available_list_head.insert_after(&part2.available_list_node);

    var iter = Iterator.get_iterator(&available_list_head);

    var part = iter.next().?.get_parent(Part, "available_list_node");
    try expect(part.number == 42);

    part = iter.next().?.get_parent(Part, "available_list_node");
    try expect(part.number == 22);

    try expect(iter.next() == null);
}

test "object removal" {
    var available_list_head = Node{};
    available_list_head.init();

    var part1 = Part.new(22);
    var part2 = Part.new(42);
    var part3 = Part.new(52);

    available_list_head.insert_after(&part1.available_list_node);
    available_list_head.insert_after(&part2.available_list_node);
    available_list_head.insert_after(&part3.available_list_node);

    part2.available_list_node.remove();

    var iter = Iterator.get_iterator(&available_list_head);

    var part = iter.next().?.get_parent(Part, "available_list_node");
    try expect(part.number == 52);

    part = iter.next().?.get_parent(Part, "available_list_node");
    try expect(part.number == 22);

    try expect(iter.next() == null);
}
