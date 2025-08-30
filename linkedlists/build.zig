const std = @import("std");

pub fn build(b: *std.Build) void {

    const optimize = b.standardOptimizeOption(.{});
    
    const lib = b.addLibrary(.{
        .name = "LinkedList",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .optimize = optimize,
            .target = b.standardTargetOptions(.{})
        }),
    });

    b.installArtifact(lib);

    const test_exe = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/tests.zig"),
            .optimize = optimize,
            .target = b.graph.host
        }),
    });

    const test_run = b.addRunArtifact(test_exe);
    test_run.skip_foreign_checks = true;

    b.step("test", "Runs unittests").dependOn(&test_run.step);
}
