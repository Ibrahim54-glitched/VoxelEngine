const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfw_dep = b.dependency("glfw_zig", .{
        .target = target,
        .optimize = optimize
    });

    const glad_dep = b.dependency("zig_glad", .{
        .target = target,
        .optimize = optimize
    });

    const mod = b.addModule("VoxelEngine", .{
            .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    mod.linkLibrary(glfw_dep.artifact("glfw"));
    mod.linkLibrary(glad_dep.artifact("glad"));

    const exe = b.addExecutable(.{
        .name = "VoxelEngine",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "VoxelEngine", .module = mod },
            },
            }),
        .use_llvm = true,
        .use_lld = true,
    });

    exe.root_module.linkLibrary(glfw_dep.artifact("glfw"));
    exe.root_module.linkLibrary(glad_dep.artifact("glad"));

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
}
