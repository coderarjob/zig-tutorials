const std = @import("std");
const common = @import("common.zig");

pub fn main() !void {
    common.section("Error handling - using try");
    // try evaluates an error union expression. If it is an error, it returns from the current
    // function with the same error. Otherwise, the expression results in the unwrapped value.
    //const id = try openFile("");
    // 'try' behaves similar to the following line.
    // const id = openFile("") catch |err| return err;

    common.section("Error handling - handling errors using switch");
    //const id = openFile("foo") catch |err| {
    //    switch (err) {
    //        error.fileNotFound => @panic("File was not found."),
    //        error.invalidInput => @panic("Input to the function was invalid."),
    //    }
    //};
    //log(id, "Starting up..");

    common.section("Error handling - handling errors using if statement");
    //if (openFile("foo")) |id| {
    //    log(id, "Starting up..");
    //} else |_| {
    //    @panic("File open failed due to an error");
    //}

    // errdefer evaluates the deferred expression on block exit path if and only if the function
    // returned with an error from the block.
    // See: https://ziglang.org/documentation/0.14.1/#errdefer
    common.section("Error handling - using errdefer");
    const id = try openFile("");
    errdefer std.debug.print("Freeing up after error\n", .{});
    log(id, "Starting up..");
}

fn openFile(file: []const u8) error{ fileNotFound, invalidInput }!u32 {
    if (file.len == 0) return error.invalidInput;
    if (!std.ascii.startsWithIgnoreCase("/", file)) return error.fileNotFound;

    return 42;
}

fn log(file: u32, msg: []const u8) void {
    _ = file;
    _ = msg;
}
