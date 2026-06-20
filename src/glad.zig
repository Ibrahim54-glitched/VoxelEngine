const std = @import("std");
const c = @import("c.zig");

const gl = c.glad;
const glfw = c.glfw;
const print = std.debug.print;

pub fn loadGlad(window: c.window) !void {
    const loader: gl.GLADloadproc = @ptrCast(&glfw.glfwGetProcAddress);
    if (gl.gladLoadGLLoader(loader) == 0) {
        print("Failed To Initialize GLAD\n", .{});
        return error.GLADInitializationFailed;
    }
    _ = glfw.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
}

fn framebuffer_size_callback(window: c.window, width: c_int, height: c_int) callconv(.c) void {
    _ = window;
    gl.glViewport(0, 0, width, height);
}
