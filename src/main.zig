const std = @import("std");

pub fn main() anyerror!void {
    var a = "as";
    const b = 2;
    std.log.info("Hello world! All your codebase are belong to us.", .{});
    std.log.debug("debug message.", .{});
    std.log.debug("a is {s}, b is {d}", .{ a, b });
    try heapLeak();
    try loop();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}

fn heapLeak() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!general_purpose_allocator.deinit());
    const gpa = general_purpose_allocator.allocator();
    const u32_ptr = try gpa.create(u32);
    _ = u32_ptr;
}

fn loop() !void {
    const stdout = std.io.getStdOut().writer();
    var i: usize = 1;
    while (i <= 16) : (i += 1) {
        if (i % 15 == 0) {
            try stdout.writeAll("ziggg\n");
        } else if (i % 3 == 0) {
            try stdout.writeAll("zigg\n");
        } else {
            try stdout.print("{d}\n", .{i});
        }
    }
}

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        gpa: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,
        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .start = null,
                .end = null,
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }
    };
}

test "Queue" {
    var int_queue = Queue(i32).init(std.testing.allocator);
    try int_queue.enqueue(1);
    try std.testing.expectEqual(int_queue.dequeue(), 1);
}
